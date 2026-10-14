#!/usr/bin/env python
"""Find floating literals that lose precision because they lack a D exponent.

In a code where floating point is REAL*8 throughout, a literal written
without a D exponent is a default-real (single precision) constant. When
it reaches a REAL*8 variable it is widened, so the stored value is the
*single* approximation of the decimal, not the decimal itself:

    0.9828   -> 0.98280000686645508
    0.9828D0 -> 0.98280000000000000

But most such literals are harmless, and separating the two cases is the
whole point of this audit. A decimal that is exactly representable in
binary32 -- 0.0, 1.0, 0.5, 2.0, 0.25 -- widens losslessly, so writing it
without D0 costs nothing. Only literals where the widened single differs
from the exact double are defects.

An E exponent is single precision too: 1.32E30 is as lossy as 1.32.

What this does NOT do is decide intent. It reports where the stored value
differs from what the decimal says, which is the objective part; whether
each one matters is a physics judgement.

Sources are parsed at 132 columns and comment lines are skipped.
"""
import collections
import glob
import os
import re
import struct
import sys

WIDTH = 132

# A Fortran real literal: digits with a decimal point or an exponent.
# Captures the exponent letter so D-exponent literals can be excluded.
LITERAL = re.compile(r'(?<![A-Za-z0-9_.])'
                     r'(\d+\.\d*|\.\d+|\d+)'
                     r'(?:([EeDdQq])([+-]?\d+))?')


def single_widen(text):
    """The double you get by parsing as single then widening, or None."""
    try:
        exact = float(text)
    except ValueError:
        return None, None
    try:
        as_single = struct.unpack('f', struct.pack('f', exact))[0]
    except (OverflowError, struct.error):
        return exact, None
    return exact, as_single


def is_comment(line):
    return bool(line) and line[0] in 'Cc*!'


FORMAT_STMT = re.compile(r'\s*\d*\s*FORMAT\s*\(', re.I)


def is_continuation(line):
    return len(line) > 5 and line[5] not in ' 0'


def code_text(line):
    """Statement text with any trailing ! comment and quotes removed."""
    body = line[6:WIDTH] if len(line) > 6 else ''
    out, inside = '', False
    i, n = 0, len(body)
    while i < n:
        ch = body[i]
        if ch == "'":
            if inside and i + 1 < n and body[i + 1] == "'":
                i += 2
                continue
            inside = not inside
            i += 1
            continue
        if ch == '!' and not inside:
            break
        out += ' ' if inside else ch
        i += 1
    return out


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    args = [a for a in sys.argv[1:] if not a.startswith('-')]
    want_list = '--list' in sys.argv[1:]
    srcdir = args[0] if args else os.path.join(here, 'src')
    lossy = []
    exact_ok = 0
    d_form = 0
    integers = 0

    fmt_skipped = 0
    for path in sorted(glob.glob(os.path.join(srcdir, '*.f'))):
        fname = os.path.basename(path)
        in_format = False
        for lineno, raw in enumerate(open(path, errors='replace'), 1):
            raw = raw.rstrip('\n')
            if is_comment(raw):
                continue
            # FORMAT statements are full of things that look like real
            # literals but are edit descriptors: 1P6E13.5, 16E16.8, 12E10.3.
            # They are not numeric constants and carry no precision, so
            # counting them inflated the earlier figure by 46. The flag is
            # carried across continuation lines, since a long FORMAT wraps.
            if not is_continuation(raw):
                in_format = bool(FORMAT_STMT.match(
                    raw[6:WIDTH] if len(raw) > 6 else ''))
            if in_format:
                fmt_skipped += len(
                    [m for m in LITERAL.finditer(code_text(raw))])
                continue
            text = code_text(raw)
            for m in LITERAL.finditer(text):
                mant, expch, expdig = m.group(1), m.group(2), m.group(3)
                token = m.group(0)
                # An integer with no point and no exponent is not a real.
                if '.' not in mant and not expch:
                    integers += 1
                    continue
                if expch and expch in 'Dd':
                    d_form += 1
                    continue
                if expch and expch in 'Qq':
                    continue
                exact, widened = single_widen(
                    mant + ('e' + expdig if expch else ''))
                if exact is None or widened is None:
                    continue
                if exact == widened:
                    exact_ok += 1
                else:
                    rel = abs(widened - exact) / abs(exact) if exact else 0.0
                    lossy.append((fname, lineno, token, exact, widened, rel))

    print(f'D-exponent literals (already REAL*8)      : {d_form}')
    print(f'no D, but exactly representable (harmless): {exact_ok}')
    print(f'no D, and LOSSY when widened              : {len(lossy)}')
    print(f'(tokens inside FORMAT statements, skipped : {fmt_skipped})')
    print()
    byfile = collections.Counter(f for f, *_ in lossy)
    print(f'lossy literals span {len(byfile)} files; worst:')
    for fname, n in byfile.most_common(12):
        print(f'   {fname:<20} {n}')
    print()
    print('largest relative errors:')
    for fname, lineno, tok, exact, wide, rel in sorted(
            lossy, key=lambda r: -r[5])[:12]:
        print(f'   {fname}:{lineno}  {tok:<14} {exact!r} -> {wide!r} '
              f'(rel {rel:.2e})')
    if want_list:
        print()
        print('every lossy literal, file:line order (--list):')
        for fname, lineno, tok, exact, wide, rel in sorted(
                lossy, key=lambda r: (r[0], r[1])):
            print(f'   {fname}:{lineno}: {tok}')
    else:
        print()
        print('pass --list for all of them, in file:line order.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
