C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     SETUPOPAC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
      SUBROUTINE SETUPOPAC(XENV, FALEX06,
     *FLIV95,FPUREZ)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NEWOPAC/ into NEWOPAC_MOD.
      USE NEWOPAC_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 XENV

C     MHP 8/25 Added pass-through file names
      CHARACTER*256 FALEX06,FLIV95,
     * FPUREZ
C 10/13/26 MHP via Claude: removed the unused COMMON/IOUNITS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
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

C
C     THIS SUBROUTINE READS IN SPECIFIED OPACITY TABLES AND
C     SET UP SPLINES FOR THE TABLES.
C     WHEN LZRAMP=T OR LDIFZ=T THEN READ IN SECOND SET OF
C     OPACITY TABLES AT DIFFERENT Z (E.G. ZOPAL952).
      L2Z = LZRAMP.OR.LDIFZ
C
C     INTERIOR TABLES
C
C     READ IN OPAL95 TABLES
      IF (LOPAL95) THEN
        CALL LL95TBL(FLIV95)
      CALL OP95XTAB(XENV)
      END IF

C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C
C     READ IN PURE Z TABLE
C
      IF(LPUREZ)THEN
         CALL RDZLAOL(FPUREZ)
       CALL ZSULAOL
      END IF
C
C     LOW TEMP TABLES
C
C     READ IN ALEX 2006 TABLES
      IF (LALEX06) THEN
        CALL READALEX06(FALEX06)
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
      END IF
      RETURN
      END
