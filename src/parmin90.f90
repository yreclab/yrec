module parmin90
  use iso_fortran_env, only: dp => real64
  implicit none
  private

  ! Variables from COMMON/VNEWCB/
  public :: vnew

  ! Variables from COMMON/LUOUT/
  public :: ilast, idebug, itrack, ishort, imilne, imodpt, istor, iowr

  ! Variables from COMMON/LUNUM/
  public :: ifirst, irun, istand, ifermi
  public :: iopmod, iopenv, iopatm, idyn
  public :: illdat, isnu, iscomp, ikur

  ! Variables from COMMON/LUFNM/
  public :: flast, ffirst, frun, fstand, ffermi
  public :: fdebug, ftrack, fshort, fmilne, fmodpt
  public :: fstor, fpmod, fpenv, fpatm, fdyn
  public :: flldat, fsnu, fscomp, fkur
  public :: fmhd1, fmhd2, fmhd3, fmhd4, fmhd5, fmhd6, fmhd7, fmhd8

  ! Variables from COMMON/MONTE/
  public :: lmonte, imbeg, imend

  ! Variables from COMMON/VNEWCB/
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

  ! Variables from COMMON/LUOUT/
  integer, parameter :: ilast  = 11  ! output: last model (text)
  integer, parameter :: idebug = 18  ! output: reserved for debugging
  integer, parameter :: itrack = 19  ! output: track
  integer, parameter :: ishort = 20  ! output: all diagnostic info
  integer, parameter :: imilne = 21  ! output: Milne invariant variables
  integer, parameter :: imodpt = 22  ! output: shell by shell info on models
  integer, parameter :: istor  = 23  ! output: saved models, can be used as starting model
  integer, parameter :: iowr   = 6   ! output: status file

  ! Variables from COMMON/LUNUM/
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

  ! Variables from COMMON/LUFNM/
  character(len=256) :: flast, ffirst, frun, fstand, ffermi
  character(len=256) :: fdebug, ftrack, fshort, fmilne, fmodpt
  character(len=256) :: fstor, fpmod, fpenv, fpatm, fdyn
  character(len=256) :: flldat, fsnu, fscomp, fkur
  character(len=256) :: fmhd1, fmhd2, fmhd3, fmhd4, fmhd5, fmhd6, fmhd7, fmhd8

  ! Variables from COMMON/MONTE/
  ! MHP 8/96 Monte Carlo option for snus added.
  ! MHP data for Monte Carlo option, etc
  logical :: lmonte = .false.
  integer :: imbeg = 1, imend = 1

end module parmin90