

C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SETSCAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SETSCAL(ALRI,LSTAR,LPASSR)
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
      REAL*8 ALRI
      INTEGER I,J
      LOGICAL*4 LPASSR,LSTAR
C 10/13/26 MHP via Claude
C code changed to replace COMMON/CALSTAR/ with explicit arguments.
C setscal.f initializes ALRI, LSTAR and LPASSR, chkscal.f reads and
C updates ALRI and sets the two flags, and main.f reads the flags; main.f
C calls both routines, so it now owns all three.  ALRI is read as well as
C written inside chkscal.f and is carried across calls there, which
C main.f's blanket SAVE preserves exactly as the block did.
C MHP 8/25 Removed unused variables
C      CHARACTER*256 FLAOL2, FOPAL2
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
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead IOOPAL2 from COMMON/ZRAMP/
C 10/9/26 MHP via Claude
C code changed to remove NK from COMMON/ZRAMP/: it was only ever a
C redundant copy of the run-index loop variable main.f already passes
C explicitly to the subroutines that need it (STARIN/RSCALE), and was
C never read by name in this file (the "NK-1" in the comment below is
C just documentation, not live code).
C 10/13/26 MHP via Claude
C code changed to remove COMMON/ZRAMP/: its sole remaining member
C IOLAOL2 is neither written nor read anywhere.  The namelist members
C that shared this block moved to the consolidated block in stage 2b.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 10/12/26 MHP via Claude
C code changed to drop BLI, AGER, BLR, BLRP and AGEI from
C COMMON/CALSTAR/; they are written and read only in chkscal.f and are
C now locals there.  This file never referenced them.
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
