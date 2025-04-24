C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     SPLINE PURE Z LAOL89
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE ZSULAOL
C DBG 4/94 Modified to do ZRAMP stuff.
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION TOP(104),TR(104),TDOR(104)
C DBG 12/95 ARRAYS FOR PURE Z TABLE
      COMMON/ZLAOL/ZOLAOL(104,52), ZOT(52), ZORHO(104),
     *  NUMRHOZ, NUMTZ
      COMMON/ZSLAOL/ZSLAOLL(104,52),ZSRHOL(104,52),
     *  ZSDORL(104,52), NUMRSZ(52)
      SAVE
      DO IT=1, NUMTZ
         ZOT(IT) = LOG10(ZOT(IT))
      END DO
        DO IT=1, NUMTZ
            NUMS=0
            DO IR=1, NUMRHOZ
                  ZSLAOLL(IR,IT) = 0.0D0
                  ZSRHOL(IR,IT) = 0.0D0
                  ZSDORL(IR,IT) = 0.0D0
                  IF(ZOLAOL(IR,IT) .NE. 0.0D0) THEN
                     NUMS = NUMS+1
                     TOP(NUMS) = LOG10(ZOLAOL(IR,IT))
                     TR(NUMS) = LOG10(ZORHO(IR))
                  END IF
            END DO
            IF (NUMS .GE. 4) THEN
               NUMRSZ(IT)=NUMS
               CALL CSPLINE(TR,TOP,NUMS,1.0D30,1.0D30,TDOR)
               DO IR=1,NUMS
                     ZSLAOLL(IR,IT) = TOP(IR)
                     ZSRHOL(IR,IT) = TR(IR)
                     ZSDORL(IR,IT) = TDOR(IR)
               END DO
            ELSE
               NUMRSZ(IT) = 0
            END IF
        END DO
      RETURN
      END
