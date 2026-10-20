'''
read_output_files.py

This file contains functions to read .track, .last, and .store outputs
from a YREC run into Pandas dataframes

read_track_table here is an alternative to the eponmous function in load_yrec_tracks.py
We recommend using load_yrec_tracks due to its extra capabilities
(such as reading multiple .track files at once and sorting the outputs)
but we have kept read_track_table as an option.
'''
import re
import pandas as pd
from astropy.io import ascii
import numpy as np


# 10/20/26 MHP via Claude: values are now converted one at a time by
# fortran_float, and anything unreadable raises. Previously a failed
# conversion set the whole column to 0, so one bad value -- or the
# 1.234-100 form below -- silently zeroed every row of that column.
_FORTRAN_EXP = re.compile(r'([+-]?(?:\d+\.?\d*|\.\d+))([+-]\d{3,})$')


def fortran_float(token, where=''):
	''' Convert one numeric token from a YREC output file to float.

		Fortran E formatting drops the E when the exponent needs three
		digits, so 1.234E-100 is written as 1.234-100. Python cannot read
		that form, so it is converted here. Any other token that is not a
		number raises ValueError, naming where it came from.
	'''
	try:
		return float(token)
	except ValueError:
		m = _FORTRAN_EXP.match(token)
		if m:
			return float(m.group(1) + 'E' + m.group(2))
		raise ValueError(f'cannot read {token!r} as a number{where}') from None


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
	# 10/20/26 MHP via Claude: column names now come from the file's own
	# header line and each row is split on whitespace, as read_store_file
	# already does. The fixed column positions that used to be listed here
	# had drifted from the format YREC writes: they cut every column after
	# Age_gyr one character off, and since a failed conversion zeroed the
	# column, 71 of 83 columns read as 0. Every row of all 301 reference
	# tracks splits into exactly as many fields as the header names. A row
	# that does not, or a value that cannot be read, now raises ValueError.
	with open(fname, 'r') as fh:
		lines = fh.read().split('\n')
	start = next((i for i, line in enumerate(lines)
	              if line.split()[:1] == ['Step']), None)
	if start is None:
		raise ValueError(f'{fname}: no "Step ..." header line found')
	names = lines[start].split()
	rows = []
	for n, line in enumerate(lines[start + 1:], start=start + 2):
		if not line.strip() or line.startswith('#'):
			continue
		tokens = line.split()
		if len(tokens) != len(names):
			raise ValueError(f'{fname}, line {n}: {len(tokens)} fields, '
			                 f'but the header names {len(names)}')
		rows.append([fortran_float(t, f' ({fname}, line {n}, column {c})')
		             for t, c in zip(tokens, names)])
	return pd.DataFrame(rows, columns=names)



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
		values = [str(v).strip() for v in last[k]]
		if values and all(v in ('T', 'F') for v in values):
			last[k] = [v == 'T' for v in values]
		else:
			last[k] = [fortran_float(v, f' ({fname}, column {k})')
			           for v in values]
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
	# 10/9/26 MHP via Claude: column names are now read from each model's
	# own header line in the file, instead of a hardcoded list here. YREC
	# writes .store in one of two formats depending on the run's LSTCH
	# namelist setting: the legacy format (header starts 'SHELL ...') or
	# the newer STITCH format (header starts 'MODEL SHELL ...', with
	# extra CONVECTIVE/INTERIOR_PT/ENV_PT/ATM_PT/TRIPLE_ALPHA/CP/
	# DLNRHODLNT columns). A hardcoded list only ever matched the legacy
	# format and silently misread the other; reading the header directly
	# handles both, and any future column YREC adds, without needing this
	# file updated to match. One known quirk: the legacy format's own
	# header was never updated when putstore.f started prepending a
	# MODEL value to every data row, so its header is one column short --
	# detected below and compensated for.
	boolean_cols = {'C', 'CONVECTIVE', 'INTERIOR_PT', 'ENV_PT', 'ATM_PT'}

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
		tokens = line.split()
		if tokens[:2] == ['MODEL', 'SHELL']:
			# STITCH format: header already labels every column, MODEL included
			names = tokens
			i += 1
			flag = True
			models.append(pd.DataFrame(columns=names))
			continue
		if tokens[:1] == ['SHELL']:
			# legacy format: header is missing the MODEL label that
			# putstore.f's FORMAT 62 nonetheless prepends to every row
			names = ['MODEL'] + tokens
			i += 1
			flag = True
			models.append(pd.DataFrame(columns=names))
			continue
		if i > -1 and line != '' and flag:
			# print(line.split())
			models[i].loc[len(models[i])] = tokens

	file.close()

	# processing to turn things into floats
	for model in models:
		for k in model.columns:
			if k in boolean_cols:
				model[k] = [shell == "T" for shell in model[k]]
			else:
				model[k] = [fortran_float(v, f' ({fname}, column {k})')
				            for v in model[k]]
	
	return models, np.array(model_ages)
