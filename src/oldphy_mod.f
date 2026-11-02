C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C OLDPHY_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OLDPHY/ into this module.
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
      MODULE OLDPHY_MOD
C 10/20/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C a PRIVATE copy here.
      USE DIMENSIONS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8 :: DELO(JSON)
      REAL*8 :: DELAO(JSON)
      REAL*8 :: AMUO(JSON)
      REAL*8 :: OO(JSON)
      REAL*8 :: CPO(JSON)
      REAL*8 :: QDTO(JSON)
      REAL*8 :: VELO(JSON)
      REAL*8 :: VISCO(JSON)
      REAL*8 :: THDIFO(JSON)
      REAL*8 :: ESUMO(JSON)
      REAL*8 :: DELRO(JSON)
      REAL*8 :: EPSO(JSON)

      END MODULE OLDPHY_MOD
