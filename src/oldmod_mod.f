C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C OLDMOD_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OLDMOD/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 17 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
      MODULE OLDMOD_MOD
C 10/20/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C a PRIVATE copy here.
      USE DIMENSIONS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: HPO(JSON)
      REAL*8    :: HTO(JSON)
      REAL*8    :: HRO(JSON)
      REAL*8    :: HLO(JSON)
      REAL*8    :: HDO(JSON)
      REAL*8    :: HCOMPP(15,JSON)
      REAL*8    :: HSS(JSON)
      LOGICAL*4 :: LCO(JSON)
      LOGICAL*4 :: LCZO(JSON)
      REAL*8    :: TEFFLO
      INTEGER*4 :: MO

      END MODULE OLDMOD_MOD
