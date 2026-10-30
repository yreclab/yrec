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
test_reqs = [x for x in config['paths']['tests'].split('\n') if len(x) > 0 ]
float_frac_tol = float(config['tolerances']['float_frac_tol'])
int_abs_tol = int(config['tolerances']['int_abs_tol'])
ref_dir = config['paths']['reference_dir']
show_output = config.getboolean('options','show_output_upon_failure')
ignore_version_diffs = config.getboolean('options', 'ignore_version_diffs')

envkeys = {'YREC_INPUT':'input', 'YREC_START':'startmodels'}
for key in envkeys.keys():
    if key not in os.environ:
        os.environ[key] = os.path.join(os.getcwd(), envkeys[key])

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


class Tcase:
    '''Definition of a test case, including the FFIRST dependency'''
    def __init__(self, subdir, control, physics):
        self.subdir = subdir     # location relative to yrec project root
        self.control = control
        self.physics = physics
        self.name = self.control.rsplit('/')[-1].rsplit('.')[0]
        self.dep = self.extract_dep()   # stub of FFIRST model dependency

    def extract_dep(self):
        nmlfile = os.path.join(self.subdir, self.control)
        with open(nmlfile, 'r') as nml:
            for line in nml:
                line = line.strip()
                if len(line) == 0 or line[0] == '!':
                    continue
                if line[0:6] == 'FFIRST':
                    ffirst = re.search('(".*")', line).groups()[0].replace('"', '')
                    ffirst_stub = line.rsplit('/')[-1].rsplit('.')[0]
                    return ffirst_stub


def collect_tcases(testreqs):
    '''Traverse testing directories and define a test for each applicable pair
    of YREC .nml1, .nml2 input files.'''
    tcases = []
    for testreq in testreqs:
        print(f"{testreq=}")
        if "," in testreq:
            tcomps = testreq.split(',')
            tcomps = [x.strip() for x in tcomps]
            if len(tcomps) != 3:
                raise ValueError("Individual test case has incorrect number of components")
            tcase = Tcase(tcomps[0], tcomps[1], tcomps[2])
            tcases.append(tcase)
        else:
            curdir = os.getcwd()
            shortdir = os.path.basename(testreq)
            for nml1 in sorted(glob(f'{testreq}/*.nml1')):
                nml1 = os.path.abspath(nml1)
                dirname = os.path.dirname(nml1)
                name = nml1.replace(".nml1", "")
                nml1_base = os.path.basename(nml1)
                test_nml2 = os.path.join(dirname, f"{name}.nml2")
                test_nml2_base = os.path.basename(test_nml2)
                if os.path.exists(test_nml2):
                    tcase = Tcase(testreq, nml1_base, test_nml2_base)
                else:
                    dir_nml2 = f"{shortdir}.nml2"
                    tcase = Tcase(testreq, nml1_base, dir_nml2)
                tcases.append(tcase)
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


#def mark_batch(batch, order_val):
#    '''Apply a pytest mark to a list of test case parameter tuples which
#    assigns an execution order to the batch relative to other batches with an
#    excution order assigned.
#
#    I.e., if a batch is assigned an order value of 2, all tests in that batch
#    will only begin running after all tests in a batch with order value 1 have
#    completed.
#    '''
#    return [
#        pytest.param(*case, marks=pytest.mark.order(order_val))
#        for case in batch
#    ]


def mark_xdist_batch(batch, idx):
    '''Apply a pytest xdist mark to a list of test case parameter tuples which
    assigns an execution order to the batch relative to other batches with an
    excution order assigned.
    Within an xdist group, the order is enforced, so dependencies must appear
    before the tests they support.
    '''
    return [
        pytest.param(*case, marks=pytest.mark.xdist_group(f"DEP_CHAIN_{idx}"))
        for case in batch
    ]

def name_in_startmodels(name):
    '''Return True if name appears anywhere in startmodels
    False otherwise
    '''
    startd = os.environ['YREC_START']
    spath = pathlib.Path(startd)
    if len(list(spath.rglob(f"{name}*"))) == 0:
        return False
    else:
        return True

#def idx_of_case_w_name(tcases, case):
#    '''Return the index in the list of cases
#    of the case that has the given dependency.
#    '''
#    for case in tcases:
#        if case.dep == dep:
#            return tcases.index(case)
#
#
#def idx_of_case_w_dep(tcases, dep):
#    '''Return the index in the list of cases
#    of the case that has the given dependency.
#    '''
#    for case in tcases:
#        if case.dep == dep:
#            return tcases.index(case)


def flatten(xss):
    return [x for xs in xss for x in xs]


def batch_tests(tcases):
    '''Iterate over all test cases
    Place each test case that is the dependency of another in the set
       in the early batch.
    Place all tests that have one of the early tests as a dependency
       in the late batch.
    All other cases go in the independent batch

    Some tests have already been run and their outputs exist in STARTMODELS
        These can run whenever
    Tests that appear as a dependency and do NOT appear in STARTMODELS
        must run first
    Tests that have a dependency on another test must run last

    '''

    # Goal:  place each complete dependency chain into it's own list
    # Each of those lists will be marked to run in order on a given worker.

    # Compose list of all test names for dep comparison
    tnames = [x.name for x in tcases]
    print(f"total tests = {len(tcases)}")

    # List of test dependencies that appear in the above list
    depnames = [x.dep for x in tcases if x.dep in tnames]

    # If a case dep does not already exist, it needs to be built.
    # Find it in the list and examine its dep.
    #   If its dep doesn't need to be built, build the case, otherwise
    #     move down the line to find the next dep and test it.
    # Walk dep graph for each test case
    depsets = []
    for case in tcases:
        depset = []
        if case.dep in tnames:
            print(f"DEPENDENCY: {case.dep}")
            for dc in tcases:   # Get the dependency
                if dc.name == case.dep and dc not in flatten(depsets):
                    depset.append(dc)  # dep(s) first
                    break
            for dc in tcases:   # Collect all tests that require the dependency
                if dc.dep == case.dep and dc not in flatten(depsets):
                    print(f"    Test that needs it: {dc.name}")
                    depset.append(dc)   # append cases that need the dep
            depsets.append(depset)

        ## If a test name matches something already in startmodels,
        ## it needs to run before anything that depends on it

    # Remove empty sets
    depsets = [x for x in depsets if len(x) > 0]

    print("\ndep sets:")
    for i, depset in enumerate(depsets):
        print(f"      Chain {i}")
        for name in [x.name for x in depset]:
            print(name)

    # All tests that don't have an order dependence can be independently
    # scheduled
    indep = []
    print("indep cases:")
    for case in tcases:
        #if case not in (early + late):
        if case not in flatten(depsets):
            indep.append(case)
            if 'base' in case.name or 'base' in case.dep:
                print("    *********")
            print(case.name, "    ", case.dep)

    # Format in lists of tuples for use by test_yrec function
    case_params = []
    early_params = []
    for i, depset in enumerate(depsets):
        for case in depset:
            ptup = (case.subdir, case.control, case.physics)
            # Make this batch execute in its interal order on a single worker.
            cparams = pytest.param(*ptup, marks=pytest.mark.xdist_group(f"DEP_CHAIN_{i}"))
            early_params.append(cparams)

    case_params = early_params

    indep_params = []
    for case in indep:
        indep_params.append((case.subdir, case.control, case.physics))
    case_params.extend(indep_params)

    return case_params




# Perform test collection and execute tests
tcases = collect_tcases(test_reqs)
test_cases_ordered = batch_tests(tcases)


# Main test execution function called automatically by pytest.
@pytest.mark.parametrize("tdir,nml1,nml2", test_cases_ordered)
def test_yrec(tdir, nml1, nml2, request):   # 'request' is pytest built-in fixture request
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
    outputs = [f for f in all_outputs if re.search(r'(\.short|\.store|\.track)', f)]

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

    # For tests that are part of an ordered dependency set,
    # copy the last model output into the YREC_START directory
    # to make it available to dependent tests.
    if "xdist_group" in request.keywords:
        for outfile in all_outputs:
            print(outfile)
            if '.last' in outfile:
                print('Copying output file to YREC_START for use by later tests.')
                shutil.copy(outfile, os.environ['YREC_START'])
                break
