C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     READCOEOS06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      subroutine readcoeos06
      use params, only : mx, mv, nr => nr06, nt => nt06
      use settings, only : ISHORT  ! /LUOUT/

c..... The purpose of this subroutine is to read the OPAL 2006 EOS data tables

      IMPLICIT REAL*8 (A-H,O-Z)
      real*8 moles
      LOGICAL*4 LOPALE, lopale01,lopale06,LNumDeriv
      CHARACTER*256 FOPALE,fopale01,fopale06
      character*1 blank
      common/aaeos06/ q(4),h(4),xxh
      common/aeos06/  xz(mx,mv,nt,nr),
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),m,mf,xa(mx)
      common/beos06/ iri(10),index(10),nta(nr),zz(mx),nra(nt)
      common/eeos06/esact,eos(mv)
      common/eeeos06/ epl(mx,nt,nr),xx(mx)
C Amu_M and alogNe were incorrectly dimensoned Amu_M(mx,nr) and alogNe(mx,nr).
C the required dimensions are Amu_M(nr,nt) alogNe(nr,nt), which is much larger.
C Something was being overwritten.         llp 8/19/08
C     x    amu_M(mx,nr),alogNe(mx,nr),rhogr(mx,nr),frac(mx,6),
c KC 2025-04-22 Downgraded this to arrays as it was only used in readcoeos06.f.
c      common/eeeeos06/moles(mx),xin(mx),tmass(mx),icycuse(mx,nr),
c     x    amu_M(nr,nt),alogNe(nr,nt),rhogr(mx,nr),frac(mx,6),
c     x    alogr(nr,nt)
      dimension moles(mx),xin(mx),tmass(mx),icycuse(mx,nr),
     x    amu_M(nr,nt),alogNe(nr,nt),rhogr(mx,nr),frac(mx,6),
     x    alogr(nr,nt)
      COMMON/OPALEOS/FOPALE,LOPALE,IOPALE,fopale01,lopale01,fopale06,
     x     lopale06,LNumDeriv

      save
      blank=' '


        if (itimeco .ne. 12345678) then
        do i=1,mx
          do j=1,mv
            do k=1,nt
              do l=1,nr
                xz(i,j,k,l)=1.D+35
              enddo
            enddo
          enddo
        enddo
        do j = 1,mv
        eos(j) = 1D0
      enddo
        itimeco=12345678
        endif

      close (2)
c..... read  tables
       open(IOPALE, FILE=FOPALE06,STATUS='OLD')


      do 3 m=1,mx
      read (IOPALE,'(3x,f6.4,3x,f12.9,11x,f10.7,17x,f10.7)')
     x  xin(m),zz(m),moles(m),tmass(m)
      read (IOPALE,'(21x,e14.7,4x,e14.7,3x,e11.4,3x,e11.4,3x,e11.4,
     x 4x,e11.4)') (frac(m,i),i=1,6)
      read (IOPALE,'(a)') blank
      do 2 jcs=1,nr
      read (IOPALE,'(2i5,2f12.7,17x,e15.7)') numtot,icycuse(m,jcs)
     x  ,dum,dum,rhogr(m,jcs)
      if(numtot .ne. jcs) then
         write (ISHORT,'(" OEOS06 Data file incorrect: numtot,jcs= "
     x   ,  2i5)') numtot,jcs
         stop
      endif
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
      if (icycuse(m,jcs) .lt. nta(jcs)) then
         write (ISHORT,'("Problem with OEOS96 data files: X=",f6.4,
     X         " density=",e14.4)') xin(m), rhogr(m,jcs)
         stop
      endif
      do  i=1,icycuse(m,jcs)
      if (i .gt. nta(jcs)) then
         read (IOPALE,'(a)') blank
         go to 4
      endif
      read (IOPALE,'(f11.6,1x,f6.4,e11.4,2e13.6,2e11.3,5f10.6)')
     x t6list(jcs,i),amu_M(jcs,i),alogNe(jcs,j),
     x (xz(m,index(iv),i,jcs),iv=1,9)
    4 continue
      enddo
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
    2 continue
      read(IOPALE,'(a)') blank
    3 continue

      do i=1,nt
         if(t6list(1,i) .eq. 0D0) then
            write(ISHORT,'("READCOEOS06: Error:",i4,
     $           "-th T6 value is zero")') i
            stop
         endif
         t6a(i)=t6list(1,i)
      enddo
      do 12 i=2,nt
   12 dfs(i)=1D0/(t6a(i)-t6a(i-1))
      rho(1)=rhogr(1,1)
      do 13 i=2,nr
      rho(i)=rhogr(1,i)
   13 dfsr(i)=1D0/(rho(i)-rho(i-1))
      do i=2,mx
      dfsx(i)=1D0/(xx(i)-xx(i-1))
      enddo
      CLOSE (IOPALE)

      return
      end
