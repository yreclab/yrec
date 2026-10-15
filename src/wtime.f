C$$$$$$
      SUBROUTINE WTIME(DELTS,M,OMEGA,DELTSW,DWMAX)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OLDROT/ into OLDROT_MOD.
      USE OLDROT_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
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
      DIMENSION OMEGA(JSON)
      SAVE
C  FOR ROTATING MODELS, LIMIT TIMESTEP BASED ON MAX CHANGE IN OMEGA.
C  THE USER PARAMETER DTWIND GOVERNS THE MAXIMUM CHANGE ALLOWED BETWEEN
C  MODELS.
C INPUT VARIABLES :
C DECLARED VARIABLES
C   DELTS : PREVIOUS MODEL TIMESTEP
C   M : NUMBER OF MODEL POINTS
C   OMEGA : RUN OF ANGULAR VELOCITY IN THE CURRENT MODEL.
C VARIABLES IN COMMON BLOCKS :
C   DTWIND : MAX DELTA OMEGA/OMEGA (DEFAULT =0.08).
C   WOLD : RUN OF ANGULAR VELOCITY IN THE PREVIOUS MODEL.
C
C OUTPUT VARIABLES :
C   DELTSW : ROTATION-BASED TIMESTEP.
C   DWMAX : MAXIMUM FRACTIONAL CHANGE IN OMEGA.
C

      II = 1
      DWMAX = 2.0D0*ABS(OMEGA(II)-WOLD(II))/(OMEGA(II)+WOLD(II))
      IWMAX = II
      DO 50 I = II+1,M
         TESTW=2.0D0*ABS(OMEGA(I)-WOLD(I))/(OMEGA(I)+WOLD(I))
         IF(TESTW.GT.DWMAX) THEN
            DWMAX = TESTW
            IWMAX = I
         ENDIF
 50   CONTINUE
      FAC = DWMAX/DTWIND
C  IF NO CHANGE FROM PREVIOUS MODEL,SET DELTSW TO TIMESTEP
C  STORED IN THE PREVIOUS MODEL.
C      IF (FAC.EQ.0.D0) FAC=1.0D0
      IF (FAC.EQ.0.D0)THEN
          DELTSW = 1.0D20
          GOTO 999
      ENDIF
C  RESTRICT CHANGE IN TIMESTEP TO NO MORE THAN A FACTOR OF ATIME(14)%
C UP OR DOWN.
C      TEMP=1.0D0+ATIME(14)
C MHP 10/14 USE ATIME(13) AS THE GLOBAL TIMESTEP LIMITER FOR THE CODE
      TEMP = ATIME(13)
      IF (FAC.GT.TEMP) FAC=TEMP
      IF (FAC.LT.1.0D0/TEMP) FAC=1.0D0/TEMP
      DELTSW = DELTS/FAC
 999  CONTINUE
      RETURN
      END
