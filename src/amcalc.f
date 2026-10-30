C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C AMCALC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      SUBROUTINE AMCALC(SMASS,BL,TEFFL,STRUCTFACTOR)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OVRTRN/ into OVRTRN_MOD.
      USE OVRTRN_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 BL,RL,RLUM,RMASS,RPHOT,RRAD,RTAU,RTOT,SMASS,STRUCTFACTOR,
     *       TEFFL


C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 9/24/26 MHP via Claude
C code changed to remove dead CMIXL from COMMON/CONST3/; it is now
C passed as an explicit argument where actually used
C MHP 8/17 ADDED EXCEN, C_2 TO COMMON BLOCK FOR MATT ET AL. 2012 CENT. TERM
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
C code changed to retire COMMON/CWIND/.  Its namelist members moved to the
C consolidated block earlier, leaving two.  C_2 is a constant, set once in
C parmin.f, so it is now the last member of COMMON/CONSTANTS/ -- appended
C there rather than inserted, and added to every declaration so the block
C keeps one size; parmin.f DATA-initializes CLSUN and CRSUN, so a short
C declaration anywhere would be the OP95INTERP hazard again.  It may
C eventually become a namelist variable.  STRUCTFACTOR, the loss-law
C prefactor, is computed by AMCALC and read by its own two callers,
C mwind.f and mcowind.f, so it is now an AMCALC output argument.
C      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,CONSTFACTOR,STRUCTFACTOR,LJDOT0
C KC 2025-05-30 reordered common block elements
C       COMMON/PMMWIND/AWIND,LMWIND,LROSSBY,LBSCALE,PMMA,PMMB,PMMC,PMMD,PMMM,
C      *         PMMJD,PMMMD,PMMSOLP,PMMSOLW,PMMSOLTAU
C 10/12/26 MHP via Claude
C code changed to remove the trailing CHARACTER member AWIND from
C COMMON/PMMWIND/.  Character data does not belong in a COMMON block, and
C this file never referenced AWIND.  It is now a local of parmin.f, the
C only routine that reads it.  Being last, its removal moves no other
C member, and the block shrinks identically in all five files.
      SAVE

C G Somers, 6/16
C THIS SHORT SUBROUTINE WILL USE THE DELIVERED STRUCTURAL VARIABLES TO DETERMINE
C THE STRENGTH OF THE TORQUE, ACCORDING TO THE MATT ET AL. (2012) FORMULATION.
C
C COLLECT THE RELEVANT STRUCTURE VARIABLES, AND
C     MASS
      RMASS = SMASS
C     RADIUS
      RL = 0.5D0*(BL+CLSUNL-C4PIL-CSIGL-4.D0*TEFFL)
      RTOT  = DEXP(CLN*RL)
      RRAD = RTOT/CRSUN
C     LUMINOSITY
      RLUM = 10.**BL
C     PHOTOSPHERIC PRESSURE
      RPHOT = 10.**(PPHOT0+FRACSTEP*(PPHOT-PPHOT0))/(10.**PMMSOLP)
C     CONVECTIVE OVERTURN TIMESCALE
      IF(LROSSBY)THEN
         RTAU = (TAUCZ0+FRACSTEP*(TAUCZ-TAUCZ0))/PMMSOLTAU
      ELSE
         RTAU = 1.
      ENDIF
C     COMBINE THEM ALL
      STRUCTFACTOR = RMASS**EXM * RRAD**EXR * RLUM**EXL * RPHOT**EXPR
     *               * RTAU**EXTAU
      RETURN
      END
