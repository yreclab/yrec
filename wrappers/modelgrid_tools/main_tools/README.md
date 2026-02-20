# YREC Tools (`main_tools/`)
## Overview

This repository contains Python tools for preparing, updating, and managing YREC (Yale Rotating Stellar Evolution Code) model grids. These scripts help you:

- Update YREC namelist files with custom parameters.
- Generate grids of stellar models over mass and metallicity ([Fe/H]).
- Load and manipulate YREC model tracks for analysis.
- Run YREC in batch mode for multiple models efficiently.

These tools are ideal for research-level stellar modeling, especially when creating large grids or testing multiple physical assumptions.

---

## Directory Structure

main_tools/
- `batchrunner.py`          : Run YREC in batch mode.
- `load_yrec_tracks.py`     : Load YREC model tracks into Python.
- `update_nml.py`           : Update YREC namelist files.
- `make_modelgrid.py`       : Generate a mass-[Fe/H] grid of input files.
- `solar_rot_calibrated.py`: Calibrate the L, T, R, and Age of a solar model.
- `README.md`               : This documentation.


