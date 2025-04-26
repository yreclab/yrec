
C MHP 4/98 SUBROUTINE FOR CALCULATING ALEXANDER LOW T OPACITIES
      SUBROUTINE YALO3D(DL,TL,X,Z,O,OL,QOD,QOT)
      use settings, only : CLN  ! /CONST1/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER (NUMX=7)
      PARAMETER (NUMZ=15)
      PARAMETER (NUMT=23)
      PARAMETER (NUMD=17)
      PARAMETER (NUMXT=8)
      COMMON /GALOT/TGR(NUMT),XXG(NUMX),R0GR(NUMD),ZZG(NUMZ)
      COMMON /ALOT/CAPALEX(NUMXT,NUMT,NUMD),XE,ZE,IX,IT,ID
      DIMENSION QR(4),FXT(4),FXTD(4),FXR(4),FXRD(4),FXX(4),OP(4),
     *          QOPR(4),OX(4),QOTX(4),QODX(4)
      SAVE
      DIFZ = ABS(Z-ZE)
C  ENSURE THAT OPACITY TABLE HAS THE SAME Z VALUE AS THE ENVELOPE.
      IF(DIFZ.GT.1.0D-8)THEN
         CALL ALXZTAB(Z)
         CALL ALX8TH(X)
      ENDIF
C  COMPUTE R FOR GRID POINT
      R = DL - 3.0D0*(TL-6.0D0)
C  FIND NEAREST GRID POINTS IN T.
C Insure that index IT is within the required array bounds  llp  8/19/08
      IF(IT .lt. 1) it=1
      IF((IT+2) .gt. NUMT) IT=NUMT-2
      IF(TL.LT.TGR(IT+2))THEN
         DO I = IT+1,2,-1
            IF(TL.GT.TGR(I))THEN
               IT = I - 1
               GOTO 10
            ENDIF
         END DO
         IT = 1
 10      CONTINUE
      ELSE
         DO I = IT+3,NUMT
            IF(TL.LT.TGR(I))THEN
               IT = I - 2
               IT = MIN(NUMT-3,IT)
               GOTO 20
            ENDIF
         END DO
         IT = NUMT - 3
 20      CONTINUE
      ENDIF
C INTERPOLATION FACTORS IN LOG T
      DO I = 1,4
         QR(I) = TGR(IT+I-1)
      END DO
      CALL INTERP(QR,FXT,FXTD,TL)
C  FIND NEAREST GRID POINTS IN R = RHO/T6**3
      IF(R.LT.R0GR(ID+2))THEN
         DO I = ID+1,2,-1
            IF(R.GT.R0GR(I))THEN
               ID = I - 1
               GOTO 30
            ENDIF
         END DO
         ID = 1
 30      CONTINUE
      ELSE
         DO I = ID+3,NUMD
            IF(R.LT.R0GR(I))THEN
               ID = I - 2
               ID = MIN(NUMD-3,ID)
               GOTO 40
            ENDIF
         END DO
         ID = NUMD - 3
 40      CONTINUE
      ENDIF
C  INTERPOLATION FACTORS IN LOG R
      IF(R.GT.R0GR(NUMD).AND. ABS(X-XE).LT.1.0D-8)THEN
         LINEAR = .TRUE.
         RR = R
         R = R0GR(NUMD)
      ELSE
         LINEAR = .FALSE.
      ENDIF
      DO I = 1,4
         QR(I) = R0GR(ID+I-1)
      END DO
      CALL INTERP(QR,FXR,FXRD,R)
C NOW EITHER INTERPOLATE IN SURFACE X TABLE OR CALCULATE OPACITY AT
C 4 DIFFERENT VALUES OF X AND INTERPOLATE IN X.
      IF(ABS(X-XE).LT.1.0D-8)THEN
C SURFACE ABUNDANCE TABLE
C INTERPOLATE IN LOG R AT FIXED T
         DO I = 1,4
            II = IT+I - 1
            OP(I) = FXR(1)*CAPALEX(8,II,ID) +
     *              FXR(2)*CAPALEX(8,II,ID+1) +
     *              FXR(3)*CAPALEX(8,II,ID+2) +
     *              FXR(4)*CAPALEX(8,II,ID+3)
            QOPR(I) = FXRD(1)*CAPALEX(8,II,ID) +
     *              FXRD(2)*CAPALEX(8,II,ID+1) +
     *              FXRD(3)*CAPALEX(8,II,ID+2) +
     *              FXRD(4)*CAPALEX(8,II,ID+3)
         END DO
         IF(LINEAR)THEN
            DO I = 1,4
               II = IT+I-1
               OP(I) = OP(I)+(RR-R)*(CAPALEX(8,II,NUMD)-
     *         CAPALEX(8,II,NUMD-1))/(R0GR(NUMD)-R0GR(NUMD-1))
            END DO
            R = RR
         ENDIF
C  INTERPOLATE IN T
         OL = FXT(1)*OP(1)+FXT(2)*OP(2)+FXT(3)*OP(3)+FXT(4)*OP(4)
C D LN CAPPA/D LN T AT FIXED R
         QOT = FXTD(1)*OP(1)+FXTD(2)*OP(2)+FXTD(3)*OP(3)+FXTD(4)*OP(4)
C INTERPOLATE IN D LN CAPPA/ D LN R AT FIXED T
         QOD = FXT(1)*QOPR(1) + FXT(2)*QOPR(2) + FXT(3)*QOPR(3) +
     *         FXT(4)*QOPR(4)
C CORRECT FROM DERIVATIVE AT FIXED R TO DERIVATIVE AT FIXED RHO
         QOT = QOT - 3.0D0*QOD
         O = EXP(CLN*OL)
      ELSE
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
         CALL INTRP2(QR,FXX,X)
C INTERPOLATE IN LOG R AT FIXED T
         DO J = 1,4
            JJ = IX+J-1
            DO I = 1,4
               II = IT+I - 1
               OP(I) = FXR(1)*CAPALEX(JJ,II,ID) +
     *                 FXR(2)*CAPALEX(JJ,II,ID+1) +
     *                 FXR(3)*CAPALEX(JJ,II,ID+2) +
     *                 FXR(4)*CAPALEX(JJ,II,ID+3)
               QOPR(I) = FXRD(1)*CAPALEX(JJ,II,ID) +
     *                 FXRD(2)*CAPALEX(JJ,II,ID+1) +
     *                 FXRD(3)*CAPALEX(JJ,II,ID+2) +
     *                 FXRD(4)*CAPALEX(JJ,II,ID+3)
            END DO
C  INTERPOLATE IN T
            OX(J) = FXT(1)*OP(1)+FXT(2)*OP(2)+FXT(3)*OP(3)+FXT(4)*OP(4)
C D LN CAPPA/D LN T AT FIXED R
            QOTX(J) = FXTD(1)*OP(1) + FXTD(2)*OP(2) +
     *                FXTD(3)*OP(3) + FXTD(4)*OP(4)
C INTERPOLATE IN D LN CAPPA/ D LN R AT FIXED T
            QODX(J) = FXT(1)*QOPR(1) + FXT(2)*QOPR(2) +
     *                FXT(3)*QOPR(3) + FXT(4)*QOPR(4)
         END DO
C INTERPOLATE IN X
         OL = FXX(1)*OX(1) + FXX(2)*OX(2) + FXX(3)*OX(3) +
     *        FXX(4)*OX(4)
         QOT = FXX(1)*QOTX(1) + FXX(2)*QOTX(2) + FXX(3)*QOTX(3) +
     *        FXX(4)*QOTX(4)
         QOD = FXX(1)*QODX(1) + FXX(2)*QODX(2) + FXX(3)*QODX(3) +
     *        FXX(4)*QODX(4)
C CORRECT FROM DERIVATIVE AT FIXED R TO DERIVATIVE AT FIXED RHO
         QOT = QOT - 3.0D0*QOD
         O = EXP(CLN*OL)
      ENDIF
      RETURN
      END
