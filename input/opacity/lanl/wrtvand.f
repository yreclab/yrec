cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      WRTVAND
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Warning this routine is tricky.  It attempts to fully automate the
c  the creation of a Vandenburg format opacity table.  At low temps
c  where the LASL tables do not exit it will read a set of Cox and
c  Stewart tables (stored in Vandenburg format) and interpolate, linearly,
c  to get the requested Z (zforcox).  The overall metallicity of the tables
c  is specified by zforvan.  zforcox allows, if desired, a different z
c  for the T<10000K Cox opaciites.
c  This routine, therefore, requires
c  a complete set in Z of Cox and Stewart opacity tables.  We normally
c  use z tables from 0.00001 to 0.10.  Two methods are used to fill in
c  gaps.  If lintrp is true then the program will carry out cubic spline
c  interpolation or as is mostly the case, extrapolation.  If ldoint is
c  false then the routine will fill the gaps with the opacity of its
c  nearest neighbor.
c
c  The output of the table, in addition to containing the opacity tables
c  themselves also contains a header which lists the abundances used by the
c  Cox mixture, scaled to the zforvan value. (only 10 elements)
c  We have added, at the end of the tables, the full mixture used to
c  construct the tables, scaled to the zforvan values.
      subroutine wrtvand(zforcox, zforvan, coxz, bz, coxfnm, numcox, 
     1   numrho, vandfnm, ldoint)
      parameter(MXTB=10, MXTRHO=100)
      logical interp
      character*64 coxfnm(10), vandfnm
      dimension tout(29), cox(10),cr(10),dincr(29),incr(29),it(29),
     1          rkout(5, 10, 29), coxm(10)
      dimension tk(50), tr(50), dtk(50)
      dimension coxz(10), coxkh(5,10,29),coxkl(5,10,29), bz(20)
      dimension coxxl(5), coxxh(5), xkl(5), xkh(5), dxkl(5), dxkh(5)
      dimension awtcox(10), frnum(10)
      common /weights/ x(MXTB), y(MXTB), z(MXTB), ttt(MXTRHO),
     1  rho(MXTRHO), xn(MXTB), yn(MXTB), zn(MXTB),
     2  zz(3), awt(3), datmix(100),
     3  sumam(MXTB), sumaz(MXTB)
c output tables calculated by interpolating the grids
      common /table/ rhot(MXTB, MXTRHO, MXTRHO),
     1    rkap(MXTB, MXTRHO, MXTRHO), et(MXTB, MXTRHO, MXTRHO),
     2    pt(MXTB, MXTRHO, MXTRHO), epst(MXTB, MXTRHO, MXTRHO)
c input grids
      common /grid/ rhog(MXTB, 50, 50), tg(MXTB, 50),
     1    rkapg(MXTB, 50, 50), eg(MXTB, 50, 50),
     2    pg(MXTB, 50, 50), epsg(MXTB, 50, 50),
     3    etag(MXTB, 50, 50)
c indicies for the grids
      common /io/ioz, ioh, iohe, iodbug, iot, iog, iocoxl, iocoxh,iodv
c     atomic weights of C, N, O, Ne, Na, Mg, Al, Si, Ar, Fe
      data awtcox/ 12.0111, 14.0067, 15.9994, 20.179,
     1 22.9898, 24.305, 26.9815, 28.086,  39.948,
     2 55.847    /
      eVtoK = 11604.5
c mass fractions of 10 elements (originally used in Cos&Stewart tables)
c normalized to 1
c C, N, O, Ne, Na, Mg, Al, Si, Ar, Fe
      coxm(1) = 1.410e-1
      coxm(2) = 4.600e-2
      coxm(3) = 4.200e-1
      coxm(4) = 2.980e-1
      coxm(5) = 1.000e-3
      coxm(6) = 1.800e-2
      coxm(7) = 1.000e-3
      coxm(8) = 2.600e-2
      coxm(9) = 3.900e-2
      coxm(10)= 8.000e-3
c     C number fraction
      frnum(1) = datmix(52)
c     N
      frnum(2) = datmix(53)
c     O
      frnum(3) = datmix(54)
C     Ne
      frnum(4) = datmix(55)
c     Na
      frnum(5) = datmix(56)
c     Mg
      frnum(6) = datmix(57)
c     Al
      frnum(7) = datmix(58)
c     Si
      frnum(8) = datmix(59)
c     Ar
      frnum(9) = datmix(63)
c     Fe
      frnum(10) = datmix(68)
c     convert number fractions to mass fractions
      sum = 0.0
      ren = 0.0
      do i=1, 10
	  ren = ren + frnum(i)
      enddo
      do i=1, 10
	  frnum(i) = frnum(i)/ren
	  sum = sum + frnum(i) * awtcox(i)
      enddo
      do i=1, 10
	  cox(i) = frnum(i) * awtcox(i) / sum
      enddo
c Cox densities - logged
      cr(1) = -13.0
      cr(2) = -12.0
      cr(3) = -11.0
      cr(4) = -10.0
      cr(5) =  -9.0
      cr(6) =  -8.0
      cr(7) =  -7.0
      cr(8) =  -6.0
      cr(9) =  -5.0
      cr(10) = -4.0
c     DV Temps  Our Temps  Index to DG Temps
c  1  1500      1500       0
c  2  2500      2500       0
c  3  3000      3000       0
c  4  4000      4000       0
c  5  5000      5000       0
c  6  6000      6000       0
c  7  7000      7000       0
c  8  8000      8000       0
c  9  9000      9000       0
c 10  10K       10K        0       eV (x11604.5 to get Kelvin)
c 11  12K       11.6K      1     1.00
c 12  15K       14.5K      2     1.25
c 13  20K       23.2K      4     2.00
c 14  30K       29.0K      5     2.5
c 15  50K       46.4K      7     4.0
c 16  70K       69.6K      9     6.0
c 17  100K      92.8K     10     8.0
c 18  200K      174K      13    15.0
c 19  500K      464K      17    40.0
c 20  1M        1.16M     21   100.0
c 21  2M        1.74M     23   150.0
c 22  5M        4.64M     27   400.0
c 23  10M       11.6M     31  1000.0
c 24  20M       17.4M     33  1500.0
c 25  50M       46.4M     37  4000.0
c 26  100M      116M      41 10000.0
c 27  200M      174M      42 15000.0
c 28  500M      464M      44 40000.0
c 29 1000M     1160M      46  100K
c
c Setup output temperature  index
      it(1) = 0
      it(2) = 0
      it(3) = 0
      it(4) = 0
      it(5) = 0
      it(6) = 0
      it(7) = 0
      it(8) = 0
      it(9) = 0
      it(10) = 0
      it(11) = 1
      it(12) = 2
      it(13) = 4
      it(14) = 5
      it(15) = 7
      it(16) = 9
      it(17) = 10
      it(18) = 13
      it(19) = 17
      it(20) = 21
      it(21) = 23
      it(22) = 27
      it(23) = 31
      it(24) = 33
      it(25) = 37
      it(26) = 41
      it(27) = 42
      it(28) = 44
      it(29) = 46
c power of ten offset for opacities
      incr(1) = 0
      incr(2) = 0
      incr(3) = 0
      incr(4) = 0
      incr(5) = 0
      incr(6) = 0
      incr(7) = 1
      incr(8) = 1
      incr(9) = 1
      incr(10) = 2
      incr(11) = 2
      incr(12) = 2
      incr(13) = 2
      incr(14) = 2
      incr(15) = 3
      incr(16) = 3
      incr(17) = 4
      incr(18) = 4
      incr(19) = 5
      incr(20) = 6
      incr(21) = 7
      incr(22) = 8
      incr(23) = 9
      incr(24) = 10
      incr(25) = 11
      incr(26) = 12
      incr(27) = 13
      incr(28) = 14
      incr(29) = 15
      do i=1, 29
	 dincr(i) = incr(i)
      end do
c Scale Cox mixture to new Z
      do i=1, 10
c Jan 28, 1991 change zforcox to zforvan
	 cox(i) = cox(i) * zforvan
      end do
c Read in appropiate Cox tables to do linear interpolation
c of low temperature opacities in Z and cubic spline interpolation
c in X.
      call locate(coxz, numcox, zforcox, jj)
      if (jj .eq. 0) then
	 locox = 1
	 hicox = 2
      else if (jj .eq. numcox) then
	 locox = jj - 1
	 hicox = jj
      else
	 locox = jj
	 hicox = jj + 1
      end if
      open (iocoxl, FILE=coxfnm(locox), FORM='FORMATTED',
     1    CARRIAGECONTROL='LIST', STATUS='OLD',READONLY)
      open (iocoxh, FILE=coxfnm(hicox), FORM='FORMATTED',
     1    CARRIAGECONTROL='LIST', STATUS='OLD',READONLY)
      open (iodv, FILE=vandfnm, FORM='FORMATTED',
     1   CARRIAGECONTROL='LIST',  STATUS='NEW')
      zlo = coxz(locox)
      zhi = coxz(hicox)
c     write(iodbug,*) 'locox=', locox,zlo, coxfnm(locox)
c     write(iodbug,*) 'hicox=', hicox,zhi, coxfnm(hicox)
      read(iocoxl, 299)
      read(iocoxh, 299)
 299  format(1x)
      read(iocoxl, 300) (((coxkl(i, j, k),j=1,10),k=1,29),i=1,5)
      read(iocoxh, 300) (((coxkh(i, j, k),j=1,10),k=1,29),i=1,5)
 300  format(1p8e9.2)
      do i=1, 7
	 read(iocoxl, 299)
	 read(iocoxh, 299)
      end do
      read(iocoxl, 301) coxxl
      read(iocoxh, 301) coxxh
 301  format(1p5e10.3)
      write(iodbug, *) 'coxxl=', coxxl
      write(iodbug, *) 'coxxh=', coxxh
c
c Carry out spline interp in X to get X(1...5) the same as in
c the LASL tables
      do j=1, 10
c Don't waste time with high temps (i.e. k=1...10 rather than ...29)
	 do k=1, 10
	    do i=1, 5
	       xkl(i) = coxkl(i, j, k)
	       xkh(i) = coxkh(i, j, k)
	    end do
c     write(iodbug, *) 'xkl=', xkl
c     write(iodbug, *) 'xkh=', xkh
	    isize = 5
	    call spline(coxxl, xkl, isize, 1.0e30, 1.0e30, dxkl)
	    call spline(coxxh, xkh, isize, 1.0e30, 1.0e30, dxkh)
	    do i=1, 5
	       thex = x(i)
	       call splint(coxxl, xkl, isize, dxkl, thex, thekl)
	       call splint(coxxh, xkh, isize, dxkh, thex, thekh)
	       coxkl(i, j, k) = thekl
	       coxkh(i, j, k) = thekh
c      write(iodbug, *) i, j, k, thekl, thekh
	    end do
	 end do
      end do
c Setup output temps
      tout(1) = 1500.
      tout(2) = 2500.
      tout(3) = 3000.
      tout(4) = 4000.
      tout(5) = 5000.
      tout(6) = 6000.
      tout(7) = 7000.
      tout(8) = 8000.
      tout(9) = 9000.
      tout(10) = 10000.
      do i=11, 29
	 tout(i) = eVtoK * tg(1,it(i))
      end do
c Fill up output opacity matrix
      do ic= 1, 5
	 do ir=1, 10
	    do itt=1,29
	       if (it(itt) .eq. 0) then
      temp = (coxkh(ic,ir,itt)-coxkl(ic,ir,itt))*
     1       (zforcox-zhi)/(zhi-zlo) + coxkh(ic,ir,itt)
		  rkout(ic,ir,itt) = temp
	       else
		  rkout(ic,ir,itt) = rkap(ic,ir+incr(itt),it(itt))
	       end if
	    end do
	 end do
      end do
c Do interpolation to fill in gaps
      if (ldoint) then
      do ic= 1, 5
	 do itt=1, 29
	    if (it(itt) .ne. 0) then
	       irr = 1
	       do ir=1, numrho
		  if (rkap(ic, ir, it(itt)) .ne. 0.0) then
		      tk(irr) = log10(rkap(ic, ir, it(itt)))
		      tr(irr) = log10(rho(ir))
		      irr = irr+1
		  end if
	       end do
	       irr = irr-1
	       if (irr .ge. 3) then
		  call spline(tr, tk, irr, 1.0e30, 1.0e30, dtk)
		  do ir=1,10
		     if (rkout(ic,ir,itt) .eq. 0.0) then
			therho = log10(rho(ir+incr(itt)))
			call splint(tr, tk, irr, dtk, therho,
     1                           thek)
			if (thek.lt.-25.0) then
			    thek =-25.0
			end if
			if (thek.gt.25.0) then
			    thek = 25.0
			end if
			rkout(ic, ir, itt) = 10.0**thek
		     end if
		  end do
	       end if
	    end if
	 end do
      end do
      else
c no interpolation, fill gaps with neighbor values in rho
c gaps assumed to be at ends with no more than four zeros in a row
      do ic=1, 5
	 do itt=1, 29
	    do ir=5, 1, -1
	       if (rkout(ic, ir, itt) .eq .0.0) then
		   rkout(ic,ir,itt) = rkout(ic,ir+1, itt)
	       end if
	    end do
	    do ir=6, 10
	       if (rkout(ic, ir, itt) .eq .0.0) then
		   rkout(ic,ir,itt) = rkout(ic,ir-1, itt)
	       end if
	    end do
	 end do
      end do
      end if
c Write out first line: as of Jan 28, 1991 this line contains the
c mass fraction abundances of those elements used in the cox mixture
c scaled to a Z of zforvan, i.e. the mass fractions sum to zforvan.
      write(iodv, 200) cox
  200 format(1p10e8.3e1)
c Write out opacities
      write(iodv, 210) (((rkout(i,j,k), j=1,10), k=1,29),i=1, 5)
  210 format(1p8e9.2)
c Write out temperature (logged)
      do i=1, 29
	 tout(i) = log10(tout(i))
      end do
      write(iodv,220) tout
  220 format(1p7e11.4)
c Write list of 10 densities-logged-before incr offset
      write(iodv, 230) cr
  230 format(1p8e10.3)
c Write out composition X
      write(iodv, 235) (x(ii), ii=1, 5)
  235 format(1p5e10.3)
c Write list of increments
      write(iodv, 240) dincr
  240 format(1p8e10.3)
c January 25, 1991  Added line to opacity table to indicate the 
c     mass fraction of the zforvan mixture.
      sum = 0.0
      do ii=3, 20
        sum = sum + bz(ii)
      enddo
      do ii=3, 20
         bz(ii) = bz(ii)/sum
         bz(ii) = bz(ii) * zforvan
      enddo
      write(iodv, 250) (bz(ii), ii=1, 20)
  250 format(1p8e10.3)
      do i=1, 10
	 coxm(i) = coxm(i) * zforcox
      end do
c January 28, 1991 added scaled to zforcox cox mixture: this mixture is
c the one used to calculate low temp opacities.
      write(iodv, 255) coxm
  255 format(1p8e10.3)
      stop
      end
