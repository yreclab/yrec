C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C FAC_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/FAC/ into this module.
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
C The dimension parameters are PRIVATE: the importing files
C declare their own PARAMETER statements for these, and an
C exported copy would collide with them.
      MODULE FAC_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: NT = 57
      INTEGER*4, PARAMETER, PRIVATE :: NTC = 76

      INTEGER*4 :: IMIN(NT)
      INTEGER*4 :: IMINMAX(NT)
      INTEGER*4 :: JP
      INTEGER*4 :: KP(4)
      INTEGER*4 :: IMIN2(NTC)
      INTEGER*4 :: IMINMAX2(NTC)

      END MODULE FAC_MOD
