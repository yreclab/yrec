C
C***********************************************************************
      REAL*8 FUNCTION QUAD(IC,I,X,Y1,Y2,Y3,X1,X2,X3)
      IMPLICIT REAL*8 (A-H,O-Z)
C..... THIS FUNCTION PERFORMS A QUADRATIC INTERPOLATION.
      SAVE
      DIMENSION  XX(3),YY(3),XX12(30),XX13(30),XX23(30),XX1SQ(30)
     . ,XX1PXX2(30)
      XX(1)=X1
      XX(2)=X2
      XX(3)=X3
      YY(1)=Y1
      YY(2)=Y2
      YY(3)=Y3
        IF(IC .EQ. 0) THEN
          XX12(I)=1.D0/(XX(1)-XX(2))
          XX13(I)=1.D0/(XX(1)-XX(3))
          XX23(I)=1.D0/(XX(2)-XX(3))
          XX1SQ(I)=XX(1)*XX(1)
          XX1PXX2(I)=XX(1)+XX(2)
        ENDIF
      C3=(YY(1)-YY(2))*XX12(I)
      C3=C3-(YY(2)-YY(3))*XX23(I)
      C3=C3*XX13(I)
      C2=(YY(1)-YY(2))*XX12(I) - XX1PXX2(I)*C3
      C1=YY(1)-XX(1)*C2-XX1SQ(I)*C3
      QUAD=C1+X*(C2+X*C3)
      RETURN
      END
