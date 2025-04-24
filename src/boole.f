C*************************************************************
C BOOLE: Performs 5-point Newton-Cotes integration of tabulated data
C      X: vector of independent variable values (x)
C      Y: vector dependent variable values ( f(x) )
C      N: number of elements in X
C      NN: number of elements desired in interpolated grid (should be 1+4*A)
C       S: returned, integrated value of the function
C      XI: returned grid in X
C      YI: returned interpolated values of Y
C
C       Data need to be evenly gridded for the integration formula to work.
C      Data that are not already so are interpolated onto an even grid
C      using spline interpolation (numerical recipes SPLINE (renamed splinnr)
C      and SPLINT)
C*************************************************************
C      PARAMETER(NN = 17)
C      PARAMETER(N = 16)
C      DATA Y/6.40,5.041,3.844,2.809,1.936,1.225,0.676,0.289,0.064,0.361,
C     *0.784,1.369,2.116,3.025,4.096,5.329/
C      DATA X/-8.0,-7.1,-6.2,-5.3,-4.4,-3.5,-2.6,-1.7,0.8,1.9,2.8,3.7,
C    *4.6,5.5,6.4,7.3/


      SUBROUTINE BOOLE(X,Y,N,NN,S)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER(SCALEX=1e-11)
      PARAMETER(SCALEY=1e7)
      REAL*8 H(1),D2X(N)
      DIMENSION X(N), Y(N),XI(NN), YI(NN), S(1), XD(N), YD(N)
      INTEGER I, N, NN, P, KLO, KHI


C Rescale radius and cs vectors to have values ~1
      DO 22 I=1,N
            XD(I)=X(I)*SCALEX
            YD(I)=Y(I)*SCALEY
22      CONTINUE
C Deal with unevenly gridded datasets:
C      IF (.NOT.LEVEN) THEN            ! do for all
            CALL SPLINJ(XD,YD,D2X,N) ! get derivs of interp. fn.
            DO 20, I=1,NN
                  XI(I)=XD(1)+(I-1)*(XD(N)-XD(1))/(NN-1)
                  CALL SPLINT(XD,YD,N,D2X,XI(I),YI(I),KLO,KHI)
20            CONTINUE


C How many sets of four points do we have?
      P=(NN-1)/4
      H=(XD(N)-XD(1))/(NN-1)
C For each set of 4 points before the last, apply formula and add up
      S=0.0D0
      DO 21, I=0,P-1
            S=S+2.0*H*(7*YI(1+4*I)+ 32*YI(2+4*I) + 12*YI(3+4*I) +
     *            32*YI(4+4*I) + 7*YI(5+4*I))/45.0
21      CONTINUE
C Rescale result back to actual units:
      S=S/(SCALEX*SCALEY)
C      PRINT*, 'Last point in vector:', NN
C      PRINT*, 'Last point integrated:',5+4*(P-1)

C--------------------------------------------------------------
C                  OPEN(UNIT=100,FILE='diagnostic3.out',STATUS='OLD')
C                  DO 1505 I=1,N
C                              WRITE(100,1504), X(I), Y(I), XD(I), YD(I),
C     *                         XI(I), YI(I), S(1), H(1)
C1505                  CONTINUE
C1504                  FORMAT(1X,8E16.8)
C                  CLOSE(100)
C----------------------------------------------------------------

      END



