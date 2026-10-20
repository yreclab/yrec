# Protocol: rebaselining the test references

How to replace the reference outputs in `testsuite/standard/` and
`examples/*/standard/` after a change that is *meant* to move the
numbers. Each step below exists because skipping it has already produced
a bad reference at least once; the issue numbers point to the record in
`KNOWN_ISSUES.md`.

A rebaseline redefines "correct" for every case in the suite. Treat it as
a measurement to be reviewed, not a copy operation.

## Checklist

1. Decide whether a rebaseline is needed at all.
2. Commit the code change on its own, and build from that commit.
3. Back up the current references, and verify the backup.
4. Run the full suite **twice**, and measure from the second pass.
5. Review every case: exit status, run extent, stopping criterion, `NaN`s.
6. Hold back any case that needs a physics judgement.
7. Install references only from cases that exited cleanly in pass 2.
8. Run the full suite a third time; it must pass.
9. Record what moved and why.

## How the harness behaves (read this first)

- `pytest -v test_all.py`, run from the repository root, collects every
  `nml1`/`nml2` pair in the directories listed in `pytest.ini` (about 300
  cases) and compares each case's `.short`, `.store` and `.track` against
  `<test dir>/standard/`. A full pass takes about five hours.
- Floats pass within a fractional tolerance of `float_frac_tol` (0.02);
  integers must match exactly.
- **A missing reference is created silently, and the case passes.** If
  `standard/<case>.track` does not exist, the harness copies the current
  output there and compares it with itself. "All passed" therefore says
  nothing about a case whose reference was absent.
- **Every case writes to one shared output directory**, `$YREC_OUTPUT`
  (issue 16). Files there persist between runs, so a file in it may be
  left over from an earlier binary or an earlier crash.
- **The harness checks the exit status before it compares anything.** A
  case that aborts fails with "Program terminated abnormally", but the
  partial outputs it wrote are still in `$YREC_OUTPUT` (issue 35).
- **`NaN` and `Inf` always compare as equal** (issue 30). A `NaN` output
  passes against a finite reference, and a `NaN` in a reference accepts
  any output.
- The references are **not under version control** (issue 32). A
  rebaseline leaves no diff to review, and an overwritten reference can
  only be recovered from a backup you made.

## 1. Decide whether a rebaseline is needed

Rebaseline only when the change is intended to move results beyond
tolerance. Use the `[ignore]` section of `pytest.ini` instead when:

- the change is cosmetic, such as a namelist variable dropped from the
  `.short` echo or a reworded diagnostic, **and**
- a narrow regular expression can match the affected lines without
  hiding real differences.

**Do not combine a harness fix with a rebaseline.** For example, if you
make the comparison reject `NaN`, cases will start failing. Those failures
are the point of the fix. A rebaseline in the same change would record
the `NaN`s again as correct.

## 2. Commit, then build

- Commit the code change before running anything. Each output header
  carries the git hash of the binary that wrote it. A `-dirty` hash means
  the outputs cannot be traced back to source.
- Run `make` in `src/`, and note the binary's time stamp. Every output
  you install later must be newer than that binary.
- Check that `YREC_INPUT`, `YREC_START` and `YREC_OUTPUT` point where you
  expect. If they are unset, the code falls back to relative defaults.

## 3. Back up the references

Archive every `standard/` directory, together with a checksum manifest:

```sh
cd <repo>
find testsuite/standard examples/*/standard -type f -print0 \
  | xargs -0 md5sum > ~/refs_<date>.md5
tar czf ~/refs_<date>.tgz testsuite/standard examples/*/standard
```

Then **verify the backup**. Unpack it into a scratch directory and run
`md5sum -c ~/refs_<date>.md5` there. Check that the number of files in
the manifest equals the number in the tarball. Keep the backup until the
rebaseline has been reviewed and accepted. It is the only way to undo the
rebaseline.

Write the backup under your home directory, not `/tmp`. The references
total about 500 MB.

## 4. Run the suite twice

```sh
pytest -v test_all.py > pass1.log 2>&1
pytest -v test_all.py > pass2.log 2>&1
```

Use pass 2 for all measurement and installation. Pass 1 is needed
because the suite modifies its own inputs:

- **Issue 35.** Three cases read a start model from `startmodels/` that a
  later case in the same run rewrites. In pass 1 they start from a model
  made by the *old* binary. By pass 2 they start from one made by the new
  binary.
- **Issue 5.** Five `Test_m2p0_feh+0p0_vzams150_*` cases read a model from
  `$YREC_OUTPUT` that is written by an example case collected later.

After pass 2, `git status` will show modified `startmodels/*.last` files.
These are the new start models, and they are part of the rebaseline.
Commit them together with its record (step 9).

## 5. Review every case

For each case, compare the pass 2 output with the current reference.
Checking that values moved by small amounts is not enough. Check all of
the following.

**Exit status.** List the cases that failed with "Program terminated
abnormally". They have no valid output. Never install anything from such
a case. Find out why it aborted before going further. A `STOP` message
in the captured stdout identifies the routine.

**Run extent.** Compare the last line of each `.track` file with the
reference: the final model number and the final age. Treat this as the
main result of the review, not a side detail. Some cases are meant to
end in a crash, such as `..._HeIgnite` at helium ignition. For those,
how far the run gets *is* the measurement (issue 33). Tabulate:

- the number of cases whose final model number is identical
- the number whose final age is within 0.1%
- every case whose final age moved by more than 0.5%, in either direction

**Stopping criterion.** A case named for an endpoint must still reach
it. For example, a `..._TAHB` case must end with central helium below
its `END_YCEN`. A case that now stops short has changed what it tests
(issue 34). It is not a small numerical shift.

**`NaN` and `Inf`.** Count the non-finite values in each output and in
its reference. The counts should not change. The harness will not
report a change (issue 30), so you have to check this yourself.

**Value changes.** Report the distribution of fractional changes across
all compared values. Use medians and percentiles over the whole suite.
Don't quote per-file maxima: a single value near zero produces a huge
fractional change that means nothing.

## 6. Hold back cases that need judgement

If a case aborts, no longer reaches its endpoint, or changes its run
extent in a way you can't explain, **keep its old reference** and open an
issue in `KNOWN_ISSUES.md`. A reviewer with the physics background
decides whether the new behaviour is correct before that case is
rebaselined. Installing it anyway would make the suite certify the new
behaviour as correct.

## 7. Install the new references

Use `rebaseline.py`, at the repository root:

```sh
python rebaseline.py pass2.log --hold CASE --hold CASE   # dry run
python rebaseline.py pass2.log --hold CASE --hold CASE --apply
```

It copies `$YREC_OUTPUT/<case>.{short,store,track}` to
`<test dir>/standard/` for each case that is not held back. Before
copying anything, it checks the points below. If any check fails, it
refuses to install anything at all:

- **the case exited with status 0 in pass 2.** Don't rely on file
  timestamps alone: a case that aborts still leaves fresh partial
  outputs.
- **every file to be installed is newer than the binary.** An older file
  was written by an earlier binary.
- **a zero-byte file is installed only if the reference is also empty.**
  Some crash-terminated cases never write a `.store`, so the zero-byte
  file in `$YREC_OUTPUT` is an old leftover (issue 33).
- **every existing reference has a matching new output.** A reference
  with no new output means the case no longer writes that file. Find out
  why before going on.

The tool takes each case's exit status from the pass 2 log, so that log
must come from `pytest -v` and must have run to completion. It does none
of the review in step 5.

Do not get new references by deleting the old ones and letting the
harness create them. That works only for cases that exit cleanly, gives
you no point at which to review, and skips the holds.

## 8. Verify with a third pass

```sh
pytest -v test_all.py > pass3.log 2>&1
```

Every case must pass, except the held cases, which are expected to fail
against their old references. List them by name. Also confirm that
`git status` shows **no further changes** to `startmodels/*.last`. That
shows the start-model chain has settled (issue 35). If the start models
keep changing, the chain has not settled, and the pass 2 references
cannot be reproduced.

## 9. Record

The references are untracked, so the commit message and
`KNOWN_ISSUES.md` are the only record of the rebaseline. Commit the
updated `startmodels/*.last` files and any new issues, with a message
that includes:

- the commit whose binary produced the new references
- how many reference files were replaced, out of how many
- the run-extent table from step 5
- the distribution of value changes from step 5
- each held case, with its issue number
- where the backup from step 3 is kept
