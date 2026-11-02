C $$$$$$
C       SUBROUTINE TRIDIA(N,EI,EJ,DJ,SUMDJ)  ! KC 2025-05-31
      SUBROUTINE TRIDIA(N,EI,DJ,SUMDJ)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/TRIDI/ into TRIDI_MOD.
      USE TRIDI_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 BET,DJ,EI,FJ,SUMDJ,U0
      INTEGER I,J,N

C       DIMENSION EI(JSON),EJ(JSON),DJ(JSON),U0(JSON)  ! KC 2025-05-31
      DIMENSION EI(JSON),DJ(JSON),U0(JSON)
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
