C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     SPLINE LAOL89
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE SULAOL
      use tables, only : OLAOL, OT, ORHO, NUMOFXYZ, NUMRHO, NUMT  ! /NWLAOL/
      use settings, only : ZLAOL1, ZLAOL2, ZOPAL1, ZOPAL2, ZOPAL951, ZALEX1, ZKUR1, ZKUR2, L2Z  ! /NEWOPAC/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION TOP(104),TR(104),TDOR(104)
      COMMON/NWLAOL2/OLAOL2(12,104,52), OXA2(12), OT2(52),
     *                ORHO2(104), NXYZ2,NRHO2,NT2
      COMMON/SLAOL/SLAOLL(12,104,52),SRHOL(12,104,52),
     *  SDORL(12,104,52), NUMRS(12,52)
      COMMON/SLAOL2/SLAOLL2(12,104,52),SRHOL2(12,104,52),
     *  SDORL2(12,104,52), NUMRS2(12,52)
      SAVE
      DO IT=1, NUMT
         OT(IT) = LOG10(OT(IT))
      END DO
      DO IX=1, NUMOFXYZ
         DO IT=1, NUMT
            NUMS=0
            DO IR=1, NUMRHO
                SLAOLL(IX,IR,IT) = 0.0D0
                SRHOL(IX,IR,IT) = 0.0D0
                SDORL(IX,IR,IT) = 0.0D0
                IF(OLAOL(IX,IR,IT) .NE. 0.0D0) THEN
                   NUMS = NUMS+1
                   TOP(NUMS) = LOG10(OLAOL(IX,IR,IT))
                   TR(NUMS) = LOG10(ORHO(IR))
                END IF
            END DO
            IF (NUMS .GE. 4) THEN
               NUMRS(IX,IT)=NUMS
               CALL CSPLINE(TR,TOP,NUMS,1.0D30,1.0D30,TDOR)
               DO IR=1,NUMS
                   SLAOLL(IX,IR,IT) = TOP(IR)
                   SRHOL(IX,IR,IT) = TR(IR)
                   SDORL(IX,IR,IT) = TDOR(IR)
               END DO
            ELSE
               NUMRS(IX,IT) = 0
            END IF
         END DO
      END DO
C DBG 4/94 Do SPLINE on second opacity table if ZRAMP
      IF (L2Z) THEN
       DO IT=1, NUMT
          OT2(IT) = LOG10(OT2(IT))
       END DO
         DO IX=1, NXYZ2
            DO IT=1, NT2
               NUMS=0
               DO IR=1, NRHO2
                  SLAOLL2(IX,IR,IT) = 0.0D0
                  SRHOL2(IX,IR,IT) = 0.0D0
                  SDORL2(IX,IR,IT) = 0.0D0
                  IF(OLAOL2(IX,IR,IT) .NE. 0.0D0) THEN
                     NUMS = NUMS+1
                     TOP(NUMS) = LOG10(OLAOL2(IX,IR,IT))
                     TR(NUMS) = LOG10(ORHO2(IR))
                  END IF
               END DO
               IF (NUMS .GE. 4) THEN
                  NUMRS2(IX,IT)=NUMS
                  CALL CSPLINE(TR,TOP,NUMS,1.0D30,1.0D30,TDOR)
                  DO IR=1,NUMS
                     SLAOLL2(IX,IR,IT) = TOP(IR)
                     SRHOL2(IX,IR,IT) = TR(IR)
                     SDORL2(IX,IR,IT) = TDOR(IR)
                  END DO
               ELSE
                  NUMRS2(IX,IT) = 0
               END IF
            END DO
         END DO
      END IF
      RETURN
      END
