C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PULSE1_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE1/ into this module.
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
      MODULE PULSE1_MOD
C 10/20/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C a PRIVATE copy here.
      USE DIMENSIONS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: PQDP(JSON)
      REAL*8    :: PQED(JSON)
      REAL*8    :: PQET(JSON)
      REAL*8    :: PQOD(JSON)
      REAL*8    :: PQOT(JSON)
      REAL*8    :: PQCP(JSON)
      REAL*8    :: PRMU(JSON)
      REAL*8    :: PQDT(JSON)
      REAL*8    :: PEMU(JSON)
      LOGICAL*4 :: LPUMOD

      END MODULE PULSE1_MOD
