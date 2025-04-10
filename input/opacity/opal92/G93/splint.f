      SUBROUTINE SPLINT(X,Y,KMAX,JMAX,IMAX,Y2,ZNEW,KAPPA)
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 KAPPA(3,50,17)
      DIMENSION X(39),Y(39,50,17),Y2(39,50,17)
C FIND NEAREST TABLE ENTRY IN Z.
      DO K = 1,37,3
         IF(X(K).GE.ZNEW) GOTO 50
      END DO
      K = 37
   50 CONTINUE
      KHI = K
      KLO = K-3
      KHI0 = KHI
      KLO0 = KLO
      H = X(KHI)-X(KLO)
      A = (X(KHI)-ZNEW)/H
      B = (ZNEW-X(KLO))/H
      DO K = 1,3
         KLO = KLO0+K-1
         KHI = KHI0+K-1
         DO J = 1,JMAX
            DO I = 1,IMAX
               KAPPA(K,J,I) = A*Y(KLO,J,I)+B*Y(KHI,J,I)+
     *         ((A**3-A)*Y2(KLO,J,I)+(B**3-B)*Y2(KHI,J,I))*(H**2)/6
            END DO
         END DO
      END DO
      RETURN
      END
