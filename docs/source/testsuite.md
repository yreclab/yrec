Test Suite
==========

YREC includes an explicit set of namelists which cover behaviors known to work in the code. They act as example namelists for how to work with the code, and log specific configurations where the code will produce an expected result. As a result, they are also used to test backwards compatibility of the code between versions.

The test suite is currently divided into two categories: one is the **published test suite**, which represents a stable set of models published with one or more YREC instrument papers. The second is a set of contributed **test suite extras**, which demonstrate relevant code functionality and may be independently documented or published.

## Published Test Suite (`testsuite/`)

The stable, published, version of the test suite is located in the `testsuite/` directory, corresponding to the suite described in Pinsonneault et al. (*in prep*). This test suite covers a wide range in mass, evolutionary state, and input physics.

```{admonition} Defaults
:class: important
All tracks are solar metallicity unless otherwise noted. Standard suite includes the GS98 mixture and OP opacities, OPAL06 + SCV EoS, gray atmosphere, 0.2 Hp core overshoot w/0.15 beta above 1 Msun, SFII rates, no diffusion or rotation.  
```

### [Solar models](testsuite/solar.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_solar_base`      | A solar model taken to be the "base case". No diffusion, no rotation, and with a gray atmosphere. |
| `Test_solar_dif`      | The base case, with diffusion turned on: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`. |
| `Test_solar_dif_rot`      | The base case, with diffusion turned on, and rotation turned on: `LROT`, `LNEW0`, `LWNEW`, `LDISK` set to `.TRUE.`. |
| `Test_solar_dif_rot_fast`      | The base case, with diffusion turned on, and rotation turned on. `TDISK` and `FC` reduced relative to the `_rot` case. |
| `Test_solar_dif_rot_solid`      | The base case, with diffusion turned on, and rotation turned on. Solid body rotation `LSOLID` enforced, and `FC` increased relative to `_rot`. |
| `Test_solar_allard`      | The base case, but with an Allard model atmosphere (`KTTAU = 4`). |
| `Test_solar_kurucz`      | The base case, but with a Kurucz model atmosphere (`KTTAU = 3`). |
| `Test_solar_SF3`      | The base case, but with custom cross sections from Solar Fusion III set (`S0_*`). |
| `Test_solar_yaleeos`      | The base case, but with the Yale EOS, `LOPALE06 = .FALSE.` and `LSCV = .FALSE.`. |

### [Brown dwarf models](testsuite/brown_dwarf.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m0030_feh0_allard_15Gyr`      | A 0.03$M_\odot$ model with the Allard model atmosphere (`KTTAU = 4`), run to 15 Gyr. |
| `Test_m0050_feh0_allard_15Gyr`      | A 0.05$M_\odot$ model with the Allard model atmosphere (`KTTAU = 4`), run to 15 Gyr. |
| `Test_m0080_feh0_allard_15Gyr`      | A 0.08$M_\odot$ model with the Allard model atmosphere (`KTTAU = 4`), run to 15 Gyr. |

### [Zero age main sequence (ZAMS) models](testsuite/evolve_to_zams.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m0100_feh0_base_ZAMS`      | A 0.1$M_\odot$ model taken to be the "base case". No diffusion, no rotation, and with a gray atmosphere, run to the ZAMS. |
| `Test_m0100_feh0_allard_ZAMS`      | A 0.1$M_\odot$ base model with the Allard model atmosphere (`KTTAU = 4`) instead, run to the ZAMS. |
| `Test_m0100_feh0_spot25_ZAMS`      | A 0.1$M_\odot$ base model with the starspot filling fraction set to 0.25, run to the ZAMS; `LSDEPTH = .TRUE.`, `SPOTF = 0.25`, and `SPOTX = 0.85`. |
| `Test_m0300_feh0_allard_ZAMS`      | A 0.3$M_\odot$ base model with the Allard model atmosphere (`KTTAU = 4`) instead, run to the ZAMS. Note: the `Test_m0300_feh0_base_ZAMS` model exists, but is classified under `Evolution`. |
| `Test_m0300_feh0_spot25_ZAMS`      | A 0.3$M_\odot$ base model with the starspot filling fraction set to 0.25, run to the ZAMS; `LSDEPTH = .TRUE.`, `SPOTF = 0.25`, and `SPOTX = 0.85`. |
| `Test_m0300_feh0_scveos_ZAMS`      | A 0.3$M_\odot$ base model, but with the SCV EOS, `LOPALE06 = .FALSE.`. |
| `Test_m0300_feh0_yaleeos_ZAMS`      | A 0.3$M_\odot$ base model, but with the Yale EOS, `LOPALE06 = .FALSE.` and `LSCV = .FALSE.`. |
| `Test_m1000_feh0_spot25_ZAMS`      | A 1.0$M_\odot$ base model with the starspot filling fraction set to 0.25, run to the ZAMS; `LSDEPTH = .TRUE.`, `SPOTF = 0.25`, and `SPOTX = 0.85`. |

### [Terminal age main sequence (TAMS) models](testsuite/evolve_to_tams.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m1000_feh0_dif_ZAMS`      | A 1.0$M_\odot$ base case, with diffusion turned on: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`, run to the TAMS. |
| `Test_m1400_feh0_dif_ZAMS`      | A 1.4$M_\odot$ base case, with diffusion turned on: `LDIFY`, `LDIFZ`, and `LDIFLI` set to `.TRUE.`, run to the TAMS. |

### [Evolution models](testsuite/evolution.md)


| Model Name     | Description    |
| ------------ | -------------- |
| `Test_m0300_feh0_base_ZAMS`      | A 0.3$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the ZAMS. |
| `Test_m0300_feh0_base_TAMS`      | A 0.3$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m1000_feh0_base_TAMS`      | A 1.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m1000_feh0_base_HeIgnite`      | A 1.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to He ignition. |
| `Test_m3000_feh0_base_TAMS`      | A 3.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the TAMS. |
| `Test_m3000_feh0_base_ZAHB`      | A 3.0$M_\odot$ base case. No diffusion, no rotation, and with a gray atmosphere. Run to the ZAHB. |
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
