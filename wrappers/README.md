# YREC-Wrappers
Wrappers, helpful codes, and additional machinery to interface with YREC in languages such as Python. Presented here as individual scripts to copy/paste and/or download. Compatible with command line and Jupyter/Spyder, and other such programs. We provide the ```modelgrid_tools/main_tools``` folder for the primary mode of interacting with the grid, and ```modelgrid_tools/alternate_tools``` for advanced interfacing and backups for some functions.

## modelgrid_tools:
Contains guidelines and tools to create a grid of models in YREC. See the readme.md file in the folder for more details. This also contains update_nml.py, which allows the user to change several namelist parameters for multiple nml files at once. 

### main_tools: 
The main set of tools created for interacting with YREC. 
Tools Include: 

- A reader function for YREC outputs
- A namelist converter for the quick assignment of filepaths and physical constants. Allows the user to quickly adapt all YREC input files to their native directory structure and swithc between models quickly
- The code for re-creating our sample grid.

### alternate_tools: 
Provides backups and simpler versions of the ```main_tools``` repository for newer users or backups in case the main tools do not work. Includes a parallel processing code for running YREC, an alternate function for reading files in, and a code for automatically changing all filepaths in namelists to ones matching the native user directory.

### slurm_tools: 
Includes a yrec grid running function that quickly makes the sample grid. 




