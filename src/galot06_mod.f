C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C GALOT06_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/GALOT06/ into this module.
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
C 4 of the 4 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE GALOT06_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: NUMD = 19
      INTEGER*4, PARAMETER, PRIVATE :: NUMT = 85
      INTEGER*4, PARAMETER, PRIVATE :: NUMX = 9
      INTEGER*4, PARAMETER, PRIVATE :: NUMZ = 16

      REAL*8 :: TGR06(NUMT) = (/2.70D0, 2.75D0, 2.80D0, 2.85D0, 2.90D0, 2.91D0, 2.92D0, 2.93D0, 2.94D0, 2.95D0, 2.96D0, 2.97D0,
     *  2.98D0, 2.99D0, 3.00D0, 3.01D0, 3.02D0, 3.03D0, 3.04D0, 3.05D0, 3.06D0, 3.07D0, 3.08D0, 3.09D0, 3.10D0, 3.11D0, 3.12D0,
     *  3.13D0, 3.14D0, 3.15D0, 3.16D0, 3.17D0, 3.18D0, 3.19D0, 3.20D0, 3.21D0, 3.22D0, 3.23D0, 3.24D0, 3.25D0, 3.26D0, 3.27D0,
     *  3.28D0, 3.29D0, 3.30D0, 3.31D0, 3.32D0, 3.33D0, 3.34D0, 3.35D0, 3.36D0, 3.37D0, 3.38D0, 3.39D0, 3.40D0, 3.41D0, 3.42D0,
     *  3.43D0, 3.44D0, 3.45D0, 3.46D0, 3.47D0, 3.48D0, 3.49D0, 3.50D0, 3.55D0, 3.60D0, 3.65D0, 3.70D0, 3.75D0, 3.80D0, 3.85D0,
     *  3.90D0, 3.95D0, 4.00D0, 4.05D0, 4.10D0, 4.15D0, 4.20D0, 4.25D0, 4.30D0, 4.35D0, 4.40D0, 4.45D0, 4.50D0/)
      REAL*8 :: XXG06(NUMX) = (/0.0D0, 0.1D0, 0.2D0, 0.35D0, 0.5D0, 0.7D0, 0.8D0, 0.9D0, 1.0D0/)
      REAL*8 :: R0GR06(NUMD) = (/-8.0D0, -7.5D0, -7.0D0, -6.5D0, -6.0D0, -5.5D0, -5.0D0, -4.5D0, -4.0D0, -3.5D0, -3.0D0, -2.5D0,
     *  -2.0D0, -1.5D0, -1.0D0, -0.5D0, 0.0D0, 0.5D0, 1.0D0/)
      REAL*8 :: ZZG06(NUMZ) = (/0.0D0, 0.00001D0, 0.00003D0, 0.0001D0, 0.0003D0, 0.001D0, 0.002D0, 0.004D0, 0.01D0, 0.02D0, 0.03D0,
     *  0.04D0, 0.05D0, 0.06D0, 0.08D0, 0.10D0/)

      END MODULE GALOT06_MOD
