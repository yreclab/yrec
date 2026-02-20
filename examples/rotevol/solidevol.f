C MHP 6/19 ADDED SM TO CALL
      SUBROUTINE SOLIDEVOL(INUMT,NM,SAGE,SI,STAUCZ,EXCEN,EXW,
     *                  FCEN,FK2,FSTRUCT,SWE,SJ,SPROT,SMCZ,SM)
      IMPLICIT REAL*8 (A-H, O-Z)
      IMPLICIT LOGICAL*4 (L)
      PARAMETER(NTRACK=40,NMOD=20000)
C MHP 6/19 ADDED J TO M OPTION
C USER PARAMETERS, WIND LAW
      COMMON/PARAM/LSOLID,IWIND,PMMA,PMMB,PMMC,PMMM,SOLJDOT,SOLMDOT,FK,
     *             PDISK,TDISK,TAUCOUPLE,WCRIT,LROSS,SJTOM,LJTOM
C SOLAR UNITS IN CGS, USED FOR LOSS LAW
C SOLAR MASS, RADIUS, LUMINOSITY, SURFACE P, OVERTURN TIMESCALE (CGS),
C ANGULAR VELOCITY(RAD/S)
      COMMON/SOLAR/ SOLM,SOLR,SOLL,SOLP,SOLTAU,SOLW
C SOLAR CALIBRATION OPTION
      COMMON/SOLCAL/SOLAGE,LCALSOL
C PHYSICAL CONSTANTS
C G (CGS), 2/3, SECONDS IN YEAR, SECONDS IN DAY
      COMMON/CONST/CG,CC23,CPI,CSECYR,CSECDAY
C INPUTS FROM TRACKS - CGS OR SOLAR UNITS AS NOTED
C SAGE = AGE (YR), SI = CGS MOMENT OF INERTIA TOTAL
C STAUCZ = CONVECTIVE OVERTURN TIMESCALE (SEC)
      REAL*8 SAGE(NTRACK,NMOD),SI(NTRACK,NMOD),STAUCZ(NTRACK,NMOD),
     *       FSTRUCT(NTRACK,NMOD),FCEN(NTRACK,NMOD),FK2,
     *       FSTRUCT0(NMOD),FK0,SMCZ(NTRACK,NMOD),SM(NTRACK,NMOD)
C SPLINE INTERPOLATION VECTORS
      REAL*8 X(NMOD),Y(NMOD),YI(NMOD),YSTR(NMOD),YTAU(NMOD),YCEN(NMOD)
C NM = VECTOR OF TRACK LENGTHS
      INTEGER*4 NM(NTRACK),ICOUNT
      LOGICAL*4 LCORE,LDISK,LSOL,LDONE
C OUTPUT VECTORS - CGS UNITS
C SWE = OMEGA(ENV), SJ= TOTAL J SPROT = SURFACE PERIOD (DAYS)
      REAL*8 SWE(NTRACK,NMOD),SJ(NTRACK,NMOD),SPROT(NTRACK,NMOD)
      SAVE
C RUN THROUGH ALL MASS TRACKS AND COMPUTE ANGULAR MOMENTUM EVOLUTION FOR ALL
      DO I = 1,INUMT
         JJ = NM(I)
         IF(JJ.LT.2)GOTO 110
C INITIALIZE TORQUE
C THE LOSS LAW HAS THE GENERAL FORM
C DJ/DT = FSTRUCT*OMEGA^EXW, OMEGA < OMEGA(CRIT);
C DJ/DT = FSTRUCT*OMEGA*OMEGA(CRIT)^(EXW-1) OTHERWISE
C (N.B. CENTRIFUGAL TERM FOR PMM LAW, SEE BELOW)
C FOR A ROSSBY SCALING THE SATURATION CRITERION IS
C OMEGA * TAU(CZ)/ TAU(CZ) SUN < OMEGA(CRIT)(SUN)
C THE CODE EVOLVES ACROSS A SINGLE STEP USING A 
C BURLICH-STORER INTEGRATOR AND SPLINE INTERPOLATION
C ACROSS A STEP.
C BEGIN BY SETTING UP SPLINE INTERPOLATION IN THE STRUCTURE
C VARIABLES FOR THE WIND LOSS, ITOT, AND OVERTURN TIMESCALE.
         DO II = 1,JJ
            X(II) = SAGE(I,II)
            Y(II) = SI(I,II)
         END DO
C SPLINE FACTORS FOR MOMENT OF INERTIA YI=D^2 I_TOT / DT^2
         CALL SPLINC(X,Y,YI,JJ)
         IF(IWIND.NE.1)THEN
            DO II = 1,JJ
               Y(II) = FSTRUCT(I,II)
            END DO
C SPLINE FACTORS FOR LOSS TERM INDEPENDENT OF OMEGA
            CALL SPLINC(X,Y,YSTR,JJ)
            DO II = 1,JJ
               Y(II) = FCEN(I,II)
            END DO
C SPLINE FACTOR FOR CENTRIFUGAL TERM IN PMM WIND LAW
            CALL SPLINC(X,Y,YCEN,JJ)
         ENDIF
         IF(LROSS)THEN
            DO II = 1,JJ
               Y(II) = STAUCZ(I,II)
            END DO
C SPLINE FACTORS FOR OVERTURN TIMESCALE
            CALL SPLINC(X,Y,YTAU,JJ)
         ENDIF
         IF(LCALSOL)THEN
            LSOL = .FALSE.
            LDONE = .FALSE.
            FK0 = FK
            ICOUNT = 1
            DO II = 1,JJ
               FSTRUCT0(II)=FSTRUCT(I,II)
            END DO
         ENDIF
 10      CONTINUE
C INITIALIZE ANGULAR MOMENTUM
C MHP 6/19 ADD J TO M OPTION
         IF(.NOT.LJTOM)THEN
            SWE(I,1)=2.0D0*CPI/CSECDAY/PDISK
            SJ(I,1) = SWE(I,1)*SI(I,1)
            SPROT(I,1) = PDISK
         ELSE
            SJ(I,1) = SJTOM*SOLM*SM(I,1)
            SWE(I,1) = SJ(I,1)/SI(I,1)
            SPROT(I,1) = 2.0D0*CPI/CSECDAY/SWE(I,1)
C            WRITE(*,*)SM(I,1),SJTOM,sj(i,1),swe(i,1),SPROT(I,1)
         ENDIF
C INITIALIZE DISK AND DISK LIFETIME IN GYR
         LDISK = .TRUE.
         TAUDISK = 1.0D-3*TDISK
C GENERAL LOOP FOR ANGULAR MOMENTUM EVOLUTION CALCULATIONS
         DO J = 2,JJ
C MODELS START WITH STAR-DISK COUPLING.  EVOLVE AT
C FIXED OMEGA UNTIL DISK AGE REACHED.  IF NO DISK COUPLING
C IS CHOSEN THE MODEL WILL EVOLVE FROM THE STARTING PERIOD.
            IF(LDISK)THEN
               IF(SAGE(I,J).LE.TAUDISK)THEN
C MHP 6/19 ADDED J TO M OPTION
C DISK LOCKED TO INITIAL ROTATION RATE
                  IF(.NOT.LJTOM)THEN
                     SWE(I,J)=2.0D0*CPI/CSECDAY/PDISK
                     SJ(I,J) = SWE(I,J)*SI(I,J)
                     SPROT(I,J) = PDISK
                  ELSE
C CONSTANT J TO M ENFORCED
                     SJ(I,J) = SJTOM*SOLM*SM(I,J)
                     SWE(I,J) = SJ(I,J)/SI(I,J)
                     SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J)
                  ENDIF
                  GOTO 100
               ELSE
C DISK DECOUPLES
                  LDISK = .FALSE.
                  FX = (TAUDISK-SAGE(I,J-1))/(SAGE(I,J)-SAGE(I,J-1))
                  T0 = TAUDISK
C SPLINE INTERPOLATE TO TOTAL I AT DECOUPLING EPOCH
C INTERPOLATE BETWEEN POINTS J AND J-1 FOR STRUCTURE VARIABLES
                  HH = SAGE(I,J)-SAGE(I,J-1)
                  A = (SAGE(I,J)-T0)/HH
                  B = (T0-SAGE(I,J-1))/HH
                  SII = A*SI(I,J-1)+B*SI(I,J)+
     *                  ((A**3-A)*YI(J-1)+(B**3-B)*YI(J))*(HH**2)/6.0D0
C                  SII = SI(I,J-1)+FX*(SI(I,J)-SI(I,J-1))
C MHP 6/19 ADDED J TO M OPTION
                  IF(.NOT.LJOTM)THEN            
                     SJ(I,J) = SWE(I,J-1)*SII
                     SWE(I,J) = SJ(I,J)/SI(I,J)
                     SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J)
                     SJ0 = SJ(I,J)
                  ELSE
                     SJ(I,J) = SJTOM*SOLM*SM(I,J)
                     SWE(I,1) = SJ(I,J)/SII
                     SPROT(I,1) = 2.0D0*CPI/CSECDAY/SWE(I,J)
                     SJ0 = SJ(I,J)
                  ENDIF
               ENDIF
            ELSE
               SJ0 = SJ(I,J-1)
               T0 = SAGE(I,J-1)
            ENDIF
            T1 = SAGE(I,J)
C NO LOSS SOLID BODY CASE
C MHP ALSO SKIP WINDS IF CZ IS LESS THAN A CRITICAL THRESHOLD IN MASS
            IF(IWIND.EQ.1 .OR. SMCZ(I,J).LT.1.0D-10)THEN
               SJ(I,J)=SJ(I,J-1)
               SWE(I,J) = SJ(I,J)/SI(I,J)
               SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J)
               GOTO 100
            ENDIF
C EVOLVE FROM TIME T0 TO TIME T1 INCLUDING WIND TORQUE.
C STAR CONSERVES ANGULAR MOMENTUM AND SPINS UP
C EVALUATE MAXIMUM TIMESTEP
C LIMIT TIMESTEP BASED ON ANGULAR MOMENTUM LOSS
C START OF TIMESTEP RATE
C FC = CENTRIFUGAL TERM, PMM
            FC0=(FK2/(FK2**2 + SWE(I,J-1)**2*FCEN(I,J-1))**0.5D0)**EXCEN
C            DJDT0A = FC0*FSTRUCT(I,J-1)*SWE(I,J-1)**EXW
            SWE(I,J)=SWE(I,J-1)*SI(I,J-1)/SI(I,J)
C END OF TIMESTEP RATE INCLUDING STRUCTURAL EVOLUTION
            FC1 = (FK2/(FK2**2+SWE(I,J)**2*FCEN(I,J))**0.5D0)**EXCEN
C            DJDT1A = FC1*FSTRUCT(I,J)*SWE(I,J)**EXW
            IF(LROSS)THEN
               IF(IWIND.EQ.3)THEN
                  W0 = SWE(I,J-1)*STAUCZ(I,J-1)/SOLTAU
                  WC0 = WCRIT
                  W1 = SWE(I,J)*STAUCZ(I,J)/SOLTAU
                  WC1 = WCRIT
               ELSE IF(IWIND.EQ.2)THEN
                  W0 = SWE(I,J-1)
                  WC0 = WCRIT*SOLTAU/STAUCZ(I,J)
                  W1 = SWE(I,J)
                  WC1 = WCRIT*SOLTAU/STAUCZ(I,J)
               ENDIF
            ELSE
               W0 = SWE(I,J-1)
               WC0 = WCRIT
               W1 = SWE(I,J)
               WC1 = WCRIT
            ENDIF
C SATURATION ACCOUNTED FOR - START OF TIMESTEP
            DJDT0 = FC0*FSTRUCT(I,J-1)*SWE(I,J-1)*
     *              MIN(W0,WC0)**(EXW-1.0D0)
C SATURATION ACCOUNTED FOR - END OF TIMESTEP
            DJDT1 = FC1*FSTRUCT(I,J)*SWE(I,J)*
     *              MIN(W1,WC1)**(EXW-1.0D0)
            DJDT = MAX(DJDT0,DJDT1)
            SJ(I,J)=SJ(I,J-1)
C LIMIT TIMESTEP TO A MAXIMUM FRACTION OF THE ANGULAR MOMENTUM
C REMOVED FROM THE STAR, ASSUMING THE HIGHEST RATE
            IF (DJDT.GT.0.0D0)THEN
               TMAX = 0.1D0*SJ(I,J)/DJDT
            ELSE
               WRITE(*,111)I,J,SJ(I,J),SWE(I,J),DJDT,FSTRUCT(I,J-1),
     *         FSTRUCT(I,J),SI(I,J-1),SI(I,J),EXW
 111           FORMAT('ERROR IN LOSS RATE SOLIDEVOL'2I5,1P8E12.4)
               STOP
            ENDIF
            DT = (T1-T0)
C            WRITE(*,211)I,J,TMAX,DT,SJ0,SJ(I,J),SJ(I,J-1),
C     *                SWE(I,J-1),SWE(I,J)
C 211        FORMAT(2I5,1P7E12.4)
            IF(DT.GT.TMAX)THEN
               KK = INT(DT/TMAX)+1
               DTT = DT/FLOAT(KK)
            ELSE
               KK = 1
               DTT = DT
            ENDIF
C LOOP FOR TORQUE CALCULATION
C            SJ0 = SJ(I,J-1) SET ABOVE WHEN LDISK FLIPPED
            DO K = 1,KK
C CHECK IF SOLAR AGE REACHED FOR SOLAR CALIBRATION
               IF(LCALSOL)THEN
                  TESTT=T0+DTT
                 IF(TESTT.GE.SOLAGE)THEN
                     DTT = SOLAGE-T0
                     LDONE = .TRUE.
                  ENDIF
               ENDIF
C USE A B-S INTERGRATOR WITH SPLINE INTERPOLATION TO SOLVE FOR ANGULAR MOMENTUM LOSS 
C ACROSS THE TIMESTEP.  NUMERICAL CONVERGENCE PROPERTIES ARE CURRENTLY HARDWIRED IN 
C BSSTEP, TO BE REPLACED WITH USER-SPECIFIED PARAMETERS.
               CALL INT1ZONE(SAGE,SI,FSTRUCT,STAUCZ,YI,YSTR,YTAU,SJ0,SJ1,
     *                     I,J,T0,DTT,EXCEN,EXW,FCEN,FK2,YCEN)
               T0 = T0+DTT
               SJ0 = SJ1
            IF(LDONE)THEN
C INTERPOLATE BETWEEN POINTS J AND J-1 FOR SOLAR I
               HH = SAGE(I,J)-SAGE(I,J-1)
               A = (SAGE(I,J)-SOLAGE)/HH
               B = (SOLAGE-SAGE(I,J-1))/HH
               SOLI = A*SI(I,J-1)+B*SI(I,J)+
     *         ((A**3-A)*YI(J-1)+(B**3-B)*YI(J))*(HH**2)/6.0D0
               WSOLMOD = SJ1/SOLI
               WCHECK = LOG10(SOLW) - LOG10(WSOLMOD)
               IF(ABS(WCHECK).LT.1.0D-4)THEN
                  LSOL = .TRUE.
                  WRITE(*,20)FK,LSOLID,IWIND,PMMA,PMMB,PMMC,PMMM,
     *                       PDISK,TDISK,TAUCOUPLE,WCRIT,LROSS
 20               FORMAT('SOLAR MODEL CONVERGED.  PARAMETERS FK ',F10.5,
     *            'LSOLID ',L2,' IWIND ',I2,' PMMA ',F8.3,' PMMB ',F8.3,   
     *            ' PMMC ',F8.3,' PMMM ',F8.3,' PDISK ',F8.3,' TDISK ',
     *            E12.4,' TAUCOUPLE ',E12.4,' WCRIT ',E12.4,' LROSS ',
     *            L2)
                  GOTO 120
               ELSE
                  IF(ICOUNT.EQ.1)THEN
                     WPREV = LOG10(WSOLMOD)
                     DFK=FK0*0.1D0
                     FK = FK+DFK
                  ELSE IF(ICOUNT.EQ.2)THEN
                     DW=LOG10(WSOLMOD)-WPREV
                     DFK = LOG10(FK)-LOG10(FK0)
                     DWDFK=DW/DFK
                     DFK = 0.5D0*WCHECK/DWDFK
                     FK = FK*10**DFK
                  ELSE IF(ICOUNT.LT.10)THEN
                     DFK = 0.5D0*WCHECK/DWDFK                    
                     FK = FK*10**DFK
                  ELSE IF(ICOUNT.LT.100)THEN
                     DFK = 0.25D0*WCHECK/DWDFK                    
                     FK = FK*10**DFK
                  ELSE                     
                     WRITE(*,40)ICOUNT,FK,WSOLMOD,WCHECK
 40                  FORMAT('FAILED TO CONVERGE IN ',I3,' ITERATIONS.',
     *               ' FK ',E12.4,' SOLAR W ',E12.4,' DELTA W ',E12.4)
                     STOP
                  ENDIF
                  WRITE(*,30)ICOUNT,FK,SOLW,WSOLMOD,WCHECK
 30               FORMAT('SOLAR CALIBRATION ITERATION, FK, SOLAR W, ',
     *            ' CURRENT W, DELTA W',I5,1P4E12.4)
                  ICOUNT = ICOUNT+1
                  LDONE = .FALSE.
                  DO II = 1,JJ
                     FSTRUCT(I,II)=FK/FK0*FSTRUCT0(II)
                  END DO
                  DO II = 1,JJ
                     Y(II) = FSTRUCT(I,II)
                  END DO
C SPLINE FACTORS FOR LOSS TERM INDEPENDENT OF OMEGA
                  CALL SPLINC(X,Y,YSTR,JJ)
                  GOTO 10
               ENDIF
            ENDIF
            END DO
 95         CONTINUE
            SJ(I,J) = SJ1
            SWE(I,J)=SJ(I,J)/SI(I,J)
            SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J) 
 100        CONTINUE
         END DO
 110     CONTINUE
      END DO
 120  CONTINUE
      RETURN
      END
