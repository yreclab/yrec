'''
A script to run a grid of yrec models

There are 2 versions within this file.

Version 1 assumes that you have not already created the grid.
To use it, change the masses and FeHs arrays
and modify the parameters of make_MFeHgrid to match your file structure.
Then run this file from the command line.

Version 2
If you've already created the grid (or some other method),
comment out Version 1 and uncomment Version 2.
path_to_nmlfiles is the directory where your grid's nml files
are stored (you should not have other grids in this directory).
Change this and run from the command line.
'''

import os
import numpy as np
from make_modelgrid import make_MFeHgrid
from glob import glob

yrecpath = '/home/sus/Masters/yrec/src/yrec' # user TODO: change this to match the path to your yrec executable

''' Version 1: Make grid and run it '''

# set the masses and FeHs you want
masses = np.array([0.5,.6,1,2.5])
FeHs = np.array([-.5,0,.5])

base_fpath = '/home/sus/Masters/yrec_tools/test_mFeHgrid_sus' # user TODO: change this to where your namelists are stored

nml_names = make_MFeHgrid(masses,FeHs,base_fname='test_sus',
            base_fpath=base_fpath,
            yrec_writepath='/home/sus/Masters/yrec_tools/test_mFeHgrid_sus/output',
            yrec_inputpath='/home/sus/Masters/yrec/input')

nml_names = np.reshape(nml_names,-1) # flatten the array

# run the grid
os.chdir(base_fpath)
for filename in nml_names:
    os.system(f'{yrecpath} {filename}.nml1 {filename}.nml2')

''' Version 2: Run pre-existing grid '''

# path_to_nmlfiles = 'test_mFeHgrid_sus'
# os.chdir(path_to_nmlfiles) # note: you should have only the files you want to run in this directory
# nml_names = glob(f'm*.nml1')
# nml_names = np.array([name[:-5] for name in nml_names])

# run the grid
# for filename in nml_names:
#     os.system(f'{yrecpath} {filename}.nml1 {filename}.nml2')
