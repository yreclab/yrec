C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C OP95INTERP_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OP95INTERP/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 6 files declared this block identically, so the USE imports
C exactly the names the declaration already made global in each
C scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while
C ifort Classic predates it.  That matches COMMON's semantics.
C
C 4 of the 16 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE OP95INTERP_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4 :: JZ = 1
      INTEGER*4 :: JX(4,4) = 1
      INTEGER*4 :: JT = 1
      INTEGER*4 :: JD(4) = 1
      REAL*8    :: BZ(4)
      REAL*8    :: BX(4,4)
      REAL*8    :: BT(4)
      REAL*8    :: BTT(4)
      REAL*8    :: BD(4,4)
      REAL*8    :: BDD(4,4)
      REAL*8    :: RHO_T63L
      REAL*8    :: RHO_T63LL
      REAL*8    :: RLH(4)
      LOGICAL*4 :: LEXTL
      LOGICAL*4 :: LEXTH
      LOGICAL*4 :: LEXH(4)

      END MODULE OP95INTERP_MOD
