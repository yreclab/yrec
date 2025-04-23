C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ZERO
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE  ZERO(A,NN)
      IMPLICIT REAL*8 (A-H,O-Z)
C     SETS A(N)=0., N=1,NN
      DIMENSION A(NN)
      save

      DO 1 N=1,NN
    1 A(N)=0.D0
      RETURN
      END
