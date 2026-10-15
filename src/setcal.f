C $$$$$$
      SUBROUTINE SETCAL(FACAGE,LSOL)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/RUNLOOP/ into RUNLOOP_MOD.  A blanket
C USE imports exactly the names the COMMON declaration made global here,
C so it cannot change meaning.  See runloop_mod.f for the block history
C and for why the module declares the types the implicit rules supplied.
      USE RUNLOOP_MOD

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
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
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
C 10/13/26 MHP via Claude
C code changed to replace COMMON/CALSUN/ with an explicit argument.  This
C routine touched only LSOL, which it clears; the block's other eight
C members were carried here positionally and never used.
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead IOOPAL2 from COMMON/ZRAMP/
C 10/9/26 MHP via Claude
C code changed to remove NK from COMMON/ZRAMP/: it was only ever a
C redundant copy of the run-index loop variable main.f already passes
C explicitly to the subroutines that need it (STARIN/RSCALE), and was
C never read by name in this file.
C 10/13/26 MHP via Claude
C code changed to remove COMMON/ZRAMP/: its sole remaining member
C IOLAOL2 is neither written nor read anywhere.  The namelist members
C that shared this block moved to the consolidated block in stage 2b.
      SAVE

C SET UP RUN TO CALIBRATE A SOLAR MODEL.
C THIS CONSISTS OF SETTING THE NUMBER OF RUNS TO THE MAXIMUM (50),
C AND COPYING THE RELEVANT PARAMETERS FROM THE FIRST TWO RUNS TO
C THE NEXT SERIES OF 24 CALIBRATING RUNS.
c mhp 5/96 changed to do solar models in 3 runs rather than 2.
      NUMRUN = 48
      DO I = 2,48
         XENV0A(I) = XENV0A(1)
         ZENV0A(I) = ZENV0A(1)
         CMIXLA(I) = CMIXLA(1)
         LSENV0A(I) = LSENV0A(1)
         SENV0A(I) = SENV0A(1)
      END DO
      DO I = 4,46,3
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
C MHP 06/13 HARDWIRE RUN 2 TO 1D8 YEARS AND RUN3 TO CALSOLAGE YEARS
      ENDAGE(2) = 1.0D8*FACAGE
C      ENDAGE(2) = ENDAGE(2)*FACAGE
      SETDT(2) = SETDT(2)*FACAGE
      ENDAGE(3) = CALSOLAGE*FACAGE
C      ENDAGE(3) = ENDAGE(3)*FACAGE
      SETDT(3) = SETDT(3)*FACAGE
      DO I = 5,47,3
         IRESCA(I) = 1
         LFIRST(I) = .FALSE.
         NMODLS(I) = NMODLS(2)
         ENDAGE(I) = ENDAGE(2)
         LENDAG(I) = LENDAG(2)
         SETDT(I) = SETDT(2)
         LSETDT(I) = LSETDT(2)
      END DO
      DO I = 6,48,3
         IRESCA(I) = 1
         LFIRST(I) = .FALSE.
         NMODLS(I) = NMODLS(3)
         ENDAGE(I) = ENDAGE(3)
         LENDAG(I) = LENDAG(3)
         SETDT(I) = SETDT(3)
         LSETDT(I) = LSETDT(3)
      END DO
      LSOL = .FALSE.
      RETURN
      END
