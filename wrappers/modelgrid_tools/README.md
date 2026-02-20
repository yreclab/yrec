# modelgrid_tools
Tools for creating a grid of models using YREC

How to use YREC to compute the ages of a population of stars:

Generally this is done with a grid of models - models making the same physical assumptions, but run at a range of masses and compositions. Then a separate program is used to interpolate between those models to the values of each data point (e.g. the mass, metallicity, alpha-abundance, and logg of a giant) (this can also be e.g. the luminosity and composition and temperature of a subgiant, or the logg, Teff and composition of a dwarf)


**Create a Base Model**

This is one model where you have calibrated the physics of interest. This is most commonly a model of solar mass, and solar composition calibrated to match the solar luminosity and solar radius at the solar age, but any similarly precise choice may be justifiable.

Look at the inlists for a model- what choices do you want to make for atmosphere boundary condition, rotation, nuclear reaction rates, timestepping, etc?

update_nml.py contains the function update_namelists() that allows you to easily change variables in namelists. 

Run the solar model, as well as models with slightly different mixing length and helium abundance. Interpolate and run a few models again, and interpolate again, getting a relatively close calibration.

Before creating and running the entire grid, create a sparse grid of models (often just the corner of the grid- maximum and minimum mass, maximum and minimum metallicity, as well as the base model) to check that the numerics will run for a range of cases (e.g. all models will make it up to the tip of the giant branch or whatever the metric of interest is).


**File List**

make_modelgrid.py allows you to create a grid of models that vary in mass and metallicity. It is the most up-to-date and well-documented way to create a file list. If you want to vary other quantities such as rotation or mixing length, feel free to modify it.

Once you have the base model decided, you come up with a list of things you want to perturb. Mass and metallicity are the most common things to change, but rotation, mixing length, helium, or other quantities may also be things you want to change.


**Running the Models**

Once all the inlists have been generated you have to run them. 

batchrunner.py is a script to run a grid of namelists in python. It is intended to be used from the command line and has 2 versions within it: one for generating and running a mass-Fe/H grid, the other for running a pre-existing grid.

run_yrec_grid.slurm is a an example slurm script for running a grid of YREC models on a supercomputer.

**Reading Output Files**
read_output_files allows the user to read individual .store, .last, and .track YREC output files into Pandas dataframes without
any additional processing of the output files. 
