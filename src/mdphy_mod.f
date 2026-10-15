C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MDPHY_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/MDPHY/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 10 files declared this block identically, so the USE
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
      MODULE MDPHY_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: JSON = 5000

      REAL*8 :: AMUM(JSON)
      REAL*8 :: CPM(JSON)
      REAL*8 :: DELM(JSON)
      REAL*8 :: DELAM(JSON)
      REAL*8 :: DELRM(JSON)
      REAL*8 :: ESUMM(JSON)
      REAL*8 :: OM(JSON)
      REAL*8 :: QDTM(JSON)
      REAL*8 :: THDIFM(JSON)
      REAL*8 :: VELM(JSON)
      REAL*8 :: VISCM(JSON)
      REAL*8 :: EPSM(JSON)

      END MODULE MDPHY_MOD
