C MHP 3/09 SUBROUTINE FOR CALCULATING ALEXANDER LOW T OPACITIES
      SUBROUTINE GETALEX06(DL,TL,X,Z,O,OL,QOD,QOT)
      use params, only : numx => numx06, numz => numz06, numxz => numxz06, numt => numt06, numd => numd06
      use settings, only : CLN  ! /CONST1/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON /GALOT06/TGR06(NUMT),XXG06(NUMX),R0GR06(NUMD),ZZG06(NUMZ)
      COMMON /ALOT06/CAPALEX06(NUMT,NUMD),XE,ZE,IX,IT,ID
      REAL*8  QR(4),FXT(4),FXTD(4),FXR(4),FXRD(4),OP(4),QOPR(4)
      SAVE
      DIFZ = ABS(Z-ZE)
      DIFX = ABS(X-XE)
C  ENSURE THAT OPACITY TABLE HAS THE SAME X,Z VALUE AS THE POINT
      IF(DIFZ.GT.1.0D-8 .OR. DIFX.GT.1.0D-8)THEN
         ZE = Z
         XE = X
         CALL ALEX06TAB
      ENDIF
C  COMPUTE R FOR GRID POINT
      R = DL - 3.0D0*(TL-6.0D0)
C Insure that index IT is within the required array bounds
      IF(IT .LT. 1) IT=1
      IF((IT+2) .GT. NUMT) IT=NUMT-2
C  FIND NEAREST GRID POINTS IN T.
      IF(TL.LT.TGR06(IT+2))THEN
         DO I = IT+1,2,-1
            IF(TL.GT.TGR06(I))THEN
               IT = I - 1
               GOTO 10
            ENDIF
         END DO
         IT = 1
 10      CONTINUE
      ELSE
         DO I = IT+3,NUMT
            IF(TL.LT.TGR06(I))THEN
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
         QR(I) = TGR06(IT+I-1)
      END DO
      CALL INTERP(QR,FXT,FXTD,TL)
C Insure that index ID is within the required array bounds
      IF(ID .LT. 1) ID=1
      IF((ID+2) .GT. NUMD) ID=NUMD-2
C  FIND NEAREST GRID POINTS IN R = RHO/T6**3
      IF(R.LT.R0GR06(ID+2))THEN
         DO I = ID+1,2,-1
            IF(R.GT.R0GR06(I))THEN
               ID = I - 1
               GOTO 30
            ENDIF
         END DO
         ID = 1
 30      CONTINUE
      ELSE
         DO I = ID+3,NUMD
            IF(R.LT.R0GR06(I))THEN
               ID = I - 2
               ID = MIN(NUMD-3,ID)
               GOTO 40
            ENDIF
         END DO
         ID = NUMD - 3
 40      CONTINUE
      ENDIF
C  INTERPOLATION FACTORS IN LOG R
      IF(R.GT.R0GR06(NUMD))THEN
         LINEAR = .TRUE.
         RR = R
         R = R0GR06(NUMD)
      ELSE
         LINEAR = .FALSE.
      ENDIF
      DO I = 1,4
         QR(I) = R0GR06(ID+I-1)
      END DO
      CALL INTERP(QR,FXR,FXRD,R)
C INTERPOLATE IN LOG R AT FIXED T
      DO I = 1,4
         II = IT + I - 1
         OP(I) = FXR(1)*CAPALEX06(II,ID) +
     *           FXR(2)*CAPALEX06(II,ID+1) +
     *           FXR(3)*CAPALEX06(II,ID+2) +
     *           FXR(4)*CAPALEX06(II,ID+3)
         QOPR(I) = FXRD(1)*CAPALEX06(II,ID) +
     *           FXRD(2)*CAPALEX06(II,ID+1) +
     *           FXRD(3)*CAPALEX06(II,ID+2) +
     *           FXRD(4)*CAPALEX06(II,ID+3)
      END DO
      IF(LINEAR)THEN
         DO I = 1,4
            II = IT+I-1
            OP(I) = OP(I)+(RR-R)*(CAPALEX06(II,NUMD)-
     *      CAPALEX06(II,NUMD-1))/(R0GR06(NUMD)-R0GR06(NUMD-1))
         END DO
         R = RR
      ENDIF
C  INTERPOLATE IN T
      OL = FXT(1)*OP(1)+FXT(2)*OP(2)+FXT(3)*OP(3)+FXT(4)*OP(4)
C D LN CAPPA/D LN T AT FIXED R
      QOT = FXTD(1)*OP(1)+FXTD(2)*OP(2)+FXTD(3)*OP(3)+FXTD(4)*OP(4)
C INTERPOLATE IN D LN CAPPA/ D LN R AT FIXED T
      QOD = FXT(1)*QOPR(1) + FXT(2)*QOPR(2) + FXT(3)*QOPR(3) +
     *      FXT(4)*QOPR(4)
C CORRECT FROM DERIVATIVE AT FIXED R TO DERIVATIVE AT FIXED RHO
      QOT = QOT - 3.0D0*QOD
      O = EXP(CLN*OL)
      RETURN
      END
