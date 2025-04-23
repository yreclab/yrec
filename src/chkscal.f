C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CHKSCAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE CHKSCAL(BL, TEFFL, DAGE, NK)
      use parmin90, only : ITRACK  ! COMMON/LUOUT/
      use parmin90, only : CLSUN, CRSUN  ! COMMON/CONST/
      use parmin90, only : C4PI  ! COMMON/CONST1/
      use parmin90, only : CSIG  ! COMMON/CONST2/

C     ONLY CALLED FOR EVEN NK, ASSUMES RESCALING ON ODD NK AND EVOLVING
C     ON EVEN NK
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON /CKIND/RESCAL(4,50),NMODLS(50),IRESCA(50),LFIRST(50),
     1        NUMRUN
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50)
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
      COMMON /NEWXYM/XENV0A(50),ZENV0A(50),CMIXLA(50),LSENV0A(50),
     1 SENV0A(50)
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
C     BL        luminosity of current model log(L/Lsun)
C     BLI       luminosity of previous model
C     BLR       luminosity of model at R
C     BLRP      luminosity of model at R* of previous run
C     XP        X of previous run = RESCAL(2, NK-1)
C
C     Check if star has passed R*.
C     If not store L and age and return.
      LPASSR=.FALSE.
      TEFF = 10.0D0**TEFFL
      ALR = SQRT((10.0D0**BL)*CLSUN/(C4PI*CSIG))/(TEFF*TEFF*CRSUN)
      IF(ALR.GT.ALRI) THEN
         IF(.NOT.(ALR.GT.SR.AND.ALRI.LE.SR)) THEN
              BLI = BL
              AGEI = DAGE
              ALRI = ALR
              RETURN
          END IF
      ELSE
          IF (.NOT.(ALR.LT.SR.AND. ALRI.GE.SR)) THEN
              BLI = BL
              AGEI = DAGE
              ALRI = ALR
              RETURN
           END IF
      ENDIF   
C
C     Check if track has passed through Teff the right number of
C     times. If not store L and age and return.
C ZZZ
      WRITE(*,*) ' Just passed R*'
      WRITE(ITRACK,*) '#Just passed R*'
      LPASSR = .TRUE.
C
C     Have previous L,Age and current L,Age (one before R* and 
C     one after R*).  Interpolate to get L,Age at R*
      DLDR = (BL-BLI)/(ALR-ALRI)
      BLR = BL + DLDR*(SR-ALR)
      DADR = (DAGE-AGEI)/(ALR-ALRI)
      AGER = DAGE + DADR*(SR-ALR)
      WRITE(*,*) ' X, LogL/Lsun at R* =', RESCAL(2,NK-1), BLR
      WRITE(ITRACK,*) '#X, LogL/Lsun at R* =', RESCAL(2,NK-1), BLR
      IF (ABS(10.0D0**BLR-XLS) .LE. XLSTOL) THEN
C        Get here then have track that passes through specified
C        L and R. Use age at R for final
C        run to stop at that age. Do one more run
C        stopping at interpolated age.
         LSTAR=.TRUE.
	 LENDAG(NK+1) = .TRUE.
	 ENDAGE(NK+1) = AGER*1.0D9
	 LENDAG(NK+2) = .TRUE.
	 ENDAGE(NK+2) = AGER*1.0D9
	 RESCAL(2,NK+1) = RESCAL(2,NK-1)
	 XENV0A(NK+1) = RESCAL(2,NK+1)
	 XENV0A(NK+2) = XENV0A(NK+1)
C 
      WRITE(*,*) ' Have hit R* & L*, prepare final run to age:',
     1  AGER
      WRITE(ITRACK,*)'#Have hit R* & L*, prepare final run to age:',
     1  AGER
         RETURN	 
      ELSE
         IF (NK .EQ. 2) THEN
C           First time through. Save L and X at R*. 
C           Add 0.01 to Y. Start next run.
            BLRP = BLR
	    XP = RESCAL(2,NK-1)
	    X = XP - 0.01D0
	    RESCAL(2,NK+1) = X
	    XENV0A(NK+1) = X
	    XENV0A(NK+2) = X
C 
      WRITE(*,*) ' NK=2, Y=Y+0.01, Setup next run, X=', X
      WRITE(ITRACK,*) '#NK=2, Y=Y+0.01, Setup next run, X=', X
            RETURN
	 ELSE 
C           If NK=4,6,8,... (second and more times through) then
C           Use current and previous values of L at R and X to calculate
C           dX/dlogL. Save L.  Start next run.
            X = RESCAL(2, NK-1)
	    XP = RESCAL(2, NK-3)
            DXDL = (X-XP)/(BLR-BLRP)
	    X = DXDL*(LOG10(XLS)-BLR)+X
C 
      WRITE(*,*) ' Setup next run, NK, X =', NK, X
      WRITE(ITRACK, *) ' Setup next run, NK, X =', NK, X
	    BLRP = BLR
	    RESCAL(2,NK+1) = X
	    XENV0A(NK+1) = X
	    XENV0A(NK+2) = X
	 END IF
      ENDIF
      RETURN
      END
