

This README describes: 

(i) How to compile and run rotevol
(ii) Rotevol input parameters 
(iii) Example scripts for running Rotevol 
======================================================


(i) Compiling and running Rotevol: 

To compile rotevol, run: 

make -f Makerotwind 

in your command line. This will generate the rotevol executable defined in the Makerotwind file. You can change this executable name if you wish. 

To run rotevol, you need a control file and a runfile. The control file defines the physics used in the rotevol run, and the runfile points to the input and output directories. The gen_rotgridv3.py module contains scripts for generating control files and run files with a given set of input physics from template control and run files. These templates are named control_file_temp.dat and runfile_temp. DO NOT DELETE THE TEMPLATE FILES. 

Once you have generated the a control file and runfile with your chosen set of inputs, you can execute rotevol by running: 

./{YOUR RUNFILE NAME}

Your output files will be sent to the directory of your choosing. 
======================================================
(ii) Rotevol Input Parameters

Below is a brief description of the available parameters in Rotevol. In the control file: 

INUMT= Number of mass tracks, if you are setting LCALSOL = .TRUE., INUMT must be 1. 
LSOLID= T/F flag for rigid rotation 
IWIND = Wind law perscription you want to use; 1=No loss 2= Modified Kawaler 3=PMM (PMM is the default for YREC)
FK= Parameter (scaling factor) for loss law.  Change to calibrate. 
PMMA= dM/dt ~ omega^PMMA, PMM wind; PMMA = 2 for V13 wind law
PMMB= B R^-PMMC ~ omega^PMMB ; PMMB = 1 for V13 wind law
PMMC= Kawaler PMMC = 2 RM PMMC = 0 ; PMMC = 0 for V13 wind lar
PMMM = Matt&Pudritz M; dJ/dt~B^4m dM/dt^1-2m.  Matt2012 m=0.22 (also for V13 wind law)
SOLJDOT=1.3000E+30 ! Reference solar dJ/dt, used for constant in PMM (do not reccomend changing this)
SOLMDOT=1.2700E+12 ! Reference solar dM/dt, used for constant in PMM (do not reccomend changing this)
NUMROT= Number of rotation cases considered, (default = 1, scripts programaticlly generate runfiles, so you should not need to change this)
PDISK0(1)=Initial rotation period (days) 
TDISK0(1)= Disk locking lifetime, P = Pdisk until Tdisk is reached (Myr) 
TAUCOUPLE= Core/envelope coupling timescale (yr); negative=decoupled \
WCRIT= Saturation threshold for loss law (rad/s); Typical value of 10 omega_sun here \
LROSS= T/F rossby scaling of omega_crit (iwind=2) or constant(iwind=3) (Reccomended to set as .TRUE.)
LCALSOL= Flag for doing a solar calibration, If T, set numtrack=1 and calibrate Fk to get solw at solage 
SOLAGE=4.568D9 ! Solar age in Gyr, used for solar calibration \
SOLW=Solar angular velocity.  25.4d=2.863d-6 rad/s \

In the runfile: 

local = Directory with rotevol 
tracks = Location of input evolutionary tracks. Note: These tracks shoulr be NON-ROTATING YREC models
output_dir = Location for rotevol output 

 ln -s $local/{3}.dat fort.11 = control file name
 ln -s $tracks/{4}.track fort.13 = track file name 
 ln -s $output_dir/{5}.numerics fort.50 = output numeric file name
 ln -s $output_dir/{6}.out fort.60 = output rotevol track name
 
 
 Scripts in this directory demonstrate how you can use functions in gen_rotgridv3 to generate control files and run files. 
 ======================================================
 (iii) Available Scripts
 
 There are a number of scripts and modules in the Rotevol directory. The rotevol_tutorialnotebook.ipynb offers the most comprehensive tutorial for using Rotevol and analyzing the outputs. The scripts in this folder include: 
 
 rotevol_tutorialnotebook.ipynb - Jupyter notebook that walks the user throuth how to run Rotevol for different rotation cases, on a mass grid, and compare rotevol outputs to YREC rotation runs. 
 
 run_rotevol_singlemass.py - Python script for running different rotation physics on a single mass track 
 
 run_rotevol_massgrid.py - Python script for running a single rotaiton case on many mass tracks
 
 run_rotevol_comparison.py - Python script for generating rotevol files to compare against full YREC rotation models as seen in the YREC release paper. 
 
 gen_rotgridv3.py - Contains functions for generating control files and runfiles. Also includes functions for generating Pandas dataframes from Rotevol and YREC outputs.  
 