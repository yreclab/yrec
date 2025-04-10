c    This program interpolates EOS5_* files to make a table for the
c    specific Z of interest.  The only input required is the value of
c    Z.  The output file is named EOSdata.  The EOSdata file is
c    read by the interpolation code EOS5_xtrin.f. A new EOSdata file
c    is needed everytime Z is changed.

      parameter (nr=170,ntt=200)
      parameter (nruse=169)
      real moles,molesz
      character*1 blank, blank1
      character front*3,front1*8,front2*8,front3*8,middle*24,eend(6)*3
      character*24 tabfile,tabfilem,tabfileu,tabfilez
      dimension z(3),moles(3),tmass(3),frac(3,6),fracz(7)
      dimension density(nr),t6(ntt),alogr(nr,ntt),p(nr,ntt)
     x ,s(nr,ntt),dedrho(nr,ntt),cv(nr,ntt),chir(nr,ntt)
     x ,chit(nr,ntt),gam1(nr,ntt),gam2p(nr,ntt),gam3p(nr,ntt)
     x ,icycuse(nr),en(nr,ntt),toff(nr),doff(nr)
     x ,amu_M(nr,ntt),alogN_e(nr,ntt)
      dimension densitym(nr),t6m(ntt),alogrm(nr,ntt),pm(nr,ntt)
     x ,sm(nr,ntt),dedrhom(nr,ntt),cvm(nr,ntt),chirm(nr,ntt)
     x ,chitm(nr,ntt),gam1m(nr,ntt),gam2pm(nr,ntt),gam3pm(nr,ntt)
     x ,icycusem(nr),enm(nr,ntt),toffm(nr),doffm(nr)
     x ,amu_Mm(nr,ntt),alogN_em(nr,ntt)
      dimension densityu(nr),t6u(ntt),alogru(nr,ntt),pu(nr,ntt)
     x ,su(nr,ntt),dedrhou(nr,ntt),cvu(nr,ntt),chiru(nr,ntt)
     x ,chitu(nr,ntt),gam1u(nr,ntt),gam2pu(nr,ntt),gam3pu(nr,ntt)
     x ,icycuseu(nr),enu(nr,ntt),toffu(nr),doffu(nr)
     x ,amu_Mu(nr,ntt),alogN_eu(nr,ntt)



      write (*,'("type Z:  ",$)')
      read (*,*) zz
      write (*,'(f15.9)') zz

      blank1=' '
      front='eos'
      eend(1)='0x'
      eend(2)='2x'
      eend(3)='4x'
      eend(4)='6x'
      eend(5)='8x'
      eend(6)='10x'
      front1='EOS5_00z'
      tabfilez='EOS5_data_H-He'
      open (15,file=tabfilez ,status='new' ,err=383)
      do kk=1,6
      tabfile=front1//eend(kk)
      j=0
          if (kk .eq. 1 ) then
            call system ('gunzip EOS5_00z0x')
          endif
          if (kk .eq. 2 ) then
            call system ('gunzip EOS5_00z2x')
          endif
          if (kk .eq. 3 ) then
            call system ('gunzip EOS5_00z4x')
          endif
          if (kk .eq. 4 ) then
            call system ('gunzip EOS5_00z6x')
          endif
          if (kk .eq. 5 ) then
            call system ('gunzip EOS5_00z8x')
          endif
          if (kk .eq. 6 ) then
            call system ('gunzip EOS5_00z10x')
          endif
            open (8,file=tabfile ,status='old' ,err=380)
      numprev=0   ! table op

      read (8,'(3x,f6.4,3x,f6.4,11x,f10.7,17x,f10.7)')
     x  x,z(1),moles(1),tmass(1)
      write (18,'(3x,f6.4,3x,f6.4,11x,f10.7,17x,f10.7)')
     x  x,z(1),moles(1),tmass(1)
      tmassz=gmass(x,z(1),amoles,eground,amassz,fracz)
      read (8,'(21x,e14.7,4x,e14.7,3x,e11.4,3x,e11.4,3x,e11.4,
     x 4x,e11.4)') (frac(1,i),i=1,6)
      write (18,'(21x,e14.7,4x,e14.7,3x,e11.4,3x,e11.4,3x,e11.4,
     x 4x,e11.4)') (frac(1,i),i=1,6)
      read (8,'(a)') blank
      write (18,'(a)') blank
      do 398 jcs=1,50000
      read (8,'(2i5,2f12.7,17x,e15.7)') numtot,icycuse(jcs)
     x  ,toff(jcs),doff(jcs),density(jcs)
      write (18,'(2i5,2f12.7,17x,e15.7)') numtot,icycuse(jcs)
     x  ,toff(jcs),doff(jcs),density(jcs)
      if(numtot .eq. 0)then
       backspace 8
      go to 397
      endif
      numprev=numprev+1   ! table op
      read(8,'(a)') blank
      read(8,'(a)') blank
      write(18,'(a)') blank
      write(18,'(a)') blank
      do 399 i=1,icycuse(jcs)
      read (8,'(f11.6,1x,f7.4,1pe12.4,2e14.6,2e11.3,0pf12.8,6f10.6)') 
     x t6(i),amu_M(jcs,i),alogN_e(jcs,i)
     x ,p(jcs,i),en(jcs,i),s(jcs,i),dedrho(jcs,i),cv(jcs,i),chir(jcs,i)
     x ,chit(jcs,i),gam1(jcs,i),gam2p(jcs,i)
      write (18,'(f11.6,1x,f7.4,1pe12.4,2e14.6,2e11.3,0pf12.8,6f10.6)') 
     x t6(i),amu_M(jcs,i),alogN_e(jcs,i)
     x ,p(jcs,i),en(jcs,i),s(jcs,i),dedrho(jcs,i),cv(jcs,i),chir(jcs,i)
     x ,chit(jcs,i),gam1(jcs,i),gam2p(jcs,i)
      if (im1 .lt. 200) then
        im1=im1+1
      endif
      p0=t6(i)*density(jcs)
      p(jcs,i)=p(jcs,i)/p0
      en(jcs,i)=(en(jcs,i)*tmass(1)-eground)/(t6(i)*tmass(1))
  399 continue
      read(8,'(a)') blank
      read(8,'(a)') blank
      read(8,'(a)') blank
      write(18,'(a)') blank
      write(18,'(a)') blank
      write(18,'(a)') blank
  398 continue
  397 continue


      tmassz=gmass (x,zz,amoles,eground,amassz,fracz)

      write (15,'(" X=",f6.4," Z=",f12.9,5x,"moles=",f10.7,
     x "  mass/mole(ion)=",f10.7,3x,"eground=",f12.7)') 
     x  x,zz,amoles,tmassz,eground
      write (15,'(" Number fractions: ","H=",1pe14.7," He=",e14.7,
     x " C=",e11.4," N=",e11.4," O=",e11.4," Ne=",e11.4)')
     x (fracz(i),i=6,1,-1)
      write(15, '(a)') blank

      kcs=0
      numuse=numprev
c     if (numuse .gt. nruse) numuse=nruse
      do 498 jcs=1,numuse
c     icycuse(jcs)=min0( icycuse(jcs), icycusem(jcs), icycuseu(jcs) )
      kcs=kcs+1
      write(15,'(2i5,2f12.7,"  density(g/cc)= ",1pe15.7,
     x" U=10e+12ergs/gm Us=U/(10e+6K) P0=T6*density ")')
     x  kcs,icycuse(jcs),toff(jcs),doff(jcs), density(jcs)
      write(15,
     x        '("  T6         mu_M  log N_e",
     x "      P/P0         E(U)/T6      S(Us)     dE/dRho       Cv   "
     x    ,"   chir  ","    chit  "
     x       ,"    g1    "," g2/(g2-1)", /)')
c     write (15,'(1h0)')


      do 499 i=1,icycuse(jcs)
c     read(9,'(1h0)')
      write (15,'(f11.6,1x,f6.4,1pe11.4,2e13.6,2e11.3,0p5f10.6)') t6(i),
     x amu_M(jcs,i),alogN_e(jcs,i),p(jcs,i),en(jcs,i),s(jcs,i)
     x,dedrho(jcs,i),cv(jcs,i),chir(jcs,i),chit(jcs,i),gam1(jcs,i),
     x gam2p(jcs,i)
  499 continue
      write(15,'(a)') blank
      write(15,'(a)') blank
      write(15,'(a)') blank

  498 continue
      izero=0
      write (15,'(2i5)') izero,izero
          if (kk .eq. 1 ) then
            call system ('gzip EOS5_00z0x')
          endif
          if (kk .eq. 2 ) then
            call system ('gzip EOS5_00z2x')
          endif
          if (kk .eq. 3 ) then
            call system ('gzip EOS5_00z4x')
          endif
          if (kk .eq. 4 ) then
            call system ('gzip EOS5_00z6x')
          endif
          if (kk .eq. 5 ) then
            call system ('gzip EOS5_00z8x')
          endif
          if (kk .eq. 6 ) then
            call system ('gzip EOS5_00z10x')
          endif
      enddo

      close (15)
      call system ('gzip EOS5_data_H-He')
      stop
  380 write (*,'("File missing is ",a)') tabfile
      stop
  381 write (*,'("File missing is ",a)') tabfilem
      stop
  382 write (*,'("File missing is ",a)') tabfileu
      stop
  383 write (*,'("File already exists:  ",a)') tabfilez
      stop
      end

c************************************************************************
      function quad(x,y1,y2,y3,x1,x2,x3)
c..... this function performs a quadratic interpolation.
      save
      dimension  xx(3),yy(3)
      if(x .eq.0) then
        quad=y1
        return
      endif
      xx(1)=x1
      xx(2)=x2
      xx(3)=x3
      yy(1)=y1
      yy(2)=y2
      yy(3)=y3
        if(ic .eq. 0) then
          ic=1
          xx12=1./(xx(1)-xx(2))
          xx13=1./(xx(1)-xx(3))
          xx23=1./(xx(2)-xx(3))
          xx1sq=xx(1)*xx(1)
          xx1pxx2=xx(1)+xx(2)
        endif
      c3=(yy(1)-yy(2))*xx12
      c3=c3-(yy(2)-yy(3))*xx23
      c3=c3*xx13
      c2=(yy(1)-yy(2))*xx12-xx1pxx2*c3
      c1=yy(1)-xx(1)*c2-xx1sq*c3
      dkap=c2+(x+x)*c3
      quad=c1+x*(c2+x*c3)
      return
      end
c******************************************************************
      function gmass(x,z,amoles,eground,fracz,frac)
      dimension anum(6),frac(7), amas(7),eion(7)
      data (eion(i),i=1,6)/-3394.873554,-1974.86545,-1433.92718,
     x  -993.326315,-76.1959403,-15.28698437/
      data (anum(i),i=1,6)/10.,8.,7.,6.,2.,1./
      xc=0.247137766
      xn=.0620782
      xo=.52837118
      xne=.1624188
      amas(7)=1.0079
      amas(6)=4.0026
      amas(5)=12.011
      amas(4)=14.0067
      amas(3)=15.9994
      amas(2)=20.179
      amas(1)=0.00054858
      fracz=z/(xc*amas(5)+xn*amas(4)+xo*amas(3)+xne*amas(2))
      xc2=fracz*xc
      xn2=fracz*xn
      xo2=fracz*xo
      xne2=fracz*xne 
      xh=x/amas(7)
      xhe=(1.-x -z)/amas(6)
      xtot=xh+xhe+xc2+xn2+xo2+xne2
      frac(6)=xh/xtot
      frac(5)=xhe/xtot
      frac(4)=xc2/xtot
      frac(3)=xn2/xtot
      frac(2)=xo2/xtot
      frac(1)=xne2/xtot
      eground=0.0
      amoles=0.0
      do i=1,6
      eground=eground+eion(i)*frac(i)  
      amoles=amoles+(1.+anum(i))*frac(i)
      enddo
      anume=amoles-1.
      gmass=0.
      do i=2,7
      gmass=gmass+amas(i)*frac(i-1)
      enddo

      return
      end
