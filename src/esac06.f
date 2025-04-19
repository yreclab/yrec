C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     ESAC06
C 
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
      subroutine esac06 (xh,ztab,t6,r,iorder,irad,*)
      use params, only : mx, mv, nr => nr06, nt => nt06

c..... The purpose of this subroutine is to interpolate 
c      the equation of state and its derivatives in X, T6, density
c        izi=0 recalulate table indices to use; =1 keep previous

c        xh=hydrogen mass fraction
c        ztab is metal fraction of the EOS5_data tables you are using.
c           included only for purpose of preventing mismatch
c        t6=T6=temperature in millions of degrees kelvin
c        r=rho=Rho=density(g/cm**3)
c..... to use esac06 insert common/eeos06/ esact,eos(10) in the calling routine.
c      This common contains the interpolated EOS values for the EOS
c
c..... eos(i) are obtained from a quadradic interpolation at
c      fixed T6 at three values of Rho; followed by quadratic
c      interpolation along T6. Results smoothed by mixing
c      overlapping quadratics.
c         definitions:
c     
c            T6 is the temperature in units of 10**6 K
c 
c            rho is the density in grams/cc
c            R=Rho/T6**3

c            eos(1) is the pressure in megabars (10**12dyne/cm**2)
c            eos(2) is energy in 10**12 ergs/gm. Zero is zero T6
c            eos(3) is the entropy in units of energy/T6
c            eos(4) is dE/dRHO at constant T6
c            eos(5) is the specific heat, dE/dT6 at constant V.
c            eos(6) is dlogP/dlogRho at constant T6. 
c                   Cox and Guil1 eq 9.82
c            eos(7) is dlogP/dlogT6 at conxtant Rho.
c                   Cox and Guil1 eq 9.81
c            eos(8) is gamma1. Eqs. 9.88 Cox and Guili.
c            eos(9) is gamma2/(gaamma2-1). Eqs. 9.88 Cox and Guili

c            iorder sets maximum index for eos(i);i.e., iorder=1
c                   gives just the pressure
c
c            irad  if =0 no radiation correction; if =1 adds radiation

c            index(i),i=1,10  sets order in which the equation of state
c            variables are stored in eos(i).  Above order corresponds
c            to block data statement:
c                 data (index(i),i=1,10)/1,2,3,4,5,6,7,8,9,10/. 
c            If you, for example, only want to return gamma1: set iorder=1 
c            and set: data (index(i),i=1,10)/8,2,3,4,5,6,7,1,9,10/
c
c
      IMPLICIT REAL*8 (A-H,O-Z)
      real*8 moles
      integer w

c***************************************************************************
c    parameters:
c	mx is the number of x's in the 2001 Opal EOS table
c	mv is the maximum number of thermmodynamic variables in the 2001
c		Opal EOS table.  Note that the input tables only contain 9.
c	nr is the number of densities in the table.
c	nt is the number of t6's associated with an x/density.  See
c		below for more details about the table.
c***************************************************************************

      character blank*1
      Character*15 ID
      common/lreadco/itime

c***************************************************************************
c    common lreadco definitions:
c	itime is the first time switch.  It is initially true. After the
c	first pass it is set to false.  When it is true, the tables are
c	read and associated variables are initialized.
c***************************************************************************


      common/eeeos06/ epl(mx,nt,nr),xx(mx)

c***************************************************************************
c    common eeeos06 definitions
c	xx is an auxilliary array containing the same values of x as array xa.      
c***************************************************************************

      common/aaeos06/ q(4),h(4),xxh
      common/aeos06/  xz(mx,mv,nt,nr),  
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),m,mf,xa(mx)

c***************************************************************************
c
c  common aeos06 definitions:
c
c    xz is the array of thermodynamic variables, as a funtion of four arguments:
c	arg 1: 	identifies the value of x in the corresponding array xa, ie, 
c		xz(1,*,*,*) refers to values at x=xa(1)=0.00, xz(2,*,*,*) 
c		refers to values at x=xa(2)=0.20, etc.
c	arg 2:	identifies which thermodynamic variable.  xz(*,1,*,*) refers to
c		the thermodynamic variable specified for eos(1) - by default the 
c		pressure, xz(*,2,*,*) refers to the thermodynamic variable
c		specified for eos(2), etc.
c	arg 3:	identifies the value of t6 in the corresponding array t6a 
c		(and t6list).  e.g., xz(*,*,1,*) refers to values at 
c		t6=t6a(1)=100, xz(*,*,2,*) refers to values at t6=t6a(2), etc.
c	arg 4:	identifies the vaue of d, the density, in the corresponding
c		array rho. eg, xz(*,*,*,1) refers to values at d=rho(1)=10**-14,
c		xz(*,*,*,2) refers to values at d-rho(2), etc.
c	Therefore, in the default eos case, xz(1,1,1,1) would be the pressure
c	at x=0.00, t6=100, density=10**-14.
c
c    t6list is the array of t6 (temperature in units of 10**6 degrees Kelvin)
c	The arguments match the first and fourth arguments in array xz above,
c	with the first argument being associated with a temperature and the
c	second with a density.
c
c	In the first column, associated with the density of 10**-14,
c	temperatures range from t6=100 in t6list(1,1) to t6=.002 in
c	t6list(1,191).  In the last column, associated with a density
c	of 10**7, temperatures range from t6=100 in t6list(169,1) to 
c	t6=22.5 in t6list(169,16).  About 10% of the table in vicinity 
c	of the lower right hand corner is empty.  The table is homogeneous
c	in t6, in that for each row in the table, all non-empty elements
c	have the same value of t6.  In row 1, all t6's are 100. In row
c	191, all t6's in the non-empty part of the table are .002, etc.
c
c    rho is to array of density in units of grams per cc.  This array has
c	one argument, matching the fourth argument in array xz.  The
c	first density in the table is for density 10**-14, and the last
c	(169th) is for density 10**7.
c
c    t6a is an auxiliary array of temperatures.  It has the full range of
c	temmperatures, from t6a(1)=100 to t6a(191)=.002.  (It exactly
c	matches the first column of t6list)
c
c    xa is the array of the tabulated values of x, eg, xa(1)=0.00, xa(2)=0.20, 
c	through xa(5)=0.80.
c
c    dsfx is the first of three auxilliary arrays used in interpolation.
c	dfsx(2)=1/(xa(2)-xa(1)), dfsx(3)=1/(xa(3)-x1(2), ...,
c	dsfx(5)=1/(xa(5)-xa(4)).
c
c    dfs is the second auxilliary array used in interpolation.
c	dfs(2)=1/(t6a(2)-t6a(1), ..., dfs(191)=1/(t6a(191)-t6a(190)).
c
c    dfsr is the third auxilliary array used in interpolaltion.
c	dfsr(2)=1/(rho(2)-rho(1)), ..., dfsr(169)=1/(rho(169)-rho(168)).
c
c***************************************************************************

      common/beos06/ iri(10),index(10),nta(nr),zz(mx),nra(nt)

c***************************************************************************
c
c    common beos96 definitions    
c
c    array index defines the order in which thermodynamic variables are 
c	returned in array eos and stored in array xz.  By default, 
c	index(1)=1, index(2)=2 ,  ..., index(10)=10.  For our purposes,
c	I see no reason to change index. 
c
c    array iri provides the inverse mapping to array index.
c	index(iri(i))=iri(index(1)=i, for i = 1, 2 ..., 10.
c	in the default case, iri(1)=1, iri(2)=2, ..., iri(10)=10.
c
c    array nta provides the index in array t6a of the lower limits of 
c	temperature in the xz array as a function of density.  For 
c	example, nta(1)=191, and t6a(nta(1))=t6a(191)=.002, the 
c	lowest temperature associated with the first density, 
c	rho(1)=10**-14.  At the highest density, in column 169, 
c	rho(169)=10**7. The associated nta(169)=16, identifies 
c	the lowest temperature for this density, and 
c	t6a(nta(169))=t6a(16)=22.5.
c
c    array zz contains the values of z read in from the 2001 Opal EOS table.
c	It can be used for checking purposes.
c
c***************************************************************************

      common/bbeos06/l1,l2,l3,l4,k1,k2,k3,k4,ip,iq
      common/eeos06/esact,eos(mv)

c***************************************************************************
c    common eeos06 definitions:
c
c    array eos is an output array containing the values of the thermodynamic
c	variables obtained by interpolation.  These interplated values
c	are for the specified x, t6 and density.
c***************************************************************************

      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
            dimension frac(7)
      data aprop/83.14511/
      data ID/"OPALEOS/ESAC06:"/
      data (xa(i),i=1,mx)/0.0,0.2,0.4,0.6,0.8/
      data (index(i),i=1,10)/1,2,3,4,5,6,7,8,9,10/
      data (nta(i),i=1,nr)/87*197,7*191,190,2*189,185,179,170,2*149,
     x  133,125,123,122,120,115,113,107,102,2*80,72,68,66,64,62,56,54,
     x  52,51,2*50,49,47,2*45,43,42,28*40,39,37,36,35,34,32,31,30,
     x  29,27,26/
      data (nra(i),i=1,nt)/ 26*169, 168, 2*167, 166, 165, 164,
     x   2*163, 162, 161, 160, 2*159, 158, 2*130, 129, 2*128,
     x   2*126, 2*125, 124, 122, 121, 2*120, 2*119, 6*118, 2*117,
     x   2*116, 2*115, 4*114, 8*113, 22*111, 5*110, 6*109, 2*108,
     x   5*107, 2*106, 105, 2*104, 8*103, 16*102, 21*100, 9* 99,
     x   6* 98, 4* 97, 95, 94, 6* 87/

      save

      blank=' '
      if (iorder .gt. 9 ) then
         write (ISHORT,'(A, " iorder cannot exceed 9")') ID
      endif
      if ((irad .ne. 0) .and. (irad .ne. 1)) then
         write (ISHORT,'(A, " Irad must be 0 or 1")') ID
         stop
      endif
      xxi=xh
      ri=r
c
      slt=t6
      slr=r
c
      if(itime .ne. 12345678) then
        itime=12345678
        do i=1,10
          do j=1,10
            if  (index(i) .eq. j) iri(i)=j
          enddo
        enddo
        do  i=1,mx
          xx(i)=xa(i)
        enddo
c
c..... read the data files
        call readcoeos06
        z=zz(1)
c        if (ztab .ne. z) then
c        write (ISHORT,'(A, "requested z=",f10.6," EOS5_data is for z=",
c     x             f10.6)')
c     x    ID,ztab,z      
c        stop
c        endif

        if(z+xh-1.D-6 .gt. 1 ) go to 61
      endif
c
c
c..... Determine T6,rho grid points to use in the
c      interpolation.
      if((slt .gt. t6a(1)).or.(slt .lt. t6a(nt))) go to 62
      if((slr .lt. rho(1)).or.(slr .gt. rho(nr))) go to 62
c
c
c
c     if (izi .eq. 0) then  ! freeze table indices if not 0
        ilo=2
        ihi=mx
    8   if(ihi-ilo .gt. 1) then
          imd=(ihi+ilo)/2
            if(xh .le. xa(imd)+1.D-7) then
              ihi=imd
            else
              ilo=imd
            endif
          go to 8
        endif
        i=ihi
        mf=i-2
        mg=i-1
        mh=i
        mi=i+1
        mf2=mi
        if (xh .lt. 1.D-6) then
        mf=1
        mg=1
        mh=1
        mi=2
        mf2=1
        endif
        if((xh .le. xa(2)+1.D-7) .or. (xh .ge. xa(mx-2)-1.D-7)) mf2=mh
c
        ilo=2
        ihi=nr
   12     if(ihi-ilo .gt. 1) then
          imd=(ihi+ilo)/2
           if (slr .eq. rho(imd)) then
           ihi=imd
           go to 13
           endif
            if(slr .le. rho(imd)) then
              ihi=imd
            else
              ilo=imd
            endif
          go to 12
          endif
   13     i=ihi
        l1=i-2
        l2=i-1
        l3=i
        l4=l3+1
        iqu=3
        if(l4 .gt. nr) iqu=2
c
        ilo=nt
        ihi=2
   11     if(ilo-ihi .gt. 1) then
          imd=(ihi+ilo)/2
           if (t6 .eq. t6list(1,imd)) then
           ilo=imd
           go to 14
           endif
            if(t6 .le. t6list(1,imd)) then
              ihi=imd
            else
              ilo=imd
            endif
          go to 11
          endif
   14     i=ilo
        k1=i-2
        k2=i-1
        k3=i
        k4=k3+1
        ipu=3
        if (k4 .gt. nt) ipu=2
      if (k3 .eq. 0) then
      write (ISHORT,'(A, " ihi,ilo,imd",3i5)') ID,ihi,ilo,imd
      endif
c     endif

c     check to determine if interpolation indices fall within
c     table boundaries.  choose largest allowed size.
      sum1=0.0D0
      sum2=0.0D0
      sum23=0.0D0
      sum33=0.0D0
      do m=mf,mf2
        do ir=l1,l1+1
          do it=k1,k1+1
            sum1=sum1+xz(m,1,it,ir)
          enddo
        enddo
        do ir=l1,l1+2
          do it=k1,k1+2
            sum2=sum2+xz(m,1,it,ir)
          enddo
        enddo
        if (ipu .eq. 3) then
          do ir=l1,l1+2
            do it=k1,k1+ipu
              sum23=sum23+xz(m,1,it,ir)
            enddo
          enddo
        else
          sum23=2.D+30
        endif
        if (iqu .eq. 3) then
          do ir=l1,l1+3
            do it=k1,k1+ipu
              sum33=sum33+xz(m,1,it,ir)
            enddo
          enddo
        else
          sum33=2.D+30
        endif
      enddo
      iq=2
      ip=2
      if (sum2 .gt. 1.D+30) then
        if (sum1 .lt. 1.D+25 ) then
          k1=k3-3
          k2=k1+1
          k3=k2+1
          l1=l3-3
          l2=l1+1
          l3=l2+1
          go to 15
            else
          go to 65
        endif
      endif
      if (sum23 .lt. 1.D+30) ip=3
      if (sum33 .lt. 1.D+30) iq=3

      if(t6 .ge. t6list(1,2)+1.D-7) ip=2
      if(slr .le. rho(2)+1.D-15) iq=2

      if((l3 .eq. nr) .or. (k3 .eq. nt)) then
         iq=2
         ip=2
      endif

   15 continue
      do 124 iv=1,iorder
      do 123 m=mf,mf2
 
      is=0
c__________
      do ir=l1,l1+iq
        do it=k1,k1+ip
        epl(m,it,ir)=xz(m,iv,it,ir)
        is=1
        enddo
      enddo
  123 continue
      if((zz(mg) .ne. zz(mf)) .or. (zz(mh) .ne. zz(mf))) then
        write(ISHORT,'(A,"Z does not match Z in OEOS06 files you are"
     x ," using")') ID
        stop
      endif
      if(z .ne. zz(mf)) go to 66
      is=0
      iw=1
      do 45 ir=l1,l1+iq
        do it=k1,k1+ip
          if (mf2 .eq. 1) then
          esk(it,ir)=epl(mf,it,ir)
          go to 46
          endif
          esk(it,ir)=quadeos06(is,iw,xh,epl(mf,it,ir),epl(mg,it,ir)
     x    ,epl(mh,it,ir),xx(mf),xx(mg),xx(mh))
          if(esk(it,ir) .gt. 1.D+20) then
          write(ISHORT,'(A," problem it,ir,l3,k3,iq,ip=", 6i5)') ID,
     x    it,ir,l3,k3,iq,ip
          write(ISHORT,'(3e12.4)') (epl(ms,it,ir),ms=mf,mf+2)
          endif
          is=1
   46     continue
        enddo
   45 continue

      if (mi .eq. mf2) then  ! interpolate between quadratics
      is=0
      iw=1
       dixr=(xx(mh)-xh)*dfsx(mh)
      do 47 ir=l1,l1+iq
        do it=k1,k1+ip
          esk2(it,ir)=quadeos06(is,iw,xh,epl(mg,it,ir),epl(mh,it,ir)
     x    ,epl(mi,it,ir),xx(mg),xx(mh),xx(mi))
          if(esk(it,ir) .gt. 1.D+20) then
          write(ISHORT,'(A," problem it,ir,l3,k3,iq,ip=", 6i5)') ID,
     x    it,ir,l3,k3,iq,ip
          write(ISHORT,'(3e12.4)')  (epl(ms,it,ir),ms=mg,mg+2)
          endif
          esk(it,ir)=esk(it,ir)*dixr+esk2(it,ir)*(1D0-dixr)
          is=1
        enddo
   47 continue
   

      endif

      is=0
c
c..... completed X interpolation. Now interpolate T6 and rho on a
c      4x4 grid. (t6a(i),i=i1,i1+3),rho(j),j=j1,j1+3)).Procedure
c      mixes overlapping quadratics to obtain smoothed derivatives.
c
c
      call t6rinteos06(slr,slt)
      eos(iv)=esact
  124 continue
      p0=t6*r
      eos(iri(1))=eos(iri(1))*p0   ! interpolated in p/po
      eos(iri(2))=eos(iri(2))*t6   ! interpolated in E/T6
      tmass=gmass06(xh,z,moles,eground,fracz,frac)
      if (irad .eq. 1) then
      call radsub06(irad,t6,r,moles,tmass)
      else
      eos(iri(5))=eos(iri(5))*moles*aprop/tmass
      endif
      return

   61 write(ISHORT,*)ID,"Mass fractions exceed unity (61)"
      WRITE(ISHORT,*)'Z, XH', Z, XH
      stop
   62 write(ISHORT,*) ID," T6/LogR outside of table range (62)"
      write(ISHORT,*) "slt, t6a(1),t6a(nt):", slt, t6a(1),t6a(nt)
      write(ISHORT,*) "slr, rho(1), rho(nr):", slr, rho(1), rho(nr)
      RETURN 1
   65 write(ISHORT,*) ID,"T6/log rho in empty region of table (65)"
      write(ISHORT,'("xh,t6,r=", 3e12.4)') xh,t6,r
      RETURN 1
   66 write(ISHORT,*)ID," Z does not match Z in EOSdata* files you ",
     . "are using (66)"
      write(ISHORT,'("mf,zz(mf)=",i5,e12.4)') mf,zz(mf)
      write(ISHORT,'("  iq,ip,k3,l3,xh,t6,r,z= ",4i5,4e12.4)')
     x ip,iq,k3,l3,xh,t6,r,z
      stop

      end

