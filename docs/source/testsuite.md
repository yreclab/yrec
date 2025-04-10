Test Suite
==========

```{admonition} Defaults
:class: important
All tracks are solar metallicity unless otherwise noted. Standard suite includes the GS98 mixture and OP opacities, OPAL06 + SCV EoS, gray atmosphere, 0.2 Hp core overshoot w/0.15 beta above 1 Msun, SFII rates, no diffusion or rotation.  
```

## Solar models

- Solar auto-calibration run: standard model, includes Z/X calibration: `Testsolarcalibration`. Note: sta 

- Standard solar model – `Test_solar_noGS_norot_gray_OPALSCV_SF2_GS98_OP_CF10`. Note: CF10= moved core fitting point in by 10x to 1e-4 (recommended for solar models.) 

- Solar model, settling, no rotation – small core and envelope fitting. `Test_solar_GS_norot_gray_OPALSCV_SF2_GS98_OP_CF10`. Note: CF10= moved core fitting point in by 10x to 1e-4 (recommended for solar models.) 

- Solar model, settling and rotation – small core and envelope fitting. `Test_solar_GS_rot_gray_OPALSCV_SF2_GS98_OP_CF10`. Note: CF10= moved core fitting point in by 10x to 1e-4 (recommended for solar models.)

## Evolution to core He ignition

- 1 solar mass pre-MS to core He ignition, no settling or rotation, legacy neutrino cooling, standard core and envelope fitting: `Test_preMStoHeflash_gray_OPALSCV_SF2_GS98_OP`

- 1 solar mass pre -MS to core He ignition, no settling or rotation, Itoh neutrino cooling,1 solar mass standard core and envelope fitting: `Test_1M_preMStoHeflash_std_Itoh_gray_OPALSCV_SF2_GS98_OP`

- 3 solar mass pre -MS to core He ignition, no settling or rotation, Itoh neutrino cooling, 3 solar mass standard core and envelope fitting: `Test_3M_preMStoHeflash_std_Itoh_gray_OPALSCV_SF2_GS98_OP`

- 8 solar mass pre -MS to core He ignition, no settling or rotation, Itoh neutrino cooling, 8 solar mass standard core and envelope fitting: `Test_8M_preMStoHeflash_std_Itoh_gray_OPALSCV_SF2_GS98_OP` 

- A ZAHB run for 1 Msun. 

- 0.3 solar masses, Pre-MS to WD cooling, no settling or rotation, standard core and envelope fitting: `Test_0p3M_preMStoWD_std_gray_OPALSCV_SF2_GS98_OP` 

- 0.1 solar masses, Pre-MS to WD cooling, no settling or rotation, standard core and envelope fitting: `Test_0p1M_preMStoWD_std_gray_OPALSCV_SF2_GS98_OP` 

- [**Pre-MS to core He ignition**]()\
Pre-MS to core He ignition, settling, no rotation 1.2, 1.4, 1.6 -standard core and envelope fitting; test GS for thin envelopes. May need outer fitting point at 1e-3. 

## Rotational models

- Pre-MS rotation, slow, to MSTO, with loss and transport, settling 0.3, 0.6, 1.4 -small core and envelope fitting. 

- Pre-MS rotation, fast, to MSTO, with loss and transport, settling 0.3, 0.6, 1.4 -small core and envelope fitting. 

- Pre-MS to core He ignition, no diffusion, slow rotation, 1, 3, 8 -standard core and envelope fitting. 

- Pre-MS to core He ignition, no diffusion, fast rotation, 1, 3, 8 -standard core and envelope fitting. 

- Toggle switch setting for Pre-MS to He core ignition (1) or H core exhaustion (0.3), to test 1) atmospheres; 2) OPAL+SCV vs OPAL EoS vs SCV; 3) various rotation settings; 4) star spots; 5) neutrino cooling DONE (1 only). 

- Toggle switch settings for Pre-MS to He core ignition (3,8) to test core overshooting. 

- Toggle switch settings for solar model, settling, no rotation to test nuclear reaction rates. 

Once these are done, models with different metallicities, should be added. Some sample runs starting on the MS and on the core He-burning sequence, as well as sample rescaling cases, are also needed. 
