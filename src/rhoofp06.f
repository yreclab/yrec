C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     RHOOFP06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

C       function rhoofp06(x,ztab,t6,p,irad)  ! KC 2025-05-31
      function rhoofp06(x,t6,p,irad)

      parameter (mx=5,mv=10,nr=169,nt=197)
      IMPLICIT REAL*8 (A-H,O-Z)
C 10/13/26 MHP via Claude
C code changed to remove COMMON/LREADCO/; the table is now read once by
C SETEOS06 from SETUPS, so this routine no longer needs the first-time
C switch or the fabricated ESAC06 call that used to force the read.
      common/aeos06/  xz(mx,mv,nt,nr),
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),midx,mf,xa(mx)
C 10/9/26 MHP via Claude
C code changed to rename AEOS06's M member to MIDX: M is such a
C universally-used name elsewhere in this codebase (e.g. shell count
C in calcad.f) that keeping it here was just asking for a future
C collision. M is genuinely used (as a composition/mixture-axis
C index) in esac06.f and readcoeos06.f; declared but never read or
C written by name in this file.
C KC 2025-05-30 reordered common block elements
C       common/beos06/ iri(10),index(10),nta(nr),zz(mx),nra(nt)
C 10/9/26 MHP via Claude
C code changed to merge COMMON/EEOS06/, COMMON/AAEOS06/, COMMON/BBEOS06/,
C and COMMON/BEOS06/ into COMMON/EOS06MISC/ (see esac06.f for the full
C rationale). AEOS06 (above) is left untouched.
      common/eos06misc/esact,eos(mv),q(4),h(4),xxh,
     .     l1,l2,l3,l4,k1,k2,k3,k4,ip,iq,
     .     zz(mx),iri(10),index(10),nta(nr),nra(nt)
      data sigmacc/1.8914785D-3/
c--------------------------------------------------------------------

      save
      rat=sigmacc
      pr=0D0
      if(irad .eq. 1) pr=4D0/3D0*rat*t6**4   ! Mb
      pnr=p-pr

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
C       call esac06 (x,ztab,t6,rhog1,1,0,*999)  ! KC 2025-05-31
      call esac06 (x,t6,rhog1,1,0,*999)
      p1=eos(1)
        if(p1 .gt. pnr) then
          p2=p1
          rhog2=rhog1
          rhog1=0.2D0*rhog1
          if(rhog1 .lt. 1.D-14) rhog1=1.D-14
C           call esac06 (x,ztab,t6,rhog1,1,0,*999)  ! KC 2025-05-31
          call esac06 (x,t6,rhog1,1,0,*999)
          p1=eos(1)
        else
          rhog2=5D0*rhog1
C          if(rhog2 .gt. rho(klo)) rhog2=rho(klo)  ! Corrected below   llp  8/19/08
          if(rhog2 .gt. rho(nra(klo))) rhog2=rho(nra(klo)) ! Had wrong pointer, see rhog1= ten lines up
C           call esac06 (x,ztab,t6,rhog2,1,0,*999)  ! KC 2025-05-31
          call esac06 (x,t6,rhog2,1,0,*999)
          p2=eos(1)
        endif

      icount=0
    1 continue
      icount=icount+1
      rhog3=rhog1+(rhog2-rhog1)*(pnr-p1)/(p2-p1)  ! KC 2025-05-31
C       call esac06 (x,ztab,t6,rhog3,1,0,*999)
      call esac06 (x,t6,rhog3,1,0,*999)
      p3=eos(1)
C Changed the comparison below to use the commented-out value 1.D-5
C found here to prevent array value eos(5) from growing without bound
C and crashing the program during certain model runs. - MR 2025-10-10
      if (abs((p3-pnr)/pnr) .lt. 1.D-5) then
C      IF (DABS((P3-PNR)/PNR) .LT. 0.5D-7) THEN
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

