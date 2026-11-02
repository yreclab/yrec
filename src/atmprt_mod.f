C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ATMPRT_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ATMPRT/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 6 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
      MODULE ATMPRT_MOD

      IMPLICIT NONE
      SAVE

      REAL*8 :: TAUL
      REAL*8 :: AP
      REAL*8 :: AT
      REAL*8 :: AD
      REAL*8 :: AO
      REAL*8 :: AFXION(3)

      END MODULE ATMPRT_MOD
