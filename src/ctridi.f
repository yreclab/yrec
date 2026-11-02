C $$$$$$
      SUBROUTINE CTRIDI(N)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/TRIDI/ into TRIDI_MOD.
      USE TRIDI_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 BET
      INTEGER J,N

      SAVE

C  SOLVES A TRIDIAGONAL MATRIX SYSTEM FOR THE FRACTIONAL ABUNDANCE
C  OF A SPECIES. NEW ABUNDANCE IS STORED IN ARRAY U.
C  THIS ROUTINE IS FROM NUMERICAL RECIPES, P.40.

      BET = B(1)
      U(1) = D(1)/BET
      DO 1 J=2,N
         GAMA(J) = C(J-1)/BET
         BET = B(J) - A(J)*GAMA(J)
         IF( BET.EQ.0 ) STOP '#TRIDIA:SINGULAR MATRIX'
         U(J) = (D(J) - A(J)*U(J-1))/BET
    1 CONTINUE
      DO 2 J=N-1,1,-1
         U(J) = U(J) - GAMA(J+1)*U(J+1)
    2 CONTINUE

      RETURN
      END
