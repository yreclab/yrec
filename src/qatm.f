C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C QATM
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE QATM(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,LSAVE,
     *                RL,TEFFL,X,Z,KATM,KSAHA)
C QATM CALCULATES THE DERIVATIVE D(P)/D(TAU), USING THE EDDINGTON
C APPROXIMATION FOR A T-TAU RELATION.
C IT ALSO RETURNS TL,O, AND FXION FOR OUTPUT PURPOSES
C   Q(TAU) = 0.6666667

      PARAMETER(JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      REAL*8 OLAOL(12,104,52),OXA(12),OT(52),ORHO(104),TOLLAOL
      CHARACTER*256 FLAOL, FPUREZ
      COMMON/NWLAOL/OLAOL, OXA, OT, ORHO, TOLLAOL,
     *  IOLAOL, NUMOFXYZ, NUMRHO, NUMT, LLAOL, LPUREZ, IOPUREZ,
     *  FLAOL, FPUREZ
      DIMENSION Y(3),DYDX(3),FXION(3)
      COMMON/PULSE/XMSOL,LPULSE,IPVER
      COMMON/PULSE1/PQDP(JSON),PQED(JSON),PQET(JSON),
     *   PQOD(JSON), PQOT(JSON), PQCP(JSON), PRMU(JSON),
     *   PQDT(JSON),PEMU(JSON),LPUMOD
      COMMON/PULSE2/QQDP,QQED,QQET,QQOD,QQOT,QDEL,
     *      QDELA, QQCP, QRMU, QTL, QPL, QDL, QO, QOL,
     *      QT, QP, QQDT, QEMU, QD, QFS
      COMMON/ATMPRT/TAUL,AP,AT,AD,AO,AFXION(3)
      COMMON/CONST1/ CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      COMMON/ATMOS/HRAS,KTTAU,KTTAU0,LTTAU
      COMMON/MHD/LMHD,IOMHD1,IOMHD2,IOMHD3,IOMHD4,IOMHD5,IOMHD6,
     1           IOMHD7, IOMHD8
      SAVE

C EDDINGTON APPROXIMATION
      TTAUL0(YY) = TEFFL - 0.031235D0 + 0.25D0*DLOG10(YY + CC23)

C KRISHNA-SWAMY APPROXIMATION (BASED ON FIT TO SOLAR ATMOSPHER)
C SEE KRISHNA-SWAMY, AP.J. 1966, 145, 176.
      TTAUL1(YY) = TEFFL - 0.031235D0 + 0.25D0*DLOG10(YY + 
     1    1.39D0 - 0.815D0*EXP(-2.54D0*YY) - 0.025D0*EXP(-30.0D0*YY))

      G = DEXP(CLN*GL)*FPL
      TAUL = X0
      TAU = DEXP(CLN*TAUL)
C USE KTTAU TO IMPLIMENT FUTURE T TAU RELATIONS
      IF (KTTAU .EQ. 0) THEN
            TL = TTAUL0(TAU)
      ELSE IF (KTTAU .EQ. 1) THEN
            TL = TTAUL1(TAU)
      ELSE IF (KTTAU .EQ. 2) THEN
            TL = TEFFL + HRA(TAU) - HRAS
      END IF
      PL = Y(1)
C IF LMHD USE MHD EQUATION OF STATE.
      IF (LMHD)THEN
       CALL MEQOS(TL,T,PL,P,DL,D,X,Z,BETA,BETA1,BETA14,FXION,RMU,AMU,
     *   EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,LDERIV,
     *   LATMO,KSAHA)
      ELSE
       CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETA1,BETA14,FXION,RMU,AMU,
     *   EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,LDERIV,
     *   LATMO,KSAHA)
      ENDIF
      CALL GETOPAC(DL, TL, X, Z, O, OL, QOD, QOT,FXION)
      DYDX(1) = G*TAU/(P*O)
      KATM = KATM + 1
      AP = PL
      AT = TL
      IF(LSAVE .OR. LPUMOD) THEN
	 AD = DL
	 AO = O
	 AFXION(1) = FXION(1)
	 AFXION(2) = FXION(2)
	 AFXION(3) = FXION(3)
	 QTL = TL
	 QT = DEXP(CLN*TL)
	 QPL = PL
	 QP = DEXP(CLN*PL)
	 QDL = DL
	 QD = DEXP(CLN*DL)
	 QO = O
	 QOL = OL
	 QQDP = QDP
	 QQED = 0.0D0
	 QQOD = QOD
	 QQOT = QOT
	 QDEL = 0.0D0
	 QQDT = QDT
	 QDELA = DELA
	 QQCP = QCP
	 QRMU = RMU
	 QEMU = EMU
      ENDIF

      RETURN
      END
