C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SURFBC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SURFBC(TRIT,TRIL,CFENV,PS,TS,RS,FTRI,ISTORE,ESTORE,
     *       LNEW,LRESET,LSBC,KSAHA,KENV,KATM,HSTOT,BL,
     *       TEFFL,X,Z,FPL,FTL,LFLP,PLIM,LC,M)

      use params, only : json
      use settings, only : ISHORT  ! /LUOUT/
      use settings, only : LSTORE, LSTENV  ! /CCOUT/
      use settings, only : NPENV  ! /CCOUT1/
      use settings, only : TRIDT, TRIDL, LNEW0  ! /CENV/
      use settings, only : STOTAL  ! /COMP/
      use settings, only : CLSUNL  ! /CONST/
      use settings, only : CLN, C4PIL  ! /CONST1/
      use settings, only : CSIGL, CGL  ! /CONST2/
      use settings, only : KTTAU, KTTAU0, LTTAU  ! /ATMOS/

C INPUTS   LNEW = .T.    START UP WITH 3 NEW ENVELOPES ABOUT(TEFFL,BL)
C INPUTS   LRESET = .T.  REDO ALL 3 ENVELOPES AND RETRIANGULATE IF NEED
C BOTH LNEW AND LRESET ARE RESET TO .FALSE.
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION LTRI(3),TRIT(3),TRIL(3),CFENV(9),PS(3),TS(3),RS(3),
     *     ESTORE(4),LC(JSON)
      COMMON /ALATM05/ AL_TEFFLmin,AL_TEFFLmax

      DATA NUMENV/0/

C G Somers 10/14, Add spot common block
      COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH
C G Somers END

      SAVE
C MHP 9/01
      IF(KTTAU .EQ. 3) THEN
         IF(TEFFL.GE. 3.95D0) THEN
            write(*,*)
            WRITE(*,5) TEFFL
 5          FORMAT('LOG TEFF OF ',F7.3,' ABOVE 3.95 - SWITCH'
     *             ,'TO GRAY ATMOSPHERE BOUNDARY CONDITION')
            write(*,*)
            KTTAU = 0
            LNEW = .TRUE.
C MHP 06/13 Remember that flag is switched
            LTTAU = .TRUE.
         ENDIF
      ENDIF
      IF(KTTAU. EQ. 4) THEN
         IF(TEFFL.GE. AL_TEFFLmax) THEN
            write(*,*)
            WRITE(*,7) TEFFL,AL_TEFFLmax
 7          FORMAT('LOG TEFF OF ',F7.3,' ABOVE Allard Table max ',F7.3
     *             ,'  - SWITCH TO GRAY ATMOSPHERE BOUNDARY CONDITION')
            write(*,*)
            KTTAU = 0
            LNEW = .TRUE.
C MHP 06/13 Remember that flag is switched
            LTTAU = .TRUE.
         ENDIF
      ENDIF
      IF(LTTAU)THEN
         IF(KTTAU0.EQ.3.AND.TEFFL.LT.3.95D0)THEN
            KTTAU = KTTAU0
            LTTAU = .FALSE.
            WRITE(*,9) TEFFL
 9          FORMAT('LOG TEFF OF ',F7.3,' BELOW 3.95 - SWITCH'
     *      ,' BACK TO KURUCZ ATMOSPHERE BOUNDARY CONDITION')
         ELSE IF(KTTAU0.EQ.4.AND.TEFFL.LT.AL_TEFFLmax)THEN
            KTTAU = KTTAU0
            LTTAU = .FALSE.
            WRITE(*,11) TEFFL,AL_TEFFLmax
 11         FORMAT('LOG TEFF OF ',F7.3,' below Allard Table max ',F7.3
     *     ,'  - SWITCH BACK TO ALLARD ATMOSPHERE BOUNDARY CONDITION')
         ENDIF
      ENDIF
      LFLP = .FALSE.
C IF LNEW0, REDO ALL 3 ENVELOPES EVERY MODEL
      IF(LNEW.OR.LRESET) THEN
C REDO ALL THREE ENVELOPES
       LTRI(1) = .FALSE.
       LTRI(2) = .FALSE.
       LTRI(3) = .FALSE.
       ISTORE = 0
       TRIERR = 0.0D0
       LRESET = .FALSE.
      ELSE
       LTRI(1) = .TRUE.
       LTRI(2) = .TRUE.
       LTRI(3) = .TRUE.
       TRIERR = 0.0D0
      ENDIF
      IF(LNEW) THEN
C STARTING PROCEDURE
       FTRI = +1.0D0
       TRIT(3) = TEFFL
       TRIT(1) = TRIT(3) - 0.5D0*TRIDT
       TRIT(2) = TRIT(1) + TRIDT
       TRIL(3) = BL + 0.5D0*TRIDL
       TRIL(1) = TRIL(3) - TRIDL
       TRIL(2) = TRIL(1)
       LNEW = .FALSE.
      ELSE
C CHECK TRIANGULATION OF POINT (TEFFL,BL)
 10      CONTINUE
       DO 20 I1 = 1,3
          I2 = MOD(I1,3) + 1
          I3 = MOD(I2,3) + 1
          TEMP = FTRI*((TRIL(I2)-TRIL(I3))*(TEFFL-TRIT(I2)) +
     *           (TRIT(I3)-TRIT(I2))*(BL  -TRIL(I2)) )
          IF(TEMP.LT.-TRIERR) THEN
             FTRI = -FTRI
             TRIT(I1) = TRIT(I2) + TRIT(I3) - TRIT(I1)
             TRIL(I1) = TRIL(I2) + TRIL(I3) - TRIL(I1)
             LTRI(I1) = .FALSE.
             TRIERR = 0.0D0
             GOTO 10
          ENDIF
 20      CONTINUE
      ENDIF
C COMPUTE NEW ENVELOPES IF NECESSARY
      LRENV = .FALSE.
      DO 40 I = 1,3
       IF(.NOT.LTRI(I)) THEN
C NEW ENVELOPE NEEDED
          LFLP = .TRUE.
          TEFFL = TRIT(I)
          B = DEXP(CLN*TRIL(I))
          RL = 0.5D0*(TRIL(I) + CLSUNL - 4.0D0*TEFFL - C4PIL - CSIGL)
          GL = CGL + STOTAL - RL - RL
          NUMENV = NUMENV + 1
C G Somers 11/14, LPENV FUNCTIONALITY NOW INCLUDED IN LSTENV.
            LPENV = .FALSE.
C          LPENV = MOD(NUMENV,NPENV).EQ.0
C          IF(.NOT.LSTORE) LPENV = .FALSE.
C          IF(LPENV) THEN
C             WRITE(ISHORT,30) I,TRIT(I),TRIL(I)
C 30            FORMAT(/,' NEW ENVELOPE NO.',I2,' LOG(TE) =',F9.5,
C     *              '  LOG(L) =',F8.5)
C          ENDIF
C G Somers END
          IXX=I
          LSBC0 = .TRUE.
C DBG PULSE: DO NOT DO PULSE OUTPUT
            LPULPT = .FALSE.
C G Somers 10/14, FOR SPOTTED RUNS, FIND THE
C PRESSURE AT THE AMBIENT TEMPERATURE ATEFFL
          IF(LC(M).AND.SPOTF.NE.0.0.AND.SPOTX.NE.1.0)THEN
               ATEFFL = TEFFL - 0.25*LOG10(SPOTF * SPOTX**4.0 + 1.0 - SPOTF)
          ELSE
             ATEFFL = TEFFL
          ENDIF
          CALL ENVINT(B,FPL,FTL,GL,HSTOT,IXX,LPENV,LSBC0,PLIM,RL,
     *           ATEFFL,X,Z,ESTORE,ISTORE,KATM,KENV,KSAHA,PS,
     *           RS,TS,LPULPT)
C G Somers END
          LRENV = .TRUE.
       ENDIF
 40   CONTINUE
      IF(LRENV) THEN
C RECOMPUTE COEFFICIENTS
       TEMP = 1.0D0/(TS(2)-TS(1))
       TEMP1 = (TS(3)-TS(1))*TEMP
       TEMP2 = 1.0D0/(PS(3)-PS(1)-TEMP1*(PS(2)-PS(1)))
       CFENV(1) = (  RS(3)-  RS(1)-TEMP1*(  RS(2)-  RS(1)))*TEMP2
       CFENV(4) = (TRIL(3)-TRIL(1)-TEMP1*(TRIL(2)-TRIL(1)))*TEMP2
       CFENV(7) = (TRIT(3)-TRIT(1)-TEMP1*(TRIT(2)-TRIT(1)))*TEMP2
       CFENV(2) = (  RS(2)-  RS(1)-CFENV(1)*(PS(2)-PS(1)))*TEMP
       CFENV(5) = (TRIL(2)-TRIL(1)-CFENV(4)*(PS(2)-PS(1)))*TEMP
       CFENV(8) = (TRIT(2)-TRIT(1)-CFENV(7)*(PS(2)-PS(1)))*TEMP
       CFENV(3) =   RS(1) - CFENV(1)*PS(1) - CFENV(2)*TS(1)
       CFENV(6) = TRIL(1) - CFENV(4)*PS(1) - CFENV(5)*TS(1)
       CFENV(9) = TRIT(1) - CFENV(7)*PS(1) - CFENV(8)*TS(1)
       WRITE(ISHORT,50)(I,LTRI(I),TRIT(I),TRIL(I),PS(I),TS(I),RS(I),
     *        (CFENV(I+I+I-3+J),J=1,3), I=1,3)
 50      FORMAT(' ENVELOPE TRIANGLE  LOG(TE)  LOG(L)   LOG(P)   LOG(T)',
     *        3X,'LOG(R)   COEFFICIENTS'/I14,L1,2X,5F9.5,8X,'LOG(R)',
     *        3F10.5/ I14,L1,2X,5F9.5,5X,'LOG(L/L0)',3F10.5/
     *        I14,L1,2X,5F9.5,7X,'LOG(TE)',3F10.5)
 60      FORMAT(' COUNTS  KATM',I5,'  KENV',I5,'  KSAHA',I5)
      ELSE
       WRITE(ISHORT,70)
 70      FORMAT(' ENVELOPE TRIANGLE NOT CHANGED')
      ENDIF
      RETURN
      END
