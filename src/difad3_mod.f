C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C DIFAD3_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/DIFAD3/ into this module.
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
      MODULE DIFAD3_MOD
C 10/20/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C a PRIVATE copy here.
      USE DIMENSIONS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8 :: FACD2(JSON)
      REAL*8 :: FACD3(JSON)
      REAL*8 :: VESD2(JSON)
      REAL*8 :: VESD3(JSON)
      REAL*8 :: ECOD5(JSON)
      REAL*8 :: ECOD6(JSON)
      REAL*8 :: FGEOM(JSON)
      REAL*8 :: FV0(JSON)
      REAL*8 :: FV1A(JSON)
      REAL*8 :: FV1B(JSON)
      REAL*8 :: FV2A(JSON)
      REAL*8 :: FV2B(JSON)
      REAL*8 :: EV0(JSON)
      REAL*8 :: EV1A(JSON)
      REAL*8 :: EV1B(JSON)
      REAL*8 :: EV2A(JSON)
      REAL*8 :: EV2B(JSON)
      REAL*8 :: DSS(JSON)
      REAL*8 :: DGSF(JSON)
      REAL*8 :: ESS(JSON)
      REAL*8 :: EGSF(JSON)

      END MODULE DIFAD3_MOD
