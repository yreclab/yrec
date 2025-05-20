C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MAIN
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

C*******
C initialize all variables, set up common blocks
C*******

C the array size, i.e. max # of shells is specified in the 
C parameter statement.  it defines JSON.  to change the array
C size do a global change on "JSON=2000" or whatever.
      PARAMETER (JSON=5000)
      PARAMETER (NUMTT=70)
      PARAMETER (NUMD=19)
      PARAMETER (NUMX=10)
      PARAMETER (NUMZ=13)
      PARAMETER (NUMXZ=126)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C DBGLAOL - to save space make tables single precision
      REAL*8 OLAOL,OXA,OT,ORHO,TOLLAOL
      CHARACTER*256 FISO, FLAOL, FPUREZ
      CHARACTER*256 FLAOL2, FOPAL2
      CHARACTER*256 FLAST, FFIRST, FRUN, FSTAND, FFERMI,
     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
     3    FLLDAT, FSNU, FSCOMP, FKUR, 
     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
      COMMON/LUNUM/IFIRST, IRUN, ISTAND, IFERMI,
     1    IOPMOD, IOPENV, IOPATM, IDYN,
     2    ILLDAT, ISNU, ISCOMP, IKUR
      COMMON/LUFNM/ FLAST, FFIRST, FRUN, FSTAND, FFERMI,
     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
     3    FLLDAT, FSNU, FSCOMP, FKUR, 
     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
C DBGLAOL
      COMMON/NWLAOL/OLAOL(12,104,52),OXA(12),OT(52),ORHO(104),TOLLAOL,
     *  IOLAOL, NUMOFXYZ, NUMRHO, NUMT, LLAOL, LPUREZ, IOPUREZ,
     *   FLAOL, FPUREZ
      COMMON/TRACK/ITRVER
      COMMON/LABEL/XENV0,ZENV0
      COMMON/CCOUT/LSTORE,LSTATM,LSTENV,LSTMOD,LSTPHYS,LSTROT,LSCRIB
      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH
      COMMON/CENV/TRIDT,TRIDL,SENV0,LSENV0,LNEW0
      COMMON/CKIND/RESCAL(4,50),NMODLS(50),IRESCA(50),LFIRST(50),
     1       NUMRUN
C 11/91 COMMON BLOCKS ADDED FOR PRESSURE SCALE HEIGHT CALC. FOR LIBURN
      COMMON/CONST2/CGAS,CA3,CA3L,CSIG,CSIGL,CGL,CMKH,CMKHN
C MHP 05/02 ADDED OPTION TO ITERATE BETWEEN ROTATION AND
C STRUCTURE CALCULATIONS - SET ITDIF1 GREATER THAN 1
      COMMON/DIFUS/DTDIF,DJOK,ITDIF1,ITDIF2
      COMMON/DPMIX/DPENV,ALPHAC,ALPHAE,ALPHAM,BETAC,IOV1,IOV2,
     *      IOVIM, LOVSTC, LOVSTE, LOVSTM, LSEMIC, LADOV, LOVMAX
      COMMON/LIOV/PSCAL0,PSCAL1
      COMMON/PREVCZ/RBASE0,BLI6OLD,BLI7OLD,BBE9OLD,JENVOS
      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL
      COMMON/CONST3/CDELRL,CMIXL,CMIXL2,CMIXL3,CLNDP,CSECYR
      COMMON/CTOL/HTOLER(5,2),FCORR0,FCORRI,FCORR,HPTTOL(12),NITER1,
     1 NITER2,NITER3
C MHP 8/17 ADDED EXCEN, C_2 TO COMMON BLOCK FOR MATT ET AL. 2012 CENT. TERM
      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,EXL,EXPR,CONSTFACTOR,
     *             STRUCTFACTOR,EXCEN,C_2,LJDOT0
C      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,CONSTFACTOR,STRUCTFACTOR,LJDOT0
      COMMON/FLAG/LEXCOM
      COMMON/HEFLSH/LKUTHE
      COMMON/ROT/WNEW,WALPCZ,ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50)
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
      COMMON/NEWENG/NITER4,LNEWS,LSNU
C 7/91 ENTROPY TERM COMMON BLOCK ADDED.
      COMMON/ENTROP/HTT0(JSON),HPP0(JSON),HLL0(JSON),HRR0(JSON)
C 7/91 FLAG TO TOGGLE BETWEEN NEW/OLD RATES ADDED.
      COMMON/OLDMOD/HPO(JSON),HTO(JSON),HRO(JSON),HLO(JSON),HDO(JSON),
     *              HCOMPP(15,JSON),HSS(JSON),LCO(JSON),LCZO(JSON),TEFFLO,MO
C MHP 9/94
      COMMON/ROTPRT/LPRT0
C MHP 9/94 ADDED DISK LOCKING OPTION - FLAG, TIME OVER WHICH LOCKING
C IS ENFORCED, AND PERIOD AT WHICH LOCKING IS SET ARE OPTIONS.
      COMMON/DISK/SAGE,TDISK,PDISK,LDISK
      COMMON/PULSE/XMSOL,LPULSE,IPVER
      COMMON/ATMOS/HRAS,KTTAU,KTTAU0,LTTAU
      COMMON/CHRONE/LRWSH, LISO, IISO, FISO
C DBG 1/92 let XENV0, ZENV0, and CMIXL be arrays so can change during
C a set of runs.
      COMMON /NEWXYM/XENV0A(50),ZENV0A(50),CMIXLA(50),LSENV0A(50),
     * SENV0A(50)
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *     IOLAOL2, IOOPAL2, NK, LZRAMP, FLAOL2, FOPAL2
C DBG 4/26/94 Tired of not have access to current age of model so...
      COMMON/THEAGE/DAGE
      DIMENSION TLUMX(8),TRIL(3),TRIT(3),PS(3),TS(3),RS(3),CFENV(9),
     *HS(JSON),HL(JSON),HR(JSON),HP(JSON),HT(JSON),HD(JSON),LC(JSON),
     *HCOMP(15,JSON),HS1(JSON),HS2(JSON),HHC(JSON),
     *HHA(4,2,JSON),HHB(4,JSON),HPP(JSON),HTT(JSON),ESTORE(4),
     *HMAX(4),NHMAX(4),HSRF(6),FP(JSON),FT(JSON),
     *OMEGA(JSON),HI(JSON),HJM(JSON),HKEROT(JSON),R0(JSON),ETA2(JSON),
     *QIW(JSON),HG(JSON),V(12),HKEROTO(JSON)
C     MHP 10/24 FLAG FOR END OF RUN
      LOGICAL*4 LEND_KIND
C JVS 02/12
	COMMON/STCH/HCOMPF(15,JSON),HRF(JSON),HPF(JSON),HDF(JSON),
     * HSF(JSON),HTF(JSON)

C DBG PULSE OUT 7/92
C variables used to contral output of pulsation models.  model
C output after has traveled pomax in HR diagram
C LPOUT and POMAX added to control common block, rest in physics
      COMMON /PO/POA,POB,POC,POMAX,LPOUT
C MHP 1/93 add common blocks for automatic calibration of solar models.
      COMMON/CONST1/ CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      COMMON/CALSUN/DLDX,DRDX,DLDA,DRDA,BLP,RLP,DX,DA,LSOL
C MHP 6/13 ADD OPTION TO CALIBRATE SOLAR Z/X, SOLAR Z/X, SOLAR AGE
      COMMON/CALS2/TOLL,TOLR,TOLZ,LCALS,LCALSOLZX,CALSOLZX,CALSOLAGE
C      COMMON/CALS2/TOLL,TOLR,LCALS
      COMMON/GRAVS3/FGRY,FGRZ,LTHOUL,LDIFZ
C DBG 12/94 added calibrate stellar model
      COMMON/CALSTAR/XLS, XLSTOL,  STEFF, SR, 
     1      BLI, ALRI, AGER, BLR, BLRP, AGEI,
     2      LSTAR, LTEFF, LPASSR,LCALST
C MHP 7/96 common block added for sound speed
      COMMON/SOUND/GAM1(JSON),LSOUND
C MHP 8/96 monte carlo option for snus added.
      COMMON/MONTE/LMONTE,IMBEG,IMEND
      COMMON/FLUXES/FLUX(10),FLUXTOT(10),CLSNU,GASNU
C MHP 6/14 DERIVATIVES ADDED TO COMMON BLOCK.  NOT USED FOR DERIVATIVES
C IN THE MONTE CARLO.
      COMMON/CROSS/SSTANDARD(17),QS0E(8),QQS0EE(8),FO16,FC12,LNEWNUC
C      COMMON/CROSS/SSTANDARD(17)
C MHP 8/96
C added monte carlo parameters for metal diffusion, solar L, solar age.
      COMMON/MONTE2/S11(1000),S33(1000),S34(1000),S17(1000),
     *              ZX(1000),FHE(1000),FZDIF(1000),FLUM(1000),
     *              FAGE(1000)
C MHP 3/96 central T,P,RHO added
      COMMON/CENT/TCENTER,PCENTER,DCENTER,ENVLM,ENVR
      COMMON /LLOT95A/TGR(NUMTT),XXG(NUMX),R0GR(NUMD),ZZG(NUMZ),
     *                CAPPA2(NUMXZ,NUMTT,NUMD),NUMXM(NUMZ),NZ(NUMZ)
C as above for the model Z.
      COMMON /LLOT95/CAPPA(NUMX,NUMTT,NUMD),ZTAB
C as above for desired surface value of X.
      COMMON /LLOT95E/CAPPAE(NUMTT,NUMD),XTAB
C indices for interpolation in Z,X,T, and R
      COMMON/OP95INDX/JZ,JX(4,4),JT,JD(4)
C interpolation factors for Z,X,T, and R, as well as derivative
C factors for T and RHO.
      COMMON/OP95FACT/BZ(4),BX(4,4),BT(4),BTT(4),BD(4,4),BDD(4,4)
C MHP 05/02 ADDED FOR ITERATION BETWEEN ROTATION AND STRUCTURE CALCULATION
      COMMON/ORIGSTART/HJM0(JSON),HCOMPP0(15,JSON)
C MHP 05/02 DEUTERIUM BURNING RATE ADDED
      COMMON/DEUTER/DRATE(JSON),DRATE0(JSON),FMASSACC,JCZ
C***MHP 1/04 inserted for test
C      COMMON/OPTAB/OPTOL,ZSI,IDT,IDD(4)
C*** end test
C LLP 8/07 Make LPTIME available for calibration
      COMMON/CT3/LPTIME
C MHP 2/04 ADDED FOR NEUTRINO FLUX TABLE
      COMMON/BE7/BE7MASSFRACTION
C JVS 02/11
	COMMON/ACDPTH/TAUCZN,DELADJ(JSON),TAUHE, TNORM, TCZ, WHE, ICLCD,
     *ACATMR(JSON), ACATMD(JSON), ACATMP(JSON), ACATMT(JSON),TATMOS,
     *LCLCD, AGEOUT(5), IACAT, IJLAST, LJLAST, LJWRT, LADON, LAOLY, IJVS,
     *IJENT, IJDEL, LACOUT		 
	INTEGER NAO
	DATA NAO/1/
C 10/11 He3+He3 luminosity info
	COMMON/GRAB/ENGHE3,HE3ALL,UMHE33(JSON),UMHEAL(JSON)
C JVS 08/13 IF THE CZ IS BEYOND THE FITTING POINT, STORE ITS LOCATION
	COMMON/ENVCZ/ENVRCZ,RINT
C JVS 04/14 Common block for additional timestep governors
	COMMON/GOVS/LTRIST
C G Somers 3/17, ADDING NEW TAUCZ COMMON BLOCK
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
C     MHP 10/24 NEW VARIABLES FOR STOP CONDITIONS ON CENTRAL ABUNDANCE
      REAL*8 XCEN(2,15),DTPREV
      LOGICAL*4 L_LASTSTEP
C
      DIMENSION BE7M(JSON),FLUXI0(10,JSON)
      DIMENSION HR1(JSON),HR2(JSON),HR3(JSON),HR4(JSON),HR5(JSON),
     1 HR6(JSON),HR7(JSON),HR8(JSON),HR9(JSON),HR10(JSON),HR11(JSON),
     2 HR12(JSON),HR13(JSON),HF1(JSON),HF2(JSON)
      DIMENSION MXZONE(12,2),MXZON0(12,2),MRZONE(13,2)
      DIMENSION LCZ(JSON)
C latest values (Bahcall and Pinsonneault 1996)-actual values set in
C subroutine PARMIN
      DIMENSION SBP(17)
      DATA SBP/0.9558,0.9690,0.9712,1.0,1.0,0.992,1.0,1.0,1.0,1.0,1.0,
     $  1.0,1.0,1.0,1.0,0.92088,0.1625/
C MHP 3/96 added data for base solar age, L
      DATA SUNAGE,SUNL/4.57D09,3.844D33/
      SAVE

C*******
C START 
C*******

      IOWR = 9
C LPUNCH is TRUE once first model is calculated
      LPUNCH=.FALSE.
C read in user parameters
      CALL PARMIN
C set up constants and read in tabular data
      CALL SETUPS(V)
C MHP 3/96 changed I/O to read in only up to max run needed.
      IF(LMONTE)THEN
         OPEN(UNIT=IDYN,FILE=FDYN,FORM='FORMATTED',STATUS='OLD')
         I0 = IMBEG
         IMEND = MIN(IMEND,1000)
         I1 = IMEND
C read in monte carlo data
         DO I = 1,IMEND
            READ(IDYN,1511)S11(I),S33(I),S34(I),S17(I),ZX(I),FHE(I),
     *                     FLUM(I),FAGE(I)
 1511       FORMAT(7X,1P7E10.3/E9.3)
            WRITE(IOWR,*)I,S11(I),S33(I),S34(I),S17(I),ZX(I),FHE(I),
     *                 FLUM(I),FAGE(I)
            FZDIF(I) = FHE(I)
         END DO
      ELSE
         I0 = 1
         I1 = 1
      ENDIF
      DO 500 NN = I0,I1
C for monte carlo run, input values of parameters being changed.
      IF(LMONTE)THEN
         SSTANDARD(1) = S11(NN)*SBP(1)
         SSTANDARD(2) = S33(NN)*SBP(2)
         SSTANDARD(3) = S34(NN)*SBP(3)
         SSTANDARD(16) = S17(NN)*SBP(16)
         FGRSET = FHE(NN)
         FGRZ = FZDIF(NN)
         CLSUN = SUNL*FLUM(NN)
         CLSUNL = DLOG10(CLSUN)
         CLNSUN = CLN/CLSUN
         FACAGE = FAGE(NN)
C timestep and final age are altered in SR SETCAL; input #s should be
C scaled for a solar age of 4.57 Gyr
         ENDAGE(2)=1.0D8
         ENDAGE(3)=4.57D9
      ELSE
         FACAGE = 1.0D0
      ENDIF
C DBG PULSE: save LPULSE flag, set LPULSE to F except on last model of 
C last run, then set LPULSE to saved value of LPULSE.
      LSAVPU = LPULSE
C 02/11 JVS uncommented LPULSE=.FALSE.
C      LPULSE = .FALSE.
C MHP 1/93 add option to automatically calibrate solar model.
C MHP 3/96 added counter for # of iterations per converged model and 
C starting estimate of ALPHA and X
      IF(LCALS)THEN
         CALL SETCAL(FACAGE)
         ICONV = 1
         XGUESS = RESCAL(2,1)
         AGUESS = CMIXLA(1)
         lptimesv = lptime   ! save LPTIME for reuse during calibration
         kttausv  = kttau    ! save KTTAU for reuse during calibration
      ELSE
         ICONV = 0
      ENDIF
C DBG 12/94 add option to automatically calculate a stellar model
C of specified Teff and L
      IF (LCALST) THEN
         CALL SETSCAL
      ENDIF	

C**********
C     RUN THROUGH THE KIND CARDS IN ORDER
C**********
      DO 200 NK = 1, NUMRUN
         LSOUND = .FALSE.
C         LPULSE=.FALSE.
         XENV0 = XENV0A(NK)
         ZENV0 = ZENV0A(NK)
         CMIXL = CMIXLA(NK) 
	 LSENV0 = LSENV0A(NK)
	 SENV0 = SENV0A(NK)
	 LRESET = .FALSE.
	 LARGE = .FALSE.
C MHP 10/02 ZERO OUT INITIAL ANGULAR MOMENTUM
         SJTOT = 0.0D0
         SKEROT = 0.0D0
C read in the initial model here
C STARIN also calls RSCALE to perform rescaling if requested
	 CALL STARIN(BL,CFENV,DAGE,DDAGE,DELTS,DELTSH,DELTS0,ETA2,
     *    FP,FT,FTRI,HCOMP,HD,HI,HJM,HKEROT,HL,HP,HR,HS,HS1,HS2,
     *    HSTOT,HT,IKUT,ISTORE,JCORE,JENV,LARGE,LC,LNEW,M,MODEL,
     *    NK,OMEGA,PS,QDP,QDT,QIW,R0,RS,SJTOT,SKEROT,SMASS,TEFFL,
     *    TLUMX,TRIL,TRIT,TS,VEL,HG,V)
c     MHP 10/24 CHECK STOP CONDITIONS AND DISABLE THEM IF THE STARTING VALUES ARE BELOW THE TARGET THRESHOLD
         IF(LENDAG(NK))THEN
            IF(END_DCEN(NK).GT.0.0D0 .AND.
     *           HCOMP(12,1).LT.END_DCEN(NK))THEN
               END_DCEN(NK)=-END_DCEN(NK)
               WRITE(*,101)HCOMP(12,1),END_DCEN(NK)
               WRITE(ISHORT,101)HCOMP(12,1),END_DCEN(NK)
 101           FORMAT('STARTING D ',E12.4,' BELOW STOP VALUE ',
     *                E12.4,' STOP DISABLED.')
            ENDIF
            IF(END_XCEN(NK).GT.0.0D0 .AND.
     *           HCOMP(1,1).LT.END_XCEN(NK))THEN
               END_DCEN(NK)=-END_XCEN(NK)
               WRITE(*,102)HCOMP(12,1),END_DCEN(NK)
               WRITE(ISHORT,102)HCOMP(12,1),END_DCEN(NK)
 102           FORMAT('STARTING X ',E12.4,' BELOW STOP VALUE ',
     *                E12.4,' STOP DISABLED.')
            ENDIF
            IF(END_YCEN(NK).GT.0.0D0 .AND.
     *           HCOMP(2,1).LT.END_YCEN(NK))THEN
               END_YCEN(NK)=-END_YCEN(NK)
               WRITE(*,103)HCOMP(12,1),END_DCEN(NK)
               WRITE(ISHORT,103)HCOMP(12,1),END_DCEN(NK)
 103           FORMAT('STARTING Y ',E12.4,' BELOW STOP VALUE ',
     *                E12.4,' STOP DISABLED.')
            ENDIF
         ENDIF
C     MHP 2/04 NEUTRINO TABLE
C      LNUTAB = .TRUE.
      LNUTAB = .FALSE.
      IF(LNUTAB)THEN
C SET UP WEIGHTS AND MASSES.
C HS1 = LOCATION IN GM (UNLOGGED) OF SHELL CENTERS.
C HS2 = MASS IN GM OF EACH SHELL.
      DS3 = EXP(CLN*HS(1))
      DS2 = - DS3
      DO I = 2,M
         DS1 = DS2
         DS2 = DS3
         DS3 = EXP(CLN*HS(I))
         HS1(I-1) = DS2
         HS2(I-1) = 0.5D0*(DS3-DS1)
      END DO
      HS1(M) = DS3
      HS2(M) = EXP(CLN*HSTOT) - 0.5D0*(DS2+DS3)
      PDT = -1.0D0
      PDP = 1.0D0
      DO J = 1,10
         FLUXTOT(J) = 0.0D0
         DO K = 1,M
            FLUXI0(J,K) = 0.0D0
         END DO
      END DO
C ASSIGN LOCAL VARIABLES FOR SR CALL FROM GLOBAL VECTORS.
      DO I = 1,M
         DL = HD(I)
         TL = HT(I)
C SKIP CALCULATIONS FOR LOW TEMPERATURES.
         IF(TL.LT.6.0D0)GOTO 666
         X = HCOMP(1,I)
         Y = HCOMP(2,I)
         Z = HCOMP(3,I)
         XHE3 = HCOMP(4,I)
         XC12 = HCOMP(5,I)
         XC13 = HCOMP(6,I)
         XN14 = HCOMP(7,I)
         XN15 = HCOMP(8,I)
         XO16 = HCOMP(9,I)
         XO17 = HCOMP(10,I)
         XO18 = HCOMP(11,I)
         CALL ENGEB(EPP1,EPP2,EPP3,ECN,E3AL,PEP,PET,SUM1,DL,
     *TL,PDT,PDP,X,Y,Z,XHE3,XC12,XC13,XN14,XN15,XO16,XO17,
     *XO18,XH2,XLI6,XLI7,XBE9,I,HR1,HR2,HR3,HR4,HR5,HR6,HR7,
     *HR8,HR9,HR10,HR11,HR12,HR13,HF1,HF2)
C BE7 MASS FRACTION.
         BE7M(I) = BE7MASSFRACTION
C CONVERT FROM ERG/GM/S TO ERG/S FOR EACH SHELL BY MULTIPLYING
C BY THE MASS OF EACH SHELL IN GM (HS2).
         DO J = 1,10
            FLUXI0(J,I) = FLUX(J)*HS2(I)
            FLUXTOT(J) = FLUXTOT(J) + FLUXI0(J,I)
         END DO
         WRITE(*,911)I,HS2(I),(FLUXI0(J,I),J=1,10)
 911     FORMAT(I5,1P11E10.3)
      END DO
  666 CONTINUE
C WRITE OUT TOTAL NEUTRINO FLUXES.
C ***NOTE THAT THESE ARE IN UNITS OF 10**10. ***
      WRITE(76,222)(FLUXTOT(I),I=1,10)
C NORMALIZE FLUXES.
      DO J = 1,10
         DO I = 1,M
            FLUXI0(J,I) = FLUXI0(J,I)/FLUXTOT(J)
         END DO
      END DO
      DO I = 1,M
C TEMPERATURE IN UNITS OF 10**6 K.
         T6 = EXP(CLN*(HT(I)-6.0D0))
         IF(T6.LT.5.0D0)GOTO 141
C ELECTRON DENSITY.
         RHOE = HD(I)+LOG10((1.0D0+HCOMP(1,I))/2.0D0)
C MASS FRACTION.
         FM = HS2(I)/1.9891D33
C RADIUS FRACTION.
         FR = EXP(CLN*HR(I))/CRSUN
C FLUXES ARE PRINTED IN THE SAME ORDER AS BAHCALL AND PINSONNEAULT.
         WRITE(76,145)FR,T6,RHOE,FM,BE7M(I),FLUXI0(1,I),FLUXI0(5,I),
     *   FLUXI0(6,I),
     *   FLUXI0(7,I),FLUXI0(8,I),FLUXI0(4,I),FLUXI0(2,I),FLUXI0(3,I)
  145    FORMAT(F9.5,F7.3,F6.3,1P10E10.3)
      END DO
  141 CONTINUE
  222    FORMAT(1P10E10.3)
C         IF(M.GT.1)STOP999
      ENDIF
C save mass in solar units
         XMSOL=SMASS
C MHP 08/02 STORE STARTING CZ PROPERTIES
         JCZ = JENV
         TAUCZ = 0.0D0	
C write out headers of the appropriate output files
	CALL WRTHEAD(SMASS)
C DBG PULSE OUT 7/92
C initialize variables for calculating when to dump pulse output
         POL1 = BL
         POT1 = TEFFL
         POA1 = DAGE 
         POLEN = 0.0D0

	 IF(LKUTHE) THEN
C timestep cutting requires a model stored in logical unit ILAST
C or it will crash - so copy initial model to unit ILAST
	    IF(LPUNCH) THEN
	       IWRITE = ILAST
	       CALL WRTLST(IWRITE,HCOMP,HD,HL,HP,HR,HS,HT,LC,TRIT,TRIL,
     *         PS,TS,RS,CFENV,FTRI,TLUMX,JCORE,JENV,MODEL,M,
     *         SMASS,TEFFL,BL,HSTOT,DAGE,DDAGE,OMEGA)
	    ENDIF
	 ENDIF

C locate the hydrogen-burning shell and the boundaries of the central
C and surface convection zones (if applicable).
         CALL FINDSH(HCOMP,HL,LC,M,JCORE,JENV,JXBEG,JXEND,JXMID,
     *               LSHELL)
C determine timestep for model
C JVS 04/14 Added Teffl to passed variables
	 CALL HTIMER(DELTS,DELTSH,M,HD,HL,HS1,HS2,HT,LC,HCOMP,JCORE,
     *               JXMID,TLUMX,DAGE,DDAGE,QDT,QDP,NK,HP,HR,OMEGA,
     *               DWMAX,JXBEG,TEFFL)

	 DELTS0 = DELTS
C zero out entropy terms.
         DO 99 I = 1,M
            HTT0(I) = 0.0D0
            HPP0(I) = 0.0D0
            HLL0(I) = 0.0D0
            HRR0(I) = 0.0D0
   99    CONTINUE

C zero out light element burning rates in the surface CZ.
         IF(LEXCOM)THEN
            BLI6OLD = 0.0D0
            BLI7OLD = 0.0D0
            BBE9OLD = 0.0D0
         ENDIF

C for a given kind card, evolve NMODLS(NK) times
C if rescaling is being performed, NMODLS(NK) is the number of times
C the new model is being relaxed
	 DO 100 MODELN = 1,NMODLS(NK)
C rewind ISHORT if LRWSH is true (keeps ISHORT small)
	    IF (LRWSH) THEN
	       REWIND(ISHORT)
	    ENDIF
C DBG PULSE:  if last model of last run then set LPULSE to LSAVPU
            IF (MODELN.EQ.NMODLS(NK) .AND. NK .EQ. NUMRUN) THEN
                 LPULSE = LSAVPU
            END IF

C JVS 02/11: Also allow pulse output at particular ages along the way
C 
C  If the step is bracketing an age of interest, turn on output. This will 
C for the step before and step after the age in AGEOUT. Once the info has 
C been printed out, AGEOUT is set to the next age.
C 
C Turn on calcad:
	IF (LACOUT) THEN
		LADON=.TRUE.
	ELSE
		LADON = .FALSE.
	ENDIF
C If output has been turned on for a previous step, keep it on for the next
C step, but then turn it off.	
	IF (LACOUT) THEN	
		IF (LJWRT) THEN
			PRINT*, 'LJWRT on'
			LPULSE = LSAVPU
			NAO=NAO+1
			LCLCD =.TRUE.
			LJLAST =.FALSE.
			LJWRT=.FALSE.
		ELSE IF (.NOT.LJWRT) THEN 
			LCLCD=.FALSE.
		ENDIF			
C If this is the step before one of the ages of interest, print everything out.
C Also, save model structure.
            IF(NAO.LT.6) THEN
            	IF(DAGE+DDAGE/1.0D9-AGEOUT(NAO) .LE. 0.0D0 .AND. 
     *		DAGE+2.0D0*DDAGE/1.0D9-AGEOUT(NAO) .GE. 0.0D0 .AND. .NOT. LJWRT) THEN
				PRINT*, 'AGEOUT reached'
				LPULSE = LSAVPU
				LCLCD = .TRUE.
				LJLAST = .TRUE.
				LJWRT=.TRUE.
			ENDIF
		ENDIF
	 ENDIF

		
C JVS end
C
C DBG PULSE:  if endage reached then set LPULSE to LSAVPU
C MHP 10/24 GENERALIZE CHECK
         IF(LENDAG(NK).AND.ENDAGE(NK).GT.0.0D0. AND.
     *   (ABS(ENDAGE(NK)-DAGE*1.0D9-DDAGE) .LE. 1.0D0)) THEN
                 LPULSE = LSAVPU
C MHP 7/96 compute sound speed for solar model
                 LSOUND = .TRUE.
            END IF 


CFD echo LSOUND
C        print*,'MAIN LSOUND = ',LSOUND
CFD end
            IF (LPOUT) THEN
	       CALL PDIST(POL1,POT1,POA1,POLEN,BL,TEFFL,MODELN)
	    ENDIF

C STARIN called here for timestep cutting
   15       IF(LARGE) THEN
	       CALL STARIN(BL,CFENV,DAGE,DDAGE,DELTS,DELTSH,DELTS0,ETA2,
     *          FP,FT,FTRI,HCOMP,HD,HI,HJM,HKEROT,HL,HP,HR,HS,HS1,HS2,
     *          HSTOT,HT,IKUT,ISTORE,JCORE,JENV,LARGE,LC,LNEW,M,MODEL,
     *          NK,OMEGA,PS,QDP,QDT,QIW,R0,RS,SJTOT,SKEROT,SMASS,TEFFL,
     *          TLUMX,TRIL,TRIT,TS,VEL,HG,V)
	    ENDIF
	    LPUNCH = .TRUE.

C skip this section if model not to be aged
C MHP 7/98
C need to add logic to permit resacling + time evolution for 
C pre-main sequence models
            IF(IRESCA(NK).NE.2 .AND. MODEL.GE.0) THEN
               LAGE = .TRUE.
            ELSE IF(MODEL.GE.0 .AND. HT(1).LT.6.6D0)THEN
               LAGE = .TRUE.
            ELSE
               LAGE = .FALSE.
            ENDIF
            LNEWFIT = .FALSE.
            IF(LAGE) THEN
C ADD MASS LOSS CALCULATION
               CALL MASSLOSS(BL,DAGE,DELTS,HCOMP,HD,HJM,HP,HR,
     *                       HS,HS1,HS2,HSTOT,HT,JENV,LNEW,
     *                       M,OMEGA,SMASS,TEFFL,SENVOLD,LNEWFIT)
C STORE COMPOSITION MATRIX AT THE BEGINNING OF THE TIMESTEP.
               NSPEC = 11
               IF(LEXCOM)NSPEC=15
               DO 33 I = 1,M
                  DO 32 J = 1,NSPEC
                     HCOMPP(J,I) = HCOMP(J,I)
   32             CONTINUE
   33          CONTINUE
               ITLVL=1
               CALL MIX(DELTS,HCOMP,HD,HL,HP,HR,HS,HS1,HS2,HSTOT,
     *                     HT,ITLVL,LC,M,QDT,QDP,DDAGE,JCORE,JENV,
     *                     MXZONE,MXZON0,TEFFL)
	       DDAGE = DELTS/CSECYR
	       DAGE = DAGE + 1.0D-9*DDAGE
            ENDIF
C***MHP 1/04 OPACITY TEST
C      IDT = 15
C      DO JJJ = 1,4
C         IDD(JJJ) = 5
C      END DO
C      XXX = 0.7D0
C      ZZZ = 0.02D0
C      Do JJJ = 1,2000
c         READ(75,*)TL,DL,XX,ZZ,OO
C         IF(TT.GT.1.0D9)STOP911
C         TL = LOG10(TT)
C         DL = LOG10(DD)
C DBG 12/95 GET OPACITY
C         CALL GETOPAC(DL, TL,XXX,ZZZ, O, OL, QOD, QOT)
c         DIFF = (O-OO)/O
C         RL = DL - 3*TL +18.0D0
C         WRITE(76,1554)TL,RL,XXX,ZZZ,O,OO,DIFF
C 1554    format(4f11.6,3e20.10)
C      END DO
C*** END TEST
C rezone new model, except rezoning not performed for He flash calculations
	    IF(.NOT.LKUTHE) THEN
	       CALL HPOINT(M,HSTOT,HS,HS1,HS2,HT,HP,HR,LC,HL,HD,
     *              HCOMP,PS,RS,ESTORE,ISTORE,LRESET,JXBEG,
     *              MODEL,LSHELL,JCORE,JENV,OMEGA,ETA2,R0,HI,
     *              HJM,HKEROT,SJTOT,SKEROT,BL,DELTS,FP,FT,
     *              HG,QIW,SMASS,TEFFL)
C STORE NEW CZ BASE
               JCZ = JENV
            ELSE
C save old model for PTIME 
               DO I=1, M
                  HPO(I) = HP(I)
                  HTO(I) = HT(I)
                  HRO(I) = HR(I)
                  HLO(I) = HL(I)
                  HDO(I) = HD(I)
               END DO
C JVS 04/14 Save Teff as well
		   TEFFLO = TEFFL
C  JVS 05/25 Added model number to list of saved values
           MO = M 

	    ENDIF
C store starting distribution of rotational kinetic energy.
            IF(LROT)THEN
               DO I = 1,M
                  HKEROTO(I) = HKEROT(I)
               END DO
            ENDIF
C changed for lithium burning with overshoot.
C store starting depth of C.Z. for light element burning.
            IF(LEXCOM)THEN
               RBASE0 = 0.0D0
               JENV0 = JENV
               IF(LOVSTE)THEN
                  PSCAL0 = ALPHAE*EXP(CLNDP*(HP(JENV)+2.0D0*HR(JENV)
     *                     -HD(JENV)-CGL-HS(JENV)))
               ELSE
                  PSCAL0 = 0.0D0
               ENDIF
C find burning rates at the beginning of the time step.
               CALL LIRATE88(HCOMP,HD,HT,M,1)
            ENDIF
C begin correction routines
C set flags for CRRECT
C CRRECT checks surface boundary conditions in every iteration
C if LNEW0 = T, new envelope triangle calculated the 1st iteration
C (i.e. old triangle ignored)
C LFINI = T if model has converged
C LARGE = T if model has diverged
	    IF(LNEW0) LNEW = .TRUE.
            IF(.NOT.LAGE) DELTS = -DABS(DELTS)
            FCORR = DABS(FCORR0) - FCORRI
            ITDONE = 0
            LARGE = .FALSE.
            LFINI = .FALSE.
            IF(.NOT.LNEWS .OR. DELTS.LE.0.0D0)THEN
               DO 20 I = 1,M
C zero entropy terms
                  HTT(I) = 0.0D0
                  HPP(I) = 0.0D0
                  HTT0(I) = 0.0D0
                  HPP0(I) = 0.0D0
                  HLL0(I) = 0.0D0
                  HRR0(I) = 0.0D0
C zero gravitational energy terms.
                  HHC(I) = 0.0D0
 20            CONTINUE
            ELSE
C use the rate of change in the previous model to estimate the new
C run of structure variables.
               DO 30 I = 1,M
                  DT = HTT0(I)*DELTS
                  DP = HPP0(I)*DELTS
                  DL = HL(I)*HLL0(I)*DELTS
                  DR = HRR0(I)*DELTS
                  HTT(I) = DT
                  HPP(I) = DP
                  HT(I) = HT(I) + DT
                  HP(I) = HP(I) + DP
                  HL(I) = HL(I) + DL
                  HR(I) = HR(I) + DR
C zero gravitational energy terms.
                  HHC(I) = 0.0D0
 30            CONTINUE
            ENDIF

C FIRST LEVEL OF ITERATIONS
C USE ENVELOPE TRIANGLE OF THE PREVIOUS MODEL;
C FOR THE FIRST MODEL OF A RUN,THE TRIANGLE IS GENERATED HERE.
            NITER = NITER1
            LSBC = .FALSE.
C CALL TO CRRECT - ADDED ITERATION LEVEL
            ITLVL = 1
            CALL CRRECT(DELTS,M,NITER,LFINI,LARGE,LNEW,LRESET,LSBC,
     *           TRIT,TRIL,CFENV,PS,TS,RS,FTRI,ISTORE,ESTORE,HSTOT,
     *           BL,TEFFL,HD,HHA,HHB,HHC,HL,HMAX,HP,HPP,HR,HS,HS1,
     *           HS2,HSRF,HT,HTT,HCOMP,LC,NHMAX,TLUMX,LATMO,LDERIV,
     *           LMIX,LOCOND,QDT,QDP,MODEL,FP,FT,ETA2,OMEGA,R0,ITDONE,
     *           HG,HI,HJM, ITLVL,LCZ,MRZONE,MXZONE,NRZONE,NZONE,
     *           QIW,HKEROT,HKEROTO)
C SECOND LEVEL OF ITERATIONS
C CHECK ENVELOPE TRIANGLE BEFORE ITERATING FOR SOLUTION
            IF(LARGE) GOTO 15
            LSBC = .TRUE.
            NITER = NITER2
            ITLVL = 2
            CALL CRRECT(DELTS,M,NITER,LFINI,LARGE,LNEW,LRESET,LSBC,
     *           TRIT,TRIL,CFENV,PS,TS,RS,FTRI,ISTORE,ESTORE,HSTOT,
     *           BL,TEFFL,HD,HHA,HHB,HHC,HL,HMAX,HP,HPP,HR,HS,HS1,
     *           HS2,HSRF,HT,HTT,HCOMP,LC,NHMAX,TLUMX,LATMO,LDERIV,
     *           LMIX,LOCOND,QDT,QDP,MODEL,FP,FT,ETA2,OMEGA,R0,ITDONE,
     *           HG,HI,HJM, ITLVL,LCZ,MRZONE,MXZONE,NRZONE,NZONE,
     *           QIW,HKEROT,HKEROTO)
            IF(LARGE)GOTO 15
C 7/91 STORE CHANGES IN THE STRUCTURE. THESE CHANGES ARE USED TO GET AN
C IMPROVED FIRST GUESS AT THE STRUCTURE FOR THE NEXT MODEL IF LNEWS=T.
            IF(DELTS.GT.0.0D0)THEN
               DO 27 II = 1,M
                  HTT0(II)=HTT(II)/DELTS
                  HPP0(II)=HPP(II)/DELTS
                  HLL0(II)=2.0D0*(HL(II)-HLO(II))/(HL(II)+HLO(II))/DELTS
                  HRR0(II)=(HR(II)-HRO(II))/DELTS
 27            CONTINUE
            ENDIF
C THIRD LEVEL OF ITERATIONS
            LSBC = .FALSE.
            NITER = NITER3
            ITLVL = 3
            CALL CRRECT(DELTS,M,NITER,LFINI,LARGE,LNEW,LRESET,LSBC,
     *           TRIT,TRIL,CFENV,PS,TS,RS,FTRI,ISTORE,ESTORE,HSTOT,
     *           BL,TEFFL,HD,HHA,HHB,HHC,HL,HMAX,HP,HPP,HR,HS,HS1,
     *           HS2,HSRF,HT,HTT,HCOMP,LC,NHMAX,TLUMX,LATMO,LDERIV,
     *           LMIX,LOCOND,QDT,QDP,MODEL,FP,FT,ETA2,OMEGA,R0,ITDONE,
     *           HG,HI,HJM, ITLVL,LCZ,MRZONE,MXZONE,NRZONE,NZONE,
     *           QIW,HKEROT,HKEROTO)
            IF(LARGE)GOTO 15
            IF(.NOT.LROT)THEN
               ITDIF1 = 1
            ENDIF
C MHP 05/02
C IF THE CODE IS ITERATING BETWEEN THE STRUCTURE AND ROTATION
C SOLUTIONS, ENSURE THAT THE START-OF-TIMESTEP QUANTITIES
C HCOMPP (COMPOSITION) AND HJMSAV (ANGULAR MOMENTUM) ARE ONLY
C OVERWRITTEN ON THE LAST RUN THROUGH.
            IF(ITDIF1.GT.1)THEN
               DO I = 1,M
                  HJM0(I) = HJM(I)
                  DO J = 1,15
                     HCOMPP0(J,I) = HCOMPP(J,I)
                  END DO
               END DO
            ENDIF
            DO ITROT = 1, ITDIF1
C MHP 05/02 RESTORE ORIGINAL "START OF TIMESTEP"
C VALUES FOR THE COMPOSITION MATRIX
               IF(ITROT.GT.1)THEN
                  DO I = 1,M
                     DO J = 1,15
                        HCOMPP(J,I) = HCOMPP0(J,I)
                     END DO
                  END DO
               ENDIF
C 7/91 THE FOURTH LEVEL OF ITERATION REPEATS THE ITERATION BETWEEN THE
C MIXING AND THE STRUCTURE VARIABLES.  IT SHOULD NOT BE USED FOR MODELS
C WHERE SEMI-CONVECTION IS IMPORTANT (ITERATING BETWEEN THE BURNING AND
C STRUCTURE GENERATES OSCILLATIONS). IT SHOULD BE USED FOR HIGH-PRECISION
C WORK (E.G. SOLAR MODELS).
C Surface boundary conditions checked again since we've changed the 
C composition (and hence the structure) of the model in ITLVL=3
C (to be implemented when I know the rest of it works!)
            NITER = NITER4
            LSBC=.FALSE.
            ITLVL = 4
            CALL CRRECT(DELTS,M,NITER,LFINI,LARGE,LNEW,LRESET,LSBC,
     *           TRIT,TRIL,CFENV,PS,TS,RS,FTRI,ISTORE,ESTORE,HSTOT,
     *           BL,TEFFL,HD,HHA,HHB,HHC,HL,HMAX,HP,HPP,HR,HS,HS1,
     *           HS2,HSRF,HT,HTT,HCOMP,LC,NHMAX,TLUMX,LATMO,LDERIV,
     *           LMIX,LOCOND,QDT,QDP,MODEL,FP,FT,ETA2,OMEGA,R0,ITDONE,
     *           HG,HI,HJM,ITLVL,LCZ,MRZONE,MXZONE,NRZONE,NZONE,
     *           QIW,HKEROT,HKEROTO)
 25         CONTINUE
            IF(.NOT.LFINI) THEN
C MODEL FAILED TO CONVERGE WITHIN(NITER1+NITER2+NITER3+NITER4)ITERATIONS
               LARGE = .TRUE.
               GOTO 15
            ENDIF

C MODEL HAS CONVERGED
C ENSURE CONVECTION ZONES ARE FULLY MIXED.
C MHP 02/12 INFER CONVECTIVE OVERTURN TIMESCALE (USED IN MDOT)
C JVS 02/12 CALL MIXCZ(HCOMP,HS2,LC,M)
C G Somers 6/14, SET IMIX = .TRUE. SO THE CORRECT GRADS ARE USED.
      IMIX = .TRUE.
      CALL MIXCZ(HCOMP,HS2,HS1,LC,HR,HP,HD,HG,M,IMIX)
C G Somers END
		
C MHP 9/94 STORE TOTAL AGE IN SAGE
            SAGE = DAGE
C JVS 02/12 STITCH TOGETHER CONVERGED INTERIOR, ENVELOPE, AND ATMOSPHERE
C		CALL STITCH(HCOMP,HR,HP,HD,HG,HS,HT,FP,FT,TEFFL,HSTOT,BL,M,
C     *HCOMPF,HRF,HPF,HDF,HSF,HTF,MM,LC)
            IF(LROT) THEN
C RESTORE ORIGINAL START OF TIMESTEP VALUES
C TO THE ANGULAR MOMENTUM DISTRIBUTION
               IF(ITROT.GT.1)THEN
                  DO I = 1,M
                     HJM(I) = HJM0(I)
                  END DO
               ENDIF
C MHP 9/94 ADDED FLAG TO TURN ON ROTATION OUTPUT WHEN END OF KIND
C CARD REACHED.
C MHP 10/24 GENERALIZE CHECK
         IF(LENDAG(NK).AND.ENDAGE(NK).GT.0.0D0. AND.
     *   (ABS(ENDAGE(NK)-DAGE*1.0D9-DDAGE) .LE. 1.0D0)) THEN
C               IF(LENDAG(NK).AND.ENDAGE(NK)-DAGE*1.0D9.LE.1.0D0)THEN
                  LPRT0 = .TRUE.
               ELSE
                  LPRT0 = .FALSE.
               ENDIF
C FIND THE NEW RUN OF OMEGA
C JENV0 ADDED TO SR CALL.
               LJDOT = LJDOT0 
               CALL GETW(BL,DELTS,DWMAX,FP,FT,HCOMP,HD,HJM,HL,HP,HR,
     *              HS,HS1,HS2,HSTOT,HT,LC,LJDOT,M,MODEL,SJTOT,SMASS,
     *              TEFFL,ETA2,HG,HI,OMEGA,QIW,R0,JENV0)
C CALCULATE FP AND FT GIVEN OMEGA FOR THE NEW POINT DISTRIBUTION
               CALL FPFT(HD,HR,HS,M,OMEGA,ETA2,FP,FT,HG,R0)
            ENDIF
            END DO
C LOCATE THE HYDROGEN-BURNING SHELL AND THE BOUNDARIES OF THE CENTRAL
C AND SURFACE CONVECTION ZONES (IF APPLICABLE).
	 CALL FINDSH(HCOMP,HL,LC,M,JCORE,JENV,JXBEG,JXEND,JXMID,
     *               LSHELL)
C PERFORM LIGHT ELEMENT BURNING
         IF(LEXCOM .AND. MODEL.GE.0 .AND. DELTS.GT.0.0D0)THEN
C ONLY FOR MODELS WITHOUT ROTATION, OR WITHOUT ROTATIONAL MIXING.
            IF(.NOT.LROT .OR. .NOT.LINSTB)THEN
C FIND CONVECTION ZONE DEPTH AT THE END OF THE TIME STEP.
               CALL CONVEC(HCOMP,HD,HP,HR,HS,HT,LC,M,MRZONE,MXZONE,
     *                      MXZON0,JCORE,JENV,NRZONE,NZONE,NZONE0)
C CHANGED FOR LITHIUM BURNING WITH OVERSHOOT.
               JENV1 = JENV
               IF(LOVSTE)THEN
                  PSCAL1 = ALPHAE*EXP(CLNDP*(HP(JENV)+2.0D0*HR(JENV)
     *                     -HD(JENV)-CGL-HS(JENV)))
               ELSE
                  PSCAL1 = 0.0D0
               ENDIF
C FIND BURNING RATES AT THE END OF THE TIME STEP.
               CALL LIRATE88(HCOMP,HD,HT,M,2)
               CALL LIBURN(DELTS,HCOMP,HD,HR,HS1,HS2,HT,JENV1,JENV0,M)
            ENDIF
         ENDIF
C MHP 07/02 RESTORE PRIOR FITTING POINT IF MASS ACCRETION IS BEING
C INCLUDED
         IF(LNEWFIT)THEN
            CALL GETNEWENV(SENVOLD,HCOMP,HD,HL,HP,HR,HS,HS1,HS2,
     *                     HSTOT,HT,LC,ETA2,HG,HI,HJM,QIW,R0,
     *                     HKEROT,BL,SJTOT,SKEROT,TEFFL,M,LNEW)
C CALCULATE FP AND FT GIVEN OMEGA FOR THE NEW POINT DISTRIBUTION
            CALL FPFT(HD,HR,HS,M,OMEGA,ETA2,FP,FT,HG,R0)
            LNEWFIT = .FALSE.
         ENDIF
C DETERMINE TIMESTEP FOR NEXT MODEL
C HTIMER ALSO LOCATES THE H-BURNING SHELL
C JVS 04/14 added teffl to passed htimer variables
	 DELTS = DABS(DELTS)
	 DELTS0 = DELTS
	 CALL HTIMER(DELTS,DELTSH,M,HD,HL,HS1,HS2,HT,LC,HCOMP,JCORE,
     *        JXMID,TLUMX,DAGE,DDAGE,QDT,QDP,NK,HP,HR,OMEGA,
     *        DWMAX,JXBEG,TEFFL)
C  IF EVOLVING TO A GIVEN AGE AND KIND CARD IS DONE, AVOID ZEROING OUT
C  TIMESTEP WRITTEN TO MODEL (AS THIS MAKES CONTINUING A SEQUENCE AWKWARD.)
C     INSTEAD WRITE THE PREVIOUS MODEL TIMESTEP TO MODEL.
C ONLY IF A FIXED END AGE IS USED, NOT FOR OTHER STOPS
	 IF(LENDAG(NK) .AND. ENDAGE(NK).GT.0.0D0)THEN
	    IF(ENDAGE(NK)-DAGE*1.0D9.LE.1.0D0)THEN
	       DELTS = MAX(DELTS0,1.0D-3*DAGE*CSECYR)
	       DDAGE = DELTS/CSECYR
	    ELSE
	       DELTS0 = DELTS
	    ENDIF
	 ELSE
	    DELTS0 = DELTS
	 ENDIF
	 IF(IRESCA(NK).NE.2) MODEL = MODEL+1
C WRTOUT IS THE OUTPUT DRIVER ROUTINE
	 CALL WRTOUT(HCOMP,HD,HL,HP,HR,HS,HS1,HT,LC,M,MODEL,DAGE,
     *        DDAGE,SMASS,TEFFL,BL,GL,LSHELL,JXBEG,JXMID,JXEND,JCORE,
     *        JENV,TLUMX,TRIT,TRIL,PS,TS,RS,CFENV,FTRI,HSTOT,OMEGA,
     *        LPUNCH,FP,FT,ETA2,R0,HJM,HI,SJTOT,SKEROT,HS2,NK)

C MHP 10/24 GENERALIZED STOP CONDITIONS
C     IF EVOLVING TO A GIVEN AGE AND AGE IS REACHED, KIND CARD IS DONE
C	 IF(LENDAG(NK).AND.ENDAGE(NK)-DAGE*1.0D9.LE.1.0D0)GOTO 110
	 IF(LENDAG(NK).AND.ENDAGE(NK).GT.0.0D0 .AND.
     *   (ENDAGE(NK)-DAGE*1.0D9).LE.1.0D0)GOTO 110
C MHP 10/24 CHECK ALL STOP CONDITIONS, EXIT IF ANY SATISFIED
         LEND_KIND = .FALSE.
         IF(LENDAG(NK).AND.END_DCEN(NK).GT.0.0D0 .AND.
     *        HCOMP(12,1).LT.END_DCEN(NK))THEN
            WRITE(*,104)HCOMP(12,1),END_DCEN(NK)
 104        FORMAT('CENTRAL D ',E12.4,' BELOW STOP VALUE ',E12.4)
            LEND_KIND =.TRUE.
         ENDIF
         IF(LENDAG(NK).AND.END_XCEN(NK).GT.0.0D0 .AND.
     *        HCOMP(1,1).LT.END_XCEN(NK))THEN
            WRITE(*,105)HCOMP(1,1),END_XCEN(NK)
 105        FORMAT('CENTRAL X ',E12.4,' BELOW STOP VALUE ',E12.4)
            LEND_KIND =.TRUE.
         ENDIF
         IF(LENDAG(NK).AND.END_YCEN(NK).GT.0.0D0 .AND.
     *        HCOMP(2,1).LT.END_YCEN(NK))THEN
            WRITE(*,106)HCOMP(2,1),END_YCEN(NK)
 106        FORMAT('CENTRAL Y ',E12.4,' BELOW STOP VALUE ',E12.4)
            LEND_KIND =.TRUE.
         ENDIF
C IF EXITING, SET I/O FLAGS PROPERLY AND EXIT LOOP
         IF(LEND_KIND)THEN
            LPULSE = LSAVPU
            LSOUND = .TRUE.
            LPRT0 = .TRUE.
            GOTO 110
         ENDIF
C TEST IF MODEL IS NEAR DESIRED Teff AND L. IF NOT RESCALE AND TRY AGAIN.
         IF (LCALST .AND. .NOT. LSTAR) THEN
            IF(MOD(NK,2).EQ.0)THEN
	       IF(MODELN.EQ.1) THEN
	          TEFFI = 10.0D0**TEFFL
	       ELSE 
	          CALL CHKSCAL(BL, TEFFL, DAGE, NK)
	          IF(LPASSR) GOTO 200
	       END IF
	    ENDIF
	 ENDIF

C END OF RUN
  100    CONTINUE

C G Somers 11/14, CHANGE CALL TO PUTSTORE INSTEAD OF WRTLST.
C STORE LAST MODEL IN ISTOR IF LSTORE, LSTPCH, AND LPUNCH ARE .TRUE.
  110    IF(LSTORE.AND.LSTPCH.AND.LPUNCH) THEN
	    CALL PUTSTORE(HCOMP,HD,HL,HP,HR,HS,HT,LC,TRIT,TRIL,PS,TS,RS,
     *           CFENV,FTRI,TLUMX,JCORE,JENV,MODEL,M,SMASS,TEFFL,BL,HSTOT,
     *           DAGE,DDAGE,OMEGA,HS1,ETA2,R0,FP,FT,HJM,HI)
            LPUNCH = .FALSE.
	 ENDIF
C 110  CONTINUE
C G Somers END
      
C MHP 1/93 CHECK AUTOMATIC CALIBRATATION OF SOLAR MODEL.
c MHP 5/96 changed solar calibration to perform solar models in 3 kind cards
         IF(LCALS)THEN
C JVS Turn off calcad - speeds things up
		LADON=.FALSE.
            IF(MOD(NK,3).EQ.0)THEN
               RLL = 0.5D0*(BL+CLSUNL-C4PIL-CSIGL-4.0D0*TEFFL)-CRSUNL
C MHP 06/13 Add solar Z/X to observables
               SOLZX = HCOMP(3,M)/HCOMP(1,M)
               CALL CHKCAL(BL,RLL,NK,SOLZX)
C               CALL CHKCAL(BL,RLL,NK)
               lptime = lptimesv  ! Restore LPTIME to original value for next cycle
               kttau  = kttausv    ! Restore KTTAU to original value for next cycle
               IF(LSOL) THEN
                  GO TO 250
               ELSE
c MHP 8/96 added counter for # of runs needed for calibration
                  ICONV = ICONV + 1
C MHP 6/97 STOP AFTER 10 ATTEMPTS AT CALIBRATION
c                  IF(ICONV.GE.11) GOTO 250
                  IF(ICONV.GE.15) GOTO 250
                  IF (LPULSE) THEN
C DBG 6/93 Need to delete pulse output because have not got ultimate
C model yet.
                     CLOSE(IOPMOD, STATUS='DELETE')
                     CLOSE(IOPENV, STATUS='DELETE')
                     CLOSE(IOPATM, STATUS='DELETE')
                     OPEN(IOPMOD, FILE=FPMOD,STATUS='UNKNOWN',
     *                    FORM='FORMATTED')
                     OPEN(IOPENV, FILE=FPENV,STATUS='UNKNOWN',
     *                    FORM='FORMATTED')
                     OPEN(IOPATM, FILE=FPATM,STATUS='UNKNOWN',
     *                    FORM='FORMATTED')
                  END IF
               END IF
            ENDIF
         ENDIF

C DBG 12/94 NO MORE RUNS NEEDED. HAVE CALIBRATED STELLAR MODEL
         IF(LCALST .AND. LSTAR.AND.(MOD(NK,2).EQ.0)) GOTO 250

C END RUN LOOP
 200  CONTINUE
C EXIT RUN LOOP
 250  CONTINUE

C FOR MONTE CARLO, REWIND OUTPUT FILES AND WRITE OUT SNU FLUXES AND
C MODEL PARAMTERS TO AN OUTPUT FILE.
C RUN FAILED TO CONVERGE.  WRITE FINAL INFO WITH WARNING NOTE.
      IF(LMONTE .AND. ICONV.GE.11 .AND. .NOT.LSOL)THEN
         REWIND(ILAST)
         REWIND(IFIRST)
         REWIND(IDEBUG)
         REWIND(ITRACK)
         REWIND(ISHORT)
         REWIND(IMODPT)
         REWIND(ISTOR)
         WRITE(ISNU,1525)BL,RLL
 1525    FORMAT(5X,'DID NOT CONVERGE WITHIN 10 ATTEMPTS L,R',2F10.6)
C MONTE CARLO #, CONVERGED MIXING LENGTH AND INITIAL H, SURFACE X,
C SURFACE Z, Z/X, CENTRAL X, CENTRAL Z
         WRITE(ISNU,1519) NN,CMIXLA(NK),RESCAL(2,NK-2),HCOMP(1,M),
     *        HCOMP(3,M),ZTOX,HCOMP(1,1),HCOMP(3,1)
 1519    FORMAT(1X,I5,3F10.6,4E10.3)
C NUMERICAL DATA : #OF RUNS NEEDED FOR A CONVERGED MODEL, INITIAL X
C AND ALPHA, FINAL DL/DX,DR/DX,DL/D ALPHA, DR/D ALPHA
         WRITE(ISNU,1518)ICONV,XGUESS,AGUESS,DLDX,DRDX,DLDA,DRDA
C SUMMARY OF STRUCTURE : TC, RHOC, PC
         WRITE(ISNU, 1517)TCENTER,PCENTER,DCENTER,
     *        HCOMP(1,1),HCOMP(3,1)
C NEUTRINO FLUXES (SEE ENGEB FOR DETAILS)
         WRITE(ISNU, 1516) CLSNU,GASNU,(FLUXTOT(I),I=1,8)
         CALL WRTMONTE(HCOMP,HD,HL,HP,HR,HS,HT,LC,M,MODEL,DAGE,
     *        DDAGE,SMASS,TEFFL,BL,GL,LSHELL,JXBEG,JXMID,
     *        JXEND,JCORE,JENV,TLUMX,TRIT,TRIL,PS,TS,RS,
     *        CFENV,FTRI,HSTOT,OMEGA,RLL,ICONV,NK,NN)
      ELSE IF(LCALS .AND. LSNU .AND. LSOL)THEN
         REWIND(ILAST)
         REWIND(IFIRST)
         REWIND(IDEBUG)
         REWIND(ITRACK)
         REWIND(ISHORT)
         REWIND(IMODPT)
         REWIND(ISTOR)

         ZTOX = HCOMP(3,M)/HCOMP(1,M)
C HEADER FILE:  MONTE CARLO PARAMETERS
         IF(LMONTE)THEN
            WRITE(ISNU,1520)NN,S11(NN),S33(NN),S34(NN),S17(NN),
     *           ZX(NN),FHE(NN),FZDIF(NN),FLUM(NN),FAGE(NN)
         ENDIF
 1520    FORMAT(I7,1P9E10.3)
C NUMERICAL DATA : #OF RUNS NEEDED FOR A CONVERGED MODEL, INITIAL X
C AND ALPHA, FINAL DL/DX,DR/DX,DL/D ALPHA, DR/D ALPHA
         WRITE(ISNU,1518)ICONV,XGUESS,AGUESS,DLDX,DRDX,DLDA,DRDA
 1518    FORMAT(1X,I2,2F10.6,1P4E11.4)
C NEUTRINO FLUXES (SEE ENGEB FOR DETAILS)
         WRITE(ISNU, 1516) CLSNU,GASNU,(FLUXTOT(I),I=1,10)
 1516    FORMAT(1X,2F8.3,1P10E10.3)
C SUMMARY OF STRUCTURE : TC, RHOC, PC, XC, ZC (ADD MU C)
         TCEN = 10.0D0**(TCENTER-6.0D0)
         PCEN = 10.0D0**(PCENTER-17.0D0)
         DCEN = 10.0D0**DCENTER
         WRITE(ISNU, 1517)TCEN,DCEN,PCEN,HCOMP(1,1),HCOMP(3,1)
 1517    FORMAT(1X,F7.3,F7.2,F6.3,2F8.5)
C INITIAL ALPHA,Y,Z,ALPHA; FINAL R, L
         YINI = 1.0D0 - RESCAL(2,NK-2) - RESCAL(3,NK-2)
         ZINI = RESCAL(3,NK-2)
         WRITE(ISNU,1521)CMIXLA(NK),YINI,ZINI,BL,RLL
 1521    FORMAT(F7.4,2F8.5,1P2E10.3)  
C CZ DEPTH (R,M), SURFACE Y, Z, Z/X (ADD T CZ BASE, RHO CZ BASE)
         WRITE(ISNU,1522)ENVR,ENVLM,HCOMP(2,M),HCOMP(3,M),ZTOX
 1522    FORMAT(F8.5,F9.6,2F8.5,F9.6)
C ENERGY GENERATION FRACTIONS PP I,II,III,CNO,EGRAV
         WRITE(ISNU,1523)(TLUMX(J),J=1,4),TLUMX(7)
 1523    FORMAT(1P5E10.3)
         IF(LMONTE)THEN
            CALL WRTMONTE(HCOMP,HD,HL,HP,HR,HS,HT,LC,M,MODEL,DAGE,
     *           DDAGE,SMASS,TEFFL,BL,GL,LSHELL,JXBEG,JXMID,
     *           JXEND,JCORE,JENV,TLUMX,TRIT,TRIL,PS,TS,RS,
     *           CFENV,FTRI,HSTOT,OMEGA,RLL,ICONV,NK,NN)
         ENDIF
      ENDIF
 500  ENDDO

      STOP
      END
