C $$$$$$
      SUBROUTINE LAX_WENDROF2(DT,ECOD1_H,EM_H,EX,NPT,STOT,LDOLI)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/GRAVEZ/ into GRAVEZ_MOD.
      USE GRAVEZ_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
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
      DIMENSION ECOD1_H(JSON),EM_H(JSON),EX(JSON)
      SAVE

      DT2 = DT*C4PI
C CENTRAL BOUNDARY CONDITION
      EMASS=EM_H(1)
      DEX = DT2*ECOD1_H(1)/EMASS
      EX(1) = EX(1)+DEX
C    99 FORMAT(5X,1P2E15.7)
C GENERAL CASE
      DO 10 I = 2,NPT-1
         EMASS=EM_H(I)-EM_H(I-1)
         DEX = DT2*(ECOD1_H(I)-ECOD1_H(I-1))/EMASS
         EX(I) = EX(I)+DEX
   10 CONTINUE
C SURFACE BOUNDARY CONDITION.
      EMASS = STOT-EM_H(NPT-1)
      DEX = -DT2*ECOD1_H(NPT-1)/EMASS
      EX(NPT) = EX(NPT)+DEX
C MHP 3/94 ADDED METAL DIFFUSION.
      IF(LDIFZ.AND..NOT.LDOLI)THEN
         EMASS = EM_H(1)
         DEZ = DT2*ECOD1Z_H(1)/EMASS
         EZ(1) = EZ(1)+DEZ
C GENERAL CASE
         DO I = 2,NPT-1
            EMASS=EM_H(I)-EM_H(I-1)
            DEZ = DT2*(ECOD1Z_H(I)-ECOD1Z_H(I-1))/EMASS
            EZ(I) = EZ(I)+DEZ
         END DO
C SURFACE BOUNDARY CONDITION.
         EMASS = STOT-EM_H(NPT-1)
         DEZ = -DT2*ECOD1Z_H(NPT-1)/EMASS
         EZ(NPT) = EZ(NPT)+DEZ
      ENDIF
      RETURN
      END
