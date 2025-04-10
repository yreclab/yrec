cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  SUBROUTINE: interp
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c This routine interpolates the eta, T grid of opacities at the
c user specified rho, T values and returns the result in the
c "table" arrays.
c Interpolation proceeds as follows:
c 1.  Get a T row (run of eta) from the opacity grid.
c 2.  Interpolate row to requested density values (eta is function of T,rho)
c 3.  Repeat step 2 for all T rows
c
c Interpolation is not done in T, default values of T are used, i.e. the
c the T values of the orginal extinction coefficients.
c
      subroutine interp(numofxyz, numt, numrho, lextra)
      logical lextra
      parameter(MXTB=10,MXTRHO=100)
      dimension datmixh(100), datmixhe(100), datmixz(100),
     1          dtuh(2000), dtuhe(2000), dtuz(2000)
      dimension itemph(100), itemphe(100), itempz(100)
c Vectors to store rows before calling spline routines
      dimension xrho(50), xkap(50), xe(50), xp(50), xeps(50),
     1          xeta(50)
c Vectors to store derivatives used by spline routines
      dimension dkap(50), de(50), dp(50), deps(50),
     1          deta(50)
c Arrays to store interpolated in rho values
      dimension tkap(MXTRHO), te(MXTRHO), tp(MXTRHO),
     1          teps(MXTRHO), teta(MXTRHO)
c input stuff
      common /weights/ xa(MXTB), ya(MXTB), za(MXTB), t(MXTRHO),
     1  rho(MXTRHO), xn(MXTB), yn(MXTB), zn(MXTB),
     2  z(3), awt(3), datmix(100),
     3  sumam(MXTB), sumaz(MXTB)
c output tables calculated by interpolating the grids
      common /table/ rhot(MXTB, MXTRHO, MXTRHO),
     1    rkapt(MXTB, MXTRHO, MXTRHO), et(MXTB, MXTRHO, MXTRHO),
     2    pt(MXTB, MXTRHO, MXTRHO), epst(MXTB, MXTRHO, MXTRHO)
c input grids
      common /grid/ rhog(MXTB, 50, 50), tg(MXTB, 50),
     1    rkapg(MXTB, 50, 50), eg(MXTB, 50, 50),
     2    pg(MXTB, 50, 50), epsg(MXTB, 50, 50),
     3    etag(MXTB, 50, 50)
c indices for the grids
      common/index/ itx, iex(50)
      common /io/ioz, ioh, iohe, iodbug, iot, iog,iocoxl, iocoxh,iodv
c Outer loop: do all compositions (X, Y, Z)
      do ic=1, numofxyz
c Interpolate in rho (T values of original opacity tapes)
	 do j=1, itx
	    nrho = iex(j)
c Dump a row (fixed T) into a vector
	    do i=1, nrho
	       xrho(i) = rhog(ic, i, j)
	       xkap(i) = rkapg(ic, i, j)
	       xeta(i) = etag(ic, i, j)
	       if (lextra) then
		  xe(i) = eg(ic, i, j)
		  xp(i) = pg(ic, i, j)
		  xeps(i) = epsg(ic, i, j)
	       end if
	    end do
c Get derivatives for spline interpolation
	    call spline(xrho, xkap, nrho, 1.0e30, 1.0e30, dkap)
	    call spline(xrho, xeta, nrho, 1.0e30, 1.0e30, deta)
	    if (lextra) then
	       call spline(xrho, xe, nrho, 1.0e30, 1.0e30, de)
	       call spline(xrho, xp, nrho, 1.0e30, 1.0e30, dp)
	       call spline(xrho, xeps, nrho, 1.0e30, 1.0e30, deps)
	    end if
c Interpolate at the numrho densities
	    do i=1, numrho
	       rrho = alog10(rho(i))
	       if(rrho .ge. xrho(1) .and.
     1            rrho .le. xrho(nrho)) then
		  call splint(xrho, xkap, nrho, dkap, rrho, rkap)
		  rkapt(ic, i, j) = 10.0**rkap
		  if (lextra) then
		     call splint(xrho, xe, nrho, de, rrho, re)
		     et(ic, i, j) = re
		     call splint(xrho, xp, nrho, dp, rrho, rp)
		     pt(ic, i, j) = rp
		     call splint(xrho, xeps, nrho, deps, rrho, reps)
		     epst(ic, i, j) = reps
		  end if
	       else if (rrho .lt. xrho(1)) then
		  rkapt(ic, i, j) = 0.0
		  if (lextra) then
		     et(ic, i, j) = 0.0
		     pt(ic, i, j) = 0.0
		     epst(ic, i, j) = 0.0
		  end if
	       else
c Put extrapolation routine in here (DBG Warning, Tests show that you
c should not extrapolate the tables because of K-edges.)
		  rkapt(ic, i, j) = 0.0
		  if (lextra) then
		     et(ic, i, j) = 0.0
		     pt(ic, i, j) = 0.0
		     epst(ic, i, j) = 0.0
		  end if
	       end if
	    end do
	 end do
c
c Insert interpolation in T routines here if you want opacities at your
c own set of T values.
      end do
      return
      end
