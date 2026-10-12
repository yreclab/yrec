# Known issues (open)

Deferred items with enough context to be picked up cold. Each entry records
what was observed, where in the code it lives, and what decision was taken.

---

## 1. `SECULR`'s `LCODM` whole-domain override is not gated on solid-body rotation

**Status:** open, deliberately unchanged as of 2026-10-11. Flagged for code
review by MHP.

### Background

`seculr.f` reads `LCODM` and `CODM` but historically never declared
`COMMON/MAG/`, so both were uninitialized locals: `LCODM` was always
`.FALSE.` and the branch below never executed, even though ~101 test and
example namelists set `LCODM = .TRUE.` explicitly. Declaring the block (same
layout as `codiff.f`) made the option live for the first time. That fix
exposed the question below; it is not itself in question.

### The override

`seculr.f:257`:

```fortran
C MHP 8/13 TREAT ENTIRE DOMAIN AS UNSTABLE IF A CONSTANT DIFFUSION
C COEFFICIENT IS BEING ADDED
      IF(LCODM.AND.CODM.GT.0.0D0)THEN
         LTEST = .TRUE.
         IBEG = IMIN - 1
         IEND = IMAX
         ISTART = IMAX + 1
         GOTO 80
      ENDIF
```

This replaces the per-region scan over `HV(J).GT.0` with a single
whole-domain pass.

### The concern

The solid-body skip at `seculr.f:313`:

```fortran
C MHP 3/09 SKIP ANGULAR MOMENTUM EVOLUTION FOR SOLID BODY MODELS
C JNT 09/25 FOR 05/15 IMPJMOD=1 IS THE SAME AS LSOLID
      IF(.NOT.LSOLID .AND. (IMPJMOD.NE.1))THEN
```

closes at **line 367**, so it covers only the angular-momentum evolution.
Two consumers of the override's `IBEG`/`IEND` sit *outside* it:

- `CALL ROTGRID(...)` at line 294 (equal-grid remap over the region)
- `CALL NDIFCOM(...)` at line 370 (composition diffusion)

Meanwhile `CODM` reaches **only** the angular-momentum coefficient `COD`,
never the composition coefficient `COD2`. In `codiff.f`:

- line 106: `COD(I)=CON1*(CODM+(VES(I)+VGSF(I)+VSS(I))*RMID(I))`
- line 107: `COD2(I)=CON2*(FESC*VES(I)+FGSFC*VGSF(I)+FSSC*VSS(I))*RMID(I)` — no `CODM`
- line 113: `COD2(I) = COD(I)*VFC(I)` — evaluated *before* line 115 adds `CODM` to `COD`

So for `LSOLID=.TRUE.` (or `IMPJMOD=1`), the sole consumer of the new physics
is skipped, yet the override still restructures the composition-diffusion
domain and the `ROTGRID` remap. The override arguably contributes no physics
in that configuration while still perturbing the solution numerically.

### Observed effect

Case `testsuite/Test_solarGS98_difrotmixsolidper18p4d1p0`
(`LSOLID=T`, `LCODM=T`, `CODM=9.0D4`) after the `COMMON/MAG/` fix:

- 45,374 differing lines in `.short`
- final model 1158: age **identical** (4.568 Gyr, calibrated), structural
  columns agree to ~1e-6 (`4.43810650` vs `4.43810299`)
- the diff lines are dominated by Newton-iteration convergence diagnostics,
  e.g. `DEL-L/L F 7.4227E-06` vs `7.9827E-06`, and by quantities that were
  exactly `0.0` in the reference becoming small and nonzero (the comparator
  requires exact equality when the reference value is 0)

i.e. the solid-body model is physically unaltered at the ~1e-6 level but is
not bit-identical.

### Candidate change (not applied)

Extend the override's condition to match line 313:

```fortran
      IF(LCODM.AND.CODM.GT.0.0D0.AND..NOT.LSOLID.AND.(IMPJMOD.NE.1))THEN
```

Expected to make `difrotmixsolidper18p4d1p0` byte-identical and confine the
`LCODM` option to configurations where `CODM` actually does work. Would
require regenerating that case's reference either way.

### Gating summary (for whoever picks this up)

The option is reachable only when both of these hold:

- `getw.f:282` — `IF(LINSTB.AND..NOT.LALLCZ)` wraps `CALL SECULR` (line 305)
- `seculr.f:257` — `LCODM .AND. CODM.GT.0`

Validation of the 21 `LROT=.TRUE.` cases (2026-10-11) gave 9 byte-identical
and 12 changed, consistent with those gates: all `LCODM=.FALSE.` cases and all
`LINSTB=.FALSE.` cases were unchanged.

---

## 2. One case is unchanged although both `LCODM` gates are open

**Status:** open, unexplained.

`examples/run_rotation_to_RG/Test_3Msolar_GS_rot_gray_OPALSCV_SF2_GS98_OP_CF10_RGp2diffrotI2`
has `LINSTB=.TRUE.`, `LCODM=.TRUE.`, `CODM=9.0D4`, `IMPJMOD=2`,
`WALPCZ=-2.0`, so both gates above are open — yet its `.short`, `.store` and
`.track` are byte-identical to the pre-fix references (88,021 reference
lines).

Most likely explanation, not verified: its unstable region already spans
`IMIN..IMAX`, so `IBEG=IMIN-1, IEND=IMAX` reproduces exactly what the normal
`HV(J).GT.0` scan would have produced, making the override a no-op. Worth
confirming, since it is the one case that does not follow the gate logic.

---

## 3. `dadcoeft.f` has zero test coverage, so its `LROSSBY` fix is unvalidated

**Status:** open; needs a new test case.

`dadcoeft.f` reads `LROSSBY` and `PMMSOLTAU` but never declared
`COMMON/PMMWIND/`, so both were uninitialized locals — `LROSSBY` was always
`.FALSE.` and the Rossby scaling of the saturation threshold never ran,
despite a namelist default of `.TRUE.` and ~105 namelists setting it
explicitly. The block has been declared (matching `mwind.f`'s layout), which
makes the namelist values arrive.

The affected logic is near line 154:

```fortran
      IF(LROSSBY)THEN
         WSAT = WMAX*PMMSOLTAU/TAUCZ
      ELSE
         WSAT = WMAX
      ENDIF
```

The routine requires **both** `LROT=.TRUE.` and `LDIFAD=.TRUE.`. No case in
`testsuite/` or `examples/` sets both — all 21 `LROT=.TRUE.` cases have
`LDIFAD=.FALSE.` — so these 589 lines are never executed and the fix is
untested. A case with both flags set is the only way to cover it.

---

## 4. The m9p0 TAMS cases do not reproduce their committed start model

**Status:** open.

**Read this first:** chaining cases is intentional. `startmodels/` is a
library of 690 committed start models, and the `examples/run_from_*_to_*`
directories are a deliberate pipeline. A case that reads a start model
some later case also writes is therefore normal: it reads the committed
fixture, and the writer merely demonstrates regenerating it. An audit of
the 2026-10-11 full run bears that out -- of 136 start-model files that
are both written via `FLAST` and read via `FFIRST`, **133 were rewritten
byte-identically** to the committed fixture. The design is self-consistent
and only two files are anomalous, which is what this entry is about. An
earlier version of this entry wrongly described the chaining itself as the
defect.

`testsuite/Test_m9p0feh+0p0GS98_base_TAMS.nml1` writes

```
 FLAST = "{YREC_START}/Test_m9p0feh+0p0GS98_base_TAMS.last"
```

and `testsuite/Test_m9p0feh+0p0GS98_base_TAHB.nml1` reads that same file

```
 FFIRST = "{YREC_START}/Test_m9p0feh+0p0GS98_base_TAMS.last"
```

as its starting model. The `yaleeos` pair does the same. So a test case
writes an input of another test case, into `startmodels/`, where the file
is tracked in git.

These two are the exception: after the 2026-10-11 run they were the **only**
two tracked files in `startmodels/` that `git status` reported as modified.
So the current code does not reproduce the committed fixture for this pair,
which strongly suggests the committed `.last` predates some later code
change.

That matters because cases are collected with `sorted(glob('*.nml1'))` and
`TAHB` sorts before `TAMS`, so the TAHB case runs **first** and reads the
fixture, after which the TAMS case overwrites it. Timing from the run: the
TAHB output was written at 17:10, and the fixture was overwritten at 17:12
(17:18 for `yaleeos`). Consequences while the fixture does not round-trip:

- the TAHB result depends on whether a previous run had already overwritten
  the fixture, not only on the code -- which is the mechanism behind the
  divergence of these two cases that had been treated as unexplained
- a full run leaves two tracked files dirty
- reference regeneration does not converge: the TAHB references now in
  `standard/` were produced from the committed fixture, while the fixture
  a later run leaves on disk is different

The two `.last` files were restored with `git checkout` so they match the
start model that produced the current TAHB references. Any full run will
dirty them again.

### Diagnosis (2026-10-12): the fixture is stale, not irreproducible

`Test_m9p0feh+0p0GS98_base_TAMS` was run twice and the `.last` it writes
compared against the committed fixture and against itself:

- the case **passes** its own `.short`/`.store`/`.track` comparison
- the two runs write **byte-identical** `.last` files, so the model is
  fully reproducible
- both differ from the committed fixture on essentially every line, but
  only in the last one or two digits, e.g. `4.02995301695` against
  `4.02995301685`, `1.3819062456E+03` against `1.3819062459E+03`, with
  identical model indices (830, 707) and agreement to ~10 significant
  figures

So the committed fixture carries round-off-level drift from an older build.
There is no chaos in the TAMS model. The TAHB divergence is a stale start
model amplified by a 9 Msun He-ignition evolution, which is sensitive
enough to turn a ~1e-10 relative perturbation in its initial model into a
visible difference.

### Fix

Refresh the fixture and its dependent reference together, as one change:

1. run the `base` and `yaleeos` TAMS cases and commit the two regenerated
   `startmodels/*_TAMS.last` files
2. regenerate the two TAHB references from those start models
3. confirm a second full run leaves `startmodels/` clean, which is the
   condition the other 133 chained fixtures already satisfy

Doing only step 1 or only step 2 makes the mismatch worse, so they must go
in the same commit. Not yet applied: it rewrites a committed physics
fixture and a reference, which is a judgement call for MHP rather than
routine cleanup. The two `.last` files are currently at their committed
state so the TAHB references in `standard/` remain self-consistent.

---

## 5. Five testsuite cases depend on a file produced by a later example case

**Status:** open.

The five `testsuite/Test_m2p0_feh+0p0_vzams150_*` cases read

```
 FFIRST = "{YREC_OUTPUT}/Test_m2000_feh0_noGS_ZAMS.last"
```

That file is written by
`examples/run_from_dbl_to_zams/Test_m2000_feh0_noGS_ZAMS.nml1`. Unlike the
designed chains in issue 4, this one is broken in three ways at once:

- it points at `{YREC_OUTPUT}`, the transient shared output directory, not
  at `{YREC_START}` where start models live
- the file is **not tracked in git**, so on a fresh clone it does not exist
  and these five cases have no starting model
- the producer is collected at position 85 and the consumers at positions
  28-32, so within a single run the consumers read whatever a previous run
  happened to leave in the output directory

It currently works only because earlier runs left the file on disk. These
are among the newer rotation/settling cases, so this likely came in with
them.

Suggested fix: commit the start model under `startmodels/` and point
`FFIRST` at `{YREC_START}`, matching the convention the other 690 start
models follow. That removes the ordering dependency entirely rather than
relying on directory order in `pytest.ini`.

---

## 6. `IMPLICIT` statements are inconsistent between scoping units

**Status:** open. Audited 2026-10-12 and currently harmless, but it is a
trap worth closing before the F90 module conversion.

The house convention is three statements:

```fortran
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)
```

Only 8 files carry all three. Across the sources:

| what | count |
|---|---|
| `REAL*8` + `LOGICAL*4` (no `INTEGER*4`) | 149 files |
| `REAL*8` only | 34 files |
| all three | 7 files (+1 with them repeated per subprogram) |
| no `IMPLICIT` at all | 13 files |
| `IMPLICIT NONE` | 3 files |

`starin.f` is one of the 151 files lacking `IMPLICIT INTEGER*4(I,J,K,M,N)`,
which is what prompted this entry. Other specific oddities:

- `getyrec7.f` uses `IMPLICIT INTEGER*4(I-K,M)`, which omits `N`
- `condopacp.f` spells it `DOUBLE PRECISION(A-H),DOUBLE PRECISION(O-Z)`
- `alfilein.f` has five `IMPLICIT` statements because its subprograms
  declare them separately, and they are not all the same set

### Why it is currently harmless

- Omitting `IMPLICIT INTEGER*4(I,J,K,M,N)` changes nothing: `I`-`N`
  already default to `INTEGER(4)`, which is the same type and size.
- Omitting `IMPLICIT LOGICAL*4(L)` makes `L` names `INTEGER(4)`. That is
  the same 4-byte size, so a COMMON block's layout is unaffected, and any
  genuine logical use fails to compile rather than misbehaving quietly.
- Omitting `IMPLICIT REAL*8(A-H,O-Z)` is the dangerous one, because reals
  become 4-byte and a shared COMMON block would be laid out at half
  width. A per-scoping-unit audit of all 218 units found exactly one that
  both lacks it and declares a COMMON block, `version.f/SETVERSION`, and
  both members of `COMMON/VERSION/` there are explicitly
  `CHARACTER*10`/`CHARACTER*20`, so nothing is implicitly typed.

A full type/size resolution of every COMMON member in every declaring
file -- using that file's `IMPLICIT` rules plus its explicit declarations
-- found **zero** members whose type or size disagrees between files.

The other 15 units lacking `REAL*8` are small numerical helpers
(`spline.f`, `kspline.f`, `search.f`, `xrng4.f` and similar) plus three
embedded helpers, `slopes.f/SAFEDIVIDE`, `liburn.f/SAFEDIVEXP` and
`parmin.f/EXPAND_VALUE`. The three embedded ones declare every variable
explicitly (`REAL*8 NUMERATOR, DENOMINATOR, RESULT`), so they are safe.

### Why to fix anyway

The safety above is incidental, not structural. Adding one real local to
any of those 16 units, or adding a COMMON block to one, silently yields
4-byte reals with no warning: the compiler is doing exactly what the
(absent) declaration asks. The F90 conversion will also have to state
these types explicitly, so normalizing first removes a class of
conversion bug.

Suggested approach: bring every unit to the three-statement convention,
then move toward `IMPLICIT NONE` with explicit declarations as the module
conversion lands. The audit scripts used here are
`/home/pinsonneault.1/model/claude_work/implicit_audit.py` (cross-file
member type resolution) and `implicit_per_unit.py` (per-scoping-unit
`REAL*8` coverage); they are worth moving into the repo as a check if
this is pursued.
