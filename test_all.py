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
test_defs = [x for x in config['paths']['tests'].split('\n') if len(x) > 0 ]
float_frac_tol = float(config['tolerances']['float_frac_tol'])
int_abs_tol = int(config['tolerances']['int_abs_tol'])
ref_dir = config['paths']['reference_dir']
show_output = config.getboolean('options','show_output_upon_failure')
ignore_version_diffs = config.getboolean('options', 'ignore_version_diffs')

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


def filevals_differ(ref_file, out_file, float_tol, int_tol):
    '''Iterate over lines in two files to compare, split lines into tokens and
    compare each token with an integer or floating-point tolerance for numeric
    values or literally, otherwise.'''
    ref = open(ref_file, 'r')
    out = open(out_file, 'r')
    lineno = 1
    diff_found = False

    # Iterate over lines of files
    while True:
        difference = False
        locs = []
        try:
            refline = next(ref)
            outline = next(out)
            if ignore_version_diffs and re.search(r"# YREC v.* \(.*\)", outline):
                continue
            ref_vals = vals_from_line(refline)
            out_vals = vals_from_line(outline)
        except StopIteration as ex:
            break

        # Compare all values on line
        for i, val in enumerate(ref_vals):
            if isinstance(val, numbers.Number):
                # An IndexError indicates the number of tokens on the line
                # differs between files.
                try:
                    diff = abs(out_vals[i] - val)
                except IndexError as ex:
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
        lineno += 1

    ref.close()
    out.close()
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


def order_batch(batch, order_val):
    '''Impose an order requirement on a batch of test cases'''
    return [
        pytest.param(
            *(item if isinstance(item, tuple) else (item,)),
            marks=pytest.mark.order(order_val)
        )
        for item in batch
    ]

def mark_batch(batch, order_val):
    return [
        pytest.param(*case, marks=pytest.mark.order(order_val))
        for case in batch
    ]


def batch_tests(tests):
    '''Iterate over all test cases and find dependencies between
    CONTROL (nml1) namelist files. Return the list of all cases
    that depend upon other cases in provided set.
    Batch all provided tests into 'early' and 'late'
    so that all tests whose outputs are dependencies of other
    tests run first.
    Sorts test cases into a maximum of two tiers, early and late.
    '''
    batches = []
    # extract the FFIRST field from every test case, keep associated with the case
    # iterate over list of tests and compare each with list of ffirsts
    # if an ffirst appears in the test list, move that test to an earlier list

    # Iterate over the next list and repeat, splitting off matches into a new list
    # Repeat until there are no more tests to examine
    # List of tuples
    #   test (3-list of test fields)
    #   FFRIST from the NML1 of the test case
    tcases = []
    for i, test in enumerate(tests):
        nmlfile = os.path.join(test[0], test[1])
        with open(nmlfile, 'r') as nml:
            for line in nml:
                line = line.strip()
                if len(line) == 0 or line[0] == '!':
                    continue
                if 'FFIRST' in line:
                    ffirst = re.search('(".*")', line).groups()[0].replace('"', '')
                    tcases.append((test, ffirst))

    batches = []
    early = []  # Test which are a dependency of another in the set
    late = []   # A test which depends upon another in the set
    indep = []  # Tests which may be independenty scheduled
    for tcase in tcases:
        dep_found = False
        stub = tcase[0][1].rsplit('.')[0]
        # Check if stub appears in any test cases
        print(f"searching for  {stub} ", end='')
        for srchcase in tcases:
            #print('.', end='')
            if srchcase[0] not in early and stub in srchcase[1]:
                early.append(tcase[0])
                print('   Found. This test is a dependency of another')
                dep_found = True
                break
        print()
        if not dep_found:
            late.append(tcase[0])

    # Assign ordering to batches
    early = mark_batch(early, 1)
    late = mark_batch(late, 2)
    batches.append(early)
    batches.append(late)

    return batches


test_cases = collect_tests(test_defs)
batches = batch_tests(test_cases)
test_cases_ordered = []
for batch in batches:
    test_cases_ordered = test_cases_ordered + batch


@pytest.mark.parametrize("tdir,nml1,nml2", test_cases_ordered)
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

