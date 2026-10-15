C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SCVEOS_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/SCVEOS/ into this module.
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
      MODULE SCVEOS_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: NPS = 76
      INTEGER*4, PARAMETER, PRIVATE :: NTS = 63

      REAL*8    :: TLOGX(NTS)
      REAL*8    :: TABLEX(NTS,NPS,12)
      REAL*8    :: TABLEY(NTS,NPS,12)
      REAL*8    :: SMIX(NTS,NPS)
      REAL*8    :: TABLEZ(NTS,NPS,13)
      REAL*8    :: TABLENV(NTS,NPS,12)
      INTEGER*4 :: NPTSX(NTS)
      INTEGER*4 :: IDTSCV
      INTEGER*4 :: IDP

      END MODULE SCVEOS_MOD
