C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C DEUTRATE - COMPUTE THE RATE OF NONEQUILIBRIUM DEUTERIUM BURNING
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C       SUBROUTINE DEUTRATE(DL,TL,X,XH2,I,ITLVL)  ! KC 2025-05-31
      SUBROUTINE DEUTRATE(DL,TL,X,I,ITLVL)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OVRTRN/ into OVRTRN_MOD.
      USE OVRTRN_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/DEUTER/ into DEUTER_MOD.
      USE DEUTER_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 AMDEUT,C21,DL,RDEUT,RDEUT2,RDEUTMAX,RHO,T9,T9M1,T9M13,T9M23,T9P13,
     *       T9P23,TFACDEUT,TL,X,Z
      INTEGER I,ITLVL
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 9/24/26 MHP via Claude
C code changed to remove dead CMIXL from COMMON/CONST3/; it is now
C passed as an explicit argument where actually used
C 10/13/26 MHP via Claude: removed the unused COMMON/NMLPAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      DATA C21/5.240358D-8/
C AMDEUT IS THE BARE DEUTERON MASS IN AMU, THE SAME VALUE AS ANUC(3)
C IN ENGEB.F.  KEEP THE TWO IN STEP.
      DATA AMDEUT/2.013553D0/
      SAVE
C T9P13 IS THE TEMPERATURE IN UNITS OF 10^9 DEGREES K TO THE PLUS 1/3
C  POWER.  MINUS IS DENOTED BY M.  HERE T9 IS THE TEMPERATURE IN UNITS
C  OF 10^9 K, CONVERTED FROM THE LOG_10 (T) AND RHO IS THE DENSITY IN
C  CGS UNITS.
      RHO=EXP(CLN*DL)
      T9 = EXP(CLN*(TL - 9.0D0))
      T9P13 = T9**CC13
      T9P23 = T9P13**2
      T9M13=1.0D0/T9P13
      T9M23=T9M13**2
      T9M1=1.0D0/T9
C MHP 5/02 ADD DEUTERIUM BURNING TERM TO THE CODE
C IF DEUTERIUM IS ABOVE A MINIMUM THRESHOLD VALUE.
C RDEUT IS THE RATE (EXCLUDING FACTORS OF THE
C ABUNDANCES) AND QRTDEUT IS THE DERIVATIVE W/R/T T.
C NOTE THAT SCREENING IS EXCLUDED - REASONABLE GIVEN
C THE LOW TEMPERATURES INVOLVED.
      Z = -3.72D0*T9M13
      TFACDEUT = 1.0D0+0.112D0*T9P13+3.38D0*T9P23+2.65D0*T9
C FACTOR OF CAVOG/AMDEUT REFLECTS AVAGADROS NUMBER DIVIDED BY THE
C MASS OF THE DEUTERON IN AMU
C 10/27/26 MHP via Claude
C code changed to correct the same two errors as in engeb.f: the
C leading power of T9 is now T9M23, not T9P23, and 3.0115D23 (that is,
C 6.023D23/2) is replaced by CAVOG/AMDEUT (CONSTANTS_MOD), here and in
C RDEUTMAX below.  Dividing by AMDEUT rather than 2 matches the
C deuteron mass ENGEB uses, ANUC(3).
      RDEUT = RHO*2.240D3*T9M23*EXP(Z)*TFACDEUT*CAVOG/AMDEUT
C NOW LIMIT DEUTERIUM BURNING IN A SURFACE CZ TO BE ON A TIME SCALE
C NO SHORTER THAN THE CONVECTIVE OVERTURN TIMESCALE.
      IF(I.GE.JCZ .AND. TAUCZ.GT.1.0D0)THEN
         RDEUTMAX = CAVOG/AMDEUT/TAUCZ
         RDEUT2 = RDEUT*X
         IF(I.EQ.JCZ)THEN
C JVS 0712 Commented out write command
c            WRITE(*,911)RDEUT2,RDEUTMAX,TAUCZ
C  911        FORMAT(1P3E15.8)
         ENDIF
         IF(RDEUT2.GT.RDEUTMAX)THEN
C JVS 0712 Commented out write command
c            WRITE(*,*)RDEUT2,RDEUTMAX
            IF(X.GT.1.0D-6)THEN
               RDEUT = RDEUTMAX/X
            ENDIF
         ENDIF
      ENDIF
      DRATE(I) = X*RDEUT*C21
      IF(ITLVL.EQ.1)THEN
         DRATE0(I) = DRATE(I)
      ENDIF
      RETURN
      END
