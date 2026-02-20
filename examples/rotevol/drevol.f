C ANGULAR MOMENTUM EVOLUTION UNDER THE ASSUMPTION OF THE SILLS ET AL. 2000 JDOT
      SUBROUTINE DREVOL(INUMT,NM,SAGE,SI,SIE,SIC,STAUCZ,EXCEN,EXW,
     *     SRCZ,SMCZ,FCEN,FK2,FSTRUCT,FCZ,SWC,SWE,SJ,SJC,SJE,SPROT)
      IMPLICIT REAL*8 (A-H, O-Z)
      IMPLICIT LOGICAL*4 (L)
      PARAMETER(NTRACK=40,NMOD=20000)
C USER PARAMETERS, WIND LAW
c mhp 6/19 ADDED CONSTANT J TO M OPTION
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
C SAGE = AGE (YR), SL = L/LSUN SR = R/RSUN SM = M/MSUN
C SRCZ = R OF CZ BASE (CGS) SMCZ = MASS OF SURFACE CZ, MSUN
C SI, SIE, SIC = CGS MOMENT OF INERTIA TOTAL, CORE, ENVELOPE
C STAUCZ = CONVECTIVE OVERTURN TIMESCALE (SEC), SP = ATM PRESSURE TAU=2/3
C SXC = CENTRAL X SHEC= POST-MS HE CORE MASS (MSUN), BOTH USED FOR ISOCHRONES
      REAL*8 SAGE(NTRACK,NMOD),SI(NTRACK,NMOD),SIE(NTRACK,NMOD),
     *       SIC(NTRACK,NMOD),STAUCZ(NTRACK,NMOD),EXCEN,EW,
     *       FSTRUCT(NTRACK,NMOD),FCZ(NTRACK,NMOD),FK2,
     *       SRCZ(NTRACK,NMOD),SMCZ(NTRACK,NMOD),FCEN(NTRACK,NMOD),
     *       FSTRUCT0(NMOD),FK0
C SPLINE INTERPOLATION VECTORS
      REAL*8 X(NMOD),Y(NMOD),YI(NMOD),YIE(NMOD),YSTR(NMOD),YTAU(NMOD),
     *       YCZ(NMOD),YCEN(NMOD)
C NM = VECTOR OF TRACK LENGTHS
      INTEGER*4 NM(NTRACK),ICOUNT
      LOGICAL*4 LCORE,LDISK,LOK,LSOL,LDONE
C OUTPUT VECTORS - CGS UNITS
C SWE = OMEGA(ENV), SWC = OMEGA(CORE), SJ= TOTAL J SJE = ENVELOPE J
C SJC = CORE J SPROT = SURFACE PERIOD (DAYS)
      REAL*8 SWE(NTRACK,NMOD),SWC(NTRACK,NMOD),SJ(NTRACK,NMOD),
     * SJE(NTRACK,NMOD),SJC(NTRACK,NMOD),SPROT(NTRACK,NMOD)
      SAVE
C RUN THROUGH ALL MASS TRACKS AND COMPUTE ANGULAR MOMENTUM EVOLUTION FOR ALL
      DO I = 1,INUMT
         JJ = NM(I)
         IF(JJ.LT.2)GOTO 110
C SET UP SPLINE INTERPOLATION IN THE STRUCTURE 
C VARIABLES FOR WIND LOSS, ITOT AND OVERTURN TIMESCALE (GENERAL CASE)
C ALSO IENV, 2/3 RCZ^2 * DMCZ/DT (FOR THE DECOUPLED CASE)
         DO II = 1,JJ
            X(II) = SAGE(I,II)
            Y(II) = SI(I,II)
         END DO
C SPLINE FACTORS FOR MOMENT OF INERTIA
         CALL SPLINC(X,Y,YI,JJ)
         IF(IWIND.NE.1)THEN
            DO II = 1,JJ
               Y(II) = FSTRUCT(I,II)
            END DO
C SPLINE FACTORS FOR WIND LOSS TERMS
            CALL SPLINC(X,Y,YSTR,JJ)
            IF(LROSS)THEN
               DO II = 1,JJ
                  Y(II) = STAUCZ(I,II)
               END DO
C SPLINE FACTORS FOR OVERTURN TIMESCALE
               CALL SPLINC(X,Y,YTAU,JJ)
            ENDIF
C CENTRIFUGAL TERM FROM PMM WIND LAW            
            DO II = 1,JJ
               Y(II) = FCEN(I,II)
            END DO
C SPLINE FACTORS FOR WIND LOSS TERMS
            CALL SPLINC(X,Y,YCEN,JJ)
         ENDIF
C SET UP SPLINE INTERPOLATION IN ENVELOPE I, 2/3RCZ^2*DMCZ/DT 
C FOR THE DECOUPLED CASE.
         DO II = 1,JJ
            Y(II) = SIE(I,II)
         END DO
C SPLINE FACTORS FOR ENVELOPE MOMENT OF INERTIA
         CALL SPLINC(X,Y,YIE,JJ)
         DO II = 1,JJ
            Y(II) = FCZ(I,II)
         END DO
C SPLINE FACTORS FOR CHANGE IN CZ DEPTH TERM
         CALL SPLINC(X,Y,YCZ,JJ)
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
         SWC(I,1)=2.0D0*CPI/CSECDAY/PDISK
         SWE(I,1) = SWC(I,1)
         SJ(I,1) = SWE(I,1)*SI(I,1)
         SJE(I,1) = SWE(I,1)*SIE(I,1)
         SJC(I,1) = SWC(I,1)*SIC(I,1)
         SPROT(I,1) = PDISK
C INITIALIZE DISK AND DISK LIFETIME IN GYR
         LDISK = .TRUE.
         TAUDISK = 1.0D-3*TDISK
         DO J = 2,JJ
            IF(LDISK)THEN
               IF(SAGE(I,J).LE.TAUDISK)THEN
C DISK LOCKED TO INITIAL ROTATION RATE
                  SWC(I,J)=2.0D0*CPI/CSECDAY/PDISK
                  SWE(I,J) = SWC(I,J)
                  SJ(I,J) = SWE(I,J)*SI(I,J)
                  SJE(I,J) = SWE(I,J)*SIE(I,J)
                  SJC(I,J) = SWC(I,J)*SIC(I,J)
                  SPROT(I,J) = PDISK
                  GOTO 100
               ELSE
C DISK DECOUPLES
                  LDISK = .FALSE.
C SPLINE INTERPOLATE TO TOTAL I AT DECOUPLING EPOCH
C INTERPOLATE BETWEEN POINTS J AND J-1 FOR STRUCTURE VARIABLES
                  HH = SAGE(I,J)-SAGE(I,J-1)
                  T0 = TAUDISK
                  A = (SAGE(I,J)-T0)/HH
                  B = (T0-SAGE(I,J-1))/HH
                  SII = A*SI(I,J-1)+B*SI(I,J)+
     *                  ((A**3-A)*YI(J-1)+(B**3-B)*YI(J))*(HH**2)/6.0D0
                  SJ(I,J) = SWE(I,J-1)*SII
                  SWE(I,J)=SJ(I,J)/SI(I,J)
                  SWC(I,J)=SWE(I,J)
                  SJE(I,J) = SWE(I,J)*SIE(I,J)
                  SJC(I,J) = SWC(I,J)*SIC(I,J)
                  SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J)
                  SJE0 = SJE(I,J)
                  SJC0 = SJC(I,J)
                  SJ0 = SJE0 + SJC0
C                  WRITE(*,91)I,J,T0,SII,SJ(I,J),SWE(I,J),SJE(I,J)
C 91               FORMAT(2I5,1P5E12.4)
               ENDIF
            ELSE
               SJE0 = SJE(I,J-1)
               SJC0 = SJC(I,J-1)
               SJ0 = SJ(I,J-1)
               T0 = SAGE(I,J-1)
            ENDIF
            T1 = SAGE(I,J)
            TMAX = T1-T0
C EVOLVE FROM TIME T0 TO TIME T1 INCLUDING WIND TORQUE IF APPLICABLE
            IF(IWIND.NE.1 .AND. SMCZ(I,J).GE.1.0D-10)THEN
C EVALUATE MAXIMUM TIMESTEP ASSUMING ONLY THE CZ SPINS DOWN
C START OF TIMESTEP RATE
               FC0 = (FK2/(FK2**2 + SWE(I,J-1)**2*
     *                FCEN(I,J-1))**0.5D0)**EXCEN
C               DJDT0A = FC0*FSTRUCT(I,J-1)*SWE(I,J-1)**EXW
C END OF TIMESTEP RATE
               SWE(I,J)=SJE(I,J-1)/SIE(I,J)
               FC1 = (FK2/(FK2**2+SWE(I,J)**2*FCEN(I,J))**0.5D0)**EXCEN
C               DJDT1A = FC1*FSTRUCT(I,J)*SWE(I,J)**EXW
C ACCOUNT FOR SATURATION
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
               DJDT0 = FC0*FSTRUCT(I,J-1)*SWE(I,J-1)*
     *                  MIN(W0,WC0)**(EXW-1.0D0)
               DJDT1 = FC1*FSTRUCT(I,J)*SWE(I,J)*
     *                  MIN(W1,WC1)**(EXW-1.0D0)
C CAP LOSS LAW AT SATURATED RATE IF LOWER THAN ACTUAL RATE
C               DJDT0 = MIN(DJDT0A,DJDT0B)
C               DJDT1 = MIN(DJDT1A,DJDT1B)
C CHOOSE THE LARGER OF THE START OR END VALUE TO CONSTRAIN DT
               DJDT = MAX(DJDT0,DJDT1)
               IF (DJDT.GT.0.0D0)THEN
                  TMAX = 0.1D0*SJE(I,J-1)/DJDT
               ELSE
                  WRITE(*,112)I,J,SJ(I,J-1),SJE(I,J-1),SJC(I,J-1),
     *            SWE(I,J),SWC(I,J-1),DJDT0A,DJDT1A,DJDT
 112              FORMAT('ERROR IN DECOUPLED LOSS RATE KWIND'2I5,1P8E12.4)
                  STOP
               ENDIF
C                  WRITE(*,112)I,J,SJ(I,J-1),SJE(I,J-1),SJC(I,J-1),
C     *            SWE(I,J),SWC(I,J-1),DJDT0A,DJDT1A,DJDT
            ENDIF
            SJ(I,J)=SJ(I,J-1)
C LIMIT TIMESTEP BASED ON RATE OF CHANGE OF ENVELOPE J
            DMCZ = SMCZ(I,J)-SMCZ(I,J-1)
            IF(ABS(DMCZ).GT.1.0D-9)THEN
               DJTRAN = (SRCZ(I,J-1)**2+SRCZ(I,J-1)**2)/3.0D0*
     *                   DMCZ*SOLM/(SAGE(I,J)-SAGE(I,J-1))
C DO NOT APPLY CONDITION IF RATE OF CHANGE OF CZ IS TOO SMALL.
               IF(DJTRAN.LT.0.0D0)THEN
                  DTTRAN = ABS(0.1D0*SJE(I,J-1)/(DJTRAN*SWE(I,J-1)))
               ELSE IF(DJTRAN.GT.0.0D0)THEN
                  DTTRAN = 0.1D0*SJE(I,J-1)/(DJTRAN*SWC(I,J-1))
               ENDIF
            ELSE
               DTTRAN = T1-T0
            ENDIF
C LIMIT TIMESTEP BASED ON ANGULAR MOMENTUM EXCHANGE FROM
C ENVELOPE TO CORE (OR VICE VERSA)
            IF(TAUCOUPLE.GT.0.0D0)THEN
C                  DELJMAX = SIE(I,J-1)*SIC(I,J-1)/SI(I,J-1)*
C     *                       (SWC(I,J-1)-SWE(I,J-1))
C                  DTTRAN2 = 0.25D0*SJE(I,J-1)*TAUCOUPLE*1.0D-9/ABS(DELJMAX)
               DTTRAN2 = 0.1D0*TAUCOUPLE*1.0D-9
            ELSE
               DTTRAN2 = DTTRAN
            ENDIF
            DT = (T1-T0)
            WRITE(55,201)I,J,DT,TMAX,DTTRAN,DTTRAN2
 201  FORMAT('TIMESTEP, MAX FROM DJ/DT,ENVELOPE CHANGE,TRANSPORT',
     *        2I5,1P4E12.4)
            TMAX = MIN(TMAX,DTTRAN,DTTRAN2)
            IF(DT.GT.TMAX)THEN
               KK = INT(DT/TMAX)+1
               DTT = DT/FLOAT(KK)
            ELSE
               KK = 1
               DTT = DT
            ENDIF
C LOOP FOR TORQUE CALCULATION
C CHECK AND SEE WHETHER THERE IS A RADIATIVE CORE
            IF(SIC(I,J).GT.0.0D0)THEN
               IF(SIC(I,J-1).LT.1.0D0)THEN
                  SJE0 = SJE(I,J-1)
                  SJC0 = 0.0D0
C NEWLY DEVELOPED RADIATIVE CORE.  INITIALIZE CORE ANGULAR MOMENTUM TERMS.
               ELSE
                  SJE0 = SJE(I,J-1)
                  SJC0 = SJC(I,J-1)
               ENDIF
               LCORE = .TRUE.
            ELSE IF(SIC(I,J-1).GT.0.0D0)THEN
C RADIATIVE CORE VANISHED.  MERGE ANGULAR MOMENTUM.
               LCORE = .FALSE.
            ELSE
               LCORE = .FALSE.
            ENDIF
C            WRITE(*,*)LCORE,I,J,KK,SJ(I,J-1),SJ(I,J),SJ0
            IF(LCORE)THEN
C USE A B-S INTERGRATOR WITH SPLINE INTERPOLATION TO SOLVE FOR ANGULAR MOMENTUM LOSS 
C ACROSS THE TIMESTEP.  NUMERICAL CONVERGENCE PROPERTIES ARE CURRENTLY HARDWIRED IN 
C BSSTEP, TO BE REPLACED WITH USER-SPECIFIED PARAMETERS.  
C THIS SR SOLVES FOR A 2
C ZONE MODEL INSTEAD OF A SOLID BODY MODEL.
C MHP 9/13 CHECK IF ANGULAR MOMENTUM LOSS IS INCLUDED
               IF(IWIND.EQ.1)THEN
                     LOSS = .FALSE.
               ELSE IF(SMCZ(I,J-1).LT.1.0D-10.OR.
     *                 SMCZ(I,J).LT.1.0D-10)THEN
                  LOSS = .FALSE.
               ELSE
                  LOSS = .TRUE.
               ENDIF
               DO K = 1,KK
C                  WRITE(55,78)I,J,SIC(I,J)
C 78               FORMAT('Two Zone Model int2zone',2I5,1PE12.4)
C CHECK IF SOLAR AGE REACHED FOR SOLAR CALIBRATION
                  IF(LCALSOL)THEN
                     TESTT=T0+DTT
                    IF(TESTT.GE.SOLAGE)THEN
                        DTT = SOLAGE-T0
                        LDONE = .TRUE.
                     ENDIF
                  ENDIF
                  CALL INT2ZONE(SAGE,SI,SIE,SIC,STAUCZ,FCZ,FSTRUCT,YI,
     *                  YIE,YCZ,YSTR,YTAU,SJC0,SJE0,SJC1,SJE1,I,J,T0,
     *                  DTT,EXCEN,EXW,FCEN,FK2,YCEN,LOK,LOSS)
                  IF(.NOT.LOK)THEN
                     IF(.NOT.LCALSOL)THEN
                        GOTO 100
                     ELSE
                        WRITE(*,101)
 101                    FORMAT(' SOLAR CALIBRATION MODEL FAILED TO ',
     *                         'COVERGE IN INT2ZONE.  RUN STOPPED')
                        STOP
                     ENDIF
                  ENDIF
                  T0 = T0+DTT
                  SJE0 = SJE1
                  SJC0 = SJC1
                  IF(LDONE)THEN
C INTERPOLATE BETWEEN POINTS J AND J-1 FOR SOLAR ENVELOPE I
                     HH = SAGE(I,J)-SAGE(I,J-1)
                     A = (SAGE(I,J)-SOLAGE)/HH
                     B = (SOLAGE-SAGE(I,J-1))/HH
                     SOLI = A*SIE(I,J-1)+B*SIE(I,J)+
     *              ((A**3-A)*YIE(J-1)+(B**3-B)*YIE(J))*(HH**2)/6.0D0
                     WSOLMOD = SJE1/SOLI
                     WCHECK = LOG10(SOLW) - LOG10(WSOLMOD)
                     IF(ABS(WCHECK).LT.1.0D-4)THEN
                        LSOL = .TRUE.
                        WRITE(*,20)FK,LSOLID,IWIND,PMMA,PMMB,PMMC,PMMM,
     *                             PDISK,TDISK,TAUCOUPLE,WCRIT,LROSS
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
               SJE(I,J) = SJE1
               SJC(I,J) = SJC1
               SJ(I,J) = SJE1+SJC1
               SWE(I,J) = SJE(I,J)/SIE(I,J)
               SWC(I,J) = SJC(I,J)/SIC(I,J)
               SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J)                                 
            ELSE
               DO K = 1,KK
C USE A B-S INTERGRATOR WITH SPLINE INTERPOLATION TO SOLVE FOR ANGULAR MOMENTUM LOSS 
C ACROSS THE TIMESTEP.  NUMERICAL CONVERGENCE PROPERTIES ARE CURRENTLY HARDWIRED IN 
C BSSTEP, TO BE REPLACED WITH USER-SPECIFIED PARAMETERS.  
C                  WRITE(55,79)I,J
C 79               FORMAT('Fully Convective or Radiative int1zone',2I5)
                  CALL INT1ZONE(SAGE,SI,FSTRUCT,STAUCZ,YI,YSTR,YTAU,SJ0,
     *                 SJ1,I,J,T0,DTT,EXCEN,EXW,FCEN,FK2,YCEN)
                  T0 = T0+DTT
                  SJ0 = SJ1
               END DO
               SJ(I,J) = SJ1
               SWE(I,J)=SJ(I,J)/SI(I,J)
               SWC(I,J)=SWE(I,J)
               SJE(I,J) = SWE(I,J)*SIE(I,J)
               SJC(I,J) = SWC(I,J)*SIC(I,J)
               SPROT(I,J) = 2.0D0*CPI/CSECDAY/SWE(I,J)
            ENDIF
 100        CONTINUE
         END DO
 110     CONTINUE
      END DO
 120  CONTINUE
      RETURN
      END
