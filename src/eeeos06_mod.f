C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C EEEOS06_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/20/26 MHP via Claude
C code changed to convert COMMON/EEEOS06/ into this module, completing
C stages 3 and 4 (KNOWN_ISSUES.md issue 37).
C
C Imported with a blanket USE, the convention for the conversion.
C All 4 declarations of this block were identical, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C Both members are REAL*8, as every declaring unit already gave them.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
C
C The dimension parameters are PRIVATE: they are OPAL06 table
C dimensions, which each importing unit also declares (issue 10).
      MODULE EEEOS06_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: MX = 5
      INTEGER*4, PARAMETER, PRIVATE :: NR = 169
      INTEGER*4, PARAMETER, PRIVATE :: NT = 197

      REAL*8    :: EPL(MX,NT,NR)
      REAL*8    :: XX(MX)

      END MODULE EEEOS06_MOD
