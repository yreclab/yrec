C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C POLINT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE POLINT(XA,YA,N,X,Y,DY)
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 C,D,DEN,DIF,DIFT,DY,HO,HP,W,X,XA,Y,YA
      INTEGER I,J,N,NS
C MHP 10/02 dimensions changed for consistency with fpft
      DIMENSION XA(20),YA(20),C(20),D(20)
      SAVE

      NS = 1
      DIF = DABS(X-XA(1))
      DO 10 I = 1,N
       DIFT = DABS(X-XA(I))
       IF(DIFT.LT.DIF) THEN
          NS = I
          DIF = DIFT
       ENDIF
       C(I) = YA(I)
       D(I) = YA(I)
   10 CONTINUE
      Y = YA(NS)
      NS = NS - 1
      DO 30 J = 1,N-1
       DO 20 I = 1,N-J
          HO = XA(I)-X
          HP = XA(I+J)-X
          W = C(I+1) - D(I)
          DEN = HO - HP
          IF(dabs(DEN).LT.1.0D-20)STOP
          DEN = W/DEN
          D(I) = HP*DEN
          C(I) = HO*DEN
   20    CONTINUE
       IF(2*NS.LT.N-J) THEN
          DY = C(NS+1)
       ELSE
          DY = D(NS)
          NS = NS-1
       ENDIF
       Y = Y + DY
   30 CONTINUE
      RETURN
      END
