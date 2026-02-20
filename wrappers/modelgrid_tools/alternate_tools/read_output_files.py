'''
read_output_files.py

This file contains functions to read .track, .last, and .store outputs
from a YREC run into Pandas dataframes

read_track_table here is an alternative to the eponmous function in load_yrec_tracks.py
We recommend using load_yrec_tracks due to its extra capabilities
(such as reading multiple .track files at once and sorting the outputs)
but we have kept read_track_table as an option.
'''
import pandas as pd
from astropy.io import ascii
import numpy as np


def read_track_table(fname):
	''' Read YREC .track output into a Pandas dataframe
	
		Parameters
		---------
		fname :  str
			File that you want to read. Should be a .track file output from YREC
	
		Returns
		-------
		track : pandas DataFrame
			Table of the parameters of a star's evolution at all timesteps of the YREC run
	'''
	track=ascii.read(fname, format="fixed_width_no_header",
		names=('Step', 'Shls', 'Age_gyr', 'LogL_lsun', 'LogR_rsun', 'Log_g', 'log_Teff', 'Mco_core', 'Mco_env', 'Rco_env',
		'Tco_env', 'Dco_env', 'Pco_env', 'Oco_env', 'LogT_cen', 'LogD_cen', 'logP_cen', 'Beta_cen', 'Eta_cen', 'X_cen',
		'Y_cen', 'Z_cen', 'ppI_lsun', 'ppII_lsun', 'ppIII_lsun', 'CNO_lsun', '3a_lsun', 'HeC_lsun', 'Egrav_lsun',
		'Neut_lsun', 'Cl_snu', 'Ga_snu', 'pp_neut', 'pep_neut', 'hep_neut', 'Be7_neut', 'B8_neut', 'N13_neut', 'O15_neut',
		'F17_neut', 'diag1', 'diag2', 'He3_cen', 'C12_cen', 'C13_cen', 'N14_cen', 'N15_cen', 'O16_cen', 'O17_cen', 'O18_cen',
		'He3_sur', 'C12_sur', 'C13_sur', 'N14_sur', 'N15_sur', 'O16_sur', 'O17_sur', 'O18_sur', ' H2_sur', 'Li6_sur',
		'Li7_sur', 'Be9_sur', 'X_sur', 'Y_sur', 'Z_sur', 'Z_X_sur', 'Jtot', 'KE_rot_tot', 'I_tot', 'I_cz', 'Omega_sur',
		'Omega_cen', 'Prot_sur_d', 'Vrot_kms', 'TauCZ_s', 'MHshell_base', 'MHshell_mid', 'MHshell_top', 'RHshell_base',
		'RHShell_mid', 'RHshell_top', 'logP_phot', 'Mass_msun'),
		col_starts=[0, 9, 17, 33, 50, 65, 81, 98, 113, 129, 141, 153, 165, 177, 189, 205, 
		221, 237, 253, 269, 285, 301, 317, 333, 349, 365, 381, 397, 413, 429, 445, 
		455, 465, 475, 485, 495, 505, 515, 525, 535, 545, 555, 565, 581, 597, 613, 
		629, 645, 661, 677, 693, 709, 725, 741, 757, 773, 789, 805, 821, 837, 853,
		869, 885, 901, 917, 933, 949, 965, 981, 997, 1013, 1029, 1045, 1061, 1077,
		1094, 1109, 1125, 1141, 1157, 1173, 1189, 1205] )
	track = track.to_pandas()
	track = track.drop(0).reset_index(drop=True)
	for k in track.columns:
		try:
			track[k] = track[k].astype(float)
		except: # errors arise once X_cen gets below 1e-99
			track[k]  = 0 # but that's basically 0
	return track

def read_last_file(fname): 
	''' Read YREC .last output into a Pandas dataframe.
	
		Parameters
		---------
		fname :  str
			File that you want to read. Should be a .track file output from YREC
	
		Returns
		-------
		last : pandas DataFrame
			The parameters of a star's structure in the final timestep of the YREC run
	'''
	names = ['SHELL','MASS','RADIUS','LUMINOSITY','PRESSURE','TEMPERATURE','DENSITY','OMEGA','C','H1',
	         'He4','METALS','He3','C12','C13','N14','N15','O16','O17','O18','H2','Li6','Li7','Be9']
	cols = [0,7,24,42,66,84,102,120,144,146,158,170,182,198,214,230,246,262,278,
	        294,310,326,342,358]
	last = ascii.read(fname, format="fixed_width_no_header", data_start=6,
		names=names, col_starts=cols )
	last = last.to_pandas()
	last = last.drop(0).reset_index(drop=True)
	for k in last.columns:
		try:
			last[k] = last[k].astype(float)
		except:
			last[k] = [shell == "T" for shell in last[k]]
	return last

def read_store_file(fname): 
	''' Returns a list of dataframes, one for each model stored in .store
	
	    Parameters
		---------
		fname :  str
			File that you want to read. Should be a .store file output from YREC
	
		Returns
		-------
		models : list of pandas DataFrames
			The parameters of a star's structure in the final timestep of the YREC run
		model_ages : array of floats
            Ages (in Gyr) corresponding to each model in the models list.
	
	'''
	model_nums = [] # this isn't currently used for anything. 
	model_ages = [] # Gyr
	models = [] # list of dataframes
	names =['SHELL','MASS','RADIUS','LUMINOSITY','PRESSURE','TEMPERATURE','DENSITY','OMEGA',
	 'C','H1','He4','METALS','He3','C12','C13','N14','N15','O16','O17','O18','H2','Li6',
	 'Li7','Be9','OPAC','GRAV','DELR','DEL','DELA','V_CONV','GAM1','HII','HEII','HEIII',
	 'BETA','ETA','PPI','PPII','PPIII','CNO','3HE','E_NUC','E_NEU','E_GRAV','A','RP/RE',
	 'FP','FT','J/M','MOMENT','DEL_KE','V_ES','V_GSF','V_SS','VTOT'] # dataframe column names
	
	file = open(fname, "r")
	i = -1
	flag = False # True while on a line that goes into the current dataframe
	for line in file:
		line = line.strip()
		if line[:4] == 'MOD2':
			model_nums.append(int(line.split()[1])) # get the model number
			model_ages.append(float(line[87:102])) # get the age (Gyr)
			flag = False
			continue
		if line[:5] == 'SHELL':
			i +=1
			flag = True
			models.append(pd.DataFrame(columns=names))
			continue
		if i > -1 and line.strip() != '' and flag:
			# print(line.split())
			models[i].loc[len(models[i])] = line.split()
		
	file.close()

	# processing to turn things into floats
	for model in models:
		for k in model.columns:
			if k == 'C':
				model[k] = [shell == "T" for shell in model[k]]
			else:
				try: 
					model[k] = model[k].astype(float)
				except: # cannot read numbers less than 1e-99
					model[k] = 0 # but that's basically 0 anyway
	
	return models, np.array(model_ages)
