      SUBROUTINE LAX_WENDROF1(DT,ECOD1,EM,NPT,STOT,EX_H,LDOLI)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD

      PARAMETER (JSON=5000)
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
      COMMON/GRAVEZ/ECOD1Z(JSON),ECOD1Z_H(JSON),ECOD2Z_H(JSON),
     *              EQCOD1Z_H(JSON),EQCOD2Z_H(JSON),EZ(JSON),
     *              EZ_H(JSON)
      DIMENSION ECOD1(JSON),EM(JSON),EX_H(JSON)
      SAVE

C VARIABLES : ECOD1 IS RUN OF DIFFUSION COEFFICIENTS, EM IS RUN OF MASSES,
C AND EX_H IS RUN OF CHANGES IN THE HYDROGEN ABUNDANCE.
      DT2 = 0.5D0*DT*C4PI
C CENTRAL BOUNDARY CONDITION
      EMASS=EM(2)
      DEX_H = DT2*ECOD1(2)/EMASS
      EX_H(1) = DEX_H
C GENERAL CASE
      DO 10 I = 2,NPT-2
         EMASS=EM(I+1)-EM(I)
         DEX_H = DT2*(ECOD1(I+1)-ECOD1(I))/EMASS
         EX_H(I) = DEX_H
   10 CONTINUE
C SURFACE BOUNDARY CONDITION.
      EMASS = STOT-EM(NPT-1)
      DEX_H = -DT2*ECOD1(NPT-1)/EMASS
      EX_H(NPT-1) = DEX_H
C METAL DIFFUSION
      IF(LDIFZ.AND..NOT.LDOLI)THEN
C CENTRAL BOUNDARY CONDITION
         EMASS=EM(2)
         DEZ_H = DT2*ECOD1Z(2)/EMASS
         EZ_H(1) = DEZ_H
C GENERAL CASE
         DO I = 2,NPT-2
            EMASS=EM(I+1)-EM(I)
            DEZ_H = DT2*(ECOD1Z(I+1)-ECOD1Z(I))/EMASS
            EZ_H(I) = DEZ_H
         END DO
C SURFACE BOUNDARY CONDITION.
         EMASS = STOT-EM(NPT-1)
         DEZ_H = -DT2*ECOD1Z(NPT-1)/EMASS
         EZ_H(NPT-1) = DEZ_H
      ENDIF
      RETURN
      END
