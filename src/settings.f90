module settings
  use, intrinsic :: iso_fortran_env, only : dp => real64
  implicit none
  public

  ! Variables from /VNEWCB/
  ! DBG 1/96 The array v, read in via rdlaol, contained the mass fractions
  ! of the envelope elements. It was used in starin to define fxenv,
  ! which are the number fraction of the envelope elements. fxenv was
  ! then updated in eqstat and eqsaha. Here we define vnew passed
  ! in a common block vnewcb. It is identical to v except that the numbers
  ! are defined here explicity for a G&N93 solar mixture. You can
  ! change them via the physics namelist. v is set equal to vnew in
  !  starin except when llaol=t (to maintain backward compatibility.
  !            Na          Al          Mg          Fe
  !            Si          C           H           O
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
  real(dp) :: atmerr, atmd0, atmbeg, atmmin, atmmax

  ! Variables from /INTENV/
  real(dp) :: enverr, envbeg, envmin, envmax

  ! Variables from /INTPAR/
  real(dp) :: stolr0
  integer :: imax, nuse

  ! Variables from /LABEL/
  real(dp) :: xenv0, zenv0

  ! Variables from /MONTE/
  ! main.f: MHP 8/96 Monte Carlo option for snus added.
  ! parmin.f: MHP data for Monte Carlo option, etc
  logical :: lmonte = .false.
  integer :: imbeg = 1, imend = 1

end module settings
