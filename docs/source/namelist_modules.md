Where Namelist Variables Live
=============================

YREC's `COMMON` blocks were replaced by Fortran 90 modules in October 2026.
There are no `COMMON` blocks left in the code. If you are looking for the
storage behind a namelist variable, this page says which module holds it
and why the namelist variables are not all in one place.

## The three namelist groups

All three groups are declared in `parmin.f`, which is the only routine
that reads the namelist files:

| group | file | variables |
| ----- | ---- | --------- |
| `/CONTROL/` | `.nml1` | 110 |
| `/PHYSICS/` | `.nml2` | 237 |
| `/DERIVED/` | written to output, not read | 36 |

366 distinct variables in total, since a few appear in more than one
group.

## Which module holds what

| module | namelist variables | of its members | holds |
| ------ | ------------------ | -------------- | ----- |
| `NMLPAR_MOD` | 234 | 234 (all) | everything the physics routines read |
| `NMLBYPASS_MOD` | 83 | 83 (all) | derivation-only variables |
| `CONSTANTS_MOD` | 5 | of 30 | `CLSUN`, `CRSUN`, `CC13`, `CC23`, `CLN` |
| `INTPAR_MOD` | 3 | of 3 | `STOLR0`, `IMAX`, `NUSE` |
| *(no module)* | 41 | -- | see below |

Broken down by namelist group:

| group | `NMLPAR` | `NMLBYPASS` | `CONSTANTS` | `INTPAR` | none |
| ----- | -------- | ----------- | ----------- | -------- | ---- |
| `/CONTROL/` | 68 | 8 | 0 | 0 | 34 |
| `/PHYSICS/` | 151 | 75 | 2 | 3 | 6 |
| `/DERIVED/` | 31 | 1 | 3 | 0 | 1 |

## Why not one module

The split is deliberate, and each boundary is drawn for a different
reason.

### `NMLPAR_MOD` against `NMLBYPASS_MOD`: split by consumer

`NMLPAR_MOD` holds the namelist variables that physics routines read.
`NMLBYPASS_MOD` holds those read **only** by `PARMIN`, to derive some
other quantity that the physics routines then use.

The point of keeping them apart is that a routine writing
`USE NMLPAR_MOD` imports only names it could legitimately use. Were the
two merged, every physics routine would import 83 names that exist purely
as inputs to a calculation in `PARMIN`, and a reader could not tell from
the import which kind of variable they were looking at.

This boundary also matters if you add a namelist variable. Ask whether a
physics routine will read the variable itself, or only something derived
from it, and put it in the matching module.

### `CONSTANTS_MOD`: a value belongs with what is derived from it

Five namelist variables sit among 25 non-namelist members. `CLSUN` and
`CRSUN` are the definitions of the solar luminosity and radius used for
tracks and output; `setups.f` derives `CLSUNL` and `CRSUNL` from them by
taking logarithms, and much of the code uses the logged forms. `CC13`,
`CC23` and `CLN` are 1/3, 2/3 and ln(10).

Moving the five into `NMLPAR_MOD` would separate each value from the
quantities computed out of it, for no gain: a routine needing `CLSUNL`
almost always wants `CLSUN` too.

### `INTPAR_MOD`: machinery for one integrator

`STOLR0`, `IMAX` and `NUSE` are the convergence tolerance, iteration
limit and sequence length of the Bulirsch-Stoer integrator. They are read
by `bsstep.f` and `envint.f` and by nothing else. They are parameters of
one numerical method rather than physics controls, so they stay with that
method.

Note that the envelope integrator's own controls -- `ENVERR`, `ENVBEG`,
`ENVMIN`, `ENVMAX`, `ENVSTP`, and the `ATM*` equivalents for the
atmosphere -- are *not* here. They are in `NMLPAR_MOD` with the rest of
the physics controls.

## The 41 variables in no module

### 32 `CHARACTER` variables

The file names (`FFIRST`, `FLAST`, `FSHORT`, `FSTOR`, `FTRACK`,
`FOPALE06`, `FALLARD` and the rest) and the option strings `AMIX`,
`AISO`, `AWIND`, `ANEWCP`, `ATMP` and `DESCRIP`.

`CHARACTER` data was deliberately removed from shared storage during the
`COMMON` consolidation and is **passed as arguments** instead. Character
data in a `COMMON` block forces padding against the numeric members,
which gfortran reports as an alignment warning and which differs between
compilers. `main.f` reads these from the namelist through `PARMIN` and
threads them to the routines that open the files.

If you add a `CHARACTER` namelist variable, pass it as an argument.

### 9 variables local to `PARMIN`

`KINDRN`, `RSCLM`, `RSCLX`, `RSCLZ`, `RSCLCM`, `ALFA`, `FK`, `WMAX_SUN`
and `SUM_FRAC`.

Each is read from the namelist and consumed inside `PARMIN` to set
something else up. `KINDRN` seeds `IRESCA` in `RUNLOOP_MOD`; the four
`RSCL*` arrays are rescaling inputs; `ALFA` and `FK` are exponents for
the legacy Kawaler (1988) wind law; `WMAX_SUN` and `SUM_FRAC` are
scratch. Nothing outside `PARMIN` reads any of them, so none needs
module storage.

## Finding a variable

To locate any name:

```
grep -l 'VARNAME' src/*_mod.f          # which module declares it
./shadow_census.py --member VARNAME    # every file that references it
```

The second form also reports whether a file holds the name through a
module or as its own local, which is the distinction that matters when
you are adding a `USE` statement. See `KNOWN_ISSUES.md` issue 22 for why
that check is worth running.

## Module conventions

Every converted block follows the same pattern, described at length in
`F90_CONVERSION_PLAN.md`:

- one block per file, `<block>_mod.f` containing `MODULE <BLOCK>_MOD`;
- imported with a blanket `USE`, not `USE ... , ONLY:`;
- explicit types, restating what the old implicit rules supplied: a name
  beginning `L` is `LOGICAL*4`, `I`/`J`/`K`/`M`/`N` are `INTEGER*4`,
  everything else `REAL*8`;
- an explicit `SAVE`, which matches `COMMON`'s semantics and does not
  rely on the Fortran 2008 rule that module variables are implicitly
  saved, since `ifort` Classic predates it;
- namelist defaults as initializers rather than `DATA` statements,
  because `DATA` on a `USE`-associated name is rejected. The initializer
  is applied once at load time, before `PARMIN` runs and therefore before
  the namelist read, which is exactly what `DATA` did.
