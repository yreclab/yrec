C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C ACDPTH_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ACDPTH/ into this module.
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
C 5 of the 18 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE ACDPTH_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: JSON = 5000

      REAL*8    :: TAUCZN
      REAL*8    :: DELADJ(JSON)
      REAL*8    :: TAUHE
      REAL*8    :: TNORM
      REAL*8    :: TCZ
      REAL*8    :: WHE
      REAL*8    :: ACATMR(JSON)
      REAL*8    :: ACATMD(JSON)
      REAL*8    :: ACATMP(JSON)
      REAL*8    :: ACATMT(JSON)
      REAL*8    :: TATMOS
      REAL*8    :: AGEOUT(5) = (/0.5D0, 1.0D0, 5.0D0, 10.0D0, 20.0D0/)
      LOGICAL*4 :: LCLCD = .FALSE.
      LOGICAL*4 :: LJLAST = .FALSE.
      LOGICAL*4 :: LJWRT = .FALSE.
      LOGICAL*4 :: LADON
      LOGICAL*4 :: LAOLY
      LOGICAL*4 :: LACOUT = .FALSE.

      END MODULE ACDPTH_MOD
