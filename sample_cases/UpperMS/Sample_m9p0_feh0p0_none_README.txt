Sample_m9p0_feh0p0_none

This is a non-rotating, solar metallicity, 9 Msun model with the default OPAL EoS, no semiconvection, no overshooting, a gray atmosphere, no gravitational settling, and no diffusion. The model is run from the deuterium birth line to the TAHB with the same tolerances and resolution parameters all the way through. 

DBL to TAHB:
The evolution is handled with two runs (NUMRUN=2). The first is a rescale and evolution run (KINDRN = 3), which rescales the 9 Msun dbl model to solar metallicity and the appropriate mixing length over two steps. The second is an evolution run (KINDRN=1) which evolves the star until the central helium abundance drops below 1E-4 (END_YCEN(2) = 0.0001). In order for the model to reach helium depletion, the inner fitting point must be moved in (LCORE=TRUE). No changes to the default tolerances, iterations, and resolution are required in order for this model to run. 

Alternate stopping point at the TAMS:
The evolution can be stopped with the central hydrogen abundance set to 1E-4 (END_XCEN(2) = 0.0001).

Alternate stopping point at the ZAHB:
To stop at the ZAHB instead, set KINDRN=1, NUMRUN=1, and set the stopping condition as a central helium abundance of 0.97 (END_YCEN(1) = 0.97). The same resolution and tolerance parameters from the DBL to TAMS evolution can be kept, with LCORE = FALSE set. Either the dbl model or the .last model from the TAMS run can be used as the starting model. If the latter, set LCORE to false.