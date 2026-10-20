C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ENVSTRUCT_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ENVSTRUCT/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 7 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
      MODULE ENVSTRUCT_MOD
C 10/20/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C a PRIVATE copy here.
      USE DIMENSIONS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: ENVP(JSON)
      REAL*8    :: ENVT(JSON)
      REAL*8    :: ENVS(JSON)
      REAL*8    :: ENVD(JSON)
      REAL*8    :: ENVR(JSON)
      REAL*8    :: ENVX(JSON)
      REAL*8    :: ENVZ(JSON)
      LOGICAL*4 :: LCENV(JSON)
      REAL*8    :: EDELS(3,JSON)
      REAL*8    :: EVELS(JSON)
      REAL*8    :: EBETAS(JSON)
      REAL*8    :: EGAM1(JSON)
      REAL*8    :: EQCP(JSON)
      REAL*8    :: EFXIONS(3,JSON)
      REAL*8    :: ENVO(JSON)
      REAL*8    :: ENVL(JSON)
      REAL*8    :: EQDT(JSON)
      INTEGER*4 :: NUMENV

      END MODULE ENVSTRUCT_MOD
