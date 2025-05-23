C
C
C  INTERPOLATION PKG FOR COX'S AND FOR KURUCZ'S OPACITIES
C     SUBROUTINE FINDEX(AX,NX,X,M)               FIND INDEX
C     SUBROUTINE INTPOL(XI,F,N,XBAR,YBAR,YBARP)  PIECEWISE INTERPOL R
C     SUBROUTINE YSPLIN(XI,C,N)                  SPLINE R
C
C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C FINDEX
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C YCK 3/91
      SUBROUTINE FINDEX(AX,NX,X,M)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION AX(NX)
      save
      
C FIND THE 'M'
      IF(M.LT.1.OR.M.GT.NX)M=1
      KIP=M
      IF(X.LT.AX(KIP))THEN
         DO 211 IYC=KIP-1,1,-1
            IF(AX(IYC).LE.X)THEN
               KIP=IYC
               GOTO 213
            ENDIF
 211     CONTINUE
         KIP=-1
      ELSE
         DO 212 IYC=KIP,NX-1
            IF(AX(IYC+1).GT.X)THEN
               KIP=IYC
               GOTO 213
            ENDIF
 212     CONTINUE
         KIP = -NX 
      ENDIF
 213  M=KIP

      RETURN
      END
