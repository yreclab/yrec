C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C QENV
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE QENV(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,
     *                LSAVE,RL,TEFFL,X,Z,KENV,KSAHA)

      use params, only : json
      use settings, only : STOTAL  ! /COMP/
      use settings, only : CLN, C4PIL  ! /CONST1/
      use settings, only : CGL  ! /CONST2/
      use settings, only : IOVIM  ! /DPMIX/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION Y(3),DYDX(3),FXION(3)
      COMMON/PULSE1/PQDP(JSON),PQED(JSON),PQET(JSON),
     *   PQOD(JSON), PQOT(JSON), PQCP(JSON), PRMU(JSON),
     *   PQDT(JSON),PEMU(JSON),LPUMOD
      COMMON/PULSE2/QQDP,QQED,QQET,QQOD,QQOT,QDEL,
     *      QDELA, QQCP, QRMU, QTL, QPL, QDL, QO, QOL,
     *      QT, QP, QQDT, QEMU, QD, QFS
      COMMON/ENVPRT/EP,ET,ER,ES,ED,EO,EBETA,EDEL(3),EFXION(3),EVEL
      COMMON/MHD/LMHD,IOMHD1,IOMHD2,IOMHD3,IOMHD4,IOMHD5,IOMHD6,
     1           IOMHD7, IOMHD8
      SAVE

      PL = X0
      SL = Y(1) + STOTAL
      TL = Y(2)
      RL = Y(3)
      IF(LMHD)THEN
         CALL MEQOS(TL,T,PL,P,DL,D,X,Z,BETA,BETA1,BETA14,FXION,RMU,
     *   AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,
     *   LDERIV,LATMO,KSAHA)
      ELSE
         CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETA1,BETA14,FXION,RMU,
     *   AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,
     *   LDERIV,LATMO,KSAHA)
      ENDIF
      CALL GETOPAC(DL, TL, X, Z, O, OL, QOD, QOT, FXION)
      IOVIM = -1
      CALL TPGRAD(TL,T,PL,P,D,RL,SL,B,O,QDT,QDP,QOT,QOD,QCP,DEL,
     *     DELR,DELA,QDTT,QDTP,QAT,QAP,QACT,QACP,QACR,QCPT,QCPP,VEL,
     *     LDERIV,LCONV,FPL,FTL,TEFFL)
      DYDX(1) = -DEXP(CLN*(C4PIL+4.0D0*RL+PL-CGL-SL-SL))/FPL
      DYDX(2) = DEL
      DYDX(3) = -DEXP(CLN*(PL+RL-CGL-SL-DL))*FPL
      KENV = KENV + 1
C 07/02 ALWAYS STORE THE BASIC STRUCTURE VARIABLES.
      EP = PL
      ET = TL
      ES = SL - STOTAL
      ER = RL
      ED = DL
      EVEL = VEL
C JVS 08/13 ALWAYS STORE GRADIENTS (FOR TRACKING CZ)
       EDEL(1) = DELR
       EDEL(2) = DELA
       EDEL(3) = DEL
       EBETA = BETA ! added 03/14

      IF(LSAVE .OR. LPUMOD) THEN
C       EP = PL
C       ET = TL
C       ES = SL - STOTAL
C       ER = RL
C       ED = DL
       EO = O
C       EBETA = BETA
C       EDEL(1) = DELR
C       EDEL(2) = DELA
C       EDEL(3) = DEL
       EFXION(1) = FXION(1)
       EFXION(2) = FXION(2)
       EFXION(3) = FXION(3)
C       EVEL = VEL
       QTL = TL
       QT = DEXP(CLN*TL)
       QPL = PL
       QP = DEXP(CLN*PL)
       QDL = DL
       QD = DEXP(CLN*DL)
       QO = O
       QOL = OL
       QFS = DEXP(CLN*(SL-STOTAL))
       QQDP = QDP
       QQED = 0.0D0
       QQOD = QOD
       QQOT = QOT
       QDEL = DEL
       QQDT = QDT
       QDELA = DELA
       QQCP = QCP
       QRMU = RMU
       QEMU = EMU
      ENDIF

      RETURN
      END
