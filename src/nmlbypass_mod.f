C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C NMLBYPASS_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLBYPASS/ into this module.
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
C 82 of the 83 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE NMLBYPASS_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: FLAG_DX = 0.05D0
      REAL*8    :: FLAG_DW = 0.10D0
      REAL*8    :: FLAG_DZ = 0.05D0
      REAL*8    :: TIME_CORE_MIN = 1.0D-3
      REAL*8    :: TIME_DL = 2.0D-2
      REAL*8    :: TIME_DP = 4.0D-2
      REAL*8    :: TIME_DR = 2.0D-2
      REAL*8    :: TIME_DT = 2.0D-2
      REAL*8    :: TIME_DW_GLOBAL = 8.0D-2
      REAL*8    :: TIME_DW_MIX = 8.0D-2
      REAL*8    :: TIME_DX_CORE_FRAC = 0.5D0
      REAL*8    :: TIME_DX_CORE_TOT = 2.0D-2
      REAL*8    :: TIME_DX_SHELL = 0.1D0
      REAL*8    :: TIME_DX_TOTAL = 1.5D-3
      REAL*8    :: TIME_DY_CORE_FRAC = 0.5D0
      REAL*8    :: TIME_DY_CORE_TOT = 2.0D-2
      REAL*8    :: TIME_DY_SHELL = 0.1D0
      REAL*8    :: TIME_DY_TOTAL = 1.5D-3
      REAL*8    :: TOL_CZBASE_FINE_WIDTH = 0.0D0
      REAL*8    :: TOL_DL_MAX = 0.02D0
      REAL*8    :: TOL_DM_MAX = 0.08D0
      REAL*8    :: TOL_DM_MIN = 1.0D-8
      REAL*8    :: TOL_DP_CORE_MAX = 0.05D0
      REAL*8    :: TOL_DP_CZBASE_MAX = 0.05D0
      REAL*8    :: TOL_DP_ENV_MAX = 0.05D0
      REAL*8    :: TOL_DX_MAX = 1.0D0
      REAL*8    :: TOL_DZ_MAX = 1.0D0
      REAL*8    :: TIME_MAX_DT_FRAC = 1.5D0
      LOGICAL*4 :: LSTRUCT_TIME = .FALSE.
      LOGICAL*4 :: LNEWVARS = .FALSE.
      REAL*8    :: S0_1_1 = 4.01D-22
      REAL*8    :: S0_3_3 = 5.21D3
      REAL*8    :: S0_3_4 = 5.6D-1
      REAL*8    :: S0_1_12 = 1.34D0
      REAL*8    :: S0_1_13 = 7.6D0
      REAL*8    :: S0_1_14 = 1.66D0
      REAL*8    :: S0_1_16 = 1.06D1
      REAL*8    :: S0_PEP = 3.5734D-6
      REAL*8    :: S0_1_BE7E = 1.7709D-10
      REAL*8    :: S0_1_BE7P = 0.0208D0
      REAL*8    :: S0_HEP = 8.6D-20
      REAL*8    :: S0_1_15_C12ALP = 7.3D4
      REAL*8    :: S0_1_15_O16 = 3.6D1
      REAL*8    :: S0P_1_1 = 4.49D-24
      REAL*8    :: S0P_3_3 = -4.9D0
      REAL*8    :: S0P_3_4 = -3.6D-4
      REAL*8    :: S0P_1_12 = 2.6D-3
      REAL*8    :: S0P_1_13 = -7.83D-3
      REAL*8    :: S0P_1_14 = -3.3D-3
      REAL*8    :: S0P_1_16 = -5.4D-2
      REAL*8    :: S0PP_1_12 = 8.3D-5
      REAL*8    :: S0PP_1_13 = 7.29D-4
      REAL*8    :: S0PP_1_16 = 0.0D0
      REAL*8    :: S0P_1_BE7P = -3.12D-5
      REAL*8    :: S0PP_1_BE7P = -2.288D-7
      REAL*8    :: XSLI6 = 5.5D3
      REAL*8    :: XSLI7 = 5.2D1
      REAL*8    :: XSBE91 = 1.1D0
      REAL*8    :: XSBE92 = 1.5D4
      REAL*8    :: XSBE93 = 1.5D4
      LOGICAL*4 :: LXLI6 = .FALSE.
      LOGICAL*4 :: LXLI7 = .FALSE.
      LOGICAL*4 :: LXBE91 = .FALSE.
      LOGICAL*4 :: LXBE92 = .FALSE.
      LOGICAL*4 :: LXBE93 = .FALSE.
      INTEGER*4 :: NPENV
      LOGICAL*4 :: LNEWNUC = .FALSE.
      LOGICAL*4 :: LENVG = .FALSE.
      INTEGER*4 :: ISETMIX = 0
      INTEGER*4 :: ISETISO = 0
      REAL*8    :: R14_15 = 411.9D0
      REAL*8    :: R16_17 = 471.4D0
      REAL*8    :: ZXMIX = 0.02292D0
      REAL*8    :: XB10_INI = 1.002D-9
      REAL*8    :: XB11_INI = 4.405D-9
      REAL*8    :: PMMA = 2.0
      REAL*8    :: PMMB = 1.0
      REAL*8    :: PMMC = 2.0
      REAL*8    :: PMMD = 0.0
      REAL*8    :: PMMM = 0.5
      REAL*8    :: PMMJD = 1.32D30
      REAL*8    :: PMMMD = 1.27D12
      REAL*8    :: FO = 1.0D0

      END MODULE NMLBYPASS_MOD
