C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     SPLINE PURE Z LAOL89
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE ZSULAOL
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ZSLAOL/ into ZSLAOL_MOD.
      USE ZSLAOL_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ZLAOL/ into ZLAOL_MOD.
      USE ZLAOL_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 TDOR,TOP,TR
      INTEGER IR,IT,NUMS
C DBG 4/94 Modified to do ZRAMP stuff.
      DIMENSION TOP(104),TR(104),TDOR(104)
C DBG 12/95 ARRAYS FOR PURE Z TABLE
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
