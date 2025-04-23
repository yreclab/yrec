C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     RHOOFP06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      function rhoofp06(x,ztab,t6,p,irad)
      use params, only : mx, mv, nr => nr06, nt => nt06

      IMPLICIT REAL*8 (A-H,O-Z)
      common/lreadco/itime
      common/aeos06/  xz(mx,mv,nt,nr),
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),m,mf,xa(mx)
      common/beos06/ iri(10),index(10),nta(nr),zz(mx),nra(nt)
      common/eeos06/esact,eos(mv)
      data sigmacc/1.8914785e-3/
c--------------------------------------------------------------------

      save
      rat=sigmacc
      pr=0D0
      if(irad .eq. 1) pr=4D0/3D0*rat*t6**4   ! Mb
      pnr=p-pr

      if (itime .ne. 12345678) then
      XDBG = 0.5D0
      T6DBG = 1.0D0
      RDBG = 0.001D0
      IDBG = 1
      CALL ESAC06 (XDBG,ZTAB,T6DBG,RDBG,IDBG,IRAD,*999)
      endif

        ilo=2
        ihi=mx
    8   if(ihi-ilo .gt. 1) then
          imd=(ihi+ilo)/2
            if(x .le. xa(imd)+1.D-7) then
              ihi=imd
            else
              ilo=imd
            endif
          go to 8
        endif
        mlo=ilo

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
   14     klo=ilo

      pmax=xz(mlo,1,klo,nra(klo))*t6*rho(nra(klo))
      pmin=xz(mlo,1,klo,1)*t6*rho(1)
      if((pnr .gt. 1.25D0*pmax) .or. (pnr .lt. pmin)) then
c      write (ISHORT,'(" The requested pressure-temperature not in",
c     x   " the OPAL 2006 EOS table")')
c     stop
c      write (ISHORT,'("pnr, pmax,pmin=",3e14.4)') pnr,pmax,pmin
        goto 999     !RHOOFP06 error exit
      endif

      rhog1=rho(nra(klo))*pnr/pmax
      call esac06 (x,ztab,t6,rhog1,1,0,*999)
      p1=eos(1)
        if(p1 .gt. pnr) then
          p2=p1
          rhog2=rhog1
          rhog1=0.2D0*rhog1
          if(rhog1 .lt. 1.D-14) rhog1=1.D-14
          call esac06 (x,ztab,t6,rhog1,1,0,*999)
          p1=eos(1)
        else
          rhog2=5D0*rhog1
C          if(rhog2 .gt. rho(klo)) rhog2=rho(klo)  ! Corrected below   llp  8/19/08
          if(rhog2 .gt. rho(nra(klo))) rhog2=rho(nra(klo)) ! Had wrong pointer, see rhog1= ten lines up
          call esac06 (x,ztab,t6,rhog2,1,0,*999)
          p2=eos(1)
        endif

      icount=0
    1 continue
      icount=icount+1
      rhog3=rhog1+(rhog2-rhog1)*(pnr-p1)/(p2-p1)
      call esac06 (x,ztab,t6,rhog3,1,0,*999)
      p3=eos(1)
C      if (abs((p3-pnr)/pnr) .lt. 1.D-5) then
      IF (DABS((P3-PNR)/PNR) .LT. 0.5D-7) THEN
        rhoofp06=rhog3
        return
      endif
      if (p3 .gt. pnr) then
        rhog2=rhog3
        p2=p3
        if (icount .lt. 11) go to 1
c        write (ISHORT,'("Rhoofp06: No convergence after 10 tries")')
        goto 999     !RHOOFP06 error exit
c        stop
      else
        rhog1=rhog3
        p1=p3
        if (icount .lt. 11) go to 1
c        write (ISHORT,'("RHOOFP06: No convergence after 10 tries")')
        goto 999   ! RHOOFP06 error exit
c        stop
      endif

  999 CONTINUE
      RHOOFP06=-999.0D0
C      WRITE(ISHORT,'("RHOOFP06: FAILED TO FIND RHO")')
      RETURN


      end

