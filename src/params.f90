module params
  use iso_fortran_env, only : dp => real64
  implicit none

  private
  public :: json  ! max # of shells
  public :: numtt, numd, numx, numz, numxz  ! opal95, op95, and ll95
  public :: nt, ng, ntc, ngc, nta, nga, nts, nps  ! surface pressures
  public :: mx, mv, nreos, nteos, nr01, nt01, nr06, nt06  ! OPAL EOS tables
  public :: ivarx, nchem0, cnvs, zero  ! EOS tables
  public :: numxalx, numzalx, numxzalx, numtalx, numdalx, numxtalx
  public :: numx06, numz06, numxz06, numt06, numd06  ! Alexander low T opacities

  ! the array size, i.e. max # of shells is specified in the 
  ! parameter statement.  it defines JSON.  to change the array
  ! size do a global change on "JSON=2000" or whatever.
  integer, parameter :: json = 5000

  ! table dimensions for opal95, op95, and ll95 (KC 2025-04-19)
  integer, parameter :: numtt = 70, numd = 19, numx = 10, numz = 13, numxz = 126

  ! envint.f: parameters nt and ng for tabulated surface pressures of Kurucz.
  integer, parameter :: nt = 57, ng = 11
  ! parmin.f: JNT 6/2014 add ntc and ngc for Kurucz/Castelli surface pressures
  ! envint.f: JNT 06/14 added ntc/ngc for kttau=5
  ! setups.f: JNT 06/14 add ntc for Kurucz/Castelli 2004 atmosphere
  integer, parameter :: ntc = 76, ngc = 11
  ! parmin.f: parameters nta and nga for tabulated Allard model surface pressures.
  ! envint.f: MHP 8/97 added nta and nga for Allard atmosphere tables
  integer, parameter :: nta = 54, nga = 5
  integer, parameter :: nts = 63, nps = 76

  ! OPAL EOS tables
  integer, parameter :: mx = 5, mv = 10, nreos = 77, nteos = 56
  integer, parameter :: nr01 = 169, nt01 = 191
  integer, parameter :: nr06 = 169, nt06 = 197

  ! EOS tables
  integer, parameter :: ivarx = 25, nchem0 = 6
  real(dp), parameter :: cnvs = 0.434294481_dp
  real(dp), parameter :: zero = 0.0_dp

  ! Alexander low T opacities
  integer, parameter :: numxalx = 7, numzalx = 15, numxzalx = 105
  integer, parameter :: numtalx = 23, numdalx = 17, numxtalx = 8
  integer, parameter :: numx06 = 9, numz06 = 16, numxz06 = 143
  integer, parameter :: numt06 = 85, numd06 = 19

end module params