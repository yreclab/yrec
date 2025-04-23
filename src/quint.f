C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C QUINT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE QUINT(X,X0,H,Y0,Y1,Y2,Y)
      IMPLICIT REAL*8 (A-H,O-Z)
C     QUADRATIC INTERPOLATION FOR EQUIDISTANT POINTS
C     Y0=Y(X0),Y1=Y(X1),Y2=Y(X2); H=X1-X0=X2-X1;
C     COMPUTES Y=Y(X)
      save

      D1 = Y1 - Y0
      D2 = Y2 - 2.D0*Y1 + Y0
      T  = (X - X0)/H
      Y  = Y0 + T*D1 + 0.5D0*T*(T-1.D0)*D2
      RETURN
      END
