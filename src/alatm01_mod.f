C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ALATM01_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ALATM01/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 4 files declared this block identically, so the USE
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
      MODULE ALATM01_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: NGA = 25
      INTEGER*4, PARAMETER, PRIVATE :: NTA = 250

      REAL*8    :: TEFFLs(NTA)
      REAL*8    :: GLs(NGA)
      REAL*8    :: FeHs(NGA)
      REAL*8    :: ALPHAs(NGA)
      REAL*8    :: PLs(NTA,NGA)
      REAL*8    :: P100Ls(NTA,NGA)
      REAL*8    :: T100Ls(NTA,NGA)
      LOGICAL*4 :: LOldNextGen
      INTEGER*4 :: nTEFF
      INTEGER*4 :: nGL
      INTEGER*4 :: nFeH
      INTEGER*4 :: nALPHA

      END MODULE ALATM01_MOD
