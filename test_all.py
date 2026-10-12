#!/usr/bin/env python
#
# YREC test runner
#   Requires:
#     python 3.x
#     pytest
#     pytest-xdist

import os, sys
import shutil
from glob import glob
import pathlib
import re
import numbers
import pytest
import subprocess as sp
import configparser as cfp

config = cfp.ConfigParser()
config.read("pytest.ini")
yrec_exe = os.path.abspath( config['paths']['yrec'] )
tests = [x for x in config['paths']['tests'].split('\n') if len(x) > 0 ]
float_frac_tol = float(config['tolerances']['float_frac_tol'])
int_abs_tol = int(config['tolerances']['int_abs_tol'])
ref_dir = config['paths']['reference_dir']
show_output = config.getboolean('options','show_output_upon_failure')
ignore_version_diffs = config.getboolean('options', 'ignore_version_diffs')

# Lines matching any of these regular expressions are dropped from BOTH the
# reference and the output before comparison, each file filtered
# independently.  See iter_compared_lines() for why that matters.
version_banner_re = re.compile(r"# YREC v.* \(.*\)")
ignore_line_res = []
if config.has_section('ignore'):
    for pattern in config['ignore'].get('patterns', '').split('\n'):
        pattern = pattern.strip()
        if not pattern:
            continue
        try:
            ignore_line_res.append(re.compile(pattern))
        except re.error as ex:
            raise ValueError(
                f"pytest.ini [ignore] patterns: {pattern!r} is not a valid "
                f"regular expression ({ex})")

if not os.path.exists(yrec_exe):
    raise FileNotFoundError(f"YREC executable {yrec_exe} not found!")

class colors:
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    ENDC = '\033[0m'

def collect_tests(testreqs):
    '''Traverse testing directories and define a test for each applicable pair
    of YREC .nml1, .nml2 input files.'''
    tcases = []
    for testreq in testreqs:
        if "," in testreq:
            tcomps = testreq.split(',')
            tcomps = [x.strip() for x in tcomps]
            if len(tcomps) != 3:
                raise ValueError("Individual test case has incorrect number of components")
            tcases.append(tcomps)
        else:
            curdir = os.getcwd()
            os.chdir(testreq)
            shortdir = os.path.basename(testreq)
            for nml1 in sorted(glob(f'*.nml1')):
                tbase = nml1.replace(".nml1", "")
                test_nml2 = f"{tbase}.nml2"
                if os.path.exists(test_nml2):
                    tcases.append([testreq, nml1, test_nml2])
                else:
                    dir_nml2 = f"{shortdir}.nml2"
                    tcases.append([testreq, nml1, dir_nml2])
            os.chdir(curdir)
    return tcases


def case_fingerprint(tdir, nml1, nml2):
    '''Return the normalized contents of a case's two input files, used to
    recognize a case that is duplicated between test directories. Trailing
    whitespace is stripped from each line, since it cannot affect namelist
    input.'''
    parts = []
    for name in (nml1, nml2):
        path = os.path.join(tdir, name)
        try:
            with open(path, 'r', errors='replace') as fh:
                parts.append('\n'.join(line.rstrip() for line in fh))
        except OSError:
            # Missing or unreadable input: fingerprint on the path so this
            # case can never be silently merged with a different one.
            parts.append(f'<unreadable {path}>')
    return tuple(parts)


def drop_duplicate_cases(tcases):
    '''Drop any case whose two input files match those of a case already
    collected, so the same model is not evolved twice in one run.

    The first occurrence in pytest.ini `tests` order is the one kept, which
    puts the regression suite ahead of the example directories. Matching is
    on file contents, not names, so editing either copy makes them differ
    and both are collected again -- this needs no maintenance as cases are
    added. Note that the skipped case's reference files are not compared
    while it remains a duplicate.'''
    seen = {}
    kept = []
    duplicates = []
    for tdir, nml1, nml2 in tcases:
        fingerprint = case_fingerprint(tdir, nml1, nml2)
        if fingerprint in seen:
            duplicates.append((f"{tdir}/{nml1}", seen[fingerprint]))
        else:
            seen[fingerprint] = f"{tdir}/{nml1}"
            kept.append([tdir, nml1, nml2])
    for skipped, original in duplicates:
        print(f"duplicate case skipped: {skipped} has the same inputs as "
              f"{original}")
    return kept


def vals_from_line(line):
    '''Split text line and return list of separate integer, float,
    and text segment components.'''
    vals = []
    # Split on whitespace or '-' not found in exponent notation.
    for tok in re.split("\\s+|(?<![Ee])-(?=\\d)", line.strip()):
        try:
            val = float(tok)
            vals.append(val)
        except ValueError as e:
            try:
                val = int(tok)
                vals.append(val)
            except ValueError as e:
                val = tok
                vals.append(val)
    return vals


def iter_compared_lines(path):
    '''Yield (physical line number, line) for every line of `path` that is not
    excluded by an ignore rule.

    Each file is filtered independently and on its own content, so a line
    that appears in only one of the two files -- a version banner, or a
    namelist variable that one side echoes and the other does not -- is
    removed from that side alone and cannot shift the rest of the comparison.
    Deciding from one file and skipping both, as this once did, turns a single
    unmatched line into a difference on every line that follows it.'''
    with open(path, 'r') as fh:
        for lineno, line in enumerate(fh, start=1):
            if ignore_version_diffs and version_banner_re.search(line):
                continue
            if any(rx.search(line) for rx in ignore_line_res):
                continue
            yield lineno, line


def filevals_differ(ref_file, out_file, float_tol, int_tol):
    '''Iterate over lines in two files to compare, split lines into tokens and
    compare each token with an integer or floating-point tolerance for numeric
    values or literally, otherwise.  Reported line numbers are physical lines
    of the reference file, counting any lines an ignore rule dropped.'''
    ref = iter_compared_lines(ref_file)
    out = iter_compared_lines(out_file)
    diff_found = False

    # Iterate over lines of files
    while True:
        difference = False
        locs = []
        ref_next = next(ref, None)
        out_next = next(out, None)
        if ref_next is None and out_next is None:
            break
        if ref_next is None or out_next is None:
            # One file still has comparable lines once the other is exhausted.
            # Returning silently here would let a truncated output pass.
            longer = "reference" if out_next is None else "output"
            print(f"{longer} has more comparable lines than the other file")
            diff_found = True
            break
        lineno, refline = ref_next
        _, outline = out_next
        ref_vals = vals_from_line(refline)
        out_vals = vals_from_line(outline)

        # Compare all values on line
        for i, val in enumerate(ref_vals):
            if isinstance(val, numbers.Number):
                # An IndexError indicates the number of tokens on the line
                # differs between files.  A TypeError indicates the token at
                # this position is numeric in one file and text in the other,
                # which happens whenever the two files are line-shifted
                # relative to each other (e.g. a namelist echo gained or lost
                # a variable).  Both are differences, not harness errors.
                try:
                    diff = abs(out_vals[i] - val)
                except (IndexError, TypeError) as ex:
                    difference = True
                    break

                # Check against fractional floating point tolerance
                if type(val) == float:
                    if val != 0:
                        if abs(diff/val) > float_tol:
                            locs.append(i)
                            difference = True
                    else:
                        if diff != 0:
                            locs.append(i)
                            difference = True

                if type(val) == int and diff > int_tol:
                    locs.append(i)
                    difference = True
            else:
                # An IndexError indicates the number of tokens on the line
                # differs between files.
                try:
                    if val != out_vals[i]:
                        difference = True
                        locs.append(i)
                except IndexError as ex:
                    difference = True
                    break

        if difference:
            diff_found = True
            print(f"line: {lineno}")
            print(refline, end='')
            print(color_indicator(outline, locs))

    return diff_found


def chunk_indicator(line, indices):
    indicator = list(" " * len(line))
    for i, chunk in enumerate(re.finditer("\\s+|(?<![Ee])-(?=\\d)", line)):
        if i in indices:
            indicator[chunk.start()] = "^"
    indicator = ''.join(indicator)
    return indicator


def color_indicator(line, indices):
    '''For each non-whitespace segment of 'line', highlight the segments
    indicated in the list 'indices' in red, leaving the rest of the line
    unchanged.
    Return the modified line.
    '''
    segs = []
    out = ""
    last = 0
    matches = list(re.finditer("\\s+|(?<![Ee])-(?=\\d)", line))
    breaks = [ x.span() for x in matches ]
    flat = [item for sublist in breaks for item in sublist]
    if flat[0] == 0:
        del flat[0]
    else:
        flat.insert(0, 0)
    flat.append(len(line))
    flat = iter(flat)
    segs = zip(flat, flat)
    for i, seg in enumerate(segs):
        out = f"{out}{line[last:seg[0]]}"
        last = seg[1]
        if i in indices:
            out = f"{out}{colors.RED}"
        out = f"{out}{line[seg[0]:seg[1]]}"
        if i in indices:
            out = f"{out}{colors.ENDC}"
    return out


test_cases = drop_duplicate_cases(collect_tests(tests))




@pytest.mark.parametrize("tdir,nml1,nml2", test_cases)
def test_yrec(tdir, nml1, nml2):
    '''Process a test case definition consisting of
       (test directory, NML1 file, NML2 file)
    by running YREC executable within the given test directory
    with those two inputs. By default STDOUT and STDERR are displayed
    for any test case failures. '''
    startdir = os.getcwd()

    # Run the executable with the inputs for a given test case.
    os.chdir(tdir)
    for direc in ['output', 'standard']:
        os.makedirs(direc, exist_ok=True)
    proc = sp.run([yrec_exe, nml1, nml2],
            stdout=sp.PIPE,
            stderr=sp.PIPE)
    os.chdir(startdir)
    out = proc.stdout.decode()
    err = proc.stderr.decode()
    if show_output:
        print(out)
        print(err)

    # Extract output directory from terminal output
    outdir = None
    for line in out.split('\n'):
        if "OUTPUT placed in" in line:
            outdir = str(pathlib.Path(line.split(':')[1].strip()))
    print(f'{outdir=}')

    # Ensure outdir is an absolute path
    outdir = os.path.abspath(os.path.join(tdir, outdir))

    # Fail on abnormal termination
    assert proc.returncode == 0, "Program terminated abnormally"

    # If process completed without error code,
    # check for the presence of a reference standard.
    # If no reference standard, copy outputs to
    # reference standard location and return.
    tbase = nml1.replace(".nml1", "")
    all_outputs = glob(f"{outdir}/{tbase}.*")
    print(f"output file base = {outdir}/{tbase}")
    print(f"{all_outputs=}")
    outputs = [f for f in all_outputs if re.search(r'(\.short|\.store|\.track)', f)]
    print(f"{outputs=}")

    # Fail on missing outputs
    assert len(outputs) > 0, "Missing output(s)"

    # For each output, check if a refrence exists.
    # If not, copy output into reference.
    print("--------------------------------------------------------------")
    print("Comparing outputs with reference standards...\n")
    outputs_identical = True
    for out in outputs:
        refname = os.path.basename(out)
        ref = f"{tdir}/{ref_dir}/{refname}"
        if not os.path.isfile(ref):
            shutil.copyfile(out, ref)
            print(f"{out} copied to reference")
        print(f"--- Comparing standard to {out}\n")
        if filevals_differ(ref, out, float_frac_tol, int_abs_tol):
            outputs_identical = False
    assert outputs_identical, "Output differs from reference standard"

