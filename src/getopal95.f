C THIS IS THE INTERPOLATION FACILITY FOR THE LIVERMORE OPACITY TABLES
C USING CUBIC SPLINE INTERPLOATION SCHEME.   (FOR OPAL95)
C --------------------------------------------------------------
C      SUBROUTINE GETOPAL95(DL,TL,X,Z,O,OL,QOD,QOT) DRIVER- GET CAPPA
C      SUBROUTINE OP952D(O,OL,QOD,QOT) 2D INTERPOLATION IN (T,RHO)
C      SUBROUTINE OP953D(O,OL,QOD,QOT) 3D INTERPOLATION IN (X,T,RHO)
C      SUBROUTINE OP954D(O,OL,QOD,QOT) 4D INTERPOLATION IN (Z,X,T,RHO)
C      SUBROUTINE LL95TBL READ IN ALL TABLES
C      SUBROUTINE OP95ZTAB(Z) GENERATE TABLE AT FIXED Z
C      SUBROUTINE OP95XTAB(X) GENERATE TABLE AT FIXED X,Z
C
C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     GETOPAL95
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE GETOPAL95(DL,TL,X,Z,O,OL,QOD,QOT)
C 7/98 MHP DRIVER ROUTINE FOR OPACITY GIVEN RHO,T, X, AND Z.
      use params, only : numt => numtt, numd, numx, numz, numxz, json
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C FULL SET OF TABLES: OPACITY AS A FUNCTION OF Z AND X, T, RHO/T6**3
C TABLES ARE INCREMENTED IN SETS OF NZ*NX.  SO THE TABLES FOR THE
C THIRD METAL ABUNDANCE (3 X 10**-4)BEGIN AT TABLE 21 AND END AT TABLE 30.
C FOR THE HIGH VALUES OF Z, THE NUMBER OF X TABLES IS NOT THE SAME (I.E.
C X<0.9 FOR Z=0.1).
C FOR EACH COMPOSITION A FULL GRID IN (T,RHO/T6**3) IS RETAINED.
      COMMON /LLOT95A/TGR(NUMT),XXG(NUMX),R0GR(NUMD),ZZG(NUMZ),
     *                CAPPA2(NUMXZ,NUMT,NUMD),NUMXM(NUMZ),NZ(NUMZ)
C AS ABOVE FOR THE MODEL Z.
      COMMON /LLOT95/CAPPA(NUMX,NUMT,NUMD),ZTAB
C AS ABOVE FOR DESIRED SURFACE VALUE OF X.
      COMMON /LLOT95E/CAPPAE(NUMT,NUMD),XTAB
C INDICES FOR INTERPOLATION IN Z,X,T, AND R
      COMMON/OP95INDX/JZ,JX(4,4),JT,JD(4)
C INTERPOLATION FACTORS FOR Z,X,T, AND R, AS WELL AS DERIVATIVE
C FACTORS FOR T AND RHO.
      COMMON/OP95FACT/BZ(4),BX(4,4),BT(4),BTT(4),BD(4,4),BDD(4,4)
      COMMON/OP95EXT/RL,RLL,RLH(4),LEXTL,LEXTH,LEXH(4)
C JVS Acoustic depth common block
  	COMMON/ACDPTH/TAUCZN,DELADJ(JSON),TAUHE, TNORM, TCZ, WHE, ICLCD,
     *ACATMR(JSON), ACATMD(JSON), ACATMP(JSON), ACATMT(JSON),TATMOS,
     *LCLCD, AGEOUT(5), IACAT, IJLAST, LJLAST, LJWRT, LADON,LAOLY, IJVS,
     *IJENT, IJDEL, LACOUT
C END JVS
      DIMENSION A(4),B(4),C(4)
      SAVE
C ENSURE THAT WE ARE WITHIN THE OPAL 95 TABLES.
C COMPUTE LOG R = RHO/T6**3
      RL = DL - 3.0D0*(TL-6.0D0)
C  CHECK T
      IF(TL.LT.TGR(1) .OR. TL.GT.TGR(NUMT))THEN
         WRITE(*,5)TL
 5       FORMAT(' LOG T OF',F11.6,'OUT OF OPAL 95 TABLE RANGE')
         STOP
      ENDIF
C CHECK TO SEE IF EXTRAPOLATION BELOW THE FIRST TABLE ELEMENT
C IN DENSITY IS NEEDED.
      IF(RL.LT.R0GR(1))THEN
         LEXTL = .TRUE.
      ELSE
         LEXTL = .FALSE.
      ENDIF
C  THIS SECTION IS REPLACED BY LINEAR EXTRAPOLATION IN R FROM THE
C  LAST TWO OPACITY VALUES.
C      IF(RL.LT.(R0GR(1)-4.0D0) .OR. RL.GT.(R0GR(NUMD)+1.0D0))THEN
C         WRITE(*,7)RL,TL
C 7       FORMAT(' LOG R OF',F11.6,' OUT OF OPAL 95 TABLE RANGE;TL'
C     *          ,F11.6)
C         STOP
C      ENDIF
C GET INTERPOLATION FACTORS IN T
      IF(TL.GE.TGR(JT+2))THEN
         DO I = JT+3,NUMT-1
            IF(TL.LT.TGR(I))THEN
               JT = I - 2
               GOTO 10
            ENDIF
         END DO
         JT = NUMT - 3
 10      CONTINUE
      ELSE
         DO I = JT+1,2,-1
            IF(TL.GT.TGR(I))THEN
               JT = I - 1
               GOTO 20
            ENDIF
         END DO
         JT = 1
 20      CONTINUE
      ENDIF
C T INTERPOLATION FACTORS
      DO I = 1,4
         A(I) = TGR(JT+I-1)
      END DO
C GET INTERPOLATION FACTORS IN T
      CALL INTERP(A,B,C,TL)
      DO I = 1,4
         BT(I) = B(I)
         BTT(I) = C(I)
      END DO
C GET INDICES IN RHO FOR EACH OF THE 4 T VALUES.
      IF(RL.GE.R0GR(JD(1)+2))THEN
         DO I = JD(1)+3,NUMD-1
            IF(RL.LT.R0GR(I))THEN
               JD(1) = I - 2
               GOTO 30
            ENDIF
         END DO
         JD(1) = NUMD - 3
 30      CONTINUE
      ELSE
         DO I = JD(1)+1,2,-1
            IF(RL.GT.R0GR(I))THEN
               JD(1) = I - 1
               GOTO 40
            ENDIF
         END DO
         JD(1) = 1
 40      CONTINUE
      ENDIF
C NOW CHECK IF WITHIN PORTION OF TABLE WITH DATA.
C NOTE THAT A POINT CAN BE WITHIN THE TABLE AND STILL HAVE THE
C 4X4 MATRIX OF T,RHO AROUND IT OUTSIDE THE TABLE.
C CHECK LOW RHO, LOW T REGIME; SINCE THE EMPTY REGION DEPENDS ON Z AT
C LOW X, POSTPONE UNTIL YOU KNOW IF IT IS A 2D, 3D, OR 4D INTERPOLATION.
      IF(X.LT.0.2D0 .AND. JT. LE. 5)THEN
         LCHK = .TRUE.
         GOTO 60
      ELSE
         LCHK = .FALSE.
      ENDIF
C CHECK HIGH RHO, HIGH T REGIME(BECAUSE OF THE TABLE GEOMETRY, THE
C POINT WILL FALL OUTSIDE THE TABLE FIRST AT THE HIGHEST T).
      LSHIFT = .FALSE.
      LEXTH = .FALSE.
      IF(CAPPA(JX(1,1),JT+3,JD(1)+3) .GE. 9.9D0) THEN
         LSHIFT = .TRUE.
C NOW THERE ARE TWO POSSIBLE SOLUTIONS: WE CAN USE A DIFFERENT SET
C OF DENSITIES FOR EACH TEMPERATURE AND STAY WITHIN THE TABLE, OR
C THE DESIRED DENSITY COULD BE OUTSIDE THE TABLE AT ONE OR MORE
C TEMPERATURES.  IF THE DESIRED DENSITY IS OUTSIDE THE TABLE,
C LINEAR EXTRAPOLATION IN R AT FIXED T IS USED.
         DO K = 1,4
            IF(CAPPA(JX(1,1),JT+K-1,JD(1)+1).GE.9.9D0)THEN
               LEXTH = .TRUE.
               LEXH(K) = .TRUE.
            ELSE
               LEXH(K) = .FALSE.
            ENDIF
         END DO
C FIND 4 NEAREST ELEMENTS WITHIN THE TABLE AT EACH OF THE 4 TEMPERATURES.
         IXX = JX(1,1)
         IDD = JD(1)
         DO I = 1,4
            ITT = JT+I-1
            IF(CAPPA(IXX,ITT,IDD+3).GT.9.9D0)THEN
               DO J = IDD+2,1,-1
                  IF(CAPPA2(IXX,ITT,J).LE.9.9D0)THEN
                     JD(I) = J - 3
                     IDD = J - 3
                     GOTO 50
                  ENDIF
               END DO
 50            CONTINUE
            ELSE
               JD(I) = IDD
            ENDIF
         END DO
      ENDIF
 60   CONTINUE
C GET INTERPOLATION FACTORS IN RHO FOR EACH OF THE 4 T VALUES.
C ASSIGN ALL THE SAME VALUES IF GRID IN R IS SAME FOR ALL T.
      IF(.NOT.LSHIFT)THEN
         DO I = 1,4
            A(I) = R0GR(JD(1)+I-1)
         END DO
         IF(.NOT.LEXTL)THEN
            CALL INTERP(A,B,C,RL)
         ELSE
            RLL = R0GR(1)
            CALL INTERP(A,B,C,RLL)
         ENDIF
         DO J = 1,4
            JD(J) = JD(1)
            DO I = 1,4
               BD(J,I) = B(I)
               BDD(J,I) = C(I)
            END DO
         END DO
      ELSE
         DO J = 1,4
            DO I = 1,4
               A(I) = R0GR(JD(J)+I-1)
            END DO
C IF EXTRAPOLATION IS BEING PERFORMED, ASSIGN R=REDGE
C AND EXTRAPOLATE LINEARLY LATER
            IF(.NOT.LEXH(J))THEN
               CALL INTERP(A,B,C,RL)
            ELSE
               RR = R0GR(JD(J)+3)
               CALL INTERP(A,B,C,RR)
               RLH(J) = RR
            ENDIF
            DO I = 1,4
               BD(J,I) = B(I)
               BDD(J,I) = C(I)
            END DO
         END DO
      ENDIF
C DETERMINE WHETHER A 2D (RHO,T); 3D (X,RHO,T); OR 4D (Z,X,RHO,T)
C INTERPOLATION IS NEEDED TO GET THE OPACITY.
C JVS 04/11 force 4d interpolation for acoustic depth calculations
	IF (LADON .AND. LACOUT) GOTO 153  ! If we're worrying about the acoustic depth, default to 4d interp
      IF(ABS(Z-ZTAB)/MAX(ZTAB,1.0D-6).LE.1.0D-4)THEN
         IF(ABS(X-XTAB).LE.1.0D-4)THEN
C 2D INTERPOLATION IN SURFACE TABLE
            CALL OP952D(O,OL,QOD,QOT)
            GOTO 9999
         ELSE
C 3D INTERPOLATION IN FIXED Z TABLE (X,T,RHO)
C GET INTERPOLATION FACTORS IN X.
         IF(X.GT.XXG(JX(1,1)+2))THEN
            DO I = JX(1,1)+3,NUMX-1
               IF(X.LT.XXG(I))THEN
                  JX(1,1) = I - 2
                  GOTO 70
               ENDIF
            END DO
            JX(1,1) = NUMX - 3
 70         CONTINUE
         ELSE
            DO I = JX(1,1)+1,2,-1
               IF(X.GE.XXG(I))THEN
                  JX(1,1) = I - 1
                  GOTO 80
               ENDIF
            END DO
            JX(1,1) = 1
 80         CONTINUE
         ENDIF
C CHECK FOR ABSENT TABLES AT HIGH X.
         IF(ZTAB.GE.0.04D0)THEN
            IF(X.GE.0.8D0)THEN
               IF(ZTAB.LT.0.1D0)THEN
C NO TABLE 9 (X=0.95)
                  JX(1,4) = NUMX
                  JX(1,3) = NUMX - 2
                  JX(1,2) = NUMX - 3
                  JX(1,1) = NUMX - 4
               ELSE
C NO TABLE 9 OR TABLE 10
                  JX(1,4) = NUMX - 2
                  JX(1,3) = NUMX - 3
                  JX(1,2) = NUMX - 4
                  JX(1,1) = NUMX - 5
               ENDIF
            ELSE
               JXX = JX(1,1) - 1
               DO I = 1,4
                  JX(1,I) = JXX + I
               END DO
            ENDIF
         ELSE
            JXX = JX(1,1) - 1
            DO I = 1,4
               JX(1,I) = JXX + I
            END DO
         ENDIF
C X INTERPOLATION FACTORS
         DO I = 1,4
            IXX = JX(1,I)
            A(I) = XXG(IXX)
         END DO
         IF(JX(1,4).EQ.NUMX)THEN
            A(4) = 1.0D0 - ZTAB
         ENDIF
C GET INTERPOLATION FACTORS IN X
         CALL INTRP2(A,B,X)
         DO J = 1,4
            BX(1,J) = B(J)
         END DO
         CALL OP953D(O,OL,QOD,QOT)
         GOTO 9999
      ENDIF
      ENDIF
153	CONTINUE
C 4D INTERPOLATION IN Z,X,T,RHO
C GET NEAREST TABLES IN Z.
      IF(Z.GT.ZZG(JZ+2))THEN
c mhp 7/12 corrected typo
C         DO I = JZ+3,NUMT-1
         DO I = JZ+3,NUMZ-1
            IF(Z.LT.ZZG(I))THEN
               JZ = I - 2
               GOTO 110
            ENDIF
         END DO
         JZ = NUMZ - 3
 110     CONTINUE
      ELSE
         DO I = JZ+1,2,-1
            IF(Z.GE.ZZG(I))THEN
               JZ = I - 1
               GOTO 120
            ENDIF
         END DO
         JZ = 1
 120     CONTINUE
      ENDIF
C mhp 7/12 added failsafe
      JZ = MIN(JZ,NUMZ-3)
C Z INTERPOLATION FACTORS
      DO I = 1,4
         A(I) = ZZG(JZ+I-1)
      END DO
C INTERPOLATION FACTORS IN Z
      CALL INTRP2(A,B,Z)
      DO I = 1,4
         BZ(I) = B(I)
      END DO
C GET NEAREST TABLES IN X AT EACH VALUE OF Z
      DO K = 1,4
         ZZ = ZZG(JZ+K-1)
         IXX = JX(K,1)
         IF(X.GT.XXG(IXX+2))THEN
            DO I = JX(K,1)+3,NUMX-1
               IF(X.LT.XXG(I))THEN
                  JX(K,1) = I - 2
                  GOTO 75
               ENDIF
            END DO
            JX(K,1) = NUMX - 3
 75         CONTINUE
         ELSE
            DO I = JX(K,1)+1,2,-1
               IF(X.GE.XXG(I))THEN
                  JX(K,1) = I - 1
                  GOTO 85
               ENDIF
            END DO
            JX(K,1) = 1
 85         CONTINUE
         ENDIF
C CHECK FOR ABSENT TABLES AT HIGH X.
         IF(ZZ.GE.0.04D0)THEN
            IF(X.GE.0.8D0)THEN
               IF(ZZ.LT.0.1D0)THEN
C NO TABLE 9 (X=0.95)
                  JX(K,4) = NUMX
                  JX(K,3) = NUMX - 2
                  JX(K,2) = NUMX - 3
                  JX(K,1) = NUMX - 4
               ELSE
C NO TABLE 9 OR TABLE 10
                  JX(K,4) = NUMX - 2
                  JX(K,3) = NUMX - 3
                  JX(K,2) = NUMX - 4
                  JX(K,1) = NUMX - 5
               ENDIF
            ELSE
               JXX = JX(K,1) - 1
               DO I = 1,4
                  JX(K,I) = JXX + I
               END DO
            ENDIF
         ELSE
            JXX = JX(K,1) - 1
            DO I = 1,4
               JX(K,I) = JXX + I
            END DO
         ENDIF
C X INTERPOLATION FACTORS
         DO I = 1,4
            IXX = JX(K,I)
            A(I) = XXG(IXX)
         END DO
         IF(JX(K,4).EQ.NUMX)THEN
            A(4) = 1.0D0 - ZZ
         ENDIF
C GET INTERPOLATION FACTORS IN X
         CALL INTRP2(A,B,X)
         DO J = 1,4
            BX(K,J) = B(J)
         END DO
      END DO
      CALL OP954D(O,OL,QOD,QOT)
 9999 CONTINUE
      RETURN
      END
