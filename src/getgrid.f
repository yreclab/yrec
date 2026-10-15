C$$$$$$
      SUBROUTINE GETGRID(HL,HP,HS,IBEG,IEND,M)
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
C 10/13/26 MHP via Claude: removed the unused COMMON/CTOL/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C OUTPUT VARIABLES
      COMMON/EGRID/CHI(JSON),ECHI(JSON),ES1(JSON),DCHI,NTOT
C INPUT VARIABLES
      DIMENSION HL(JSON),HP(JSON),HS(JSON)
C LOCAL VARIABLES
      DIMENSION YTAB(JSON)
      SAVE
C THIS ROUTINE FORMS THE SUM OF CHI, DEFINED AS
C CHI = LOG(M)/DM + L/(LTOT*DL) - LOG(P)/DP, WHERE DM, DP, AND DL ARE
C THE POINT SPACINGS FOR LOG MASS, LUMINOSITY, AND PRESSURE RESPECTIVELY.
C THIS ROUTINE TRANSFORMS THESE VARIABLES TO AN EQUALLY SPACED GRID FROM
C THE FIRST POINT TO THE LAST POINT.  IT RETURNS A SET OF EQUALLY SPACED
C CHI VALUES AND THEIR LOCATION IN MASS.
C
C USE THE MODEL CRITERIA FOR ASSIGNING THE SPACING BETWEEN GRID POINTS.
      DM = HPTTOL(2)
      DL = HPTTOL(9)*HL(M)
      DP = HPTTOL(11)
      NTAB = IEND - IBEG + 1
      DO II = 1, NTAB
         I = IBEG + II - 1
         CHI(II) = HS(I)/DM+HL(I)/DL-HP(I)/DP
      END DO
C DEFINE NTOT EQUAL TO NTAB
      NTOT = NTAB
C TOTAL NUMBER OF ZONES IS MODULUS OF FINAL CHI PLUS ONE.
C      NTOT = INT(CHI(NTAB)-CHI(1))+1
C FOR ROTATION PURPOSES, DEFINE THE MINIMUM NUMBER OF
C EQUALLY SPACED SHELLS AS 3.
      NTOT = MAX(NTOT,3)
C EQUALLY SPACED INCREMENT IN CHI
C      CHT = 0.5D0*(CHI(NTAB)+CHI(NTAB-1))
C      CHB = 0.5D0*(CHI(2)+CHI(1))
C      DCHI = (CHT-CHB)/FLOAT(NTOT-2)
      DCHI = (CHI(NTAB)-CHI(1))/DFLOAT(NTOT-1)
C ASSIGN VECTOR OF EQUALLY SPACED CHI
C       ECHI(1) = CHB - 0.5D0*DCHI
C       DO I = 2,NTOT
C          ECHI(I) = ECHI(I-1)+DCHI
C       END DO
      ECHI(1) = CHI(1)
      DO I = 2,NTOT
         ECHI(I) = ECHI(I-1)+DCHI
      END DO
C NOW ASSIGN MASSES TO THE NEW EQUALLY SPACED GRID POINTS.
C PERFORM INTERPOLATION IN LOG MASS - CONSISTENT WITH CHI DEFINED
C IN LOG M, LOG P, ETC.
      DO I = 1,NTAB
         YTAB(I) = HS(IBEG+I-1)
      END DO
      CALL OSPLIN(ECHI,ES1,CHI,YTAB,NTAB,NTOT)
C TRANSFORM TO PHYSICAL MASS (GM)
      DO I = 1,NTOT
         ES1(I) = EXP(CLN*ES1(I))
      END DO
      RETURN
      END
