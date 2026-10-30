# Known issues

Deferred items with enough context to be picked up cold. Each entry records
what was observed, where in the code it lives, and what decision was taken.
Resolved entries are kept, marked as such, because their reasoning is still
the record of why the code is the way it is.

## Index

Status as of 2026-10-27.

| # | issue | status |
|---|---|---|
| 1 | `SECULR` `LCODM` override not gated on solid-body rotation | open; MHP reviewing |
| 2 | One case unchanged although both `LCODM` gates are open | open, unexplained |
| 3 | `dadcoeft.f` has no test coverage | open; needs a `LROT`+`LDIFAD` case |
| 4 | m9p0 TAMS cases did not reproduce their start model | **resolved** 2026-10-16 (`9568ab4`); confirmed 2026-10-20 |
| 5 | Five cases read a file a later example case writes | open |
| 6 | Inconsistent `IMPLICIT` statements | **resolved** 2026-10-20 (stage 5) |
| 7 | QENV/QATM callback data cannot become arguments | standing constraint |
| 8 | `LREADCO`: read the EOS table earlier | **resolved** 2026-10-13 |
| 9 | `PREVCZ` information flow | open; MHP to investigate |
| 10 | Table and index blocks excluded from consolidation | standing rule |
| 11 | Classification of the per-shell working blocks | blocks are modules; explicit-argument work not started |
| 12 | `MASSCHG2` set aside with the experimental mass-loss code | set aside by MHP |
| 13 | Write-only members kept as potential output | retained by MHP |
| 14 | Name divergences before the module conversion | **resolved** 2026-10-14 |
| 15 | `LENVG` dead namelist variable | step 1 of 2 done; code removal awaits the other developers |
| 16 | All cases share one output directory | open |
| 17 | `read_track_table` zeroes columns it cannot parse | **resolved** 2026-10-20 |
| 18 | Reference standards not tracked in git | superseded by 32 |
| 19 | `getopac.f` unused label 100 | **resolved** 2026-10-20 |
| 20 | Repository housekeeping | open |
| 21 | CZ-base scalars borrowing the envelope prefix | **resolved** 2026-10-15 |
| 22 | Names a future `USE` would capture | silent category **closed** 2026-10-20 (stage 5) |
| 23 | Floating literals missing a `D` exponent | **applied** 2026-10-16; confirmed by the 2026-10-20 full pass |
| 24 | Fifteen unreachable routines | **resolved** 2026-10-15 |
| 25 | 94 orphaned `PARAMETER` declarations | **resolved** 2026-10-15 |
| 26 | Centralise `JSON`, not the table dimensions | **resolved** 2026-10-15 (importers) and 2026-10-20 (block modules) |
| 27 | Inter-module dependencies | **resolved** 2026-10-20 |
| 28 | OPAL06 EOS table-grid tolerance | open |
| 29 | No explicit interfaces | open; unblocked now that stage 5 is done |
| 30 | Harness passes `NaN` silently | **resolved** 2026-10-20 |
| 31 | `GAM1` is `NaN` in the Yale EOS path | open; its case now fails, by design (issue 30) |
| 32 | Test references not under version control | open; MHP to decide |
| 33 | Crash-terminated cases: run extent is the measurement | documented; not a defect |
| 34 | `ZAHB_m1p0feh+0p0_TAHB` no longer reaches TAHB | open; needs MHP's judgement |
| 35 | Cases read a start model a later case overwrites | open; install-time checks now in `rebaseline.py` |
| 36 | yaleeos TAHB aborts in `TPGRAD` | open (cause of the `NaN`); rebaselined 2026-10-20 |
| 37 | Three OPAL06 EOS `COMMON` blocks were never converted | **resolved** 2026-10-20 |
| 38 | A bare `STOP` ends a failed run with exit status 0 | open |
| 39 | High-mass start models too compact to resolve the D birthline | DBL above 2.4 Msun rebuilt by zero-timestep ramp, 2026-10-27 |

## Status of the original tasks

Both original tasks are **closed** as of 2026-10-13.

*Remove obsolete functions* -- the obsolete physics options were removed
over the preceding sessions (OPAL92, Kurucz 1990, LAOL89 and Alexander 1995
opacities, the MHD and OPAL 1995/2001 equations of state, the Monte Carlo
option, RTAB, LPMM, PMMWMAX, LSCRIB), and the 183 stale COMMON declarations
they left behind were swept in `84fba4e`.

*Consolidate or remove COMMON blocks* -- 153 blocks became 86. The namelist
consolidation went from 62 blocks to 2 (`COMMON/NMLPAR/`, 234 members, and
`COMMON/NMLBYPASS/`, 83), with all 367 namelist variables accounted for and
no `CHARACTER` data left in any COMMON block. Every remaining block is
classified: 6 settled, 24 tables/indices/machinery (issue 10), 17
start-of-timestep and 8 output stores (issue 11), 7 rotation, and the rest
set aside by ruling. No unclassified consolidation candidates remain.

Issues 1 to 13 below are what those tasks surfaced and did not resolve;
issues 14 to 20 were added when closing them out. The next body of work,
F90 modules and `IMPLICIT NONE`, is planned separately in
`F90_CONVERSION_PLAN.md`.

*F90 modules and `IMPLICIT NONE`* -- stages 0 to 5 are **done** as of
2026-10-20. Every scoping unit is `IMPLICIT NONE`, and 83 blocks are
modules. Three OPAL06 EOS blocks were missed by the conversion and are
still `COMMON` (issue 37). Issues 21 to 37 were added during this work.

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

**Status: RESOLVED 2026-10-16 in `9568ab4`, confirmed 2026-10-20.** The
2026-10-20 full run left `startmodels/` with no tracked changes.
The issue 23 rebaseline carried out the fix below: it committed the
regenerated `base` and `yaleeos` TAMS start models together with
references regenerated from them. A re-run confirmed that the `base`
producer rewrites its `.last` byte-identically and that `..._base_TAHB`
passes. The `yaleeos` TAHB consumer now aborts on its new start model,
which is issue 36, not this. Step 3, a full run that leaves
`startmodels/` clean, is being checked by the 2026-10-20 full run. The
ordering hazard behind this entry is still open, as issue 35.

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

**Status: RESOLVED 2026-10-20 by stage 5** (`F90_CONVERSION_PLAN.md`).
Every scoping unit is now `IMPLICIT NONE` with explicit declarations, so
no `IMPLICIT` typing statement remains and the inconsistency below no
longer exists. Every type was preserved exactly. No unit turned out to
need a 4-byte `REAL`, and the 30 `L`-prefixed names in units without
`LOGICAL*4(L)` are integers and stay `INTEGER`. The text below is the
original audit.

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

---

## 7. Constraint: blocks serving the QENV/QATM callbacks cannot become arguments

**Status:** not a defect. Recorded so further consolidation does not break
it.

`QATM` and `QENV` are declared `EXTERNAL` in `envint.f` and handed to
`BSSTEP`, which passes them to `MMID` as its `DERIV` dummy procedure.
They are therefore invoked polymorphically with a fixed argument list and
**cannot take new arguments**. Anything they need must travel by COMMON.

`COMMON/QENVMIX/CMIXLQ` exists for exactly this reason: it relays `CMIXL`
to `QENV` after `CMIXL` was converted from COMMON storage to an explicit
argument everywhere else. `envint.f` sets it immediately before every
path that can reach `QENV`, direct calls and the `BSSTEP`/`MMID` callback
alike. Both sides already carry a comment saying so (`qenv.f` at the
subroutine header, `envint.f` at the declaration).

So `QENVMIX` is **not** a merge or demotion candidate despite looking like
an ideal one -- one member, two files. A census that ranks blocks by size
and file count will keep proposing it; it must be skipped.

`QATM` needs no such relay, but note it keeps unused dummy arguments alive
with `IF (.FALSE.) PRINT *, B, FTL, LOCOND, RL` for the same
interface-compatibility reason. Do not "clean up" that line.

The blocks shared with these two routines form the callback's data
channel and should be treated as load-bearing:

- `envint.f` with `qenv.f`: `COMP`, `ENVPRT`, `PULSE`, `PULSE1`,
  `PULSE2`, `QENVMIX` (plus `CONSTANTS`, `NMLPAR`)
- `envint.f` with `qatm.f`: `ATMOS`, `ATMPRT`, `NEWOPAC`, `PULSE`,
  `PULSE1`, `PULSE2` (plus `CONSTANTS`, `IOUNITS`, `NMLPAR`)

Members of those blocks may still be demotable when they never cross the
boundary -- `PULSE2`'s `QQET`, for instance, is set in `envint.f` and
passed onward by argument, while `qenv.f` and `qatm.f` only carry it
positionally and never use it -- but each case needs checking against
this boundary first, not just a file count.

---

## 8. `COMMON/LREADCO/`: the EOS table should be read much earlier

**Status: RESOLVED 2026-10-13 in `17b669b`.** The one-time work moved into
a new `SETEOS06`, called from `SETUPS` under `IF(lopale06)` beside the SCV
table read, and `rhoofp06.f`'s fabricated `ESAC06` call -- made purely to
force the read -- is gone. Retained here for the record.

Original report:

`COMMON/LREADCO/` holds one flag shared by `esac06.f` and `rhoofp06.f`. It
gates the first-call read of the OPAL 2006 EOS table from inside a
low-level routine, so a large table read is triggered lazily, deep in the
call tree, rather than during setup.

The table should instead be read once during initialization, alongside the
other table reads, which would remove both the flag and the block. Left
alone for now because it changes startup sequencing rather than just
storage, and the lazy read is currently harmless.

---

## 9. `COMMON/PREVCZ/`: information flow needs tracing before any change

**Status:** open, flagged for MHP to investigate.

`COMMON/PREVCZ/` has five members shared by `liburn.f`, `liburn2.f` and
`main.f`. It looks like a small merge or demotion candidate by size and
file count, but the lithium-burning routines appear to use it to carry
convection-zone state between timesteps, which a census cannot confirm.

Likely to need preserving. Do not treat it as ordinary consolidation
fodder until the flow between the two `liburn` routines and `main.f` has
been traced -- in particular whether the values are expected to persist
across calls, as with `chkcal.f`'s `BLP`/`RLP`.

---

## 10. Rule: table and index COMMON blocks are excluded from consolidation

**Status:** standing rule, agreed 2026-10-13.

Blocks holding input data tables, or the index and interpolation state for
those tables, are **not** candidates for merging or for conversion to
declared variables. They are read once from an input file during setup and
then shared read-only by the physics routines; that is what COMMON is
genuinely for here, and merging them would mix unrelated table families.

### How to tell one

The reliable discriminator is **what the array dimensions are**:

- a **table or index block** is dimensioned on the table-grid parameters --
  `NUMT`, `NUMD`, `NUMX`, `NUMZ`, `NUMXZ`, `NTA`, `NGA`, `NTS`, `NPS`,
  `NTC`, `NGC`, `NG`, `NT`, `mx`, `mv`, `nr`, `nt` -- or on literals that
  are table extents, such as `ZLAOL`'s `(104,52)` and `CCR`'s `(5,43,20)`
- **working storage** is dimensioned on `JSON`, the maximum shell count

Do not classify on literal dimensions alone: `CKIND`'s `RESCAL(4,50)` and
`SETT`'s `LENDAG(50)` are dimensioned on the run-loop count, and `COMP`'s
`FXENV(12)` on the ionization species, so none of those is a table.
`DEBHU`'s `ZDH(18)` is per-element Debye-Huckel data and is a judgement
call, currently left out of the category.

Two members of the category have no array members and are included because
they belong to a family: `ALATM05` holds the Allard table's Teff bounds,
and `OP95INTERP` is purely the interpolation index set for `LLOT95A`.

### The category, by family

| family | blocks |
|---|---|
| OPAL 2006 EOS | `AEOS06`, `EEEOS06`, `EOS06MISC` |
| SCV EOS | `SCVEOS` |
| OPAL95 / Livermore opacity | `LLOT95A`, `LLOT95`, `LLOT95E`, `OP95INTERP` |
| Alexander 2006 opacity | `ALOT06ALL`, `ALOT06`, `GALOT06` |
| Allard atmospheres | `ALATM01`, `ALATM02`, `ALATM05` |
| pure-Z / LAOL opacity | `ZLAOL`, `ZSLAOL` |
| Fermi / degenerate EOS | `CCR` |
| gray and KS atmosphere tables | `ATMOS2`, `ATMOS2C`, `FAC` |
| interpolation and solver machinery | `SPLIN`, `TRIDI`, `EGRID`, `EGRIDDER` |

24 blocks, about 65% of all remaining COMMON storage.

### Interpolation workspace counts too

`COMMON/SPLIN/XVAL(JSON),YVAL(JSON),XTAB(JSON),YTAB(JSON)` is excluded
even though it is dimensioned on `JSON` rather than on a table grid. It is
not physics state: it is the spline machinery's scratch, feeding
`osplin.f`, `spline.f`, `slopes.f`, `search.f` and `meval.f`, and its four
declaring files -- `eq2mod.f`, `mixcom.f`, `mixgrid.f`, `rotgrid.f` -- are
all regridding routines.

So the dimension test separates input tables from per-shell state, but it
does not catch numerical machinery. Arrays that exist to perform an
interpolation or a solve are excluded on the same grounds as the tables
they serve, whatever they are dimensioned on. Also in that category, per
MHP:

- `COMMON/TRIDI/A,B,C,D,U,GAMA` -- tridiagonal solver scratch
- `COMMON/EGRID/` and `COMMON/EGRIDDER/` -- the equal-grid remap used by
  ROTGRID

`COMMON/QUADRU/QUAD,GG` is **not** machinery despite sitting next to these:
it is a physical quantity tied to rotation, so it stays a candidate.

### Note: XTAB is two different variables

`XTAB` is a member of both `SPLIN` and `LLOT95E`, and the two uses are not
merely separate storage -- they are different kinds of quantity:

- **`LLOT95E/XTAB` is a composition.** `op95xtab.f:31` sets `XTAB = X`,
  recording the hydrogen mass fraction the loaded table was built for, and
  `getopal95.f:245` tests `IF(ABS(X-XTAB).LE.1.0D-4)` to ask whether the
  requested X matches that table. Its sibling `LLOT95/ZTAB` follows the
  same pattern, `ZTAB = Z` in `op95ztab.f`, for metallicity.
- **`SPLIN/XTAB(JSON)` is a coordinate.** It is the array of tabulated
  abscissae; `search.f` binary-searches `XTAB(1..NUM)` for a value.

So the `*TAB` suffix means "the composition this table is for" in the
opacity blocks and "the tabulated independent variable" in the spline
workspace. A reader who knows one convention will misread the other. No
file declares both blocks, so nothing is wrong today, but any future merge
touching either must not bring them into the same scoping unit, and the
names deserve to diverge before the module conversion.

### Note: LLOT95E's extent is spelled two ways

`getopal95.f`, `op952d.f` and `op95xtab.f` declare
`CAPPAE(NUMT,NUMD)`, while `main.f` declares `CAPPAE(NUMTT,NUMD)`.
Both parameters are 70 and `NUMD` is 19 everywhere, so the layout agrees
today and nothing is wrong. It is a trap, though: changing one spelling
without the other would resize the block in three files and not the
fourth. The linker's "size of symbol changed" warning would catch it, so
that warning must never be dismissed -- it is what the OP95INTERP
corruption earlier in this work was signalling.

MHP may revisit the larger ones later, so they are kept as a named
category rather than simply dropped from the lists.

---

## 11. Classification of the per-shell working blocks

**Status:** classification agreed 2026-10-13. Since then every block
below has become a module (stages 3 and 4, 2026-10-15), and
`COMMON/ENVCZ/` was deleted as recommended. Modules kept the blanket
`USE` model, so the work in group (c), passing intermediate quantities
explicitly as arguments, has **not started**. The classification still
stands as the guide for that work.

The remaining candidates are dominated by `JSON`-dimensioned per-shell
arrays. MHP's split, with the evidence behind each group.

### a. Start-of-timestep state -- keep in COMMON for now

`hpoint.f` is the routine that stores the model state, and it writes
exactly these: `OLDMOD`, `OLDPHY`, `OLDROT`, `OLDROT2`, `TEMP`, `SCRTCH`,
`DWMAX`, `ENTROP`, `DEUTER`, `BURN`. Together with the model-level state
`ACDPTH`, `CENV`, `LABEL`, `COMP2`, `CROSS` and `OVRTRN`, these hold the
model as of the start of the step and are read very widely -- `OLDMOD` by
19 files, `OVRTRN` by 22, `DEUTER` by 22. They stay in COMMON.

| block | words | files |
|---|---|---|
| `OLDMOD` | 115,002 | 19 |
| `OLDPHY` | 60,000 | 3 |
| `OLDROT2` | 45,000 | 5 |
| `OLDROT` | 30,000 | 6 |
| `TEMP` | 25,000 | 5 |
| `ACDPTH` | 25,017 | 6 |
| `ENTROP` | 20,000 | 2 |
| `OLDRAT` | 15,000 | 5 |
| `DWMAX` | 10,000 | 3 |
| `DEUTER` | 10,002 | 22 |

### b. Reconstructed solutions held for output -- keep in COMMON

Per MHP: `ENVSTRUCT` and `ATMSTRUCT` store the reconstructed envelope and
atmosphere solutions for output, so they stay. `SOUND` and `CENT` are
confirmed by MHP as the same category.

The general test is whether an **output routine** reads the block: the
output routines are entered at a different point in the control flow, so
passing these explicitly would mean threading large per-shell arrays down
through `main.f`. The test was derived from `ENVSTRUCT`/`ATMSTRUCT` and
then correctly predicted `SOUND` and `CENT`, so it is worth applying to
any further block before proposing it for conversion.

| block | words | read by |
|---|---|---|
| `ATMSTRUCT` | 75,001 | `stitch.f` |
| `ENVSTRUCT` | 105,001 | `stitch.f` (plus physics readers `calcad.f`, `gettau.f`, `tauint.f`) |
| `SOUND` | 5,001 | `putstore.f`, `stitch.f`, `wrtmod.f` |
| `CENT` | 5 | `stitch.f` |

`stitch.f` is the routine that writes the stitched interior + envelope +
atmosphere model, the `LSTCH` path that 51 namelists enable.

An earlier draft of this entry recommended `ATMSTRUCT` as the first piece
of work and described its hand-off as `envint.f -> surfbc.f`. Both were
wrong: `surfbc.f` is an `ENVSTRUCT` writer, not an `ATMSTRUCT` reader, and
`ATMSTRUCT`'s only reader is `stitch.f`, which is exactly why it must be
retained.

### c. Computed at intermediate steps -- candidates to pass explicitly

Produced partway through the solve, consumed nearby, and **not** read by
any output routine:

| block | words | writer -> reader |
|---|---|---|
| `GRAVSZ` | 20,000 | `setup_grsett.f` -> `model_to_equal.f` |
| `ROTDER` | 25,000 | `coefft.f` -> `crrect.f` |
| `NEWEPS` | 2 | `engeb.f` -> `coefft.f`, `ytime.f` |
| `NULOSS` | 2 | `engeb.f`, `parmin.f` only |
| `MASSCHG2` | 5 | `mdot.f`, `massloss.f` -> `coefft.f` |

Wider but the same character: `INTVAR`, `GRAVEZ`, `PUALPHA`, `GRAB`,
`FLUXES`, `DEBHU`, `DPMIX`.

### b2. Now dead: COMMON/ENVCZ/

`ENVRCZ` is written once, at `envint.f:940`, and read nowhere. `RINT` has
no references at all. Its only reader was the commented-out JVS block in
`wrtout.f` removed in stage 4, so this block became dead as a side effect
of that cleanup. Three declarations, removable.

### c. Rotation -- special handling

Rotation **cross-cuts** the other two groups rather than partitioning
them, which is worth stating plainly: of the candidates, only three are
touched exclusively by the rotation routines.

| block | words | writer -> reader |
|---|---|---|
| `TAUKH` | 30,000 | `setupv.f` -> `vcirc.f` |
| `DIFAD2` | 20,000 | `vcirc.f` -> `checkj.f`, `rotgrid.f` |
| `DIFAD` | 10,000 | `dadcoeft.f`, `rotgrid.f` -> `checkj.f`, `dcoeft.f` |

A further 21 are rotation-touched but not exclusive, so any rule framed as
"rotation blocks" will catch blocks that belong in groups (a) or (b):
`CENT`, `DIFAD3`, `DWMAX`, `ENVSTRUCT`, `INTVAR`, `LIOV`, `MDPHY`,
`NEWRAT`, `OLDMOD`, `OLDPHY`, `OLDRAT`, `OLDROT`, `OLDROT2`, `OVRTRN`,
`QUADD`, `QUADRU`, `ROTDER`, `SCRTCH`, `TEMP`, `TEMP2`, `VFACT`.

`QUADRU` is a physical quantity tied to rotation, not machinery, per
issue 10.

### Suggested order of work

1. `COMMON/ENVCZ/` -- delete it; it is dead.
2. `GRAVSZ` -- 20,000 words, two files, a single
   `setup_grsett.f` -> `model_to_equal.f` hand-off, not output-bound. The
   cleanest large conversion left.
3. `ROTDER`, then the small ones `NEWEPS`, `NULOSS`, `MASSCHG2`.

---

## 12. `COMMON/MASSCHG2/` is set aside with the experimental mass-loss code

**Status:** set aside by MHP, 2026-10-13. Do not trim it.

`COMMON/MASSCHG2/SACC,SCEN,SMASS0,DLOGP,DLOGT` looks trimmable: `SACC` is
assigned in `massloss.f` and `SMASS0` in `mdot.f` and neither is read
anywhere, while `SCEN` goes only from `massloss.f` to `MDOT`, which
`massloss.f` itself calls. A first pass did reduce the block to
`DLOGP,DLOGT` and was reverted.

It belongs to the experimental, partially implemented mass-loss section.
`SACC` (accreted-matter entropy) and `SMASS0` are computed for physics
that is not wired up yet, so "write-only" here means "not finished", not
"dead". Leave the block and its assignments alone.

Fixing outright bugs in that code is still wanted -- see the `mdot.f`
divisor guard in `6a3f560` and the `CALL MDOT` argument fix recorded
below -- but its COMMON blocks and seemingly unused members are not
consolidation material.

---

## 13. Write-only members that are potential output items -- retained

**Status:** retained by MHP, 2026-10-13. Do not delete these as dead.

Some COMMON members are assigned and never read. In this codebase that
does **not** reliably mean dead: several are quantities computed for
physics or diagnostics that are not yet wired up. MHP's ruling is to keep
them.

| block | members | written in | read |
|---|---|---|---|
| `GRAB` | `ENGHE3`, `HE3ALL`, `UMHE33`, `UMHEAL` | `coefft.f`, `engeb.f` | nowhere -- a potential output item |
| `INTVAR` | `DELAMI`, `DELMI`, `EPSILM`, `HS3`, `PM`, `QDTMI`, `TM` | `setupv.f` | nowhere (35,000 words) |
| `MASSCHG2` | `SACC`, `SMASS0` | `massloss.f`, `mdot.f` | nowhere -- see issue 12 |

`INTVAR`'s other four members, `ALM`, `DM`, `HGM` and `RM`, *are* consumed
outside `setupv.f`: `RM` by `getfc.f`, `seculr.f` and `vcirc.f`, `DM` by
`getfc.f`, and `ALM` and `HGM` by `vcirc.f`. Converting just those four to
arguments was considered and declined: the block survives either way
because of the seven retained members, so the structural gain is marginal
against adding nine array arguments to `SECULR`, `VCIRC` and `SETUPV`, the
rotation core.

Note when reading a census: the apparent uses of the seven members in
`getfc.f`, `seculr.f` and `vcirc.f` are only the `COMMON/INTVAR/`
declaration lines, which list all eleven. Executable use is confined to
`setupv.f`.

### Consolidation status

With this, all 86 remaining COMMON blocks are classified: 6
settled/consolidated, 20 tables and indices plus 4 interpolation and
solver machinery (issue 10), 17 start-of-timestep (issue 11a), 8 output
stores (issue 11b), 7 rotation (issue 11c), and the rest set aside by
ruling. No unclassified candidates remain.

---

## 14. Name divergences to settle before the module conversion

**Status:** RESOLVED on 2026-10-14. After these changes **all 82 blocks
declare identically in every file, and no member name appears in two
blocks.**

| case | action taken | files |
|---|---|---|
| `ATMPRT` position 1 | `TAU` → `TAUL` | 5 |
| `EGRID` position 3 | `EQS1` → `ES1` | 1 |
| `LLOT95E` scalar | `XTAB` → `XOP95` | 3 |
| `CENT` scalar | `ENVR` → `CZsurf_R` | 2 |
| `QUAD` | `quad.f` deleted | -- |

`quad.f` held `REAL*8 FUNCTION QUAD(IC,I,X,Y1,Y2,Y3,X1,X2,X3)`, a
quadratic interpolation helper with saved `XX12`/`XX13`/`XX23`
coefficient arrays -- the signature of the OPAL table interpolator. MHP
confirms it is a leftover of an OPAL equation-of-state table that was
removed earlier. It was referenced nowhere: no `EXTERNAL` declaration, no
call site outside the three files where `QUAD(I)` is `QUADRU`'s array,
and no undefined `quad_` reference in any object. `COMMON/QUADRU/`'s
member `QUAD` is now unambiguous and needs no rename.

The `TAU` → `TAUL` rename deliberately left comments alone. Eleven
comment lines in `alsurfp.f` and `envint.f` mention `TAU`, but every one
states physics -- `TAU = 2/3`, `TAU=100`, `DP/DTAU`, the T-tau relations
-- not the variable. Rewriting them would have made them false, since the
slot holds log<sub>10</sub>&tau;.

The original analysis follows, since the reasoning for each choice is
worth keeping.

A COMMON block may be declared with different member *names* in different
files, since matching is positional. A module has one set of names, so
each divergence must be resolved first.

A full census was run on 2026-10-14 over all 861 declarations, parsed at
the 132-column width the Makefile actually compiles at. **80 of the 82
blocks are declared identically in every file that holds them.** For
those, a module import is semantically identical to the `COMMON`
declaration it replaces.

An earlier pass of this census reported four divergent blocks. Two of
them, `OLDMOD` and `SCRTCH`, were artifacts of truncating statements at
column 72: `hpoint.f:103` runs to column 79, so `TEFFLO,MO` was read as
`TEFF`, inventing a variant. All 17 `OLDMOD` and all 16 `SCRTCH`
declarations agree. The lesson is the recurring one in this work -- a
tool that does not honour the real column rules produces a clean-looking
wrong answer.

### The complete set, five items

**1. `ATMPRT` position 1: `TAU` in five files, `TAUL` in `qatm.f`.**
The only one with physics in it, and the majority spelling is the wrong
one: the slot holds log<sub>10</sub>&tau;. `qatm.f:89-90` sets
`TAUL = X0` and derives a *local* linear `TAU = DEXP(CLN*TAUL)`, while
`envint.f:439` independently does `TAUN = DEXP(CLN*TAU)`. Both treat the
shared slot as a log, so there is no bug -- but five files call a log
quantity `TAU`. Resolve by renaming the five to `TAUL`, adopting the
minority spelling because it is accurate. Free: none of the five already
has a `TAUL`, and four only declare the block, `envint.f` being the sole
user.

**2. `EGRID` position 3: `ES1` in six files, `EQS1` in `seculr.f`.**
`seculr.f:125` is declaration-only and never references the name, so
renaming it to `ES1` carries no risk.

**3. `XTAB` is two different things.** In `LLOT95E` (3 files) it is a
**scalar**, the composition the loaded opacity table is for --
`op95xtab.f` sets `XTAB = X` and `getopal95.f` tests `ABS(X-XTAB)`. In
`SPLIN` (4 files) it is `XTAB(JSON)`, an **array** of tabulated
abscissae that `search.f` binary-searches. The `*TAB` suffix thus means
"the composition this table is for" in the opacity blocks and "the
tabulated independent variable" in the spline workspace. Rename
`LLOT95E`'s scalar: it is the smaller change and it preserves `SPLIN`'s
`XVAL/YVAL/XTAB/YTAB` symmetry, which a one-sided rename would break.
Same reasoning as `OP95INTERP`'s `RL`/`RLL` to
`RHO_T63L`/`RHO_T63LL`.

**4. `ENVR` is in two blocks.** `ENVSTRUCT` (7 files) has
`ENVR(JSON)`, one of eighteen `ENV*` envelope profile members; `CENT`
(2 files) has a scalar `ENVR` beside `TCENTER`, `PCENTER`, `DCENTER` and
`ENVLM`. Rename `CENT`'s: 2 files rather than 7, and `ENVSTRUCT`'s name
is the one consistent with its siblings. Both blocks are retained as
output storage per MHP.

**5. `QUAD` -- no rename needed.**
`REAL*8 FUNCTION QUAD(IC,I,X,Y1,Y2,Y3,X1,X2,X3)` in `quad.f` is
referenced nowhere in the tree; the `QUAD(I)` in `getqua.f`, `getw.f`
and `vcirc.f` is `QUADRU`'s array. The clash resolves by deleting the
dead function, which also drops `quad.o` from the link.

### Closed

`LLOT95E`'s `CAPPAE(NUMT,...)` versus `CAPPAE(NUMTT,...)` divergence,
previously listed here, is **gone**: all three real declarations now read
`CAPPAE(NUMT,NUMD),XTAB`, and `main.f`'s is a comment recording the
removal. `NUMT` and `NUMTT` are both 70 in any case.

### Why `USE ... , ONLY:` shrinks this problem

With `ONLY` adopted (see `F90_CONVERSION_PLAN.md` stage 1), an import
names just the members a routine references, so a name a routine does not
use cannot be captured. That removes the prefix-subset class entirely --
the `RL`/`RLL` situation could not recur -- and leaves only these five,
each of which is a genuine ambiguity worth fixing on its own merits.

---

## 15. `LENVG` is a dead namelist variable awaiting staged removal

**Status:** step 1 of 2 done on 2026-10-14. The code-side removal is still
open, and MHP is consulting the other developers before it happens.

`LENVG` has no executable use anywhere: its only occurrences are the
`COMMON/NMLBYPASS/` declaration continuations in `parmin.f`, `remap.f` and
`starin.f`, the `PHYSICS` namelist entry, and its `DATA` default. But
**960 tracked namelist files set it**, so it cannot simply be dropped from
the namelist -- a namelist read would then fail on every one of those
inputs.

MHP's required order: strip `LENVG` from all namelist files first, then
remove it from the namelist and the code. Not urgent; it costs one word.

**Step 1, done.** All 960 tracked namelist files had their single
`LENVG = .FALSE.` line removed, comment included: `testsuite` (51),
the nine `examples` case directories (55), `examples/class_exercises`
(6), `grid` (516), `sample_cases` (200) and `startmodels/sample_cases`
(132). Every line was byte-identical in form and held no other
assignment, so each file lost exactly one line and gained none.

This changed no output, for two independent reasons: the value removed
(`.FALSE.`) is the `DATA` default, and the `.short` echo is generated
from the `PHYSICS` namelist group rather than from the input text, so
`LENVG` is still echoed as `F`. That is why no reference regeneration
and no `[ignore]` rule were needed, unlike the `CMIXL` removal.

All 13 untracked namelists in `ClassExercises/` and
`examples/class_exercises/exercise_4/` were stripped too, so no namelist
in the tree names `LENVG` any more.

**Guard against reintroduction.** `pytest.ini` has a `[banned]` section
listing namelist variables that no test input may assign, and
`test_namelists_free_of_banned_variables` fails with the file and line of
each offender. `LENVG` is the first entry. This covers the dangerous
window: while the code still declares `LENVG` in the `PHYSICS` group, a
case that reintroduces it reads perfectly well and nothing complains --
right up until step 2 lands, when every such input breaks at once. The
check matches assignments only, so the `ATMSTP`/`ENVSTP` comments that
mention `LENVG` do not trip it. Remove the entry once step 2 is done,
since the namelist read is then its own check.

**Step 2, still open.** Removing `LENVG` from `COMMON/NMLBYPASS/` in the
three files, from the `PHYSICS` namelist group, and from the `DATA`
statement at `parmin.f:520`. That `DATA` statement also initializes
`ATMSTP` and `ENVSTP`, which are live, so only the `LENVG` item and its
`.FALSE.` value may be removed. Doing this *will* shorten the `.short`
echo by one line and so needs either regenerated references or an
`[ignore]` rule, the same treatment `CMIXL` received.

**Related stale comments, left alone.** 973 namelist files carry
`ATMSTP`/`ENVSTP` lines whose comments read "Maximum step in atmosphere
integrator for LENVG". `ATMSTP` and `ENVSTP` are live -- read in
`calcad.f:213-218`, `stitch.f:159-164` and `wrtmod.f:207-212`, each
assigning them into `ATMBEG/ATMMIN/ATMMAX` and `ENVBEG/ENVMIN/ENVMAX`.
Their lines were therefore not touched, since deleting them would change
the integrator step sizes from the namelist value 0.05 back to the `DATA`
default 0.5. Only the comment text is stale, and rewording it is a
cosmetic follow-up best done alongside step 2.

---

## 16. Every test case writes to one shared output directory

**Status:** open.

All cases resolve `OUTPUT placed in` to the same directory,
`/home/pinsonneault.1/model/output`. Consequences:

- Cases with the same base name in different test directories overwrite
  each other's output. Three such pairs existed between `testsuite/` and
  `examples/giant_differential_rotation/`; the content-based deduplication
  in `4cd6c72` stops them being *run* twice, but the shared directory is
  still the underlying fragility.
- A case cannot be re-run concurrently with another, so the suite cannot
  be parallelised with `pytest-xdist` as it stands, which is why a full
  run takes about five hours.

Per-case output directories would fix both.

---

## 17. `read_track_table` silently zeroes columns it cannot parse

**Status: RESOLVED 2026-10-20.** The cause was worse than the entry below
supposed. `read_track_table` sliced each row at hard-coded character
positions, and those positions had drifted from the `.track` format:
`Step`, `Shls` and `Age_gyr` occupy 34 characters, but the next column
was taken from character 33. Every column after the third was cut one
character off, failed to parse, and was zeroed whole -- 71 of 83 columns
in a typical track. This was not about values below 1e-99.

Now the reader takes its column names from the file's own header line
and splits each row on whitespace, as `read_store_file` already did.
Every row of all 301 reference tracks (131,780 rows) splits into exactly
as many fields as the header names. A new `fortran_float` reads the
`1.234-100` form Fortran writes for three-digit exponents. A row with the
wrong field count, or a value that still cannot be read, now raises
`ValueError` naming the file, line and column. The `.store` and `.last`
readers use the same converter, so they no longer zero a whole column
either. On a `.store` with tiny values, 4 columns that used to be zeroed
now keep values down to 2.8e-321. The `.last` reads are unchanged.

One visible change for callers: the column the old list called
`' H2_sur'`, with a stray leading space, is now `'H2_sur'`, as the file's
header spells it.

`wrappers/modelgrid_tools/alternate_tools/read_output_files.py` catches
parse failures and substitutes zero (`except: track[k] = 0`, and similar
at lines 51, 79 and 157). A malformed or unexpectedly formatted column
therefore reads as 0.0 rather than raising.

This made the reader unusable for comparing physics during this work: when
checking whether a change had moved a model, most columns came back as
zeros and only `Step` and `Age_gyr` could be trusted. It should raise, or
return a sentinel the caller must handle.

---

## 18. Reference standards are not tracked in git

**Status:** superseded by issue 32, which measures the same problem in
more detail and lists the options. The auto-copy hazard described here
is now documented in `REBASELINE_PROTOCOL.md`, where "a missing reference
is created silently, and the case passes" is the second harness
behaviour listed. The harness itself still does not warn.

`git ls-files` returns nothing for `testsuite/standard` or
`examples/*/standard`: all 903 reference files, about 493 MB, exist only on
disk. A regeneration that went wrong would be unrecoverable, and a fresh
clone has no references at all until a first run creates them -- at which
point the harness silently adopts whatever that run produced as the
standard, since it copies a missing reference and then compares it against
itself.

If they stay untracked, the auto-copy behaviour in `test_all.py` deserves a
warning, because a case with no reference always passes.

---

## 19. `getopac.f`: unused statement label 100

**Status: RESOLVED 2026-10-20.** The `100 CONTINUE` is removed, which
takes the gfortran warning count from 20 to 19. With the original line
numbering restored, the object is byte-identical, so the code is
unchanged.

`getopac.f:95` (it was line 114 when this was written) defines label 100
with nothing branching to it, giving the warning
`Label 100 at (1) defined but not used`. It is one of the 20 warnings the
gfortran build gives as of 2026-10-20, not the only one. Pre-existing, and almost
certainly another remnant of the removed opacity schemes. Worth clearing so
that the build is warning-free and a new warning stands out.

---

## 20. Repository housekeeping

**Status:** open.

Rechecked 2026-10-20; the first three items are unchanged.

- A stash is still unpopped: `stash@{0}: On development: pre-existing stray
  local edits, unrelated to this session, found blocking rebase`. It should
  be inspected and dropped or applied.
- `origin/doc_update` was reviewed and merged except for `spot_evol`, which
  MHP excluded as new code. The stale remote branch can be deleted.
- `main` is ahead 2 and behind 19 relative to `origin/main` (behind 14
  when first recorded), which wants sorting out separately from
  `development`.
- ~~A full suite run leaves the two m9p0 `.last` fixtures modified every
  time.~~ Resolved with issue 4; the 2026-10-20 full run is the check.

---

## 21. CZ-base output scalars were borrowing the envelope integrator's prefix

**Status:** RESOLVED on 2026-10-15.

### The naming scheme, per MHP

An earlier draft of this entry framed the problem as "`ENV*` carries two
unrelated meanings" and proposed reserving `ENV*` for the profile arrays.
That mis-described the code, and MHP corrected it:

- **`ENV*` and its `E*` abbreviations belong to the envelope integrator
  and its solution, and follow one set of rules.** That covers both
  `COMMON/ENVSTRUCT/`'s members -- the `ENV*` profile arrays *and* the
  `E*` ones, `EDELS`, `EVELS`, `EBETAS`, `EGAM1`, `EQCP`, `EFXIONS`,
  `EQDT` -- and the integrator controls in `NMLPAR`: `ENVERR`, `ENVBEG`,
  `ENVMIN`, `ENVMAX`, `ENVSTP`. None of these is a defect and none is to
  be renamed. In particular the `E*` abbreviation inside `ENVSTRUCT` is
  part of that scheme, not an inconsistency; a suggestion to normalise
  those seven members to `ENV*` was withdrawn.
- **`CZsurf_` is only for the global scalars used for output that hold
  surface convection-zone properties.** Those are the `COMMON/CENT/`
  members and the `wrtout.f` locals feeding them.

So there was only ever one genuine conflation: the CZ-base output scalars
were using the envelope integrator's prefix. That is what is fixed here,
and `ENVSTRUCT` needed nothing.

### The scalars that were misnamed

Computed in `wrtout.f` around the `MHP 2/98 FIND RADIUS OF CZ BASE`
comment:

| name | meaning | where it lives |
|---|---|---|
| `ENVLM` | mass in the convection zone | `COMMON/CENT/` |
| `CZsurf_R` | radius at the CZ base (was `ENVR`) | `COMMON/CENT/` |
| `ENVRL` | log radius at the CZ base | local, `wrtout.f` + `taucal.f` |
| `ENVTL`, `ENVDL`, `ENVPL` | log T, density, pressure at the CZ base | locals, `wrtout.f` |
| `ENVT`, `ENVD`, `ENVP` | the same three, delinearized | locals, `wrtout.f` |
| `ENVO` | opacity at the CZ base | local, `wrtout.f` |

**Why this matters for the module conversion.** Four names --
`ENVT`, `ENVD`, `ENVP` and `ENVO` -- are simultaneously `ENVSTRUCT`
array members in 8 files and *scalar locals* in `wrtout.f`. Nothing is
broken today only because `wrtout.f` does not declare `ENVSTRUCT`. The
moment it needs the envelope arrays -- plausible, since `ENVSTRUCT`
exists precisely for output and `wrtout.f` is an output routine -- a
blanket `USE` would silently alias those four scalars to the arrays.
`USE ... , ONLY:` prevents it, but the name reuse remains a trap for a
reader and for whoever next edits `wrtout.f`.

### Done on 2026-10-15, and what the survey found beyond it

Renamed, all in `wrtout.f` except `ENVLM`, which is a `CENT` member and so
also touches `main.f`: `ENVLM` to `CZsurf_M`, `ENVRL` to `CZsurf_RL`,
`ENVTL`/`ENVDL`/`ENVPL` to `CZsurf_TL`/`CZsurf_DL`/`CZsurf_PL`, and
`ENVT`/`ENVD`/`ENVP`/`ENVO` to `CZsurf_T`/`CZsurf_D`/`CZsurf_P`/`CZsurf_O`.
44 references in total. `ENVSTRUCT`'s members of those four names, in the
other seven files, are untouched -- which was the point.

**Effect on the shadow census:** the silent-capture set drops from 45 to
41, and `wrtout.f` goes to zero. `shadow_census.py --file wrtout.f` now
reports that any `USE` can be added safely. That was the safety argument
for doing this before `ENVSTRUCT` converts.

**`taucal.f` is deliberately untouched**, although it holds its own
`ENVRL` and `ENVR` locals computing the same CZ-base radius. Renaming
them would make matters worse: its `ENVR` currently shadows
`ENVSTRUCT`'s `ENVR(JSON)`, an **array**, so a future `USE` of that module
fails loudly on a rank mismatch, whereas `CZsurf_R` would shadow `CENT`'s
**scalar** of the same name and alias silently. A loud future failure is
worth more than a consistent name.

### Related daughter variables, surveyed but not changed

MHP asked whether other variables share the prefix. They do, in three
groups, none addressed above.

**1. `ENVSTRUCT`'s `E*` members -- NOT a defect, suggestion withdrawn.**
Of its 18 members, 9 are `ENV*` profile arrays, 2 are `LCENV` and
`NUMENV`, and 7 use a bare `E` prefix: `EDELS(3,JSON)`, `EVELS`,
`EBETAS`, `EGAM1`, `EQCP`, `EFXIONS(3,JSON)`, `EQDT` -- envelope del,
velocities, beta, gamma-1, Cp, ionization fractions, dT. This entry
originally proposed normalising them to `ENV*` as a cosmetic tidy-up.
MHP's ruling is that `ENVSTRUCT` belongs to the envelope integrator and
follows its rules, abbreviations included, so these are correct as they
stand and must be left alone.

**2. `NMLPAR` holds a third `ENV*` family -- EXCLUDED by MHP on
2026-10-15.** `ENVERR`, `ENVBEG`, `ENVMIN`, `ENVMAX` and `ENVSTP` are
envelope *integrator controls*: convergence tolerance and the beginning,
minimum and maximum step sizes. MHP's ruling is that they serve a
different purpose from the envelope solution and should not be folded
into any `ENV*`/`CZsurf_` scheme. They are not to be renamed.

This means `ENV*` deliberately retains two senses -- the `ENVSTRUCT`
profile arrays and these integrator controls -- which is a decision, not
an oversight. They collide with nothing, so nothing is at risk; the
`CZsurf_` split removed the only pair that did.

**3. The CZ-base computation is duplicated under three local names.**
Besides `wrtout.f`:

```
taucal.f:127     ENVRL  = HR(IMAX-1)+FX*(HR(IMAX)-HR(IMAX-1))
tauint.f:100     ENVRCL = HR(IMAX-1)+FX*(HR(IMAX)-HR(IMAX-1))
```

with `tauintnew.f` also holding `ENVRCL`. Three files compute the same
radius independently under different names, which is a consolidation
question rather than a naming one. `rscale.f` adds a fourth sense of the
prefix with `ENVOLD`, `ENVNEW` and `ENVTOTAL` for envelope *mass*.

Discount two apparent hits: `ENVELOPE` occurs only in comments and
`ENVINT` is a subroutine name. `shadow_census.py` reads identifiers from
statement text including quoted and commented content, so both show up in
a naive survey.

**Proposed rule.** Prefix by what the quantity is attached to, and keep
`L` as the log suffix:

- `CZsurf_` for the convection-zone-base scalars: `CZsurf_R` (done),
  `CZsurf_RL`, `CZsurf_M` (was `ENVLM`), `CZsurf_T`/`CZsurf_TL`,
  `CZsurf_D`/`CZsurf_DL`, `CZsurf_P`/`CZsurf_PL`, `CZsurf_O`.
- `ENV*` reserved for the `ENVSTRUCT` profile arrays.

Cost is low: every family-2 name except `ENVLM` and `ENVRL` is local to
`wrtout.f`, so the rename is confined to one file. `ENVLM` is a `CENT`
member and so touches `main.f` too; `ENVRL` also appears in `taucal.f`.

The same question should be asked of any other prefix that names both a
profile array and a scalar sampled from it.

---

## 22. Names a future `USE` would capture

**Status:** the silent category is **closed by stage 5, 2026-10-20**.
Every scoping unit is now `IMPLICIT NONE`, so a local cannot be
implicitly typed. A `USE` that brings in a name already declared locally
is a compile error. All 45 names listed under "The silent 45" below are
now declared locals, so capturing any of them would fail loudly. What
remains is a compile-time inconvenience, not a hazard.

`shadow_census.py` still reports 38 "IMPLICIT-local" pairs. All 38 are
parser false positives, not real implicit locals; the compiler now
guarantees there are none:

- 36 are `JSON` in `*_mod.f` files, where it is declared with F90 `::`
  syntax that the census does not parse.
- `tpgrad.f` `CAPPA` occurs only inside a `FORMAT` string.
- `calcad.f` `TAUCZ` occurs only in a comment.

The original text follows, measured on 2026-10-14.

The module conversion uses a **blanket `USE`**, decided in
`F90_CONVERSION_PLAN.md` stage 1. That is safe for the conversion itself
because of three properties that hold across the code after the issue 14
renames:

- every block is declared identically in every file that holds it,
- no member name appears in two blocks,
- no member name is also a procedure name.

A blanket `USE` placed where the `COMMON` declaration stood therefore
imports exactly the names that declaration already made global in that
scoping unit. It cannot change meaning, which is a stronger guarantee
than `USE ... , ONLY:` offers: an `ONLY` list that omits a scalar member
compiles and links clean, leaving an implicitly typed local whose writes
go nowhere.

**The risk is the next edit, not the conversion.** If a file uses a name
as a local and later imports a module exporting that name, the local is
captured. The census over all 212 files finds 159 (file, name) pairs
where that could happen, and how each would fail depends on how the local
is declared:

| | count | outcome if that module is `USE`d |
|---|---|---|
| dummy argument | 93 (58%) | compile error -- loud |
| declared local | 21 (13%) | compile error -- loud |
| **implicitly typed local** | **45 (28%)** | **silent capture** |

So 114 of the 159 announce themselves. The dangerous set is 45, it is
enumerable, and **none of it affects the conversion**: each of those
files does not declare the owning block, so a faithful conversion gives
it no `USE` of that module.

`IMAX` from `INTPAR` is the worst single name -- an implicitly typed
local in 8 files, and referenced in 21 files altogether. Four of the 45
are issue 21's `ENV*` overload: `wrtout.f` uses `ENVD`, `ENVO`, `ENVP`
and `ENVT` as convection-zone-base scalars while `ENVSTRUCT` exports them
as profile arrays. That makes issue 21's rename a safety fix, not only a
clarity one, since `ENVSTRUCT` exists for output and `wrtout.f` is an
output routine.

### Two checks to run by habit

Before adding a `USE` to a file:

```
./shadow_census.py --file wrtout.f
```

Before adding a member to a module:

```
./shadow_census.py --member IMAX
```

The first lists what that file would have captured; the second lists
every file already using the name, so a new member cannot quietly collide
with an existing local. Run with no arguments for the full census.

### The silent 45

- `bsrotmix.f` `IMAX` -- captured from `INTPAR`
- `calcad.f` `TAUCZ` -- captured from `OVRTRN`
- `codiff.f` `AMUM` -- captured from `MDPHY`
- `codiff.f` `THDIFM` -- captured from `MDPHY`
- `codiff.f` `VISCM` -- captured from `MDPHY`
- `envint.f` `GAM1` -- captured from `SOUND`
- `eqsaha.f` `FACT1` -- captured from `VFACT`
- `eqsaha.f` `FACT2` -- captured from `VFACT`
- `eqsaha.f` `SQET` -- captured from `ROTDER`
- `eqstat2.f` `AMUO` -- captured from `OLDPHY`
- `eqstat2.f` `DELAO` -- captured from `OLDPHY`
- `eqstat2.f` `QDTO` -- captured from `OLDPHY`
- `eqstat2.f` `RAT` -- captured from `QUADD`
- `getopac.f` `SQOT` -- captured from `ROTDER`
- `gettau.f` `IMAX` -- captured from `INTPAR`
- `getw.f` `ENVR` -- captured from `ENVSTRUCT`
- `getw.f` `IMAX` -- captured from `INTPAR`
- `getw.f` `IMIN` -- captured from `FAC`
- `grsett.f` `IMAX` -- captured from `INTPAR`
- `hpoint.f` `DCHI` -- captured from `EGRID`
- `hpoint.f` `DSS` -- captured from `DIFAD3`
- `hpoint.f` `NTOT` -- captured from `EGRID`
- `mcowind.f` `TCZ` -- captured from `ACDPTH`
- `mdot.f` `DELM` -- captured from `MDPHY`
- `microdiff_cod.f` `CON_RAD` -- captured from `CONFAC`
- `microdiff_cod.f` `CON_TEMP` -- captured from `CONFAC`
- `microdiff_run.f` `IMAX` -- captured from `INTPAR`
- `momi.f` `ETA2X` -- captured from `OLDROT`
- `mwind.f` `FCORR` -- captured from `CTOL`
- `mwind.f` `TCZ` -- captured from `ACDPTH`
- `oeqos06.f` `DLOGP` -- captured from `MASSCHG2`
- `oeqos06.f` `ZTAB` -- captured from `LLOT95`
- `radsub06.f` `RAT` -- captured from `QUADD`
- `ratext.f` `IMAX` -- captured from `INTPAR`
- `rhoofp06.f` `RAT` -- captured from `QUADD`
- `simeqc.f` `IMAX` -- captured from `INTPAR`
- `surfbc.f` `NUMENV` -- captured from `ENVSTRUCT`
- `taucal.f` `ENVR` -- captured from `ENVSTRUCT`
- `tauint.f` `IMAX` -- captured from `INTPAR`
- `tauintnew.f` `IMAX` -- captured from `INTPAR`
- `tpgrad.f` `CAPPA` -- captured from `LLOT95`
- `wrtout.f` `ENVD` -- captured from `ENVSTRUCT`
- `wrtout.f` `ENVO` -- captured from `ENVSTRUCT`
- `wrtout.f` `ENVP` -- captured from `ENVSTRUCT`
- `wrtout.f` `ENVT` -- captured from `ENVSTRUCT`

---

## 23. Floating literals missing a `D` exponent lose precision

**Status:** APPLIED and rebaselined 2026-10-16. 413 literals given a `D`
exponent, plus 5 replacements of a near-2/3 constant by the exact `CC23`
/ `CC13`. 4 literals held back as issue 28. The measured effect is below;
**887 of 894 references installed** at first, with two cases held back
as issues 34 and 36. Issue 36's three were installed on 2026-10-20 at
MHP's direction, making it 890; only issue 34's case is still held back,
plus the one empty `.store` (issue 33). The first full pass against these
references is the 2026-10-20 run: 296 of 298 passed, and the two
failures are the expected ones (issue 34's case on its held-back
references, and issue 36's abort). `startmodels/` was left clean. Originally flagged by
MHP on 2026-10-14: the code is designed so that
floating point is `REAL*8` throughout, so a literal written without `D0`
is far more likely an accident than an intention, and should be treated
as a defect rather than preserved.

A literal with no `D` exponent is a default-real (single precision)
constant. Reaching a `REAL*8` variable it is widened, so the stored value
is the *single* approximation of the decimal rather than the decimal:

```
0.9828    ->  0.98280000686645508
0.9828D0  ->  0.98280000000000000
```

An `E` exponent is single too: `1.32E30` is as lossy as `1.32`.

### Scope, measured with `literal_audit.py`

| | count |
|---|---|
| literals already carrying a `D` exponent | 4001 |
| no `D`, but exactly representable in binary32 -- harmless | 476 |
| **no `D`, and lossy when widened -- defects** | **413** |

The harmless 476 are values such as `0.0`, `1.0`, `0.5` and `2.0`, which
are exact in binary32, so widening them costs nothing and they need no
change. Separating those two groups is the point of the audit: a blanket
sweep over every literal lacking `D0` would touch 889 and change nothing
in 476 of them.

**FORMAT statements must be excluded**, and the first pass of this audit
did not. A FORMAT is full of tokens that look like real literals but are
edit descriptors -- `1P6E13.5`, `16E16.8`, `12E10.3` from
`wrtout.f:1800`. They carry no precision at all. Counting them inflated
the figure to 459 and produced an entirely spurious set of "worst files"
(`wrtmod.f` 13, `envint.f` 12, `wrtout.f` 7, `starin.f` 4), every one of
which is in fact clean. `literal_audit.py` now skips FORMAT statements
and their continuation lines.

The real 413 are concentrated far more sharply:

| file | lossy literals | what they are |
|---|---|---|
| `engeb.f` | 211 | nuclear masses and Q-values |
| `rates.f` | 160 | reaction-rate coefficients |
| `parmin.f` | 17 | namelist defaults |
| `eqsaha.f` | 11 | Saha equation constants |
| `esac06.f` | 5 | |
| `sneut.f` | 4 | |
| 5 further files | 5 | one each |

So **371 of 413 (90%)** are the tabulated nuclear data in `engeb.f` and
`rates.f` -- `ANUC/1.008665,1.007276,2.013553,.../`, `Q6`, `Q7` and the
like. Relative errors run to 5.8e-8, i.e. the eighth significant digit
onward is wrong.

### The single-precision routines: delete rather than convert

MHP's ruling on 2026-10-14: single precision has no clear benefit here
and complicates the work, so the `REAL*4` declarations should become
`REAL*8` at the same time as the explicit-typing stage.

Investigating what that involves gives a better answer. The only
single-precision declarations in the entire tree are four lines in two
files:

```
splinnr.f:3   REAL yp1,ypn,x(n),y(n),y2(n)
splinnr.f:6   REAL p,qn,sig,un,u(NMAX)
splnr.f:3     REAL yp1,ypn,x(n),y(n),y2(n)
splnr.f:6     REAL p,qn,sig,un,u(NMAX)
```

and **both routines are dead**. `splinnr_` and `splnr_` are defined in
their own objects and referenced nowhere: no `CALL` site in any case or
spacing, no `EXTERNAL` declaration, and no undefined reference to either
symbol in any object file. They are also **byte-identical to each other
apart from the subroutine name** -- the same Numerical Recipes `spline`
routine copied twice, 34 lines each.

(An earlier check appeared to find two references to them. That was a
false positive: `nm -u *.o` prints a `filename:` header line per object,
and those headers matched the grep. Filtering to lines actually marked
`U` shows nothing references either routine.)

The tree already has nine live spline routines -- `cspline.f`,
`kspline.f`, `osplin.f`, `ksplint.f`, `splinj.f`, `splinc.f`,
`splintd2.f`, `splint.f`, `ysplin.f` -- and `boole.f`, whose comment at
line 13 still refers to "numerical recipes SPLINE (renamed splinnr)",
in fact calls `SPLINJ` and `SPLINT`.

**Recommended: delete both files**, as `quad.f` was deleted. That removes
68 lines of duplicated dead code and eliminates single precision from the
codebase entirely, which satisfies the intent of the ruling more
completely than retyping them would. The stale comment in `boole.f:13`
should be corrected in the same change.

If instead they are to be kept for future use, converting `REAL` to
`REAL*8` in all four lines is the alternative; it is behaviour-neutral
because nothing calls them. Either way, after this change a type-aware
literal sweep no longer needs an exception for declared single
precision.

### Why after the module conversion, and all at once

- **Byte-identity is the conversion's only validation criterion**, and it
  has caught real defects. A precision fix changes outputs by design, so
  interleaving the two makes a diff ambiguous: a conversion bug and the
  intended change become indistinguishable.
- **Interference is minimal.** 371 of the 413 are in `engeb.f` and
  `rates.f`, which the conversion does not touch. Only `parmin.f`'s 17
  are in `DATA` statements that migrate into modules, and they migrate
  verbatim, so fixing them afterwards in the module is one edit each.
- **Doing it first would leave every later conversion stage validating
  against freshly regenerated, unreviewed references.**
- **All at once**, with a single reference regeneration. Each fix is
  text-preserving -- only the exponent marker changes -- so per-fix risk
  is nil; what needs judgement is the aggregate physics change, best read
  in one diff. Incremental would mean repeated five-hour regenerations
  for no gain. Review the diff by group: nuclear data, namelist defaults,
  output routines.

### What to expect when it is done

Every one of the 298 references will change. The shifts start at ~5e-8
but amplify over Gyr of nonlinear evolution -- see issue 4 for the m9p0
TAHB case, which already diverges chaotically from a last-digit
difference in its start model. Validation must therefore be the 2% float
tolerance and physics review, not byte-identity.

Note also that this is a scientific-provenance decision as much as a code
one. The fix makes the constants match their written values, so present
behaviour is defensibly wrong, but it is the behaviour every existing
published YREC model was computed with. That argues for one deliberate,
well-documented change rather than a quiet sweep.

### Measured effect, 2026-10-16

The prediction above held: the shifts start at roundoff and amplify
through nonlinear evolution. Measured over all 298 cases, 894 output
files, against the pre-fix references (preserved as a verified 204 MB
tarball under `reference_baseline_pre_issue23/`, 903 files, manifest
checksums confirmed against the unpacked copy).

**How far individual values moved** -- pooled over every comparable
value, which is the honest statistic. A *per-file maximum* is set by
whichever diagnostic in that file is most singular and says nothing about
the run; see the caution below.

| | |
|---|---|
| numeric values compared | 54,264,456 |
| exactly unchanged | 20,868,371 (38.5%) |
| 90th percentile relative change | 3.6e-07 |
| 99th percentile | 8.3e-04 |
| 99.9th percentile | 4.8e-02 |
| past the 2% tolerance | 55,752 (0.103%) |
| ...of those, with \|ref\| < 1e-20 | 10,065 |

**How far the runs got** -- the measurement that matters for
crash-terminated cases (issue 33):

| | |
|---|---|
| final model number identical | 284 of 298 (95.3%) |
| final age within 0.1% | 289 of 298 |
| final age shifted by more than 0.5% | 6 |

The six are concentrated on the horizontal branch -- 4 of 33 ZAHB-to-TAHB
cases, against 1 of 13 red giant, 1 of 78 pre-MS, and **0 of 191** across
to-ZAMS, to-TAMS, solar and the rest. MHP, 2026-10-16: these cases are
known to be numerically touchy, and are being forwarded to other
developers to check. Only one changed whether it meets its own stopping
criterion -- issue 34.

### Caution: do not quote per-file maxima

The per-file worst relative change reaches 1e24 and above. Every such
entry is one of two harmless classes, and quoting them as the size of the
change is wrong:

- **Trace values.** `2.9e-66 -> 2.9e-41` in `Test_m0400_feh0_noGS_ZAMS`
  is a ratio of 1e25 and an absolute change of 3e-41.
- **Singular diagnostics.** `TauCZ_s` in
  `Test_m1p0feh+0p0GS98_base_HeIgnite` goes 2.2e5 -> 2.1e18 s, a 1/x
  quantity that diverges as the surface convection zone thins at helium
  ignition, while the columns either side of it agree to six digits.

Separately, **both the harness and any ad-hoc comparison align output to
reference by line position**, so a run that takes one extra model
iteration mismatches every line after the divergence no matter how small
the perturbation. Of the 894 files, 600 keep the same structure end to
end and 294 diverge mid-file (median: only 21% of the file comparable).
A first attempt at this measurement that ignored that reported `inf` and
"100% of files changed"; both were artifacts of the misalignment. Any
future rebaseline measurement must separate the aligned region from the
point of structural divergence. `claude_work/measure_shift.py` and
`claude_work/measure_extent.py` do this.

### Defects this rebaseline surfaced

All pre-existing, none caused by the literal fix: issues 30 (the harness
silently passes `NaN`), 31 (`GAM1` is `NaN` in the Yale EOS path), 32
(the references are not under version control), 33 (crash-terminated
cases), 34 (`ZAHB_m1p0feh+0p0_TAHB`), 35 (three cases read a start model
a later case overwrites) and 36 (`Test_m9p0feh+0p0GS98_yaleeos_TAHB`
aborts in `TPGRAD`).

Seven of the 894 reference files are therefore left at their pre-fix
values: three for issue 34, three for issue 36, and one empty `.store`
for issue 33.

---

## 24. Fifteen unreachable routines, mostly left by the physics removals

**Status:** RESOLVED 2026-10-15. MHP triaged it the same day: keep
`putyrec7.f`, remove the other fourteen. Done in `da1887a` -- 1001 lines
of unreachable code, with `putyrec7.f` retained deliberately and recorded
below so a future dead-code check reporting it is not mistaken for an
oversight. Found on 2026-10-14 in answer to his question of whether the
earlier physics removals left dead routines behind. They did.

`dead_code.py` answers this from the linker's symbol table rather than by
grepping for `CALL`, which misses function references, `EXTERNAL`
declarations and unexpected casing. It records what each object defines
and references, then walks outward from whichever object defines
`MAIN__`. The walk is **transitive**, which matters: a routine called
only by another dead routine still looks referenced if you merely ask
"is this symbol undefined somewhere".

Of 215 objects, 200 are reachable and **15 are not**, totalling 1001
lines:

| file | lines | what it is | why it is probably dead |
|---|---|---|---|
| `findex.f` | | "INTERPOLATION PKG FOR COX'S AND FOR KURUCZ'S OPACITIES" | Kurucz 1990 opacities were removed |
| `quadeos01.f` | | `QUADEOSS01` | OPAL 2001 EOS was removed; `quadeos06.f` is live |
| `gmass01.f` | | the 2001 counterpart of `gmass06.f` | same removal; `gmass06.f` is live |
| `gmass.f` | | the original of the same family | superseded by `gmass06.f` |
| `intpt.f` | | "GROUP: SR_P" table interpolation | calls only `lir.f` |
| `lir.f` | | `lir_`, `lir1_` | called only from `intpt.f` |
| `intpol.f` | | spline interpolation package | calls only `ysplin.f` |
| `ysplin.f` | | | called only from `intpol.f` |
| `putyrec7.f` | | "Write out a stellar model in YREC7 format" | the reader `getyrec7.f` is live; only the writer is unused |
| `splinnr.f` | 34 | Numerical Recipes spline, single precision | see issue 23 |
| `splnr.f` | 34 | byte-identical copy of `splinnr.f` | see issue 23 |
| `rabu.f` | | | |
| `quint.f` | | | |
| `wcz.f` | | | `wczimp.f` is live |
| `zero.f` | | | |

The two transitive pairs are worth noting as evidence the method works:
`LIR` has two call sites and `YSPLIN` one, so a naive check would call
them live -- but every caller is itself unreachable.

### Why this is worth doing before the rest of the conversion

One of the fifteen, `wcz.f`, declares `COMMON/NMLPAR/`, so removing it
takes `NMLPAR` from 104 declaration sites to 103 before the largest
remaining stage runs.

A first pass claimed three of them declared `NMLPAR` and that `wcz.f`
also declared `NMLBYPASS`. That was wrong, from a grep that matched
`COMMON/NMLPAR/` anywhere in the file including inside comments -- and
these files carry conversion-history comments naming the block.
Column-aware matching gives one real declaration, in `wcz.f` alone, and
none of `NMLBYPASS`. This is the third time in this work that matching a
block name without honouring the column rules produced a confident wrong
answer; it is why `shadow_census.py` and the conversion tool both parse
statements rather than grep lines.

It is also already costing work: `putyrec7.f`, `intpol.f` and `wcz.f`
received module conversions earlier today, so dead code is being
carefully migrated for no benefit.

### Triage, settled 2026-10-14

MHP's ruling: **keep `putyrec7.f`, remove the other fourteen.**

**`putyrec7.f` is a deliberate exception.** It writes the YREC7 model
format whose reader, `getyrec7.f`, is still live, so it may have legacy
use even though nothing in the tree calls it. It stays unreachable on
purpose, in the way `COMMON/MASSCHG2/` was retained with the experimental
mass-loss code (issue 12). Anyone running a dead-code check will see it
reported; that is expected, and this entry is the reason. It references
only `log10`, so it carries no other dead code with it.

The fourteen removed: `findex.f`, `gmass.f`, `gmass01.f`, `intpol.f`,
`intpt.f`, `lir.f`, `quadeos01.f`, `quint.f`, `rabu.f`, `splinnr.f`,
`splnr.f`, `wcz.f`, `ysplin.f`, `zero.f`.

Checked before removal, because an unreachable routine can still be
*referenced* by another unreachable one and a dangling reference breaks
the link even though neither runs: across all 215 objects the only
references to any of the fourteen were `intpol.o` to `ysplin_` and
`intpt.o` to `lir_`. Both sides of each pair are in the set, so removing
them together leaves nothing dangling. `putyrec7.o` references none of
them.

`boole.f`'s comment credited "numerical recipes SPLINE (renamed
splinnr)"; it actually calls `SPLINJ` and `SPLINT`, and the comment was
corrected in the same change.

This also removes the last single-precision declarations in the tree, so
issue 23's exception for declared `REAL*4` no longer applies: every
floating variable is now `REAL*8` and a literal sweep can be uniform.

---

## 25. The module conversion orphaned 94 `PARAMETER` declarations

**Status:** RESOLVED 2026-10-15. All 94 removed: 67 statements deleted
outright, 5 rebuilt where live entries remained, across 38 files, for a
net 67 lines. Build clean, 19 targeted cases byte-identical.

Two notes from doing it. The detector originally excluded *all*
`PARAMETER` statements when looking for uses, which would have wrongly
orphaned a parameter used only to compute another -- `sneut.f` does that
throughout, with `fac1 = 5.0d0*pi/3.0d0` and `tfac1` built from `cv`,
`ca`, `cvp`, `cap` and `xnufam`. It now counts occurrences across every
statement and requires exactly one, the name's own declaration. The list
came out at 94 either way, so no false positive was present, but the
check no longer depends on that.

The column-132 guard also refused `main.f` for a 159-character line,
which turned out to be a comment -- the only line past 132 in the tree,
and one the compiler ignores. The guard now looks at code lines only.

The original finding follows.

Of the integer `PARAMETER` declarations in the non-module sources, **225
are still used and 94 are now declared and never referenced.** The arrays
that needed them moved into the modules, which carry their own `PRIVATE`
copies, so the importer's declaration was left behind with nothing to
size.

Worst offenders, by name, with the count of files where the same name is
still live for comparison:

| name | orphaned in | still live in |
|---|---|---|
| `JSON` | 12 | 108 |
| `NPS` | 12 | **0** |
| `NUMXZ` | 10 | 1 |
| `NTS` | 8 | 4 |
| `NGA`, `NTA` | 7 each | 1 each |
| `NUMX`, `NUMZ` | 6 each | 5 each |
| `NT`, `NUMT`, `NUMD`, `NG` | 4 each | 10, 6, 7, 2 |
| `NGC`, `NTC` | 3 each | 2 each |

Two names are now **entirely dead**: `NPS`, orphaned in all 12 files that
declare it and live in none, and `NUMXZ`, live in only one of eleven.

A separate group predates the conversion. `NTA=54` and `NGA=5` in
`envint.f`, `parmin.f`, `remap.f` and `setups.f` are the *old* NextGen
Allard dimensions, in four files that do not touch the Allard tables at
all -- the current format is `NTA=250, NGA=25` and lives in the four
`al*.f` files. Those four declarations were stale before any of this
work.

The fix is pure subtraction and should be byte-identical: delete a
`PARAMETER` entry wherever the name is unreferenced in that file, and
remove the statement entirely where nothing is left in it. Verify with a
clean build plus the targeted set, as usual.

Detect them with the same method used to find them: for each file, parse
its `PARAMETER` statements and ask whether each name appears in any other
statement of that file. Note that the check must honour fixed-form column
rules and inline comments, for the reasons recorded in issues 22 and 24.

---

## 26. Centralise `JSON` in a parameters module -- but not the table dimensions

**Status:** RESOLVED 2026-10-15 for the importer side. `dimensions_mod.f`
now holds `JSON = 5000` as the single public definition and 108 files take
it by `USE`; no code-level `PARAMETER(JSON=...)` remains outside the
modules. Build clean, 19 targeted cases byte-identical.

**The block-module half is RESOLVED 2026-10-20.** The 36 block modules
dimensioned on `JSON` now `USE DIMENSIONS_MOD` in place of their own
`PRIVATE` copies, so `JSON` is defined once in the whole code. The
Makefile orders them after `dimensions_mod.o` (issue 27). The table
dimensions stay `PRIVATE` in their 12 modules, as ruled below. The
paragraph that follows is the earlier reasoning, kept for the record.

**Previously open, deliberately:** the 36 `PRIVATE` copies inside the block
modules. They cannot clash with `DIMENSIONS_MOD` because `PRIVATE` is not
exported, so leaving them costs only duplication. Removing them means a
module importing another module, which needs generated inter-module
dependencies in the Makefile first -- stage 0 item 3. Ordering was
checked rather than assumed when the importer work landed:
`dimensions_mod.o` compiles at position 10 and the first ordinary object
at 85, so the existing `$(OBJS): $(MODOBJS)` rule already suffices while
no module imports another.

**A fix folded in.** `microdiff_mte.f` had `INTEGER HALFJSON` set to a
hardcoded `5000` and used as `NPT = MIN(NPT,HALFJSON)`. The name says half
of `JSON`, but the value was all of it, so the cap had evidently been
raised to the full array bound without renaming -- and duplicating the
literal meant a future change to `JSON` would silently desynchronise the
cap from the bound it exists to enforce. It now reads `HALFJSON = JSON`.
The name is kept so the change is behaviour-neutral; correcting it is a
loose end. It was the only hardcoded `5000` outside a `PARAMETER` or
module in the tree.

The original scoping follows, with MHP's distinction between input-table
dimensions and the code's own structural dimensions. They need opposite
treatments, which is the point of this entry.

### Do centralise: `JSON`, and anything else like it

`JSON` is the maximum shell count: a property of the code's own arrays,
not of any input file, so a single global value is correct by
construction. It is declared `PARAMETER (JSON=5000)` in **120 files with
no exceptions**, and it is genuinely live -- 108 of those files reference
it in **183 places**, mostly local declarations such as
`DIMENSION HR(JSON)` rather than block members.

A module exporting it replaces 120 identical `PARAMETER` statements with
120 `USE` statements. Mechanically this is the operation already
performed 83 times in stages 1 to 4, with one difference that is not
optional: **each importer must drop its own `PARAMETER (JSON=5000)` as it
gains the `USE`**, because keeping both is a conflict error. That clash
is precisely why the block modules declare their dimension parameters
`PRIVATE`.

**Sequencing matters here.** The 83 block modules each declare `JSON` as
a `PRIVATE` parameter. They can stay exactly as they are, since `PRIVATE`
is not exported and so cannot clash with a parameters module. Switching
them to `USE` the parameters module instead would remove that
duplication, but it would be **the first module importing another module
in this code**, which is the trigger condition for
`F90_CONVERSION_PLAN.md` stage 0 item 3: the Makefile's
`$(OBJS): $(MODOBJS)` rule orders modules against ordinary objects but
not among themselves. So the importer work can be done now; dedupicating
the modules is a separate step that needs generated inter-module
dependencies first.

### Do NOT centralise: the input-table dimensions

These describe the shape of specific data files, and the same name
legitimately carries different values:

| name | values | families |
|---|---|---|
| `NUMT` | 70 / 85 | OPAL95 opacities / Alexander 2006 |
| `NUMX` | 10 / 9 | same two |
| `NUMZ` | 13 / 16 | same two |
| `NUMXZ` | 126 / 143 | same two |
| `NT` | 57 / 197 | surface-pressure tables / OPAL06 EOS |
| `NTA`, `NGA` | 250,25 / 54,5 | current Allard / old NextGen |

A single global module cannot hold `NUMT` twice. The conversion already
resolved this the right way: each table's module declares its own
`PRIVATE` copy, so the two values coexist **by scope**, with no renaming.

An earlier draft of this plan proposed renaming them per family --
`NUMT_OP95` against `NUMT_A06` and so on. **That suggestion is
withdrawn.** Scoping gives the same separation for free, and renaming
table identifiers to work around a scoping problem that no longer exists
would be the worse trade, touching physics-table indexing for no gain.

### Do NOT centralise: per-routine scratch bounds

`NMAX` is 15 in `ratext.f`, 42 in `thdiff.f`, 100 in `ludcmp.f` and 8000
in `bandw.f` and `dadcoeft.f`. It sizes local workspace and is
deliberately per-routine. Centralising it would be actively wrong.

### Order of work

Issue 25 first. Deleting the 94 orphans removes 12 of `JSON`'s 120
declarations before any of them has to be converted, and it is pure
subtraction, so it is the cheaper and safer half.

---

## 27. Inter-module dependencies: scope the work, then do it after stage 5

**Status: RESOLVED 2026-10-20**, by the one-line rule the scoping below
anticipated. Issue 26's block-module half created the first edges, 36
modules depending on `DIMENSIONS_MOD`, and the Makefile now carries

```make
$(filter-out dimensions_mod.o,$(MODOBJS)): dimensions_mod.o
```

beside `$(OBJS): $(MODOBJS)`. Answers to the scoping questions, as
measured:

1. **Edges:** 36, all into one module. A dependency generator is not
   warranted. Build one if a second kind of edge appears, as the Makefile
   comment says.
2. **Tool:** none needed.
3. **Cycles:** not possible with one target.
4. **Kept honest:** a missing rule fails loudly. Seven `JSON` modules sort
   alphabetically ahead of `dimensions_mod.f` (`acdpth`, `atmstruct`,
   `burn`, `deuter`, `difad`, `difad2`, `difad3`), so a serial build
   without the rule stops with "Can't open module file".
5. **`make -j`:** verified with five clean `make -j 16` builds, all
   successful. A serial build now compiles `dimensions_mod.f` first.

Validation: 280 of 281 objects are byte-identical to the build before the
change. The exception is `version.o`, which carries the git hash.

The original scoping follows, added 2026-10-16 at MHP's request. He asked
for this as a task after stage 5, or at minimum an item to scope the
degree of change required.

### What is missing

`Makefile` orders modules against ordinary objects:

```make
$(OBJS): $(MODOBJS)
```

That guarantees every module compiles before any object that `USE`s one,
which is sufficient *only while no module imports another*. It does not
order the modules among themselves. The moment one module `USE`s another,
the build depends on `MODOBJS` happening to be in a workable order, which
the `wildcard` expansion does not promise -- it is alphabetical. Stage 0
item 3 recorded this and deferred it for exactly this reason.

### Why it is not yet a problem

No module imports another today. That is not an accident: the 36 block
modules dimensioned on `JSON` each declare their own `PRIVATE` copy
rather than importing `DIMENSIONS_MOD`, which is what kept issue 26's
importer work clear of this. `dimensions_mod.o` compiles at position 10
and the first ordinary object at 85, so the current rule covers it.

### What would trigger it

- Removing the 36 duplicate `PRIVATE JSON` copies in favour of
  `USE DIMENSIONS_MOD` (the open half of issue 26).
- Any module that needs a type, parameter or interface from another.
- Stage 5 may create pressure for this: moving to `IMPLICIT NONE` with
  explicit declarations tends to surface shared derived types and
  parameters that naturally live in one module and are used by others.

### Scoping questions to answer before committing to an approach

1. **How many edges would there actually be?** Today zero. After issue
   26's second half it would be 36 modules depending on one. That single
   case is trivially orderable by hand, so measure whether a generated
   solution is warranted at all or whether a one-line explicit
   prerequisite suffices:
   `$(filter-out dimensions_mod.o,$(MODOBJS)): dimensions_mod.o`
2. **Which tool?** `makedepf90` is the conventional answer but is a new
   build dependency for every developer and may not be packaged on the
   target systems. A short script generating a `.d` fragment from `USE`
   statements is maybe 40 lines and has no dependency, and the parsing it
   needs -- joined continuations, inline comments, column rules -- is
   already implemented in `shadow_census.py`.
3. **Does it need to handle cycles?** Fortran forbids circular `USE`, so
   a topological sort either succeeds or reveals a real error worth
   reporting.
4. **How is it kept honest?** A generated dependency file that is stale
   is worse than none. Either regenerate on every build, which costs a
   parse of 280 files, or make it a checked-in artifact with a test that
   fails when it disagrees with the sources. The second fits this
   project's habits better, given the test suite already guards other
   invariants.
5. **Does `make -j` still work?** It does today, verified in stage 0
   against the `$(OBJS): $(MODOBJS)` rule. Any replacement must be
   re-verified the same way, since an ordering bug shows up only
   intermittently under parallel builds and is easy to mistake for
   something else.

### Recommended sequencing

Scope it now, in this entry; implement after stage 5. Doing it earlier
builds machinery with no edges to exercise it, and stage 5 is the change
most likely to determine what the dependency graph actually needs to look
like.

---

## 28. The OPAL06 EOS table-grid tolerance is a relic, and will trigger

**Status:** open, flagged by MHP on 2026-10-16 while issue 23 was being
applied. Held back deliberately from that change.

`esac06.f` declares the hydrogen-abundance coordinates of the OPAL 2006
EOS tables:

```fortran
      data (xa(i),i=1,mx)/0.0,0.2,0.4,0.6,0.8/
```

and tests membership against them with a fixed tolerance:

```fortran
      if(xh .le. xa(imd)+1.D-7) then
      if((xh .le. xa(2)+1.D-7) .or. (xh .ge. xa(mx-2)-1.D-7)) mf2=mh
```

These four literals are the **only lossy ones left in the tree** after
issue 23. They were excluded from it because `0.2`, `0.4`, `0.6` and
`0.8` are table *coordinates* rather than physical constants, and the
precision error on them is about 1.5e-8 against a comparison tolerance
of 1.0e-7 -- the same order of magnitude. Giving them `D0` could
therefore flip a table-lookup branch rather than merely shifting a value
in its last digits.

**MHP's assessment:** a tolerance of this kind is a relic of older
compilers, where round-off could be severe enough to need that much
slack. The problem is that 1.0e-7 is also large enough to be crossed by
ordinary composition changes during evolution, so the branch it guards
will trigger on real physics rather than only on round-off. That makes
the tolerance, not the literals, the thing to examine.

### What to decide

1. Is the intended grid exactly 0.2, 0.4, 0.6, 0.8, or whatever the
   OPAL 2006 table files actually tabulate? This is a question about the
   data, not the code.
2. Should the tolerance scale with the grid spacing, or be tightened to
   something near the double-precision round-off it was meant to absorb?
3. Once the tolerance is settled, the four literals follow: with a
   tolerance well clear of 1e-8 they can safely take `D0` like the other
   413.

Doing it in that order matters. Fixing the literals first would change
branch decisions under a tolerance nobody has reviewed, and the effect
would be indistinguishable from the rest of issue 23 in the same diff.

---

## 29. No procedure has an explicit interface, so argument errors are not checked

**Status:** open, added 2026-10-16 at MHP's request. A zero-cost partial
measure is available immediately; the full fix belongs after stage 5.
**Stage 5 finished on 2026-10-20, so the full fix is now unblocked.**
After stage 5, `ifx` reports 531 `#8889` warnings, down from the 537
quoted below. The partial measure has not been applied.

### The gap

Every procedure in YREC is an F77 external subprogram, so no call site
has an explicit interface and **the compiler cannot check argument count,
type, rank or shape at any of them**. `ifort -warn all` reports this as
537 instances of

```
warning #8889: Explicit interface or EXTERNAL declaration is required.
```

across **202 distinct procedures**. The heaviest are `OSPLIN` (37 call
sites), `EXPAND_VALUE` (23), `KSPLINT` and `KSPLINE` (20 each), `INTERP`
(15), `SOLID` and `EQSTAT` (13 each).

This is not hypothetical. It is exactly the gap that let
`CALL MDOT(BL,...)` pass 24 arguments to a 23-argument subroutine
undetected until it was found by hand in October 2026. Nothing in the
build would have objected.

### A measure available today at no cost

`Makefile` passes **`-nogen-interfaces`** to both the ifort and ifx
branches, which explicitly switches off the check that would catch this.
Removing it and compiling twice -- once to generate interface modules,
once to check calls against them -- finds real problems with no source
change at all:

- **0 argument-count mismatches.** The code is currently clean of the
  MDOT class, which is worth knowing.
- **8 argument-shape mismatches**, all pre-existing:

| site | actual | dummy |
|---|---|---|
| `calcad.f:225` | `BJ`, `FPLJ`, `FTLJ`, declared `(1)` | `ENVINT`'s `B`, `FPL`, `FTL` |
| `calcad.f:340`, `:355` | `RCZ`, `ANS`, declared `(1)` | |
| `starin.f:991` | `ENVR(JSON)`, the whole array | `GETTAU`'s scalar `RBCZ` |

Each is the old F77 sequence-association idiom: declare `X(1)` and let
the callee treat it as longer, or pass an array where a scalar is
expected and have the callee use its first element. These work with
contiguous storage and are not conforming. They are worth a reading
rather than an automatic fix -- the question in each case is whether the
callee ever writes past the first element.

**Recommended now:** drop `-nogen-interfaces`, keep the two-pass check as
something that can be run deliberately, and review those 8. That buys
most of the detection value before any restructuring.

### The two full solutions

**Interface blocks.** Declare each procedure's signature in an
`INTERFACE` block, gathered in a module that callers `USE`. The
definitions stay exactly where they are.

- Nothing is restructured; the 190 single-procedure files keep their
  shape.
- It can be adopted one procedure at a time, worst-first.
- Changing a procedure's *body* does not recompile its callers.
- **The signature is duplicated, and that is the problem.** An interface
  block is a second, independent statement of the truth. Edit the
  subroutine and forget the block and the compiler now believes the stale
  one -- the same silent mismatch as today, but with the compiler
  confidently agreeing. For 202 procedures that is a large hand-kept
  artifact, and it would need its own guard test to stay honest.

**Module procedures.** Move each procedure inside a module
(`MODULE X_MOD / CONTAINS / SUBROUTINE X ... / END MODULE`) and have
callers `USE` it.

- **The interface cannot drift, because it is the definition.** Nothing
  to duplicate, nothing to maintain, no guard needed.
- Every call is checked automatically, and `PUBLIC`/`PRIVATE` becomes
  available.
- It restructures all 197 source files holding procedures.
- It creates a web of inter-module dependencies, which makes issue 27 a
  prerequisite at full scale rather than the 36-modules-to-one case it is
  today.
- Changing a procedure's interface recompiles its users. That is correct
  but slower.

### Complications either approach must handle

- **One alternate return.** `subroutine esac06 (xh,t6,r,iorder,irad,*)`,
  called as `CALL ESAC06(...,*999)` from `calcad.f` and `oeqos06.f`.
  Declarable in an interface body and legal in a module procedure;
  obsolescent in both.
- **Four dummy procedure arguments.** `DERIV` in `bsstep.f` and
  `mmid.f`, `QATM` and `QENV` in `envint.f`, `sort_shell` in
  `alfilein.f`. Checking calls *through* a dummy procedure needs an
  interface for the dummy itself, not just for the actual, so these need
  an interface block or a `PROCEDURE()` declaration either way. Note that
  `QATM`/`QENV` are the callbacks constrained by issue 7.
- **Seven multi-procedure files**, against 190 holding one.

### Recommendation

Module procedures, because the duplication inherent in interface blocks
defeats the purpose of the exercise. But sequenced: after stage 5, whose
explicit declarations both approaches need anyway, and after issue 27,
which module procedures would otherwise force at full scale. Use
interface blocks only for the four dummy procedure arguments, where
nothing else will do.

Meanwhile drop `-nogen-interfaces`, since it costs nothing and restores
the only check that currently exists.

## 30. The harness silently passes `NaN`, and a `NaN` reference accepts anything

**Status: RESOLVED 2026-10-20**, as its own change, per the fix below.
`filevals_differ` now treats a non-finite value on either side as a
difference before the tolerance test, `NaN` against `NaN` included.

Checked by comparing every reference file against itself: exactly one
now fails, `Test_m0p3feh+0p0GS98_yaleeos_ZAMS.store`, the issue 31 file
and the only one with non-finite values. Run through pytest, that case
now fails on exactly its 228 `NaN` lines, and its `.short` and `.track`
still pass. Synthetic checks confirm the cases that should still pass,
finite values within tolerance and equal text, do pass. Expect a full
suite run to show this case failing until issue 31 is fixed; that is the
intended outcome. `REBASELINE_PROTOCOL.md` is updated to match.

The original entry follows, found 2026-10-16 while measuring the issue 23
rebaseline. Not caused by issue 23 -- it is pre-existing, and it is the
reason issue 31 went unnoticed.

`filevals_differ` compares a value by

```python
diff = abs(out_vals[i] - val)
if abs(diff/val) > float_tol:
```

If either side is `NaN`, `diff` is `NaN`, and **every comparison against
`NaN` is false**, so `NaN > float_tol` does not fire. Two consequences:

- An output that has gone `NaN` where the reference is finite **passes**.
  A run that produced garbage is indistinguishable from a run that
  reproduced the reference exactly.
- Where the *reference* holds `NaN`, that position accepts **any** output
  value whatsoever, finite or not, forever.

The same applies to `Inf`. The integer branch is unaffected.

This is the worst possible failure direction for a regression harness: it
is silent, and it is silent precisely on the outputs that most need to
fail. 298 cases have been passing with 228 `NaN` values among them.

**Fix:** reject non-finite values explicitly, before the tolerance test,
on both sides -- `math.isfinite` on each numeric token, a difference if
either side fails. Do this as its own change, and expect it to turn issue
31 into a failing case, which is the correct outcome; it should not be
folded into a rebaseline, or the `NaN` is simply re-recorded as the new
reference.

**Interaction with the issue 23 rebaseline:** the rebaseline preserves
the status quo here rather than worsening it. The `NaN` values are
identical in the old reference and the new output (`nan -> nan` at every
one of the 228), so the new references record exactly what the old ones
already did. No new `NaN` was introduced and none was concealed.


## 31. `GAM1` is `NaN` over a band of shells in the Yale EOS path

**Status:** open, found 2026-10-16. Pre-existing, and **unrelated to the
issue 23 literal fix** -- the values are bit-identical before and after.
**Since 2026-10-20 its case fails the suite**, because the harness now
rejects `NaN` (issue 30). That failure is intended, and stays until the
`NaN` is fixed. Do not rebaseline it away.

In `testsuite/Test_m0p3feh+0p0GS98_yaleeos_ZAMS` (0.3 Msun, ZAMS, Yale
EOS), the `.store` output carries `GAM1 = NaN` on **228 of its 1202
shell records**. It is the only case in the suite that produces a
non-finite value anywhere.

The affected records are a contiguous band, shells **471-611**, in models
99 and 295. On those lines the whole EOS-derived group is degenerate, not
just `GAM1`:

| column | value on the affected shells |
|---|---|
| `DEL` | `0.0000E+00` |
| `DELAD` | `0.0000E+00` |
| `V_CONV` | `0.0000E+00` |
| `GAM1` | `NaN` |
| `HII`, `HEII`, `HEIII` | `0.00000` |
| `BETA` | `1.00000` |

`DELAD = 0` and zero ionization fractions with `BETA = 1` are not
physical for interior shells; they look like an unset or zeroed EOS
return, with `GAM1` then falling out of a `0/0`. So the thing to chase is
not `GAM1`'s own arithmetic but why the Yale EOS returns an empty result
over that band -- most likely the shells fall outside its table coverage
and the out-of-range path leaves the output structure untouched instead
of failing.

The 9.0 Msun Yale EOS case (`Test_m9p0feh+0p0GS98_yaleeos_TAHB`) is
clean, so this is not the whole EOS path, only part of its domain.

Depends on issue 30: until the harness rejects non-finite values, this
case will keep passing and any fix here cannot be verified by the suite.


## 32. The test references are not under version control

**Status:** open, found 2026-10-16 while preparing the issue 23 rebaseline.
Process issue rather than a code defect, but it governs how every future
rebaseline can be reviewed. Issue 18 recorded the same problem earlier and
is superseded by this entry. Until it is decided, `REBASELINE_PROTOCOL.md`
step 3 requires a checksummed, test-restored backup before any rebaseline.

The 903 reference files under `testsuite/standard/` and
`examples/*/standard/` are **untracked**, and not by an ignore rule --
`.gitignore` says nothing about them, they were simply never added. They
total **494 MB**, which is presumably why.

The consequence is that the artifact defining "correct" for all 298 cases
exists only in one working directory:

- A rebaseline leaves **no diff to review**. The only record that the
  references moved, by how much, and why, is the prose in a commit
  message and in this file.
- There is no way to check out the code at an earlier commit together
  with the references that matched it, so an old revision cannot be
  re-validated.
- A lost or overwritten reference tree cannot be recovered from the
  repository. For this rebaseline the previous tree is preserved as a
  204 MB tarball under `claude_work/`, with checksums verified against a
  test restore -- but that is an ad-hoc safeguard, not a repeatable one.

**Options, in rough order of cost:** store the references with Git LFS;
keep them in a separate repository pinned by commit; or stop storing full
outputs and commit a reduced digest per case (selected columns at
selected models, or a checksum per output) with the full outputs
regenerated on demand. The last is the smallest in bytes but the largest
change to the harness.

Not resolved here, and not a prerequisite for the issue 23 rebaseline --
recorded so that the absence of a reviewable diff for that rebaseline is
a known condition rather than a surprise.



## 33. Crash-terminated cases: the run extent *is* the measurement

**Status:** documented 2026-10-16, not a defect. Recorded because the
first reading of it was wrong, and because it governs how a rebaseline
must be judged.

For low-mass stars in this suite, **helium ignition is by definition an
event that crashes the code** (MHP, 2026-10-16). A case such as
`testsuite/Test_m1p0feh+0p0GS98_base_HeIgnite` is not expected to reach
its nominal `NMODLS(1) = 20000`; the information it carries is **how far
the run gets before the crash**. Its reference is a record of that
extent, and the case passing means the extent has not moved.

Observable signature, so this is not mistaken for a regression again:

- The run stops at model 9399 of 20000 with the solution diverging --
  the last iterations show `DEL-L/L` of 7e2 against a 3e-4 tolerance and
  corrections of order unity.
- No `STOP` or non-convergence record appears in the 350,000 lines of
  `.short`. If the program announces the termination it does so on
  stdout, which the harness captures and discards unless the case fails.
- It writes **no `.store`**, despite `LSTORE`, `LSTMOD`, `LSTPCH`,
  `LSTATM`, `LSTENV`, `LSTPHYS` and `LSTROT` all being `.TRUE.` -- the
  crash precedes any store write. The `.store` in the shared output
  directory is a zero-byte relic dated 2026-09-28 whose mtime does not
  move when the case runs.

**Do not "fix" this by failing cases with empty outputs.** An output that
a crash-terminated case never reaches is correctly absent, and such a
check would fail this case for behaving as intended.

### What this means for a rebaseline

Because the extent is the measurement, the number to check before
replacing any reference is **how far each run got**, not only how far
individual values moved. For the issue 23 rebaseline, measured over the
289 cases with a `.track` pair:

| | |
|---|---|
| final model number identical | 284 of 298 (95.3%) |
| final age within 0.1% | 289 of 298 |
| final age shorter by more than 0.5% | 5 |
| final age longer by more than 0.5% | 1 |

`Test_m1p0feh+0p0GS98_base_HeIgnite` is among the unchanged: it crashes
at model 9399 before and after, so its information content is preserved
exactly.

Of the five that shorten, four are small and keep their stopping
criterion: `Test_3Msolar_..._RGp2diffrotI0` (-1.7% in age),
`ZAHB_m1p6feh+0p0_diffcal_TAHB` (-1.5%, and already failing to reach
TAHB in the old reference -- `Y_cen` 4.98e-04 then, 5.00e-04 now, both
above the 1e-4 threshold), `ZAHB_m1p7feh+0p0_diffcal_TAHB` (-1.2%, still
reaching TAHB at `Y_cen` 7.2e-05), and `m0300gs98z060000_Dbl` (-1.1%).
Fewer models at the same endpoint means larger timesteps, not lost
evolution. The fifth is issue 34.

The one that lengthens is `ZAHB_m1p9feh+0p0_diffcal_TAHB`, model 2130 ->
2801 (+31%) and age +7.4%. Like `m1p6`, it fails the 1e-4 TAHB threshold
on both sides (`Y_cen` 3.87e-04 then, 4.06e-04 now), so it is in the
same already-not-terminating class; it now gets further before stopping.
These two are worth a separate look at some point -- a ZAHB-to-TAHB case
that never reaches TAHB is not testing what its name says -- but neither
is a change introduced here.

### `Test_m0p03feh+0p0GS98_allard_15Gyr` (added 2026-10-28)

The 0.03 Msun brown dwarf has never reached its 15 Gyr end age in any
configuration, and it stays in the suite as a crash-extent case (MHP,
2026-10-28). Every run stops as the centre turns degenerate, after the
timestep collapses to about 100 yr per model with the luminosity
corrections jumping between widely separated shells. The run then
diverges (TPGRAD, exit 144) or leaves the OPAL95 opacity table (bare
STOP, exit 0, issue 38).

| 0.03 Msun run | stops at | log Tc | log rho_c | eta_c |
|---|---|---|---|---|
| old code, this deck (old reference) | 65.6 Myr | 6.09 | 1.96 | 4.14 |
| old code, DBL-to-ZAMS, tuned nml2 | 37.6 Myr | 6.07 | 1.77 | 3.11 |
| new code, this deck, HTOLER x10, larger triangle | 10.4 Myr | 5.85 | 1.07 | 1.42 |

With the corrected deuterium rate and the new pre-MS models the centre
reaches mild degeneracy at a cooler temperature, and the run stops near
eta_c = 1.1-1.4 instead of 3-4. Starting from the start model instead
of the DBL model, relaxing HTOLER x10 or x30, halving the timestep, a
smaller or larger envelope triangle, and a deeper fitting point all stop
at 8.2-10.4 Myr; none of the convergence ingredients moves it. The cause
is likely an EOS or opacity boundary that the centre crosses near
eta_c = 1, not yet identified. The next rebaseline will move this
case's recorded extent from 65.6 Myr to about 10 Myr; that move is
expected.

The DBL-to-ZAMS 0.03 Msun case was removed from the suite instead.

### `ZAHB_m1p9feh+0p0_diffcal_TAHB` (added 2026-10-28)

**Resolved later on 2026-10-28.** With the diffusion-calibrated starting
composition restored after the solar recalibration (X 0.708504,
Z 0.018797, base alpha), this case reaches the TAHB (Yc 9.5e-5 at
289.6 Myr) with the default `FCORR0` 0.6 and is no longer a crash-extent
case. The `ALEX06TAB` question below is still open.

Before that, this ZAHB-to-TAHB case had never reached its `END_YCEN` of
1e-4, and it was kept in the suite as a crash-extent case. Every run
stops during a core breathing pulse near central He exhaustion, while
the growing convective core is mixing fresh helium in and Yc is rising.

| 1.9 Msun diffcal run | last model | age | Yc | stop |
|---|---|---|---|---|
| old code (reference) | 2801 | 329.5 Myr | 4.1e-4 | core diverged (DEL-L/L 71, negative beta at log T 9.27) |
| new code, `FCORR0` 0.6 | 2200 | 315.3 Myr | 8.7e-4 | `ILLEGAL COMPOSITION (X,Z) = 0.00 0.98 IN ALEX06` |
| new code, `FCORR0` 0.3 | 2200 | 315.3 Myr | 8.7e-4 | same |

The two new-code runs agree to five digits up to the stop, so the
Newton damping that rescued the 1.1, 1.3, 1.7 diffcal and 1.8 Msun
decks has no effect here. The stop is a bare `STOP` in `ALEX06TAB`
(exit 0, issue 38): the molecular opacity table, which only applies near
the surface, was asked for the C/O core composition. How core
composition reaches the low-temperature opacity path -- most likely a
trial model that went wrong mid-iteration -- is not yet known; start
from `GETALEX06` and its callers. A guard there might also help the
other ZAHB decks that stop at a breathing pulse. The next rebaseline
will move this case's recorded extent from 329.5 Myr to about 315 Myr;
that move is expected.


## 34. `ZAHB_m1p0feh+0p0_TAHB` no longer reaches TAHB

**Status:** open, found 2026-10-16. **Needs MHP's judgement before this
case is rebaselined.** It is the one case where the issue 23 literal fix
changed whether the run accomplishes what it is for.

`examples/run_from_zahb_to_tahb/ZAHB_m1p0feh+0p0_TAHB.nml1` sets

```
 NMODLS(3)   = 1000000
 END_YCEN(3) = 0.0001      ! stop at TAHB
```

| | old reference | after the literal fix |
|---|---|---|
| final model | 2455 | **1474** (-40%) |
| final age | 0.247383 Gyr | **0.214214 Gyr** (-13.4%) |
| final `Y_cen` | 9.51e-05 | **3.33e-04** |

The old run stopped because it reached TAHB: `Y_cen` fell below the 1e-4
threshold. The new run ends with `Y_cen` still at 3.3e-04, more than
three times the threshold, at model 1474 out of a million. **It satisfies
neither stopping condition** -- it terminates early with helium left in
the core, 0.033 Gyr of core-helium burning short of the endpoint.

Note this is *not* the crash-by-design class of issue 33. A ZAHB-to-TAHB
run is meant to complete, and this one did complete before.

### What is and is not known

The perturbation that caused it is tiny. Issue 23 gave 413 literals a `D`
exponent; the resulting changes are at the 1e-7 level across the suite
(90th percentile relative change 3.6e-07), and 281 of 289 cases end
within 0.1% of the same age (284 of 298 end at the identical model
number). So the likely reading is that this case sits
on a convergence cliff and any perturbation of that size moves it, rather
than that the more accurate constants are themselves wrong. That is a
hypothesis, not a finding.

It is worth knowing which, because the two have opposite implications: a
fragile case should be made robust (or its fragility recorded), whereas a
systematic failure in core-helium burning triggered by corrected nuclear
data would matter well beyond this case.

**Cheap discriminating test:** rerun this case against the pre-fix binary
with a slightly perturbed timestep control. If an unrelated perturbation
of comparable size also truncates the run, the case is fragile and issue
23 merely tripped it. The six sibling ZAHB cases at other masses, which
all still reach TAHB, are evidence for fragility rather than a systematic
effect.

**Handling in the rebaseline:** this case's three reference files are
**held back**. Installing them would replace a reference that reaches
TAHB with one that stops in mid-helium-burning, and the suite would then
certify the shorter run as correct. The other 297 cases are rebaselined.


## 35. Three cases read a start model that a later case overwrites

**Status:** open, found 2026-10-16 while committing the issue 23
rebaseline. Pre-existing. Handled for this rebaseline; the underlying
ordering hazard is not fixed. Since 2026-10-20 the rebaseline procedure
guards against it. `REBASELINE_PROTOCOL.md` requires two full passes and
a check that `startmodels/` has settled. `rebaseline.py` refuses to
install from any case that did not exit cleanly, which is the exit-status
check called for below.

Of the 298 cases, **294 write their `FLAST` into `{YREC_OUTPUT}`** and
only **4 write into `{YREC_START}`**, where 189 cases look for their
`FFIRST` start models. For three of those four, the case that *reads* the
file runs **before** the case that *writes* it:

| start model | written by | read by | order |
|---|---|---|---|
| `Test_m1p0feh+0p0GS98_base_TAMS.last` | `..._base_TAMS` (#22) | `..._base_HeIgnite` (#21) | consumer first |
| `Test_m9p0feh+0p0GS98_base_TAMS.last` | `..._base_TAMS` (#36) | `..._base_TAHB` (#35) | consumer first |
| `Test_m9p0feh+0p0GS98_yaleeos_TAMS.last` | `..._yaleeos_TAMS` (#38) | `..._yaleeos_TAHB` (#37) | consumer first |
| `tams/Test_m3p0feh+0p0GS98_std25_TAMS.last` | `..._std25_TAMS` (#33) | `..._std25_ZAHB` (#34) | producer first, fine |

So each of those three consumers starts from a model left behind by the
**previous** run of the suite -- which, across a change of physics or
compiler, means the previous *binary*. The dependency is invisible: both
cases pass, and nothing in the output records which generation of start
model was used.

These three `.last` files are tracked in git, so the coupling also shows
up as three modified files in `git status` after every full run, which is
how it was noticed.

### Why it mattered here

The first pass of the issue 23 rebaseline installed references for all
298 cases from one suite run. For these three, that run had read a
**pre-fix** start model (the producer had not yet re-run), while the
`.last` files left on disk afterwards were post-fix. The next full run
would therefore read a different start model and not reproduce the
reference just installed.

Re-running those three cases against the now-current post-fix start
models and reinstalling their references fixed two of them: a second
re-run confirmed `..._base_HeIgnite` and `..._base_TAHB` both pass, and
the producers rewrote their `.last` files byte-identically, so the fixed
point holds as expected. The third, `..._yaleeos_TAHB`, aborts on the new
start model and is issue 36.

Note also that the harness asserts `proc.returncode == 0` **before** it
globs the outputs, so a case that aborts fails without any comparison --
and the partial outputs it left behind are still sitting in the shared
output directory. Reinstalling references from such a run installs the
output of a crash. That happened here for `..._yaleeos_TAHB` and was
reverted from the backup. A rebaseline must check the run's exit status,
not only the age of its output files.

**Note for any future rebaseline:** a single suite run is not sufficient.
Either run the suite twice and rebaseline from the second pass, or
re-run these three cases afterwards as was done here. Prefer, when
someone has the time, pointing these four cases at `{YREC_OUTPUT}` like
the other 294 and committing the start models they need as fixed inputs,
so the suite stops mutating its own inputs.


## 36. `Test_m9p0feh+0p0GS98_yaleeos_TAHB` aborts in `TPGRAD` on the new start model

**Status:** open, found 2026-10-16 verifying the issue 23 rebaseline.
The misleading diagnostic in the abort branch is fixed (`5a32817`; see
the end of this entry). The cause of the `NaN` is not.
**Rebaselined 2026-10-20 at MHP's direction:** the references are now the
post-fix run that aborts at model 4422 (copied from the 2026-10-16 16:54
verify run, md5 checked). The pre-fix references remain in
`reference_baseline_pre_issue23/`. The cause of the `NaN` is still open.

**The case still fails the harness.** `test_all.py` asserts a zero exit
status before it compares outputs, and `STOP 912` exits with status 144,
so this case fails as "Program terminated abnormally" whatever its
references hold. Until the harness can accept an expected abort, a full
suite pass will show this one failure.

With the post-fix start model (issue 35) this case terminates abnormally
at model **4422** of a reference 4646 -- about 95% of the way -- with exit
status 144, i.e. `STOP 912` from `tpgrad.f:146`:

```
***WARNING***
TPGRAD TRIED TO TAKE SQUARE ROOT OF NEGATIVE NUMBER - ASSUMED ADIABATIC CONVECTION
 DELDEL          NaN QDT    1.302E+01 DISC.          NaN
```

The warning never fires in a run from the pre-fix start model -- zero
occurrences across the full 298-case pass -- and fires in both runs from
the post-fix one.

### How far the run gets

Measured 2026-10-20 from the two `.track` files. The series is
`..._yaleeos_TAMS` (deuterium birthline to TAMS, unchanged by issue 23;
ends at model 828, 29.85 Myr, `X_cen` 7.8e-5) followed by this case,
which should run to `END_YCEN` = 1e-4.

| | reference (pre-fix start model) | current (post-fix start model) |
|---|---|---|
| end | model 4646, normal stop | model 4422, `STOP 912` in `TPGRAD` |
| age at end | 33.494 Myr | 33.315 Myr |
| `Y_cen` at end | 1.4e-5 (TAHB reached) | 0.0727 |
| log Teff, log L at end | 3.576, 4.178 (red supergiant) | 3.784, 4.220 (still moving redward) |
| fraction of core He burning | all | 95% of its duration, 93% of the helium |

The run tracks the reference closely right up to the abort, so this is
an abrupt failure, not a drift:

| `Y_cen` | reference: model, age, log Teff | current: model, age, log Teff |
|---|---|---|
| 0.9 | 1893, 30.653 Myr, 3.576 | 1897, 30.652 Myr, 3.576 |
| 0.5 | 3521, 32.403 Myr, 3.977 | 3555, 32.433 Myr, 3.975 |
| 0.1 | 4347, 33.231 Myr, 3.845 | 4374, 33.257 Myr, 3.840 |
| 0.0727 | 4396, 33.289 Myr, 3.789 | 4422, 33.315 Myr, 3.784 (abort) |

The current run trails by about 26 models and 0.03 Myr, with Teff and L
agreeing to a few thousandths in the log. `DELDEL` goes `NaN` during the
redward crossing late in core helium burning, a region the reference
passed through cleanly. That points to a fragile region that a small
change in the start model happens to hit, rather than to a gross physics
error. Next step: find the first shell where `DELDEL` is `NaN` in model
4422, starting with the spot recomputation noted below.

### The literal fix is not the cause

`tpgrad.f` is one of the 15 files issue 23 touched, which looks damning,
but the single changed line is

```fortran
      IF(A3.GT.1.0D+3) V = A3**(-CC13)
```

at line **153**, and the abort is at line **146**, inside the `ELSE` of
`IF(TEST.GT.0.0D0)`. On the failing path the changed line is never
reached. The arithmetic the fix altered plays no part.

### What actually happens

`DELDEL` arrives as `NaN`, so `TEST = DELDEL*G*(-QDT)/PRESHT` is `NaN`,
and `IF(TEST.GT.0.0D0)` is false for `NaN` -- the same property of `NaN`
comparisons behind issue 30. Control falls into the diagnostic branch.
The real question is upstream: what makes `DELDEL` `NaN` in a 9 Msun
Yale-EOS model at that point. Note `DELDEL` is recomputed just above for
spotted models (`IF(SPOTF .NE. 0.00)`), which is worth checking first.

### A separate defect in that branch

The branch does not do what it says. Its comment and message read

```fortran
C ODD CONVERGENCE PROBLEM; WRITE DIAGNOSTIC AND CONTINUE.
         WRITE(*,201)DELDEL,QDT,TEST
 201     FORMAT('***WARNING***'/'TPGRAD TRIED TO TAKE SQUARE ROOT',
     *          ' OF NEGATIVE NUMBER - ASSUMED ADIABATIC CONVECTION'/
```

and it then does the opposite:

```fortran
          STOP 912
C         GOTO 15
      ENDIF
```

The commented-out `GOTO 15` is the continue path the comment describes.
So a hard stop, evidently left in during debugging, sat where the code
announced it would assume adiabatic convection and carry on.

**Resolved 2026-10-20 by MHP's ruling: the stop is correct.** A square
root of a negative number here is a pathological failure in the cubic
solver and should end the run. The comment now reads `PATHOLOGICAL
FAILURE IN THE CUBIC SOLVER.` and the message ends `- RUN ENDED`; the
`STOP 912` stays. This changes only the diagnostic text, so no
validation run was needed.

Worth checking whether other suite cases are one perturbation away from
the same stop.


## 37. Three OPAL06 EOS `COMMON` blocks were never converted

**Status: RESOLVED 2026-10-20.** The three blocks are now
`AEOS06_MOD`, `EEEOS06_MOD` and `EOS06MISC_MOD`, and the code contains
no `COMMON` statement at all. The conversion followed the stage 3 and 4
pattern: a blanket `USE` in each of the 9 scoping units that declared a
block, each member's type statement removed from those units, and the
dimension parameters `PRIVATE` in each module. The four `DATA`
initializers in `esac06.f` (`xa`, `index`, `nta`, `nra`) moved into the
modules with their value lists copied verbatim. Their implied-DO lists
each covered the whole array, so they became whole-array `DATA`.

Validation: the object-identity check does not apply here, since module
variables get different symbol names from `COMMON` storage. Instead,
six cases using the OPAL06 EOS were run with the converted binary in a
separate output directory: `m0p3` base and spot25 ZAMS, `m1p0` spot25
ZAMS, `m0p7` GN93 TAHB, `m0p3` base TAMS and `m1p0` dif TAMS. All six
exit cleanly. Every `.store` and `.track` is byte-identical to its
reference, and every `.short` is identical once the echoed output path
and its blank padding are normalised. A clean `make -j 16` build
succeeds, with the same 19 warnings as before.

The original entry follows.

`F90_CONVERSION_PLAN.md` records stages 3 and 4 as leaving "no `COMMON`
blocks". That is not quite right. Three blocks of the OPAL 2006 equation
of state are still `COMMON`, with 19 declarations across 8 files:

| block | declarations | files | members |
|---|---|---|---|
| `EOS06MISC` | 9 | `calcad.f`, `eqbound06.f`, `esac06.f` (2), `oeqos06.f`, `radsub06.f`, `readcoeos06.f`, `rhoofp06.f`, `t6rinteos06.f` | `esact, eos(mv), q(4), h(4), xxh, l1-l4, k1-k4, ip, iq, zz(mx), iri(10), index(10), nta(nr), nra(nt)` |
| `AEOS06` | 6 | `eqbound06.f`, `esac06.f` (2), `readcoeos06.f`, `rhoofp06.f`, `t6rinteos06.f` | `xz(mx,mv,nt,nr), t6list(nr,nt), rho(nr), t6a(nt), esk(nt,nr), esk2(nt,nr), dfsx(mx), dfs(nt), dfsr(nr), midx, mf, xa(mx)` |
| `EEEOS06` | 4 | `esac06.f` (2), `readcoeos06.f`, `t6rinteos06.f` | `epl(mx,nt,nr), xx(mx)` |

The numbers bear this out. The original-tasks summary says 153 blocks
became 86, and 83 became modules, so exactly 3 were left. These three are
listed under the OPAL 2006 EOS family in issue 10 and in the plan's
stage 3 and 4 text, so they were meant to be converted. They are the only
blocks written in lower case (`common/aeos06/`), which is the likely
reason the conversion's census missed them.

**They are a clean candidate for conversion.** Each block is declared
with identical text in every file that holds it, so the blanket-`USE`
reasoning of stages 3 and 4 applies unchanged. The member types also
agree everywhere. `l1`-`l4` in `EOS06MISC` start with L, but every
declaring file types them as integers: `calcad.f`, the one file with an
`LOGICAL*4(L)` rule, declares them `Integer*4` explicitly, and stage 5
typed them `INTEGER` in the others. They are table data in the issue 10
sense, so they keep the per-module `PRIVATE` dimension parameters
(`mx`, `mv`, `nr`, `nt`), and `DIMENSIONS_MOD` stays out of it.

Their presence is harmless today, and `IMPLICIT NONE` already holds in
every unit that declares them. Converting them would make the plan's
claim true, and would close the last route by which a layout mismatch
could slip in silently.


---

## 38. A bare `STOP` ends a failed run with exit status 0

**Status:** open, found 2026-10-27.

`GETOPAL95` stops the run when log T leaves the OPAL95 table:

```fortran
      IF(TL.LT.TGR(1) .OR. TL.GT.TGR(NUMT))THEN
         WRITE(*,5)TL
 5       FORMAT(' LOG T OF',F11.6,'OUT OF OPAL 95 TABLE RANGE')
         STOP
      ENDIF
```

A bare `STOP` exits with status 0, so the harness sees a clean exit.
Its "Program terminated abnormally" check never fires, and the case
fails only on "Output differs", which looks the same as an intended
change. `rebaseline.py` would install its outputs, and an install
script that copies the `.first` would install a model from partway
through the run.

It happened on 2026-10-27 in
`examples/run_from_seed_to_start/m3000gs98z040000_prems`, after the
deuterium rate fix in `788f2b7`. The run diverged on its second model
(log T = 11.8), stopped after 1 of its 5 models, and exited 0. Its
`.first` was installed in `startmodels/start/` before the short run
was noticed, and the Z = 0.06 deck, which reads it, built on it. Both
were restored from git.

29 source files contain a bare `STOP`. Some are normal ends of a run;
the rest are error exits like this one. The fix is to give the error
exits a nonzero code (`STOP 1`, or a distinct code per site, as
`TPGRAD`'s `STOP 912` already does), after sorting the 29 into the two
kinds. Until then, a case that writes fewer models than its reference
is worth checking by hand, whatever its exit status.

---

## 39. Above about 2.4 Msun the start models are too compact to resolve the deuterium birthline

**Status:** accepted by MHP, 2026-10-27 (option 4 below). Recorded so
the DBL models for these masses are not mistaken for a resolved
birthline.

The deuterium rate fix in `788f2b7` (T9**(-2/3), not T9**(+2/3)) raised
the rate by about 1D4 at 1 MK. The seed, start and DBL libraries were
regenerated with it on 2026-10-27, in that order.

Below about 2.2 Msun the sequence works. The start models' log Tc stays
below 6.09, and each DBL run takes 13-87 models to reach the 1% drop in
central D (`END_DCEN = 2.75D-5`). Compared with the old rate, the
birthline comes 5-10x earlier, 0.4-0.5 dex brighter and 0.2 dex larger.

Above that, the start models are already hot: log Tc = 6.1-6.5 for
2.4-18 Msun. With the correct rate, D burns as soon as they evolve:

- 14 cases burn more than 1% of their D in the 5-model seed-to-start
  step. Their DBL run starts below `END_DCEN`, so `MAIN` disables the
  stop and the run went to 1000 models, onto the main sequence. Those
  decks now set `NMODLS(1) = 1`, so the DBL model is the start model plus
  one step. The cases are 2.8, 3.0, 4.0, 5.0, 6.0, 7.5, 12, 14, 16 and
  18 Msun at Z = 0.018804; 3 Msun at Z = 0.001, 0.003 and 0.010; and
  1 Msun at Z = 0.06.
- Most of the other masses above 2.4 Msun reach the 1% drop within
  1-16 models.

The radius cannot be raised to fix this. Pre-MS models can only be
rescaled in mass, not evolved up in radius, and ramping up from a lower
mass keeps R nearly fixed, so Tc rises roughly as M. A lower mixing
length during the ramp was tried: from 2.2 to 3.0 Msun at alpha = 1.0,
log R grew by only 0.004-0.013 dex over alpha = 1.85, and L fell by
0.23 dex. The ramp itself spans about 4D4 yr and burns more than half
the D. (alpha = 1.0 did make the ramp more stable: it reached 3.0 Msun,
where alpha = 1.85 aborted at 2.7.) A zero-timestep rescale cannot work
for a pre-MS model, which has no nuclear energy source.

Options considered: rescale from a more extended seed (not possible as
above), turn D burning off during the ramp, new extended seeds, or
accept the compact start. MHP chose to accept it.

Not regenerated, so still on the old rate:

- `startmodels/start/` at 22.5 and 25 Msun. Both abort in `TPGRAD` during
  their mass ramp from 18 Msun.
- 20 Msun. Its regenerated start model made the DBL run abort in
  `TPGRAD`, so the old start model was restored; its DBL model is new.
- 3 Msun at Z = 0.04 and 0.06 (issue 38).
- The 25 Msun DBL model. Its run fails to converge on the first model,
  from the old start model.
- `startmodels/dbl_grid/` (132 models). Its generators in
  `startmodels/sample_cases/` read pre-MS models that are not in the
  repository.

The experiments are in `ref_backups/2026-10-27_788f2b7/mlt_expt/`, beside
the repository.

### Zero-timestep rescaling, and the `L_ZERODT_PREMS` toggle (2026-10-27)

A true zero-timestep rescale does work for a model at the birthline,
where deuterium burning can carry the luminosity. `MAIN` had prevented
it: a `KINDRN = 2` rescale is aged whenever log Tc < 6.6 (the MHP 7/98
pre-MS failsafe). The new CONTROL namelist toggle `L_ZERODT_PREMS`
(default `.FALSE.`) disables that failsafe. With the default, results
are identical to before; only the namelist echo in `.short` gains a
line, which `pytest.ini` ignores.

With the toggle set, starting from the 2.2 Msun DBL model:

- A static solution converges at fixed mass. L equals the nuclear
  luminosity exactly and the gravitational term is 0. It is 0.06 dex
  smaller in log R and 0.08 dex hotter in log Tc than the evolving DBL
  model, which still contracts at its 1% D drop.
- A zero-timestep mass ramp in about 10% steps converges from 2.2 to
  10 Msun. log R rises smoothly from 1.06 to 1.67 while log Tc stays
  between 6.18 and 6.31, pinned by the temperature sensitivity of D
  burning. The deuterium is untouched.
- A normal DBL run from the 3 Msun static model needs `SETDT`. Without
  it, `HTIMER` took the stored timestep and the first step was 315 kyr,
  which burned all the D. With `SETDT(1) = 20` yr, the 1% drop came in
  22 models (440 yr) at constant L, R and Tc. That gives log R = 1.162
  and log Tc = 6.204, against 1.141 and 6.235 for the current library
  model.

### The DBL models above 2.4 Msun now use the zero-timestep ramp (2026-10-27)

28 DBL decks in `examples/run_from_start_to_dbl/` were rebuilt this
way (29 with 2.4 Msun, below): 2.6-25 Msun at Z = 0.018804, and 3 Msun at Z = 0.001, 0.003,
0.010, 0.040 and 0.060. Each deck:

1. reads a lower-mass DBL model from the library: 2.2 Msun for solar
   Z, 1 Msun at the same Z for the others. These decks therefore
   depend on other DBL models already being installed, the same pattern
   as the chained start decks.
2. sets `ISETISO = 1`. This resets D to its initial abundance on
   read-in. The source model is already past its own 1% drop, and
   without the reset `MAIN` disables the `END_DCEN` stop.
3. ramps to the target mass with `KINDRN = 2` zero-timestep rescales
   (`L_ZERODT_PREMS = .TRUE.`), 6 relaxations per step. The steps follow
   one shared ladder: every library mass from 2.4 Msun up, subdivided so
   no step is more than 8%. With a separate geometric sequence per deck,
   7 of the 23 solar ramps failed to converge somewhere between 3.2 and
   6.4 Msun, at masses other decks passed through cleanly. On the shared
   ladder all of them converge.
4. evolves at a fixed `SETDT` (20 yr x (3/M)**1.5, at least 1 yr) until
   `END_DCEN`, the 1% central-D drop.

All 28 exit cleanly and stop on `END_DCEN` after 7-43 models. There is
no `NaN` and no failure message. Along the solar sequence the DBL
models are smooth: log R runs from 1.115 to 2.032 and log Tc from 6.19
to 6.45, between 2.6 and 25 Msun. The `NMODLS(1) = 1` workaround is gone
from the decks it was in.

Checked to the ZAMS:

- The 19 `run_from_dbl_to_zams` cases at 2.6-16 Msun all stop on
  `END_XCEN`. They are within 0.002 dex in L, 0.004 dex in R and
  0.002 dex in Teff of their references.
- Temporary ZAMS decks were made for the other 9 models. The 18 Msun
  model reaches the ZAMS, and so do all five non-solar 3 Msun models
  (each with `END_XCEN` = X - 0.005).
- 20, 22.5 and 25 Msun abort in `TPGRAD` during the pre-MS
  contraction. That is not caused by the new models: the same decks
  started from the old DBL models (`09c3b9b`, and the `f7c4520` 20 Msun
  one) abort the same way. It is the limit above 16 Msun noted in
  `startmodels/readme.md`.

2.4 Msun was rebuilt the same way afterwards: a 2-step ramp, then 20
models to the 1% drop. It reaches the ZAMS within 0.002 dex of its
reference. So the seam is now between 2.2 Msun, which keeps its evolved
DBL model (log R = 1.118), and 2.4 Msun (1.087). From 2.4 Msun up the
ramp sequence is smooth (2.6 Msun is at 1.115).
