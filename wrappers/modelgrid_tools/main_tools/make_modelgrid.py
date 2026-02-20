''' Make Grid
This file contains the function make_MFeHgrid, which generates a grid of
input files for YREC at user-specified masses and [Fe/H]s.

This file also contains various helper functions.
Most notably, FeH_to_XYZ converts iron abundance to metal mass fractiom
for a star with solar alpha abundance.

Lists of metallicity and mass values (and their string versions)
are hard-coded at the end of the file. Feel free to take a look
and switch them if you're using different input tables or models


Example: Make a grid of masses from 0.5-1 Msun and [Fe/H] from -0.5 to 0 

# masses should only have 2 decimal places of precision 
# unless you modify make_MFeHgrid
masses = np.round(np.linspace(0.5,1,11),3) 
FeHs = np.linspace(-.5,0,3)

# relative or absolute path to the starting namelists
base_fpath = 'norotation_grid' # or '/home/sus/yrec_tools/norotation_grid/' 

# relative or absolute path to which yrec will write the models
yrec_writepath = 'output' # or '/home/sus/yrec_tools/norotation_grid/output'

# relative or absolute path to yrec input files
yrec_inputpath = '../../yrec/input" # or '/home/sus/yrec/input'

# the name of the starting namelists
# found in the base_fpath directory
base_fname 'GSnorot' 

nml_grid_filenames = make_MFeHgrid(masses,FeHs,base_fname=base_fname,base_fpath=base_fpath,
			yrec_writepath=yrec_writepath,yrec_inputpath=yrec_inputpath)


print(nml_grid_filenames[1][1])
out: 'norotation_grid/m055fehm025_GSnorot' 
# or absolute path '/home/sus/Masters/yrec_tools/norotation_grid/m055fehm025_GSnorot'

Now you have all the file names for your grid in object
'''

import numpy as np
import update_nml
from update_nml import update_namelists
from glob import glob


# helper function
def find_numrun(nml1_filename:str):
	''' Reads .nml1 file and returns the value of the NUMRUNS variable
		Parameter
		--------
		path : str
			absolute or relative path to the .nml1 file you're checking

	'''
	nml1_lines = update_nml.read_nml(nml1_filename)
	for line in nml1_lines:
		stripped = line.strip()
		if stripped[:6] == 'NUMRUN':
			n = stripped.split('=')[1]
			return int(n.split()[0])
	raise Exception(f'NUMRUN not declared in {nml1_filename}')

# helper function
def ENV0A_params(numrun:int,Xstr:str,Zstr:str):
	''' The changes to nml1 depend on the NUMRUN variable

		Parameters
		----------
		numrun : int
			The value of NUMRUN in the nml1 file you're modifying
		Xstr : string
			The value of X for your model
		Zstr : string
			The value of Z for your model
		
		Return
		------
			params : list(str)
				The parameters of nml1 that will set the envelope abundances
				(will take the form ['XENV0A(1)', 'ZENV0A(1)', etc])
			values : list(str)
				The values for the envelope abundances

	'''
	params = []
	values = [Xstr,Zstr] * numrun
	for i in range(numrun):
		params.append(f'XENV0A({i+1})')
		params.append(f'ZENV0A({i+1})')
	return params, values

def get_initialmodel_Zs(mass:float,yrec_inputpath:str):
	''' For a starting mass, get the accepted z values
	'''
	mass_idx = np.where(mass_options == mass)[0][0]
	mass = mass_stringoptions[mass_idx]
	lines = glob(f'{yrec_inputpath}/models/dbl/m{mass}*')
	zstrs = []
	zs = []
	for line in lines:
		zstr = line.split('z')[1].split('_')[0]
		zstrs.append(zstr)
		z_idx = np.where(Z_stringoptions == zstr)[0][0]
		zs.append(float(Z_options[z_idx]))
	return zs, zstrs

# helper function
def FeH_to_XYZ(FeH,Z_solar,X_solar,Yp=0.2482):
	""" Returns the H, He, and metal mass fraction. Assumes solar alpha enhancement.

		Parameters
		----------
		FeH : float
			Iron content of a star
		Yp : float (default = 0.2482) # Planck Collaboration 2020
			Primordial He abundance
		Z_solar : float
			Solar metal mass fraction
		X_solar : float
			Solar hydrogen mass fraction

		Return
		------
		X, Y, Z : float
			H, He, and metal mass fraction, respectively

		System of equations:
			1 = X + Y + Z
			Y = Yp + DelY/DelZ * Z # Yp is the primordial (BBN) He mass fraction
			FeH = log10(Z/X) - log10(Z_sol/X_sol)
		"""

	Y_solar = 1 - X_solar - Z_solar
	DelY_DelZ = (Y_solar - Yp) / Z_solar
	ZoX_solar = Z_solar/X_solar
	q = 10**FeH * ZoX_solar # define q to make the next line shorter

	Z = (1-Yp)/(1/q + DelY_DelZ + 1)

	Y = Yp + DelY_DelZ*Z

	X = 1 - Y - Z
	return X,Y,Z

# helper function
def filestr_to_num(s:str,sig_figs=3,ignore_sign=False):
	''' Converts a string to a floating point

		Parameters
		----------
		s : string
			A string of the form '(p/m)000'
		sig_figs : int (default = 3)
			Number of significant figures
		ignore_sign : bool (detault = False)
			If False, s[0] indicates whether the number is positive or negative
			If True, s is a positive number. Ex: filestr_to_num('300',ignore_sign=True) = 3.00
		Returns
		-------
		num : float
			A number with sig_figs digits. '''
	tol = 10**(sig_figs-1)

	if ignore_sign:
		try:
			float(s[0])
		except:
			print(f'{s} is not sign-independent')
		if len(s) > sig_figs:
			print('Too many digits in your string!')
		return float(s)/tol

	coef = 1 if s[0]=='p' else -1
	if len(s)-1 > sig_figs:
		raise Exception(f'{s} has too many digits. It should only have {sig_figs}')

	num = float(s[1:])/tol
	print(float(s[1:]),tol)
	return coef * num

# helper function
def num_to_filestr(z:float,sig_figs=3,ignore_sign=False):
	""" Convert a number to a string that can be used in the filename
		Parameters
		----------
		z : float
			[Fe/H] (or Z?) metallicity value, only works if abs(z) is between [10/sig_figs, 9.99,]

		sig_figs : int (default = 3)
			Set the number of significant figures in z

		ignore_sign : bool (default = False)
			If True, the returned string will not begin with 'p' or 'm' to signify the sign

		Returns
		----------
		zname : string
			Has the form "(p/m)000"
			Ex: z_to_filestr(-1.32) = 'm132'
			Ex: z_to_filestr(0.00) = 'm000' """
	# make sure that you don't have too many significant figures
	tol = 10**(sig_figs-1)
	if round(z,sig_figs-1) != z:
		prec = ''.join(['0' for i in range(sig_figs-1)])
		raise Exception(f'{z} has too many decimal places \nAccepted precision level: 0.{prec}')
	# make sure you fall within the acceptable bounds
	if abs(z) > 10:
		raise Exception(f'Error: Input {z} is not between (-10,10)')

	# pick the sign
	zname = "m"
	if z > 0:
		zname = 'p'
	z = abs(z)
	# convert to string (sorry this is complicated)
	tmp = str(round(int(tol*z)))
	
	while len(tmp) < sig_figs:
		tmp = '0' + tmp
	if ignore_sign:
		return tmp
	return zname + tmp

# helper function
def find_nearest(a:np.ndarray, value:float):
	''' Find the index of the element of a closest to value.
	If there are two equidistant elements of a, use the one with a lower index.
	I don't know why numpy doesn't already have this function built-in.  '''
	idx = np.argmin(abs(a-value))
	return idx

# the actual function!
def make_MFeHgrid(masses:np.ndarray, FeHs:np.ndarray, base_fname:str, base_fpath:str,
				yrec_writepath:str, yrec_inputpath:str,X_solar=0.735,Z_solar=0.017,Yp=0.2454):
	""" Creates a grid of YREC input files with the same base physical assumptions,
		but run at a range of masses and compositions

		Parameters
		----------
		masses : np.ndarray(float)
			List of masses (2 decimal places of precision) to make the grid for (units: Msolar)
			If you want to add more decimal places of precision, modify the sig_figs parameter
			of num_to_filestr
		FeHs : np.ndarray(float)
			List of [Fe/H] values you wish to make the grid for
		base_fname : string
			Name of the starting .nml1 and .nml2 files (base_fname.nml1 and base_fname.nml2)
			The namelists that result from this will have the form
			'm000feh(p/m)000{base_fname}.nml(1/2)'
			For example, the namelists for a model with a mass M = 1.13 and a
			metallicity [Fe/H] = -0.05 and base_fname = 'a14GSnorot' will be
			 'm113feh_m005_a14GSnorot.nml(1/2)'
		base_fpath : string
			Path to the initial .nml1 and .nml2 files. The grid of namelists will be written
			to the same location.  
		yrec_writepath : string
			Path to where YREC outputs will be stored (e.g. /home/myname/EVOLUTION/output/YRECgrid/nodiff )
			If using a relative path, make sure it starts from where you'll run yrec with the namelists
		yrec_inputpath : string
			Path to where the input files for YREC are located (e.g. /home/myname/yrec/input)
			If using a relative path, make sure it starts from where you'll run yrec with the namelists
		X_solar : float (default = 0.735)
			Solar X value. The default is 0.735 from Grevesse & Sauval 1998.
		Z_solar : float (default = 0.017)
			Solar Z value. The default is 0.017 from Grevesse & Sauval 1998.
		Yp : float (default = 0.2454)
			Primordial He abundance. The default is from the Planck 2018 results.
			
		Return
		------
		nmls_list : list(list(string))
		 	2d list with shape (len(masses),len(FeHs)) that contains the nml filenames
			E.g. if masses[0] = 1 and FeHs[0] = -.25
				nmls_list[0][0] = base_fpath + 'm100fehm025_' + base_fname
			If you have a version of numpy that supports variable-length strings, 
			you can convert this output to an array to make indexing easier
		 """

	# output an array of the resulting base nml names (index by mass and FeH)
	nmls_list = []
	for i in range(len(masses)):
		# find the nearest mass_options value to masses[i] (used for determining the input file)
		mnum = find_nearest(mass_options, masses[i])
		if masses[i] < mass_options[mnum]:
			# as of 2013, it is easier/more reliable to rescale up than down
			mnum = mnum - 1 if mnum != 0 else mnum
		m_Ffirst = mass_stringoptions[mnum]
		Zoptions, Zstr_options = get_initialmodel_Zs(mass_options[mnum],yrec_inputpath)

		mass_str = num_to_filestr(masses[i],sig_figs=3,ignore_sign=True) # string version of mass, used for naming files
		if masses[i] > 10: # num to filestr only works for inputs less than 10
			mass_str = num_to_filestr(masses[i]/10,sig_figs=4,ignore_sign=True)
		
		# set up the element of nmls that will be populated by file names
		nmls_list.append([])


		for j in range(len(FeHs)):
			FeH_str = num_to_filestr(FeHs[j])

			# get Z, X from FeH. If you are running an alpha enhanced grid, this will not work!
			X,Y,Z = FeH_to_XYZ(FeHs[j],Z_solar,X_solar,Yp)

			Xstr = str(X).strip()[:9] # only need 9 digits of information
			Zstr = str(Z).strip()[:9] # only need 9 digits of information

			# pick the nearest opacity table to match FeHs[j]
			opbase = yrec_inputpath + '/eos/opal2006/EOSOPAL06Z0'
			opnum = find_nearest(opaloptions, Z)
			opname = f'"{opbase}{opalstr[opnum]}"'

			# pick the nearest atmosphere table to match FeHs[j]
			atmbase = yrec_inputpath +'/atmos/kurucz/atmk1990'
			# if you change to using Allard atmosphere tables, you'll need to change atmoptions and atmbase
			atmnum = find_nearest(atmoptions,FeHs[j])
			atmname = f'"{atmbase}{atmstr[atmnum]}.tab"'

			# change all output file names to have the form 'm0000feh000_{base_fname}'
			output_file_ends = [".last",".full",".store",".track",".short",".pmod",".penv ",".atm ",".snu",".excomp"]
			output_file_params = ["FLAST","FMODPT","FSTOR","FTRACK","FSHORT","FPMOD","FPENV","FPATM ","FSNU","FSCOMP"]
			Fname = yrec_writepath + '/m' + mass_str + 'feh' + FeH_str + "_" + base_fname  # name of the output
			output_filenames = [f'"{Fname}{f_end}"' for f_end in output_file_ends]

			# these are inputs that are not being modifed
			# but they need to have the correct path leading to them
			input_filenames = [f'"{yrec_inputpath}{i}"' for i in yrec_inputpath_vals]

			# find the nearest zoptions value to Z
			Z_idx = find_nearest(Zoptions, Z)
			Z_Ffirst = Zstr_options[Z_idx]

			# Ffirst is the starting model. I recommend starting with the dbl (deuterium birthline) models
			Ffirst = f'"{yrec_inputpath}/models/dbl/m{m_Ffirst}gs98z{Z_Ffirst}_Dbl.first"'

			
			nml_base = base_fpath + "/" + base_fname
			new_nml_name = base_fpath + '/m' + mass_str + 'feh' + FeH_str +"_" + base_fname
			
			# set envelope abundance labels - the number of parameters that need to be changed 
			# depends on the value of NUMRUN
			numrun = find_numrun(nml_base+'.nml1') 
			ENV0A = ENV0A_params(numrun,Xstr,Zstr) 

			params = ['RSCLM(1)','RSCLX(1)','RSCLZ(1)','ZOPAL951','FFIRST','FOPALE06','FATM'] \
				+ output_file_params + yrec_inputpath_params + ENV0A[0]
			values = [masses[i], Xstr, Zstr, Zstr, Ffirst, opname, atmname] \
				+ output_filenames + input_filenames + ENV0A[1]

			changes_dict = dict(zip(params, values))

			

			info = update_namelists(f'{nml_base}.nml1',f'{nml_base}.nml2', new_nml_name, changes_dict, verbose=False)
			nmls_list[i].append(info['output_files'][0][:-5]) # don't keep .nml1 suffix
			
			# we'll want to track if there are problems with assigning variable names 
			problems = set(info['missing_params'])
			if problems == set(['ZENV0A(3)','XENV0A(3)']):
				continue
			elif problems != set():
				raise Exception(f'Problem with parameters: \n{problems} \ncould not be changed')

	return nmls_list

opalstr = ['.002632875','.021444000','.020000000','.029000000','.002674883','.018664570',
			'.007734637','.003444000','.001714251','.031490336','.046300423','.010369920',
			'.016467650','.002747177','.044373926','.012000000','.002602589','.023444000',
			'.018256818','.016000000','.018338000','.014760018','.010000000','.018630590',
			'.043276547','.018000000','.001941304','.016492','.001718041','.017000000',
			'.030000000','.023000000','.027000000','.001185001','.009000000','.039602600',
			'.001039811','.018338378','.018407800','.019444000','.002714609','.005444000',
			'.028000000','.001689992','.000054449','.018776','.018298713','.021000000',
			'.000543784','.006577536','.045081929','.001236447','.003098193','.004694806',
			'.001931311','.018298972','.029098996','.001171370','.118215775','.077050371',
			'.017007107','.060131645','.041321892','.018334365','.001939065','.004116123',
			'.067127050','.018127060','.008000000','.060831381','.043362634','.002000000',
			'.001735667','.001854732','.001444000','.016465591','.022337799','.001000000',
			'.020727145','.020623244','.029444000','.002606204','.038804833','.011444000',
			'.003016661','.004344797','.025906047','.001203908','.01757','.005368163',
			'.043318144','.025000000','.006501875','.001876315','.003037668','.001646600',
			'.025499197','.001644316','.004769713','.061801969','.001096056','.004164021',
			'.001688526','.000017220','.090863722','.016559552','.004121840','.003000000',
			'.001038368','.015444000','.043297159','.038881687','.043863498','.006682483',
			'.018804','.001663451','.013200081','.046300359','.001957773','.017444000',
			'.038266667','.019000000','.021840707','.001936972','.021196113','.016299487',
			'.021393150','.043888364','.007412820','.022000000','.011544666','.002714746',
			'.006863090','.020166951','.004898624','.007000000','.009444000','.001951151',
			'.004230460','.015000000','.040000000','.068991690','.025444000','.010264873',
			'.000965916','.010535376','.043863559','.025450839','.043373164','.004640802',
			'.005000000','.006733295','.011000000','.003061610','.002969285','.026000000',
			'.045081991','.001941834','.007531094','.013444000','.047584367','.060000000',
			'.600000000','.039147056','.002935130','.016111996','.031000000','.014000000',
			'.001906252','.020500932','.028642003','.004000000','.001050452','.029885456',
			'.011865351','.012186036','.043163970','.011679008','.010250636','.025205883',
			'.007327551','.000305985','.013000000','.070856330','.028312537','.000172129',
			'.027444000','.031444000','.006000000','.024000000','.008437702','.067908189',
			'.019134119','.010561242','.001967802','.007444000','.026606210','.043558181',
			'.001937326','.010820115','.040234474','.016465295','.021880056','.001067212',
			'.063472292','.018596758']

opaloptions = [0.002632875, 0.021444, 0.02, 0.029, 0.002674883, 0.01866457, 0.007734637,
			 0.003444, 0.001714251, 0.031490336, 0.046300423, 0.01036992, 0.01646765,
			 0.002747177, 0.044373926, 0.012, 0.002602589, 0.023444, 0.018256818, 0.016,
			 0.018338, 0.014760018, 0.01, 0.01863059, 0.043276547, 0.018, 0.001941304,
			 0.016492, 0.001718041, 0.017, 0.03, 0.023, 0.027, 0.001185001, 0.009, 0.0396026,
			 0.001039811, 0.018338378, 0.0184078, 0.019444, 0.002714609, 0.005444, 0.028,
			 0.001689992, 5.4449e-05, 0.018776, 0.018298713, 0.021, 0.000543784, 0.006577536,
			 0.045081929, 0.001236447, 0.003098193, 0.004694806, 0.001931311, 0.018298972,
			 0.029098996, 0.00117137, 0.118215775, 0.077050371, 0.017007107, 0.060131645,
			 0.041321892, 0.018334365, 0.001939065, 0.004116123, 0.06712705, 0.01812706, 0.008,
			 0.060831381, 0.043362634, 0.002, 0.001735667, 0.001854732, 0.001444, 0.016465591,
			 0.022337799, 0.001, 0.020727145, 0.020623244, 0.029444, 0.002606204, 0.038804833,
			 0.011444, 0.003016661, 0.004344797, 0.025906047, 0.001203908, 0.01757, 0.005368163,
			 0.043318144, 0.025, 0.006501875, 0.001876315, 0.003037668, 0.0016466, 0.025499197,
			 0.001644316, 0.004769713, 0.061801969, 0.001096056, 0.004164021, 0.001688526, 1.722e-05,
			 0.090863722, 0.016559552, 0.00412184, 0.003, 0.001038368, 0.015444, 0.043297159,
			 0.038881687, 0.043863498, 0.006682483, 0.018804, 0.001663451, 0.013200081, 0.046300359,
			 0.001957773, 0.017444, 0.038266667, 0.019, 0.021840707, 0.001936972, 0.021196113,
			 0.016299487, 0.02139315, 0.043888364, 0.00741282, 0.022, 0.011544666, 0.002714746,
			 0.00686309, 0.020166951, 0.004898624, 0.007, 0.009444, 0.001951151, 0.00423046, 0.015,
			 0.04, 0.06899169, 0.025444, 0.010264873, 0.000965916, 0.010535376, 0.043863559,
			 0.025450839, 0.043373164, 0.004640802, 0.005, 0.006733295, 0.011, 0.00306161,
			 0.002969285, 0.026, 0.045081991, 0.001941834, 0.007531094, 0.013444, 0.047584367,
			 0.06, 0.6, 0.039147056, 0.00293513, 0.016111996, 0.031, 0.014, 0.001906252, 0.020500932,
			 0.028642003, 0.004, 0.001050452, 0.029885456, 0.011865351, 0.012186036, 0.04316397,
			 0.011679008, 0.010250636, 0.025205883, 0.007327551, 0.000305985, 0.013, 0.07085633,
			 0.028312537, 0.000172129, 0.027444, 0.031444, 0.006, 0.024, 0.008437702, 0.067908189,
			 0.019134119, 0.010561242, 0.001967802, 0.007444, 0.02660621, 0.043558181, 0.001937326,
			 0.010820115, 0.040234474, 0.016465295, 0.021880056, 0.001067212, 0.063472292, 0.018596758]

# starting mass options in yrec/input/model/dbl
mass_options = np.array([0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1,
				0.15, 0.2, 0.3, 0.4,0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
				1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8,1.9, 2.0,
				2.2, 2.4, 2.6, 2.8, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5,
				6.0, 6.5,7.0, 7.5, 8.0, 8.5, 9.0, 10.0, 12.0, 14.0,
				16.0, 18.0, 20.0, 22.5, 25.0])
mass_stringoptions = ['0030', '0040', '0050', '0060', '0070', '0080', '0090', '0100',
		'0150', '0200', '0300', '0400','0500', '0600', '0700', '0800', '0900', '1000',
		'1100', '1200', '1300', '1400', '1500', '1600', '1700', '1800','1900', '2000',
		'2200', '2400', '2600', '2800', '3000', '3500', '4000', '4500', '5000', '5500',
		'6000', '6500','7000', '7500', '8000', '8500', '9000', '10000', '12000', '14000',
		'16000', '18000', '20000', '22500', '25000']

# starting Z options in yrec/input/model/dbl
Z_options = np.array([0.001, 0.003, 0.01, 0.018804, 0.04, 0.06])
Z_stringoptions = np.array(['001000', '003000', '010000', '018804', '040000', '060000'])


# atmosphere FeH values from Kurucz
atmoptions = [-5.0,-4.5,-4.0,-3.5,-3.3,-3.0,-2.5,-2.3,-2.0,-1.75,-1.7,-1.5,-1.3,
			  -1.25,-1,-.75,-.5,-.4,-.3,-.2,-.1,-.05, 0.0, 0.05, 0.1, 0.12,
			  0.13, 0.14, 0.15, 0.2, 0.3, 0.4, 0.5, 0.75, 1.0 ]
# str versions of atmosphere values from Kurucz
atmstr = [ 'm50', 'm45','m40', 'm35','m33','m30','m25','m23','m20','m175','m17','m15',
		'm13','m125','m10','m075','m05','m04','m03','m02','m01','m005','p00','p005',
		'p01','p012','p013', 'p014','p015','p02','p03','p04','p05','p075','p10' ]

# atmosphere FeH values from Allard
# atmoptions = [-4,-3.5,-3,-2,-1.5,-1.3,-1,-0.5,0]

# parameters that need to have the correct inputpath
yrec_inputpath_params = ["FcondOpacP", "FALLARD", 
						 "FSCVH", "FSCVHE",
						  "FSCVZ", "FFERMI",
						  "FPUREZ","FLIV95",
						  "FALEX06"]

# values of parameters that need to have the correct inputpath
yrec_inputpath_vals = ["/opacity/potekhin/condall06.d","/atmos/allard/Nextgen2.all",
						"/eos/scv/h_tab_i.dat","/eos/scv/he_tab_i.dat",
						"/eos/scv/z_tab_i.dat","/eos/yale/FERMI.TAB",
						"/opacity/lanl/PURECO.DBGLAOL","/opacity/opal95/GS98.OP17",
						"/opacity/alex06/alexmol06gs98.tab"]
