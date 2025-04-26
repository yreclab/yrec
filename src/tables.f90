module tables
  use, intrinsic :: iso_fortran_env, only : dp => real64
  use params, only : nt, ng, ntc, ngc, nts, nps
  implicit none
  public

  ! Variables from /NWLAOL/
  ! DBGLAOL - to save space make tables single precision
  real(dp) :: olaol(12, 104, 52), oxa(12), ot(52), orho(104), tollaol = 10.0_dp
  integer, parameter :: iolaol  = 61  ! input LAOL opacities in dense grid format
  integer, parameter :: iopurez = 62  ! input: LAOL opacities for pure CN in dense grid format
  integer :: numofxyz, numrho, numt
  logical :: llaol = .false., lpurez = .false.
  character(256) :: flaol, fpurez

  ! Variables from /ATMOS2/
  ! JMH 8/18/91
  real(dp) :: atmpl(nt, ng), atmtl(nt), atmgl(ng), atmz
  integer :: ioatm
  character(256) :: fatm

  ! Variables from /ATMOS2C/
  ! parmin.f: JNT 6/14 Same as ATMOS2 but for Kurucz/Castelli2004 atmospheres
  ! envint.f: JNT 6/14 Add for Kurucz/Castelli 2004 atmospheres
  real(dp) :: atmplc(ntc, ngc), atmtlc(ntc), atmglc(ngc)

  ! Variables from /SCVEOS/
  ! MHP  5/97 Added common block for scv eos tables
  real(dp) :: tlogx(nts), tablex(nts, nps, 12), tabley(nts, nps, 12)
  real(dp) :: smix(nts, nps), tablez(nts, nps, 13), tablenv(nts, nps, 12)
  integer :: nptsx(nts)
  ! MHP 5/97 Option for Saumon, Chabrier, and Van Horn eos added
  logical :: lscv = .false.
  integer :: idtt, idp 

end module tables