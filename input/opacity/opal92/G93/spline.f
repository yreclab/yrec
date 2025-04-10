      SUBROUTINE SPLINE(X,Y,KMAX,JMAX,IMAX,Y2)
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION X(39),Y(39,50,17),Y2(39,50,17),U(39,50,17)
C FIND SECOND DERVIATIVES OF CAPPA WITH RESPECT TO Z.
C NOTE ON STORAGE : THREE TABLES WITH DIFFERENT X ARE STORED FOR
C EACH Z, WHICH EXPLAINS THE DIFFERENCES BETWEEN THIS SR AND THE
C ONE FROM NUMERICAL RECIPES, P.88, ON WHICH IT IS BASED.
C NATURAL SPLINE LOWER BOUNDARY CONDITION
      DO K = 1,3
         DO J = 1,JMAX
            DO I = 1,IMAX
               Y2(K,J,I) = 0.0D0
               U(K,J,I) = 0.0D0
            END DO
         END DO
      END DO
C DECOMPOSITION LOOP.
      DO K = 4,KMAX-3
         DXP = X(K+3)-X(K)
         DXM = X(K)-X(K-3)
         SIG = DXM/DXP
C        SIG = (X(K)-X(K-3))/(X(K+3)-X(K))
         DO J = 1,JMAX
            DO I = 1,IMAX
               P = SIG*Y2(K-3,J,I)+2.0D0
               Y2(K,J,I) = (SIG-1.0D0)/P
               U(K,J,I) = (6.0D0*((Y(K+3,J,I)-Y(K,J,I))/DXP
     *                    -(Y(K,J,I)-Y(K-3,J,I))/DXM)/(DXM+DXP)
     *                    -SIG*U(K-3,J,I))/P
            END DO
         END DO
      END DO
C NATURAL SPLINE UPPER BOUNDARY CONDITION
      DO K = 37,39
         DO J = 1,JMAX
            DO I = 1,IMAX
               Y2(K,J,I) = 0.0D0
            END DO
         END DO
      END DO
C BACKSUBSTITUTION
      DO K = KMAX-3,1,-1
         DO J = 1,JMAX
            DO I = 1,IMAX
               Y2(K,J,I) = Y2(K,J,I)*Y2(K+3,J,I)+U(K,J,I)
            END DO
         END DO
      END DO
      RETURN
      END
