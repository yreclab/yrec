

C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SETSCAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SETSCAL
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C MHP 8/25 Removed unused variables
C      CHARACTER*256 FLAOL2, FOPAL2
      COMMON /CKIND/RESCAL(4,50),NMODLS(50),IRESCA(50),LFIRST(50),
     1        NUMRUN
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      COMMON/IOUNITS/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,
     *  IOWR,IFIRST,IRUN,ISTAND,IFERMI,IOPMOD,IOPENV,IOPATM,ISNU,
     *  IALEX06,ICLCD,IJLAST,IOPUREZ,IcondOpacP,ILIV95,IOATM,IOATMA,
     *  IOPALE,ISCVH,ISCVHE,ISCVZ
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50)
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
      COMMON /NEWXYM/XENV0A(50),ZENV0A(50),CMIXLA(50),LSENV0A(50),
     1 SENV0A(50)
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead IOOPAL2 from COMMON/ZRAMP/
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *             IOLAOL2, NK,
     *             LZRAMP
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR
      COMMON/CALSTAR/XLS, XLSTOL,  STEFF, SR,
     1      BLI, ALRI, AGER, BLR, BLRP, AGEI,
     2      LSTAR, LTEFF, LPASSR,LCALST
      SAVE
C     LSTAR     T - have got a star at Teff and L
C     LPASSR    T - on run have just passed Teff
C     XLS       Luminosity (L/Lsun) wanted by adjusting Y
C     XLSTOL    tolerance wanted for luminosity
C     LTEFF     T - specify Teff for star
C               F - specify R/Rsun for star
C     STEFF     Effective temperature of star (K) or...
C     SR        Radius of star (R/Rsun)
C     TEFF      Teff of current model
C     ALR       log(R/Rsun) of current model
C     ALRI      log(R/Rsun) of previous model
C     DAGE      age of current model (Gyr)
C     AGEI      age of previous model (Gyr)
C     AGER      age of model at R*
C     BL        luminosity of current model
C     BLI       luminosity of previous model
C     BLR       luminosity of model at R
C     BLRP      luminosity of model at R* of previous run
C     XP        X of previous run = RESCAL(2, NK-1)
C mhp 10/02 linct not used, commented out
C      LINCT = .TRUE.
      LSTAR = .FALSE.
      LPASSR = .FALSE.
      IF (LTEFF) THEN
         SR = SQRT(XLS*CLSUN/(C4PI*CSIG))/(STEFF*STEFF*CRSUN)
      ELSE
         STEFF = ((XLS*CLSUN)/(C4PI*CSIG*SR*SR*CRSUN*CRSUN))**0.25D0
      END IF
      ALRI = 0
C     SET UP RUN TO EVOLVE TO L, Teff IN HR-DIAGRM.
C     THIS CONSISTS OF SETTING THE NUMBER OF RUNS TO THE MAXIMUM (50),
C     AND COPYING THE RELEVANT PARAMETERS FROM THE FIRST TWO RUNS TO
C     THE NEXT SERIES OF 24 CALIBRATING RUNS.
      NUMRUN = 50
      DO I = 2,50
         XENV0A(I) = XENV0A(1)
         ZENV0A(I) = ZENV0A(1)
         CMIXLA(I) = CMIXLA(1)
         LSENV0A(I) = LSENV0A(1)
         SENV0A(I) = SENV0A(1)
      END DO
      DO I = 3,49,2
         IRESCA(I) = IRESCA(1)
         LFIRST(I) = .TRUE.
         NMODLS(I) = NMODLS(1)
         RSCLZC(I) = RSCLZC(1)
         RSCLZM1(I) = RSCLZM1(1)
         RSCLZM2(I) = RSCLZM2(1)
         DO J = 1,4
            RESCAL(J,I) = RESCAL(J,1)
         END DO
      END DO
      DO I = 4,50,2
         IRESCA(I) = 1
         LFIRST(I) = .FALSE.
         NMODLS(I) = NMODLS(2)
         ENDAGE(I) = ENDAGE(2)
         LENDAG(I) = LENDAG(2)
         SETDT(I) = SETDT(2)
         LSETDT(I) = LSETDT(2)
      END DO
      WRITE(*,*) ' Evolve to R*, L* = ', SR, XLS
      WRITE(ITRACK,*) '#Evolve to R*, L* = ', SR, XLS
      RETURN
      END
