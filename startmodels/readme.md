# Libraries of Starting Models for YREC

This directory contains libraries of starting models for YREC:

- `seed` models are the legacy starting models from prior generations of the YREC code. These are all pre-MS models, well up the Hayashi track.
- `start` models are generated from the seed models. These are all generated using the Grevesse & Sauval (1998) heavy element mixture, the OPAL 2006 EoS, the Eddington gray atmosphere, and a mix of OP atomic opacities and Alexander+2006 molecular opacities. There is a dense grid of models for solar metallicity (0.03 – 25 solar masses), and a sparse grid (0.05, 0.1, 0.3, 1, 3, 10 solar masses) run for metallicities from 0.001 – 0.06. These models are a good initial starting set if you plan on modifying the masses, mixtures or metallicities of the models. You can generate a denser grid at different metallicities by copying the templates used in the Run_start_zgrid for a wider range of starting masses.
- `dbl` models are the starting models run to the beginning of the deuterium burning birthline, defined as a 1% drop from the initial deuterium abundance. These are a good starting point for normal stellar evolution calculations. If you need a mass / abundance combination not present in the library, you should generate it from the starting model libraries and run it to this initial state.

Important notes:

- Above 16 solar masses, the code will fail because we are not properly accounting for radiation pressure driven winds in the atmosphere model solution.
- Below 40 Jupiter masses, the solutions fall outside of the OPAL 2006 EoS. A different set of starting models, using the SCV EoS alone, would need to be developed from perturbing the starting models.
