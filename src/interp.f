C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C INTERP
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE INTERP(A,B,C,X)

      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(4),B(4),C(4)
      SAVE

C INTERP IS THE INTERPOLATION ROUTINE FOR THE VANDENBERG
C OPACITY TABLES(CAPPA), AND IT USES A 4-POINT LAGRANGIAN
C INTERPOLATION SCHEME.
      A43 = A(4) - A(3)
      A42 = A(4) - A(2)
      A41 = A(4) - A(1)
      A32 = A(3) - A(2)
      A31 = A(3) - A(1)
      A21 = A(2) - A(1)
      D1 = -A21*A31*A41
      D2 = A21*A32*A42
      D3 = -A31*A32*A43
      D4 = A41*A42*A43
      XA1 = X - A(1)
      XA2 = X - A(2)
      XA3 = X - A(3)
      XA4 = X - A(4)
      B(1) = (XA2*XA3*XA4)/D1
      B(2) = (XA1*XA3*XA4)/D2
      B(3) = (XA1*XA2*XA4)/D3
      B(4) = (XA1*XA2*XA3)/D4
      C(1) = (XA3*XA4 + XA2*XA4 + XA2*XA3)/D1
      C(2) = (XA3*XA4 + XA1*XA4 + XA1*XA3)/D2
      C(3) = (XA2*XA4 + XA1*XA4 + XA1*XA2)/D3
      C(4) = (XA2*XA3 + XA1*XA3 + XA1*XA2)/D4

      RETURN
      END
