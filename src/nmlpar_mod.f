C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C NMLPAR_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 103 files declared this block identically, so the USE imports
C exactly the names the declaration already made global in each
C scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while
C ifort Classic predates it.  That matches COMMON's semantics.
C
C 202 of the 234 members carry an initializer, migrated
C from parmin.f's DATA statements because DATA on a USE-associated
C name is rejected.  The literal text is copied verbatim: these
C are namelist variables whose DATA supplied a default the
C namelist read could override, and a module initializer is
C applied once at load time, before PARMIN runs, which is the
C same thing.  Rewriting a literal such as 0.9828 as 0.9828D0
C would change its stored value, so that is deliberately not
C done here; see KNOWN_ISSUES.md issue 23.
      MODULE NMLPAR_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: ALATM_FeH
      REAL*8    :: ALATM_Alpha
      LOGICAL*4 :: LALTPTau100
      REAL*8    :: SLI6 = 1.0D0
      REAL*8    :: SLI7 = 1.0D0
      REAL*8    :: SBE91 = 1.0D0
      REAL*8    :: SBE92 = 1.0D0
      REAL*8    :: SBE93 = 1.0D0
      REAL*8    :: CMIN = 1.0D-20
      REAL*8    :: ABSTOL = 1.0D-5
      REAL*8    :: RELTOL = 1.0D-4
      INTEGER*4 :: KEMMAX = 50
      REAL*8    :: TOLL = 1.0D-5
      REAL*8    :: TOLR = 1.0D-4
      REAL*8    :: TOLZ = 1.0D-3
      LOGICAL*4 :: LCALS = .FALSE.
      LOGICAL*4 :: LCALSOLZX = .FALSE.
      REAL*8    :: CALSOLZX = 0.02292D0
      REAL*8    :: CALSOLAGE = 4.57D9
      LOGICAL*4 :: LDEBUG = .FALSE.
      LOGICAL*4 :: LCORR = .TRUE.
      LOGICAL*4 :: LMILNE = .FALSE.
      LOGICAL*4 :: LTRACK = .TRUE.
      LOGICAL*4 :: LSTPCH = .FALSE.
      LOGICAL*4 :: LRWSH = .FALSE.
      REAL*8    :: CSTMIXING = 1.0
      REAL*8    :: CSTDIFFMIX = 1.0
      LOGICAL*4 :: LCORE = .FALSE.
      INTEGER*4 :: MCORE = 0
      REAL*8    :: FCORE = 1.0
      REAL*8    :: DTWIND = 1.0D1
      LOGICAL*4 :: LPTIME = .TRUE.
      REAL*8    :: DTDIF = 1.0D-2
      REAL*8    :: DJOK = 1.0D-4
      INTEGER*4 :: ITDIF1 = 1
      INTEGER*4 :: ITDIF2 = 1
      LOGICAL*4 :: LEXCOM = .FALSE.
      LOGICAL*4 :: LTRIST = .FALSE.
      REAL*8    :: DT_GS = 0.1D0
      REAL*8    :: XMIN = 1.0D-3
      REAL*8    :: YMIN = 1.0D-3
      LOGICAL*4 :: LTHOULFIT = .FALSE.
      REAL*8    :: FGRY = 1.0D0
      REAL*8    :: FGRZ = 1.0D0
      LOGICAL*4 :: LTHOUL = .FALSE.
      LOGICAL*4 :: LDIFZ = .FALSE.
      LOGICAL*4 :: LNEWDIF = .FALSE.
      LOGICAL*4 :: LDIFLI = .FALSE.
      REAL*8    :: GRTOL = 1.0D-8
      INTEGER*4 :: ILAMBDA = 1
      INTEGER*4 :: NITER_GS = 10
      LOGICAL*4 :: LDIFY = .FALSE.
      LOGICAL*4 :: LKUTHE = .FALSE.
      REAL*8    :: ATMERR = 3.0D-4
      REAL*8    :: ATMD0 = 1.0D-10
      REAL*8    :: ATMBEG = 1.0D-1
      REAL*8    :: ATMMIN = 1.0D-1
      REAL*8    :: ATMMAX = 5.0D-1
      REAL*8    :: ENVERR = 3.0D-4
      REAL*8    :: ENVBEG = 1.0D-1
      REAL*8    :: ENVMIN = 1.0D-1
      REAL*8    :: ENVMAX = 5.0D-1
      REAL*8    :: CODM = 2.5D4
      LOGICAL*4 :: LCODM = .FALSE.
      REAL*8    :: DMDT0 = -1.0D-14
      REAL*8    :: FCZDMDT = 0.1D0
      REAL*8    :: FTOTDMDT = 1.0D-2
      REAL*8    :: COMPACC(15) = (/0.71668d0, 0.265721d0, 0.01757d0, 2.9d-5, 3.013d-3, 3.385d-5, 9.346d-4, 0.0d0, 8.462d-3, 0.0d0,
     *  1.696d-5, 0.0d0, 2.0d-9, 2.0d-9, 3.0d-11/)
      REAL*8    :: CREIM = -4.0D-13
      LOGICAL*4 :: LREIMER = .FALSE.
      LOGICAL*4 :: LMDOT = .FALSE.
      REAL*8    :: XNEWCP = 1.3D1
      INTEGER*4 :: INEWCP
      LOGICAL*4 :: LNEWCP = .FALSE.
      LOGICAL*4 :: LREL
      INTEGER*4 :: NITER4 = 0
      LOGICAL*4 :: LNEWS = .FALSE.
      LOGICAL*4 :: LSNU = .FALSE.
      REAL*8    :: XENV0A(50)
      REAL*8    :: ZENV0A(50)
      REAL*8    :: CMIXLA(50)
      LOGICAL*4 :: LSENV0A(50) = .FALSE.
      REAL*8    :: SENV0A(50) = 1.26D-4
      LOGICAL*4 :: LNOJ = .FALSE.
      LOGICAL*4 :: lopale06 = .FALSE.
      LOGICAL*4 :: lNumDeriv = .FALSE.
      REAL*8    :: POA = 1.0D0
      REAL*8    :: POB = 10.0D0
      REAL*8    :: POC = 0.0D0
      REAL*8    :: POMAX = 0.1D0
      LOGICAL*4 :: LPOUT = .FALSE.
      REAL*8    :: WNEW = 0.0D0
      REAL*8    :: WALPCZ = 0.0D0
      REAL*8    :: ACFPFT = 1.0D-36
      INTEGER*4 :: ITFP1 = 5
      INTEGER*4 :: ITFP2 = 20
      LOGICAL*4 :: LROT = .FALSE.
      LOGICAL*4 :: LINSTB = .FALSE.
      LOGICAL*4 :: LWNEW = .FALSE.
      LOGICAL*4 :: LSOLID = .FALSE.
      INTEGER*4 :: IMPJMOD = 0
      REAL*8    :: SPOTF = 0.00
      REAL*8    :: SPOTX = 1.00
      LOGICAL*4 :: LSDEPTH = .FALSE.
      INTEGER*4 :: ITRVER = 1
      REAL*8    :: FESC = 1.0D0
      REAL*8    :: FSSC = 1.0D0
      REAL*8    :: FGSFC = 1.0D0
      INTEGER*4 :: IES = 1
      INTEGER*4 :: IGSF = 1
      INTEGER*4 :: IMU = 1
      REAL*8    :: VNEW(12) = (/0.001999D0, 0.003238D0, 0.037573D0, 0.071794D0, 0.040520D0, 0.173285D0, 0.000000D0, 0.482273D0,
     *  0.053152D0, 0.005379D0, 0.098668D0, 0.000000D0/)
      REAL*8    :: WEAKSCREENING = 0.03D0
      INTEGER*4 :: KTTAU = 0
      INTEGER*4 :: KTTAU0
      LOGICAL*4 :: LTTAU
      REAL*8    :: XLS
      REAL*8    :: XLSTOL
      REAL*8    :: STEFF
      REAL*8    :: SR
      LOGICAL*4 :: LTEFF = .FALSE.
      LOGICAL*4 :: LCALST = .FALSE.
      LOGICAL*4 :: LSTORE = .FALSE.
      LOGICAL*4 :: LSTATM
      LOGICAL*4 :: LSTENV
      LOGICAL*4 :: LSTMOD
      LOGICAL*4 :: LSTPHYS
      LOGICAL*4 :: LSTROT
      LOGICAL*4 :: LSTCH = .FALSE.
      INTEGER*4 :: NPRTMOD = 1
      INTEGER*4 :: NPRTPT = 1
      INTEGER*4 :: NPOINT = 1
      REAL*8    :: TRIDT = 1.0D-2
      REAL*8    :: TRIDL = 8.0D-2
      LOGICAL*4 :: LNEW0 = .FALSE.
      INTEGER*4 :: NMODLS(50) = 0
      LOGICAL*4 :: LFIRST(50) = .TRUE.
      INTEGER*4 :: NUMRUN = 1
      REAL*8    :: SSTANDARD(17) = (/0.9828D0, 1.0485D0, 0.9815D0, 0.9241D0, 1.3818D0, 1.0542D0, 1.0D0, 1.0D0, 1.0D0, 1.0D0, 1.0D0,
     *  1.0D0, 1.0D0, 1.0D0, 1.0108D0,
     *  0.7819D0, 0.2875D0/)
      REAL*8    :: ATIME(14) = (/1.0D-3, 2.0D-2, 5.0D-1, 2.0D-2, 3.0D-1, 1.5D-3, 1.0D-1, 2.0D-2, 4.0D-2, 2.0D-2, 2.0D-2, 0.25D0,
     *  1.5D0, 0.25D0/)
      REAL*8    :: TCUT(5) = (/6.5D0, 6.5D0, 6.82D0, 7.7D0, 7.5D0/)
      REAL*8    :: TSCUT = 6.0D0
      REAL*8    :: TENV0 = 3.0D0
      REAL*8    :: TENV1 = 9.0D0
      REAL*8    :: TGCUT = 6.9D0
      REAL*8    :: HTOLER(5,2) = RESHAPE((/6.0D-5, 4.5D-5, 3.0D-5, 9.0D-5, 3.0D-5, 9.0D-1, 5.0D-1, 5.0D-1, 2.0D0, 2.5D-6/), (/5,
     *  2/))
      REAL*8    :: FCORR0 = 0.8D0
      REAL*8    :: FCORRI = 0.1D0
      REAL*8    :: HPTTOL(12) = (/1.0D-8, 8.0D-2, 5.0D-2, 5.0D-2, 1.0D0, 1.0D0, 0.0D0, 5.0D-2, 2.0D-2, 5.0D-2, 5.0D-2, 1.0D-1/)
      INTEGER*4 :: NITER1 = 2
      INTEGER*4 :: NITER2 = 20
      INTEGER*4 :: NITER3 = 2
      REAL*8    :: WMAX = 3.0D-4
      REAL*8    :: EXMD
      REAL*8    :: EXW
      REAL*8    :: EXTAU
      REAL*8    :: EXR
      REAL*8    :: EXM
      REAL*8    :: EXL
      REAL*8    :: EXPR
      REAL*8    :: CONSTFACTOR
      REAL*8    :: EXCEN
      LOGICAL*4 :: LJDOT0 = .TRUE.
      REAL*8    :: ETADH0 = -1.0D0
      REAL*8    :: ETADH1 = 1.0D0
      LOGICAL*4 :: LDH = .FALSE.
      REAL*8    :: TDISK = 0.0D0
      REAL*8    :: PDISK = 7.2722D-6
      LOGICAL*4 :: LDISK = .FALSE.
      REAL*8    :: DPENV = 1.0D0
      REAL*8    :: ALPHAC = 0.0D0
      REAL*8    :: ALPHAE = 0.0D0
      REAL*8    :: ALPHAM = 0.0
      REAL*8    :: BETAC = 0.15D0
      LOGICAL*4 :: LOVSTC = .FALSE.
      LOGICAL*4 :: LOVSTE = .FALSE.
      LOGICAL*4 :: LOVSTM = .FALSE.
      LOGICAL*4 :: LSEMIC = .FALSE.
      LOGICAL*4 :: LADOV = .FALSE.
      LOGICAL*4 :: LOVMAX = .FALSE.
      REAL*8    :: ATMSTP = 0.5
      REAL*8    :: ENVSTP = 0.5
      LOGICAL*4 :: LSOLWIND = .FALSE.
      LOGICAL*4 :: LMIXTURE
      LOGICAL*4 :: LISOTOPE
      REAL*8    :: FRAC_C = 0.172148D0
      REAL*8    :: FRAC_N = 0.050426D0
      REAL*8    :: FRAC_O = 0.468195D0
      REAL*8    :: R12_13 = 88.27D0
      REAL*8    :: R16_18 = 2693.0D0
      REAL*8    :: XH2_INI = 2.781D-5
      REAL*8    :: XHE3_INI = 3.461D-5
      REAL*8    :: XLI6_INI = 7.187D-10
      REAL*8    :: XLI7_INI = 1.025D-8
      REAL*8    :: XBE9_INI = 1.595D-10
      REAL*8    :: ZOPAL951
      REAL*8    :: TMOLMIN = 4.0D0
      REAL*8    :: TMOLMAX = 4.1D0
      REAL*8    :: TOLLAOL = 10.0
      LOGICAL*4 :: LALEX06 = .FALSE.
      LOGICAL*4 :: LOPAL95
      LOGICAL*4 :: LPUREZ = .FALSE.
      LOGICAL*4 :: LcondOpacP = .FALSE.
      LOGICAL*4 :: LNULOS1 = .FALSE.
      REAL*8    :: OPTOL = 1.0D-8
      LOGICAL*4 :: LNEWTCZ = .TRUE.
      LOGICAL*4 :: LCALCENV = .TRUE.
      REAL*8    :: PMMSOLP = 4.9304D0
      REAL*8    :: PMMSOLW = 2.836D-6
      REAL*8    :: PMMSOLTAU = 9.4805D5
      LOGICAL*4 :: LMWIND = .FALSE.
      LOGICAL*4 :: LROSSBY = .TRUE.
      LOGICAL*4 :: LBSCALE = .FALSE.
      LOGICAL*4 :: LPULSE = .FALSE.
      INTEGER*4 :: IPVER = 1
      LOGICAL*4 :: LSCV = .FALSE.
      REAL*8    :: ENDAGE(50) = 0.0
      REAL*8    :: SETDT(50) = 0.0
      REAL*8    :: END_DCEN(50) = 0.0
      REAL*8    :: END_XCEN(50) = 0.0
      REAL*8    :: END_YCEN(50) = 0.0
      LOGICAL*4 :: LVFC = .FALSE.
      LOGICAL*4 :: LDIFAD = .FALSE.
      REAL*8    :: FW = 1.0D0
      REAL*8    :: FC = 1.0D0
      REAL*8    :: FES = 1.0D0
      REAL*8    :: FGSF = 1.0D0
      REAL*8    :: FMU = 1.0D0
      REAL*8    :: FSS = 1.0D0
      REAL*8    :: RCRIT = 1.0D3
      REAL*8    :: RSCLZC(50) = -1.0D0
      REAL*8    :: RSCLZM1(50) = -1.0D0
      REAL*8    :: RSCLZM2(50) = -1.0D0
      LOGICAL*4 :: LZRAMP = .FALSE.

      END MODULE NMLPAR_MOD
