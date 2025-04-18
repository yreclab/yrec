Sample Namelists
================

## Nuclear Reaction Rate Tests (subdirectory)

`Test_1Msun_stdpp` (`nml1` and `nml2`) and `Test_10Msun_stdcno` (`nml1` and `nml2`) are sample template cases with standard nuclear reaction rates for a 1 and 10 solar mass model respectively, evolved from the deuterium burning birthline to the ZAMS. This is intended to use as a basis for exploring changes in nuclear reaction rates, listed below. Code defaults, from Solar Fusion 2, are listed. Updated rates from the Solar Fusion 3 paper are in () after.  Changing just pp (**S0_1_1**), all three major pp branches (**S0_1_1**, **S0_3_3**, **S0_3_4**), just N14+p (**S0_1_14**) and all CNO (**S0_1_12**, **S0_1_13**, **S0_1_15**, **S0_1_16**, **S0_1_15_C12ALP**, **S0_1_15_O16**) are recommended variant cases.

```
  S0_1_1 = 4.01D-22 !(4.09D-22)
  S0_3_3 = 5.21D3 !(5.21D3)
  S0_3_4 = 5.61D-1 !(5.61D-1)
  S0_1_12 = 1.34D0 !(1.44D0)
  S0_1_13 = 7.6D0 !(6.1D0)
  S0_1_14 = 1.66D0 !(1.68D0)
  S0_1_16 = 1.06D1 !(1.09D1)
  S0_PEP = 3.5734D-6 
  S0_1_BE7E = 1.7709D-10
  S0_1_BE7P = 0.0208D0 !(0.0205D0)
  S0_HEP = 8.6D-20
  S0_1_15_C12ALP = 7.3D4 !(7.3D4)
  S0_1_15_O16 = 3.6D1 !(4.0D1)
```

## Solar Models (subdirectory)

1. `Test_solarcal_noGS_norot` (`nml1` and `nml2`) is an example that runs an auto-calibrator to solve for the (X,Y,Z) and mixing length alpha for a calibrated solar model.

2. `Test_solar_noGS_norot` (`nml1` and `nml2`) is a solar model run using the solution from the auto-calibrator in the first namelist. Both of these models do not include gravitational settling of helium and heavy elements, or rotation.

3. `Test_solar_GS_norot_gray_OPALSCV_SF2_GS98_OP_CF10` (`nml1` and `nml2`) is a solar model that includes gravitational settling of helium and heavy elements, but does not include rotation.

4. `Test_solar_GS_rot_gray_OPALSCV_SF2_GS98_OP_CF10` (`nml1` and `nml2`) is a solar model that includes both gravitational settling of helium and heavy elements and rotation.

## Starting Models (subdirectories)

1. `run_from_seed_to_start` has the namelists and scripts used to generate the library of luminous, Hayashi track initial models. These examples include models with different metallicities and a wide range of masses. Note that these were all generated with a common set of physics and numerical inputs (start.nml2).  Feel free to use these as templates for other mass / metallicity combinations.

2. `run_from_start_to_dbl` has the namelists and scripts used to generate the library of models at the deuterium burning birthline. These examples include models with different metallicities and a wide range of masses. Note that these runs do not all have the same numerical settings – in particular, the lowest mass models require more precise tunings.

## Pre-MS to MS (subdirectory)

3. `run_from_dbl_to_zams` models has sample namelists and scripts to generate models from the pre-MS to the ZAMS.  Note that, by setting a different stop condition, these same scripts could be used to evolve either to the He flash or through He core burning for higher mass stars.  You should use these as templates, paying attention to differences in the numerical parameters for stars below 0.2 solar masses.
