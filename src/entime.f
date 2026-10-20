C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ENTIME
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE ENTIME(DELTS,HL,TEFFL,M,EDELT)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OLDMOD/ into OLDMOD_MOD.
      USE OLDMOD_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 DELTS,EDELT,FAC,HL,HMAX,TEFFL,TEMP,TESTL,TESTT
      INTEGER M

C 10/13/26 MHP via Claude: removed the unused COMMON/CONSTANTS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/24/26 MHP via Claude
C code changed to remove dead CMIXL from COMMON/CONST3/; it is now
C passed as an explicit argument where actually used
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
C 10/13/26 MHP via Claude
C code changed to drop COMMON/CTLIM/, declared here but never used.
C 10/13/26 MHP via Claude: removed the unused COMMON/CENV/ declaration
C (no member referenced here; residue of the obsolete-option removals).

      DIMENSION HL(JSON)
      DIMENSION HMAX(4)  ! NHMAX(4)
      SAVE

C  THIS SR LIMITS THE TIMESTEP BASED ON THE REQUIREMENT THAT THE CHANGES FROM
C  ONE MODEL TO THE NEXT IN T,AND L BE LESS THAN THE SIZE OF THE ENVELOPE TRIANGLE
C  (TRIL AND TRIT). THIS PREVENTS EXTRAPOLATION OUTSIDE OF THE TRIANGLE
C  FOR SMALL ENVELOPE TRIANGLES.
C
C INPUT VARIABLES
C DECLARED VARIABLES :
C   DELTS : PREVIOUS MODEL TIMESTEP.
C   HL : RUN OF LUMINOSITY(AS A FUNCTION OF MASS) IN THE CURRENT MODEL.
C   TEFFL: EFFECTIVE TENPERATURE OF CURRENT MODEL
C   M : NUMBER OF POINTS IN THE MODEL.
C VARIABLES IN COMMON BLOCKS :
C   TRIL: DELT L OF ENVELOPE TRIANGLE
C   TRIT: DELT T OF ENVELOPE TRIANGLE
C   ATIME(13): maximum percentage change in the timestep from the previous one
C   HLO : RUN OF LUMINOSITY(AS A FUNCTION OF MASS) IN THE PREVIOUS MODEL.
C   TEFFLO : EFFECTIVE TEMPERATURE OF PREVIOUS MODEL
C OUTPUT VARIABLES :
C   EDELT : TIME STEP FOR REQUESTED CHANGE IN P,T,R,L.
C
C FIND MAXIMUM ABSOLUTE TIME DIFFERENCES FOR EACH QUANTITY
C
C  TEMPERATURE
      HMAX(1)=TRIDT
C  LUMINSOITY
        HMAX(2)=TRIDL

        TESTT = ABS(TEFFLO-TEFFL)
      TESTL = ABS(DLOG10(HLO(MO))-DLOG10(HL(M)))

C NOW ACTUALLY LIMIT THE TIMESTEP BY A FACTOR THAT REDUCES THE
C TIME CHANGES IN ALL QUANTITIES TO THE TRIANGLE VALUES OR LESS
      FAC = TESTT/TRIDT
      IF (TESTL/TRIDL .GT.FAC) FAC=TESTL/TRIDL
C  IF NO CHANGE FROM PREVIOUS MODEL,SET EDELT TO TIMESTEP
C  STORED IN THE PREVIOUS MODEL.
      IF (FAC .EQ. 0.0D0) FAC=1.0D0
C USE ATIME(13) AS THE GLOBAL FACTOR FOR LIMITING TIMESTEP CHANGES
      TEMP = ATIME(13)
      IF (FAC.GT.TEMP) FAC=TEMP
      IF (FAC.LT.1.0D0/TEMP) FAC=1.0D0/TEMP
      EDELT = DELTS/FAC

      RETURN
      END

