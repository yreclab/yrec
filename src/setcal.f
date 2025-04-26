C $$$$$$
      SUBROUTINE SETCAL(FACAGE)
      use settings, only : RESCAL, NMODLS, IRESCA, LFIRST  ! /CKIND/
      use settings, only : ENDAGE, SETDT, LENDAG, LSETDT  ! /SETT/
      use settings, only : XENV0A, ZENV0A, CMIXLA, LSENV0A, SENV0A  ! /NEWXYM/
      use settings, only : CALSOLAGE  ! /CALS2/
      use settings, only : RSCLZC, RSCLZM1, RSCLZM2  ! /ZRAMP/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/CALSUN/DLDX,DRDX,DLDA,DRDA,BLP,RLP,DX,DA,LSOL
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
