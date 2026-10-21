C $$$$$$
      SUBROUTINE EQUAL_TO_MODEL(DT,ER,EX,IBEGIN,IEND,NPT,HCOMP,HQPR,
     *                          HRU,HS1,HTU,M,STOT)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/GRAVEZ/ into GRAVEZ_MOD.
      USE GRAVEZ_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONFAC/ into CONFAC_MOD.
      USE CONFAC_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 DT,DXMOD,DZMOD,ER,EX,FACINTERP,HCOMP,HQPR,HRU,HS1,HTU,
     *       RADMOD,STOT,TABLER,XMAX,XMINIM,ZMAX,ZMIN,ZZ,ZZ2
      INTEGER I,IBEGIN,IEND,J,JMIN,K,K0,M,NPT
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
      DIMENSION ER(JSON),EX(JSON),HCOMP(15,JSON),HQPR(JSON),HRU(JSON),
     *          HS1(JSON),HTU(JSON),TABLER(4),FACINTERP(4)
      SAVE
C  TRANSFORM BACK TO ORIGINAL GRID OF MODEL POINTS FROM EQUALLY
C  SPACED GRID.
      XMINIM = 0.0D0
      DO 10 I = IBEGIN,1,-1
         HCOMP(1,I)=MAX(HCOMP(1,I) + EX(1),XMINIM)
   10 CONTINUE
C MHP 3/94 ADDED METAL DIFFUSION
C NOTE THAT BECAUSE METALS SINK, AND HYDROGEN RISES, THE FAILSAFES
C ARE OPPOSITE (GUARDING AGAINST NEGATIVE X AND Z>1 RESPECTIVELY).
      IF(LDIFZ)THEN
         DO I = IBEGIN,1,-1
            ZMAX = 1.0D0 - HCOMP(1,I) - HCOMP(4,I)
            ZZ=MIN(HCOMP(3,I)+EZ(1),ZMAX)
            ZZ2 = ZZ/HCOMP(3,I)
            HCOMP(3,I) = ZZ
            DO J = 5,11
               HCOMP(J,I) = ZZ2*HCOMP(J,I)
            END DO
            HCOMP(2,I)=1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
         END DO
      ELSE
         DO I = IBEGIN,1,-1
            HCOMP(2,I)=1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
         END DO
      ENDIF
      JMIN=2
      DO 20 I=IBEGIN+1,IEND-1
         DO 30 J=JMIN,NPT

C  FIND EQUALLY SPACED GRID POINTS CLOSEST TO THE MODEL POINT.
            IF (J .EQ. 0) PRINT*, 'line 47 etm'
            IF(ER(J).GE.HRU(I))THEN

C  ENSURE THAT FIRST INTERP. POINT NO LESS THAN FIRST EQUALLY SPACED POINT.
               K0 = MAX(J-2,1)
C  ENSURE THAT LAST INTERP. POINT NO GREATER THAN LAST EQUALLY SPACED POINT.
               K0 = MIN(K0,NPT-3)
C JVS fix for NPT = 3?
               IF (K0 .EQ. 0) K0=1
               JMIN=J
               GOTO 40
            ENDIF
   30    CONTINUE
         K0 = NPT-3
         JMIN=NPT
   40    CONTINUE

         DO 50 K=1,4
            TABLER(K)=ER(K0+K-1)
   50    CONTINUE
         RADMOD=HRU(I)
C  FIND 4 POINT LAGRANGIAN INTERPOLATION FACTORS.
         CALL INTRP2(TABLER,FACINTERP,RADMOD)
C  PERFORM 4 POINT LAGRANGIAN INTERPOLATION FOR CHANGE IN X.
         DXMOD = FACINTERP(1)*EX(K0)+FACINTERP(2)*EX(K0+1)+
     *             FACINTERP(3)*EX(K0+2)+FACINTERP(4)*EX(K0+3)
         XMAX = 1.0D0 - HCOMP(3,I) - HCOMP(4,I)
         HCOMP(1,I)=MIN(HCOMP(1,I) + DXMOD,XMAX)
C MHP 3/94 ADDED METAL DIFFUSION
         IF(LDIFZ)THEN
            ZMAX = 1.0D0 - HCOMP(1,I) - HCOMP(4,I)
            DZMOD = FACINTERP(1)*EZ(K0)+FACINTERP(2)*EZ(K0+1)+
     *             FACINTERP(3)*EZ(K0+2)+FACINTERP(4)*EZ(K0+3)
            ZZ = MIN(HCOMP(3,I)+DZMOD,ZMAX)
            ZZ2 = ZZ/HCOMP(3,I)
            HCOMP(3,I)=ZZ
            DO J = 5,11
               HCOMP(J,I) = ZZ2*HCOMP(J,I)
            END DO
            HCOMP(2,I)=1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
         ELSE
            HCOMP(2,I)=1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
         ENDIF
   20 CONTINUE
      DO 60 I = IEND,M
         XMAX = 1.0D0 - HCOMP(3,I) - HCOMP(4,I)
         HCOMP(1,I)=MIN(HCOMP(1,I) + EX(NPT),XMAX)
   60 CONTINUE
C MHP 3/94 ADDED METAL DIFFUSION
      IF(LDIFZ)THEN
         ZMIN = 0.0D0
         DO I = IEND,M
            ZZ = MAX(HCOMP(3,I)+EZ(NPT),ZMIN)
            ZZ2 = ZZ/HCOMP(3,I)
            HCOMP(3,I) = ZZ
            DO J = 5,11
               HCOMP(J,I) = ZZ2*HCOMP(J,I)
            END DO
            HCOMP(2,I)=1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
         END DO
      ELSE
         DO I = IEND,M
            HCOMP(2,I)=1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
         END DO
      ENDIF
      DO 70 I=1,M

         HRU(I)=HRU(I)/CON_RAD
         HTU(I)=HTU(I)/CON_TEMP
         HS1(I)=HS1(I)/CON_MASS
         HQPR(I)=HQPR(I)*CON_RAD
   70 CONTINUE
      DT=DT*CON_TIME
      STOT=STOT/CON_MASS
      RETURN
      END
