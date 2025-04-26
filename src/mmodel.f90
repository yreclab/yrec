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

end module mmodel