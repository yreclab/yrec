      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C  MARC PINSONNEAULT, YALE UNIVERSITY,DEPARTMENT OF ASTRONOMY.
C   THIS PROGRAM READS IN THE LAWRENCE LIVERMORE OPACITY TABLES, AND
C   CREATES A TABLE OF THE DESIRED METALLICITY.  THIS IS SPECIFIED
C   AN ABSOLUTE METALLICITY (Z) READ IN FROM THE COMMAND FILE.
C   A CUBIC SPLINE (IN LOG CAPPA) IS USED TO INTERPOLATE IN Z.
C TABLE RANGE IN Z:
C   THE TABLES RANGE FROM Z=0 TO Z=0.10.
C TABLE RANGE IN TEMPERATURE : 6000 TO 10**8 K.
C ASSUMED MIXTURE OF HEAVY ELEMENTS :
C   ***THE CURRENT TABLES DO NOT ALLOW FOR VARYING THE RELATIVE
C   ABUNDANCES OF THE HEAVY ELEMENTS.
C   THE HEAVY ELEMENT MIXTURE IS FROM GREVESSE (1991), AND THE RELATIVE
C   ABUNDANCES (NUMBER FRACTIONS) ARE LISTED IN THE DATA STATEMENT FOR
C   THE VECTOR "ZABUNDS".
C   THERE ARE 20 ELEMENTS CONSIDERED WHEN COMPUTING THE OPACITIES.
C   THE SOLAR X,Y,Z VALUES (USED TO INTERPRET [FE/H] VALUES) ARE LISTED
C   IN THE DATA STATEMENT FOR THE VECTOR "SOLABUNDS".
C OUTPUT TABLE FORMAT :
C   THE FIRST 2 LINES OF THE OUTPUT FILE CONTAINS Z AND THE HEAVY ELEMENT
C   ABUNDANCES.
C   FOLLOWING THIS, THERE ARE THREE TABLES FOR THE GIVEN Z AND 
C   X OF (0.0,0.35,0.7).
C   PRIOR TO EACH TABLE IS A HEADER FILE.
C   THE HEADER FILE INDICATES THE X VALUE FOR THE TABLE, AND INDICATES THE
C   SET OF DENSITY RELATED POINTS R.
C   THE LISTED NUMBERS ARE THE LOGARITHM OF (RHO/T6**3), WHERE T6 IS
C   THE TEMPERATURE IN UNITS OF 10**6 K.
C   ***NOTE : THERE ARE MORE DENSITIES STORED FOR LOW TEMPERATURES (BELOW
C   45 THOUSAND K) THAN FOR HIGH TEMPERATURES.
C   THE FIRST NUMBER IN EACH LINE IS THE VALUE OF T6 FOR THE OPACITIES 
C   WHICH FOLLOW.
C   THE LOGARITHMS (BASE 10) OF THE OPACITIES ARE STORED IN THE TABLES
C   THEMSELVES.
      REAL*8 KAPPA(3,50,17)
      DIMENSION XGRID(3),ZGRID(39),T6GRID(50),RT3GRID(17),ZGRIDL(39),
     * CAPPA(39,50,17),RT3(17),T6(50),QCAPPAZ(39,50,17),DUM(4)
      DATA T6GRID/0.006D0,0.007D0,0.008D0,0.009D0,0.010D0,0.011D0,
     *    0.012D0,0.014D0,0.016D0,0.018D0,0.020D0,0.025D0,0.030D0,
     *    0.035D0,0.040D0,0.045D0,0.050D0,0.055D0,0.060D0,0.070D0,
     *    0.080D0,0.090D0,0.100D0,0.120D0,0.150D0,0.200D0,0.250D0,
     *    0.300D0,0.400D0,0.500D0,0.600D0,0.800D0,1.000D0,1.200D0,
     *    1.500D0,2.000D0,2.500D0,3.000D0,4.000D0,5.000D0,6.000D0,
     *    8.000D0,1.000D1,1.500D1,2.000D1,3.000D1,4.000D1,6.000D1,
     *    8.000D1,1.000D2/
      DATA RT3GRID/-7.0D0,-6.5D0,-6.0D0,-5.5D0,
     *             -5.0D0,-4.5D0,-4.0D0,-3.5D0,-3.0D0,-2.5D0,-2.0D0,
     *             -1.5D0,-1.0D0,-0.5D0, 0.0D0, 0.5D0, 1.0D0/
      DATA XGRID/0.7D0,0.35D0,0.0D0/
      DATA ZGRID/0.0D0,0.0D0,0.0D0,1.0D-4,1.0D-4,1.0D-4,3.0D-4,3.0D-4,
     *3.0D-4,1.0D-3,1.0D-3,1.0D-3,2.0D-3,2.0D-3,2.0D-3,4.0D-3,4.0D-3,
     *4.0D-3,1.0D-2,1.0D-2,1.0D-2,2.0D-2,2.0D-2,2.0D-2,3.0D-2,3.0D-2,
     *3.0D-2,4.0D-2,4.0D-2,4.0D-2,6.0D-2,6.0D-2,6.0D-2,8.0D-2,8.0D-2,
     *8.0D-2,1.0D-1,1.0D-1,1.0D-1/
      DATA ZMIN,ZMAX/0.0D0,0.1D0/
      DATA DUM/-9.999D0,-9.999D0,-9.999D0,-9.999D0/
      DATA IDATA,ITABLE/11,12/
      DO K = 1,3
         ZGRIDL(K) = -8.0D0
      END DO
      DO K = 4,39
         ZGRIDL(K) = LOG10(ZGRID(K))
      END DO
C OPEN DATA FILE AND READ IN HEADER INFO
      OPEN(UNIT=IDATA,FORM='FORMATTED',STATUS='OLD',READONLY,SHARED)
      DO K = 3,39,3
         READ(IDATA,10)X,Z,(RT3(N),N=1,14)
   10    FORMAT(////49X,F6.4,7X,F6.4////6X,F6.1,9F7.1/F5.1,3F7.1/)
C CHECK FOR CONSISTENCY OF STORED AND ACTUAL X,Z
         IF(X.NE.XGRID(3) .OR. Z.NE.ZGRID(K))THEN
            WRITE(*,911)XGRID(3),ZGRID(K)
  911       FORMAT(1X,'MISMATCH BETWEEN DATA AND EXPECTED X&Z'/
     *             'TABLE X AND Z',2F6.4,' RUN STOPPED')
            STOP
         ELSE
            DO N = 1,14
C CHECK FOR CONSISTENCY OF STORED AND ACTUAL RHO/T6**3 GRID POINTS
               IF(RT3(N).NE.RT3GRID(N))THEN
                  WRITE(*,912)N,RT3(N),RT3GRID(N)
  912             FORMAT(1X,'MISMATCH BETWEEN DATA AND EXPECTED RT3'/
     *            ' ACTUAL AND TABLE RT3, ENTRY ',I2,2F6.1,' STOPPED')
                  STOP
               ENDIF
            END DO
         ENDIF
C READ IN DATA FOR THE FIRST 32 TEMPERATURES (13 DENSITY ENTRIES)
         DO J = 1,32
            READ(IDATA,20)T6(J),(CAPPA(K,J,I),I=1,13)
   20       FORMAT(11F7.3/3F7.3)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
  913          FORMAT(' ERROR IN TABLE ',I2,' LINE ',I2,
     *         'STORED AND ACTUAL TEMPERATURES DIFFERENT'/
     *         ' ACTUAL ',F7.3,' STORED ',F7.3,' RUN STOPPED')
               STOP
            ENDIF
         END DO
         DO J = 33,50
            READ(IDATA,30)T6(J),(CAPPA(K,J,I),I=1,14)
   30       FORMAT(11F7.3/4F7.3)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
      END DO
      DO K = 2,38,3
         READ(IDATA,11)X,Z,(RT3(N),N=1,17)
   11    FORMAT(////49X,F6.4,7X,F6.4////6X,F6.1,9F7.1/F5.1,6F7.1/)
C CHECK FOR CONSISTENCY OF STORED AND ACTUAL X,Z
         IF(X.NE.XGRID(2) .OR. Z.NE.ZGRID(K))THEN
            WRITE(*,911)XGRID(2),ZGRID(K)
            STOP
         ELSE
            DO N = 1,17
C CHECK FOR CONSISTENCY OF STORED AND ACTUAL RHO/T6**3 GRID POINTS
               IF(RT3(N).NE.RT3GRID(N))THEN
                  WRITE(*,912)N,RT3(N),RT3GRID(N)
                  STOP
               ENDIF
            END DO
         ENDIF
C READ IN DATA FOR THE FIRST 15 TEMPERATURES (17 DENSITY ENTRIES)
         DO J = 1,15
            READ(IDATA,25)T6(J),(CAPPA(K,J,I),I=1,17)
   25       FORMAT(11F7.3/7F7.3)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
         DO J = 16,32
            READ(IDATA,20)T6(J),(CAPPA(K,J,I),I=1,13)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
         DO J = 33,50
            READ(IDATA,30)T6(J),(CAPPA(K,J,I),I=1,14)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
      END DO
      DO K = 1,37,3
         READ(IDATA,11)X,Z,(RT3(N),N=1,17)
C CHECK FOR CONSISTENCY OF STORED AND ACTUAL X,Z
         IF(X.NE.XGRID(1) .OR. Z.NE.ZGRID(K))THEN
            WRITE(*,911)XGRID(1),ZGRID(K)
            STOP
         ELSE
            DO N = 1,17
C CHECK FOR CONSISTENCY OF STORED AND ACTUAL RHO/T6**3 GRID POINTS
               IF(RT3(N).NE.RT3GRID(N))THEN
                  WRITE(*,912)N,RT3(N),RT3GRID(N)
                  STOP
               ENDIF
            END DO
         ENDIF
C READ IN DATA FOR THE FIRST 15 TEMPERATURES (17 DENSITY ENTRIES)
         DO J = 1,15
            READ(IDATA,25)T6(J),(CAPPA(K,J,I),I=1,17)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
C READ IN DATA FOR THE NEXT 17 TEMPERATURES (13 DENSITY ENTRIES)
         DO J = 16,32
            READ(IDATA,20)T6(J),(CAPPA(K,J,I),I=1,13)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
C READ IN DATA FOR THE LAST 18 TEMPERATURES (14 DENSITY ENTRIES)
         DO J = 33,50
            READ(IDATA,30)T6(J),(CAPPA(K,J,I),I=1,14)
C CHECK IF ACTUAL, STORED TEMPERATURES AGREE.
            IF(T6(J).NE.T6GRID(J))THEN
               WRITE(*,913)K,J,T6(J),T6GRID(J)
               STOP
            ENDIF
         END DO
      END DO
C LINEAR EXTRAPOLATION IN THE LOG TO FILL OUT R=-0.5 COLUMN FOR
C INTERMEDIATE TEMPERATURES.
      DO K = 1,39
         DO J = 16,32
            CAPPA(K,J,14)=2.0D0*CAPPA(K,J,13)-CAPPA(K,J,12)
         END DO
C ZERO OUT DENSITY ARRAYS WHICH ARE NOT STORED
         DO J = 16,50
            DO KK = 15,17
               CAPPA(K,J,KK)=-9.999D0
            END DO
         END DO
      END DO
C FOR X=0 TABLES, FIND OPACITY FOR LOW T BY LINEAR EXTRAPOLATION
C IN THE LOG FROM X=0.35 AND X=0.7 TABLES
      DO K = 3,39,3
         DO J = 1,15
            DO I = 14,17
               CAPPA(K,J,I) = 2.0D0*CAPPA(K-1,J,I)-CAPPA(K-2,J,I)
            END DO
         END DO
      END DO
C NOW READ IN DESIRED TABLE Z
      READ(*,40)ZNEW
   40 FORMAT(F8.6)
C ENSURE THAT THE DESIRED Z IS WITHIN THE TABLE RANGE.
      IF(ZNEW.LT.ZMIN .OR. ZNEW.GT.ZMAX)THEN
         WRITE(*,914)ZNEW
  914    FORMAT(' VALUE OF ZNEW ',F6.4,' OUT OF BOUNDS- STOPPED')
         STOP
      ENDIF
      ZNEWL = LOG10(ZNEW)
      DO K = 1,37,3
C FOR THE SPECIAL CASE ZNEW = ZGRID, SKIP INTERPOLATION AND WRITE OUT
C THE APPROPRIATE TABLE. 
         IF(ZGRID(K).EQ.ZNEW)THEN
            DO KK=K+2,K,-1
              JJ=MOD(KK,3)
              IF(JJ.EQ.0)JJ=3
              WRITE(ITABLE,60)XGRID(JJ),ZGRID(KK),(RT3GRID(N),N=1,17)
   60         FORMAT(31X,' X ',F6.4,' Z ',F6.4/37X,'Log R'/4X,'T6',
     *               17F7.1)
              WRITE(ITABLE,65)(T6(J),(CAPPA(KK,J,I),I=1,17),J=1,50)
   65         FORMAT(18F7.3)
            END DO
            STOP
         ENDIF
         IF(ZGRID(K).GE.ZNEW) GOTO 50
      END DO
      K = 37
   50 CONTINUE
      KABOVE=K
C DETERMINE SPLINE COEFFICIENTS
      CALL SPLINE(ZGRIDL,CAPPA,39,50,17,QCAPPAZ)
C INTERPOLATE TO FIND THE TABLES AT THE DESIRED Z.
      CALL SPLINT(ZGRIDL,CAPPA,39,50,17,QCAPPAZ,ZNEWL,KAPPA)
      DO KK=3,1,-1
         WRITE(ITABLE,60)XGRID(KK),ZNEW,(RT3GRID(N),N=1,17)
         WRITE(ITABLE,65)(T6(J),(KAPPA(KK,J,I),I=1,17),J=1,15)
         WRITE(ITABLE,65)(T6(J),(KAPPA(KK,J,I),I=1,14),
     *                   (DUM(II),II=1,3),J=16,50)
      END DO
      STOP
      END
      SUBROUTINE SPLINE(X,Y,KMAX,JMAX,IMAX,Y2)
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION X(39),Y(39,50,17),Y2(39,50,17),U(39,50,17)
C FIND SECOND DERVIATIVES OF CAPPA WITH RESPECT TO Z.
C NOTE ON STORAGE : THREE TABLES WITH DIFFERENT X ARE STORED FOR
C EACH Z, WHICH EXPLAINS THE DIFFERENCES BETWEEN THIS SR AND THE
C ONE FROM NUMERICAL RECIPES, P.88, ON WHICH IT IS BASED.
C NATURAL SPLINE LOWER BOUNDARY CONDITION
      DO K = 1,3
         DO J = 1,JMAX
            DO I = 1,IMAX
               Y2(K,J,I) = 0.0D0
               U(K,J,I) = 0.0D0
            END DO
         END DO
      END DO
C DECOMPOSITION LOOP.
      DO K = 4,KMAX-3
         DXP = X(K+3)-X(K)
         DXM = X(K)-X(K-3)
         SIG = DXM/DXP
C        SIG = (X(K)-X(K-3))/(X(K+3)-X(K))
         DO J = 1,JMAX
            DO I = 1,IMAX
               P = SIG*Y2(K-3,J,I)+2.0D0
               Y2(K,J,I) = (SIG-1.0D0)/P
               U(K,J,I) = (6.0D0*((Y(K+3,J,I)-Y(K,J,I))/DXP
     *                    -(Y(K,J,I)-Y(K-3,J,I))/DXM)/(DXM+DXP)
     *                    -SIG*U(K-3,J,I))/P
            END DO
         END DO
      END DO
C NATURAL SPLINE UPPER BOUNDARY CONDITION
      DO K = 37,39
         DO J = 1,JMAX
            DO I = 1,IMAX
               Y2(K,J,I) = 0.0D0
            END DO
         END DO
      END DO
C BACKSUBSTITUTION
      DO K = KMAX-3,1,-1
         DO J = 1,JMAX
            DO I = 1,IMAX
               Y2(K,J,I) = Y2(K,J,I)*Y2(K+3,J,I)+U(K,J,I)
            END DO
         END DO
      END DO
      RETURN
      END
      SUBROUTINE SPLINT(X,Y,KMAX,JMAX,IMAX,Y2,ZNEW,KAPPA)
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 KAPPA(3,50,17)
      DIMENSION X(39),Y(39,50,17),Y2(39,50,17)
C FIND NEAREST TABLE ENTRY IN Z.
      DO K = 1,37,3
         IF(X(K).GE.ZNEW) GOTO 50
      END DO
      K = 37
   50 CONTINUE
      KHI = K
      KLO = K-3
      KHI0 = KHI
      KLO0 = KLO
      H = X(KHI)-X(KLO)
      A = (X(KHI)-ZNEW)/H
      B = (ZNEW-X(KLO))/H
      DO K = 1,3
         KLO = KLO0+K-1
         KHI = KHI0+K-1
         DO J = 1,JMAX
            DO I = 1,IMAX
               KAPPA(K,J,I) = A*Y(KLO,J,I)+B*Y(KHI,J,I)+
     *         ((A**3-A)*Y2(KLO,J,I)+(B**3-B)*Y2(KHI,J,I))*(H**2)/6
            END DO
         END DO
      END DO
      RETURN
      END
