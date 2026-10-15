CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     HSUBP
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE HSUBP (HCOMP,HD,HP,HR,HS,HT,JEDGE,PSCAHE)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
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
      COMMON/DEBHU/CDH,ZDH(18),XXDH,YYDH,ZZDH,DHNUE(18)
      DIMENSION HCOMP(15,JSON),HD(JSON),HP(JSON),HR(JSON),HS(JSON),
     *          HT(JSON),FXION(3)
      SAVE

C *** CALCULATES THE LOCAL PRESSURE SCALE HEIGHT AT THE EDGE OF A
C     CONVECTIVE REGION (PD DEC. 1984) 2/91 MHP REVISED FOR YREC/MARK6***
C
C  CALL EQUATION OF STATE TO DETERMINE THE MEAN MOLECULAR WEIGHT.
      LDERIV = .FALSE.
      LATMO = .TRUE.
      KSAHA = 0
      X = HCOMP(1,JEDGE)
      Z = HCOMP(3,JEDGE)
      PL = HP(JEDGE)
      TL = HT(JEDGE)
      DL = HD(JEDGE)
      IF (LDH) THEN
         XXDH = HCOMP(1,JEDGE)
         YYDH = HCOMP(2,JEDGE)+HCOMP(4,JEDGE)
         ZZDH = HCOMP(3,JEDGE)
         ZDH(1) = HCOMP(5,JEDGE)+HCOMP(6,JEDGE)
         ZDH(2) = HCOMP(7,JEDGE)+HCOMP(8,JEDGE)
         ZDH(3) = HCOMP(9,JEDGE)+HCOMP(10,JEDGE)+HCOMP(11,JEDGE)
      END IF
      CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,
     *            RMU,AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,
     *            QAT,QAP,QCPT,QCPP,LDERIV,LATMO,KSAHA)
C  COMPUTE PRESSURE SCALE HEIGHT.
      SL = HS(JEDGE)
      RL = HR(JEDGE)
      PSCAP = RMU*EXP(CLN*(TL-CGL-SL+RL+RL))
      PSCAHE = EXP(CLN*(PL + 2.0D0*RL - DL - CGL - SL))
      RETURN
      END
