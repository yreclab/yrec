C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PDIST
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

C calculates the distance the star has travelled in the HR diagram
C if far enough, output pulsation model
C MHP 8/25 passed file names directly and removed common block with file names
      SUBROUTINE PDIST(POL1,POT1,POA1,POLEN,BL,TEFFL,MODELN,FPATM,FPENV,
     * FPMOD)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      CHARACTER*256 COUT,CTEMP
C Removed variables not used in the routine
      CHARACTER*256 FPMOD, FPENV, FPATM
C MHP 10/02 added proper dimensions to last 2 variables
      COMMON/THEAGE/DAGE
      COMMON /PO/POA,POB,POC,POMAX,LPOUT
      COMMON/PULSE/XMSOL,LPULSE,IPVER
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead IOOPAL2 from COMMON/ZRAMP/
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *             IOLAOL2, NK,
     *             LZRAMP
C 9/24/26 MHP via Claude
C code changed to remove dead ILLDAT, IKUR from COMMON/LUNUM/
C 9/24/26 MHP via Claude
C code changed to remove dead IDYN from COMMON/LUNUM/
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
C 9/25/26 MHP via Claude
C code changed to remove dead COMMON/LUNUM/ISCOMP (declared,
C assigned a unit number, but never opened or read anywhere)
C MHP 8/25 Removed common block with file names
C      COMMON/LUFNM/ FLAST, FFIRST, FRUN, FSTAND, FFERMI,
C     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
C     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
C     3    FLLDAT, FSNU, FSCOMP, FKUR,
C     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
      SAVE

      TM1 = BL-POL1
      TM2 = TEFFL-POT1
      TM3 = DAGE-POA1
      TMP1 = POA*TM1*POA*TM1
      TMP2 = POB*TM2*POB*TM2
      TMP3 = POC*TM3*POC*TM3
      POLEN = POLEN+TMP1+TMP2+TMP3
      POL1 = BL
      POT1 = TEFFL
      POA1 = DAGE
      IF (POLEN .GE. POMAX) THEN
          LPULSE = .TRUE.
          POLEN = 0.0D0
          IOCCOL = INDEX(FPMOD,' ')-1
          IF (MODELN.LT.10000)THEN
             WRITE(CTEMP,'(I2.2,''_'',I4.4)')NK, MODELN
             COUT = FPMOD(1:IOCCOL) // CTEMP(1:7)
          ELSE
             WRITE(CTEMP,'(I2.2,''_'',I5.5)')NK, MODELN
             COUT = FPMOD(1:IOCCOL) // CTEMP(1:8)
          ENDIF
          OPEN(IOPMOD,FILE=COUT,STATUS='NEW',FORM='FORMATTED')
          IOCCOL = INDEX(FPENV,' ')-1
          IF (MODELN.LT.10000)THEN
             WRITE(CTEMP,'(I2.2,''_'',I4.4)')NK, MODELN
             COUT = FPENV(1:IOCCOL) // CTEMP(1:7)
          ELSE
             WRITE(CTEMP,'(I2.2,''_'',I5.5)')NK, MODELN
             COUT = FPENV(1:IOCCOL) // CTEMP(1:8)
          ENDIF
          OPEN(IOPENV,FILE=COUT,STATUS='NEW',FORM='FORMATTED')
          IOCCOL = INDEX(FPATM,' ')-1
          IF (MODELN.LT.10000)THEN
             WRITE(CTEMP,'(I2.2,''_'',I4.4)')NK, MODELN
             COUT = FPATM(1:IOCCOL) // CTEMP(1:7)
          ELSE
             WRITE(CTEMP,'(I2.2,''_'',I5.5)')NK, MODELN
             COUT = FPATM(1:IOCCOL) // CTEMP(1:8)
          ENDIF
          OPEN(IOPATM,FILE=COUT,STATUS='NEW',FORM='FORMATTED')
       ELSE
          CLOSE(IOPMOD)
          CLOSE(IOPENV)
          CLOSE(IOPATM)
          LPULSE = .FALSE.
       END IF
       WRITE(IOWR,276)POLEN,TM1,TM2,TM3
       WRITE(ISHORT,276)POLEN,TMP1,TMP2,TMP3
 276   FORMAT(5X,' LEN SQ=',1PE10.3, '  D L=',1PE10.3,
     *        '  D Te=',1PE10.3,'  D AGE=',1PE10.3)

       RETURN
       END
