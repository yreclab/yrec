C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PARMIN
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 9/22/26 MHP via Claude
C code changed to remove the MHD equation of state
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
      SUBROUTINE PARMIN(FALEX06,FALLARD,FATM,FFERMI,
     * FLIV95,FPATM,FPENV,FPMOD,FPUREZ,FSCVH,
     * FSCVHE,FSCVZ,YRECVER,GITHASH)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NEWOPAC/ into NEWOPAC_MOD.
      USE NEWOPAC_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/LABEL/ into LABEL_MOD.
      USE LABEL_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ACDPTH/ into ACDPTH_MOD.
      USE ACDPTH_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/COMP/ into COMP_MOD.
      USE COMP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CCOUT/ into CCOUT_MOD.
      USE CCOUT_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLBYPASS/ into NMLBYPASS_MOD.
      USE NMLBYPASS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/INTPAR/ into INTPAR_MOD.
      USE INTPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/RUNLOOP/ into RUNLOOP_MOD.  A blanket
C USE imports exactly the names the COMMON declaration made global here,
C so it cannot change meaning.  See runloop_mod.f for the block history
C and for why the module declares the types the implicit rules supplied.
      USE RUNLOOP_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 ALFA,FK,RSCLCM,RSCLM,RSCLX,RSCLZ,SUM_FRAC,WMAX_SUN
      INTEGER KINDRN,NCMXCK,NKIND
      LOGICAL*4 LCMXBAD

C PARAMETERS NT AND NG FOR TABULATED SURFACE PRESSURES.
C JNT 6/2014 ADD NTC AND NGC FOR KURUCZ/CASTELLI SURFACE PRESSURES
C PARAMETERS NTA AND NGA FOR TABULATED ALLARD MODEL SURFACE PRESSURES.

      CHARACTER*10 YRECVER
      CHARACTER*20 GITHASH
      CHARACTER*256 VERFMT
      CHARACTER*256 FPUREZ
      CHARACTER*256 DESCRIP(2)
      CHARACTER*3 ANEWCP,ATMP,AID(12)
C MHP 10/24 MIXTURE TYPE FOR NEW HEAVY ELEMENT MIXTURE MACHINERY
      CHARACTER*8 AMIX,AISO,AMIXT(4)
      REAL*8 ZXMIXT(4),FRAC_CT(4),FRAC_NT(4),FRAC_OT(4)
      DIMENSION KINDRN(50),RSCLM(50),RSCLX(50),RSCLZ(50),
     1          RSCLCM(50)
C 9/25/26 MHP via Claude
C code changed to remove the LISO isochrone-output option
      CHARACTER*256 FATM
      CHARACTER*256 FSTCH
      CHARACTER*256 FALLARD,FSCVH,FSCVHE,FSCVZ
      CHARACTER*256 FLAST, FFIRST, FFERMI,
     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
     2    FSTOR, FPMOD, FPENV, FPATM,
     3    FSNU, FSCOMP
C 9/25/26 MHP via Claude
C code changed to add FSOUND, the Csound.dat sound-speed-profile
C output filename, to the file-name-managed unit system
      CHARACTER*256 FSOUND
C 9/24/26 MHP via Claude
C code changed to remove the Monte Carlo option
C JVS 02/11 PARAMETERS for command line yrec input file specification
C      and extra acoustic depth (calcad.f) output files
C       CHARACTER*256 FCLCD, YREC1, YREC2, FACAT, FJLAST,FJVS, FJENT, FJDEL
      CHARACTER*256 FCLCD, YREC1, YREC2
      !CHARACTER*256 FJLAST
      CHARACTER*256 CMD  ! Shell command composition for system() call
      INTEGER  I, LAST_SLASH_IDX
C 9/25/26 MHP via Claude
C code changed to remove dead IACAT, IJVS, IJENT, IJDEL unit
C reservations
C 10/14/26 MHP via Claude
C code changed to drop ICLCD and IJLAST from this declaration.  Both are
C IOUNITS members, and redundantly typing a COMMON member is legal while
C doing the same to a USE-associated name is rejected:
C "Symbol 'iclcd' conflicts with symbol from module 'iounits_mod'".
C IOUNITS_MOD supplies both types.  MRK is a genuine local and stays.
      INTEGER MRK
C 10/12/26 MHP via Claude
C code changed to extend COMMON/NMLPAR/ to 234 members, adding the
C namelist variables that the physics routines read from 27 COMMON
C blocks which also held derived or working members.  Those blocks keep
C only their non-namelist members; five of them -- NEWMX, VMULT,
C PMMWIND, CCOUT1 and ENVGEN -- had nothing left and are gone.
C Derivation-only namelist variables from the same blocks went to
C COMMON/NMLBYPASS/ instead, not here.
C
C Declared identically in all 121 files that hold any of these members.
C Generated from one member list, so every copy is byte-identical; the
C linker's 'size of symbol changed' warning is the check that they are.
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
C 9/25/26 MHP via Claude
C code changed to add ISOUND (Csound.dat unit) to COMMON/IOUNITS/
C 9/24/26 MHP via Claude
C code changed to remove dead ILLDAT, IKUR from COMMON/LUNUM/
C 9/24/26 MHP via Claude
C code changed to remove dead IDYN from COMMON/LUNUM/
C 9/25/26 MHP via Claude
C code changed to remove dead COMMON/LUNUM/ISCOMP (declared,
C assigned a unit number, but never opened or read anywhere)
C MHP 8/25 Removed file names from common block
C      COMMON/LUFNM/ FLAST, FFIRST, FRUN, FSTAND, FFERMI,
C     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
C     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
C     3    FLLDAT, FSNU, FSCOMP, FKUR,
C     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
C 9/24/26 MHP via Claude
C code changed to remove the Monte Carlo option
C 10/12/26 MHP via Claude
C code changed to drop COMMON/DESC/, which was declared in parmin.f alone.
C DESCRIP is now simply a local, kept by the blanket SAVE, and remains a
C CONTROL namelist variable.  Character data does not belong in a COMMON
C block.
C 10/11/26 MHP via Claude
C code changed to remove LSCRIB from COMMON/CCOUT/: it was declared
C positionally in all 17 files sharing this block but never read or
C written in executable code anywhere, and no namelist file sets it.
C 10/13/26 MHP via Claude: removed the unused COMMON/CENV/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 9/24/26 MHP via Claude
C code changed to remove dead CMIXL from COMMON/CONST3/; it is now
C passed as an explicit argument where actually used
C 10/13/26 MHP via Claude
C code changed to drop COMMON/CTLIM/; TENV is now derived in envint.f,
C its only reader, from TENV0 and TENV1.
C 10/13/26 MHP via Claude: removed the unused COMMON/CTOL/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 7/91 LSEMIC (SEMI-CONVECTION) ADDED TO COMMON BLOCK.
C 10/13/26 MHP via Claude: removed the unused COMMON/DPMIX/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 10/24 ADDED NEW CONTROLS FOR ALTERING THE CNO MASS FRACTIONS
C ISOTOPIC RATIOS(C,N,O) AND D/HE3/LI/BE/B ABUNDANCES.
C THESE CONTROLS ONLY ALTER THE MIXTURE IN THE STARTING MODEL AND ONLY
C IF THE MODEL IS CHEMICALLY UNEVOLVED. POSTPROCESSING TOOLS SHOULD BE USED FOR THE
C CORE HE BURNING PHASE.
c      COMMON/NEWCMP/XNEWCP,INEWCP,LNEWCP,LREL,ANEWCP
C 10/12/26 MHP via Claude
C code changed to remove COMMON/OPTAB/ entirely.  Once OPTOL moved to the
C consolidated namelist block, every remaining member was write-only:
C ZSI appeared only in a DATA statement in parmin.f, and IDT and IDD were
C assigned the constants 15 and 5 in coefft.f, envint.f, physic.f and
C starin.f and read nowhere in the code.  They are leftovers from the
C removed opacity-table interpolation schemes.
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
C 10/13/26 MHP via Claude: removed the unused COMMON/DEBHU/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 10/90 DIFFERENT FC FOR DIFFERENT MECHANISMS INTRODUCED.
C ALSO OPTION FOR SMOOTHING VELOCITIES FOR LENGTH SCALE CALCULATIONS.
C MHP 5/90 ADD COMMON BLOCK FOR GRAVITATIONAL SETTLING.
C MHP 5/90 ADD COMMON BLOCK FOR NEW TREATMENT OF
C ENTROPY TERM(LNEWS),AND THE CALCULATION
C OF SOLAR NEUTRINOS(LSNU).ALSO ALLOWS A FOURTH LEVEL OF ITERATION(NITER4).
C MHP 7/91 ADDED COMMON BLOCK FOR NUMERICAL PARAMETERS IN KEMCOM.
C YCK >>> OPAL95
      CHARACTER*256 FLIV95
C MHP 8/25 Removed character file names from common block
C <<< YCK
C MHP 6/90 ADDITIONAL COMMON BLOCK FOR SETTLING.
C GES 6/15 NEW COMMON BLOCK FOR LIGHT DIFFUSION AND NEW DIFF ROUTINE.
C DBG PULSE
C 10/13/26 MHP via Claude
C code changed to drop COMMON/PULSE/, declared here but never used.
C DBG PULSE OUT 7/92
C VARIABLES USED TO CONTROL OUTPUT OF PULSATION MODELS.  MODEL
C OUTPUT AFTER HAS TRAVELED POMAX IN HR DIAGRAM
C LPOUT AND POMAX ADDED TO CONTROL COMMON BLOCK, REST IN PHYSICS
C 10/13/26 MHP via Claude: removed the unused COMMON/ATMOS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/ATMOS2/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C JMH
C JNT 6/14 SAME AS ATMOS2 BUT FOR KURUCZ/CASTELLI2004 ATMOSPHERES
C 10/13/26 MHP via Claude: removed the unused COMMON/ATMOS2C/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/06 GN --- New neutrino loss common block
C KC 2025-05-30 reordered common block elements
C       COMMON/NULOSS/LNULOS1,DSNUDT,DSNUDD
C 10/13/26 MHP via Claude
C code changed to remove COMMON/NULOSS/: engeb.f assigns DSNUDT and
C DSNUDD and nothing reads them, in engeb.f or anywhere else, so they are
C now plain locals there.  parmin.f declared the block without using it.
C MHP 1/93 ADD OPTION TO AUTOMATICALLY CALIBRATE SOLAR MODEL.
C      COMMON/CALS2/TOLL,TOLR,LCALS
C MHP 6/13 ADD OPTION TO CALIBRATE SOLAR Z/X, SOLAR Z/X, SOLAR AGE
C DBG 7/92 ADDED DEBYE HUCKEL PARAMETERS TO NAMELIST, ETADH0, ETADH1

C 10/13/26 MHP via Claude: removed the unused COMMON/CALSTAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C OPAL eos
      CHARACTER*256 FcondOpacP,FOPALE06
C MHP 8/25 Remove file names from common blocks
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
C OPACITY COMMON BLOCKS - modified 3/09
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove dead opacity-table Z-value inputs
C 9/24/26 MHP via Claude
C code changed to merge COMMON /MISCOPAC/ and COMMON/NWLAOL/ into
C COMMON /NEWOPAC/
      CHARACTER*256 FALEX06
C 10/13/26 MHP via Claude: removed the unused COMMON/CROSS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/12/26 MHP via Claude
C code changed to merge COMMON/NEWPARAM/, COMMON/NEWCROSS/ and
C COMMON/XSECT/ into a single COMMON/NMLBYPASS/, declared here, in
C remap.f and in starin.f.
C
C These are namelist variables that exist only to set other quantities,
C or that are reserved for future development; none is read by the wider
C code.  Keeping them in their own block keeps them OUT of the single
C consolidated namelist block being built, so that block holds only
C variables the physics routines actually consume.  starin.f declares it
C although it uses none of them yet, so the isotope and cross-section
C machinery there can reach them without reopening this layout.
C
C Member order is NEWPARAM, then NEWCROSS, then XSECT, and the three
C declarations are generated from one list so all files agree.
C 10/13/26 MHP via Claude: removed the unused COMMON/SCVEOS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/DISK/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 3/99 ADDED FLAG TO TREAT THE ENTIRE STAR AS 'CONVECTIVE'
C FOR ANGULAR MOMENTUM PURPOSES.
C JNT 2025/09/04 ADD IMPJMOD TO SOLID
C FROM JNT 05/15 add IMPJMOD (impose J model) which controls angular momentum 
C     coupling (0=no effect, 1=solid body rotation, 2= solid body core decoupled from surface cz
C     decoupled from surface cz, 3=solid body core coupled to surface cz)
C MHP 10/01 ADDED COMMON BLOCK FOR MASS LOSS/ACCRETION
C mhp 8/10 added option to scale mass loss rate by rotation; requires rotating model
C MHP 2/12 MOVED INTO PMM TORQUE MODEL, RETAINED MDOT SWITCH
C KC 2025-05-30 reordered common block elements
C      COMMON/MASSCHG3/LSOLWIND,DMSUN,DMWSUN,DMWMAX
C      COMMON/MASSCHG3/DMSUN,DMWSUN,DMWMAX,LSOLWIND
CFD 10/09 ADDED COMMON BLOCK FOR EXTRA MIXING. IT MIMIC SOME MIXING BY AFFECTING
C        THE SETTLING COEFFICIENT DIRECTLY (in setup_grsett.f)
C JVS 02/11 Acoustic depth calc common block
C KC 2025-05-30 reordered common block elements
C       COMMON/ACDPTH/TAUCZN,DELADJ(JSON),TAUHE, TNORM, TCZ, WHE, ICLCD,
C 9/25/26 MHP via Claude
C code changed to remove dead IACAT, IJVS, IJENT, IJDEL unit
C reservations from COMMON/ACDPTH/ (declared but never opened anywhere)
C      *LCLCD, AGEOUT(5), IACAT, IJLAST, LJLAST, LJWRT, LADON,LAOLY, IJVS,
C JVS END
C JVS 04/14 Common block for additional timestep governors
C MHP 02/12 NEW PARAMETERIZATION OF ANGULAR MOMENTUM AND MASS LOSS
C FROM MAGNETIZED SOLAR-LIKE WINDS
      CHARACTER*3 AWIND
C KC 2025-05-30 reordered common block elements
C       COMMON/PMMWIND/AWIND,LMWIND,LROSSBY,LBSCALE,PMMA,PMMB,PMMC,PMMD,PMMM,
C      *         PMMJD,PMMMD,PMMSOLP,PMMSOLW,PMMSOLTAU	
C 10/12/26 MHP via Claude
C code changed to remove the trailing CHARACTER member AWIND from
C COMMON/PMMWIND/.  Character data does not belong in a COMMON block, and
C AWIND is referenced in executable code only here, where it selects the
C wind law ('K97'/'V13') below; the other four files declaring this block
C never used it.  AWIND stays a PHYSICS namelist variable and is now a
C local, kept across calls by the blanket SAVE.  Being last, its removal
C moves no other member.
C MHP 8/17 ADDED EXCEN, C_2 TO COMMON BLOCK FOR MATT ET AL. 2012 CENT. TERM
C 10/13/26 MHP via Claude
C code changed to retire COMMON/CWIND/.  Its namelist members moved to the
C consolidated block earlier, leaving two.  C_2 is a constant, set once in
C parmin.f, so it is now the last member of COMMON/CONSTANTS/ -- appended
C there rather than inserted, and added to every declaration so the block
C keeps one size; parmin.f DATA-initializes CLSUN and CRSUN, so a short
C declaration anywhere would be the OP95INTERP hazard again.  It may
C eventually become a namelist variable.  STRUCTFACTOR, the loss-law
C prefactor, is computed by AMCALC and read by its own two callers,
C mwind.f and mcowind.f, so it is now an AMCALC output argument.
C CREATE A NEW COMMON BLOCK FOR OVERTURN TIMESCALE THINGS (PPHOT,TAUCZ,LNEWTCZ)
C 10/13/26 MHP via Claude: removed the unused COMMON/OVRTRN/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 02/12 PERMIT CONSTANT DIFFUSION COEFFICIENT
C KC 2025-05-30 reordered common block elements
C       COMMON/MAG/LCODM,CODM
C
C G Somers 6/14 ALLOW VARIABLE LI/BE DESTRUCTION CROSS SECTIONS
C G Somers END
C 10/13/26 MHP via Claude
C code changed to replace COMMON/VERSION/ with explicit arguments.  These
C are CHARACTER, which does not belong in a COMMON block; SETVERSION sets
C them and parmin.f is the only reader, so main.f now holds them and
C passes them to both.
      SAVE
C
C SPLIT NAMELIST INTO TWO: CONTROL and PHYSICS
      NAMELIST /CONTROL/
     *   CMIXLA, CALSOLAGE, CALSOLZX,
     *   DESCRIP,
     *   ENDAGE,
     *   FPUREZ,
     *   FLAST, FFIRST, FFERMI, FDEBUG, FTRACK, FSHORT, FSTCH,
     *   FMILNE, FMODPT, FSTOR, FPMOD, FPATM, FPENV,
     *   FSNU, FSCOMP, FATM, FSOUND,
     *   FALLARD, FSCVH, FSCVHE, FSCVZ, FLIV95,
     *   IPVER, ITRVER,
     *   KINDRN,
     *   LDEBUG, LCORR, LMILNE, LTRACK, LSTORE, LFIRST,
     *   LSTPCH, LSTCH,
C G Somers 11/14
     *   LSTATM,LSTENV,LSTMOD,LSTPHYS,LSTROT,
C G Somers END
     *   LPULSE, LZRAMP, LTEFF, LCALST, LPUREZ,
C MHP 9/24 add LCALSOLZX to namelist
C 9/25/26 MHP via Claude
C code changed to remove the LISO isochrone-output option
     *   LRWSH, LSENV0A, LPOUT,LCALS,LCALSOLZX,
     *   LOPAL95,
     *   NPOINT,
     *   NPENV, NPRTMOD, NPRTPT, NUMRUN, NMODLS,
     *   POA, POB, POC, POMAX,
     *   RSCLM, RSCLX, RSCLZ, RSCLCM, RSCLZC, RSCLZM1, RSCLZM2,
     *   SETDT, SENV0A,STEFF,SR,
     *   TOLR, TOLL,TOLZ,
     *   XENV0A, XLS, XLSTOL,
     *   ZENV0A,
C 9/24/26 MHP via Claude
C code changed to remove dead opacity-table Z-value inputs
     *   ZOPAL951,
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
     *     FcondOpacP,FOPALE06,FALEX06,LALEX06,
C MHP 10/24 ADDED END_DCEN,END_XCEN,END_YCEN VECTORS TO NML1, USED IN MAIN
C MHP 10/24 ADDED HEAVY ELEMENT MIXTURE CONTROLS TO NML1,USED IN STARIN
C 10/27/26 MHP via Claude: added L_ZERODT_PREMS, used in MAIN
     * END_DCEN,END_XCEN,END_YCEN,L_ZERODT_PREMS,ISETMIX,ISETISO,
     * AMIX,AISO,FRAC_C,FRAC_N,FRAC_O,R12_13,R14_15,R16_17,R16_18,ZXMIX,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,XB10_INI,XB11_INI
C
      NAMELIST /PHYSICS/
     *   ATMMIN, ATMBEG, ATMERR, ATMMAX, ATMD0, ANEWCP, ATMP, ACFPFT,
     *   ATIME, ALPHAC, ALPHAE, ALFA, ALPHAM, ATMSTP, ABSTOL, BETAC,
     *   CMIN, CLSUN, CRSUN,
     *   DPENV, DTDIF, DTWIND, DJOK, DT_GS,
     *   ENVERR, ENVMAX, ENVMIN, ENVBEG, ENVSTP,ETADH0,ETADH1,
     *   FCORR0, FCORRI, FK,  FW, FC, FO, FMU, FES,
     *   FCORE, FGSF, FSS, FESC, FSSC, FGSFC, FGRY, FGRZ,
     *   GRTOL,
     *   HTOLER, HPTTOL,
     *   ITFP1, ITFP2, IMAX, ITDIF1, ITDIF2, IES, IGSF, IMU, ILAMBDA,
     *   KTTAU, KEMMAX,
     *   LVFC, LDIFAD, LNOJ, LNEWDIF, LDIFY, LDIFZ, LDIFLI, LSNU, LDH,
     *   LNEWCP, LKUTHE, LOVSTC, LOVSTE, LOVSTM, LOVMAX,
     *   LEXCOM, LROT, LNEW0, LINSTB, LWNEW, LJDOT0, LPTIME,LADOV,LTRIST,
     *   LENVG, LNULOS1, LTHOUL, LTHOULFIT,
     *   LCORE, LSEMIC, LNEWS,
     *   MCORE,
     *   NITER1, NITER2, NITER3, NITER4, NUSE, NITER_GS,
     *   OPTOL,
     *   RCRIT, RELTOL,
     *   STOLR0,
     *   TCUT, TSCUT, TENV0, TENV1, TGCUT, TRIDT, TRIDL,
     *   TOLLAOL,
     *   VNEW,
     *   WALPCZ, WNEW, WEAKSCREENING,
     *   XNEWCP, XMIN,
     *   YMIN, TMOLMIN,TMOLMAX,
     *   SSTANDARD,LSCV,
     *   LDISK,TDISK,PDISK,WMAX,LSOLID,IMPJMOD, !JNT 09/2025 FOR 05/15
     *   DMDT0,FCZDMDT,FTOTDMDT,COMPACC,CREIM,LREIMER,LMDOT,
     *   LcondOpacP,LOPALE06,LNumDeriv,
     *   ALATM_FeH,ALATM_Alpha,LALTPTau100,! For new Allard Atmospheres
     *   CSTMIXING, CSTDIFFMIX,      !CFD oct2009 To mimic mixing(reduce settling)
C 10/8/26 MHP via Claude
C code changed to remove LPMM: confirmed unused (not in any COMMON
C block, no conditional anywhere in the code references it, and its
C own DATA default was already commented out), so it had zero effect
C on any run. The PMMA/PMMB/PMMC/PMMD/PMMM/PMMJD/PMMMD
C parameters below remain live, used under the LMWIND option.
C 10/11/26 MHP via Claude
C code changed to remove PMMWMAX: like LPMM, it was in no COMMON
C block, had no DATA default, and was referenced nowhere in the code,
C so setting it had no effect. No namelist file sets it.
     *   LSOLWIND,LMWIND,LROSSBY,LBSCALE,
     *   AWIND,PMMA,PMMB,PMMC,PMMD,PMMM,PMMJD,PMMMD,
C MHP 8/17 ADDED WMAX_SUN
     *   PMMSOLP,PMMSOLW,PMMSOLTAU,LCODM,CODM,WMAX_SUN,
C G Somers 6/14
     *   XSLI6,XSLI7,XSBE91,XSBE92,XSBE93,
     *   LXLI6,LXLI7,LXBE91,LXBE92,LXBE93,
     *   SLI6,SLI7,SBE91,SBE92,SBE93,LNEWNUC,
     *   SPOTF, SPOTX, LSDEPTH,
C G Somers END
C MHP 09/14 ADDED CROSS SECTIONS
     *   S0_1_1,S0_3_3,S0_3_4,S0_1_12,S0_1_13,S0_1_14,S0_1_16,
     *   S0_PEP,S0_1_BE7E,S0_1_BE7P,S0_HEP,S0_1_15_C12ALP,S0_1_15_O16,
     *   S0P_1_1,S0P_3_3,S0P_3_4,S0P_1_12,S0P_1_13,S0P_1_14,
     *   S0P_1_16,S0PP_1_12,S0PP_1_13,S0PP_1_16,S0P_1_BE7P,S0PP_1_BE7P,
     *   FLAG_DX,FLAG_DW,FLAG_DZ,LSTRUCT_TIME,
     *   TIME_CORE_MIN,TIME_DL,TIME_DP,TIME_DR,TIME_DT,TIME_DW_GLOBAL,
     *   TIME_DW_MIX,TIME_DX_CORE_FRAC,TIME_DX_CORE_TOT,TIME_DX_SHELL,
     *   TIME_DX_TOTAL,TIME_DY_CORE_FRAC,TIME_DY_CORE_TOT,TIME_DY_SHELL,
     *   TIME_DY_TOTAL,TOL_CZBASE_FINE_WIDTH,TOL_DL_MAX,TOL_DM_MAX,
     *   TOL_DM_MIN,TOL_DP_CORE_MAX,TOL_DP_CZBASE_MAX,TOL_DP_ENV_MAX,
     *   TOL_DX_MAX,TOL_DZ_MAX,TIME_MAX_DT_FRAC,LNEWVARS,
C G Somers 3/17 USE NEW OVERTURN TIMESCALE CALC?
     *   LNEWTCZ, LCALCENV
C
C 10/8/26 MHP via Claude
C code added: an output-only NAMELIST (never READ, only WRITTEN) for
C variables that are derived/overridden after PHYSICS and CONTROL are
C read in, so their effective (post-derivation) values can be echoed
C to .short alongside the raw namelists, without a hand-written
C FORMAT per variable. Excludes purely incidental I/O bookkeeping
C (e.g. CMD, FCLCD, ICLCD, MRK, LAST_SLASH_IDX).
      NAMELIST /DERIVED/
     *   CLN, CC13, CC23,
     *   CONSTFACTOR, EXCEN, EXL, EXM, EXMD, EXPR, EXR, EXTAU, EXW, WMAX,
     *   LDIFY, LDIFZ, LTHOUL, LTHOULFIT, LNEW0, LNEWDIF, ILAMBDA,
     *   SLI6, SLI7, SBE91, SBE92, SBE93, FRAC_C, FRAC_N, FRAC_O,
     *   ZXMIX, SUM_FRAC, LISOTOPE, LMIXTURE, INEWCP,
C 10/13/26 MHP via Claude
C code changed to drop CMIXL from the output-only DERIVED namelist.  The
C mixing length actually used is the scalar CMIXL that main.f reads out of
C the per-run vector CMIXLA at CMIXL = CMIXLA(NK), then passes on as an
C explicit argument.  PARMIN is called once, before the run loop, so it
C has no NK and cannot know that value: its own CMIXL never leaves this
C routine and keeps its DATA default, so the echo reported 1.4 no matter
C what the namelist asked for -- 1.4 against an actual 1.797279, for
C instance.  CMIXLA is echoed with the CONTROL namelist, with the real
C per-run values, so nothing is lost by removing this line.
     *   LREL, KTTAU0, LTTAU
C
C DBG DATA CARDS FOR THE RUN PARAMETERS
C 9/24/26 MHP via Claude
C code changed to remove the Monte Carlo option
c Changed slightly 3He-3He on 9/25/97 to take account of the S'.
c  Previously (6/16/97) used S at Gamow Peak. Agrees with Workshop paper.
c
C MHP 7/93 VARIABLE FC OPTION
C MHP 9/94 COMBINED DIFFUSION/ADVECTION OPTION
C MHP 9/93
      DATA KINDRN/50*1/
C MHP 10/24 ADDED NEW DEFAULTS FOR END CONDITIONS ON CENTRAL D,X,Y
      DATA RSCLM, RSCLX, RSCLZ, RSCLCM/50*0.0, 50*0.0, 50*0.0, 50*0.0/
      DATA AID/'HE3','C12','C13','N14','N15','O16','O17','O18','H2 ',
     *'LI6','LI7','BE9'/
C 10/14/26 MHP via Claude
C code changed to move DATA STOLR0,IMAX,NUSE/1.0D-3,11,7/ into
C INTPAR_MOD as initializers.  DATA on a USE-associated name is rejected,
C so the defaults had to move with the block.  Same effect: all three are
C PHYSICS namelist variables, and the module initializer is applied once
C at load time, before PARMIN runs and before the namelist read.
      DATA ANEWCP/'   '/
C 10/8/26 MHP via Claude
C code changed to add a blank default for ATMP: it had no DATA
C statement anywhere, so its storage was zero-initialized to NUL
C bytes rather than blanks. Harmless as long as nothing echoed it
C (IF(ATMP.EQ.'ABS') at line ~1173 just evaluates false either way,
C matching the LREL=.TRUE. default), but the new NML=PHYSICS echo
C writes it out verbatim, and raw NUL bytes turned .short into a
C binary-looking file. Blank matches the "not 'ABS'" default.
      DATA ATMP/'   '/
C MHP 10/24 ADDED NEW MIXTURE CONTROL ISETISO CONTROLS CNO ISOTOPE RATIOS AND
C LIGHT ELEMENT ABUNDANCES D,HE3,LI6,LI7,BE9,B10,B11 (1=USED)
C ISETMIX CONTROLS C+N+O MASS FRACTIONS (1=USED)
C AMIX AND AISO ARE STRINGS IDENTIFYING EITHER A PRESET MIXTURE OR A CUSTOM ONE ('CUS')
C SUPPORTED AMIX AT PRESENT ARE 'GS98','AAG21',M22M','M22P'. SUPPORTED AISO IS 'L21'.
C FOR A CUSTOM MIXTURE YOU CAN ENTER INDIVIDUAL VALUES.
C TO BE ADDED - AMIX FROM ATOMIC OPACITY TABLES (INEWMIX=2) AND OTHER MIXTURES/ISOTOPES
      DATA AMIX, AISO/'GS98', 'L21'/
C     L21 DEFAULT ISOTOPE DATA LODDERS ET AL. 2021 SSRV 217,44
C     GS98 DEFAULT CNO FRACTIONS OF METALS GREVESSE&sAUVAL 1998 SSRV 85,161
C MHP 10/24 DATA FOR CNO FRACTIONS AND Z/X OF DIFFERNT SOLAR MIXTURES.
C     AMIXT IS THE LIST OF IDS,EACH OF WHICH HAS A ZX AND CNO FRACS
C     ENTRY 1 =GS98(IN PARMIN),2=ASPLUND ET AL. 2021 A&A 653,141
C     3,4=MAGG ET AL. 2021 (MET,PHOT) A&A 661,140
      DATA AMIXT,ZXMIXT,FRAC_CT,FRAC_NT,FRAC_OT/'GS98','AAG21',
     *     'M22P','M22M',0.02292D0,0.0187D0,0.0225D0,0.0226D0,
     * 0.172148D0,0.184156D0,0.19239D0,0.191425D0,
     * 0.050426D0,0.050344D0,0.059012D0,0.058716D0,
     * 0.468195D0,0.416592D0,0.415631D0,0.413545D0/
C      ATIME(13) was orginally = 1.5.
C JVS 04/14
C 10/15/26 MHP via Claude
C code changed to remove DATA CMIXL/1.4D0/.  PARMIN's own CMIXL is a local
C that nothing reads -- ifort reports it as unused -- and it has been dead
C since CMIXL was dropped from the output-only DERIVED namelist on
C 10/13/26.  The mixing length the code actually uses is the scalar
C main.f:382 takes from the per-run vector as CMIXL = CMIXLA(NK), so a
C default here could never reach the run; keeping one would only suggest
C otherwise.  An illegal CMIXLA is now trapped below instead.
C       DATA DPENV,LNSTDMX,LOVSTC,ALPHAC,LOVSTE,ALPHAE, LOVSTM, ALPHAM
C      */1.0D0,.FALSE.,.FALSE., 0.0D0, .FALSE.,0.0D0, .FALSE., 0.0/
C JVS 07/13
C END JVS
      DATA ALFA, FK/1.5D0, 1.0D0/
C MHP 8/17 INITIALIZED WMAX_SUN
      DATA WMAX_SUN/1000.0/
C DBG PULSE DATA CARD FOR PULSATION
C 10/14/26 MHP via Claude
C code changed to move DATA CLSUN,CRSUN/3.8515D33,6.9598D10/ into
C CONSTANTS_MOD as initializers, since DATA on a USE-associated name is
C rejected.  Same effect: both are PHYSICS namelist variables, and the
C module initializer is applied at load time, before this routine runs
C and before the namelist read.  CLSUNL and CRSUNL are derived from them
C later, in setups.f.
C DBG If LCORE is TRUE then calculate shells interior to start up
C     model's inner most shell.
C MHP 5/90 NEW DATA STATEMENTS FOR NEW PARAMETERS
C DBGLAOL
C DBG 11/11/91
C 9/25/26 MHP via Claude
C code changed to add a default for FSOUND matching the previous
C hardcoded Csound.dat behavior; overridable via the CONTROL namelist
      DATA FSOUND/'Csound.dat'/
C 10/8/26 MHP via Claude
C code changed to add blank defaults for the remaining CONTROL/PHYSICS
C CHARACTER namelist variables that had none. Each is always set by
C every current test's namelist anyway, but with no DATA default their
C storage zero-initializes to NUL bytes rather than blanks; harmless
C as long as nothing echoed them, but the new NML=CONTROL/PHYSICS echo
C (see above) writes every member verbatim, and raw NULs turn .short
C into a binary-looking file for any run that leaves one of these
C unset (as FDEBUG and FSTCH, both legacy/unused outputs, always are).
C A single blank is padded to each variable's full declared length by
C the compiler, same as ANEWCP's existing default above. FALEX06,
C FALLARD, FATM, FFERMI, FLIV95, FPATM, FPENV, FPMOD, FPUREZ, FSCVH,
C FSCVHE, FSCVZ are PARMIN's own dummy arguments (not local variables,
C can't take a DATA default here) but are always explicitly set by
C every current test's namelist, so are not at risk in practice.
      DATA DESCRIP/2*' '/
      DATA FDEBUG,FFIRST,FLAST/3*' '/
      DATA FMILNE,FMODPT,FOPALE06,FSCOMP/4*' '/
      DATA FSHORT,FSNU,FSTCH,FSTOR,FTRACK,FcondOpacP/6*' '/
C 3/92 DBG
C DBG PULSE OUT 7/92
C MHP 06/13 ADDED FLAG TO CALIBRATE TO SOLAR Z/X, SOLAR Z/X, SOLAR AGE
C      DATA TOLL,TOLR,LCALS/1.0D-5,1.0D-4,.FALSE./
C DBG 4/94 ZRAMP STUFF
C DBG 12/94 CALIBRATED STELLAR MODEL STUFF
C LLP >>> OPAL 2006 EOS, Potekhin Conductive Opacities,
C         Use Numerical Derivitives switches
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
C MHP 8/25 Removed hard coded defaults
C     Alex low T opacity
C      DATA OPECALEX/'OPACALEXANDER.X00',
C     +              'OPACALEXANDER.X01',
C     +              'OPACALEXANDER.X02',
C     +              'OPACALEXANDER.X035',
C     +              'OPACALEXANDER.X05',
C     +              'OPACALEXANDER.X07',
C     +              'OPACALEXANDER.X08'/

C DBG 1/96 THE ARRAY V, READ IN VIA RDLAOL, CONTAINED THE MASS FRACTIONS
C OF THE ENVELOPE ELEMENTS. IT WAS USED IN STARIN TO DEFINE FXENV,
C WHICH ARE THE NUMBER FRACTION OF THE ENVELOPE ELEMENTS. FXENV WAS
C THEN UPDATED IN EQSTAT AND EQSAHA. HERE WE DEFINE VNEW PASSED
C IN A COMMON BLOCK VNEWCB. IT IS IDENTICAL TO V EXCEPT THAT THE NUMBERS
C ARE DEFINED HERE EXPLICITY FOR A G&N93 SOLAR MIXTURE. YOU CAN
C CHANGE THEM VIA THE PHYSICS NAMELIST. V IS SET EQUAL TO VNEW IN
C  STARIN EXCEPT WHEN LLAOL=T (TO MAINTAIN BACKWARD COMPATIBILITY.
C            Na          Al          Mg          Fe
C            Si          C           H           O
C            N           Ar          Ne          He
C MHP 5/97 OPTION FOR SAUMON, CHABRIER, AND VAN HORN EOS ADDED
C MHP 3/99 OPTION FOR SB ROTATION ENFORCED IN THE ENTIRE STAR AT
C ALL TIMES
C JNT 09/2025 FOR 05/15 IMPJMOD default set to 0
C mhp 8/10 added scaled solar wind mass loss option
C      DATA LSOLWIND,DMSUN,DMWSUN,DMWMAX/.FALSE.,-2.0D-14,2.863E-6,9.054E-5/
C 3/09 Alexander 2006 opacity table options and opacity ramp options
CFD 10/09 Mimic mixing options - acting on setling and differential settling
C JVS 02/11 Initialize acoustic depth common block values appropriately
C JVS end
C MHP 02/12 NEW PARAMETERIZATION OF ANGULAR MOMENTUM AND MASS LOSS
C FROM MAGNETIZED SOLAR-LIKE WINDS
C      DATA LPMM,PMMA,PMMB,PMMC,PMMM,PMMJD,PMMMD,PMMWMAX,
C     *     PMMSOLP,PMMSOLW,PMMSOLTAU
C     *   /.FALSE.,2.0D0,1.0D0,0.0D0,0.22D0,1.32E30,1.27E12,
C     *     2.836E-5,4.9304D0,2.836E-6,1.065E6/
C G Somers 6/16 NEW PARAMETERIZATION OF ANGULAR MOMENTUM AND MASS LOSS FROM
C SOLAR WINDS. FOLLOW MATT ET AL (2012) FORMULATION, BUT DEFAULT TO KAWALER
C TYPE LAW.
C MHP 8/17 CHANGED DEFAULT FOR PMMA TO 2 FROM 0
      DATA AWIND/'K97'/
C MHP 02/12 PERMIT CONSTANT DIFFUSION COEFFICIENT
C
C G Somers 06/14 ALLOW NEW LI DESTRUCTION CROSS SECTIONS
C           NEW VALUES SHOULD BE IN UNITS OF keV b.
C           DEFAULT LI6 = 5,500 keV b FROM FOWLER ET AL. 1967
C           DEFAULT LI7 = 52 keV b FROM ROLFS & KAVANAGH 1986
C           DEFAULT BE9(P,G)B10 (BE91) = 1.1 keV b INFERRED FROM FOWLER 1988
C               THEY DON'T SHOW THIS REACTION, SO THIS IS APPROXIMATE.
C           DEFAULT BE9(P,D)2HE4 (BE92) = 15,000 keV b FROM FOWLER ET AL. 1967
C           DEFAULT BE9(P,A)LI6 (BE93) = 15,000 keV b FROM FOWLER ET AL. 1967
C G Somers END
C MHP 8/14 DEFAULT CROSS-SECTIONS ARE TAKEN FROM THE SOLAR FUSION II PAPER
C REFERENCE ADELBERGER ET AL. 2011. UNITS ARE KeV b
C NOTE: PEP IS THE PROPORTIONALITY CONSTANT RELATIVE TO PP
C NOTE: BE7+E- IS THE PROPORTIONALITY CONSTANT IN THE LINEAR TERM
C THE CODE USES T9, NOT T6, SO ANY EXPRESSION IN TERMS OF T/10^6 K
C NEEDS TO BE DIVIDED BY 1000^0.5 (FOR BOTH PEP AND BE7+E-)
C REFERENCE FIRST DERRIVATIVES OF CROSS-SECTIONS (ADELBERGER ET AL. 2011)
C UNITS ARE b
C REFERENCE SECOND DERIVATIVES OF CROSS SECTIONS (ADELBERGER ET AL. 2011)
C DEFAULT TO YES FOR NEW TAUCZ CALCULATION
C
C THIS SUBROUTINE READS ALL USER DEFINED QUANTITIES FROM THE
C FILES yrec8.nml1 and yrec8.nml2
C VALUES FOR LOGICAL UNITS USED IN READS AND WRITES SET IN DATA
C STATEMENT; THEY CAN BE CHANGED IN THE NAMELIST IF NEEDED.
C LOGICAL UNIT 5 = READ FROM SCREEN
C LOGICAL UNIT 6 = WRITE TO SCREEN: FOR BATCH USE STATUS FILE INSTEAD
C SPECIFY ALL LOGICAL UNIT NUMBERS HERE:
C OUTPUT: STATUS FILE
      IOWR = 6
C OUTPUT: LAST MODEL (TEXT)
      ILAST = 11
C INPUT: FIRST MODEL (TEXT)
      IFIRST = 12
C INPUT: PHYSICS NAMELIST
      IRUN = 13
C INPUT: CONTROL NAMELIST
      ISTAND = 14
C INPUT: FERMI TABLES
      IFERMI = 15
C OUTPUT: RESERVED for DEBUGGING
      IDEBUG = 18
C OUTPUT: TRACK
      ITRACK = 19
C OUTPUT: ALL DIAGNOSTIC INFO
      ISHORT = 20
C OUTPUT: MILNE INVARIANT VARIABLES
      IMILNE = 21
C OUTPUT: SHELL BY SHELL INFO ON MODELS
      IMODPT = 22
C OUTPUT: SAVED MODELS, CAN BE USED AS STARTING MODEL
      ISTOR = 23
C OUTPUT: FOR PULSATION CODE, INTERIOR
      IOPMOD = 24
C OUTPUT: FOR PULSATION CODE, ENVELOPE
      IOPENV = 25
C OUTPUT: FOR PULSATION CODE, ATMOSPHERE
      IOPATM = 26
C 9/25/26 MHP via Claude
C code changed to remove dead ILSTBN, ISTOBN, IFSTBN unit reservations
C (assigned here but never opened, read, or written anywhere; not even
C shared via a common block)
C OUTPUT: SOUND SPEED PROFILE (WRITTEN BY WRTMOD WHEN LSOUND IS TRUE)
      ISOUND = 500
C 9/24/26 MHP via Claude
C code changed to remove the Monte Carlo option
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C YCK INPUT: OPAL95 OPACITY TABLE
      ILIV95 = 48
C OUTPUT: SNU FLUXES
      ISNU = 33
C 9/25/26 MHP via Claude
C code changed to remove dead COMMON/LUNUM/ISCOMP unit reservation
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/25/26 MHP via Claude
C code changed to remove the LISO isochrone-output option
C INPUT: KURUCZ ATMOSPHER TABLE
      IOATM = 38
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
C INPUT: OPAL EQUATION OF STATE
      IOPALE = 49
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C INPUT: LAOL OPACITIES FOR PURE CN IN DENSE GRID FORMAT
      IOPUREZ = 62
C DBG 4/94
C     INPUT:
C DBG 8/95 SECOND OPOACITY TABLES FOR ZRAMP AND Z DIFFUSION
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C MHP 6/97 ADDED OPTION FOR ALLARD MODEL ATMOSPHERES
      IOATMA = 66
C 9/24/26 MHP via Claude
C code changed to remove the Monte Carlo option
C INPUT FILES FOR THE SCV EOS
      ISCVH=72
      ISCVHE=73
      ISCVZ=74
C Input files for Potekhin conductive opacities. LLP 7/8/06
      IcondOpacP = 75
C      FcondOpacP = 'condall.d'
C Default FeH and Alpha for new Allard Atmospheres
      ALATM_FeH = 0D0
      ALATM_Alpha = 0D0
      LALTPTAU100 = .FALSE.
C 3/09 Input file for 2006 Alexander opacities
      IALEX06 = 90

      print *,''
      print *,'Yale Rotating Evolution Code - YREC, v',YRECVER(1:LEN_TRIM(YRECVER)),' (',GITHASH(1:LEN_TRIM(GITHASH)),')'

C JVS 02/11 Altered the yrec8 input format so that files can be entered
C on the command line, with the *.nml1 as the first argument, and *.nml2 as
C the second. Defaults to yrec8.nml1 and yrec8.nml2 if none are provided.
c      OPEN(UNIT=ISTAND, FILE='yrec8.nml1', STATUS='OLD')
c      OPEN(UNIT=IRUN, FILE='yrec8.nml2', STATUS='OLD')
c      READ(UNIT=ISTAND, NML=CONTROL)
c      READ(UNIT=IRUN, NML=PHYSICS)
c      CLOSE(ISTAND)
c      CLOSE(IRUN)

C Dynamically create format string so version info is nicely spaced
      WRITE(VERFMT, 315) LEN_TRIM(YRECVER), LEN_TRIM(GITHASH)
  315 FORMAT('(''# YREC v'', A', I2.2, ', '' ('', A', I2.2,
     *       ', '')'')')

      CALL GETARG(1, YREC1)
      IF (YREC1(1:2) .EQ. ' ') YREC1 = 'yrec8.nml1'
      print *, ' '
      write(*,*) 'CONTROL namelist :  ',YREC1(1:LEN_TRIM(YREC1))

      CALL GETARG(2, YREC2)
      IF (YREC2(1:2) .EQ. ' ') YREC2 = 'yrec8.nml2'
      write(*,*) 'PHYSICS namelist :  ',YREC2(1:LEN_TRIM(YREC2))

      OPEN(UNIT=ISTAND, FILE=YREC1, STATUS='OLD')
      OPEN(UNIT=IRUN, FILE=YREC2, STATUS='OLD')
      READ(UNIT=ISTAND, NML=CONTROL)
      READ(UNIT=IRUN, NML=PHYSICS)
      CLOSE(ISTAND)
      CLOSE(IRUN)
C MHP 8/14 SUBROUTINE TO CONVERT MORE USER-FRIENDLY INPUT VARIABLES
C INTO THE VECTORS USED IN THE CODE (SUPERCEDES OLDER INPUTS)
      CALL REMAP
C MHP 06/13 Added memory of whether the choice of atmospheres has
C been changed during the run, and what the original setting was
      KTTAU0 = KTTAU
      LTTAU = .FALSE.
C 9/25/26 MHP via Claude
C 10/8/26 MHP via Claude
C code changed to resolve the fort.20 live issue noted above (now
C removed): the namelist echo belongs after ISHORT is OPENed, not
C here. Moved to just past OPEN(ISHORT,...), alongside the rest of
C the run-parameter echo -- see the NML=PHYSICS/CONTROL/DERIVED
C writes there.

C Post-process all CONTROL namelist vars that hold path values.
C Expand any placeholders found in the string with the value taken from a
C corresponding environment variable, if one is defined.
      CALL EXPAND_VALUE(FALEX06)
      CALL EXPAND_VALUE(FALLARD)
      CALL EXPAND_VALUE(FATM)
      CALL EXPAND_VALUE(FcondOpacP)
      CALL EXPAND_VALUE(FFERMI)
      CALL EXPAND_VALUE(FFIRST)
      CALL EXPAND_VALUE(FLAST)
      CALL EXPAND_VALUE(FLIV95)
      CALL EXPAND_VALUE(FMODPT)
      CALL EXPAND_VALUE(FOPALE06)
      CALL EXPAND_VALUE(FPATM)
      CALL EXPAND_VALUE(FPENV)
      CALL EXPAND_VALUE(FPMOD)
      CALL EXPAND_VALUE(FPUREZ)
      CALL EXPAND_VALUE(FSCOMP)
      CALL EXPAND_VALUE(FSCVH)
      CALL EXPAND_VALUE(FSCVHE)
      CALL EXPAND_VALUE(FSCVZ)
      CALL EXPAND_VALUE(FSHORT)
      CALL EXPAND_VALUE(FSNU)
      CALL EXPAND_VALUE(FSOUND)
      CALL EXPAND_VALUE(FSTOR)
      CALL EXPAND_VALUE(FTRACK)

C Create output directory as specified in the FTRACK value of CONTROL
C namelist if it doesn't already exist.
      ! find index of last '/' char. Use that to snip out the directory name.
      DO I = LEN_TRIM(FTRACK), 1, -1
          IF (FTRACK(I:I) .EQ. '/') THEN
              LAST_SLASH_IDX = I
              GOTO 1250
          ENDIF
      END DO
1250  CONTINUE
      CMD = 'mkdir -p "' // FTRACK(1:LAST_SLASH_IDX) // '"'
      print *,"OUTPUT placed in :  ",FTRACK(1:LAST_SLASH_IDX)
      print *, ''
      CALL system(CMD)


C JVS 02/11 Acoustic depth/ Asteroseismic glitch output. Puts output
C in the same directory as all other output, and names it with the
C same conventions
      IF (LACOUT) THEN
            ICLCD = 91
            MRK=INDEX(FSHORT,'short')
            FCLCD=FSHORT(1:MRK-1)//'calcad'
            OPEN(UNIT=ICLCD, FILE=FCLCD, STATUS='UNKNOWN')
            WRITE(ICLCD,*) 'Acoustic depth calculation output file'
            WRITE(ICLCD,*) 'age (Gyr),radius(cm),1/sound speed(s/cm),radius (CZ), 1/cs (CZ)
     *       delad,gamma1,P, T, X'


C 9/25/26 MHP via Claude
C code changed to remove dead IACAT, IJVS, IJENT, IJDEL unit
C reservations (all were declared but never opened anywhere)
C            IJLAST = 93
C            FJLAST=FSHORT(1:MRK-1)//'jlast'
C            OPEN(UNIT=IJLAST, FILE=FJLAST, STATUS='UNKNOWN')
      ENDIF


C JVS END
C
C G Somers 6/14, DEFINE SCALING COEFFICIENT FOR LI/BE CROSS SECTIONS
C          DEFAULT LI6 = 5.5 MeV b FROM FOWLER ET AL. 1967
C          DEFAULT LI7 = 52 keV b FROM ROLFS & KAVANAGH 1986
C           DEFAULT BE9(P,G)B10 (BE91) = 1.1 keV b INFERRED FROM FOWLER 1988
C           DEFAULT BE9(P,D)2HE4 (BE92) = 15,000 keV b FROM FOWLER ET AL. 1967
C           DEFAULT BE9(P,A)LI6 (BE93) = 15,000 keV b FROM FOWLER ET AL. 1967
      IF (LXLI6) THEN
          SLI6 = XSLI6/5.5D3
      ENDIF
      IF (LXLI7) THEN
          SLI7 = XSLI7/5.2D1
      ENDIF
      IF (LXBE91) THEN
          SBE91 = XSBE91/1.1D0
      ENDIF
      IF (LXBE92) THEN
          SBE92 = XSBE92/1.5D4
      ENDIF
      IF (LXBE93) THEN
          SBE93 = XSBE93/1.5D4
      ENDIF
C G Somers END
C MHP 8/25 open relevant table as well as ensuring that only one is selected
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
      IF (LOPALE06) THEN
         OPEN(IOPALE, FILE=FOPALE06,STATUS='OLD')
      ENDIF
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables

      OPEN(ISTOR,FILE=FSTOR,FORM='FORMATTED',STATUS='UNKNOWN')
      REWIND(ISTOR)
C G Somers 11/14 write the new header for the .store file, if LSTORE = TRUE.
      IF(LSTORE)THEN
C JvS 08/25 Added stitched interior and envelope option      
         IF(LSTCH)THEN
            LPHHD = .TRUE.
         ELSE
            WRITE(ISTOR,VERFMT) YRECVER, GITHASH
            WRITE(ISTOR,1012)
         ENDIF   
      ENDIF
 1012 FORMAT('# Header Key',/,'# ModType    ModNum    #Shells    ',
     1 'M/Msun    log(Teff)    log(L/Lsun)    log(M/gram)    Age/Gyr',
     1 '    Timestep/yr    log(M_inner/gram)    log(M_outer/gram)',/,
     1 '# JCORE  JENV  CMIXL  EOS  ATM  ALOK HIK  LPUREZ  COMPMIX',
     1 '  LEXCOM  LDIFY  LDIFZ  LSEMIC  LOVSTC  LOVSTE  LOVSTM',
     1 '  LROT  LINSTB  LJDOT0  LDISK  TDISK  PDISK  WMAX  LSTORE',
     1 '  LSTATM  LSTENV  LSTMOD  LSTPHYS  LSTROT',/,'# PPI_lum',
     1 '    PPII_lum    PPIII_lum    CNO_lum    3He_lum    ',
     1 'OldNeu_lum    Grav_lum',/,'# ENV1-3   log(Teff)',
     1 '    log(L/Lsun)    P_base    T_base    R_base    MatrixElements'
     1 ,/)
C 1013 FORMAT('# JCORE  JENV  CMIXL  EOS  ATM  ALOK HIK  LPUREZ  COMPMIX',
C     1 '  LEXCOM  LDIFY  LDIFZ  LSEMIC  LOVSTC  LOVSTE  LOVSTM',
C     1 '  LROT  LINSTB  LJDOT0  LDISK  TDISK  PDISK  WMAX  LSTORE',
C     1 '  LSTATM  LSTENV  LSTMOD  LSTPHYS  LSTROT'
C     1 ,/)
C 1014     FORMAT(
C     1'MODEL SHELL MASS RADIUS LUMINOSITY PRESSURE TEMPERATURE DENSITY OMEGA ',
C     1'CONVECTIVE INTERIOR_PT H1 He4 METALS He3 C12 C13 N14 N15 O16 O17 O18 H2 Li6 Li7 ',
C     1'Be9 OPACITY GRAV DELR DEL DELAD V_CONV GAM1 HII HEII HEIII BETA ',
C     1'ETA PPI PPII PPIII CNO TRIPLE_ALPHA E_NUC E_NEU E_GRAV CP DLNRHODLNT A RP/RE FP ',
C     1'FT J/M MOMENT DEL_KE V_ES V_GSF V_SS VTOT ')
C G Somers END

      OPEN(ISHORT,FILE=FSHORT,FORM='FORMATTED',STATUS='UNKNOWN')
      REWIND(ISHORT)
C 9/25/26 MHP via Claude
C code changed to open the sound-speed-profile output (previously
C hardcoded to unit 500/'Csound.dat' in wrtmod.f) here instead, using
C the managed ISOUND unit and FSOUND filename. Opened unconditionally
C since LSOUND is only known at runtime, well after PARMIN returns.
C Rewound explicitly so every run starts with a clean file even if
C LSOUND never becomes true this run (STATUS='UNKNOWN' alone does not
C truncate/reposition an existing file on OPEN, so without this a
C stale file from an earlier LSOUND-triggering run would otherwise be
C left in place, opened but unwritten, and could be mistaken for
C fresh output).
      OPEN(ISOUND,FILE=FSOUND,FORM='FORMATTED',STATUS='UNKNOWN')
      REWIND(ISOUND)
      IF (LTRACK) THEN
          OPEN(UNIT=ITRACK,FILE=FTRACK, FORM='FORMATTED',
     *        STATUS='UNKNOWN')
          REWIND(ITRACK)
      ENDIF

C SNU OUTPUT
      IF(LSNU) THEN
          OPEN(UNIT=ISNU,FILE=FSNU, FORM='FORMATTED',
     *        STATUS='UNKNOWN')
          REWIND(ISNU)
      ENDIF
      IF(LDEBUG) THEN
            OPEN(IDEBUG,FILE=FDEBUG,FORM='FORMATTED',
     *         STATUS='UNKNOWN')
      END IF
C     MHP Moved opening of FMILNE here, no need to do elsewhere
      IF(LMILNE)THEN
         OPEN(UNIT=IMILNE,FILE=FMILNE,FORM='FORMATTED',
     *     STATUS='UNKNOWN',ACCESS='APPEND')
      ENDIF
C     MHP 10/02 LBNIN never set, ignore loop
C      IF (.NOT.LBNIN) THEN
         OPEN(UNIT=IFIRST,FILE=FFIRST,FORM='FORMATTED',STATUS='OLD')
C      END IF
      OPEN(UNIT=ILAST,FILE=FLAST,FORM='FORMATTED',STATUS='UNKNOWN')
      OPEN(UNIT=IMODPT,FILE=FMODPT,FORM='FORMATTED',STATUS='UNKNOWN')
C     OPEN ALL PULSE FILES
      IF(LPULSE) THEN
      OPEN(IOPMOD, FILE=FPMOD,STATUS='UNKNOWN',FORM='FORMATTED')
      OPEN(IOPENV, FILE=FPENV,STATUS='UNKNOWN',FORM='FORMATTED')
      OPEN(IOPATM, FILE=FPATM,STATUS='UNKNOWN',FORM='FORMATTED')
      END IF
C 9/24/26 MHP via Claude
C code changed to remove the Monte Carlo option
C     MHP 8/25 Moved opening of conductive opacity and EoS tables here, to avoid complicated passages of declared variables.
      IF(LcondOpacP)then
         open(IcondOpacP,file=FcondOpacP,status='OLD')
      ENDIF
C 9/25/26 MHP via Claude
C code changed to remove the LISO isochrone-output option
      IF(LSEMIC)THEN
         IF(LOVSTC.OR.LOVSTE.OR.LOVSTM)THEN
            WRITE(ISHORT,2)LSEMIC,LOVSTE,LOVSTC,LOVSTM
    2       FORMAT(1X,'ERROR IN SUBROUTINE PARMIN'/'SEMI-CONVECTION',
     * ' AND OVERSHOOT FLAGS BOTH TURNED ON'/'FLAGS LSEMIC',L2,
     * ' OVERSHOOT - CORE,ENVELOPE,INTERMEDIATE-',3L2/'RUN STOPPED')
            STOP
         ENDIF
      ENDIF
      WRITE(ISHORT,1)(HPTTOL(I),I=1,12),ALPHAE,ALPHAC,LINSTB,LJDOT0,
     *              ALFA,FK,FW,FC,FO,FMU,RCRIT
    1 FORMAT(1X,'PT TOL',12F6.3/1X,'O.S.ENV',F6.3,' O.S.CORE',F6.3,
     *       ' LINSTB ',L1,' LJDOT ',L1,' WIND IND.',F6.3,' FK',
     *       1PE8.2/1X,' FV',0PF5.2,' FC',F5.2,' COUPLING'
     *       ,F6.3, ' F MU',F5.2,' RCRIT',F9.1)
C 10/13/26 MHP via Claude
C code changed to remove the TENV derivation: it existed only to populate
C COMMON/CTLIM/ for envint.f, which now derives it itself.
      IF(LROT) THEN
         LNEW0 = .TRUE.
         IF(WALPCZ.LT.-2.0D0) WALPCZ = -2.0D0
         IF(WALPCZ.GT.0.0D0) WALPCZ = 0.0D0
C JNT 09/2025 LSOLID OVERWRITES IMPJMOD
         IF(LSOLID) IMPJMOD = 1
CCCCCC OLD OR NEW WINDLAW.
         IF(.NOT.LMWIND)THEN
CCCCCC INSTRUCTIONS FOR THE OLD WINDLAW
CCCCCC
CCCCCC SET UP COEFFICIENTS FOR ANGULAR MOMENTUM LOSS VIA WINDS.
CCCCCC GIVEN THE INDEX ALFA, THE FORMULA FOR JDOT IS
CCCCCC JDOT = FK*2.036D33*1.452D9**ALFA*(MDOT/1.0D-14)**(1-2ALFA/3)
CCCCCC *OMEGA**(1+4ALFA/3)*(R/RSUN)**(2-ALFA)*(M/MSUN)**-ALFA/3
CCCCCC EXMD = EXPONENT OF MDOT TERM; EXW SAME FOR OMEGA;EXR FOR R;EXM FOR M.
CCCCCC FK IS A FUDGE FACTOR,SET TO 1 TO REPRODUCE THE OBSERVED SOLAR ANGULAR
CCCCCC MOMENTUM LOSS.
            CC13 = 1.0D0/3.0D0
            CC23 = 2.0D0/3.0D0
            CONSTFACTOR = FK*2.036D33*1.452D9**ALFA
            EXMD = 1.0D0 - CC23*ALFA
            EXW = 1.0D0 + 2.0D0*CC23*ALFA
            EXR = 2.0D0 - ALFA
            EXM = -CC13*ALFA
C
C INSTRUCTIONS FOR THE NEW WINDLAW
C
C SET UP INDICES FOR LOSS LAW IN TERMS OF PMM A, B, C, M.
C INCLUDE A PMMD AS WELL, FOR TURNING TAUCZ and CENTRIFUG DEPENDENCE ON/OFF.
C EXCEN = EXPONENT FOR CENTRIFUGAL TERM, {K2^2/(K2^2+0.5*W^2 R^3/GM)}^PMMM
C
C AWIND = 'K97' ENFORCES KRISHNAMURTHI (1997) WIND LAW.
C AWIND = 'V13' ENFORCES VAN SADERS + PINSONNEAULT (2013) WIND LAW, AS ADAPTED
C         FROM MATT ET AL. (2008,2012).
C AWIND = 'CUS' ADOPTS THE M-D VALUES GIVEN IN THE NAMELIST.
C
C
C THEN CONVERT THE PMM VALUES INTO EXPONENTS FOR THE TORQUE CALCULATION.
C BASIC EQUATIONS, WHERE EVERY TERM IS SCALED TO SOLAR, ARE:
C
C Jdot = w * Bmag^4m * Mdot^1-2m * R^5m+2 * M^-m * Fcen^md
C Bmag = Pphot^0.5 * (w * R^c)^b * Tcz^d
C GM/R * Mdot = (Lx/Lbol * Lbol)^a -> Mdot = R * M^-1 * Lbol * w^a
C ...where Lx/Lbol is assumed to scale with w to the power of a.
C
C THIS GIVES:
C JDOT ~ w ^ 1+a-2ma+4mb
C      ~ Tcz ^ 4md
C      ~ R ^ 3+3m+4mbc
C      ~ M ^ m-1
C      ~ Lbol ^ 1-2m
C      ~ Pphot ^ 2m
C      ~ Fcen ^ md
C
C For moment, ignore GM/R term in Mdot. This makes:
C JDOT ~ R ^ 2+5m+4mbc
C JDOT ~ M ^ -m
C
         ELSE
            IF(AWIND.EQ.'K97')THEN
               PMMM = ALFA/3.0
C MHP 8/17 CORRECT DEFAULT FOR A = 2, NOT 0
               PMMA = 2.0
               PMMB = 1.0
               PMMC = 2.0
               PMMD = 0.0
               LBSCALE = .FALSE.
            ELSEIF(AWIND.EQ.'V13')THEN
               PMMM = 0.22D0
               PMMA = 2.0
               PMMB = 1.0
               PMMC = 0.0
               PMMD = 1.0
               LBSCALE = .TRUE.
            ENDIF
            EXW   = 1.0D0 + PMMA - 2.0D0*PMMA*PMMM + 4.0D0*PMMM*PMMB
C G Somers 8/17 ZERO'D OUT EXTAU. TAUCZ TERM NOW COMPUTED IN
C MWIND/MCOWIND, NOT IN AMCALC.
C            EXTAU = 4.0D0*PMMM
            EXTAU = 0.0
C JvS 09/25 REMOVED TYPO IN EXR = 2.0D0+5.0D0*PMMM-4.0D0*PMMM*PMMB*PMMC
            EXR   = 2.0D0+5.0D0*PMMM-4.0D0*PMMM*PMMC
            EXM   = -PMMM
            EXL   = 1.0D0 - 2.0D0*PMMM
C G Somers 11/17, ADDED PMMD TO SWTICH OFF IN K97 FORM.
            EXPR  = 2.0D0*PMMM*PMMD
            EXCEN = PMMM*PMMD
C INITIALIZE CONSTANT FACTOR FOR CENTRIFUGAL TERM
            C_2 = 0.0506D0
C SET THE CONSTANT FACTOR
            CONSTFACTOR = FK*PMMJD/PMMSOLW**EXW
C IF RELEVANT RESET THE SATURATION THRESHOLD IN
C TERMS OF THE SOLAR ROTATION RATE.  WMAX_SUN<1000
C INDICATES SATURATION (AT THE SUN), SO
C WSAT = WMAX_SUN*PMMSOLW
            IF(WMAX_SUN.LT.1.0E3)THEN
               WMAX = WMAX_SUN*PMMSOLW
            ENDIF
         ENDIF
      ENDIF
C     WINDLAW END
C
      CLN = DLOG(10.0D0)
      IF(LNEWCP) THEN
       LREL = .TRUE.
       IF(ATMP.EQ.'ABS') LREL = .FALSE.
C DECIDE WHICH ELEMENT IN ARRAY HCOMP TO BE RESCALED
C USING CHARACTER ARRAY AID AND INPUT CHARACTER VARIABLE ANEWCP
       DO 10 I = 1,12
          IF(ANEWCP.EQ.AID(I)) THEN
C INEWCP IS THE INDEX OF THE ELEMENT BEING ALTERED
            INEWCP = I + 3
            GOTO 30
          ENDIF
   10    CONTINUE
C ANEWCP NOT A RECOGNIZED ELEMENT
       LNEWCP = .FALSE.
       WRITE(ISHORT,20) ANEWCP
   20    FORMAT(1X,'VARIABLE',A4,1X,'NOT A RECOGNIZED ELEMENT'/1X,
     *   'RESCALING NOT PERFORMED')
   30    CONTINUE
      ENDIF
      LMIXTURE = .FALSE.
      LISOTOPE = .FALSE.
      IF(ISETMIX.EQ.1)THEN
C IF DEFAULT MIX (GS98) CNOFRACS ARE ALREADY SET.
C         IF(AMIX.EQ.'GS98')THEN
C            LMIXTURE = .TRUE.
C            GOTO 606
C         ENDIF
C FOR A CUSTOM MIX,DISABLE IF THE SUM OF CNO MASS FRACTIONS EXCEEDS ONE
C OR IF ANY MASS FRACTION IS NEGATIVE
         IF(AMIX.EQ.'CUS')THEN
            IF(FRAC_C.LT.0.0D0.OR.FRAC_N.LT.0.0D0.OR.FRAC_O.LT.0.0D0)THEN
               WRITE(*,591)FRAC_C,FRAC_N,FRAC_O
               WRITE(ISHORT,591)FRAC_C,FRAC_N,FRAC_O
 591           FORMAT('NEGATIVE INPUT CNO FRACTION ',3E12.4,
     *             ' MIX NOT MODIFIED')
               GOTO 602
            ENDIF
            SUM_FRAC=FRAC_C+FRAC_N+FRAC_O
            IF(SUM_FRAC.GE.1.0D0)THEN
               WRITE(*,598)FRAC_C,FRAC_N,FRAC_O
               WRITE(ISHORT,598)FRAC_C,FRAC_N,FRAC_O
 598           FORMAT('INPUT CNO FRACTION ',3E12.4,
     *             ' EXCEEDS 1. MIX NOT MODIFIED')
               GOTO 602
            ENDIF
C VALID MIXTURE, USE CUSTOM ENTRIES FROM .NML1
            LMIXTURE = .TRUE.
            GOTO 606
         ENDIF
C SEARCH THROUGH OTHER VALID MIXTURE ENTRIES;IF FOUND,ASSIGN
C         DO I = 2,4
         DO I = 1,4
            IF(AMIX.EQ.AMIXT(I))THEN
               ZXMIX = ZXMIXT(I)
               FRAC_C = FRAC_CT(I)
               FRAC_N = FRAC_NT(I)
               FRAC_O = FRAC_OT(I)
               LMIXTURE = .TRUE.
               GOTO 606
            ENDIF
         END DO
C     NO VALID MIX SPECIFIED
         WRITE(*,589)AMIX
         WRITE(ISHORT,589)AMIX
 589     FORMAT('DESIRED CNO MIXTURE ',A8,' NOT FOUND. MIX NOT ALTERED.')
      ENDIF
 606  IF(LMIXTURE)THEN
         WRITE(*,604)AMIX,FRAC_C,FRAC_N,FRAC_O
         WRITE(ISHORT,604)AMIX,FRAC_C,FRAC_N,FRAC_O
 604     FORMAT('CNO MIXTURE ',A8,' C ',E12.4,' N ',E12.4,' O ',
     *        E12.4,' APPLIED TO STARTING MODEL.')
      ENDIF
C     CHECK IF ISOTOPE RATIOS NEED TO BE ALTERED
 602  IF(ISETISO.EQ.1)THEN
C FOR A CUSTOM MIX,DISABLE IF THE SUM OF CNO MASS FRACTIONS EXCEEDS ONE
C OR IF ANY MASS FRACTION IS NEGATIVE
         IF(AISO.EQ.'CUS')THEN
            IF(R12_13.LT.0.0D0 .OR. R14_15.LT.0.0D0 .OR. R16_17.LT.0.0D0
     * .OR. R16_18.LT.0.0D0 .OR. XH2_INI.LT.0.0D0 .OR. XHE3_INI.LT.0.0D0
     * .OR. XLI6_INI.LT.0.0D0 .OR. XLI7_INI.LT.0.0D0 .OR.
     * XBE9_INI.LT.0.0D0.OR.XB10_INI.LT.0.0D0 .OR.XB11_INI.LT.0.0D0)THEN
               WRITE(*,596)R12_13,R14_15,R16_17,R16_18,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,XB10_INI,XB11_INI
               WRITE(ISHORT,596)R12_13,R14_15,R16_17,R16_18,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,XB10_INI,XB11_INI
 596           FORMAT('NEGATIVE INPUT ISOTOPE RATIO OR LIGHT ELEMENT'
     *  ' MASS FRACTION ',11E12.4,
     *             ' MIX NOT MODIFIED')
               GOTO 603
            ENDIF
            SUM_FRAC= XH2_INI+XHE3_INI+XLI6_INI+XLI7_INI+XBE9_INI+
     *                XB10_INI+XB11_INI
            IF(SUM_FRAC.GE.1.0D0)THEN
               WRITE(*,595)XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,
     * XB10_INI,XB11_INI
               WRITE(ISHORT,595)XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,
     * XBE9_INI,XB10_INI,XB11_INI
 595           FORMAT('SUM OF LIGHT ELEMENT MASS FRACTIONS EXCEEDS 1',
     * 11E12.4,' MIX NOT MODIFIED')
               GOTO 603
            ENDIF
C     CURRENTLY THERE ARE ONLY 2 VALID OPTIONS - THE DEFAULT (L21) OR
C A CUSTOM MIXTURE (CUS) - IF NEITHER IS TRUE, EXIT
         ELSE IF(AISO.NE.'L21')THEN
            GOTO 603
         ENDIF
C     PASSED ALL CHECKS - EITHER THE DEFAULT OR THE CUSTOM SETTINGS WILL BE APPLIED
         LISOTOPE = .TRUE.
      ENDIF
      IF(LISOTOPE)THEN
         WRITE(*,605)AISO,R12_13,R16_18,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI
         WRITE(ISHORT,605)AISO,R12_13,R16_18,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI
 605     FORMAT('ISOTOPE AND LIGHT ELEMENT MIXTURE ',A8,' C12/C13 ',
     *   E12.4,' O16/O18 ',E12.4,' H2 ',E12.4,' HE3 ',E12.4,' LI6 ',
     *   E12.4,' LI7 ',E12.4,' BE9 ',E12.4,' APPLIED TO STARTING MODEL.')
      ENDIF
C DBG 12/95 ENSURE CORRECT PARAMETERS FOR Z DIFFUSION
 603  IF (LDIFZ) THEN
           LDIFY=.TRUE.
         LTHOUL=.TRUE.
      END IF

C G SOMERS 04/15; ENSURE CORRECT PARAMETERS FOR LIGHT ELEMENT DIFFUSION.
      IF(LDIFLI)THEN
          LNEWDIF=.TRUE.
          LDIFY=.TRUE.
          LDIFZ=.TRUE.
          LTHOUL=.TRUE.
          LTHOULFIT=.FALSE.
          ILAMBDA=4
      ENDIF

C     WRITE OUT RUN PARAMETERS.
C 10/8/26 MHP via Claude
C code changed to replace the hand-written STANDARD/CURRENT echo
C tables (which only covered a subset of namelist variables, had
C truncated arrays for ATIME/HPTTOL, and had a broken arg list on the
C old TRIDT/TRIDL line -- WRITE(ISHORT,45) TRIDT,TRIDL/TRIDT/TRIDL was
C parsed as two items, not four, despite FORMAT 45's four-column
C header) with a complete, always-in-sync echo of the actual PHYSICS
C and CONTROL namelists, plus a DERIVED namelist (declared above) for
C the handful of values that are only meaningful after post-namelist-
C read derivation/overrides (e.g. CMIXL, LREL, the LDIFLI-forced
C cascade). The NPOINT/NPENV/NPRTMOD/NPRTPT sentinel-default logic
C below is functional, not echo, and is preserved unchanged.
      IF(NPOINT.LE.0) NPOINT = 9999
      IF(NPENV.LE.0) NPENV = 9999
      IF(NPRTMOD.LE.0) NPRTMOD = 9999
      IF(NPRTPT.LE.0) NPRTPT = 9999
      WRITE(ISHORT,NML=PHYSICS)
      WRITE(ISHORT,NML=CONTROL)
      WRITE(ISHORT,NML=DERIVED)
C 10/15/26 MHP via Claude
C code changed to trap an illegal convective mixing length before the run
C starts.  CMIXLA is the per-run vector the mixing length is taken from --
C main.f:382 sets CMIXL = CMIXLA(NK) for each kind card -- and nothing
C validated it anywhere.  It has no default, so an entry the namelist
C never sets is zero, and a zero or negative mixing length is unphysical:
C the run fails further in, where the cause is no longer apparent.
C
C Only the entries that will actually be used are checked.  Under solar
C calibration just CMIXLA(1) comes from the namelist: SETCAL sets
C NUMRUN = 48 and fills entries 2..48 from CMIXLA(1), so checking the
C whole vector here would report entries the user never supplied.  The
C bound is MIN(NUMRUN,50) because CMIXLA is dimensioned 50 while NUMRUN
C is read from the namelist and is not itself range-checked.
C
C Placed after the namelist echo, unlike the LSEMIC/overshoot trap above,
C so that the .short file carries the inputs that caused the stop as well
C as the diagnosis.
      IF(LCALS)THEN
         NCMXCK = 1
      ELSE
         NCMXCK = MIN(NUMRUN,50)
      ENDIF
      LCMXBAD = .FALSE.
      DO I = 1,NCMXCK
         IF(CMIXLA(I).LE.0.0D0)THEN
            LCMXBAD = .TRUE.
            WRITE(ISHORT,8801)I,CMIXLA(I)
            WRITE(*,8801)I,CMIXLA(I)
         ENDIF
      END DO
 8801 FORMAT(1X,'ERROR IN SUBROUTINE PARMIN'/'ILLEGAL MIXING LENGTH:',
     * ' CMIXLA(',I2,') =',1PE12.4,' - MUST BE POSITIVE')
      IF(LCMXBAD)THEN
         IF(LCALS)THEN
            WRITE(ISHORT,8802)
            WRITE(*,8802)
         ELSE
            WRITE(ISHORT,8803)NCMXCK
            WRITE(*,8803)NCMXCK
         ENDIF
         STOP
      ENDIF
 8802 FORMAT('SOLAR CALIBRATION IS ON, SO ONLY CMIXLA(1) IS READ FROM',
     * ' THE NAMELIST'/'RUN STOPPED')
 8803 FORMAT('CMIXLA MUST BE SET FOR EACH OF THE',I3,' KIND CARDS'/
     * 'RUN STOPPED')
      IF(KTTAU .EQ. 0) THEN
           WRITE(ISHORT, 197)
      ELSE IF (KTTAU .EQ. 1) THEN
           WRITE(ISHORT, 198)
      ELSE IF (KTTAU .EQ. 2) THEN
           WRITE(ISHORT, 1999)
      ELSE IF (KTTAU .EQ. 3) THEN
           WRITE(ISHORT, 1888)
      ELSE IF (KTTAU .EQ. 4) THEN
           WRITE(ISHORT, 1889)
C JNT 6/14 ADD FOR NEW KURUCZ/CASTELLI ATMOSPHERE TABLES
      ELSE IF (KTTAU .EQ. 5) THEN
           WRITE(ISHORT, 1887)
      END IF
  197 FORMAT(' USING EDDINGTON T-TAU RELATION.')
  198 FORMAT(' USING KRISHNA-SWAMY T-TAU RELATION.')
 1999 FORMAT(' USING HARVARD-SMITHSONIAN REFERENCE ATMOSPHERE')
 1888 FORMAT(' USING KURUCZ ATMOSPHERE TABLE')
 1889 FORMAT(' USING ALLARD ATMOSPHERE TABLE')
 1887 FORMAT(' USING KURUCZ/CASTELLI ATMOSPHERE TABLE')

C DBG PULSE
      IF (LPULSE) THEN
          WRITE(ISHORT,196)
  196     FORMAT(/,' CALCULATE PULSATION OUTPUT ON LAST MODEL')
      END IF
      IF (LPUREZ) THEN
          WRITE(ISHORT,*) ' USING PURE C AND N OPACITY TABLES'
      END IF

      WRITE(IMODPT,310) DESCRIP(1),  DESCRIP(2)

      WRITE(ISHORT,314)
      WRITE(ISHORT,VERFMT) YRECVER, GITHASH
      WRITE(ISHORT,310) DESCRIP(1),  DESCRIP(2)
  310    FORMAT('# DESCRIPTION OF RUN:',A80,/, '#',9X,'  ',8X,': ',
     *          A80,/,'#', 100('='))

      IF(LTRACK) THEN

         WRITE(ITRACK,314)
  314    FORMAT('#',/,'#',100('='))
         WRITE(ITRACK,VERFMT) YRECVER, GITHASH
         WRITE(ITRACK,320) DESCRIP(1), DESCRIP(2)
  320    FORMAT('# DESCRIPTION OF RUN:',A80,/, '#',9X,'  ',8X,': ',
     *          A80,/,'#', 100('='))

      ENDIF
      WRITE(ISHORT,323)
 323  FORMAT(' USING OSCILATORY SPLINE INTERPOLATION IN HPOINT')

C     INTERPRET RUN FROM SEQUENCE OF "KIND" CARDS

      WRITE(ISHORT,200)
  200 FORMAT(/35X,'RUN CARDS'/)

      LFIRST(1) = .TRUE.

C     RUN LOOP
      DO 1000 NKIND=1, NUMRUN
C READ IN NMODLS AND MODEL SOURCE(MEMORY OR FIRST MODEL)-SAME FOR ALL
       IRESCA(NKIND) = KINDRN(NKIND)
       IF(KINDRN(NKIND).EQ.1) THEN
C EVOLVE CARD
C MHP 10/24 GENERALIZE STOP CONDITIONS
C          LENDAG(NKIND) = ENDAGE(NKIND).GT.0D0
            IF(ENDAGE(NKIND).GT.0.0D0 .OR. END_DCEN(NKIND).GT.0.0D0
     * .OR. END_XCEN(NKIND).GT.0.0D0 .OR. END_YCEN(NKIND).GT.0.0D0)THEN
               LENDAG(NKIND)=.TRUE.
            ELSE
               LENDAG(NKIND)=.FALSE.
            ENDIF
          LSETDT(NKIND) = SETDT(NKIND).GT.0D0
            IF (NMODLS(NKIND).GT.0) THEN
          IF (LFIRST(NKIND)) THEN
             WRITE(IOWR,350) NKIND,NMODLS(NKIND)
             WRITE(ISHORT,350) NKIND,NMODLS(NKIND)
  350          FORMAT(/1X,'RUN #',I3,'   EVOLVE ',I5,
     1         ' MODELS, STARTING',
     2         ' WITH THE INPUT "FIRST MODEL".')
          ELSE
             WRITE(IOWR,351) NKIND, NMODLS(NKIND)
             WRITE(ISHORT,351) NKIND, NMODLS(NKIND)
  351          FORMAT(/1X,'RUN #',I3,'   EVOLVE ',I5,
     1         ' MODELS, STARTING',
     1         ' WITH THE PREVIOUS RUN''S LAST MODEL.')
          END IF
C GENERALIZE STOP CONDITIONS
          IF(LENDAG(NKIND).OR.LSETDT(NKIND)) THEN
             WRITE(IOWR,370)LENDAG(NKIND),LSETDT(NKIND),
     *              ENDAGE(NKIND), SETDT(NKIND),END_DCEN(NKIND),
     *         END_XCEN(NKIND),END_YCEN(NKIND)
             WRITE(ISHORT,370)LENDAG(NKIND),LSETDT(NKIND),
     *         ENDAGE(NKIND), SETDT(NKIND),END_DCEN(NKIND),
     *         END_XCEN(NKIND),END_YCEN(NKIND)
  370          FORMAT(1X,'EVOLVE TO AGE ',L1,' SET DELT ',
     *              L1,' FINAL AGE ', E9.2,' FIXED TSTEP ',E9.2,
     *  ' CENTRAL D ',E10.4,' CENTRAL X ',E12.4,' CENTRAL Y ',E12.4)
          ENDIF
            END IF
       ELSE IF(KINDRN(NKIND).EQ.2) THEN
C RESCALE CARD:  RESCALE STARTING MODEL
C QUANTITIES TO BE RESCALED STORED IN ARRAY RESCALE(4,50)
C WHERE THE ELEMENTS MASS,X,Z,CORE MASS ARE STORED IN ORDER
          RESCAL(1,NKIND) = RSCLM(NKIND)
          RESCAL(2,NKIND) = RSCLX(NKIND)
          RESCAL(3,NKIND) = RSCLZ(NKIND)
          RESCAL(4,NKIND) = RSCLCM(NKIND)
            IF (NMODLS(NKIND) .GT. 0) THEN
          IF (LFIRST(NKIND)) THEN
             WRITE(IOWR,450) NKIND
             WRITE(ISHORT,450) NKIND
  450          FORMAT(/1X,'RUN #',I3,
     1         '   RESCALE THE INPUT MODEL: "FIRST MODEL".')
          ELSE
             WRITE(IOWR,451) NKIND
             WRITE(ISHORT,451) NKIND
  451          FORMAT(/1X,'RUN #',I3,
     1         '   RESCALE THE PREVIOUS RUN''S LAST MODEL.')
          END IF
          WRITE(IOWR,452) NMODLS(NKIND),(RESCAL(I,NKIND),I = 1,4)
          WRITE(ISHORT,452) NMODLS(NKIND),
     1      (RESCAL(I,NKIND),I = 1,4)
  452       FORMAT(1X,'RELAX RESCALED MODEL',I3,
     *      ' TIMES. RESCALE THE FOLLOW',
     *      'ING(0=USE CURRENT VALUE):'/1X,'MASS ',
     *      F9.6,3X,'X',F9.6,3X,'Z',
     *      F9.6,3X,'CORE MASS',F9.6)
            END IF
         ELSE IF(KINDRN(NKIND).EQ.3) THEN
C RESCALE AND EVOLVE CARD:  RESCALE STARTING MODEL
C QUANTITIES TO BE RESCALED STORED IN ARRAY RESCALE(4,50)
C WHERE THE ELEMENTS MASS,X,Z,CORE MASS ARE STORED IN ORDER
            RESCAL(1,NKIND) = RSCLM(NKIND)
            RESCAL(2,NKIND) = RSCLX(NKIND)
            RESCAL(3,NKIND) = RSCLZ(NKIND)
            RESCAL(4,NKIND) = RSCLCM(NKIND)
            IF (LFIRST(NKIND)) THEN
               WRITE(IOWR,550) NKIND
               WRITE(ISHORT,550) NKIND
  550          FORMAT(/1X,'RUN #',I3,
     1         '   RESCALE & EVOLVE THE INPUT MODEL: "FIRST MODEL".')
            ELSE
               WRITE(IOWR,451) NKIND
               WRITE(ISHORT,451) NKIND
C   551          FORMAT(/1X,'RUN #',I3,
C      1         '   RESCALE & EVOLVE THE PREVIOUS RUN''S LAST MODEL.')
            END IF
            WRITE(IOWR,452) NMODLS(NKIND),(RESCAL(I,NKIND),I = 1,4)
            WRITE(ISHORT,452) NMODLS(NKIND),
     1      (RESCAL(I,NKIND),I = 1,4)
       END IF
         IF(RESCAL(3,NKIND).GE.0.0D0)  ZENV=RESCAL(3,NKIND)
 1000 CONTINUE
      RETURN
      END


C Replace any defined "{YREC_XXX}" placeholder string in the passed
C variable with the value of the corresponding environment variable.
      SUBROUTINE EXPAND_VALUE(NML_VAR)
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      INTEGER I,NUM_ENVVARS
      PARAMETER (NUM_ENVVARS=3) ! Number of possible env. vars.
      CHARACTER*256 NML_VAR
      CHARACTER*256 TEMP
      CHARACTER*256 PHOLDERS(NUM_ENVVARS)
      CHARACTER*256 DEFAULTS(NUM_ENVVARS)
      CHARACTER*256 PHOLDER
      INTEGER STLEN1, STLEN2, PH_LEN, DEF_LEN
C Each placeholder (env var name enclosed in curly braces) to be
C supported for expansion in namelists, along with default value in the
C case where the var is not defined in the execution environment.
C The number of assignment pairs here must match the value of the
C parameter NUM_ENVVARS, above.
      PHOLDERS(1) = "{YREC_INPUT}"
      DEFAULTS(1) = "../../input"

      PHOLDERS(2) = "{YREC_START}"
      DEFAULTS(2) = "../../startmodels"

      PHOLDERS(3) = "{YREC_OUTPUT}"
      DEFAULTS(3) = "output"

      DO 5000 i=1, NUM_ENVVARS
        PH_LEN = LEN_TRIM(PHOLDERS(i))
        DEF_LEN = LEN_TRIM(DEFAULTS(i))
        PHOLDER = PHOLDERS(i)(1:PH_LEN)

        IF (NML_VAR(1:PH_LEN) .EQ. PHOLDER) THEN  ! If placeholder
            CALL getenv(PHOLDER(2:PH_LEN-1), TEMP)
            STLEN1 = LEN_TRIM(TEMP)
            STLEN2 = LEN_TRIM(NML_VAR)
            IF (STLEN1 .NE. 0) THEN     ! If env var set
                TEMP(STLEN1+1:STLEN1+STLEN2-PH_LEN) = NML_VAR(PH_LEN+1:STLEN2)
                !print *,"Override: ",TEMP(1:LEN_TRIM(TEMP))
            ELSE                        ! No env var. Use default path.
                TEMP(1:DEF_LEN) = DEFAULTS(i)(1:LEN_TRIM(DEFAULTS(i)))
                TEMP(DEF_LEN+1:DEF_LEN+STLEN2) = NML_VAR(PH_LEN+1:STLEN2)
                !print *,"default: ",TEMP(1:LEN_TRIM(TEMP))
            END IF
            NML_VAR = TEMP
        END IF
5000  CONTINUE
      END
