# python wrapper that can be used to calibrate a standard solar model using YREC

# This script generates namelists and runs a YREC model
# It is executed in directory yrec/explore/master/ which includes template.yml and yml.py
# from Lyra - see https://bitbucket.org/rrlyrae/yrecml/src/master/

# Calculates new values for relevant parameters
# Copies the old namelists and replaces parameters with the new values
# Runs new YREC models
# And repeats, checking if the solar models are within specified tolerance of solar values
# until success or a maximum number of iterations 

# calibrates: Solar rotation period
#             Surface Z/X
#             Surface Li
#             Solar Luminosity (using methodology from chkcal.f)
#             Solar Radius (using methodology from chkcal.f)
#             Rotation rate at 10 Myr (potential issue with fastest rotators not spinning up enough)


# before each run:

# edit template.yml as desired
# should generate 5 tracks from fastest to
# slowest rotator (90th, 75th, 50th, 25th, and 10th percentile of rotation)

# in this file,
# change date on new_namelist (around L106) (can ctrl+s '2023' or last used year)
#                new_namelist (L202)
# change         constants (L47 and on)
#                namelist_path to directory where you want to store namelists
#                output_path to directory for the trackfiles
# make sure starting values match template (old_CMIXLA, FK, FC, etc.)



############# CHANGES ###############

# 3/26/23 CMB
# Added additional comments to improve readability

# 9/22/23 CMB
# added in calibration of radius and luminosity
# run models with LCALS = FALSE
# should speed up calibration quite a bit
# by reducing total number of runs
# could also break my plots...
# simplest solution is to pick the final two runs and
# combine them together into an output file if needed

# 9/8/23 CMB
# fails to reproduce rapid rotators, trying the following:
# changing calibration from TDISK to PDISK and setting
# disk locking time to 0

# 8/4/23 CMB
# adding in calibration of surface Lithium via
# efficiency of mixing, FC in nml2

# 2/2/23 CMB
# changing so that the tracks go beyond solar calibration
# of 4.568 Gyr (was causing jumps in Luminosity
# due to changing the size of the timestep)
# np.interp(sol_age, ...) where applicable

# have to change file output paths in namelists!

# 1/19/23 CMB
# having trouble reading/replacing fk so working on that

# 11/14/22-11/17/22 CMB
# outline of code to run initial set of models and then do calibration


import yml
import numpy as np
import shutil
import fileinput
import sys


def replaceAll(file, searchExp, replaceExp):
    for line in fileinput.input(file, inplace=1):
        if searchExp in line:
            line = line.replace(line, replaceExp)
        sys.stdout.write(line)

        
########## SOME (STARTING) CONSTANTS ##########

# age of sun
sol_age = 4.568 #Gyr
# check rotation period (changed by fk), TDISK, and Z/X (changed by ZINIT)
sol_rot_period = 25.4 #days
# pre-determined partial derivatives from chkcal.f
DLDX = -3.78		# empirical result:  -3.783    RMS error .070
DRDX = -0.89 		# empirical result:  -0.890    RMS error .048
DLDA = 0.0139		# empirical result:  +0.139    RMS error .0022
DRDA = -0.050		# empirical result:  -0.0504   RMS error .0059

# probably better to read mixing length and
# X from trackfile, but I'm feeling lazy
# starting mixing length
old_CMIXLA = 1.91081247
# starting X
old_XENV0A = 7.10664867e-01

# Z/X for abundance mixture (Magg22 Met .0226 / Magg22 Phot .0225 /
#                           (GS98 .0231 / AAG21 .0187)
ZX_mixture = 0.0226

# starting Tdisk for plots
oldTdisk = np.array([0.0004651,0.001389,0.002651,0.006569,0.01])
oldPdisk = np.array([4.46171e-06,2.21952e-06,1.46512e-06,7.27441e-07,4.75655e-07])
# angular velocity at 10 Myr (from Upper Sco data)
w10 = np.array([4.78057e-05,2.38355e-05,1.57169e-05,7.78109e-06,5.07552e-06])
# angular velocity at Tdisk (initialize rotation at this rate)
w0 = 5.07552e-6
# starting FC value
FC = 0.98

# measured solar Lithium abundance
# from AAG21 (which is from Wang et al. 2021)
# because M22 doesn't include Lithium
Li_measured = 0.96

# starting FK value
FK = 6.80

# calibration tolerances 
calibration_tol = 1e-3
TOLL = 5.0e-6
TOLR = 5.0e-6

# max number of iterations
max_iter = 10



######### BEGIN WITH RUNNING A SET OF MODELS #############

# run initial models via Lyra's code
namelist_locations = yml.parse('template.yml')
yml.run_parallel(namelist_locations, pool_size = 20, command = "../../model5.0")

# intialize some empty lists
# if one or more of the models succeed (e.g. 90th percentile)
# a new list with the remaining rotation rates will be used
# for future runs (e.g. 75th, 50th, 25th, 10th)
new_CMIXLA = []
new_XENV0A = []
new_w10 = []
new_namelist_locations = []
new_FC = []
new_FK = []
new_Tdisk = []
new_Pdisk = []
print('Checking calibration')
print('Tolerance =', calibration_tol)
print('TOLL =', TOLL)
print('TOLR =', TOLR)
print('--------------------')
namelist_path = '/home/basinger.101/yrec/nml/'
output_path = '/home/basinger.101/yrec/FinalModels/standard_model/'
output_locations = []
for i in range(len(namelist_locations)):
  output_locations.append(output_path+namelist_locations[i][28:]+'.track')

for i in range(len(namelist_locations)):

  # read in file
  age_tracks, logL, logR, Li_surf, Z_surf, ZX_surf, I_tot, I_cz, w_env, Prot = np.genfromtxt(output_locations[i], usecols=(2,3,4,60,64,65,68,69,70,72), unpack=True)
  age = age_tracks
  Li_surf = np.log10(Li_surf/Li_surf[0])+3.31
  #I0 = w10 * np.interp(0.01,age,I_cz) / w0
  
  # check calibration
  if np.abs((np.interp(sol_age,age,Prot)-sol_rot_period)/sol_rot_period) < calibration_tol and\
     np.abs((np.interp(sol_age,age,ZX_surf)-ZX_mixture)/ZX_mixture) < calibration_tol and\
     np.abs((np.interp(sol_age,age,Li_surf)-Li_measured)/Li_measured) < 5e-3 and\
     np.abs(np.interp(sol_age,age,logL)) < TOLL and\
     np.abs(np.interp(sol_age,age,logR)) < TOLR and\
     np.abs((np.interp(0.01,age,w_env)-w10[i])/w10[i]) < calibration_tol:
    print(output_locations[i],'complete')
    continue
  
  # create new nml and change nml values if necessary
  else:
    
    print('filename:',output_locations[i])
    print('--------------------')
    print('diff logL {:.3g}'.format(np.abs(np.interp(sol_age,age,logL))))
    print('diff logR {:.3g}'.format(np.abs(np.interp(sol_age,age,logR))))
    print('fractional diff Prot {:.3g}'.format(np.abs((np.interp(sol_age,age,Prot)-sol_rot_period)/sol_rot_period)))
    print('fractional diff ZX_surf {:.3g}'.format(np.abs((np.interp(sol_age,age,ZX_surf)-ZX_mixture)/ZX_mixture)))
    print('fractional diff Li_surf {:.3g}'.format(np.abs((np.interp(sol_age,age,Li_surf)-Li_measured)/Li_measured)))
    print('fractional diff w10 {:.3g}'.format(np.abs((np.interp(0.01,age,w_env)-w10[i])/w10[i])))
    print('--------------------')

    # calculate new CMIXLA and XENV0A
    DA = ((logL[-1]*DRDX/DLDX-logR[-1])/(DRDA-DLDA*DRDX/DLDX))
    DX = -(logL[-1] + DLDA*DA)/DLDX
    CMIXLA = old_CMIXLA + DA
    XENV0A = old_XENV0A + DX

    print('new CMIXLA {:.9g} DA {:.9g}'.format(CMIXLA, DA))
    print('new XENV0A {:.9g} DX {:.9g}'.format(XENV0A, DX))

    # calculate new Tdisk
    #I0 = w10[i] * np.interp(0.01,age,I_cz) / w0
    #Tdisk = np.interp(I0,[I_cz[np.where(I_cz<=I0)[0][0]],I_cz[np.where(I_cz<=I0)[0][0]-1]],[age[np.where(I_cz<=I0)[0][0]],age[np.where(I_cz<=I0)[0][0]-1]])
    #Tdisk = oldTdisk[i]*(np.interp(0.01,age,w_env)/w10[i])

    # calculate new Pdisk
    #Pdisk = w10[i]*np.interp(0.01,age,I_cz)/np.interp(0.0005,age,I_cz)
    Pdisk = oldPdisk[i]*(w10[i]/np.interp(0.01,age,w_env))
    print('new PDISK {:.6g}'.format(Pdisk))
    
    # calculate new Z
    newZ = Z_surf[0]*(ZX_mixture/np.interp(sol_age,age,ZX_surf))
    print('new ZENV0A {:.5g}'.format(newZ))
    
    # calculate new FC
    newFC = np.max([0.05,FC*(np.interp(sol_age,age,Li_surf)/Li_measured)])
    print('new FC {:.3g}'.format(newFC))
    
    # calculate new FK
    newFK = FK*(sol_rot_period/np.interp(sol_age,age,Prot))
    print('new FK {:.5g}'.format(newFK))

    # generate new namelist and new_w10 array
    new_namelist = namelist_path+'20230928_1_PDISK_{:.6g}_ZINIT_{:.5g}_FC_{:.3g}_FK_{:.5g}'.format(Pdisk, newZ, newFC, newFK)
    new_output = output_path+new_namelist[28:]

    # copy old namelist to new
    # shutil.copyfile(source, destination)
    shutil.copyfile(namelist_locations[i]+'.nml1',new_namelist+'.nml1') 
    shutil.copyfile(namelist_locations[i]+'.nml2',new_namelist+'.nml2')     

    # find and replace on new namelist

    replaceAll(new_namelist+'.nml1', 'RSCLX(1) =', 'RSCLX(1) = {:.9g}\n'.format(XENV0A))
    replaceAll(new_namelist+'.nml1', 'XENV0A(1) =', 'XENV0A(1) = {:.9g}\n'.format(XENV0A))
    replaceAll(new_namelist+'.nml1', 'XENV0A(2) =', 'XENV0A(2) = {:.9g}\n'.format(XENV0A))
    replaceAll(new_namelist+'.nml1', 'XENV0A(3) =', 'XENV0A(3) = {:.9g}\n'.format(XENV0A))

    replaceAll(new_namelist+'.nml1', 'CMIXLA(1) =', 'CMIXLA(1) = {:.9g}\n'.format(CMIXLA))
    replaceAll(new_namelist+'.nml1', 'CMIXLA(2) =', 'CMIXLA(2) = {:.9g}\n'.format(CMIXLA))
    replaceAll(new_namelist+'.nml1', 'CMIXLA(3) =', 'CMIXLA(3) = {:.9g}\n'.format(CMIXLA))

    replaceAll(new_namelist+'.nml1', 'RSCLZ(1) =', 'RSCLZ(1) = {:.5g}\n'.format(newZ))
    replaceAll(new_namelist+'.nml1', 'ZENV0A(1) =', 'ZENV0A(1) = {:.5g}\n'.format(newZ))
    replaceAll(new_namelist+'.nml1', 'ZENV0A(2) =', 'ZENV0A(2) = {:.5g}\n'.format(newZ))
    replaceAll(new_namelist+'.nml1', 'ZENV0A(3) =', 'ZENV0A(3) = {:.5g}\n'.format(newZ))

    replaceAll(new_namelist+'.nml1', 'FLAST =', 'FLAST = \'{0}.last\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FMODPT =', 'FMODPT = \'{0}.full\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FSTOR =', 'FSTOR = \'{0}.store\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FTRACK =', 'FTRACK = \'{0}.track\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FSHORT =', 'FSHORT = \'{0}.short\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FPMOD =', 'FPMOD = \'{0}.pmod\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FPENV =', 'FPENV = \'{0}.penv\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FPATM =', 'FPATM = \'{0}.atm\'\n'.format(new_output))

    replaceAll(new_namelist+'.nml1', 'FSNU =', 'FSNU = \'{0}.snu\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FSCOMP =', 'FSCOMP = \'{0}.excomp\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FDEBUG =', 'FDEBUG = \'{0}.debug\'\n'.format(new_output))
    replaceAll(new_namelist+'.nml1', 'FMILNE =', 'FMILNE = \'{0}.milne\'\n'.format(new_output))

    replaceAll(new_namelist+'.nml2', 'PDISK =', 'PDISK = {:.6g}\n'.format(Pdisk))
    replaceAll(new_namelist+'.nml2', 'FC =', 'FC = {:.3g}\n'.format(newFC))
    replaceAll(new_namelist+'.nml2', 'FK =', 'FK = {:.5g}\n'.format(newFK))

    # add name to array
    new_namelist_locations += [new_namelist]
    new_CMIXLA += [CMIXLA]
    new_XENV0A += [XENV0A]
    new_w10 += [w10[i]]
    new_FC += [newFC]
    new_FK += [newFK]
    new_Pdisk += [Pdisk]
    print('--------------------')

if any(new_namelist_locations):
  pass
else:
  print('Done!')
  sys.exit()

w10 = new_w10
namelist_locations = new_namelist_locations
old_CMIXLA = new_CMIXLA
old_XENV0A = new_XENV0A
FC = new_FC
FK = new_FK
oldTdisk = new_Tdisk
oldPdisk = new_Pdisk
new_CMIXLA = []
new_XENV0A = []
new_w10 = []
new_namelist_locations = []
new_FC = []
new_FK = []
new_Tdisk = []
new_Pdisk = []


# And now run through all the iterations
j = 1
while j<= max_iter:
  
  print('Begin iteration', j)
  print('--------------------')
  yml.run_parallel(namelist_locations, pool_size = 20, command = "../../model5.0")

  output_locations = []
  for i in range(len(namelist_locations)):
    output_locations.append(output_path+namelist_locations[i][28:]+'.track')

  for i in range(len(namelist_locations)):

    # read in file
    age_tracks, logL, logR, Li_surf, Z_surf, ZX_surf, I_tot, I_cz, w_env, Prot = np.genfromtxt(output_locations[i], usecols=(2,3,4,60,64,65,68,69,70,72), unpack=True)
    age = age_tracks
    Li_surf = np.log10(Li_surf/Li_surf[0])+3.31
    #I0 = w10 * np.interp(0.01,age,I_cz) / w0
    
    # check calibration
    if np.abs((np.interp(sol_age,age,Prot)-sol_rot_period)/sol_rot_period) < calibration_tol and\
       np.abs((np.interp(sol_age,age,ZX_surf)-ZX_mixture)/ZX_mixture) < calibration_tol and\
       np.abs((np.interp(sol_age,age,Li_surf)-Li_measured)/Li_measured) < 5e-3 and\
       np.abs(np.interp(sol_age,age,logL)) < TOLL and\
       np.abs(np.interp(sol_age,age,logR)) < TOLR and\
       np.abs((np.interp(0.01,age,w_env)-w10[i])/w10[i]) < calibration_tol:
      print(output_locations[i],'complete')
      continue
  
    # create new nml and change nml values if necessary
    else:
          
      print('filename:',output_locations[i])
      print('--------------------')
      print('diff logL {:.3g}'.format(np.abs(np.interp(sol_age,age,logL))))
      print('diff logR {:.3g}'.format(np.abs(np.interp(sol_age,age,logR))))
      print('fractional diff Prot {:.3g}'.format(np.abs((np.interp(sol_age,age,Prot)-sol_rot_period)/sol_rot_period)))
      print('fractional diff ZX_surf {:.3g}'.format(np.abs((np.interp(sol_age,age,ZX_surf)-ZX_mixture)/ZX_mixture)))
      print('fractional diff Li_surf {:.3g}'.format(np.abs((np.interp(sol_age,age,Li_surf)-Li_measured)/Li_measured)))
      print('fractional diff w10 {:.3g}'.format(np.abs((np.interp(0.01,age,w_env)-w10[i])/w10[i])))
      print('--------------------')

      # calculate new Tdisk
      #I0 = w10[i] * np.interp(0.01,age,I_cz) / w0
      #Tdisk = np.interp(I0,[I_cz[np.where(I_cz<=I0)[0][0]],I_cz[np.where(I_cz<=I0)[0][0]-1]],[age[np.where(I_cz<=I0)[0][0]],age[np.where(I_cz<=I0)[0][0]-1]])
      #Tdisk = oldTdisk[i]*(np.interp(0.01,age,w_env)/w10[i])

      # calculate new CMIXLA and XENV0A
      DA = ((logL[-1]*DRDX/DLDX-logR[-1])/(DRDA-DLDA*DRDX/DLDX))
      DX = -(logL[-1] + DLDA*DA)/DLDX
      CMIXLA = old_CMIXLA[i] + DA
      XENV0A = old_XENV0A[i] + DX

      print('new CMIXLA {:.9g} DA {:.9g}'.format(CMIXLA, DA))
      print('new XENV0A {:.9g} DX {:.9g}'.format(XENV0A, DX))
    
      # calculate new Pdisk
      #Pdisk = w10[i] * np.interp(0.01,age,I_cz)/np.interp(0.0005,age,I_cz)
      Pdisk = oldPdisk[i]*(w10[i]/np.interp(0.01,age,w_env))
      print('new PDISK {:.6g}'.format(Pdisk))

      # calculate new Z
      newZ = Z_surf[0]*(ZX_mixture/np.interp(sol_age,age,ZX_surf))
      print('new ZENV0A {:.5g}'.format(newZ))

      # calculate new FC
      newFC = np.max([0.05,FC[i]*(np.interp(sol_age,age,Li_surf)/Li_measured)])
      #newFC = 0.98
      print('new FC {:.3g}'.format(newFC))

      # calculate new FK
      newFK = FK[i]*(sol_rot_period/np.interp(sol_age,age,Prot))
      print('new FK {:.5g}'.format(newFK))

      # generate new namelist and new_w10 array
      new_namelist = namelist_path+'20230928_{}_PDISK_{:.6g}_ZINIT_{:.5g}_FC_{:.3g}_FK_{:.5g}'.format(j+1, Pdisk, newZ, newFC, newFK)
      new_output = output_path+new_namelist[28:]

      # copy old namelist to new
      # shutil.copyfile(src, dst)
      shutil.copyfile(namelist_locations[i]+'.nml1',new_namelist+'.nml1') 
      shutil.copyfile(namelist_locations[i]+'.nml2',new_namelist+'.nml2')     

      # find and replace on new namelist
      
      replaceAll(new_namelist+'.nml1', 'RSCLX(1) =', 'RSCLX(1) = {:.9g}\n'.format(XENV0A))
      replaceAll(new_namelist+'.nml1', 'XENV0A(1) =', 'XENV0A(1) = {:.9g}\n'.format(XENV0A))
      replaceAll(new_namelist+'.nml1', 'XENV0A(2) =', 'XENV0A(2) = {:.9g}\n'.format(XENV0A))
      replaceAll(new_namelist+'.nml1', 'XENV0A(3) =', 'XENV0A(3) = {:.9g}\n'.format(XENV0A))

      replaceAll(new_namelist+'.nml1', 'CMIXLA(1) =', 'CMIXLA(1) = {:.9g}\n'.format(CMIXLA))
      replaceAll(new_namelist+'.nml1', 'CMIXLA(2) =', 'CMIXLA(2) = {:.9g}\n'.format(CMIXLA))
      replaceAll(new_namelist+'.nml1', 'CMIXLA(3) =', 'CMIXLA(3) = {:.9g}\n'.format(CMIXLA))
    
      replaceAll(new_namelist+'.nml1', 'RSCLZ(1) =', 'RSCLZ(1) = {:.5g}\n'.format(newZ))
      replaceAll(new_namelist+'.nml1', 'ZENV0A(1) =', 'ZENV0A(1) = {:.5g}\n'.format(newZ))
      replaceAll(new_namelist+'.nml1', 'ZENV0A(2) =', 'ZENV0A(2) = {:.5g}\n'.format(newZ))
      replaceAll(new_namelist+'.nml1', 'ZENV0A(3) =', 'ZENV0A(3) = {:.5g}\n'.format(newZ))

      replaceAll(new_namelist+'.nml1', 'FLAST =', 'FLAST = \'{0}.last\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FMODPT =', 'FMODPT = \'{0}.full\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FSTOR =', 'FSTOR = \'{0}.store\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FTRACK =', 'FTRACK = \'{0}.track\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FSHORT =', 'FSHORT = \'{0}.short\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FPMOD =', 'FPMOD = \'{0}.pmod\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FPENV =', 'FPENV = \'{0}.penv\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FPATM =', 'FPATM = \'{0}.atm\'\n'.format(new_output))

      replaceAll(new_namelist+'.nml1', 'FSNU =', 'FSNU = \'{0}.snu\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FSCOMP =', 'FSCOMP = \'{0}.excomp\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FDEBUG =', 'FDEBUG = \'{0}.debug\'\n'.format(new_output))
      replaceAll(new_namelist+'.nml1', 'FMILNE =', 'FMILNE = \'{0}.milne\'\n'.format(new_output))

      replaceAll(new_namelist+'.nml2', 'PDISK =', 'PDISK = {:.6g}\n'.format(Pdisk))
      replaceAll(new_namelist+'.nml2', 'FC =', 'FC = {:.3g}\n'.format(newFC))
      replaceAll(new_namelist+'.nml2', 'FK =', 'FK = {:.5g}\n'.format(newFK))

      # add name to array
      new_namelist_locations += [new_namelist]
      new_CMIXLA += [CMIXLA]
      new_XENV0A += [XENV0A]
      new_w10 += [w10[i]]
      new_FC += [newFC]
      new_FK += [newFK]
      new_Pdisk += [Pdisk]
      print('--------------------')

  if any(new_namelist_locations):
    pass
  else:
    print('Done!')
    sys.exit()

  w10 = new_w10
  namelist_locations = new_namelist_locations
  old_CMIXLA = new_CMIXLA
  old_XENV0A = new_XENV0A
  FC = new_FC
  FK = new_FK
  oldTdisk = new_Tdisk
  oldPdisk = new_Pdisk
  new_CMIXLA = []
  new_XENV0A = []
  new_w10 = []
  new_namelist_locations = []
  new_FC = []
  new_FK = []
  new_Tdisk = []
  new_Pdisk = []
  
  j+= 1
  print('--------------------')


print('Failed to converge after {0} iterations'.format(max_iter))
