C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CHKSCAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE CHKSCAL(BL, TEFFL, DAGE, NK,ALRI,LSTAR,LPASSR)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
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
      REAL*8 AGEI,AGER,ALR,ALRI,BL,BLI,BLR,BLRP,DADR,DAGE,DLDR,DXDL,
     *       TEFF,TEFFL,X,XP
      INTEGER NK
      LOGICAL*4 LPASSR,LSTAR
C     ONLY CALLED FOR EVEN NK, ASSUMES RESCALING ON ODD NK AND EVOLVING
C     ON EVEN NK
C 10/13/26 MHP via Claude
C code changed to replace COMMON/CALSTAR/ with explicit arguments.
C setscal.f initializes ALRI, LSTAR and LPASSR, chkscal.f reads and
C updates ALRI and sets the two flags, and main.f reads the flags; main.f
C calls both routines, so it now owns all three.  ALRI is read as well as
C written inside chkscal.f and is carried across calls there, which
C main.f's blanket SAVE preserves exactly as the block did.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
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
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
C 10/12/26 MHP via Claude
C code changed to demote BLI, AGER, BLR, BLRP and AGEI from
C COMMON/CALSTAR/ to locals of this routine.  All five are written and
C read only here -- BLI/AGEI at the interpolation setup, BLR/AGER/BLRP in
C the radius-matching iteration below -- while main.f, parmin.f and
C setscal.f merely carried them positionally.  The blanket SAVE below
C keeps their values across calls exactly as COMMON storage did, which
C BLRP relies on, being set on one call and read on the next.  Only
C ALRI, LSTAR and LPASSR are genuinely shared; setscal.f initializes
C those three.
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
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
