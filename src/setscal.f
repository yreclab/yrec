

C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SETSCAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SETSCAL
      use settings, only : ITRACK  ! /LUOUT/
      use settings, only : RESCAL, NMODLS, IRESCA, LFIRST, NUMRUN  ! /CKIND/
      use settings, only : CLSUN, CRSUN  ! /CONST/
      use settings, only : C4PI  ! /CONST1/
      use settings, only : CSIG  ! /CONST2/
      use settings, only : ENDAGE, SETDT, LENDAG, LSETDT  ! /SETT/
      use settings, only : XENV0A, ZENV0A, CMIXLA, LSENV0A, SENV0A  ! /NEWXYM/
      use settings, only : RSCLZC, RSCLZM1, RSCLZM2  ! /ZRAMP/
      use settings, only : XLS, STEFF, SR, ALRI, LSTAR, LTEFF, LPASSR  ! /CALSTAR/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
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
