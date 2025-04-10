
C  SUBROUTINE FOR GENERATING SURFACE X TABLES FOR ALEXANDER OPACITIES
      SUBROUTINE ALX8TH(X)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER (NUMX=7)
      PARAMETER (NUMZ=15)
      PARAMETER (NUMT=23)
      PARAMETER (NUMD=17)
      PARAMETER (NUMXT=8)
C     ALEX LOW T OPACITY
      COMMON /GALOT/TGR(NUMT),XXG(NUMX),R0GR(NUMD),ZZG(NUMZ)
      COMMON /ALOT/CAPALEX(NUMXT,NUMT,NUMD),XE,ZE,IX,IT,ID
      DIMENSION QR(4),FX(4)
      SAVE
      XE = X
C FIND 4 NEAREST TABLES IN X.
      IF(X.LT.XXG(4))THEN
         IF(X.GT.XXG(3))THEN
            IX = 2
         ELSE
            IX = 1
         ENDIF
      ELSE
         IF(X.GT.XXG(5))THEN
            IX = 4
         ELSE
            IX = 3
         ENDIF
      ENDIF
      DO I = 1,4
         QR(I) = XXG(IX+I-1)
      END DO
      CALL INTRP2(QR,FX,X)
      DO I = 1,NUMT
         DO J = 1,NUMD
            CAPALEX(8,I,J) = FX(1)*CAPALEX(IX,I,J)+
     *      FX(2)*CAPALEX(IX+1,I,J) + FX(3)*CAPALEX(IX+2,I,J) +
     *      FX(4)*CAPALEX(IX+3,I,J)
         END DO
      END DO
      RETURN
      END
