C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C INTPOL
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C  ***** THE INTERPOLATION ROUTINE *****
C  THIS ROUTINE CONTAINS TWO INTERPOLATION METHODS; HERMITE,
C  AND SPLINE.  EACH OF THESE HAS OWN MERIT AND DEMERIT.
C  IF THE INTERPOLANT IS SMOOTH, BOTH OF THESE WILL GIVE GOOD
C  RESULTS.  GENERALLY, SPLINE GIVES MORE SMOOTH INTERPOLATION.
C  WHEN THE INTERPOLANT CONTAINS ABRUPT VARIATION IN GRADIENT,
C  HOWEVER, SPLINE GET WORSE AT THAT PART, WHILE HERMIT STILL
C  GIVES REASONABLE RESULT.  UNFORTUNATELY, THERE IS NO CRITERION
C  FOR SELECTION BETWEEN THESE TWO METHODS.  THEREFORE, THIS
C  ROUTINE GIVES THE RIGHT FOR SELECTION TO USER.  
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C YCK 3/91
      SUBROUTINE INTPOL(XI,F,N,XBAR,YBAR,YBARP)
C ----------------------------------------------------------
C  XI  ; ARRAY OF ABSCISSA POINTS
C  F   ; ARRAY OF ORDINATE POINTS
C  N   ; SIZE OF THE ARRAYS
C  XBAR; A X-VALUE AT WHICH WE WANT TO FIND Y-VALUE
C  KLO ; THE GRID POINT SMALLER THAN AND CLOSEST TO XBAR
C  YBAR; THE VALUE WE WANT
C  YBARP; THE DERIVATIVE VALUE AT XBAR
C ---------------------------------------------------------
      PARAMETER (NP=100)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 XI(N),F(N),XBAR,C(4,NP),DX,XBARI
      REAL*8 YBAR,YBARP,VALUE
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
      DATA C/400*0.0D0/
      SAVE

C THE COEFFICIENTS FOR THE ZERO-TH ORDER TERM
      DO 1 I=1,N
         C(1,I)=F(I)
 1    CONTINUE
C FIND THE COEFFICIENTS FOR SPLINE INTERPLOATION
      CALL YSPLIN(XI,C,N)
      XBARI=XBAR
C FIND THE GRID POINT,  KLO, SUCH THAT XI(KLO)<=XBARI, AND
C ABS(XI(KLO)-XBARI)<1.
      IF(XI(1).GT.XBAR)THEN
         KLO=1
         KHI=2
         GO TO 522
      ENDIF
      IF(XI(N).LT.XBAR)THEN
         KLO=N-1
         KHI=N
         GO TO 522
      ENDIF
      KLO=1
      KHI=N
    2 IF((KHI-KLO).GT.1)THEN
         K = (KHI+KLO)/2
         IF(XI(K).GT.XBARI)THEN
            KHI=K
         ELSE
            KLO=K
         ENDIF
         GO TO 2
      ENDIF
      IF((KHI-KLO).LE.0)THEN
         WRITE(IOWR, *) 'ERROR COX OP: INTERPOLATION'
         WRITE(ISHORT, *) 'ERROR COX OP: INTERPOLATION'
         STOP
      ENDIF
 522  CONTINUE
C NOW, (KLO,KHI) IS SUB-RANGE OF XI WHICH CONTAINS XBARI.
      DX=XBARI-XI(KLO)
C GO ON TO THE SPLINE INTERPOLATION ROUTINE.
C EVALUATES THE INTERPOLATION VALUE IN THE SUB-RANGE WE DETERMINED.
      VALUE=((C(4,KLO)*DX+C(3,KLO))*DX+C(2,KLO))*DX+C(1,KLO)
      VALP=(3.0D0*C(4,KLO)*DX+2.0D0*C(3,KLO))*DX+C(2,KLO)
C RETURN THE RESULTS FROM THE SPLINE ROUTINE
      YBAR=VALUE
      YBARP=VALP

      RETURN
      END
