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

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C     MHP 8/25 Added pass-through file names
      CHARACTER*256 FALEX06,FLIV95,
     * FPUREZ
C OPACITY COMMON BLOCKS - modified 3/09
C 9/24/26 MHP via Claude
C code changed to remove dead opacity-table Z-value inputs
C 9/24/26 MHP via Claude
C code changed to merge COMMON /MISCOPAC/ and COMMON/NWLAOL/ into
C COMMON /NEWOPAC/
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
      COMMON/NEWOPAC/ZOPAL951,TMOLMIN,TMOLMAX,TOLLAOL,LALEX06,LOPAL95,
     *  L2Z,LLAOL,LPUREZ,LcondOpacP
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead IOOPAL2 from COMMON/ZRAMP/
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *             IOLAOL2, NK,
     *             LZRAMP
      COMMON/GRAVS3/FGRY,FGRZ,LTHOUL,LDIFZ
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
