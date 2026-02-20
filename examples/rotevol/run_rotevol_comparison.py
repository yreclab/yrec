"""

Script for running rotevol on non-rotating YREC models
User can include different rotation physics by modifying the parameter inputs below
This script runs matching rotation physics to full Rotevol runs in Gyrochrone directory

@author: AAsh
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import os
import glob
import scipy.interpolate as interp
import gen_rotgridv3 as gen_rotgrid
import pandas as pd
import matplotlib
import matplotlib.cm as cm
import time


def p0(mstar):
    if mstar > 0.4:
        pdisk = 8.0 
    if mstar <= 0.4:
        lnpdisk = 3.82*mstar - 0.62
        pdisk = (10**lnpdisk)
        pdisk = pdisk
    return pdisk


rotevol_executable = "run_experiment"        
solid_output_dir = "/tracks/comparisons/solidbody" #directory for solid body rotevol outputs 
nonsolid_output_dir = "/tracks/comparisons/nonsolidbody" #directory for non-solid body rotevol outputs 

fname_template = "{0}" #naming convention for rotevol outputs
track_dir = "../../Release Paper Sample Case Output/Gyrochrones"
local_rotevol = os.getcwd() 

os.system("mkdir {0}".format(solid_output_dir))
os.system("mkdir {0}".format(nonsolid_output_dir))

#define model grid parameters for control file: 
Lsolid = ["T"]
IWIND = ["3"]
Fk = ["6.5600D0"]
PMMA = ["2.0000D0"]
PMMB = ["1.0000D0"]
PMMC = ["0.0000D0"]
PMMM = ["2.2000D-1"]
SOLJDOT = ["1.3000E+30"]
SOLMDOT = ["1.2700E+12"]
NUM_ROT = ["1"]
Prot0 = ["1.0000D0"]
Tdisk = ["5.000D1"]
TauCouple = ["2.0000E+07"]
Ro_scale = ["TRUE"]
Omega_Crit = ["2.83D-5"] 
LROSS = ["T"]
LCalSol = ["FALSE"]
SOLAGE = ["4.568D9"]
SOLW = ["2.83D-6"] 

# Use tools from gen_rotgrid to generde runfiles and control files: 

grid = np.meshgrid(Lsolid, IWIND, Fk, PMMA, PMMB, PMMC, PMMM, SOLJDOT, SOLMDOT, NUM_ROT, Prot0, Tdisk, TauCouple, Ro_scale, Omega_Crit, LROSS, 
                  LCalSol, SOLAGE, SOLW)
dim = len(grid)
elements = grid[0].size  # Number of elements, any index will do
flat = np.concatenate(grid).ravel()  # Flatten the whole meshgrid
grid = np.reshape(flat, (dim, elements)).T  # Reshape and transpose


for windparam in grid: 
    #generate runfile 
    tracks = sorted(glob.glob(track_dir +  "/rotevolin*.track")) #pick non-rotating YREC tracks
    
    for t in tracks: 
        track_name = t.split("/")[-1].split(".track")[0]
        
        #run solid body case
        runfile_params = {"local":local_rotevol,
                     "tracks": track_dir,
                     "output_dir": local_rotevol + solid_output_dir,
                     "dat_file":fname_template.format(track_name),
                     "track_file": track_name,
                     "numerics_out": track_name + "_num",
                     "rot_track_out": track_name + "_rot",
                     "executable_name": rotevol_executable}

        
        runfile_name = "run_" + track_name

        #generate control file
        controlfile_params = {"INUMT":"1",
                   "LSOLID":".TRUE.",
                   "IWIND":windparam[1],
                   "FK":"7.5", #matches YREC settings 
                  "PMMA":windparam[3],
                  "PMMB": windparam[4],
                  "PMMC": windparam[5],
                  "PMMM": windparam[6],
                  "NUMROT":"1",
                  "PDISK0(1)":windparam[10],
                  "TDISK0(1)":windparam[11],
                  "TAUCOUPLE":windparam[12],
                  "WCRIT":windparam[14],
                  "LROSS":windparam[13], 
                  "SOLAGE":windparam[17], 
                  "SOLW":windparam[18]}

        
        controlfile_name = track_name + ".dat"

        gen_rotgrid.gen_runfile(runfile_params, runfile_name)
        gen_rotgrid.gen_controlfile(controlfile_params, controlfile_name)

        os.system("make -f Makerotwind")
        os.system("mkdir -p {0}".format(runfile_params["output_dir"]))

        os.system("./{0}".format(runfile_name)) #runs rotevol for the set of parameters given by windparam
        
        
        ########################################### run non-solid body case
        
        
        
        runfile_params = {"local":local_rotevol,
                     "tracks": track_dir,
                     "output_dir": local_rotevol + nonsolid_output_dir,
                     "dat_file":fname_template.format(track_name),
                     "track_file": track_name,
                     "numerics_out": track_name + "_num",
                     "rot_track_out": track_name + "_rot",
                     "executable_name": rotevol_executable}

        
        runfile_name = "run_" + track_name
        
        #generate control file
        controlfile_params = {"INUMT":"1",
                   "LSOLID":".FALSE.",
                   "IWIND":windparam[1],
                   "FK":"10.8", #matches YREC settings 
                  "PMMA":windparam[3],
                  "PMMB": windparam[4],
                  "PMMC": windparam[5],
                  "PMMM": windparam[6],
                  "NUMROT":"1",
                  "PDISK0(1)":windparam[10],
                  "TDISK0(1)":windparam[11],
                  "TAUCOUPLE":windparam[12],
                  "WCRIT":windparam[14],
                  "LROSS":windparam[13], 
                  "SOLAGE":windparam[17], 
                  "SOLW":windparam[18]}
        
        
        controlfile_name = track_name + ".dat"

        gen_rotgrid.gen_runfile(runfile_params, runfile_name)
        gen_rotgrid.gen_controlfile(controlfile_params, controlfile_name)

        os.system("make -f Makerotwind")
        os.system("mkdir -p {0}".format(runfile_params["output_dir"]))

        os.system("./{0}".format(runfile_name)) #runs rotevol for the set of parameters given by windparam
        
