cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Subroutine:          COMBINE
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c This routine adds together the two elements h and he and the
c mixture z in the proportions given by the vectors xa, ya, and za.
c The resultant opacity coefficients are integrated to produce a final
c set of tables, one table for each xa, ya, za, at the eta rho values
c of the h, he, and z files.
      subroutine combine(numofxyz, lextra)
      logical lextra
      parameter(MXTB=10,MXTRHO=100)
      dimension datmixh(100), datmixhe(100), datmixz(100),
     1          dtuh(2000), dtuhe(2000), dtuz(2000)
      dimension itemph(100), itemphe(100), itempz(100)
c input stuff
      dimension wr(2000), dtu(2000)
      common /weights/ xa(MXTB), ya(MXTB), za(MXTB), t(MXTRHO),
     1  rho(MXTRHO), xn(MXTB), yn(MXTB), zn(MXTB),
     2  z(3), awt(3), datmix(100),
     3  sumam(MXTB), sumaz(MXTB)
c output tables calculated by interpolating the grids
      common /table/ rhot(MXTB, MXTRHO, MXTRHO),
     1    rkapt(MXTB, MXTRHO, MXTRHO), et(MXTB, MXTRHO, MXTRHO),
     2    pt(MXTB, MXTRHO, MXTRHO), epst(MXTB, MXTRHO, MXTRHO)
c indices for the grids
      common/index/ itx, iex(50)
c input grids
      common /grid/ rhog(MXTB, 50, 50), tg(MXTB, 50),
     1    rkapg(MXTB, 50, 50), eg(MXTB, 50, 50),
     2    pg(MXTB, 50, 50), epsg(MXTB, 50, 50),
     3    etag(MXTB, 50, 50)
      common /io/ioz, ioh, iohe, iodbug, iot, iog,iocoxl, iocoxh,iodv
      equivalence (datmixh(1), itemph(1)),
     1            (datmixhe(1), itemphe(1)),
     2            (datmixz(1), itempz(1))
c setup wr vector
      ui = 0.01
      dui = 0.01
      wconst = 0.0384974334
      do i=1, 2000
	 emu = exp(-ui)
	 wr(i) = ui**7*emu/(1.0-emu)**3
	 ui = ui + dui
      end do
      read(ioh, end=2222) datmixh, dtuh
      read(iohe, end=2222) datmixhe, dtuhe
      read(ioz, end=2222) datmixz, dtuz
      etah = datmixh(5)
      etahe = datmixhe(5)
      etaz = datmixz(5)
      tevh = datmixh(4)
      tevhe = datmixhe(4)
      tevz = datmixz(4)
      itx = 1
      iex(itx) = 0
      tevold = tevh
 1111 continue
      if ((etah .eq. etahe) .and. (etah. eq. etaz) .and.
     1  (tevh .eq. tevhe) .and. (tevh .eq. tevz)) then
c all three files match up so add them together
	 if (tevh .ne. tevold) then
	     tevold = tevh
	     itx = itx+1
	     iex(itx) = 0
	 end if
	 iex(itx) = iex(itx)+1
	 capf = datmixh(6)
	 rhoz = datmixh(7)
	 rdz = datmixh(17)
	 rdz = rdz * 5.29166e-9
	 fne = datmixh(24)
	 pz = datmixh(10)
	 amuh = datmixh(3)
	 amuhe = datmixhe(3)
	 amuz = datmixz(3)
	 capnfh = datmixh(8)
	 capnfhe = datmixhe(8)
	 capnfz = datmixz(8)
	 etotzh = datmixhe(11)
	 etotzhe = datmixhe(11)
	 etotzz = datmixz(11)
	 z2barh = datmixh(25)
	 z2barhe = datmixhe(25)
	 z2barz = datmixz(25)
	 excih = datmixh(36)
	 excihe = datmixhe(36)
	 exciz = datmixz(36)
	 feta = ffeta(etah)
	 pkt = tevh * 1.60209e-12
	 pezl = log10(0.66666666)+log10(fne)+log10(feta)
	1       -log10(capf)+log10(pkt)
c Numbers excede range of Vax
	 if (pezl .gt. 3.6e1) pezl = 3.6e1
	 if (pezl .lt. -3.6e1) pezl = -3.6e1
	 pez = 10.0**pezl
	 excih = (excih-2.15e12)*amuh
	 excihe = (excihe-2.15e12)*amuhe
	 exciz = (exciz-2.15e12)*amuz
	 t32 = (tevh/13.6048)**1.5
	 pe = pez
	 do i=1, numofxyz
	    en = 1.44782e12 * tevh/sumam(i)
	    sumexc = xn(i)*excih+yn(i)*excihe+zn(i)*exciz
	    tfree = capnfh*xn(i)+capnfhe*yn(i)+capnfz*zn(i)
	    sumaf2 = xn(i)*capnfh*capnfh+yn(i)*capnfhe*capnfhe
	1               +zn(i)*capnfhz*capnfhz
	    sumaz2 = xn(i)*z2barh+yn(i)*z2barhe+zn(i)*z2barz
c Rosseland mean sum over frequencies
	    do id=1, 2000
	       dtu(id) = dtuh(id)*xn(i)+dtuhe(id)*yn(i)
	1                    +dtuz(id)*zn(i)
	    end do
	    rhomix = 0.5676887*capf*t32*sumam(i)/tfree
	    zstar1 = sumaf2/tfree + 1.0
	    rdebye = 7.433385e2 * sqrt(tevh/(fne*zstar1))
	    rava = 1.0e-8*(0.396396588*sumam(i)/rhomix)**0.33333333
	    rmax = max(rava, rdebye)
	    epsi = 1.44e-7 * (1.0 + tfree) / (rmax * tevh)
	    pn = fne * pkt /tfree
	    ee = 1.5 * pe / rhomix
	    fnmax = max(2.0, tfree + sumaz2/tfree)
	    a1=(4.2e-7*fnmax/(tevh*rmax)+1.0)**0.6666666-1.0
	    epl = -2.413e11*tfree*tevh*a1
	1            *(1.0+tfree)/(sumam(i)*fnmax)
	    ppl = 0.3333333*rhomix*epl
	    pmix = pn + pe + ppl
	    sumexc = sumexc/sumam(i) + 2.15e12
	    emix = en + ee + epl + sumexc
c make grid entry
	    tryd = tevh/13.6048
	    arho = sumam(i)*tryd*2.1000e-7
	    tri = 0.0
	    tpi = 0.0
	    uplas = 2.1179*sqrt(tfree*rhomix/sumam(i))/tryd
	    nplas = uplas*100.
	    if (nplas .eq. 0) nplas = 1
	    ui = nplas*0.01
	    tri = wr(nplas)/(dtu(nplas)*2.0)
	    if (uplas .lt. 0.01) tri = wr(nplas)/dtu(nplas)
	    npp = nplas + 1
	    do j=npp, 2000
	       tri = tri+wr(j)/dtu(j)
	    end do
	    tri = wconst*0.01*(tri-wr(2000)/(dtu(2000)*2.0))
	    trk = 1.0/(arho*tri)
	    if (trk .gt. rkapmx) rkapmx = trk
	    it = itx
	    ie = iex(itx)
	    rkapg(i,ie,it) = alog10(trk)
	    tg(i,it)= tevh
	    rhog(i,ie,it) = alog10(rhomix)
	    etag(i,ie,it) = etah
	    if (lextra) then
	       epsg(i,ie,it) = epsi
	       eg(i,ie,it) = emix
	       pg(i,ie,it) = alog10(pmix)
	    end if
 3333    end do
	 read(ioh, end=2222) datmixh, dtuh
	 read(iohe, end=2222) datmixhe, dtuhe
	 read(ioz, end=2222) datmixz, dtuz
	 etah = datmixh(5)
	 etahe = datmixhe(5)
	 etaz = datmixz(5)
	 tevh = datmixh(4)
	 tevhe = datmixhe(4)
	 tevz = datmixz(4)
	 go to 1111
      else
c files do not match
c        write(iodbug,*)' recs do not match at: ',etah, tevh,
c    1   etahe, tevhe, etaz, tevz
	 if (tevh .lt. tevz) then
	    do while (tevh .lt. tevz)
	       read(ioh, end=2222) datmixh, dtuh
	       etah = datmixh(5)
	       tevh = datmixh(4)
	    end do
	    go to 1111
	 else if (tevhe .lt. tevz) then
	    do while (tevhe .lt. tevz)
	       read(iohe, end=2222) datmixhe, dtuhe
	       etahe = datmixhe(5)
	       tevhe = datmixhe(4)
	    end do
	    go to 1111
	 else if (tevh .gt. tevz) then
	    do while (tevz .lt. tevh)
	       read(ioz, end=2222) datmixz, dtuz
	       etaz = datmixz(5)
	       tevz = datmixz(4)
	    end do
	    go to 1111
	 else if (tevhe .gt. tevz) then
	    do while(tevz .lt. tevhe)
	       read(ioz, end=2222) datmixz, dtuz
	       etaz = datmixz(5)
	       tevz = datmixz(4)
	    end do
	    go to 1111
	 else
	    if (etah .lt. etaz) then
	       do while((etah .lt. etaz) .and. (tevh .eq. tevz))
		  read(ioh, end=2222) datmixh, dtuh
		  etah = datmixh(5)
		  tevh = datmixh(4)
	       end do
	       go to 1111
	    else if (etahe .lt. etaz) then
	       do while((etahe .lt. etaz) .and. (tevhe .eq. tevz))
		  read(iohe, end=2222) datmixhe, dtuhe
		  etahe = datmixh(5)
		  tevhe = datmixh(4)
	       end do
	       go to 1111
	    else if (etah .gt. etaz) then
	       do while((etaz .lt. etah) .and. (tevh .eq. tevz))
		  read(ioz, end=2222) datmixz, dtuz
		  etaz = datmixz(5)
		  tevz = datmixz(4)
	       end do
	       go to 1111
	    else
	       go to 1111
	    end if
	 end if
      end if
 2222 continue
c finished reading tape
      return
      end
