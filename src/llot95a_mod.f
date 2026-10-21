C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C LLOT95A_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/LLOT95A/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 5 files declared this block identically, so the USE imports
C exactly the names the declaration already made global in each
C scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while
C ifort Classic predates it.  That matches COMMON's semantics.
C
C 4 of the 7 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE LLOT95A_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: NUMD = 19
      INTEGER*4, PARAMETER, PRIVATE :: NUMT = 70
      INTEGER*4, PARAMETER, PRIVATE :: NUMX = 10
      INTEGER*4, PARAMETER, PRIVATE :: NUMXZ = 126
      INTEGER*4, PARAMETER, PRIVATE :: NUMZ = 13

      REAL*8    :: TGR(NUMT)
      REAL*8    :: XXG(NUMX) = (/0.0D0, 0.1D0, 0.2D0, 0.35D0, 0.5D0, 0.7D0, 0.8D0, 0.9D0, 0.95D0, 1.0D0/)
      REAL*8    :: R0GR(NUMD)
      REAL*8    :: ZZG(NUMZ) = (/0.0D0, 0.0001D0, 0.0003D0, 0.001D0, 0.002D0, 0.004D0, 0.01D0, 0.02D0, 0.03D0, 0.04D0, 0.06D0,
     *  0.08D0, 0.10D0/)
      REAL*8    :: CAPPA2(NUMXZ,NUMT,NUMD)
      INTEGER*4 :: NUMXM(NUMZ) = (/10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9, 9, 8/)
      INTEGER*4 :: NZ(NUMZ) = (/0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 109, 118/)

      END MODULE LLOT95A_MOD
