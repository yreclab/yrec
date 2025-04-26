C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PDIST
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

C calculates the distance the star has travelled in the HR diagram
C if far enough, output pulsation model

      SUBROUTINE PDIST(POL1,POT1,POA1,POLEN,BL,TEFFL,MODELN)
      use settings, only : IOPMOD, IOPENV, IOPATM  ! /LUNUM/
      use settings, only : FPMOD, FPENV, FPATM  ! /LUFNM/
      use settings, only : ISHORT  ! /LUOUT/
      use settings, only : LPULSE  ! /PULSE/
      use settings, only : POA, POB, POC, POMAX  ! /PO/
      use settings, only : NK  ! /ZRAMP/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      CHARACTER*256 COUT,CTEMP
C MHP 10/02 added proper dimensions to last 2 variables
      COMMON/THEAGE/DAGE

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
