C $$$$$$
      SUBROUTINE TRIDIAG_GS(A,B,C,EX_PRIME,NPT,EX)
      use mmodel, only : json
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION A(JSON),B(JSON),C(JSON),EX_PRIME(JSON),EX(JSON),
     * GAMA(JSON)
      SAVE

      BET = B(1)
      EX(1) = EX_PRIME(1)/BET
      DO 1 J=2,NPT
         GAMA(J) = C(J-1)/BET
         BET = B(J) - A(J)*GAMA(J)
         IF( BET.EQ.0 ) STOP '#TRIDIA:SINGULAR MATRIX'
         EX(J) = (EX_PRIME(J) - A(J)*EX(J-1))/BET
    1 CONTINUE
      DO 2 J=NPT-1,1,-1
         EX(J) = EX(J) - GAMA(J+1)*EX(J+1)
    2 CONTINUE
 911  FORMAT(1P6E10.2)

      RETURN
      END
