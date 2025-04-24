C$$$$$$
      SUBROUTINE SPLINJ(X,Y,Y2,N)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C     PARAMETER (JSON=5000)
      REAL*8 X(N),Y(N),Y2(N),U(N)
C     SAVE
C NATURAL SPLINE
      Y2(1) = 0.0D0
      U(1) = 0.0D0
      DO I = 2,N-1
         SIG = (X(I)-X(I-1))/(X(I+1)-X(I-1))
         P = SIG*Y2(I-1)+2.0D0
         Y2(I) = (SIG-1.0D0)/P
         U(I) = (6.0D0*((Y(I+1)-Y(I))/(X(I+1)-X(I))-(Y(I)-Y(I-1))
     *          /(X(I)-X(I-1)))/(X(I+1)-X(I-1))-SIG*U(I-1))/P
      END DO
      QN = 0.0D0
      UN = 0.0D0
      Y2(N) = (UN-QN*U(N-1))/(QN*Y2(N-1)+1.0D0)
      DO K = N-1,1,-1
         Y2(K) = Y2(K)*Y2(K+1)+U(K)
      END DO
      RETURN
      END
