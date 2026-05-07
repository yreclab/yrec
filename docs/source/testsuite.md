Test Suite
==========

YREC includes an explicit set of namelists which cover behaviors known to work in the code. They act as example namelists for how to work with the code, and log specific configurations where the code will produce an expected result. They are also used to test backwards compatibility of the code between versions and during development.

The test suite is currently divided into two categories: one is the **published test suite**, which represents a stable set of models published with one or more YREC instrument papers. The second is a set of contributed **test suite extras**, which demonstrate relevant code functionality and may be independently documented or published.

## Running tests

A test runner is provided to execute YREC on collections of model definitions,
store the results as reference standards, and compare subsequent runs against
those standards in order to identify changes in behavior.  While YREC is a pure
Fortran application, pytest was chosen to be the test execution framework due
to its feature set and ease of installation and use.

### Environment

The test runner is implemented using pytest, which in turn requires python. A
python virtualenv may be useful to host the necessary packages.

```
python -m venv ./yrec
source ./yrec/bin/activate
pip install pytest pytest-xdist
```

If a suitable python is not available, one may be installed using mamba or
conda and then used as a base for installing pytest.

```
mamba create -n yrec python=3.10
mamba activate yrec
pip install pytest pytest-xdist
```

The test runner has been successfully used with python 3.10, pytest 8.4.2, and
pytest-xdist 3.8.0 and should also work with newer versions of these.

### Procedure

1. Build YREC using the Makefile in `src` (see <project:./quickstart.md#building-yrec>)
2. Activate environment containing pytest per Environment steps above
3. Edit configuration file `pytest.ini` (in repository root directory) to specify and/or change various parameters, such as:

    a. Location of yrec executable

    b. List of sets or individual cases to run. The file contains documentation
    on how to precisely specify which tests to run.

    c. Numerical tolerance for comparisons with reference standard outputs

4. Run tests - Tests are typically run from the repository root directory.

    a. Sequentially:  `pytest`

    b. Multiple in parallel, using X concurrent workers:  `pytest -nX`

### Test Runner Behavior

The test runner will produce a summary of pass/fail results and indicate any
differences from reference outputs indentified. With the default output
verbosity, green periods (.) indicate passing tests, failures are marked with a
red 'F'. Output from failing tests is provided after all tests have been run.
Other pytest command line arguments are accepted as well, including '-v' for a
more verbose output during execution which shows the name of each test case.

The first time a test case is run, the YREC outputs produced are promoted to
reference standards and are copied into the `standard` directory alongside the
input namelists in a given directory. If the test runner detects that a
reference standard output for a test case already exists in the `standard`
directory, it will compare the new YREC outputs against the standard and will
fail a test that has outputs which differ from the reference standard.

```{admonition} Note
All test suite and extras namelists are configured to honor the various YREC
path overrides provided through environment variables.
```
(Re: the note above, see <project:./namelist_control.md#file-location-specifiers> )


## Published Test Suite (`testsuite/`)

The stable, published, version of the test suite is located in the `testsuite/`
directory, corresponding to the suite described in Pinsonneault et al. This
test suite covers a wide range in mass, evolutionary state, and input physics.

In addition to the set of model definitions provided in the formal test suite,
there are additional test cases which exercise further YREC functionality.
These are found in the 'examples', and 'sample_cases' directories.

```{admonition} Defaults
:class: important
All tracks are solar metallicity unless otherwise noted. Standard suite includes the GS98 mixture and OP opacities, OPAL06 + SCV EoS, gray atmosphere, 0.2 Hp core overshoot w/0.15 beta above 1 Msun, SFII rates, no diffusion or rotation.
```

### [Solar models](testsuite/solar.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_solarGS98_base`      | A solar model taken to be the "base case". No diffusion, no rotation, and with a gray atmosphere. |
| `Test_solarGS98_dif`      | The base case, with diffusion turned on: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`. |
| `Test_solarAAG21_dif`      | The base case, with diffusion turned on and the AAG21 mixture: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`. |
| `Test_solarM22M_dif`      | The base case, with diffusion turned on and the Magg22 mixture: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`. |
| `Test_solarGS98_dif_rot`      | The base case, with diffusion turned on, and rotation turned on: `LROT`, `LNEW0`, `LWNEW`, `LDISK` set to `.TRUE.`. |
| `Test_solarGS98_dif_rot_fast`      | The base case, with diffusion turned on, and rotation turned on. `TDISK` and `FC` reduced relative to the `_rot` case. |
| `Test_solarGS98_dif_rot_solid`      | The base case, with diffusion turned on, and rotation turned on. Solid body rotation `LSOLID` enforced, and `FC` increased relative to `_rot`. |
| `Test_solarGS98_kurucz`      | The base case, but with a Kurucz model atmosphere (`KTTAU = 3`). |
| `Test_solarGS98_SF3`      | The base case, but with custom cross sections from Solar Fusion III set (`S0_*`). |
| `Test_solarGS98_yaleeos`      | The base case, but with the Yale EOS, `LOPALE06 = .FALSE.` and `LSCV = .FALSE.`. |

### [Brown dwarf models](testsuite/brown_dwarf.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m0p03feh0+0GS98_allard_15Gyr`      | A 0.03$M_\odot$ model with the Allard model atmosphere (`KTTAU = 4`), run to 15 Gyr. |
| `Test_m0p05feh0+0GS98_allard_15Gyr`      | A 0.05$M_\odot$ model with the Allard model atmosphere (`KTTAU = 4`), run to 15 Gyr. |
| `Test_m0p08feh0+0GS98_allard_15Gyr`      | A 0.08$M_\odot$ model with the Allard model atmosphere (`KTTAU = 4`), run to 15 Gyr. |

### [Zero age main sequence (ZAMS) models](testsuite/evolve_to_zams.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m0p1feh0+0GS98_base_ZAMS`      | A 0.1$M_\odot$ model taken to be the "base case". No diffusion, no rotation, and with a gray atmosphere, run to the ZAMS. |
| `Test_m0p1feh0+0Gs98_allard_ZAMS`      | A 0.1$M_\odot$ base model with the Allard model atmosphere (`KTTAU = 4`) instead, run to the ZAMS. |
| `Test_m0p1feh0+0GS98_spot25_ZAMS`      | A 0.1$M_\odot$ base model with the starspot filling fraction set to 0.25, run to the ZAMS; `LSDEPTH = .TRUE.`, `SPOTF = 0.25`, and `SPOTX = 0.85`. |
| `Test_m0p3feh0+0GS98_allard_ZAMS`      | A 0.3$M_\odot$ base model with the Allard model atmosphere (`KTTAU = 4`) instead, run to the ZAMS. Note: the `Test_m0300_feh0_base_ZAMS` model exists, but is classified under `Evolution`. |
| `Test_m0p3feh0+0GS98_spot25_ZAMS`      | A 0.3$M_\odot$ base model with the starspot filling fraction set to 0.25, run to the ZAMS; `LSDEPTH = .TRUE.`, `SPOTF = 0.25`, and `SPOTX = 0.85`. |
| `Test_m0p3feh0+0GS98_scveos_ZAMS`      | A 0.3$M_\odot$ base model, but with the SCV EOS, `LOPALE06 = .FALSE.`. |
| `Test_m0p3feh0+0GS98_yaleeos_ZAMS`      | A 0.3$M_\odot$ base model, but with the Yale EOS, `LOPALE06 = .FALSE.` and `LSCV = .FALSE.`. |
| `Test_m1p0feh0+0GS98_spot25_ZAMS`      | A 1.0$M_\odot$ base model with the starspot filling fraction set to 0.25, run to the ZAMS; `LSDEPTH = .TRUE.`, `SPOTF = 0.25`, and `SPOTX = 0.85`. |

### [Terminal age main sequence (TAMS) models](testsuite/evolve_to_tams.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m1p0feh0+0GS98_dif_ZAMS`      | A 1.0$M_\odot$ base case, with diffusion turned on: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`, run to the TAMS. |
| `Test_m1p4feh0+0GS98_dif_ZAMS`      | A 1.4$M_\odot$ base case, with diffusion turned on: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`, run to the TAMS. |

### [Evolution models](testsuite/evolution.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m0p3feh0+0GS98_base_ZAMS`      | A 0.3$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the ZAMS. |
| `Test_m0p3feh0+0GS98_base_TAMS`      | A 0.3$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m1p0feh0+0GS98_base_TAMS`      | A 1.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m1p0feh0+0GS98_base_HeIgnite`      | A 1.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to He ignition. |
| `Test_m3p0feh0+0GS98_base_TAMS`      | A 3.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m3p0feh0+0GS98_base_ZAHB`      | A 3.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the ZAHB. |
| `Test_m9p0feh0+0GS98_base_TAMS`      | A 9.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m9p0feh0+0GS98_base_TAHB`      | A 9.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAHB. |
| `Test_m9p0feh0+0GS98_yaleeos_TAMS`      | A 9.0$M_\odot$ base case with the Yale EoS. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m9p0feh0+0GS98_yaleeos_TAHB`      | A 9.0$M_\odot$ base case with the Yale EoS. No diffusion, no rotation, and with a gray atmosphere. Run to the TAHB. |


## Test Suite Extras (`examples/`)

 To be completed.

### Links to test suite models:
```{toctree}
:maxdepth: 1
:glob:
testsuite/*
```
