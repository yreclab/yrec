C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     LL95TBL
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE LL95TBL(FLIV95)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OP95INTERP/ into OP95INTERP_MOD.
      USE OP95INTERP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/LLOT95A/ into LLOT95A_MOD.
      USE LLOT95A_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 XX,XXT,Z,ZZ
      INTEGER I,IX,IZ,J,N,NFMT,NMAX,NN,NUMD,NUMX,NUMXZ,NUMZ
c MHP 7/98 MODIFIED TO READ IN ALL METAL ABUNDACES FOR OPACITY TABLES.
      PARAMETER (NUMD=19)
      PARAMETER (NUMX=10)
      PARAMETER (NUMZ=13)
      PARAMETER (NUMXZ=126)
      CHARACTER*256 FLIV95
C MHP 8/25 Removed character file names from common block
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      SAVE
C FULL SET OF TABLES: OPACITY AS A FUNCTION OF Z AND X, T, RHO/T6**3
C TABLES ARE INCREMENTED IN SETS OF NZ*NX.  SO THE TABLES FOR THE
C THIRD METAL ABUNDANCE (3 X 10**-4)BEGIN AT TABLE 21 AND END AT TABLE 30.
C FOR THE HIGH VALUES OF Z, THE NUMBER OF X TABLES IS NOT THE SAME (I.E.
C X<0.9 FOR Z=0.1).
C FOR EACH COMPOSITION A FULL GRID IN (T,RHO/T6**3) IS RETAINED.
C INDICES FOR INTERPOLATION IN Z,X,T, AND R; INTERPOLATION FACTORS FOR
C Z,X,T, AND R (AND DERIVATIVE FACTORS FOR T AND RHO); AND DATA FOR
C LINEAR EXTRAPOLATION WHEN OUTSIDE THE TABLE IN RHO.
C 10/9/26 MHP via Claude
C code changed to merge COMMON/OP95INDX/ into COMMON/OP95INTERP/ (see
C getopal95.f for the full rationale). This file declares the FULL
C block, not just the JZ..JD prefix it originally needed: it has its
C own DATA statement initializing JZ,JX,JT,JD below, and mixing a
C DATA-initialized short declaration of a COMMON block with a larger
C declaration of the same name elsewhere is a genuine linker/ABI
C hazard (confirmed: this caused NaN corruption when first tried as a
C prefix -- see the linker's "size of symbol changed" warning).
C Declaring the full block here avoids any size mismatch.
C 10/13/26 MHP via Claude
C code changed to rename COMMON/OP95INTERP/'s RL and RLL to RHO_T63L and
C RHO_T63LL.  RL is log(rho/T6**3), set here as RL = DL - 3*(TL-6); the
C old names clash with RL and RLL as used for radius throughout the rest
C of the code, which is why main.f declared only a 10-member prefix of
C this block to avoid importing them.  With the clash gone main.f can
C declare the full block, which a USE statement will require once this
C becomes a module.
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove dead opacity-table Z-value inputs
C (this also fixes a pre-existing COMMON /NEWOPAC/ layout mismatch:
C  this file previously omitted TMOLMIN,TMOLMAX,LALEX06, which every
C  other file sharing this block declares)
C 9/24/26 MHP via Claude
C code changed to merge COMMON /MISCOPAC/ and COMMON/NWLAOL/ into
C COMMON /NEWOPAC/
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
C NUMBER OF COMPOSITION TABLES AT LOWER Z FOR EACH ABUNDANCE
C NUMBER OF X TABLES AT EACH Z
C TABULTED SET OF X
C TABULATED SET OF Z
c INDICES FOR INTERPOLATION
C  LOCAL VECTOR, USED TO SKIP LONG HEADER.
      CHARACTER*132 DUMMY
C     READ IN OPACITY TABLES, SKIPPING HEADER.  HEY, IT WORKS.
      OPEN(ILIV95,FILE=FLIV95,STATUS='OLD',ACCESS='SEQUENTIAL')
      NFMT=1

 10   READ(ILIV95,1,END=9999)DUMMY
      IF( DUMMY(NFMT:NFMT+4).NE.'TABLE' ) GO TO 10
  1   FORMAT(A)
      READ(DUMMY,'(36X,F7.4,11X,F7.4)')XX,ZZ
      IZ = 1
      IX = 1
      NN = 1
C ENTRY POINT FOR GETTING NEW TABLES.
 15   CONTINUE
      N = NZ(IZ)+IX
      IF(IX.LT.NUMX)THEN
         XXT = XXG(IX)
      ELSE
         XXT = 1.0D0 - ZZG(IZ)
      ENDIF
      IF(ZZG(IZ).NE.ZZ .OR. XXT.NE.XX)THEN
       WRITE(ISHORT,*)' OPAL95: Z ERROR INCOMPATIBLE TABLE'
         STOP
      ENDIF

C READ IN HEADER INFO: GRID IN RHO/T6**3
      READ(ILIV95,20,END=1000) (R0GR(I),I=1,NUMD)
 20   FORMAT(///,4X,19F7.1,/)
C READ IN FULL TABLE: LOG CAPPA AS A FUNCTION OF LOG T AND
C LOG R = RHO/T6**3
      DO I = 1,57
         READ(ILIV95,30,END=9999)TGR(I),(CAPPA2(N,I,J),J=1,NUMD)
      END DO
 30   FORMAT(F4.2,19F7.3)
C MHP 12/97 NOW TREAT CORNER WITHOUT DATA.
      READ(ILIV95,31,END=9999)TGR(58),(CAPPA2(N,58,J),J=1,NUMD-1)
 31   FORMAT(F4.2,18F7.3)

      CAPPA2(N,58,19) = 9.999D0
      DO I = 59,60
         READ(ILIV95,32,END=9999)TGR(I),(CAPPA2(N,I,J),J=1,NUMD-2)
 32      FORMAT(F4.2,17F7.3)
         DO J = 18,19
            CAPPA2(N,I,J) = 9.999D0
         END DO
      END DO
      DO I = 61,64
         READ(ILIV95,33,END=9999)TGR(I),(CAPPA2(N,I,J),J=1,NUMD-3)
 33      FORMAT(F4.2,16F7.3)
         DO J = 17,19
            CAPPA2(N,I,J) = 9.999D0
         END DO
      END DO
      DO I = 65,69
         READ(ILIV95,34,END=9999)TGR(I),(CAPPA2(N,I,J),J=1,NUMD-4)
 34      FORMAT(F4.2,15F7.3)
         DO J = 16,19
            CAPPA2(N,I,J) = 9.999D0
         END DO
      END DO
      I = 70
      READ(ILIV95,35,END=9999)TGR(I),(CAPPA2(N,I,J),J=1,NUMD-5)
 35   FORMAT(F4.2,14F7.3)
      DO J = 15,19
         CAPPA2(N,I,J) = 9.999D0
      END DO

C EXIT IF CORRECT NUMBER OF TABLES READ IN.
      IF(NN.GE.NUMXZ)GOTO 1000
      NN = NN + 1
C NEED TO ACCOUNT FOR FEWER X VALUES AT HIGHER Z.
      IF(IX.LE.8)THEN
         NMAX = NUMZ
      ELSE IF(IX.EQ.9)THEN
         NMAX = NUMZ - 3
      ELSE
         NMAX = NUMZ - 1
      ENDIF
C READ IN NEXT METAL ABUNDANCE (AT FIXED X) OR READ IN FIRST METAL
C ABUNDANCE AT NEXT X.
      IF(IZ.LT.NMAX)THEN
         IZ = IZ + 1
      ELSE
         IZ = 1
         IX = IX + 1
      ENDIF

C RETURN TO READ IN NEXT TABLE.
      READ(ILIV95,900)XX,ZZ
 900  FORMAT(/36X,F7.4,11X,F7.4)
      GOTO 15
 1000 CONTINUE

      CLOSE(ILIV95)
C  NOW GENERATE A TABLE AT A FIXED VALUE OF Z.
C  NOTE THAT FOR METAL DIFFUSION A 4-D INTERPOLATION (IN X,Z,T,RHO)
C  IS PERFORMED RATHER THAN A LINEAR INTERPOLATION BETWEEN TWO FIXED
C  Z TABLES.
      Z = ZOPAL951

      CALL OP95ZTAB(Z)
 9999 CONTINUE
      RETURN
      END
