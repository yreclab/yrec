C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C BSSTEP
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE BSSTEP(Y,DYDX,NV,X0,HTRY,EPS,YSCAL,HDID,HNEXT,DERIV,
     *                  B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,LSAVE,RL,
     *                  TEFFL,X,Z,KOUNT,KSAHA,ERR)

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER (ONE=1.0D0,SHRINK=0.95D0,GROW=1.2D0)
      COMMON/INTPAR/STOLR0,IMAX,NUSE
      DIMENSION Y(3),DYDX(3),YSCAL(3),YERR(3),YSAV(3),DYSAV(3),
     *          YSEQ(3),NSEQ(11),ERR(3)
      EXTERNAL DERIV
      DATA NSEQ /2,4,6,8,12,16,24,32,48,64,96/
      SAVE
      H = HTRY
      XSAV = X0
      DO 10 I = 1,NV
       YSAV(I) = Y(I)
       DYSAV(I) = DYDX(I)
   10 CONTINUE
   20 DO 40 I = 1,IMAX
       CALL MMID(YSAV,DYSAV,NV,XSAV,H,NSEQ(I),YSEQ,DERIV,B,FPL,FTL,
     *          GL,LATMO,LDERIV,LOCOND,LSAVE,RL,TEFFL,X,Z,KOUNT,KSAHA)
       XEST = (H/NSEQ(I))**2
       CALL RATEXT(I,XEST,YSEQ,Y,YERR,NV,NUSE)
       ERRMAX = 0.0D0
       DO 30 J = 1,NV
          ERRMAX = DMAX1(ERRMAX,DABS(YERR(J)/YSCAL(J)))
          ERR(J) = DABS(YERR(J)/YSCAL(J))
   30    CONTINUE
       ERRMAX = ERRMAX/EPS
       IF(ERRMAX.LT.ONE) THEN
          X0 = X0 + H
          HDID = H
          IF(I.EQ.NUSE) THEN
             HNEXT = H*SHRINK
          ELSE IF (I.EQ.NUSE-1) THEN
             HNEXT = H*GROW
          ELSE
             HNEXT = H*DFLOAT(NSEQ(NUSE-1))/DFLOAT(NSEQ(I))
          ENDIF
          RETURN
       ENDIF
   40 CONTINUE
      H = 0.25D0*H/2.0D0**INT((IMAX-NUSE)/2)
C      H = 0.25D0*H/2**((IMAX-NUSE)/2)
      IF(X+H.EQ.X) THEN
         WRITE(*,*) 'ERROR IN BSSTEP'
       STOP
      END IF
      GOTO 20

      END
