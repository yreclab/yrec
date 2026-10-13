# Known issues (open)

Deferred items with enough context to be picked up cold. Each entry records
what was observed, where in the code it lives, and what decision was taken.

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

**Status:** classification agreed 2026-10-13; no code changes yet.

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

**Status:** open. These are benign under COMMON and become errors or
silent confusion under `USE`.

A COMMON block may be declared with different member *names* in different
files, since matching is positional. A module has one set of names, so
each divergence must be resolved first.

| block | spelling A | spelling B |
|---|---|---|
| `ATMPRT` | `TAU,AP,AT,AD,AO,AFXION(3)` | `TAUL,AP,...` |
| `EGRID` | `CHI,ECHI,ES1,DCHI,NTOT` | `CHI,ECHI,EQS1,...` |
| `LLOT95E` | `CAPPAE(NUMT,NUMD),XTAB` | `CAPPAE(NUMTT,NUMD),XTAB` |

`NUMT` and `NUMTT` are both 70 today, so `LLOT95E`'s layout agrees; the
risk is that changing one spelling resizes the block in three files and
not the fourth.

Separately, **`XTAB` means two different things** and both would be
imported by a file that `USE`s each module: in `LLOT95E` it is a
*composition* (`op95xtab.f` sets `XTAB = X`, and `getopal95.f` tests
`ABS(X-XTAB)` to ask whether the requested X matches the loaded table),
while in `SPLIN` it is a *coordinate* (the tabulated abscissae that
`search.f` binary-searches). The `*TAB` suffix therefore means "the
composition this table is for" in the opacity blocks and "the tabulated
independent variable" in the spline workspace. One of them should be
renamed, as `OP95INTERP`'s `RL`/`RLL` were renamed to
`RHO_T63L`/`RHO_T63LL` for the same reason.

---

## 15. `LENVG` is a dead namelist variable awaiting staged removal

**Status:** open, deliberately staged by MHP.

`LENVG` has no executable use anywhere: its only occurrences are the
`COMMON/NMLBYPASS/` declaration continuations in `parmin.f`, `remap.f` and
`starin.f`, the `PHYSICS` namelist entry, and its `DATA` default. But
**106 namelist files set it**, so it cannot simply be dropped from the
namelist -- a namelist read would then fail on those inputs.

MHP's required order: strip `LENVG` from all namelist files first, then
remove it from the namelist and the code. Not urgent; it costs one word.

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

**Status:** open.

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

**Status:** open, for MHP to decide.

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

**Status:** open, cosmetic.

`getopac.f:114` defines label 100 with nothing branching to it, giving the
build's one remaining warning:
`Label 100 at (1) defined but not used`. Pre-existing, and almost
certainly another remnant of the removed opacity schemes. Worth clearing so
that the build is warning-free and a new warning stands out.

---

## 20. Repository housekeeping

**Status:** open.

- A stash is still unpopped: `stash@{0}: On development: pre-existing stray
  local edits, unrelated to this session, found blocking rebase`. It should
  be inspected and dropped or applied.
- `origin/doc_update` was reviewed and merged except for `spot_evol`, which
  MHP excluded as new code. The stale remote branch can be deleted.
- `main` is ahead 2 and behind 14 relative to `origin/main`, which wants
  sorting out separately from `development`.
- A full suite run leaves the two m9p0 `.last` fixtures modified every time;
  see issue 4.
