#!/usr/bin/env python
"""Install new test references from a completed suite run.

This is step 7 of REBASELINE_PROTOCOL.md. Read the protocol first: this
script only copies files, and it does none of the review in step 5.

Usage, from anywhere:

    python rebaseline.py pass2.log                  # dry run
    python rebaseline.py pass2.log --hold CASE ...  # keep old references
    python rebaseline.py pass2.log --apply          # install

pass2.log is the captured output of `pytest -v test_all.py` from the
second full pass. For each case collected by test_all.py, the script
copies <case>.short, .store and .track from the shared output directory
into <test dir>/standard/, but only after every case passes these checks:

  - the case appears in the log. A case the log does not mention was not
    run, so its output is not from this binary.
  - the case exited cleanly. A case passes this check if it is PASSED, or
    FAILED only because "Output differs from reference standard". Any
    other failure, an abort included, blocks the install, because an
    aborted case still leaves fresh partial outputs behind (issue 35).
  - every output is newer than the binary. The output directory is shared
    and persists between runs (issue 16), so an older file was written by
    an earlier binary.
  - every existing reference has a matching output. A missing output means
    the case no longer writes that file, which needs explaining first.

One exception is allowed: a zero-byte output whose reference is also
empty is skipped rather than reported as stale. Some crash-terminated
cases never write a .store, and the empty file in the output directory is
an old leftover (issue 33).

Any failed check stops the whole install, not just the affected case.
Fix the cause, or hold the case back with --hold.
"""
import argparse
import os
import re
import shutil
import sys

SUFFIXES = ('.short', '.store', '.track')
CLEAN_FAILURE = 'Output differs from reference standard'

result_re = re.compile(r'^test_all\.py::test_yrec\[(.+)\] (PASSED|FAILED|ERROR)\b')
section_re = re.compile(r'^_+ test_yrec\[(.+)\] _+$')
assertion_re = re.compile(r'^E\s+AssertionError: (.*)$')
summary_re = re.compile(r'^=+ .*\b(passed|failed)\b.* in [\d.]+s')


def parse_log(path):
    '''Return ({test id: PASSED/FAILED/ERROR}, {test id: first assertion
    message}, whether the session ran to completion).'''
    status, reason = {}, {}
    section = None
    finished = False
    with open(path, errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            m = result_re.match(line)
            if m:
                status[m.group(1)] = m.group(2)
                continue
            m = section_re.match(line)
            if m:
                section = m.group(1)
                continue
            m = assertion_re.match(line)
            if m and section is not None and section not in reason:
                reason[section] = m.group(1).strip()
                continue
            if summary_re.match(line):
                finished = True
    return status, reason, finished


def main():
    ap = argparse.ArgumentParser(
        description='Install new test references from a completed suite '
                    'run (REBASELINE_PROTOCOL.md, step 7).')
    ap.add_argument('log', help='captured output of `pytest -v test_all.py`')
    ap.add_argument('--hold', action='append', default=[], metavar='CASE',
                    help='case base name whose old reference is kept; '
                         'may be repeated')
    ap.add_argument('--output-dir', default=os.environ.get('YREC_OUTPUT'),
                    help='directory the run wrote to (default: $YREC_OUTPUT)')
    ap.add_argument('--apply', action='store_true',
                    help='install the files; without this, only report')
    args = ap.parse_args()

    log = os.path.abspath(args.log)
    if not args.output_dir:
        sys.exit('YREC_OUTPUT is not set; pass --output-dir')
    outdir = os.path.abspath(args.output_dir)

    # test_all reads pytest.ini from the working directory.
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sys.path.insert(0, os.getcwd())
    import test_all as ta

    bin_mtime = os.path.getmtime(ta.yrec_exe)
    if os.path.getmtime(log) < bin_mtime:
        sys.exit(f'{log} is older than {ta.yrec_exe}; it is not a run of '
                 'this binary')
    status, reason, finished = parse_log(log)
    if not finished:
        sys.exit(f'{log} has no final pytest summary line; the run did not '
                 'finish, or was not captured in full')
    if not status:
        sys.exit(f'{log} records no test_yrec results; was pytest run '
                 'with -v?')

    bases = {nml1.replace('.nml1', '') for _, nml1, _ in ta.test_cases}
    unknown = sorted(set(args.hold) - bases)
    if unknown:
        sys.exit(f'--hold names cases that are not collected: {unknown}')
    hold = set(args.hold)

    plan, held, skipped_empty = [], [], []
    not_run, aborted, stale, no_output = [], [], [], []
    for tdir, nml1, nml2 in ta.test_cases:
        base = nml1.replace('.nml1', '')
        test_id = f'{tdir}-{nml1}-{nml2}'
        if base in hold:
            held.append(base)
            continue
        result = status.get(test_id)
        if result is None:
            not_run.append(base)
            continue
        if result != 'PASSED' and reason.get(test_id) != CLEAN_FAILURE:
            aborted.append((base, reason.get(test_id, result)))
            continue
        for suf in SUFFIXES:
            src = os.path.join(outdir, base + suf)
            dst = os.path.join(tdir, ta.ref_dir, base + suf)
            if not os.path.exists(src):
                if os.path.exists(dst):
                    no_output.append(dst)
                continue
            if os.path.getmtime(src) < bin_mtime:
                if (os.path.getsize(src) == 0 and os.path.exists(dst)
                        and os.path.getsize(dst) == 0):
                    skipped_empty.append(src)
                    continue
                stale.append(src)
                continue
            plan.append((src, dst))

    print(f'cases collected                  : {len(ta.test_cases)}')
    print(f'files to install                 : {len(plan)}')
    print(f'cases held back                  : {len(held)}')
    print(f'empty on both sides, skipped     : {len(skipped_empty)}')
    print(f'cases not in the log             : {len(not_run)}')
    print(f'cases that did not exit cleanly  : {len(aborted)}')
    print(f'outputs older than the binary    : {len(stale)}')
    print(f'references with no new output    : {len(no_output)}')
    for base in held:
        print(f'   HELD      {base}')
    for path in skipped_empty:
        print(f'   EMPTY     {os.path.basename(path)}')
    for base in not_run:
        print(f'   NOT RUN   {base}')
    for base, why in aborted:
        print(f'   NOT CLEAN {base}: {why}')
    for path in stale:
        print(f'   STALE     {path}')
    for path in no_output:
        print(f'   NO OUTPUT {path}')

    if not_run or aborted or stale or no_output:
        sys.exit('\nrefusing to install: resolve the above, or hold the '
                 'cases back with --hold')
    if not args.apply:
        print('\ndry run; pass --apply to install')
        return

    for src, dst in plan:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copyfile(src, dst)
    print(f'\ninstalled {len(plan)} reference files')


if __name__ == '__main__':
    main()
