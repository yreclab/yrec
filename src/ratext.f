C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C RATEXT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE RATEXT(IEST,XEST,YEST,YZ,DY,NV,NUSE)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER (IMAX=11,NMAX=15,NCOL=7)
      DIMENSION X(IMAX),YEST(NV),YZ(NV),DY(NV),D(NMAX,NCOL),FX(NCOL)
      SAVE
C  SAME AS SR RZEXTR FROM NUMERICAL RECIPES, P.566.
C
C  SAVE CURRENT INDEPENDENT VARIABLE.
      X(IEST) = XEST
      IF(IEST.EQ.1)THEN
         DO 11 J = 1,NV
            YZ(J) = YEST(J)
            D(J,1) = YEST(J)
            DY(J) = YEST(J)
   11    CONTINUE
      ELSE
C  USE AT MOST NUSE PREVIOUS MEMBERS.
         M1 = MIN(IEST,NUSE)
         DO 12 K = 1,M1-1
            FX(K+1) = X(IEST-K)/XEST
   12    CONTINUE
C  EVALUATE NEXT DIAGONAL IN TABLEAU.
         DO 14 J=1,NV
            YY = YEST(J)
            V = D(J,1)
            C = YY
            D(J,1) = YY
            DO 13 K = 2,M1
               B1 = FX(K)*V
               B = B1 - C
C  CARE NEEDED TO AVOID DIVISION BY ZERO.
               IF(B.NE.0D0)THEN
                  B = (C - V)/B
                  DDY = C*B
                  C = B1*B
               ELSE
                  DDY = V
               ENDIF
               V = D(J,K)
               D(J,K) = DDY
               YY = YY + DDY
   13       CONTINUE
            DY(J) = DDY
            YZ(J) = YY
   14    CONTINUE
      ENDIF
      RETURN
      END
