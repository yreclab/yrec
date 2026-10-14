C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CONSTANTS_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 90 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
C CLSUN and CRSUN carry initializers, migrated from parmin.f's
C   DATA CLSUN,CRSUN/3.8515D33,6.9598D10/
C because DATA on a USE-associated name is rejected.  Both are PHYSICS
C namelist variables, so the DATA statement supplied a default the
C namelist read could override; a module initializer is applied once at
C load time, before PARMIN runs, which is the same thing.  The derived
C CLSUNL and CRSUNL are set later still, in setups.f, so the order
C initializer -> namelist read -> derivation is unchanged.
C
C The other 28 members have no initializer because none had DATA: they
C are set by executable assignment in parmin.f and setups.f, which needs
C no change under USE association.
      MODULE CONSTANTS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8 :: CLSUN = 3.8515D33
      REAL*8 :: CLSUNL
      REAL*8 :: CLNSUN
      REAL*8 :: CMSUN
      REAL*8 :: CMSUNL
      REAL*8 :: CRSUN = 6.9598D10
      REAL*8 :: CRSUNL
      REAL*8 :: CMBOL
      REAL*8 :: CLN
      REAL*8 :: CLNI
      REAL*8 :: C4PI
      REAL*8 :: C4PIL
      REAL*8 :: C4PI3L
      REAL*8 :: CC13
      REAL*8 :: CC23
      REAL*8 :: CPI
      REAL*8 :: CGAS
      REAL*8 :: CA3
      REAL*8 :: CA3L
      REAL*8 :: CSIG
      REAL*8 :: CSIGL
      REAL*8 :: CGL
      REAL*8 :: CMKH
      REAL*8 :: CMKHN
      REAL*8 :: CDELRL
      REAL*8 :: CMIXL2
      REAL*8 :: CMIXL3
      REAL*8 :: CLNDP
      REAL*8 :: CSECYR
      REAL*8 :: C_2

      END MODULE CONSTANTS_MOD
