module tables
  use, intrinsic :: iso_fortran_env, only : dp => real64
  use params, only : nt, ng, ntc, ngc  ! , nts, nps, json
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
  real(dp) :: atmpl(nt, ng)
  real(dp) :: atmtl(nt)
  real(dp) :: atmgl(ng)
  real(dp) :: atmz
  integer :: ioatm
  character(256) :: fatm

  ! Variables from /ATMOS2C/
  real(dp) :: atmplc(ntc, ngc)
  real(dp) :: atmtlc(ntc)
  real(dp) :: atmglc(ngc)

end module tables