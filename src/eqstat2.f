C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C EQSTAT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      SUBROUTINE EQSTAT2(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,
     *RMU,AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,
     *LDERIV,LATMO,KSAHA)
c
c  Input Arguments: TL, PL, X, Z, LDERIV, LATMO
c
c  Output Arguments: T, P, D, DL, BETA, BETAI, BETA14, FXION, RMU, AMU,
c          EMU, QDT, QDP, QCP, DELA, QDTT, QDTP, QAT, QAP, QCPT, QCPP,
c
c  Update (Input and Output) Arguments: KSAHA
c

      use params, only : nts, nps
      use settings, only : XENV, ZENV, AMUENV, FXENV  ! COMMON/COMP/
      use settings, only : CLN  ! COMMON/CONST1/
      use settings, only : CGAS, CA3  ! COMMON/CONST2/
      use settings, only : TSCUT  ! COMMON/CTLIM/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      SAVE
      DIMENSION FX(12),ATOMWT(4),FXION(3),ATOMW2(12)
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
      COMMON/DEBHU/CDH,ETADH0,ETADH1,ZDH(18),XXDY,
     1     YYDH,ZZDH,DHNUE(18),LDH
C YCK 2/95 OPAL eos
C LLP 2001 OPAL eos
C LLP 2006 OPAL eos
C LLP Add Use Numerical Derivatives flag, LNumDeriv   7/07
      LOGICAL*4 LOPALE, lopale01,lopale06,lNumDeriv
      CHARACTER*256 FOPALE,fopale01,fopale06
      COMMON/OPALEOS/FOPALE,LOPALE,IOPALE,fopale01,lopale01,fopale06,
     x     lopale06,lNumDeriv
C MHP 3/94 ADDED METAL DIFFUSION
      COMMON/GRAVS3/FGRY,FGRZ,LTHOUL,LDIFZ
C MHP  5/97 ADDED COMMON BLOCK FOR SCV EOS TABLES
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *     TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *     TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDT,IDP
      DATA NZP1/12/
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      DATA SCALET,SCALES/0.500D0, 2.000D0/
      DATA ATOMW2/23.0D0,26.99D0,24.32D0,55.86D0,28.1D0,12.015D0,
     *            1.008D0,16.0D0,14.01D0,39.96D0,20.19D0,4.004D0/
      SAVE
C LSAHA = T IF T LOW ENOUGH TO REQUIRE CALL TO EQSAHA TO SOLVE
C SAHA IONIZATION EQUATION. IF LSAHA = F, FULLY IONIZED GAS ASSUMED.
C LONLYS = T IF SAHA EQUATION MUST BE SOLVED BUT RELATIVISTIC
C EQUATION OF STATE NOT NEEDED.
 9    LSAHA = TL.LT.TSCUT
      LONLYS = TL.LE.(TSCUT - SCALET)

C MHP 3/94 METAL DIFFUSION ADDED.  ASSUME ALL METALS SCALE EQUALLY.
      Z0 = Z
      IF(LDIFZ)THEN
C THE VECTOR FXENV IS DEFINED IN STARIN AS
C (MASS FRACTION OF SPECIES/ATOMIC WT/AMUENV) FOR THE COMPOSITION
C XENV,ZENV.
C AND AMU IS DEFINED AS THE SUM OF THE MASS FRACTIONS DIVIDED BY THEIR
C ATOMIC WEIGHTS.  FOR METAL DIFFUSION, ALL THE METALS ARE ASSUMED TO
C CHANGE EQUALLY.
         RAT = Z/ZENV
         R1A = (RAT-1.0D0)*AMUENV
         AMU = AMUENV
         DO I = 1,6
            AMU = AMU + R1A*FXENV(I)
         END DO
         DXX = (X - XENV)/ATOMW2(7)
         AMU = AMU +  DXX
         DO I = 8,11
            AMU = AMU + R1A*FXENV(I)
         END DO
         DYY = (XENV + ZENV - X - Z)/ATOMW2(12)
         AMU = AMU + DYY
         RAA = RAT*AMUENV/AMU
         IF(LSAHA)THEN
            DO I = 1,6
               FX(I) = RAA*FXENV(I)
            END DO
            FX(7) = (FXENV(7)*AMUENV + DXX)/AMU
            DO I = 8,11
               FX(I) = RAA*FXENV(I)
            END DO
            FX(12) = (FXENV(12)*AMUENV + DYY)/AMU
         ENDIF
      ELSE
C SET UP FRACTIONAL ABUNDANCES
      DFX1 = (X - XENV)
      DFX12 = (Z - ZENV)
      IF(DABS(DFX1) + DABS(DFX12) .LT. 1.0D-5) THEN
C USE ENVELOPE ABUNDANCES
	 AMU = AMUENV
	 IF(LSAHA) THEN
	    DO 10 I = 1,NZP1
	       FX(I) = FXENV(I)
 10         CONTINUE
	 ENDIF
      ELSE
	 DFX1 = DFX1*ATOMWT(1)
	 DFX12 = DFX12*ATOMWT(3)
	 DFX4 = (XENV+ZENV -X-Z)*ATOMWT(2)
C ASSUME EXCESS Z(METALS) IS IN THE FORM OF CARBON(12)
	 AMU = AMUENV + DFX1 + DFX4 + DFX12
	 AMUI = 1.0D0/AMU
	 IF(LSAHA) THEN
	    FMU = AMUENV*AMUI
	    DO 20 I = 1,NZP1
	       FX(I) = FMU*FXENV(I)
 20         CONTINUE
	    FX(6) = FX(6) + DFX12*AMUI
	    FX(7) = FX(7) + DFX1*AMUI
	    FX(12) = FX(12)+ DFX4*AMUI
	 ENDIF
      ENDIF
      ENDIF
C COMPUTE RADIATION PRESSURE
      T = DEXP(CLN*TL)
      P = DEXP(CLN*PL)
      BETA14 = CA3*(T**2)**2/P
      BETA = 1 - BETA14

      if(BETA .LT. 0d0) then
        write(ishort,*) 'EQSTAT2: BETA is negative: TL,PL,BETA,1-BETA',
     *        TL,PL,BETA,1D0-BETA
      endif

      BETAI = 1.0D0/BETA
      BETA14 = 4.0D0*BETAI*DMIN1(1.0D0,BETA14)
      ETA = 0.0D0
      IF(.NOT.LSAHA) THEN
C COMPUTE VALUES FOR FULLY IONIZED GAS AND RETURN
	 EMU = X*ATOMWT(1) + (1.0D0-X)*ATOMWT(4)
	 RMU = CGAS*(AMU+EMU)
	 FXION(1) = 1.0D0
	 FXION(2) = 0.0D0
	 FXION(3) = 1.0D0
	 CALL EQRELV(TL,T,PL,P,DL,D,BETA,AMU,EMU,ETA,QDT,QDP,QCP,DELA,
     *        QDTT,QDTP,QAT,QAP,QCPT,QCPP,X)
	 GOTO 200
      ENDIF
C CHECK IF SAUMON, CHABRIER, AND VAN HORN EQUATION OF STATE NEEDED.
C THIS EOS REPLACES THE CALL TO EQSAHA, EXCEPT FOR DERIVATIVE PURPOSES.
      IF(LSCV) THEN
         CALL EQSAHA(FX,TL,T,PL,P,DL,D,BETA,BETAI,BETA14,FXION,RMU,
     1        AMU,EMU,LDERIV,LATMO,QDT,QDP,QCP,DELA,QDTT,
     2        QDTP,QAT,QAP,QCPT,QCPP,KSAHA)
         CALL EQSCVE(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,
     *        RMU,AMU,EMU,ETA,QDT,QDP,QCP,DELA,LCALC)

         LSCVD = .FALSE.   ! Do not do SCV derivatives
         IF(LSCVD .AND. LCALC)THEN
c  LLP 9/6/03 To get reasonable accuracy in numerical derivatives in
c	the 4-5 decimal place SCV tables, appropriate sizes for the
c	stepouts in the numerical derivatives must be obtained.  The
c	row to row and column to column spacings are .20 in PL and
c	.08 in TL. Maximum row to row changes are of the order of
c	0.2000 out of 10.0000 (in density).  Maximum column to column
c       changes changes are of the order of .0500 out of 3.5000 (in
c	density.  It appears that stepouts of plus and minus half a
c	row and column are needed to get appropriate accuracy for the
c	derivatives.

            dpl = .010d0
            dtl = .040d0
            TTL = TL + dtl
            T = 10.0D0**TTL
            CALL EQSCVE(TTL,T,PL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *      FXION,RMU,AMU,EMU,ETA,QDT1,QDP1,QCP1,DELA1,LCALC1)
            TTL = TL - dtl
            T = 10.0D0**TTL
            CALL EQSCVE(TTL,T,PL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *      FXION,RMU,AMU,EMU,ETA,QDT2,QDP2,QCP2,DELA2,LCALC2)
            dtl2 = 2D0 * dtl
            QDTT1 = (QDT1-QDT2)/dtl2/CLN
            QCPT1 = (DLOG10(QCP1)-DLOG10(QCP2))/dtl2
            QAT1 = (DLOG10(DELA1)-DLOG10(DELA2))/dtl2

            T = 10.0D0**TL
            PPL = PL + dpl
            P = 10.0D0**PPL
            CALL EQSCVE(TL,T,PPL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *      FXION,RMU,AMU,EMU,ETA,QDT1,QDP1,QCP1,DELA1,LCALC1)
            PPL = PL - dpl
            P = 10.0D0**PPL
            CALL EQSCVE(TL,T,PPL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *      FXION,RMU,AMU,EMU,ETA,QDT2,QDP2,QCP2,DELA2,LCALC2)
            P = 10.0D0**PL
            dpl2 = 2D0 * dpl
            QDTP1 = (QDT1-QDT2)/dpl2/CLN
            QCPP1 = (DLOG10(QCP1)-DLOG10(QCP2))/dpl2
            QAP1 = (DLOG10(DELA1)-DLOG10(DELA2))/dpl2
            QDTT = QDTT1
            QDTP = QDTP1
            QAT = QAT1
            QAP = QAP1
            QCPP = QCPP1
            QCPT = QCPT1
         ENDIF
      ELSE
C CALL TO PRATHER EOS - Either because SCV was not requested or it has failed.
         CALL EQSAHA(FX,TL,T,PL,P,DL,D,BETA,BETAI,BETA14,FXION,RMU,
     1        AMU,EMU,LDERIV,LATMO,QDT,QDP,QCP,DELA,QDTT,QDTP,
     2        QAT,QAP,QCPT,QCPP,KSAHA)
      ENDIF
C STORE EQSAHA VALUES FOR INTERPOLATION WITH EQRELV VALUES
      DL0 = DL
      QDT0 = QDT
      QDP0 = QDP
      QCP0 = QCP
      DELA0 = DELA
      IF(LDERIV) THEN
	 QDTT0 = QDTT
	 QDTP0 = QDTP
         QCPT0 = QCPT
         QCPP0 = QCPP
         QAT0 = QAT
         QAP0 = QAP
      ENDIF
      IF(LONLYS) GOTO 200  ! Bypass relativistic EOS (eqrelv) if in low temperature region
C COMPUTE VALUES FOR FULLY IONIZED GAS
      EMU = X*ATOMWT(1) + (1.0D0-X)*ATOMWT(4)
      RMU = CGAS*(AMU+EMU)
      FXION(1) = 1.0D0
      FXION(2) = 0.0D0
      FXION(3) = 1.0D0
      CALL EQRELV(TL,T,PL,P,DL,D,BETA,AMU,EMU,ETA,QDT,QDP,QCP,DELA,
     *     QDTT,QDTP,QAT,QAP,QCPT,QCPP,X)
C INTERPOLATE VALUES
      WTS = SCALES*(TSCUT - TL)
      WTS2 = WTS*WTS
      WT0 = WTS2*WTS*(6.0D0*WTS2 - 15.0D0*WTS + 10.0D0)
C      WT1 =-SCALES*30.0D0*WTS2*(1.0D0-WTS)**2 ! Derivative of WT0
      DL0 = DL0 - DL
      QDT0 = QDT0 - QDT
      QDP0 = QDP0 - QDP
      QCP0 = QCP0 - QCP
      DELA0 = DELA0 - DELA
      QCPT0 = QCPT0-QCPT
      QCPP0 = QCPP0-QCPP
      QAT0 = QAT0 - QAT
      QAP0 = QAP0 - QAP
      DL = DL + WT0*DL0
      D = DEXP(CLN*DL)
      RMU = BETA*P/(D*T)
      EMU = RMU/CGAS - AMU
      FXION(1) = 1.0D0 + WT0*(FXION(1) - 1.0D0)
      FXION(2) = WT0*FXION(2)
      FXION(3) = 1.0D0 + WT0*(FXION(3) - 1.0D0)
      QDT = QDT + WT0*QDT0
      QDP = QDP + WT0*QDP0
      QCP = QCP + WT0*QCP0
      DELA = DELA + WT0*DELA0
      IF(LDERIV) THEN
         QDTT = QDTT + WT0*QDTT0
         QDTP = QDTP + WT0*QDTP0
         QCPT = QCPT + WT0*QCPT0
         QCPP = QCPP + WT0*QCPP0
         QAT = QAT + WT0*QAT0
         QAP = QAP + WT0*QAP0
      ENDIF
 200  CONTINUE

C 1995 OPAL eqos
      IF(LOPALE)THEN
      IF(T.GE.5.0D3 .AND. TL.LE.8.0D0 .AND. DL.LE.5.0D0)THEN

         CALL OEQOS(TL,T,PL,P,D10o,Doo,X,Z,BETAo,BETAIo,
     1   BETA14o,RMUo,AMUo,EMUo,QDTo,QDPo,QCPo,DELAo,*998)

         CALL EQBOUND(T,D10o,DL0,FAC,LTAB,LRAMP)

         IF(.NOT.LTAB)GOTO 998  ! Point is not in OPAL 1995 EOS table, so exit.

         IF(.NOT.LRAMP)THEN
C  No ramping needed between OPAL 1995 EOS and Yale/SCV. Result is
C  fully in the OPAL 1995 table
            DL=D10o
            D=10.0D0**DL
            BETA=BETAo
            BETAI=1.0D0/BETA
            BETA14=1.0D0-BETA
            RMU=RMUo
            AMU=AMUo
            EMU=EMUo
            QDT=QDTo
            QDP=QDPo
            QCP=QCPo
            DELA=DELAo
         ELSE
C  Ramping required. Result is on border between OPAL 1995 EOS and Yale/SCV.
            DL=DL+FAC*(D10o-DL)
            D=10.0D0**DL
            BETA=BETA+FAC*(BETAo-BETA)
            BETAI=1.0D0/BETA
            BETA14=1.0D0-BETA
            RMU=RMU+FAC*(RMUo-RMU)
            AMU=AMU+FAC*(AMUo-AMU)
            EMU=EMU+FAC*(EMUo-EMU)
            QDT=QDT+FAC*(QDTo-QDT)
            QDP=QDP+FAC*(QDPo-QDP)
            QCP=QCP+FAC*(QCPo-QCP)
            DELA=DELA+FAC*(DELAo-DELA)
         ENDIF
      ENDIF
      ENDIF

C 2001 OPAL eqos  LLP 6/17/03
      IF(LOPALE01)THEN
      IF(T.GE.2.0D3 .AND. T.LE.100D6 .AND. DL.LE.7.0D0)THEN
         CALL OEQOS01(TL,T,PL,P,D10o,Doo,X,Z,BETAo,BETAIo,
     1   BETA14o,RMUo,AMUo,EMUo,QDTo,QDPo,QCPo,DELAo,*998)

         CALL EQBOUND01(T,D10o,DL0,FAC,LTAB,LRAMP)
C eqbound01 determines whether or not the point is in the OPAL 2001 EOS table

         IF(.NOT.LTAB)GOTO 998  ! Point is not in OPAL 2001 tabel, so exit.
C USE OPAL RESULTS IF NOT IN (RHO,T) REGIME WHERE RAMP
C NEEDED
         IF(.NOT.LRAMP)THEN
C  No ramping needed between OPAL 2001 EOS and Yale/SCV. Result is
C  fully in the OPAL 2001 table
            DL=D10o
            D=10.0D0**DL
            BETA=BETAo
            BETAI=1.0D0/BETA
            BETA14=1.0D0-BETA
            RMU=RMUo
            AMU=AMUo
            EMU=EMUo
            QDT=QDTo
            QDP=QDPo
            QCP=QCPo
            DELA=DELAo
         ELSE
C  Ramping required. Result is on border between OPAL 2001 EOS and Yale/SCV.
            DL=DL+FAC*(D10o-DL)
            D=10.0D0**DL
            BETA=BETA+FAC*(BETAo-BETA)
            BETAI=1.0D0/BETA
            BETA14=1.0D0-BETA
            RMU=RMU+FAC*(RMUo-RMU)
            AMU=AMU+FAC*(AMUo-AMU)
            EMU=EMU+FAC*(EMUo-EMU)
            QDT=QDT+FAC*(QDTo-QDT)
            QDP=QDP+FAC*(QDPo-QDP)
            QCP=QCP+FAC*(QCPo-QCP)
            DELA=DELA+FAC*(DELAo-DELA)
         ENDIF
      ENDIF
      ENDIF

C 2006 OPAL eqos  LLP 10/13/2996
      IF(LOPALE06)THEN
      IF(T.GE.1.870D3 .AND. T.LE.200D6 .AND. DL.LE.7.0D0)THEN
         CALL OEQOS06(TL,T,PL,P,D10o,Doo,X,Z,BETAo,BETAIo,
     1   BETA14o,RMUo,AMUo,EMUo,QDTo,QDPo,QCPo,DELAo,*998)

         CALL EQBOUND06(T,D10o,DL0,FAC,LTAB,LRAMP)
C EQBOUND01 determines whether or not the point is in the OPAL 2006 EOS table
C    If LTAB is true, point is in Opal 2006 table
C    If LRAMP is true, point is in ramp area, and ramping is required. The ramp
C       factor FAC is the weight of the point for ramping purposes.
C    Also, to eliminate a point, one can set LRAMP to true and FAC to zero.

         IF(.NOT. LTAB) goto 998  ! Point is not in OPAL 2006 EOS table, so exit.

C USE OPAL 2006 RESULTS ONLY IF NOT IN (RHO,T) REGIME WHERE RAMPING is NEEDED
         IF(.NOT.LRAMP)THEN
C  No ramping needed between OPAL 2006 EOS and Yale/SCV. Result is
C  fully in the OPAL 2006 table
            DL=D10o
            D=10.0D0**DL
            BETA=BETAo
            BETAI=1.0D0/BETA
            BETA14=1.0D0-BETA
            RMU=RMUo
            AMU=AMUo
            EMU=EMUo
            QDT=QDTo
            QDP=QDPo
            QCP=QCPo
            DELA=DELAo
         ELSE
C  Ramping required. Result is on border between OPAL 2006 EOS and Yale/SCV.
            DL=DL+FAC*(D10o-DL)
            D=10.0D0**DL
            BETA=BETA+FAC*(BETAo-BETA)
            BETAI=1.0D0/BETA
            BETA14=1.0D0-BETA
            RMU=RMU+FAC*(RMUo-RMU)
            AMU=AMU+FAC*(AMUo-AMU)
            EMU=EMU+FAC*(EMUo-EMU)
            QDT=QDT+FAC*(QDTo-QDT)
            QDP=QDP+FAC*(QDPo-QDP)
            QCP=QCP+FAC*(QCPo-QCP)
            DELA=DELA+FAC*(DELAo-DELA)
         ENDIF
      ENDIF
      ENDIF


 998  CONTINUE
      Z = Z0
      RETURN
      END
