C $$$$$$
      SUBROUTINE TRIDIA(N,EI,EJ,DJ,SUMDJ)

      use params, only : json
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON/TRIDI/A(JSON),B(JSON),C(JSON),D(JSON),U(JSON),GAMA(JSON)
      DIMENSION EI(JSON),EJ(JSON),DJ(JSON),U0(JSON)
      SAVE

      DJ(N) = GAMA(N)
      DO I = 1,N
         U0(I) = D(I)
      END DO
      BET = B(1)
      U(1) = D(1)/BET
      DO 1 J=2,N
         GAMA(J) = C(J-1)/BET
         BET = B(J) - A(J)*GAMA(J)
         IF( BET.EQ.0 ) STOP '#TRIDIA:SINGULAR MATRIX'
         U(J) = (D(J) - A(J)*U(J-1))/BET
    1 CONTINUE
      DJ(N) = DJ(N)+(U(N)-U0(N))*EI(N)
      SUMDJ = DJ(N)
      FJ = 1.0D0+(U(N)-U0(N))/U0(N)
      U(N) = U0(N)*FJ
      DO 2 J=N-1,1,-1
         U(J) = U(J) - GAMA(J+1)*U(J+1)
         DJ(J) = (U(J)-U0(J))*EI(J)
         SUMDJ = SUMDJ + DJ(J)
    2 CONTINUE

      RETURN
      END
