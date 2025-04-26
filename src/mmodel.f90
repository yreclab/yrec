module mmodel
  use, intrinsic :: iso_fortran_env, only : dp => real64
  implicit none
  public

  ! the array size, i.e. max # of shells is specified in the 
  ! parameter statement.  it defines JSON.  to change the array
  ! size do a global change on "JSON=2000" or whatever.
  integer, parameter :: json = 5000

  ! Variables from /VARFC/
  ! seculr.f: Add option for variable FC.
  ! parmin.f: MHP 7/93 Variable fc option
  !           MHP 9/94 Combined diffusion/advection option
  real(dp) :: vfc(json)
  logical :: lvfc = .false., ldifad = .false.

  ! Variables from /ACDPTH/
  ! JVS 02/11 Acoustic depth calc common block
  real(dp) :: tauczn, deladj(json), tauhe, tnorm, tcz, whe
  real(dp) :: acatmr(json), acatmd(json), acatmp(json), acatmt(json), tatmos
  ! JVS 02/11 Initialize acoustic depth common block values appropriately
  real(dp) :: ageout(5) = [0.5_dp, 1.0_dp, 5.0_dp, 10.0_dp, 20.0_dp]
  integer :: iclcd, iacat, ijlast, ijvs, ijent, ijdel
  logical :: lclcd = .false., ljlast = .false., ljwrt = .false., ladon, laoly, lacout = .false.

end module
