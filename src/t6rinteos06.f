C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     T6RINTEOS01
C 
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
      subroutine t6rinteos06(slr,slt)
      use params, only : mx, mv, nr => nr06, nt => nt06
      use parmin90, only : ISHORT  ! COMMON/LUOUT/

c     The purpose of this OPAL 2006 EOS subroutine is to interpolate in 
c     T6 and rho

      IMPLICIT REAL*8 (A-H,O-Z)
      common/eeeos06/ epl(mx,nt,nr),xx(mx)
      common/aaeos06/ q(4),h(4),xxh
      common/aeos06/  xz(mx,mv,nt,nr),  
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),m,mf,xa(mx)
      common/bbeos06/l1,l2,l3,l4,k1,k2,k3,k4,ip,iq
      common/eeos06/esact,eos(mv) 
c
      save
      iu=0
      is=0

      do kx=k1,k1+ip
          iw=1
        iu=iu+1
        h(iu)=quadeos06(is,iw,slr,esk(kx,l1),esk(kx,l2),esk(kx,l3),
     x  rho(l1),rho(l2),rho(l3))
          if(iq. eq. 3) then
            iw=2
            q(iu)=quadeos06(is,iw,slr,esk(kx,l2),esk(kx,l3),
     x      esk(kx,l4),rho(l2),rho(l3),rho(l4))
          endif
        is=1
      enddo
c
      is=0
      iw=1
c..... eos(i) in lower-right 3x3(i=i1,i1+2 j=j1,j1+2)
      esact=quadeos06(is,iw,slt,h(1),h(2),h(3),t6a(k1),t6a(k2),
     x     t6a(k3))
        if (iq. eq. 3) then
c.....    eos(i) upper-right 3x3(i=i1+1,i1+3 j=j1,j1+2)
          esactq=quadeos06(is,iw,slt,q(1),q(2),q(3),t6a(k1),
     x           t6a(k2),t6a(k3))
        endif
        if(ip .eq. 3) then
c.....    eos(i) in lower-left 3x3.
          esact2=quadeos06(is,iw,slt,h(2),h(3),h(4),t6a(k2),t6a(k3),
     x           t6a(k4))
c.....    eos(i) smoothed in left 3x4
          dix=(t6a(k3)-slt)*dfs(k3)
          esact=esact*dix+esact2*(1D0-dix)
c       endif   ! moved to loc a
        if(iq .eq. 3) then
 
c.....     eos(i) in upper-right 3x3.
          esactq2=quadeos06(is,iw,slt,q(2),q(3),q(4),t6a(k2),t6a(k3),
     x            t6a(k4))
          esactq=esactq*dix+esactq2*(1D0-dix)
        endif
        endif  ! loc a
c
        if(iq .eq. 3) then
          dix2=(rho(l3)-slr)*dfsr(l3)
            if(ip .eq. 3) then
c.....        eos(i) smoothed in both log(T6) and log(R)
              esact=esact*dix2+esactq*(1-dix2)
            endif
        endif
        if (esact .gt. 1.D+15) then
          write(ISHORT,'("T6RINTEOS06: Interpolation indices out",
     x              " of range;please report conditions.")') 
          stop
        endif

      return
      end

