C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     GET LAOL OPACITY FOR PURE Z
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE GTPURZ(DL,TL,O,OL,QOD,QOT)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ZSLAOL/ into ZSLAOL_MOD.
      USE ZSLAOL_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ZLAOL/ into ZLAOL_MOD.
      USE ZLAOL_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      REAL*8 DL,TL,O,OL,QOD,QOT
C MHP 8/25 Removed unused variables
C      CHARACTER*256 FLAOL, FPUREZ
      DIMENSION TOP(104),TR(104),TDOR(104), DODR(52)
      DIMENSION TOP1(52),TT(52), TDOT(52)
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead OLAOL,OXA,OT,ORHO,IOLAOL,
C NUMOFXYZ,NUMRHO,NUMT from COMMON/NWLAOL/, and dead COMMON/SLAOL/
C (never used, sole other declarers already removed with LAOL89)
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
C DBG 12/95 ARRAYS FOR PURE Z TABLE
      SAVE
C
C     1. CUBIC SPLINE INTERPOLATE IN DENSITY
C     2. CUBIC SPLINE INTERPOLATE IN TEMPERATURE
C     IF WITHIN TOLLAOL OF EDGE THEN LINEAR EXTRAPOLATE
C
C     TOLLAOL PERMITS SOME EXTRAPLOATION BEYOND TABLE EDGE.
      TOLLOG = LOG(TOLLAOL)
      RTL = TL
      RDL = DL
      CALL LOCATE(ZOT,NUMTZ,RTL,JT)
      NUMTS = 0
C     GET RANGE OF FOUR TT SURROUNDING T
      CALL XRNG4(JT,NUMTZ,JT1,JT2)
      DO IT=JT1, JT2
         NUMS = NUMRSZ(IT)
         IF(NUMS .GE. 4) THEN
            DO IR=1, NUMS
               TOP(IR) = ZSLAOLL(IR,IT)
               TR(IR) = ZSRHOL(IR,IT)
               TDOR(IR) = ZSDORL(IR,IT)
            END DO
            IF (RDL.GT.TR(1) .AND. RDL.LT.TR(NUMS)) THEN
               CALL SPLINT(TR,TOP,NUMS,TDOR,RDL, ROL, KLO, KHI)
               NUMTS = NUMTS+1
               TOP1(NUMTS) = ROL
               TT(NUMTS) = ZOT(IT)
               DODR(NUMTS)=(TOP(KHI)-TOP(KLO))/(TR(KHI)-TR(KLO))
            ELSE IF (RDL.GT.TR(1)-TOLLOG .AND. RDL.LE.TR(1)) THEN
C              PUT LINEAR EXTRAPOLATION ROUTINES HERE
               SLOPE = (TOP(2)-TOP(1))/(TR(2)-TR(1))
               ROL = TOP(1)+SLOPE*(RDL-TR(1))
               NUMTS = NUMTS+1
               TOP1(NUMTS) = ROL
               TT(NUMTS) = ZOT(IT)
               DODR(NUMTS) = SLOPE
            ELSE IF (RDL.GE.TR(NUMS) .AND.
     *               RDL.LT.TR(NUMS)+TOLLOG) THEN
C              PUT LINEAR EXTRAPOLATION ROUTINES HERE
               SLOPE = (TOP(NUMS-1)-TOP(NUMS))/
     *                 (TR(NUMS-1)-TR(NUMS))
               ROL = TOP(NUMS)+SLOPE*(RDL-TR(NUMS))
               NUMTS = NUMTS+1
               TOP1(NUMTS) = ROL
               TT(NUMTS) = ZOT(IT)
               DODR(NUMTS) = SLOPE
            END IF
         ELSE
            WRITE(ISHORT,120)DL,TL
  120       FORMAT(' OUTSIDE Z OPACITY TABLE, IN DENSITY.  ',
     *     'LOG(RHO)=',1PE12.3, ' LOG(T)=', 1PE12.3)
            STOP
         END IF
      END DO
      IF(NUMTS .GE. 4) THEN
         CALL CSPLINE(TT,TOP1,NUMTS,1.0D30,1.0D30,TDOT)
         CALL SPLINT(TT,TOP1,NUMTS,TDOT,RTL, ROL, KLO, KHI)
         SLOPE=(DODR(KHI)-DODR(KLO))/(TT(KHI)-TT(KLO))
         QOD = DODR(KLO)+SLOPE*(RTL-TT(KLO))
         QOT = (TOP1(KHI)-TOP1(KLO))/(TT(KHI)-TT(KLO))
      ELSE
         WRITE(ISHORT,121)DL,TL
  121    FORMAT(' OUTSIDE Z OPACITY TABLE, IN TEMPERATURE.  ',
     *         'LOG(RHO)=',1PE12.3, ' LOG(T)=', 1PE12.3)
         STOP
      END IF
      IF(ROL .GT. 35) THEN
         O = 1.0D35
         OL = 35.0D0
      ELSE
         O = 10.0D0**ROL
         OL = ROL
      END IF
      RETURN
      END
