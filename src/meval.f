
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MEVAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MEVAL(XVAL,YVAL,XTAB,YTAB,MTAB,NUM,NUME,EPS,ERR)
C
C                                 SHAPE PRESERVING QUADRATIC SPLINES
C                                   BY D.F.MCALLISTER & J.A.ROULIER
C                                     CODED BY S.L.DOOD & M.ROULIER
C                                       N.C. STATE UNIVERSITY
C
      PARAMETER (JSON=5000)
      REAL*8 XVAL(JSON),YVAL(JSON),XTAB(JSON),YTAB(JSON),
     *     MTAB(JSON),V1,V2,W1,W2,Z1,Z2,Y1,Y2,E1,E2,SPLINE,EPS
      INTEGER START,START1,END,END1,ERR,FND
C
C MEVAL CONTROLS THE EVALUATION OF AN OSCULATORY QUADRATIC SPLINE. THE
C USER MAY PROVIDE HIS OWN SLOPES AT THE POINTS OF INTERPOLATION OR USE
C THE SUBROUTINE 'SLOPES' TO CALCULATE SLOPES WHICH ARE CONSISTENT WITH
C THE SHAPE OF THE DATA.
C
C
C
C ON INPUT--
C
C   XVAL MUST BE A NONDECREASING VECTOR OF POINTS AT WHICH THE SPLINE
C   WILL BE EVALUATED.
C
C   XTAB CONTAINS THE ABSCISSAS OF THE DATA POINTS TO BE INTERPOLATED.
C   XTAB MUST BE INCREASING.
C
C   YTAB CONTAINS THE ORDINATES OF THE DATA POINTS TO BE INTERPOLATED.
C
C   MTAB CONTAINS THE SLOPE OF THE SPLINE AT EACH POINT OF INTERPOLA-
C   TION.
C
C   NUM IS THE NUMBER OF DATA POINTS (DIMENSION OF XTAB AND YTAB).
C
C   NUME IS THE NUMBER OF POINTS OF EVALUATION (DIMENSION OF XVAL AND
C   YVAL).
C
C   EPS IS A RELATIVE ERROR TOLERANCE USED IN SUBROUTINE 'CHOOSE'
C   TO DISTINGUISH THE SITUATION MTAB(I) OR MTAB(I+1) IS RELATIVELY
C   CLOSE TO THE SLOPE OR TWICE THE SLOPE OF THE LINEAR SEGMENT
C   BETWEEN XTAB(I) AND XTAB(I+1). IF THIS SITUATION OCCURS,
C   ROUNDOFF MAY CAUSE A CHANGE IN CONVEXITY OR MONOTONICITY OF THE
C   RESULTING SPLINE AND A CHANGE IN THE CASE NUMBER PROVIDED BY
C   CHOOSE. IF EPS IS NOT EQUAL TO ZERO, THEN EPS SHOULD BE GREATER
C   THAN OR EQUAL TO MACHINE EPSILON.
C
C
C ON OUTPUT--
C
C   YVAL CONTAINS THE IMAGES OF THE POINTS IN XVAL.
C
C   ERR IS AN ERROR CODE--
C   ERR=0 - MEVAL RAN NORMALLY.
C   ERR=1 - XVAL(I) IS LESS THAN XTAB(1) FOR AT LEAST ONE I OR
C           XVAL(I) IS GREATER THAN XTAB(NUM) FOR AT LEAST ONE I.
C           MEVAL WILL EXTRAPOLATE TO PROVIDE FUNCTION VALUES FOR
C           THESE ABSCISSAS.
C   ERR=2 - XVAL(I+1) .LT. XVAL(I) FOR SOME I.
C
C AND
C
C   MEVAL DOES NOT ALTER XVAL,XTAB,YTAB,MTAB,NUM,NUME.
C
C
C   MEVAL CALLS THE FOLLOWING SUBROUTINES OR FUNCTIONS:
C      SEARCH
C      CASES
C      CHOOSE
C      SPLINE
C
C---------------------------------------------------------------------
C
      save
      
      
      START=1
      END=NUME
      ERR=0
      IF (NUME .EQ. 1) GO TO 20
C
C DETERMINE IF XVAL IS NONDECREASING.
      NUME1=NUME - 1
      DO 10 I=1,NUME1
	  IF (XVAL(I+1) .GE. XVAL(I)) GO TO 10
	  ERR=2
	  GO TO 230
  10  CONTINUE
C
C
C IF XVAL(I) .LT. XTAB(1), THEN XVAL(I)=YTAB(1).
C IF XVAL(I) .GT. XTAB(NUM), THEN XVAL(I)=YTAB(NUM).
C
C DETERMINE IF ANY OF THE POINTS IN XVAL ARE LESS THAN THE ABSCISSA OF
C THE FIRST DATA POINT.
  20  DO 30 I=1,NUME
	  IF (XVAL(I) .GE. XTAB(1)) GO TO 40
	  START=I+1
  30  CONTINUE
C
C
  40  NUME1=NUME+1
C
C DETERMINE IF ANY OF THE POINTS IN XVAL ARE GREATER THAN THE ABSCISSA
C OF THE LAST DATA POINT.
      DO 50 I=1,NUME
	  IND=NUME1-I
	  IF (XVAL(IND) .LE. XTAB(NUM)) GO TO 60
	  END = IND-1
  50  CONTINUE
C
C
C CALCULATE THE IMAGES OF POINTS OF EVALUATION WHOSE ABSCISSAS
C ARE LESS THAN THE ABSCISSA OF THE FIRST DATA POINT.
  60  IF (START .EQ. 1) GO TO 80
C SET THE ERROR PARAMETER TO INDICATE THAT EXTRAPOLATION HAS OCCURRED.
      ERR=1
      CALL CHOOSE(XTAB(1),YTAB(1),MTAB(1),MTAB(2),XTAB(2),
     *            YTAB(2),EPS,NCASE)
      CALL CASES(XTAB(1),YTAB(1),MTAB(1),MTAB(2),XTAB(2),
     *           YTAB(2),E1,E2,V1,V2,W1,W2,Z1,Z2,Y1,Y2,NCASE)
      START1=START - 1
      DO 70 I=1,START1
	 YVAL(I)= SPLINE(XVAL(I),Z1,Z2,XTAB(1),YTAB(1),XTAB(2),YTAB(2),
     *                   Y1,Y2,E2,W2,V2,NCASE)
  70  CONTINUE
      IF (NUME .EQ. 1) GO TO 230
C
C
C SEARCH LOCATES THE INTERVAL IN WHICH THE FIRST IN-RANGE POINT OF
C EVALUATION LIES.
  80  IF ((NUME .EQ. 1) .AND. (END .NE. NUME)) GO TO 200
      CALL SEARCH(XTAB,NUM,XVAL(START),LCN,FND)
C
      LCN1=LCN+1
C
C
C IF THE FIRST IN-RANGE POINT OF EVALUATION IS EQUAL TO ONE OF THE DATA
C POINTS, ASSIGN THE APPROPRIATE VALUE FROM YTAB. CONTINUE UNTIL A
C POINT OF EVALUATION IS FOUND WHICH IS NOT EQUAL TO A DATA POINT.
      IF (FND .EQ. 0) GO TO 130
  90  YVAL(START)=YTAB(LCN)
      START1=START
      START=START+1
      IF (START .GT. NUME) GO TO 230
      IF (XVAL(START1) .EQ. XVAL(START)) GO TO 90
C
  100 IF (XVAL(START) - XTAB(LCN1)) 130,110,120
C
  110 YVAL(START)=YTAB(LCN1)
      START1=START
      START=START+1
      IF (START .GT. NUME) GO TO 230
      IF (XVAL(START) .NE. XVAL(START1)) GO TO 120
      GO TO 110
C
  120 LCN=LCN1
      LCN1=LCN1+1
      GO TO 100
C
C
C
C CALCULATE THE IMAGES OF ALL THE POINTS WHICH LIE WITHIN RANGE OF THE
C DATA.
C
  130 IF ((LCN .EQ. 1) .AND. (ERR .EQ. 1)) GO TO 140
      CALL CHOOSE(XTAB(LCN),YTAB(LCN),MTAB(LCN),MTAB(LCN1),
     *            XTAB(LCN1),YTAB(LCN1),EPS,NCASE)
      CALL CASES(XTAB(LCN),YTAB(LCN),MTAB(LCN),MTAB(LCN1),
     *           XTAB(LCN1),YTAB(LCN1),E1,E2,V1,V2,W1,W2,Z1,Z2,
     *           Y1,Y2,NCASE)
C
  140 DO 190 I=START,END
C
C IF XVAL(I) -XTAB(LCN1) IS NEGATIVE, DO NOT RECALCULATE THE PARAMETERS
C FOR THIS SECTION OF THE SPLINE SINCE THEY ARE ALREADY KNOWN.
      IF (XVAL(I) - XTAB(LCN1)) 150,160,170
C
  150 YVAL(I)=SPLINE(XVAL(I),Z1,Z2,XTAB(LCN),YTAB(LCN),XTAB(LCN1),
     *               YTAB(LCN1),Y1,Y2,E2,W2,V2,NCASE)
      GO TO 190
C
C IF XVAL(I) IS A DATA POINT, ITS IMAGE IS KNOWN.
  160 YVAL(I)=YTAB(LCN1)
      GO TO 190
C
C INCREMENT THE POINTERS WHICH GIVE THE LOCATION IN THE DATA VECTOR.
  170 LCN=LCN1
      LCN1=LCN+1
C
C DETERMINE THAT THE ROUTINE IS IN THE CORRECT PART OF THE SPLINE.
      IF (XVAL(I) - XTAB(LCN1)) 180,160,170
C
C CALL CHOOSE TO DETERMINE THE APPROPRIATE CASE AND THEN CALL
C CASES TO COMPUTE THE PARAMETERS OF THE SPLINE.
  180 CALL CHOOSE(XTAB(LCN),YTAB(LCN),MTAB(LCN),MTAB(LCN1),
     *            XTAB(LCN1),YTAB(LCN1),EPS,NCASE)
      CALL CASES(XTAB(LCN),YTAB(LCN),MTAB(LCN),MTAB(LCN1),
     *           XTAB(LCN1),YTAB(LCN1),E1,E2,V1,V2,W1,W2,Z1,Z2,
     *           Y1,Y2,NCASE)
      GO TO 150
  190 CONTINUE
C
C
C CALCULATE THE IMAGES OF THE POINTS OF EVALUATION WHOSE ABSCISSAS
C ARE GREATER THAN THE ABSCISSA OF THE LAST DATA POINT.
      IF (END .EQ. NUME) GO TO 230
      IF ((LCN1 .EQ. NUM) .AND. (XVAL(END) .NE. XTAB(NUM))) GO TO 210

C Previously, when we arrived at 200 or 210, NUM1 could be improperly set.
C The NUM1= lines below protect from that.  llp   8/19/08

C SET THE ERROR PRARMETER TO INDICATE THAT EXTRAPOLATION HAS OCCURRED.
  200 ERR=1
      NUM1=max(NUM-1,1)
      CALL CHOOSE(XTAB(NUM1),YTAB(NUM1),MTAB(NUM1),MTAB(NUM),
     *            XTAB(NUM),YTAB(NUM),EPS,NCASE)
      CALL CASES(XTAB(NUM1),YTAB(NUM1),MTAB(NUM1),MTAB(NUM),
     *           XTAB(NUM),YTAB(NUM),E1,E2,V1,V2,W1,W2,Z1,Z2,
     *           Y1,Y2,NCASE)
  210 END1=END + 1
      NUM1=max(NUM-1,1)
      DO 220 I=END1,NUME
	 YVAL(I)= SPLINE(XVAL(I),Z1,Z2,XTAB(NUM1),YTAB(NUM1),
     *                   XTAB(NUM),YTAB(NUM),Y1,Y2,E2,W2,V2,NCASE)
  220 CONTINUE
C
C
  230 RETURN
      END
