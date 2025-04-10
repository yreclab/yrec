cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      SUBROUTINE:    wrtgrid
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c This routine writes out the grids for reference purposes only.
c
      subroutine wrtgrid(iog, numofxyz, lextra, gpstfx)
      logical lextra
      parameter(MXTB=10,MXTRHO=100)
      character*32 gpstfx
      character*20 prefx
      character*64 filenm
      common /weights/ xa(MXTB), ya(MXTB), za(MXTB), t(MXTRHO),
     1  rho(MXTRHO), xn(MXTB), yn(MXTB), zn(MXTB),
     2  z(3), awt(3), datmix(100),
     3  sumam(MXTB), sumaz(MXTB)
      common /grid/ rhog(MXTB, 50, 50), tg(MXTB, 50),
     1    rkapg(MXTB, 50, 50), eg(MXTB, 50, 50),
     2    pg(MXTB, 50, 50), epsg(MXTB, 50, 50),
     3    etag(MXTB, 50, 50)
      do i=1, numofxyz
	 if (i .le. 9) then
	    write(prefx,100)i
  100       format('GRID',i1,'.')
	 else
	    write(prefx, 101)i
  101       format('GRID',i2,'.')
	 end if
	 filenm = prefx // gpstfx
	 open (iog, FILE=filenm, CARRIAGECONTROL='LIST',
	1      STATUS='NEW', FORM='FORMATTED')
	 write(iog,190) xa(i), za(i)
  190    format(' X=', 1pe10.4, '  Z=', 1pe10.4)
	 write(iog, 201)
  201    format(' Density')
	 do j=1, 50
	    write(iog, 200) j, (rhog(i,j,k), k=1, 50)
  200       format(i5, 1p5e12.5, 9(/,5x,1p5e12.5))
	 end do
	 write(iog, 202)
  202    format(' Temperature')
	 j = 1
	 write(iog, 200)j, (tg(i,k), k=1, 50)
	 write(iog, 207)
  207    format(' Eta')
	 do j=1, 50
	    write(iog, 200) j, (etag(i,j,k), k=1, 50)
	 end do
	 write(iog, 203)
  203    format(' Opacity')
	 do j=1, 50
	    write(iog, 200) j, (rkapg(i,j,k), k=1, 50)
	 end do
	 if (lextra) then
	    write(iog, 204)
  204       format(' Energy')
	    do j=1, 50
	       write(iog, 200) j, (eg(i,j,k), k=1, 50)
	    end do
	    write(iog, 205)
  205       format(' Pressure')
	    do j=1, 50
	       write(iog, 200) j, (pg(i,j,k), k=1, 50)
	    end do
	    write(iog, 206)
  206       format(' Epsilon')
	    do j=1, 50
	       write(iog, 200) j, (epsg(i,j,k), k=1, 50)
	    end do
	 end if
	 close (iog)
      end do
      return
      end
