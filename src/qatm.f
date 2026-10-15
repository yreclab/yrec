C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C QATM
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE QATM(X0,Y,DYDX,B,FPL,FTL,GL,LATMO,LDERIV,LOCOND,LSAVE,
     *                RL,TEFFL,X,Z,KATM,KSAHA)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE2/ into PULSE2_MOD.
      USE PULSE2_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE1/ into PULSE1_MOD.
      USE PULSE1_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ATMPRT/ into ATMPRT_MOD.
      USE ATMPRT_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ATMOS/ into ATMOS_MOD.
      USE ATMOS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C QATM CALCULATES THE DERIVATIVE D(P)/D(TAU), USING THE EDDINGTON
C APPROXIMATION FOR A T-TAU RELATION.
C IT ALSO RETURNS TL,O, AND FXION FOR OUTPUT PURPOSES
C   Q(TAU) = 0.6666667

      PARAMETER(JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 10/13/26 MHP via Claude: removed the unused COMMON/IOUNITS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/12/26 MHP via Claude
C code changed to extend COMMON/NMLPAR/ to 234 members, adding the
C namelist variables that the physics routines read from 27 COMMON
C blocks which also held derived or working members.  Those blocks keep
C only their non-namelist members; five of them -- NEWMX, VMULT,
C PMMWIND, CCOUT1 and ENVGEN -- had nothing left and are gone.
C Derivation-only namelist variables from the same blocks went to
C COMMON/NMLBYPASS/ instead, not here.
C
C Declared identically in all 121 files that hold any of these members.
C Generated from one member list, so every copy is byte-identical; the
C linker's 'size of symbol changed' warning is the check that they are.
C 10/13/26 MHP via Claude: removed the unused COMMON/NEWOPAC/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      DIMENSION Y(3),DYDX(3),FXION(3)
C 10/13/26 MHP via Claude
C code changed to drop COMMON/PULSE/, declared here but never used.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
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
C 9/22/26 MHP via Claude
C code changed to remove the MHD equation of state
      CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETA1,BETA14,FXION,RMU,AMU,
     *   EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,LDERIV,
     *   LATMO,KSAHA)
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

C KC 2025-05-31 THESE MUST BE RETAINED FOR EXTERNAL PROCEDURE COMPATIBILITY.
      IF (.FALSE.) PRINT *, B, FTL, LOCOND, RL

      RETURN
      END
