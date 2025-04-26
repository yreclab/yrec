module settings
  use, intrinsic :: iso_fortran_env, only : dp => real64
  implicit none
  public

  ! Variables from /VNEWCB/
  ! DBG 1/96 The array v, read in via rdlaol, contained the mass fractions
  ! of the envelope elements. It was used in starin to define fxenv, &
  ! which are the number fraction of the envelope elements. fxenv was
  ! then updated in eqstat and eqsaha. Here we define vnew passed
  ! in a common block vnewcb. It is identical to v except that the numbers
  ! are defined here explicity for a G&N93 solar mixture. You can
  ! change them via the physics namelist. v is set equal to vnew in
  !  starin except when llaol=t (to maintain backward compatibility.
  !            Na          Al          Mg          Fe
  !            Si          !           H           O
  !            N           Ar          Ne          He
  real(dp) :: vnew(12) = [0.001999_dp, 0.003238_dp, 0.037573_dp, 0.071794_dp, &
                       &  0.040520_dp, 0.173285_dp, 0.000000_dp, 0.482273_dp, &
                       &  0.053152_dp, 0.005379_dp, 0.098668_dp, 0.000000_dp]

  ! Variables from /LUOUT/
  integer, parameter :: ilast  = 11  ! output: last model (text)
  integer, parameter :: idebug = 18  ! output: reserved for debugging
  integer, parameter :: itrack = 19  ! output: track
  integer, parameter :: ishort = 20  ! output: all diagnostic info
  integer, parameter :: imilne = 21  ! output: Milne invariant variables
  integer, parameter :: imodpt = 22  ! output: shell by shell info on models
  integer, parameter :: istor  = 23  ! output: saved models, can be used as starting model
  integer, parameter :: iowr   = 6   ! output: status file

  ! Variables from /LUNUM/
  integer, parameter :: ifirst = 12  ! input: first model (text)
  integer, parameter :: irun   = 13  ! input: physics namelist
  integer, parameter :: istand = 14  ! input: control namelist
  integer, parameter :: ifermi = 15  ! input: Fermi tables
  integer, parameter :: iopmod = 24  ! output: for pulsation code, interior
  integer, parameter :: iopenv = 25  ! output: for pulsation code, envelope
  integer, parameter :: iopatm = 26  ! output: for pulsation code, atmosphere
  integer, parameter :: idyn   = 30  ! output: info relavent to dynamo
  integer, parameter :: illdat = 32  ! YCK input: OPAL92 opacity tables
  integer, parameter :: isnu   = 33  ! output: snu fluxes
  integer, parameter :: iscomp = 34  ! output: extended composition info
  integer, parameter :: ikur   = 36  ! YCK input: Kurucz low T opacities

  ! Variables from /LUFNM/
  character(len=256) :: flast, ffirst, frun, fstand, ffermi
  character(len=256) :: fdebug, ftrack, fshort, fmilne, fmodpt
  character(len=256) :: fstor, fpmod, fpenv, fpatm, fdyn
  character(len=256) :: flldat, fsnu, fscomp, fkur
  character(len=256) :: fmhd1, fmhd2, fmhd3, fmhd4, fmhd5, fmhd6, fmhd7, fmhd8

  ! Variables from /IOMONTE/
  character(len=256) :: fmonte1, fmonte2
  integer, parameter :: imonte1 = 70, imonte2 = 71  ! MHP 6/98 Monte Carlo for snus

  ! Variables from /CCOUT/, /CCOUT1/, and /CCOUT2/
  ! putstore.f: include common blocks with required physics and output flags
  ! envint.f: G Somers 11/14, add i/o common block
  logical :: lstore = .false., lstatm, lstenv, lstmod, lstphys, lstrot, lscrib = .true.
  integer :: npenv, nprtmod = 1, nprtpt = 1, npoint = 1
  logical :: ldebug = .false., lcorr = .true., lmilne = .false., ltrack = .true., lstpch = .false.

  ! Variables from /CENV/
  real(dp) :: tridt = 1.0e-2_dp, tridl = 8.0e-2_dp, senv0
  logical :: lsenv0, lnew0 = .false.

  ! Variables from /CKIND/
  real(dp) :: rescal(4, 50)
  integer :: nmodls(50) = 0, iresca(50)
  logical :: lfirst(50) = .true.
  integer :: numrun = 1

  ! Variables from /COMP/ and /COMP2/
  ! getnewenv.f: senv is the difference in mass between the total and the last model
  !              point.  It is set to a different value in this routine.
  real(dp) :: xenv, zenv, zenvm, amuenv, fxenv(12), xnew, znew, stotal, senv
  real(dp) :: yenv, y3env

  ! Variables from /CONST/, /CONST1/, /CONST2/, and /CONST3/
  ! getnewenv.f: Physical constants.
  real(dp) :: clsun = 3.8515e33_dp, clsunl, clnsun, cmsun, cmsunl, &
            & crsun = 6.9598e10_dp, crsunl, cmbol
  real(dp) :: cln, clni, c4pi, c4pil, c4pi3l, cc13, cc23, cpi
  real(dp) :: cgas, ca3, ca3l, csig, csigl, cgl, cmkh, cmkhn
  real(dp) :: cdelrl, cmixl = 1.4_dp, cmixl2, cmixl3, clndp, &
            & csecyr  ! engeb.f: seconds per year

  ! Variables from /CTLIM/, /CT2/, and /CT3/
  ! parmin.f: atime(13) was orginally = 1.5.
  real(dp) :: atime(14) = [1.0e-3_dp, 2.0e-2_dp, 5.0e-1_dp, 2.0e-2_dp, 3.0e-1_dp, 1.5e-3_dp, 1.0e-1_dp, &
                         & 2.0e-2_dp, 4.0e-2_dp, 2.0e-2_dp, 2.0e-2_dp, 0.25_dp,   1.5_dp,    0.25_dp]
  ! midmod.f: MHP 05/02 Added for deuterium burning (tcut)
  ! mix.f: MHP Common block added for G.S. (tcut)
  real(dp) :: tcut(5) = [6.5_dp, 6.5_dp, 6.82_dp, 7.7_dp, 7.5_dp]
  real(dp) :: tscut = 6.0_dp, tenv0 = 3.0_dp, tenv1 = 9.0_dp, tenv, tgcut = 6.9_dp
  real(dp) :: dtwind = 1.0e1_dp
  logical :: lptime = .true.  ! main.f: LLP 8/07 Make LPTIME available for calibration

  ! Variables from /CTOL/
  ! starin.f: MHP 10/98 Added hpttol for changing core fitting point
  ! getnewenv.f: hpttol used to set the spatial resolution of the envelope integration
  real(dp) :: htoler(5, 2) = reshape([6.0e-5_dp, 4.5e-5_dp, 3.0e-5_dp, 9.0e-5_dp, 3.0e-5_dp, &
                                    & 9.0e-1_dp, 5.0e-1_dp, 5.0e-1_dp, 2.0_dp,    2.5e-6_dp], [5, 2])
  real(dp) :: fcorr0 = 0.8_dp, fcorri = 0.1_dp, fcorr
  real(dp) :: hpttol(12) = [1.0e-8_dp, 8.0e-2_dp, 5.0e-2_dp, 5.0e-2_dp, 1.0_dp,    1.0_dp, &
                         &  0.0_dp,    5.0e-2_dp, 2.0e-2_dp, 5.0e-2_dp, 5.0e-2_dp, 1.0e-1_dp]
  integer :: niter1 = 2, niter2 = 20, niter3 = 2

  ! Variables from /DIFUS/
  ! main.f: MHP 05/02 added option to iterate between rotation and
  !         structure calculations - set itdif1 greater than 1
  ! getnewenv.f: hpttol used to set the spatial resolution of the envelope integration
  ! dadcoeft.f: convergence criterion
  real(dp) :: dtdif = 1.0e-2_dp, djok = 1.0e-4_dp
  integer :: itdif1 = 1, itdif2 = 1

  ! Variables from /DPMIX/
  ! liburn.f: MHP 10/91 Common block added for overshoot.
  real(dp) :: dpenv = 1.0_dp, alphac = 0.0_dp, alphae = 0.0_dp, &
            & alpham = 0.0_dp, betac = 0.15_dp
  integer :: iov1, iov2, iovim
  ! parmin.f: 7/91 lsemic (semi-convection) added to common block.
  logical :: lovstc = .false., lovste = .false., lovstm = .false., &
           & lsemic = .false., ladov = .false., lovmax = .false.

  ! Variables from /ENVGEN/
  real(dp) :: atmstp = 0.5, envstp = 0.5
  logical :: lenvg = .false.

  ! Variables from /FLAG/
  ! getnewenv.f: extended composition flag
  ! seculr.f: MHP 6/00 added flag for call to ndifcom
  logical :: lexcom = .false.

  ! Variables from /HEFLSH/
  logical :: lkuthe = .false.

  ! Variables from /INTATM/
  real(dp) :: atmerr = 3.0e-4_dp, atmd0 = 1.0e-10_dp, atmbeg = 1.0e-1_dp, &
            & atmmin = 1.0e-1_dp, atmmax = 5.0e-1_dp

  ! Variables from /INTENV/
  ! getnewenv.f: tolerances for the envelope integration; temporarily assign new
  !              values for the integration to find the new points and then reset.
  ! starin.f: MHP 07/02 added for envelope integration when changing the
  !           outer fitting point
  real(dp) :: enverr = 3.0e-4_dp, envbeg = 1.0e-1_dp, &
            & envmin = 1.0e-1_dp, envmax = 5.0e-1_dp

  ! Variables from /INTPAR/
  real(dp) :: stolr0 = 1.0e-3_dp
  integer :: imax = 11, nuse = 7

  ! Variables from /LABEL/
  ! rscale.f: MHP 5/91 common block added to fix core rescaling.
  real(dp) :: xenv0 = 0.7, zenv0 = 0.02

  ! Variables from /NEWCMP/
  ! parmin.f: mhp 10/24 Added new controls for altering the CNO mass fractions
  !           isotopic ratios(C,N,O) and D/He3/Li/Be/B abundances.
  !           These controls only alter the mixture in the starting model and only
  !           if the model is chemically unevolved. Postprocessing tools should be used for the
  !           core He burning phase.
  ! rscale.f: mhp 10/24 added new controls for altering the heavy element mixture
  !           they are used in starin. the old entries (xnewcp->anewcp) are used here
  !                common/newcmp/xnewcp,inewcp,lnewcp,lrel,acomp
  real(dp) :: xnewcp = 1.3e1_dp
  integer :: inewcp
  logical :: lnewcp = .false., lrel

  ! Variables from /NEWMX/
  ! mhp 10/24 Added new mixture control isetiso controls cno isotope ratios and
  ! light element abundances D,He3,Li6,Li7,Be9,B10,B11 (1=used)
  ! isetmix controls C+N+O mass fractions (1=used)
  ! amix and aiso are strings identifying either a preset mixture or a custom one ('CUS')
  ! supported amix at present are 'GS98','AAG21',M22M','M22P'. supported aiso is 'L21'.
  ! For a custom mixture you can enter individual values.
  ! to be added - amix from atomic opacity tables (inewmix=2) and other mixtures/isotopes
  integer :: isetmix = 0, isetiso = 0
  logical :: lmixture, lisotope
  ! GS98 default CNO fractions of metals Grevesse&Sauval 1998 SSRv 85,161
  real(dp) :: frac_c = 0.172148_dp, frac_n = 0.050426_dp, frac_o = 0.468195_dp
  ! L21 default isotope data Lodders et al. 2021 SSRv 217,44
  real(dp) :: r12_13 = 88.27_dp, r14_15 = 411.9_dp, r16_17 = 471.4_dp, &
            & r16_18 = 2693.0_dp, zxmix = 0.02292_dp
  real(dp) :: xh2_ini = 2.781e-5_dp, xhe3_ini = 3.461e-5_dp, xli6_ini = 7.187e-10_dp, xli7_ini = 1.025e-8_dp, &
            & xbe9_ini = 1.595e-10_dp, xb10_ini = 1.002e-9_dp, xb11_ini = 4.405e-9_dp

  ! Variables from /OPTAB/
  real(dp) :: optol = 1.0e-8_dp, zsi = 0.0_dp
  integer :: idt, idd(4)

  ! Variables from /ROT/
  ! getnewenv.f: lrot needed to know if you have to compute rotation terms.
  ! mixcz.f: MHP 02/12 added rotation information.  hg vector is not defined for
  !          spherical models and is used for taucz; added information so that
  !          taucz is properly computed for such models.
  real(dp) :: wnew = 0.0_dp, walpcz = 0.0_dp, acfpft = 1.0e-36_dp
  integer :: itfp1 = 5, itfp2 = 20
  logical :: lrot = .false., linstb = .false., lwnew = .false.

  ! Variables from /SETT/
  ! MHP 10/24 Added stop criteria for central H,D,and He4
  ! parmin.f: MHP 10/24 Added new defaults for end conditions on central D,X,Y
  real(dp) :: endage(50) = 0.0_dp, setdt(50) = 0.0_dp
  logical :: lendag(50), lsetdt(50)
  real(dp) :: end_dcen(50) = 0.0_dp, end_xcen(50) = 0.0_dp, end_ycen(50) = 0.0_dp

  ! Variables from /VMULT/ and /VMULT2/
  real(dp) :: fw = 1.0_dp, fc = 1.0_dp, fo = 1.0_dp, fes = 1.0_dp, &
            & fgsf = 1.0_dp, fmu = 1.0_dp, fss = 1.0_dp, rcrit = 1.0e3_dp
  ! MHP 10/90 Different fc for different mechanisms introduced.
  ! Also option for smoothing velocities for length scale calculations.
  real(dp) :: fesc = 1.0_dp, fssc = 1.0_dp, fgsfc = 1.0_dp
  integer :: ies = 1, igsf = 1, imu = 1

  ! Variables from /DEBHU/
  ! DBG 7/92 Common block added to compute Debye–Hückel correction.
  ! getnewenv.f: Terms needed to compute the Debye–Hückel correction in the E.o.S.
  ! eqrelv.f: DBG 7/92 cdh is constant term defined in setups
  !           ramp function between no electron degeneracy eta .lt. etadh0
  !           and full electron degeneracy eta .gt. etadh1 version of D.H.
  !           correction.
  !           If ldh = .true. then apply D.H. correction.
  !           zdh is array of relative mass fractions of laol metal mixture
  !           summed to 1.0.
  real(dp) :: cdh, etadh0 = -1.0_dp, etadh1 = 1.0_dp
  real(dp) :: zdh(18), xxdh, yydh, zzdh, dhnue(18)
  logical :: ldh = .false.

  ! Variables from /NEWENG/
  ! mix.f: MHP 6/91 Common block for new mixing and semi-convection.
  !        These are parmin parameters in mark6.
  ! coefft.f: MHP 5/91 Add common block for energy from alpha capture reactions
  !           and losses from neutrino-cooled cores in evovled stars.
  ! engeb.f: 7/91 Common block added to skip flux calculations if lsnu=f
  ! parmin.f: MHP 5/90 Add common block for new treatment of
  !           entropy term(lnews),and the calculation
  !           of solar neutrinos(lsnu).Also allows a fourth level of iteration(niter4).
  integer :: niter4 = 0
  logical :: lnews = .false., lsnu = .false.

  ! Variables from /BURTOL/
  ! MHP 7/91 Added common block for numerical parameters in kemcom.
  real(dp) :: cmin = 1.0e-20_dp, abstol = 1.0e-5_dp, reltol = 1.0e-4_dp
  integer :: kemmax = 50

  ! Variables from /LOPAL95/
  ! YCK >>> OPAL95
  character(256) :: fliv95
  integer, parameter :: iliv95 = 48  ! YCK input: OPAL95 opacity table

  ! Variables from /GRAVST/, /GRAVS2/, /GRAVS3/, and /GRAVS4/
  ! MHP 5/90 Add common block for gravitational settling.
  ! MHP 5/90 New data statements for new parameters
  real(dp) :: grtol = 1.0e-8_dp
  integer :: ilambda = 1, niter_gs = 10
  logical :: ldify = .false.
  ! MHP 6/90 Additional common block for settling.
  real(dp) :: dt_gs = 0.1_dp, xmin = 1.0e-3_dp, ymin = 1.0e-3_dp
  logical :: lthoulfit = .false.
  ! MHP 3/94 Added metal diffusion
  real(dp) :: fgry = 1.0_dp, fgrz = 1.0_dp
  logical :: lthoul = .false., ldifz = .false.
  ! ges 6/15 New common block for light diffusion and new diff routine.
  logical :: lnewdif = .false., ldifli = .false.

  ! Variables from /PULSE/
  ! DBG Pulse
  ! DBG Pulse data card for pulsation
  real(dp) :: xmsol
  logical :: lpulse = .false.
  integer :: ipver = 1

  ! Variables from /PO/
  ! DBG Pulse out 7/92
  ! Variables used to control output of pulsation models.  Model
  ! output after has traveled pomax in hr diagram
  ! lpout and pomax added to control common block, rest in physics
  real(dp) :: poa = 1.0_dp, pob = 10.0_dp, poc = 0.0_dp, pomax = 0.1_dp
  logical :: lpout = .false.

  ! Variables from /TRACK/
  integer :: itrver = 1

  ! Variables from /ATMOS/
  ! surfbc.f: MHP 9/01 Added common block
  !           needed to switch to gray atmosphere from Kurucz/Ah above log
  !           Teff = 3.95
  ! putstore.f: LLP 3/19/03 Add required COMMON blocks such that header flags
  !                 ATM, EOS, HIK and LOK can be determined.
  ! parmmin.f: MHP 06/13 Added memory of whether the choice of atmospheres has
  !            been changed during the run, and what the original setting was
  real(dp) :: hras
  integer :: kttau = 0, kttau0
  logical :: lttau

  ! Variables from /MHD/
  ! YC  If LMHD is TRUE use MHD equation of state tables.  LU numbers
  !     are stored in IOMHDi.
  logical :: lmhd = .false.
  ! input: mhd equ. of state tables
  integer, parameter :: iomhd1 = 40, iomhd2 = 41, iomhd3 = 42, iomhd4 = 43, &
                      & iomhd5 = 44, iomhd6 = 45, iomhd7 = 46, iomhd8 = 47

  ! Variables from /CORE/
  ! DBG If LCORE is TRUE then calculate shells interior to start up
  !     model's inner most shell.
  logical :: lcore = .false.
  integer :: mcore = 0
  real(dp) :: fcore = 1.0_dp

  ! Variables from /CHRONE/
  ! DBG 11/11/91 Added to namelist
  logical :: lrwsh = .false., liso = .false.
  integer, parameter :: iiso = 37  ! output: isochrone information
  character(256) :: fiso

  ! Variables from /NEWXYM/
  ! DBG 1/92 let XENV0, ZENV0, and CMIXL be arrays so can change during
  ! a set of runs.
  real(dp) :: xenv0a(50), zenv0a(50), cmixla(50), senv0a(50) = 1.26e-4_dp
  logical :: lsenv0a(50) = .false.

  ! Variables from /NULOSS/
  ! 9/06 GN --- New neutrino loss common block
  logical :: lnulos1 = .false.  ! 3/92 DBG
  real(dp) :: dsnudt, dsnudd

  ! Variables from /CALS2/
  ! mhp 1/93 Add option to automatically calibrate solar model.
  ! mhp 6/13 Add option to calibrate solar Z/X, solar Z/X, solar age
  real(dp) :: toll = 1.0e-5_dp, tolr = 1.0e-4_dp, tolz = 1.0e-3_dp
  logical :: lcals = .false., lcalsolzx = .false.
  real(dp) :: calsolzx = 0.02292e0_dp, calsolage = 4.57e9_dp

  ! Variables from /ZRAMP/
  ! parmin.f: DBG 4/94 Added parameters to control ramp Z in core
  !           If lzramp=t then rescale Z in core from rsclzc value to Zenv value
  !           where change is linear. Z meets Zenv at rsclzm.
  ! wrthead.f: MHP 10/02 added proper dimensions for flaol2, fopal2
  ! sulaol.f: DBG 4/94 Modified to do ZRAMP stuff.
  real(dp) :: rsclzc(50) = -1.0_dp, rsclzm1(50) = -1.0_dp, rsclzm2(50) = -1.0_dp
  integer, parameter :: iolaol2 = 63, ioopal2 = 64  ! DBG 8/95 second opoacity tables for zramp and z diffusion
  integer :: nk
  logical :: lzramp = .false.
  character(256) :: flaol2, fopal2

  ! Variables from /CALSTAR/
  ! DBG 12/94 Added calibrate stellar model
  ! DBG 12/94 Calibrated stellar model stuff
  real(dp) :: xls, xlstol, steff, sr
  real(dp) :: bli, alri, ager, blr, blrp, agei
  logical :: lstar, lteff = .false., lpassr, lcalst = .false.

  ! Variables from /OPALEOS/
  ! eqstat.f: YCK >>>  2/95 OPAL eos
  !           LLP 2001 OPAL eos Mar 2003
  !           LLP 2006 OPAL eos Oct 2006
  !           LLP Add Use Numerical Derivatives flag, LNumDeriv   7/07
  ! parmin.f: LLP >>> OPAL 2001 EOS, Potekhin Conductive Opacities, &
  !           OPAL 2006 EOS, Use Numerical Derivitives switches
  character(256) :: fopale, fopale01, fopale06
  logical :: lopale = .false., lopale01 = .false., lopale06 = .false., lnumderiv = .false.
  integer, parameter :: iopale = 49  ! input: opal equation of state

  ! Variables from /NEWOPAC/
  ! Opacity common blocks - modified 3/09
  ! 3/09 Alexander 2006 opacity table options and opacity ramp options
  real(dp) :: zlaol1, zlaol2, zopal1, zopal2, zopal951
  real(dp) :: zalex1, zkur1, zkur2, tmolmin = 4.0_dp, tmolmax = 4.1_dp
  logical :: lalex06 = .false., llaol89, lopal92, lopal95, lkur90, lalex95, l2z

  ! Variables from /MISCOPAC/
  ! condopacp.f: The following three lines provide and interface to PARMIN in order to
  !              locate the Potekhin files.
  integer, parameter :: ikur2 = 65, &    ! DBG 8/95 second opoacity tables for zramp and z diffusion
                      & icondopacp = 75  ! Input files for Potekhin conductive opacities. LLP 7/8/06
  character(256) :: fkur2, fcondopacp
  logical :: lcondopacp = .false.

  ! Variables from /ALEXO/
  ! Alex low T opacity
  ! switch
  character(256) :: opecalex(7) = [character(256) :: 'OPACALEXANDER.X00', &
                                 & 'OPACALEXANDER.X01', 'OPACALEXANDER.X02', 'OPACALEXANDER.X035', &
                                 & 'OPACALEXANDER.X05', 'OPACALEXANDER.X07', 'OPACALEXANDER.X08']
  integer, parameter :: ialxo = 39  ! YCK input: Alex low T opacities

  ! Variables from /ALEX06/
  ! 2006 version added 3/09
  ! readalex06.f: Alex low t opacity common blocks
  character(256) :: falex06
  integer, parameter :: ialex06 = 90  ! 3/09 Input file for 2006 Alexander opacities

  ! Variables from /ALEXMIX/
  real(dp) :: xalex = 0.7, zalex = 0.02

  ! Variables from /NOTRAN/
  ! MHP 9/93
  logical :: lnoj = .false.

  ! Variables from /CROSS/
  ! parmin.f: 8/96 MHP New common block for nuclear reaction rates.
  ! main.f: MHP 6/14 Derivatives added to common block.  Not used for derivatives
  !         in the Monte Carlo.
  ! parmin.f: MHP 9/14 Extended to permit user rescaling of derivates of reaction
  !           rates and the branching ration for n15
  !           Changed slightly 3He-3He on 9/25/97 to take account of the S'.
  !            Previously (6/16/97) used S at Gamow Peak. Agrees with Workshop paper.
  real(dp) :: sstandard(17) = [0.9828, 1.0485, 0.9815, 0.9241, 1.3818, 1.0542, 1.0, &
                             & 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0108, 0.7819, 0.2875]
  real(dp) :: qs0e(8), qqs0ee(8), fo16, fc12
  logical :: lnewnuc = .false.

  ! Variables from /NEWCROSS/
  ! MHP 8/14 Default cross-sections are taken from the Solar Fusion II paper
  ! Reference Adelberger et al. 2011. Units are KeV b
  real(dp) :: s0_1_1 = 4.01e-22_dp, s0_3_3 = 5.21e3_dp, s0_3_4 = 5.6e-1_dp, &
            & s0_1_12 = 1.34_dp, s0_1_13 = 7.6_dp
  ! Note: pep is the proportionality constant relative to pp
  ! Note: Be7+e- is the proportionality constant in the linear term
  ! The code uses T9, not T6, so any expression in terms of T/10^6 k
  ! needs to be divided by 1000^0.5 (for both pep and Be7+e-)
  real(dp) :: s0_1_14 = 1.66_dp, s0_1_16 = 1.06e1_dp, &
            & s0_pep = 3.5734e-6_dp, s0_1_be7e = 1.7709e-10_dp
  real(dp) :: s0_1_be7p = 0.0208_dp, s0_hep = 8.6e-20_dp, &
            & s0_1_15_c12alp = 7.3e4_dp, s0_1_15_o16 = 3.6e1_dp
  ! Reference first derrivatives of cross-sections (Adelberger et al. 2011)
  ! units are b
  real(dp) :: s0p_1_1 = 4.49e-24_dp, s0p_3_3 = -4.9_dp, &
            & s0p_3_4 = -3.6e-4_dp, s0p_1_12 = 2.6e-3_dp
  real(dp) :: s0p_1_13 = -7.83e-3_dp, s0p_1_14 = -3.3e-3_dp, &
            & s0p_1_16 = -5.4e-2_dp, s0p_1_be7p = -3.12e-5_dp
  ! Reference second derivatives of cross sections (Adelberger et al. 2011)
  real(dp) :: s0pp_1_12 = 8.3e-5_dp, s0pp_1_13 = 7.29e-4_dp, &
            & s0pp_1_16 = 0.0_dp, s0pp_1_be7p = -2.288e-7_dp

  ! Variables from /NEWPARAM/
  ! 10/14 MHP New parameters - replacing dtdif,dtwind, hpttol & atime vectors
  real(dp) :: flag_dx = 0.05_dp, flag_dw = 0.10_dp, flag_dz = 0.05_dp
  logical :: lstruct_time = .false.
  real(dp) :: time_core_min = 1.0e-3_dp, time_dl = 2.0e-2_dp, time_dp = 4.0e-2_dp, &
            & time_dr = 2.0e-2_dp, time_dt = 2.0e-2_dp, time_dw_global = 8.0e-2_dp
  real(dp) :: time_dw_mix = 8.0e-2_dp, time_dx_core_frac = 0.5_dp, &
            & time_dx_core_tot = 2.0e-2_dp, time_dx_shell = 0.1_dp
  real(dp) :: time_dx_total = 1.5e-3_dp, time_dy_core_frac = 0.5_dp, time_dy_core_tot = 2.0e-2_dp
  real(dp) :: time_dy_shell = 0.1_dp, time_dy_total = 1.5e-3_dp, time_max_dt_frac = 1.5_dp
  real(dp) :: tol_czbase_fine_width = 0.0_dp
  real(dp) :: tol_dl_max = 0.02_dp, tol_dm_max = 0.08_dp, &
            & tol_dm_min = 1.0e-8_dp, tol_dp_core_max = 0.05_dp
  real(dp) :: tol_dp_czbase_max = 0.05_dp, tol_dp_env_max = 0.05_dp, &
            & tol_dx_max = 1.0_dp, tol_dz_max = 1.0_dp
  logical :: lnewvars = .false.

  ! Variables from /MONTE/
  ! main.f: MHP 8/96 Monte Carlo option for snus added.
  ! parmin.f: MHP data for Monte Carlo option, etc
  logical :: lmonte = .false.
  integer :: imbeg = 1, imend = 1

  ! Variables from /SCV2/
  character(len=256) :: fscvh, fscvhe, fscvz
  ! input files for the SCV EoS
  integer, parameter :: iscvh = 72, iscvhe = 73, iscvz = 74

  ! Variables from /ALATM03/
  ! envint.f: MHP 6/97 Added Allard model atmospheres
  ! parmin.f: LLP 9/08 New ALATM03 COMMON to share info with Allard atmosphere routines
  ! parmin.f: Default FeH and Alpha for new Allard Atmospheres
  real(dp) :: alatm_feH = 0.0_dp, alatm_alpha = 0.0_dp
  logical :: laltptau100 = .false.
  ! MHP 6/97 Added option for Allard model atmospheres
  integer, parameter :: ioatma = 66

  ! Variables from /ALATM04/
  character(len=256) :: fallard

  ! Variables from /DISK/
  ! MHP 9/94 Added disk locking option - flag, time over which locking
  ! is enforced, and period at which locking is set are options.
  real(dp) :: sage, tdisk = 0.0e0_dp, pdisk = 7.2722e-6_dp
  logical :: ldisk = .false.

  ! Variables from /WEAK/
  real(dp) :: weakscreening = 0.03_dp

  ! Variables from /SBROT/
  ! MHP 3/99 Added flag to treat the entire star as 'convective'
  ! for angular momentum purposes.
  ! parmin.f: MHP 3/99 OPtion for sb rotation enfored in the entire star at
  !           all times
  ! midmod.f: MHP 3/09 Added flag to enforce solid body rotation at all times.
  logical :: lsolid = .false.

end module settings
