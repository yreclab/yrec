C$$$$$$
C SOLID
      SUBROUTINE SOLID(HD,HJM,HR,HS,HS2,JSTART,JEND,ETA2,HI,OMEGA,
     *                 QIW,R0,M)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/ERRMOM/TOLERI
C 10/13/26 MHP via Claude: removed the unused COMMON/IOUNITS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 9/94 ADDED DISK LOCKING OPTION - FLAG, TIME OVER WHICH LOCKING
C IS ENFORCED, AND PERIOD AT WHICH LOCKING IS SET ARE OPTIONS.
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
      COMMON/DISK/SAGE
      DIMENSION HJM(JSON),HI(JSON),QIW(JSON),OMEGA(JSON),ETA2(JSON),
     * R0(JSON),HD(JSON),HS2(JSON),HR(JSON),HS(JSON)
      SAVE
C  GIVEN THE ANGULAR MOMENTUM PER UNIT MASS, SOLID RETURNS THE ROTATION
C  RATE OMEGA.  IT ALSO CALLS MOMI, WHICH CALCULATES THE MOMENT OF INERT
C  AND R0 AND ETA2; R0 AND ETA2 ARE NEEDED BY FPFT.
      CZJ = 0.0D0
      WSUM = 0.0D0
      ICOUNT = 0
C  FIND THE TOTAL ANGULAR MOMENTUM OF SHELLS JSTART TO JEND.
C  ALSO MAKE A FIRST GUESS AT OMEGA BY AVERAGING THE PREVIOUS VALUES.
      DO 10 J = JSTART,JEND
         CZJ = CZJ + HS2(J)*HJM(J)
         WSUM = WSUM + OMEGA(J)
   10 CONTINUE
C MHP 9/94 OPTION ADDED TO ENFORCE DISK LOCKING UP TO A GIVEN AGE IN
C THE SURFACE C.Z. ONLY.
      LOCK = .FALSE.
      IF(JEND.EQ.M .AND. JSTART.NE.JEND .AND. LDISK .AND.
     *   SAGE.LE.TDISK)LOCK = .TRUE.
      IF(.NOT.LOCK)THEN
         WGUESS = WSUM/DFLOAT(JEND - JSTART + 1)
      ELSE
         WGUESS = PDISK
      ENDIF
   20 DO 30 J = JSTART,JEND
         OMEGA(J) = WGUESS
   30 CONTINUE
C  DETERMINE THE MOMENTS OF INERTIA OF SHELLS JSTART TO JEND WITH OMEGA
C  EQUAL TO WGUESS.
      CALL SHAPE(HD,HR,HS,JSTART,JEND,OMEGA,ETA2,R0)
C       CALL MOMI(ETA2,HD,HR,HS,HS2,JSTART,JEND,OMEGA,R0,HI,QIW,M)  ! KC 2025-05-31
      CALL MOMI(ETA2,HR,HS,HS2,JSTART,JEND,OMEGA,R0,HI,QIW)
      CZI = 0.0D0
      CZQIW = 0.0D0
C  FIND TOTAL MOMENT OF INERTIA(CZI) AND TOTAL DI/DOMEGA (CZQIW)
      DO 40 J = JSTART,JEND
         CZI = CZI + HI(J)
         CZQIW = CZQIW + QIW(J)
   40 CONTINUE
      CZJNEW = WGUESS*CZI
C  CHECK IF THE TOTAL ANGULAR MOMENTUM FOUND WITH OMEGA = WGUESS IS CLOS
C  ENOUGH.  IF NOT, CALCULATE DELTA OMEGA AND TRY AGAIN WITH A NEW WGUES
      DELJ = CZJ - CZJNEW
      IF(LOCK)GOTO 45
      IF(DABS(DELJ/CZJ).GT.TOLERI) THEN
         IF(ICOUNT.LT.20) THEN
            ICOUNT = ICOUNT + 1
            DELW = DELJ/(CZI + WGUESS*CZQIW)
            WGUESS = WGUESS + DELW
            GOTO 20
         ENDIF
      ENDIF
 45   CONTINUE
      DO 50 J = JSTART,JEND
         HJM(J) = HI(J)*OMEGA(J)/HS2(J)
   50 CONTINUE

      RETURN
      END
