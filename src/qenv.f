C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C QENV
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE QENV(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,
     *                LSAVE,RL,TEFFL,X,Z,KENV,KSAHA)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/QENVMIX/ into QENVMIX_MOD.
      USE QENVMIX_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE2/ into PULSE2_MOD.
      USE PULSE2_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE1/ into PULSE1_MOD.
      USE PULSE1_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ENVPRT/ into ENVPRT_MOD.
      USE ENVPRT_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/DPMIX/ into DPMIX_MOD.
      USE DPMIX_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/COMP/ into COMP_MOD.
      USE COMP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 9/24/26 MHP via Claude
C QENV's argument list must stay fixed: it is invoked polymorphically as
C the DERIV callback by MMID/BSSTEP (see EXTERNAL QENV in envint.f),
C which always calls it with this exact original argument list. CMIXL
C cannot be added here as a normal argument; it is relayed instead via
C COMMON/QENVMIX/, set by ENVINT immediately before every code path that
C may reach QENV (direct calls and the BSSTEP/MMID callback alike).

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION Y(3),DYDX(3),FXION(3)
C 10/13/26 MHP via Claude: removed the unused COMMON/NMLPAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude
C code changed to drop COMMON/PULSE/, declared here but never used.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      SAVE

      PL = X0
      SL = Y(1) + STOTAL
      TL = Y(2)
      RL = Y(3)
C 9/22/26 MHP via Claude
C code changed to remove the MHD equation of state
      CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETA1,BETA14,FXION,RMU,
     *   AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,
     *   LDERIV,LATMO,KSAHA)
      CALL GETOPAC(DL, TL, X, Z, O, OL, QOD, QOT, FXION)
      IOVIM = -1
      CALL TPGRAD(TL,T,PL,P,D,RL,SL,B,O,QDT,QDP,QOT,QOD,QCP,DEL,
     *     DELR,DELA,QDTT,QDTP,QAT,QAP,QACT,QACP,QACR,QCPT,QCPP,VEL,
     *     LDERIV,LCONV,FPL,FTL,TEFFL,CMIXLQ)
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
C JVS 08/25 ALSO ALWAYS SAVE ADDITIONAL INFO FOR PROFILE
      EFXION(1) = FXION(1)
      EFXION(2) = FXION(2)
      EFXION(3) = FXION(3)
      QQDP = QDP
      QQDT = QDT
      QQCP = QCP

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

C KC 2025-05-31 THESE MUST BE RETAINED FOR EXTERNAL PROCEDURE COMPATIBILITY.
      IF (.FALSE.) PRINT *, GL, LOCOND

      RETURN
      END
