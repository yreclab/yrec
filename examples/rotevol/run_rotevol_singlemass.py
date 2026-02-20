"""

Script for running rotevol on non-rotating YREC model
User can include different rotation physics by modifying the parameter inputs below
This script runs different rotation physics on a somar mass model 

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

rotevol_executable = "run_experiment" #must match executable name in Makerotwind
master_output_dir = "/tracks/solar_model/" #directory for rotevol outputs 

fname_template = "solar_rot_{0}PMMA" #naming convention for rotevol outputs
track_dir = "../../Release Paper Sample Case Output/Gyrochrones"
local_rotevol = os.getcwd()

os.system("mkdir {0}".format(master_output_dir))

#define model grid parameters for control file: 
Lsolid = ["T"]
IWIND = ["3"]
Fk = ["6.5600D0"]
PMMA = ["2.0000D0", "3.0000D0"]
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
Omega_Crit = ["2.687D-5"] 
LROSS = ["T"]
LCalSol = ["FALSE"]
SOLAGE = ["4.568D9"]
SOLW = ["2.86307D-6"] 

# Use tools from gen_rotgrid to generde runfiles and control files: 

grid = np.meshgrid(Lsolid, IWIND, Fk, PMMA, PMMB, PMMC, PMMM, SOLJDOT, SOLMDOT, NUM_ROT, Prot0, Tdisk, TauCouple, Ro_scale, Omega_Crit, LROSS, 
                  LCalSol, SOLAGE, SOLW)
dim = len(grid)
elements = grid[0].size  # Number of elements, any index will do
flat = np.concatenate(grid).ravel()  # Flatten the whole meshgrid
grid = np.reshape(flat, (dim, elements)).T  # Reshape and transpose


for windparam in grid: 
    #generate runfile 
    runfile_params = {"local":local_rotevol,
                 "tracks": track_dir,
                 "output_dir": local_rotevol + master_output_dir,
                 "dat_file":fname_template.format(windparam[3]),
                 "track_file": "rotevolin_m1p05per8p0",
                 "numerics_out": "rotevolin_m1p05per8p0",
                 "rot_track_out": fname_template.format(windparam[3]),
                 "executable_name": rotevol_executable}

    
    runfile_name = "run_" + fname_template.format(windparam[3])
    
    #generate control file
    controlfile_params = {"INUMT":"1",
               "LSOLID":windparam[0],
               "IWIND":windparam[1],
               "FK":windparam[2],
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

    
    controlfile_name = fname_template.format(windparam[3]) + ".dat"
   
    gen_rotgrid.gen_runfile(runfile_params, runfile_name) #generates runfiles
    gen_rotgrid.gen_controlfile(controlfile_params, controlfile_name) #generates control files 
    
    os.system("make -f Makerotwind") #compiles rotevol 
    os.system("mkdir -p {0}".format(runfile_params["output_dir"]))
    
    os.system("./{0}".format(runfile_name)) #runs rotevol for the set of parameters given by windparam
