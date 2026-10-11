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
