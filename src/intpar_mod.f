C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C INTPAR_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/INTPAR/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 3 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
C
C The initializers are the first DATA migration of the conversion.  They
C carry over parmin.f's
C   DATA STOLR0,IMAX,NUSE/1.0D-3,11,7/
C which had to move, because DATA on a USE-associated name is rejected
C ("Cannot change attributes of USE-associated symbol").
C
C The semantics are unchanged.  All three are PHYSICS namelist variables:
C the DATA statement supplied the default before the namelist read could
C override it, and a module initializer is likewise applied once at load
C time, before PARMIN runs.  It is also a standards improvement, since
C DATA on a COMMON member outside BLOCK DATA is non-standard.
      MODULE INTPAR_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: STOLR0 = 1.0D-3
      INTEGER*4 :: IMAX   = 11
      INTEGER*4 :: NUSE   = 7

      END MODULE INTPAR_MOD
