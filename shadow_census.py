#!/usr/bin/env python
"""Report names that a USE statement would capture.

YREC's COMMON blocks are being converted to F90 modules imported with a
blanket USE. That is safe for the conversion itself, because three
properties hold across the code: every block is declared identically in
every file that holds it, no member name appears in two blocks, and no
member name is also a procedure name. A blanket USE placed where the
COMMON declaration stood therefore imports exactly the names that
declaration already made global in that scoping unit.

The risk is the next edit. If a file uses a name as a local and later
imports a module that exports the same name, the local is captured. How
that fails depends on how the local is declared:

  dummy argument    -> compile error, loud
  declared local    -> compile error, loud
  implicitly typed  -> SILENT; the local simply becomes the global

This script finds those cases. Two checks are worth running by habit:

  before adding a USE to a file
      shadow_census.py --file wrtout.f
    lists the names that file already uses which some module would
    capture, and says whether each would be loud or silent.

  before adding a member to a module
      shadow_census.py --member IMAX
    lists every file that already uses that name, so a new member cannot
    quietly collide with an existing local.

With no arguments it prints the whole census, which is the summary
recorded in KNOWN_ISSUES.md issue 22.

Sources are parsed at 132 columns, the width the Makefile compiles at.
Parsing at 72 silently truncates long declarations and invents
differences that are not there; that mistake cost real time once already.
"""
import argparse
import glob
import os
import re
import sys
from collections import defaultdict

WIDTH = 132

# Intrinsics, keywords and names too short for a word-bounded match to mean
# anything. Excluded from the census as noise rather than evidence.
NOISE = {'I', 'J', 'K', 'M', 'N', 'X', 'Y', 'Z', 'T', 'P', 'R', 'S', 'O',
         'MAX', 'MIN', 'ABS', 'LOG', 'EXP', 'SQRT', 'SUM', 'INDEX', 'SIZE'}

TYPEDECL = re.compile(
    r'\s*(REAL\*?\d*|INTEGER\*?\d*|LOGICAL\*?\d*|DOUBLE\s+PRECISION'
    r'|CHARACTER\*?\d*|DIMENSION|PARAMETER|EXTERNAL|SAVE)\b(.*)', re.I)
HEADER = re.compile(
    r'\s*(?:RECURSIVE\s+)?(?:SUBROUTINE|(?:REAL\*?\d*|INTEGER\*?\d*'
    r'|LOGICAL\*?\d*|DOUBLE\s+PRECISION)?\s*FUNCTION)\s+'
    r'([A-Za-z0-9_]+)\s*\(([^)]*)\)', re.I)
COMMON = re.compile(r'\s*COMMON\s*/\s*([A-Za-z0-9_]+)\s*/(.*)')
USE = re.compile(r'\s*USE\s+([A-Za-z0-9_]+)', re.I)
MODULE = re.compile(r'\s*MODULE\s+([A-Za-z0-9_]+)\s*$', re.I)
# A module variable declaration, e.g. "REAL*8    :: RESCAL(4,50)".
MODVAR = re.compile(r'\s*(?:REAL|INTEGER|LOGICAL|DOUBLE\s+PRECISION|CHARACTER)'
                    r'\*?\d*\s*(?:,[^:]*)?::\s*(.*)', re.I)


def block_name(module):
    """RUNLOOP_MOD -> RUNLOOP, so converted blocks keep one identity."""
    m = module.upper()
    return m[:-4] if m.endswith('_MOD') else m


def is_comment(line):
    return bool(line) and line[0] in 'Cc*!'


def logical_lines(path):
    """Statements, with fixed-form continuations joined.

    A comment or blank line inside a continuation sequence does not end the
    statement, so those are skipped while looking for the continuation.
    """
    lines = [l.rstrip('\n') for l in open(path, errors='replace')]
    i, out = 0, []
    while i < len(lines):
        line = lines[i]
        if is_comment(line) or not line.strip():
            i += 1
            continue
        stmt = line[6:WIDTH] if len(line) > 6 else ''
        j = i + 1
        while j < len(lines):
            nxt = lines[j]
            if is_comment(nxt) or not nxt.strip():
                j += 1
                continue
            if len(nxt) > 5 and nxt[5] not in ' 0':
                stmt += nxt[6:WIDTH] if len(nxt) > 6 else ''
                j += 1
                continue
            break
        out.append(stmt)
        i = j
    return out


def comma_names(text):
    """Top-level comma-separated names, array and length suffixes dropped."""
    out, depth, cur = [], 0, ''
    for ch in text:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch == ',' and depth == 0:
            out.append(cur)
            cur = ''
            continue
        if depth == 0 and ch not in '()':
            cur += ch
    out.append(cur)
    return {n.split('(')[0].split('*')[0].strip().upper()
            for n in out if n.strip()}


def scan(srcdir):
    """Return (members, declares, imports, locals_by_file)."""
    members = {}                      # NAME -> owning block
    block_members = defaultdict(set)  # block -> {NAME}
    declares = defaultdict(set)       # file -> blocks declared
    imports = defaultdict(set)        # file -> modules USEd
    info = {}                         # file -> (refs, dummies, declared)

    for path in sorted(glob.glob(os.path.join(srcdir, '*.f'))):
        fname = os.path.basename(path)
        stmts = logical_lines(path)
        dummies, declared = set(), set()
        # A module file contributes its variables as that block's members,
        # so the census keeps working as blocks convert. Without this it
        # goes blind on every block already turned into a module: the
        # members are in no COMMON statement any more, and a collision
        # with them stops being reported.
        in_module = None
        for s in stmts:
            mod = MODULE.match(s)
            if mod:
                in_module = block_name(mod.group(1))
                continue
            if in_module:
                mv = MODVAR.match(s)
                if mv:
                    # Strip any initializer, so "JSON = 5000" yields JSON.
                    names = {n.split('=')[0].strip()
                             for n in comma_names(mv.group(1))}
                    block_members[in_module] |= {n for n in names if n}
                    # The module's own file holds the block, or it would be
                    # reported as shadowing the names it defines.
                    declares[fname].add(in_module)
                    continue
            m = COMMON.match(s)
            if m:
                blk = m.group(1).upper()
                names = comma_names(m.group(2))
                block_members[blk] |= names
                declares[fname].add(blk)
                continue
            u = USE.match(s)
            if u:
                imports[fname].add(block_name(u.group(1)))
            h = HEADER.match(s)
            if h:
                dummies |= comma_names(h.group(2))
            t = TYPEDECL.match(s)
            if t:
                declared |= comma_names(t.group(2))
        text = ' '.join(s.upper() for s in stmts if not COMMON.match(s))
        refs = set(re.findall(r'\b[A-Z][A-Z0-9_]*\b', text))
        info[fname] = (refs, dummies, declared)

    for blk, names in block_members.items():
        for n in names:
            members[n] = blk
    return members, block_members, declares, imports, info


def kind_of(name, dummies, declared):
    if name in dummies:
        return 'dummy-arg', 'loud'
    if name in declared:
        return 'declared-local', 'loud'
    return 'IMPLICIT-local', 'SILENT'


def shadows(members, declares, imports, info):
    """(file, name, owner, kind, loudness) for every potential capture."""
    rows = []
    for fname, (refs, dummies, declared) in info.items():
        held = declares[fname] | imports[fname]
        for name in sorted(refs):
            if name in NOISE or len(name) < 3:
                continue
            owner = members.get(name)
            if owner and owner not in held:
                kind, loud = kind_of(name, dummies, declared)
                rows.append((fname, name, owner, kind, loud))
    return rows


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--src', default=os.path.join(here, 'src'),
                    help='source directory (default: ./src)')
    ap.add_argument('--file', help='what a USE added to this file would capture')
    ap.add_argument('--member', help='which files already use this name')
    args = ap.parse_args()

    members, block_members, declares, imports, info = scan(args.src)
    rows = shadows(members, declares, imports, info)

    if args.member:
        name = args.member.upper()
        owner = members.get(name)
        print(f'{name}: ' + (f'currently a member of {owner}'
                             if owner else 'not currently a block member'))
        hits = [(f, kind_of(name, d, dc))
                for f, (refs, d, dc) in info.items() if name in refs]
        if not hits:
            print('  referenced in no file: safe to add as a module member')
            return 0
        print(f'  referenced in {len(hits)} file(s):')
        for f, (kind, loud) in sorted(hits):
            held = declares[f] | imports[f]
            legit = owner in held if owner else False
            tag = 'via the block/module' if legit else f'{kind} -> {loud}'
            print(f'    {f:<20} {tag}')
        return 0

    if args.file:
        target = os.path.basename(args.file)
        mine = [r for r in rows if r[0] == target]
        if target not in info:
            print(f'{target}: not found under {args.src}')
            return 1
        print(f'{target}: {len(mine)} name(s) a new USE could capture')
        for _, name, owner, kind, loud in sorted(mine, key=lambda r: r[1]):
            print(f'  {name:<16} from {owner:<14} {kind:<16} {loud}')
        if not mine:
            print('  none: any USE can be added safely')
        return 0

    by_kind = defaultdict(list)
    for r in rows:
        by_kind[r[3]].append(r)
    total = len(rows)
    files = len({r[0] for r in rows})
    print(f'files examined                    : {len(info)}')
    print(f'blocks                            : {len(block_members)}')
    print(f'distinct member names             : {len(members)}')
    print(f'files with at least one shadow     : {files}')
    print(f'total (file, name) pairs           : {total}')
    print()
    for kind in ('dummy-arg', 'declared-local', 'IMPLICIT-local'):
        n = len(by_kind[kind])
        pct = (100.0 * n / total) if total else 0.0
        loud = 'SILENT capture' if kind == 'IMPLICIT-local' else 'compile error'
        print(f'  {kind:<16} {n:>4} ({pct:>3.0f}%)  {loud}')
    print()
    print('The silent set, which is the one that matters:')
    for f, name, owner, _, _ in sorted(by_kind['IMPLICIT-local']):
        print(f'  {f:<20} {name:<16} would be captured from {owner}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
