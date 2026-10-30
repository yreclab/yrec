C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ALOT06_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ALOT06/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 3 files declared this block identically, so the USE imports
C exactly the names the declaration already made global in each
C scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while
C ifort Classic predates it.  That matches COMMON's semantics.
C
C 5 of the 6 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE ALOT06_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: NUMD = 19
      INTEGER*4, PARAMETER, PRIVATE :: NUMT = 85

      REAL*8    :: CAPALEX06(NUMT,NUMD)
      REAL*8    :: XE = 0.0D0
      REAL*8    :: ZE = 0.0D0
      INTEGER*4 :: IX = 4
      INTEGER*4 :: IT = 43
      INTEGER*4 :: ID = 10

      END MODULE ALOT06_MOD
