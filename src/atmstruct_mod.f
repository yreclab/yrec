C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ATMSTRUCT_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ATMSTRUCT/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 2 files declared this block identically, so the USE
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
      MODULE ATMSTRUCT_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: JSON = 5000

      REAL*8    :: ATMOP(JSON)
      REAL*8    :: ATMOT(JSON)
      REAL*8    :: ATMOD(JSON)
      REAL*8    :: ATMOR(JSON)
      REAL*8    :: ADELS(3,JSON)
      REAL*8    :: ABETAS(JSON)
      REAL*8    :: AGAM1(JSON)
      REAL*8    :: AQDT(JSON)
      REAL*8    :: AFXIONS(3,JSON)
      REAL*8    :: ATMOO(JSON)
      REAL*8    :: ATMOCP(JSON)
      INTEGER*4 :: NUMATM

      END MODULE ATMSTRUCT_MOD
