C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     RHOOFP01
C 
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
      function rhoofp01(x,ztab,t6,p,irad)
      use params, only : mx, mv, nr => nr01, nt => nt01
      
      IMPLICIT REAL*8 (A-H,O-Z)
      
      common/lreadco/itime
      common/aeos/  xz(mx,mv,nt,nr),  
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),m,mf,xa(mx)
      common/beos/ iri(10),index(10),nta(nr),zz(mx)
      common/eeos/esact,eos(mv)
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
      
      dimension nra(nt)
      data sigmacc/1.8914785e-3/
      
      data (nra(i),i=1,nt)/16*169,168,167,166,165,2*164,163,2*162,161,
     x   160,2*159,4*143,5*137,6*134,2*125,5*123,2*122,6*121,4*119,
     x   8*116,6*115,8*113,7*111,6*110,34*109,107,104,40*100,10*99,98,
     x   97,96,95,94,93,92/
      SAVE
      
      RAT=SIGMACC
      PR=0.0D0
C      IF(IRAD .EQ. 1) PR=4.D0/3.D0*RAT*T6**4   ! MB 
      PNR=P-PR

      IF (ITIME .NE. 12345678) THEN
      XDBG = 0.5D0
      T6DBG = 1.0D0
      RDBG = 0.001D0
      IDBG = 1
      CALL ESAC01 (XDBG,ZTAB,T6DBG,RDBG,IDBG,IRAD,*999)
      ENDIF

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
      
      pmax=xz(mlo,1,klo,nra(klo))*t6*rho(nra(klo)) +
     + IRAD*4.D0/3.D0*RAT*T6**4
      pmin=xz(mlo,1,klo,1)*t6*rho(1) +
     + IRAD*4.D0/3.D0*RAT*T6**4
      if((pnr .gt. 1.25D0*pmax) .or. (pnr .lt. pmin)) then
C      write (ISHORT,'(" The requested pressure-temperature not in ",
C     X       "table")')
C     stop
C      write (ISHORT,'("pnr, pmax,pmin=",3e14.4)') pnr,pmax,pmin
      GOTO 999
      endif
      
      rhog1=rho(nra(klo))*pnr/pmax
      CALL ESAC01 (X,ZTAB,T6,RHOG1,1,IRAD,*999)
      p1=eos(1)
        if(p1 .gt. pnr) then
          p2=p1
          rhog2=rhog1
          rhog1=0.2D0*rhog1
          if(rhog1 .lt. 1.D-14) rhog1=1.D-14
          CALL ESAC01 (X,ZTAB,T6,RHOG1,1,IRAD,*999)
          p1=eos(1)
        else
          rhog2=5D0*rhog1
C          if(rhog2 .gt. rho(klo)) rhog2=rho(klo)  ! Corrected below llp 8/19/08
          if(rhog2 .gt. rho(nra(klo))) rhog2=rho(nra(klo)) ! Had wrong pointer, see rhog1= ten lines up
          CALL ESAC01 (X,ZTAB,T6,RHOG2,1,IRAD,*999)
          p2=eos(1)
        endif
           
        icount=0
    1 continue
      icount=icount+1
      rhog3=rhog1+(rhog2-rhog1)*(pnr-p1)/(p2-p1)
      CALL ESAC01 (X,ZTAB,T6,RHOG3,1,IRAD,*999)
      p3=eos(1)
C      if (abs((p3-pnr)/pnr) .lt. 1.D-5) then
      IF (ABS((P3-PNR)/PNR) .LT. 0.5D-7) THEN
         rhoofp01=rhog3
      
         return
      endif
      if (p3 .gt. pnr) then
        rhog2=rhog3
        p2=p3
        if (icount .lt. 11) go to 1
C        write (ISHORT,'("No convergence after 10 tries")')
         GOTO 999
C        stop
      else
        rhog1=rhog3
        p1=p3
        if (icount .lt. 11) go to 1
C        write (*,'("No convergence after 10 tries")')
        GOTO 999
C        stop
      endif
  
  999 CONTINUE
      RHOOFP01=-999.0D0
C      WRITE(ISHORT,'("FAIL TO FIND RHO")')
      RETURN
      
      end
