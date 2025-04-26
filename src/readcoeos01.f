C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     READCOEOS01
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      subroutine readcoeos01
      use params, only : mx, mv, nr => nr01, nt => nt01
      use settings, only : ISHORT  ! /LUOUT/
      use settings, only : IOPALE, FOPALE01  ! /OPALEOS/

c..... The purpose of this subroutine is to read the data tables

      IMPLICIT REAL*8 (A-H,O-Z)

      real*8 moles
      character*1 blank
      common/aaeos/ q(4),h(4),xxh
      common/aeos/  xz(mx,mv,nt,nr),
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),m,mf,xa(mx)
      common/beos/ iri(10),index(10),nta(nr),zz(mx)
      common/eeos/esact,eos(mv)
      common/eeeos/ epl(mx,nt,nr),xx(mx)
c KC 2025-04-22 Downgraded this to arrays as it was only used in readcoeos01.f.
c      common/eeeeos/moles(mx),xin(mx),tmass(mx),icycuse(mx,nr),
c     x    rhogr(mx,nr),frac(mx,6),alogr(nr,nt)
      dimension moles(mx),xin(mx),tmass(mx),icycuse(mx,nr),
     x    rhogr(mx,nr),frac(mx,6),alogr(nr,nt)
C mhp 7/2003
      COMMON/RMPOPEOS01/RMX(NT),KRA(NT),KT
      DATA (KRA(I),I=1,NT)/16*169,168,167,166,165,2*164,163,2*162,
     X     161,160,2*159,4*143,5*137,6*134,2*125,5*123,2*122,6*121,
     X     4*119,8*116,9*115,5*113,7*111,6*110,34*109,107,104,
     X     40*100,10*99,98,97,96,95,94,93,92/
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
        itimeco=12345678
        endif

      close (2)
c..... read  tables
       open(IOPALE, FILE=FOPALE01,STATUS='OLD')


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
         write (ISHORT,'(" Data file incorrect: numtot,jcs= ",2i5)')
     x     numtot,jcs
         stop
      endif
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
      if (icycuse(m,jcs) .lt. nta(jcs)) then
         write (ISHORT,'("problem with data files: X=",f6.4,
     X         " density=",e14.4)') xin(m), rhogr(m,jcs)
         stop
      endif
      do  i=1,icycuse(m,jcs)
      if (i .gt. nta(jcs)) then
         read (IOPALE,'(a)') blank
         go to 4
      endif
      read (IOPALE,'(f9.5,1x,f6.2,3e13.5,6f8.4)')
     x t6list(jcs,i),alogr(jcs,i),(xz(m,index(iv),i,jcs),iv=1,9)
    4 continue
      enddo
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
    2 continue
      read(IOPALE,'(a)') blank
    3 continue

      do i=1,nt
         if(t6list(1,i) .eq. 0.0D0) then
            write(ISHORT,'("READCOEOS01: Error:",i4,
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
C  MHP 7/2003 ADDED RAMP BETWEEN OPAL AND OTHER EOS
C  NEED EDGE OF TABLE AT HIGH RHO, FIXED T.
      KT = 1
      DO I = 1, NT
         RMX(I) = RHO(KRA(I))
      END DO

      return
      end
