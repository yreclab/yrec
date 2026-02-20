C MHP 8/19 Program for extracting rotation distributions for a specified mass-dependent initial state.
C The underlying input is from the ROTEVOL code, processed in the ROTISOCHRONE code to a fixed age.
      IMPLICIT REAL*8 (A-H, O-Z)
      IMPLICIT LOGICAL*4 (L)
C MAXIMUM NUMBER OF MASS TRACKS AND MODELS PER TRACK RESPECTIVELY
      PARAMETER(NTRACK=40,NROT=40,NPER=5)
C INPUTS FROM TRACKS - ROTATION PERIOD AT FIXED AGE AS A FUNCTION OF MASS AND INITIAL PERIOD
      REAL*8 SM(NTRACK),SPROT(NROT),SPERIOD(NROT,NTRACK),SMPER(NTRACK)
C INPUT DATA FOR INITIAL PERIOD AS A FUNCTION OF MASS AND PERCENTILE GROUP
      REAL*8 SP_INIT(NPER,NTRACK),PER(NPER)
C OUTPUT DATA - ISOCHRONE PERIOD VS MASS BY PERCENTILE GROUP
      REAL*8 SP_INTERP(NPER,NTRACK)
C INTERPOLATION TERMS
      REAL*8 A(4),B(4)
C HEADER
      CHARACTER*80 DUMMY
      SAVE
C NUMBER OF MASS TRACKS AND INITIAL ROTATION STATES
      INUMT = 13
      NUMROT=31
      IISO=20
C HEADER
      READ(IISO,10)DUMMY
 10   FORMAT(A80)
C READ IN ISOCHRONE DATA AS A FUNCTION OF P_INIT AND MASS (FIXED GRID)
      DO I=1,NUMROT
         DO JJ = 1,INUMT
            READ(IOUT,20)SM(J),SPROT(I),SPERIOD(I,J)
         END DO
      END DO
 20   FORMAT(3E16.8)
C READ IN THE DESIRED PERCENTILE BINS BEING MODELED AND THE DEPENDENCE OF P_INIT ON MASS FOR THEM
      IPER=5
      IIC=21
      READ(IIC,*)(PER(I),I=1,IPER)
      DO J = 1,NTRACK
         READ(IIC,*)SMPER(J),(SP_INIT(I,J),I=1,NPER)
         TEST = ABS(SMPER(J)-SM(J))
         IF(TEST.GT.1.0D-4)STOP911
      END DO
C NOW RUN THROUGH AND INTERPOLATE IN THE FIXED GRID TO THE DESIRED MASS DEPENDENT IC
      DO I = 1,IPER
         DO J = 1,NTRACK
            X = SP_INIT(I,J)
            DO JJ = 3,NUMROT
               IF(X.LT.SPROT(JJ))THEN
                  IMIN = JJ-3
                  GOTO 40
               ENDIF
            END DO
            IMIN = NUMROT - 4
 40         CONTINUE
            DO JJ = 1,4
               A(JJ)=SPROT(IMIN+JJ)
            END DO
            CALL INTRP2(A,B,X)
            SP_INTERP(I,J)=B(1)*SPERIOD(J,IMIN+1)+B(2)*SPERIOD(J,IMIN+2)+
     *                     B(3)*SPERIOD(J,IMIN+3)+B(4)*SPERIOD(J,IMIN+4)
         END DO
      END DO
C NOW RUN THROUGH AND INTERPOLATE IN THE FIXED GRID TO THE DESIRED MASS DEPENDENT IC
      IOUT = 30
      DO I = 1,IPER
         DO J = 1,NTRACK
            WRITE(IOUT,50)PER(I),SMPER(J),SP_INIT(I,J),SP_INTERP(I,J)
         END DO
      END DO
 50   FORMAT(4F10.3)
      STOP
      END
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C INTEP2
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE INTRP2(A,B,X)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(4),B(4)
      SAVE
C INTRP2 IS A 4-POINT LAGRANGIAN INTERPOLATION SCHEME WITHOUT DERIVATIVES
      A43 = A(4) - A(3)
      A42 = A(4) - A(2)
      A41 = A(4) - A(1)
      A32 = A(3) - A(2)
      A31 = A(3) - A(1)
      A21 = A(2) - A(1)
      D1 = -A21*A31*A41
      D2 = A21*A32*A42
      D3 = -A31*A32*A43
      D4 = A41*A42*A43
      XA1 = X - A(1)
      XA2 = X - A(2)
      XA3 = X - A(3)
      XA4 = X - A(4)
      B(1) = (XA2*XA3*XA4)/D1
      B(2) = (XA1*XA3*XA4)/D2
      B(3) = (XA1*XA2*XA4)/D3
      B(4) = (XA1*XA2*XA3)/D4
      RETURN
      END

