ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c SUBROUTINE:  wrttab
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c This routine writes out the tables of opacity, etc to disk files.
c One file each is used for each composition.
c Zero entries indicate that the opacity was not
c available (i.e. calculated by LASL).
c
c The tables contain all T values, no interpolation in T is done.
c
      subroutine wrttab(iog, numofxyz, numrho, lextra, tpstfx)
      logical lextra
      parameter(MXTB=10, MXTRHO=100)
      character*32 tpstfx
      character*20 prefx
      character*64 filenm
      common /weights/ xa(MXTB), ya(MXTB), za(MXTB), t(MXTRHO),
     1  rho(MXTRHO), xn(MXTB), yn(MXTB), zn(MXTB),
     2  z(3), awt(3), datmix(100),
     3  sumam(MXTB), sumaz(MXTB)
c input grids
      common /grid/ rhog(MXTB, 50, 50), tg(MXTB, 50),
     1    rkapg(MXTB, 50, 50), eg(MXTB, 50, 50),
     2    pg(MXTB, 50, 50), epsg(MXTB, 50, 50),
     3    etag(MXTB, 50, 50)
c output tables calculated by interpolating the grids
      common /table/ rhot(MXTB, MXTRHO, MXTRHO),
     1    rkapt(MXTB, MXTRHO, MXTRHO), et(MXTB, MXTRHO, MXTRHO),
     2    pt(MXTB, MXTRHO, MXTRHO), epst(MXTB, MXTRHO, MXTRHO)
      do ic = 1, numofxyz
	 if (ic .le. 9) then
	    write(prefx, 100)ic
  100       format('TABLE', i1, '.')
	 else
	    write(prefx, 101)ic
  101       format('TABLE', i2, '.')
	 end if
	 filenm = prefx // tpstfx
	 open (iot, FILE=filenm,
     1         STATUS='NEW', FORM='FORMATTED')
	 write(iot, 190) xa(ic), ya(ic), za(ic), numrho
  190    format(' X =',1pe13.6,'  Y =',1pe13.6,'  Z =', 1pe13.6,
     1   /, i3, ' 46 (number of densities, number of temperatures)')
	 write(iot, 195) (rho(i),i=1, 50)
  195    format(/,' Densities (gm/cc):',/,(1p5e12.5))
	 write(iot, 196) (tg(ic, i), i=1, 50)
  196    format(/,' Temperatures:(eV) x11604.5 to get K',
     1    /,(1p5e12.5))
	 write(iot, 197)
  197    format(/,' Opacities (sq-cm/gm)',
     1    ' Arranged in blocks of common density')
	 do i=1, numrho
	    write(iot, 200)rho(i),(rkapt(ic, i, j), j=1, 50)
	 end do
  200    format (1pe7.1, 1p5e12.5, 9(/,7x,1p5e12.5))
	 if (lextra) then
	    write(iot, 201)
  201       format(/, 'log(Pressure) (gm/sq-cm)',
     1       ' Arranged in blocks of common density')
	    do i=1, numrho
	       write(iot, 200)rho(i), (pt(ic, i, j), j=1, 50)
	    end do
	    write(iot, 203)
  203       format(/, ' Energy (erg)',
     1       ' Arranged in blocks of common density')
	    do i=1, numrho
	       write(iot, 200)rho(i), (et(ic, i, j), j=1, 50)
	    end do
	    write(iot, 205)
  205       format(/, ' Epsilon)',
     1       ' Arranged in blocks of common density')
	    do i=1, numrho
	       write(iot, 200)rho(i), (epst(ic, i, j), j=1, 50)
	    end do
	 end if
	 close(iot)
      end do
      return
      end
