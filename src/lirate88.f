C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C LIRATE88
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE LIRATE88(HCOMP,HD,HT,M,J)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OLDRAT/ into OLDRAT_MOD.
      USE OLDRAT_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OLDMOD/ into OLDMOD_MOD.
      USE OLDMOD_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NEWRAT/ into NEWRAT_MOD.
      USE NEWRAT_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD

      PARAMETER(JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
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
C G Somers END
      DIMENSION HCOMP(15,JSON),HD(JSON),HT(JSON)
      DATA TLIM/6.0D0/
      SAVE

C THIS ROUTINE COMPUTES THE BURNING RATES FOR LI6,LI7,BE9 AT THE
C BEGINNING AND END OF A TIMESTEP AND STORES THEM IN COMMON BLOCKS
C NEWRAT AND OLDRAT.
C
C BURNING RATES FROM CAUGHLIN AND FOWLER (1988).
C
      DO 100 I = 1,M
         IF(HT(I).LT.TLIM.AND.HTO(I).LT.TLIM)GOTO 110
         IF(J.EQ.1)THEN
            RHOX = EXP(CLN*HD(I))*HCOMP(1,I)
            T9=EXP(CLN*(HT(I)-9.0D0))
         ELSE
            RHOX = EXP(CLN*HDO(I))*HCOMPP(1,I)
            T9=EXP(CLN*(HTO(I)-9.0D0))
         ENDIF
         T913=T9**CC13
         T923=T913*T913
         T943=T923*T923
C MHP 10/91 ADDED DEFINITION
         T953 = T943*T913
         T932=T9**1.5D0
         T934=T9**7.5D-1
C
C LI6(P,HE3)ALPHA
C
C           FLI6=3.73D10/T923*EXP(-8.413/T913-(T9/5.50)**2)*
C    1      (1.+%TYPO%0.50*T913-0.061*T923-0.021*T9+0.006*T943+0.006*T953)
C    2      +1.33D10/T932*EXP(-17.763/T9)+1.29D9/T9*EXP(-21.820/T9)
C ***TYPO IN OLD RATE***
         FLI6=3.73D10/T923*EXP(-8.413D0/T913-(T9/5.50D0)**2)*
     1   (1.D0+0.050D0*T913-0.061D0*T923-0.021D0*T9+0.006D0*T943
     2    +0.005D0*T953)+1.33D10/T932*EXP(-17.763D0/T9)
     3    +1.29D9/T9*EXP(-21.820D0/T9)
C
C LI7(P,ALFA)HE4
C
C           FLI7=8.04D08/T923*EXP(-8.471/T913-(T9/30.068)**2)*
C    1      (1.+0.049*T913+0.230*T923+0.079*T9-0.027*T943-0.023*T953)
C    2      +1.54D06/T932*EXP(-4.479/T9)+1.07D10/T932*EXP(-30.443/T9)
         T9A = T9/(1.0D0+0.759D0*T9)
         C56 = 1.25D0*CC23
         FLI7=1.096D9/T923*EXP(-8.472D0/T913)-4.830D8*T9A**C56/
     1   T932*EXP(-8.472D0/T9A**CC13)+1.06D10/T932*EXP(-30.442D0/T9)
C
C BE9(P,GAMMA)B10
C
         FBE91=1.33D+07/T923*EXP(-10.359D0/T913-(T9/0.846D0)**2)
     1   *(1.0D0+4.0D-2*T913+1.52D0*T923+4.28D-1*T9+2.15D0*T943+
     2   1.54D0*T953) + 9.64D+4/T932*EXP(-3.445D0/T9) +
     3   2.72D+6/T932*EXP(-10.62D0/T9)
C    3      2.76D+6/T932*EXP(-10.62D0/T9) %OLD LAST LINE%
C
C BE9(P,D)2HE4 - UNCHANGED.
C
         FX=2.11D+11/T923*EXP(-10.359D0/T913-(T9/5.2D-1)**2)
     1   *(1.0D0+4.0D-2*T913+1.09D0*T923+3.07D-1*T9+3.21D0*T943
     2   +2.3D0*T953)
         EX = EXP(-3.046D0/T9)/T9
         FBE92=FX+5.79D+8*EX+8.5D+8/T934*EXP(-5.8D0/T9)
C
C BE9(P,ALPHA)LI6
C
         FBE93=FX+4.51D+8*EX+6.7D+8/T934*EXP(-5.16D0/T9)
C G Somers 6/14, SCALE BY THE NEW CROSS SECTIONS
         FLI6=SLI6*FLI6
         FLI7=SLI7*FLI7
         FBE91=SBE91*FBE91
         FBE92=SBE92*FBE92
         FBE93=SBE93*FBE93
C G Somers END
C SUM RATES
         FSBE9 = FBE91 + FBE92 + FBE93
         IF(J.EQ.1)THEN
            RLI6(I) = FLI6*RHOX
            RLI7(I) = FLI7*RHOX
            RBE9(I) = FSBE9*RHOX
         ELSE
            RLI60(I) = FLI6*RHOX
            RLI70(I) = FLI7*RHOX
            RBE90(I) = FSBE9*RHOX
         ENDIF
  100 CONTINUE
  110 CONTINUE
      DO 120 K = I,M
         RLI6(K)=0.0D0
         RLI7(K)=0.0D0
         RBE9(K)=0.0D0
         RLI60(K)=0.0D0
         RLI70(K)=0.0D0
         RBE90(K)=0.0D0
  120 CONTINUE
      RETURN
      END
