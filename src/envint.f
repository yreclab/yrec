C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ENVINT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE ENVINT(B,FPL,FTL,GL,HSTOT,IE,LPRT,LSBC,PLIM,RL,TEFFL,
     *                  X,Z,ESTORE,ISTORE,KATM,KENV,KSAHA,PS,RS,TS,
     *                  LPULPT)
      use params, only : json, nt, ng, ntc, ngc, nta, nga
      use settings, only : ISHORT, ISTOR, IOWR  ! /LUOUT/
      use settings, only : IOPENV, IOPATM  ! /LUNUM/
      use settings, only : LSTATM, LSTENV  ! /CCOUT/
      use settings, only : SENV  ! /COMP/
C DBG pulse: constants needed for del and dela calculation
      use settings, only : CLSUNL, CRSUNL  ! /CONST/
      use settings, only : CLN, CC23  ! /CONST1/
      use settings, only : CGAS, CA3, CGL  ! /CONST2/
      use settings, only : CDELRL, CSECYR  ! /CONST3/
      use settings, only : TENV  ! /CTLIM/
      use settings, only : ATMERR, ATMD0, ATMBEG, ATMMIN, ATMMAX  ! /INTATM/
      use settings, only : ENVERR, ENVBEG, ENVMIN, ENVMAX  ! /INTENV/
      use settings, only : STOLR0  ! /INTPAR/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)
      REAL*8 OLAOL(12,104,52),OXA(12),OT(52),ORHO(104),TOLLAOL
      REAL*8 ENVS1(JSON),ENVS2(JSON),ENVG(JSON),EDEL1(JSON),
     * EDEL2(JSON)
      CHARACTER*256 FLAOL, FPUREZ, FATM, FALLARD

C DBG CHANGED MAXSTEP FROM 200 TO 2000 TO GIVE ATMOSPHERE INTEGRATER A CHANCE.
      PARAMETER (MAXSTP = 2000,TINY=1.0D-30)
      EXTERNAL QATM,QENV
      COMMON/NWLAOL/OLAOL, OXA, OT, ORHO, TOLLAOL,
     *  IOLAOL, NUMOFXYZ, NUMRHO, NUMT, LLAOL, LPUREZ, IOPUREZ,
     *  FLAOL, FPUREZ
      COMMON/ATMPRT/TAU,AP,AT,AD,AO,AFXION(3)
      COMMON/ENVPRT/EP,ET,ER,ES,ED,EO,EBETA,EDEL(3),EFXION(3),EVEL
      COMMON/OPTAB/OPTOL,ZSI,IDT,IDD(4)
C DBG PULSE
      COMMON/PULSE/XMSOL,LPULSE,IPVER
      COMMON/PULSE1/PQDP(JSON),PQED(JSON),PQET(JSON),
     *   PQOD(JSON), PQOT(JSON), PQCP(JSON), PRMU(JSON),
     *   PQDT(JSON),PEMU(JSON),LPUMOD
      COMMON/PULSE2/QQDP,QQED,QQET,QQOD,QQOT,QDEL,
     *      QDELA, QQCP, QRMU, QTL, QPL, QDL, QO, QOL,
     *      QT, QP, QQDT, QEMU, QD, QFS
      COMMON/ATMOS/HRAS,KTTAU,KTTAU0,LTTAU
      COMMON/MHD/LMHD,IOMHD1,IOMHD2,IOMHD3,IOMHD4,IOMHD5,IOMHD6,
     1           IOMHD7, IOMHD8
      COMMON/ATMOS2/ATMPL(NT,NG),ATMTL(NT),
     *              ATMGL(NG),ATMZ,IOATM,FATM
C JNT 6/14 ADD FOR KURUCZ/CASTELLI 2004 ATMOSPHERES
      COMMON/ATMOS2C/ATMPLC(NTC,NGC),ATMTLC(NTC),
     *              ATMGLC(NGC)
C MHP 6/97 ADDED ALLARD MODEL ATMOSPHERES
C      COMMON/ATMOS3/ATMZA,ATMPLA(NTA,NGA),
C     *ATMTLA(NTA),ATMGLA(NGA),FALLARD,IOATMA
      COMMON /ALATM03/ ALATM_FeH,ALATM_Alpha,LALTPTau100,  ! Shared: ALFILEIN,
     x       IOATMA                                         ! ALSURFP and PARMIN
      COMMON /ALATM04/ DUMMY1,DUMMY2,FALLARD,DUMMY3,DUMMY4
C DBG 7/95 To store variables for pulse output
      COMMON/PUALPHA/ALFMLT,PHMLT,CMXMLT,
     *             VALFMLT(JSON),VPHMLT(JSON),VCMXMLT(JSON)
C MHP 07/02 STORE CONTENTS OF ENVELOPE INTEGRATION INTO A
C SET OF VECTORS, WHICH ARE FLIPPED AND CONVERTED INTO AN ASCENDING
C SERIES AFTER THE INTEGRATION IS DONE.
      COMMON/ENVSTRUCT/ENVP(JSON),ENVT(JSON),ENVS(JSON),ENVD(JSON),
     *                 ENVR(JSON),ENVX(JSON),ENVZ(JSON),LCENV(JSON),
     *                 NUMENV,EDELS(3,JSON),EVELS(JSON),EBETAS(JSON)
C JVS 08/13 IF THE CZ IS BEYOND THE FITTING POINT, STORE ITS LOCATION
      COMMON/ENVCZ/ENVRCZ,RINT

C MHP 08/02 ADDED VECTOR FOR STORING THE OVERTURN TIMESCALE OF THE
C SURFACE CONVECTION ZONE
      COMMON/DEUTER/DRATE(JSON),DRATE0(JSON),FMASSACC,JCZ
      DIMENSION FXION(3),PS(3),RS(3),TS(3),ESTORE(4)
      DIMENSION Y(3),DYDX(3),YSCAL(3),YSTART(3),ERRSUM(3),ERR(3)

C JVS Acoustic depth common block
        COMMON/ACDPTH/TAUCZN,DELADJ(JSON),TAUHE, TNORM, TCZ, WHE, ICLCD,
     *ACATMR(JSON), ACATMD(JSON), ACATMP(JSON), ACATMT(JSON),TATMOS,
     *LCLCD, AGEOUT(5), IACAT, IJLAST, LJLAST, LJWRT, LADON,LAOLY, IJVS,
     *IJENT, IJDEL, LACOUT

C G Somers 3/17, ADDING NEW TAUCZ COMMON BLOCK
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP

C MHP 1/01 CHANGED END OF FILE INDICATOR IN ATMOSPHERE/ENVELOPE FILES TO
C VECTOR FROM SCALAR
      DIMENSION XYZ(22)
      DATA XYZ/22*99.99D0/
      SAVE

C DBG PULSE TURN ON DERIVATIVE CALCULATOR
      IF (LPULPT.AND.LPRT) THEN
          LPUMOD = .TRUE.
          LDERIV = .TRUE.
          LATMO = .FALSE.
      ELSE
          LPUMOD = .FALSE.
          LDERIV = .FALSE.
          LATMO = .TRUE.
      END IF
      LOCOND = .FALSE.

C JVS 10/07/13 Always calculate derivatives
      LDERIV = .TRUE.

C G Somers 11/14 WRITE ATMOSHPHERE HEADER TO .STORE FILE, AND ADDED
C I/O FLAGS TO THE ATMOSPHERE CALLS
      IF(LPRT.AND.LSTATM) WRITE(ISTOR,60)
 60   FORMAT(/,'******** ATMOSPHERE BEGIN ********')

C GET PRESSURE AT T=Teff BY INTERPOLATION IN TABLE ATMPL.
      IF (KTTAU .EQ. 3) THEN
C KURUCZ ATMOSPHERES
         CALL SURFP(TEFFL,GL,LPRT.AND.LSTATM)
         GOTO 200
C JNT 06/14
C GET PRESSURE AT T=Teff BY INTERPOLATION IN TABLE ATMPLC.
      ELSE IF (KTTAU .EQ. 5) THEN
C KURUCZ ATMOSPHERES
         CALL KCSURFP(TEFFL,GL,LPRT.AND.LSTATM)
         GOTO 200
C We have Kurucz atmosphere boundary conditions
      ELSE IF (KTTAU .EQ. 4) THEN
C ALLARD & HAUSCHILDT ATMOSPHERES
         CALL ALSURFP(TEFFL,GL,LPRT.AND.LSTATM,LAlFail)
C Changed to Allard atmosphere code
         IF(LAlFail) then
            KTTAU=0
            LTTAU = .TRUE.
C Set to gray atmosphere (KTTAU=0), as
C TeffL is above Allard max, or GL is out of range.
            WRITE(*,*) 'ENVINT: Change to gray atmosphere (KTTAU=0)'
            WRITE(ISHORT,*)'ENVINT: Change to gray atmosphere (KTTAU=0)'
            goto 2
         ENDIF
         GOTO 200
C We have Allard atmosphere boundary conditions
      ENDIF
    2 CONTINUE
C Start gray atmosphere bounary conditions
C GUESS THE TEMPERATURE FOR AN OPTICAL DEPTH NEAR ZERO.
      IDT = 15
      DO 5 JJ = 1,4
       IDD(JJ) = 5
    5 CONTINUE
      ERRSUM(1) = 0.0D0
      IF(KTTAU .EQ. 0) THEN
            TL = TEFFL - 0.031235D0 + 0.25D0*DLOG10(CC23)
      ELSE IF (KTTAU .EQ. 1) THEN
            TL = TEFFL - 0.031235D0 + 0.25D0*DLOG10(0.550D0)
      ELSE IF (KTTAU .EQ. 2) THEN
            TL = TEFFL + HRA(CC23) - HRAS
      END IF
C                 For kttau = 0,1,or 2, very occasionally the integration
C                 fails because the starting point (X0) is past the end
C                 point (XLIM). When this happens, we divide the effective
C                 starting density (atmd0) by 10 and retry.
      atmdx = atmd0
 1998 continue
C Return point if X0 > XLIM
      T = DEXP(CLN*TL)
C FIND THE PRESSURE CORRESPONDING TO THIS T AND THE DENSITY CHOSEN
C FOR THE START OF THE ATMOSPHERE INTEGRATION.

c      PL = DLOG10((CGAS*ATMD0 + CA3*T**3)*T)
      PL = DLOG10((CGAS*ATMDX + CA3*T**3)*T)

C NOW FIND THE OPTICAL DEPTH(X0) WHERE THE ATMOSPHERE INTEGRATION BEGINS.
C YC   IF LMHD USE MHD EQUATION OF STATE.
      IF(LMHD)THEN
         CALL MEQOS(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *        AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,
     *        QCPP,LDERIV,LATMO,KSAHA)
      ELSE
         CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *        AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,
     *        QCPP,LDERIV,LATMO,KSAHA)
      ENDIF
C DBG 12/95 GET OPACITY
      CALL GETOPAC(DL, TL, X, Z, O, OL, QOD, QOT, FXION)
      X0 = PL - GL + DLOG10(O)
      Y(1) = PL
      DYDX(1) = DEXP(CLN*(GL+X0-OL-PL))
c G Somers 11/14 ADDED I/O FLAG AND CHANGED WRITE OUTS TO .STORE.
      IF(LPRT.AND.LSTATM) THEN
       WRITE(ISTOR,10)
         BETA = 1.0D0 - CA3*(T**2)**2/P
         CHRH = 1.0D0/QDP
         CHT = -CHRH*QDT
         CV = QCPP - EXP(CLN*(PL-DL-TL))*CHT**2/CHRH
         GAM1 = CHRH*QCPP/CV
       WRITE(ISTOR,20)X0,PL,TL,DL,O,(FXION(I),I=1,3),KSAHA,KATM,
     *                   GAM1,QDP,QDT,BETA,QCPP,CV
   10    FORMAT(6X,'TAU',9X,'P',10X,'T',10X,'D',11X,'O',9X,
     *         'HII  HEII HEIII   SAHA   KATM')
   20    FORMAT(1X,4F11.7,1PE14.7,0P3F6.3,2I7,4F12.8,1P2E12.5)
      ENDIF
C DBG PULSE INITIAL POINT FOR PULSATION
      IF (LPULPT.AND.LPRT) THEN
        QQED = 0.0D0
        QESUM = 0.0D0
        QQET = 0.0D0
        QFS = 1.0D0
        TAUP = DEXP(CLN*X0)
        OP = O
        DP = DEXP(CLN*DL)
        DELTR = 0.0D0
        PELPF = CGAS * T * D * EMU
C FROM FIRST LINES OF TPGRAD
        DELR = O*B*DEXP(CLN*(PL-HSTOT-4.0D0*TL+CLSUNL-CGL+
     *           CDELRL))*FTL/FPL
        IF (DELR-DELA .LE. 1.0D-6) THEN
            DEL = DELR
        ELSE
            DEL = DELA
        END IF
        IF(IPVER.EQ.1) THEN
C MHP 10/02 TYPO - QED SHOULD HAVE BEEN QQED
C     *         PL, QESUM,O,QDP,QED,
           WRITE(IOPATM,5001)DELTR,QFS,B,TL,DL,
     *         PL, QESUM,O,QDP,QQED,
     *         QQET,QOD,QOT,DEL,DELA,
     *         QCP,RMU,QDT,PELPF
C     *         PL, TAUP ,O,QDP,QED,
          ELSE IF (IPVER.EQ.2 .OR. IPVER.EQ.3) THEN
           WRITE(IOPATM,6001)DELTR,QFS,B,TL,DL,
     *         PL, TAUP ,O,QDP,QQED,
     *         QQET,QOD,QOT,DEL,DELA,
     *         QCP,RMU,QDT,PELPF
          END IF

 5001 FORMAT(5E16.9,/,5E16.9,/,5E16.9,/,4E16.9)
 6001 FORMAT(5E23.16,/,5E23.16,/,5E23.16,/,4E23.16)
 6003 FORMAT(6E23.16,/,6E23.16,/,6E23.16,/,4E23.16)
      END IF



C INTEGRATE DP/DTAU FROM THIS STARTING TAU TO TAU = 2/3.
C SET NUMERICAL PARAMETERS UP.
      NV = 1
      EPS = ATMERR
      IF (KTTAU .EQ. 1) THEN
C KRISHNA-SWAMY T TAU HAS DIFFERENT ZERO THAN EDDINGTON T TAU
C TAU = 0.312156330 AT TEFF.
            XLIM = -0.505627854D0
      ELSE
C TAU = 2/3 AT TEFF.
            XLIM = -0.176091259D0
      END IF

      if  (x0 .gt. xlim) then ! Check that starting point is before endpoint
         write(ishort,*)"ENVINT: X0>XLIM, X0,XLIM:",x0,xlim
       write(ishort,*)"ENVINT: get new X0 by dividing ATMD0 by 10"
       atmdx = atmdx / 10D0   ! If not before, divide starting density by 10
       goto 1998              ! and retry.
      endif

      HMAX = ATMMAX
      HMIN = ATMMIN
      H = ATMBEG
      STOLER = STOLR0
      NOK = 0
      NBAD = 0

C INTEGRATION LOOP.
      DO 40 NSTEP = 1,MAXSTP
C YSCAL IS THE ARRAY THAT THE NUMERICAL ERRORS ARE SCALED AGAINST.
       DO 30 I = 1,NV
          YSCAL(I) = DABS(Y(I)) + DABS(H*DYDX(I))+TINY
   30    CONTINUE
C ENSURE THAT STEP DOESN'T EXCEED MAXIMUM STEP SIZE OR GO PAST
C THE LIMIT OF THE INTEGRATION.
       IF((X0-XLIM)*(X0+H-XLIM).LT.0.0D0) H = XLIM - X0
       IF(H.GT.HMAX) H = HMAX
C INTEGRATE THE ATMOSPHERE FROM TAU TO TAU + H
C H IS THE ATTEMPTED STEP,HDID IS THE ONE PERFORMED, AND HNEXT IS THE
C PREDICTED NEXT STEP.
       CALL BSSTEP(Y,DYDX,NV,X0,H,EPS,YSCAL,HDID,
     x      HNEXT,QATM, B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,LPRT,RL,
     X      TEFFL,X,Z,KATM,KSAHA,ERR)
C FIND DP/DTAU AT THE START OF THE NEXT STEP.
       ERRSUM(1) = ERRSUM(1) + ERR(1)
       CALL QATM(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,
     *             LPRT,RL,TEFFL,X,Z,KATM,KSAHA)
c G Somers 11/14 ADDED I/O FLAG AND CHANGED WRITE OUTS TO .STORE.
       IF(LPRT.AND.LSTATM) THEN
            BETA = 1.0D0 - CA3*EXP(CLN*(4.0D0*AT-AP))
            CHRH = 1.0D0/QQDP
            CHT = -CHRH*QQDT
            CV = QQCP - EXP(CLN*(AP-AD-AT))*CHT**2/CHRH
            GAM1 = CHRH*QQCP/CV
          WRITE(ISTOR,20)TAU,AP,AT,AD,AO,(AFXION(I),I=1,3),
     *               KSAHA,KATM,GAM1,QQDP,QQDT,BETA,QQCP,CV
       ENDIF
       IF(HDID.EQ.H) THEN
          NOK = NOK + 1
       ELSE
          NBAD = NBAD + 1
       ENDIF
C DBG PULSE ATMOSPHERE VALUES FOR PULSATION
C JVS 02/11 - Added LCLCD option to IF statement
       IF (LPULPT.AND.LPRT .OR. LCLCD) THEN
          QQED = 0.0D0
          QESUM = 0.0D0
          QQET = 0.0D0
          QFS = 1.0D0
          ON = QO
          DN = DEXP(CLN*QDL)
          TAUN = DEXP(CLN*TAU)
C SEE J.P. COX PRINC. OF STELL. STRUC. P590
          DELTR =  (TAUN - TAUP)/(((DN*ON)+(DP*OP))/2)
          PELPF = CGAS * QT * QD * QEMU
          OP = ON
CFROM FIRST LINES OF TPGRAD
          DELR = QO*B*DEXP(CLN*(QPL-HSTOT-4.0D0*QTL+CLSUNL-CGL+
     *           CDELRL))*FTL/FPL
          IF (DELR-QDELA .LE. 1.0D-6) THEN
            DEL = DELR
          ELSE
            DEL = QDELA
          END IF
          IF (LPULPT.AND.LPRT) THEN
                IF (IPVER.EQ.1) THEN
                         WRITE(IOPATM,5001)DELTR,QFS,B,QTL,QDL,
     *                     QPL, QESUM ,QO,QQDP,QQED,
     *                     QQET,QQOD,QQOT,DEL,QDELA,
     *                     QQCP,QRMU,QQDT,PELPF
                        ELSE IF (IPVER.EQ.2.OR.IPVER.EQ.3) THEN
                         WRITE(IOPATM,6001)DELTR,QFS,B,QTL,QDL,
     *                     QPL, TAUN ,QO,QQDP,QQED,
     *                     QQET,QQOD,QQOT,DEL,QDELA,
     *                     QQCP,QRMU,QQDT,PELPF
                       END IF
            END IF


          TAUP = TAUN
          DP = DN
       END IF
C DBG END


C  CHECK IF INTEGRATION COMPLETE
       IF(DABS(X0 - XLIM).LE.STOLER) THEN
          WRITE(ISHORT,35)NOK,NBAD,ERRSUM(1)
   35       FORMAT(1X,'ATMOSPHERE INTEGRATION COMPLETE',1X,
     *            'NUMBER OF STEPS ACCEPTED',I5,' REJECTED',
     *            I5/5X,'MAXIMUM RELATIVE ERROR IN P ',1PE22.13)
          GOTO 200
       ENDIF
       IF(HNEXT.LT.HMIN) HNEXT = HMIN
       H = HNEXT
40    CONTINUE
C INTEGRATION HAS FAILED TO FINISH IN MAXSTP STEPS;
C PRINT NASTY MESSAGE AND QUIT.
      WRITE(IOWR,50)
      WRITE(ISHORT,50)
   50 FORMAT(5X,'ATMOSPHERE INTEGRATION FAILED AFTER MAXSTP',1X,
     *       'INTEGRATIONS.I QUIT.')
      STOP
C ENVELOPE INTEGRATION
C HERE P IS THE INDEPENDENT VARIABLE AND M,R,AND T ARE
C DEPENDENT VARIABLES.  INTEGRATE FROM TAU = 2/3 TO THE LAST
C MASS POINT IN THE MODEL.


  200 CONTINUE   ! Kurucz and Allard (KTTAU=3 and 4) bypass atmosphere
                 !  integration and come here

C G Somers 3/17, IF INTERESTED ONLY IN PPHOT, BREAK HERE.
      PPHOT = AP
      IF(.NOT.LCALCENV) GOTO 555

C G Somers 11/14 WRITE ENVELOPE HEADER
      IF(LPRT.AND.LSTENV) WRITE(ISTOR,61)
 61   FORMAT(/,'******** ENVELOPE BEGIN ********')

C DBG PULSE WRITE END OF DATA INDICATOR
      IF (LPULPT.AND.LPRT) THEN
C         XYZ = 99.99D0
         IF(IPVER.EQ.1) THEN
            WRITE(IOPATM, 5001) (XYZ(I),I=1,19)
         ELSE IF (IPVER.EQ.2.OR.IPVER.EQ.3) THEN
            WRITE(IOPATM, 6001) (XYZ(I),I=1,19)
         END IF
C 5002    FORMAT(E16.9)
C 6002    FORMAT(E23.16)
      ENDIF
C DBG
C  IF ENVELOPE MASS(SENV) SMALL ENOUGH,SKIP ENVELOPE INTEGRATION.
C DBG 2/92 CHANGED FROM 1.0D-10 to 1.0D-12
      IF(SENV.GT.-1.0D-12) THEN
       IF(LSBC) THEN
          PS(IE) = AP
          RS(IE) = RL
          TS(IE) = AT
          IF(LPRT)WRITE(ISTOR,230)PS(IE),TS(IE),RS(IE),SENV
       ENDIF
 230     FORMAT(4X,3F16.12,8X,F16.12)
       GOTO 300
      ENDIF
C  INITIALIZE VARIABLES AND SET NUMERICAL PARAMETERS.
      LATMO = .FALSE.
      DO 235 I = 1,3
       ERRSUM(I) = 0.0D0
 235  CONTINUE
      NOK = 0
      NBAD = 0
      X0 = AP
      SL = 0.0D0
      Y(1) = SL
      Y(2) = AT
      Y(3) = RL
      NV = 3
      EPS = ENVERR
      HMAX = ENVMAX
      HMIN = ENVMIN
      H = ENVBEG
      STOLER = DABS(STOLR0*SENV)
      RSURF = DEXP(CLN*RL)
      IF(ISTORE.EQ.IE) ISTORE = 0

      LLSTORE = .FALSE.
      IF (LSBC) THEN
         LTEST = .FALSE.
      ELSE
         LTEST = .TRUE.
      END IF
C  FIND DY/DX AT THE START OF THE STEP.
      CALL QENV(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,
     *     LPRT,RL,TEFFL,X,Z,KENV,KSAHA)
C DBG PULSE WRITE FIRST POINT OF ENVELOPE
      IF (LPULPT.AND.LPRT) THEN
C         REWIND IOPENV
         QQED = 0.0D0
         QESUM = 0.0D0
         QQET = 0.0D0
         PELPF = CGAS * QT * QD * QEMU
         IF(IPVER.EQ.1) THEN
          WRITE(IOPENV,5001)RL,QFS,B,QTL,QDL,
     *           QPL, QESUM,QO,QQDP,QQED,
     *           QQET,QQOD,QQOT,QDEL,QDELA,
     *           QQCP,QRMU,QQDT,PELPF
         ELSE IF (IPVER.EQ.2) THEN
          WRITE(IOPENV,6001)RL,QFS,B,QTL,QDL,
     *           QPL, QESUM,QO,QQDP,QQED,
     *           QQET,QQOD,QQOT,QDEL,QDELA,
     *           QQCP,QRMU,QQDT,PELPF
         ELSE IF (IPVER.EQ.3) THEN
C DBG 7/95 Appended mixing length info at end of first three lines
          WRITE(IOPENV,6003)RL,QFS,B,QTL,QDL,ALFMLT,
     *           QPL, QESUM,QO,QQDP,QQED,PHMLT,
     *           QQET,QQOD,QQOT,QDEL,QDELA,CMXMLT,
     *           QQCP,QRMU,QQDT,PELPF
         END IF
      END IF   !uncertain!
C DBG
c G Somers 11/14 ADDED I/O FLAG AND CHANGED WRITE OUTS TO .STORE.
      IF(LPRT.AND.LSTENV) THEN
       WRITE(ISTOR,240) 'GRAV  ','P   ','T   ','DEPTH    ','M      ',
     *       'D    ','O   ','BETA','DELR  ','DELA','DEL ','HII ',
     *       'HEII','HEIII','V   ','GAM1   ','QQDP   '
 240     FORMAT(1X,3A10,2A14,2A10,A7,A9,5A6,A9,2A12)
c     X' ',4X,'GRAV',7X,'P',8X,'T',8X,'DEPTH',6X,'M',
c     *        9X,'D',6X,'O',7X,'BETA',3X,'DELR',5X,'DELA',3X,
c     *        'DEL',3X,'HII',3X,'HEII',1X,'HEIII',3X,'V')

c 260        FORMAT(1X,1PE10.3,0P2F10.7,1P2E14.7,0P1F10.7,
c     *           1PE10.2,0PF7.3,1PE9.2,0P3F6.3,2F6.3,1PE9.2,
c     *           0P2F12.8)


       SRAD = DEXP(CLN*RL)
       DE = (RSURF-SRAD)/RSURF
       SGL = CGL+HSTOT-2.0D0*RL
       EG = DEXP(CLN*SGL)
         CHRH = 1.0D0/QQDP
         CHT = -CHRH*QQDT
         CV = QQCP - EXP(CLN*(EP-ED-ET))*CHT**2/CHRH
         GAM1 = CHRH*QQCP/CV
       WRITE(ISTOR,260)EG,EP,ET,DE,ES,ED,EO,EBETA,
     *        (EDEL(K),K=1,3),(EFXION(K),K=1,3),EVEL,
     *        GAM1,QQDP
      ENDIF
C STORE STARTING VALUES OF THE INTEGRATION
C 07/02 INITIALIZE NUMBER OF STORED ENVELOPE POINTS TO 1
      LSURCZ = .FALSE.
      TAUCZENV = 0.0D0
      ENVD(1) = ED
      ENVP(1) = EP
      ENVR(1) = ER
      ENVS(1) = ES
      ENVT(1) = ET
      ENVX(1) = X
      ENVZ(1) = Z
      LCENV(1) = EVEL.GT.0.0D0
C JVS 03/28
      EDELS(1,1) = EDEL(1)
      EDELS(2,1) = EDEL(2)
      EDELS(3,1) = EDEL(3)
      EVELS(1) = EVEL
      EBETAS(1) = EBETA
c JVS end
C JVS 10/10
      CHDELJ = EDEL(2)
      CHDELD = QDELA

      IF(LCENV(1))LSURCZ = .TRUE.
      NUMENV = 1
      DO 220 NSTEP = 1,MAXSTP
       XSTART = X0
       DO 210 I = 1,NV
          YSTART(I) = Y(I)
          YSCAL(I) = DABS(Y(I)) + DABS(H*DYDX(I))+TINY
 210     CONTINUE
       SEST = Y(1) + H*DYDX(1)
       IF(SENV - Y(1).GT.0.0D0 .OR. SENV - SEST.GT.0.0D0) THEN
C  IF THE INTEGRATION HAS OVERSHOT THE FITTING POINT, OR THE NEXT
C  STEP WILL DO SO,LIMIT STEP SIZE OR INTEGRATE BACKWARDS TO THE
C  CORRECT MASS.
          H = (SENV - Y(1))/DYDX(1)
       ENDIF
C  ENSURE THAT STEP DOESN'T EXCEED MAXIMUM STEP SIZE
       IF(H.LT.0.0D0) THEN
          IF(H.LT.-HMAX) H = -HMAX
       ELSE
          IF(H.GT.HMAX)  H = HMAX
       ENDIF
C  PLIM IS AN ESTIMATE OF THE ENDING PRESSURE FOR THE INTEGRATION,
C  BASED ON THE PRESSURE OF THE LAST MODEL POINT.
C  THE FIRST TIME THE INTEGRATOR TRIES TO PASS IT,LIMIT THE STEP
C  IN PRESSURE.
       IF(LTEST) THEN
          IF(X0 + H.GT.PLIM) THEN
             H = PLIM - X0
             LTEST = .FALSE.
          ENDIF
       ENDIF
C  INTEGRATE THE EQUATIONS FROM X0 TO X0 + H
C  H IS THE ATTEMPTED STEP,HDID IS THE ONE PERFORMED, AND HNEXT IS THE
C  PREDICTED NEXT STEP.

       CALL BSSTEP(Y,DYDX,NV,X0,H,EPS,YSCAL,HDID,HNEXT,QENV,
     *        B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,LPRT,RL,
     *        TEFFL,X,Z,KENV,KSAHA,ERR)
       DO 255 K = 1,3
          ERRSUM(K) = ERRSUM(K) + ERR(K)
 255     CONTINUE
C  FIND DY/DX AT THE START OF THE NEXT STEP.

       CALL QENV(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,
     *        LPRT,RL,TEFFL,X,Z,KENV,KSAHA)
C DBG PULSE
         IF (LPULPT.AND.LPRT) THEN
          QQED = 0.0D0
          QESUM = 0.0D0
          QQET = 0.0D0
          PELPF = CGAS * QT * QD * QEMU
          IF(IPVER.EQ.1) THEN
               WRITE(IOPENV,5001)RL,QFS,B,QTL,QDL,
     *              QPL, QESUM,QO,QQDP,QQED,
     *              QQET,QQOD,QQOT,QDEL,QDELA,
     *              QQCP,QRMU,QQDT,PELPF
            ELSE IF (IPVER.EQ.2) THEN
               WRITE(IOPENV,6001)RL,QFS,B,QTL,QDL,
     *              QPL, QESUM,QO,QQDP,QQED,
     *              QQET,QQOD,QQOT,QDEL,QDELA,
     *              QQCP,QRMU,QQDT,PELPF
            ELSE IF (IPVER.EQ.3) THEN
C DBG 7/95 Appended mixing length info at end of first three lines
               WRITE(IOPENV,6003)RL,QFS,B,QTL,QDL,ALFMLT,
     *              QPL, QESUM,QO,QQDP,QQED,PHMLT,
     *              QQET,QQOD,QQOT,QDEL,QDELA,CMXMLT,
     *              QQCP,QRMU,QQDT,PELPF
            END IF
         END IF
C DBG END
c G Somers 11/14 ADDED I/O FLAG AND CHANGED WRITE OUTS TO .STORE.
       IF(LPRT.AND.LSTENV) THEN
          SRAD = DEXP(CLN*RL)
          DE = (RSURF-SRAD)/RSURF
          SGL = CGL+HSTOT-2.0D0*RL
          EG = DEXP(CLN*SGL)
            CHRH = 1.0D0/QQDP
            CHT = -CHRH*QQDT
            CV = QQCP - EXP(CLN*(EP-ED-ET))*CHT**2/CHRH
            GAM1 = CHRH*QQCP/CV
          WRITE(ISTOR,260)EG,EP,ET,DE,ES,ED,EO,EBETA,
     *           (EDEL(K),K=1,3),(EFXION(K),K=1,3),EVEL,
     *           GAM1,QQDP
 260        FORMAT(1X,1PE10.3,0P2F10.7,1P2E14.7,0P1F10.7,
     *           1PE10.2,0PF7.3,1PE9.2,0P3F6.3,2F6.3,1PE9.2,
     *           0P2F12.8)
       ENDIF
       IF(HDID.EQ.H) THEN
          NOK = NOK + 1
       ELSE
          NBAD = NBAD + 1
       ENDIF
C  CHECK IF INTEGRATION COMPLETE
       SDIF = SENV - Y(1)
C 07/02 STORE ENVELOPE TERMS IF THE INTEGRATION
C HAS NOT OVERSHOT THE FITTING POINT.
         IF(SDIF.LE.STOLER)THEN
            NUMENV = NUMENV + 1
            ENVD(NUMENV) = ED
            ENVP(NUMENV) = EP
            ENVR(NUMENV) = ER
            ENVS(NUMENV) = ES
            ENVT(NUMENV) = ET
            ENVX(NUMENV) = X
            ENVZ(NUMENV) = Z
            LCENV(NUMENV) = EVEL.GT.0.0D0
C JVS 08/13 ADD RUN FOR CZ CALCULATION
            EDELS(1,NUMENV) = EDEL(1)
            EDELS(2,NUMENV) = EDEL(2)
            EDELS(3,NUMENV) = EDEL(3)
            EVELS(NUMENV) = EVEL
            EBETAS(NUMENV) = EBETA

            IF(.NOT.LSURCZ)THEN
               IF(LCENV(NUMENV))THEN
                  LSURCZ = .TRUE.
               ENDIF
            ELSE IF(EVEL.GT.0.0D0)THEN
               DR = 10.0D0**ENVR(NUMENV-1) -
     *              10.0D0**ENVR(NUMENV)
               TAUCZENV = TAUCZENV + DR/EVEL
            ENDIF
         ENDIF
       IF(DABS(SDIF).LE.STOLER)THEN
C            WRITE(*,*)TAUCZENV/CSECYR
          IF(LSBC) THEN
             WT0 = SDIF/(YSTART(1)-Y(1))
             PS(IE) = X0 + WT0*(XSTART - X0)
             RS(IE) = Y(3) + WT0*(YSTART(3) - Y(3))
             TS(IE) = Y(2) + WT0*(YSTART(2) - Y(2))
             IF(LPRT)WRITE(ISHORT,230)PS(IE),TS(IE),RS(IE),SENV
          ENDIF
          GOTO 300
       ELSE IF(.NOT.LLSTORE) THEN
          IF(Y(2).GE.TENV .AND. LSBC) THEN
             LLSTORE = .TRUE.
             ISTORE = IE
             ESTORE(1) = X0
             ESTORE(2) = Y(2)
             ESTORE(3) = Y(3)
             ESTORE(4) = Y(1)
          ENDIF
       ENDIF
       IF(HNEXT.LT.HMIN) HNEXT = HMIN
       H = HNEXT
 220  CONTINUE
C INTEGRATION HAS FAILED TO FINISH IN MAXSTP STEPS;
C PRINT NASTY MESSAGE AND QUIT.
      WRITE(IOWR,911)
      WRITE(ISHORT,911)
 911  FORMAT(5X,'ENVELOPE INTEGRATION FAILED AFTER MAXSTP TRIES.',1X,
     *     'I QUIT')
      STOP
 300  CONTINUE
C 07/02 NOW INVERT THE ENVELOPE VECTOR.
      IF(SENV.LT.-1.0D-12)THEN
         DO I = 1,NUMENV
            I1 = I
            I2 = NUMENV - I + 1
            IF(I1.GE.I2)GOTO 310
            DUM1 = ENVD(I1)
            ENVD(I1) = ENVD(I2)
            ENVD(I2) = DUM1
            DUM1 = ENVP(I1)
            ENVP(I1) = ENVP(I2)
            ENVP(I2) = DUM1
            DUM1 = ENVR(I1)
            ENVR(I1) = ENVR(I2)
            ENVR(I2) = DUM1
            DUM1 = ENVS(I1)
            ENVS(I1) = ENVS(I2)
            ENVS(I2) = DUM1
            DUM1 = ENVT(I1)
            ENVT(I1) = ENVT(I2)
            ENVT(I2) = DUM1
            DUM1 = ENVX(I1)
            ENVX(I1) = ENVX(I2)
            ENVX(I2) = DUM1
            DUM1 = ENVZ(I1)
            ENVZ(I1) = ENVZ(I2)
            ENVZ(I2) = DUM1
            LDUM = LCENV(I1)
            LCENV(I1) = LCENV(I2)
            LCENV(I2) = LDUM
C 08/13 JVS ADDED DEL VECTORS
            DUM1 = EDELS(1,I1)
            EDELS(1,I1) = EDELS(1,I2)
            EDELS(1,I2) = DUM1
            DUM1 = EDELS(2,I1)
            EDELS(2,I1) = EDELS(2,I2)
            EDELS(2,I2) = DUM1
            DUM1 = EDELS(3,I1)
            EDELS(3,I1) = EDELS(3,I2)
            EDELS(3,I2) = DUM1
            DUM1 = EVELS(I1)
            EVELS(I1) = EVELS(I2)
            EVELS(I2) = DUM1
            DUM1 = EBETAS(I1)
            EBETAS(I1) = EBETAS(I2)
            EBETAS(I2) = DUM1

         END DO
 310     CONTINUE
C JVS 07/12 Save the last envelope point pressure
C      PPHOT = ENVP(NUMENV) ! G Somers 3/17, MOVED PPHOT DEF HIGHER UP
C END JVS
      ENDIF
C DBG PULSE WRITE END OF DATA INDICATOR
      IF (LPULPT.AND.LPRT) THEN
C         XYZ = 99.99D0
         IF(IPVER.EQ.1) THEN
            WRITE(IOPENV, 5001) (XYZ(I),I=1,19)
         ELSE IF (IPVER.EQ.2 .OR. IPVER.EQ.3)THEN
            WRITE(IOPENV, 6003) (XYZ(I),I=1,22)
         END IF
      ENDIF

      WRITE(ISHORT,215)NOK,NBAD,SDIF,Y(1),(ERRSUM(J),J=1,3)
 215  FORMAT(1X,'ENVELOPE INTEGRATION COMPLETE',1X,
     *     'NUMBER OF STEPS ACCEPTED',I5,' REJECTED',
     *     I5/5X,'SENV-LAST M=',1PE22.13,'  LAST M=',E22.13/
     *     5X,'MAX RELATIVE ERRORS:M ',1PE14.5,'  T ',E14.5,
     *     '  R ',E14.5)

C JVS 08/13
C IF THE CZ IS IN THE ENVELOPE (.I.E. BEYOND THE FITTING POINT) TRACK ITS
C LOCATION IN MASS AND RADIUS FOR USE WITH AM LOSS ROUTINES
C
C G Somers 3/17, SKIP TAUCAL CALL IF USING NEW TAUCZ ROUTINES
        IF(LNEWTCZ)GOTO 555
C G Somers END
      JENV = 0.0
      DO I=1,NUMENV
            IF (JENV .EQ. 0.0 .AND. LCENV(I) ) JENV = I
      END DO

      IF (JENV .GT. 1) THEN
            ! Calculate the the location of the base sof the surface CZ in radius
            DD2 = EDELS(1,JENV-1)-EDELS(2,JENV-1)
            DD1 = EDELS(1,JENV)-EDELS(2,JENV)
            FX = DD2/(DD2-DD1)

            ENVCZL = ENVR(JENV-1)+FX*(ENVR(JENV)-ENVR(JENV-1))-CRSUNL
            ENVRCZ = EXP(CLN*ENVCZL)

            DO I=1,NUMENV
                  ENVS1(I) = DEXP(CLN*(ENVS(I)+HSTOT))

                  IF (I.EQ.NUMENV) THEN
                        ENVS2(I) = 0.0
                  ELSE
                        ENVS2(I)=DEXP(CLN*ENVS(I+1))-DEXP(CLN*ENVS(I))
                  ENDIF

                  EDEL1(I) = EDELS(1,I)
                  EDEL2(I) = EDELS(2,I)
            END DO

            CALL TAUCAL(ENVX,ENVS2,ENVS1,LCENV,ENVR,ENVP,ENVD,ENVG,NUMENV,
     *            EVELS, EDEL1,EDEL2)
      ENDIF

555      CONTINUE
      RETURN
      END
