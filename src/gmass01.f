C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     GMASS01
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      function gmass01(x,z,amoles,eground,fracz,frac)

      IMPLICIT REAL*8 (A-H,O-Z)
      dimension anum(6),frac(7), amas(7),eion(7)
      data (eion(i),i=1,6)/-3394.873554D0,-1974.86545D0,-1433.92718D0,
     x  -993.326315D0,-76.1959403D0,-15.29409D0/
      data (anum(i),i=1,6)/10.,8.,7.,6.,2.,1./
      SAVE

      xc=0.247137766D0
      xn=.0620782D0
      xo=.52837118D0
      xne=.1624188D0
      amas(7)=1.0079D0
      amas(6)=4.0026D0
      amas(5)=12.011D0
      amas(4)=14.0067D0
      amas(3)=15.9994D0
      amas(2)=20.179D0
      amas(1)=0.00054858D0
      fracz=z/(xc*amas(5)+xn*amas(4)+xo*amas(3)+xne*amas(2))
      xc2=fracz*xc
      xn2=fracz*xn
      xo2=fracz*xo
      xne2=fracz*xne
      xh=x/amas(7)
      xhe=(1D0-x -z)/amas(6)
      xtot=xh+xhe+xc2+xn2+xo2+xne2
      frac(6)=xh/xtot
      frac(5)=xhe/xtot
      frac(4)=xc2/xtot
      frac(3)=xn2/xtot
      frac(2)=xo2/xtot
      frac(1)=xne2/xtot
      eground=0.0D0
      amoles=0.0D0
      do i=1,6
      eground=eground+eion(i)*frac(i)
      amoles=amoles+(1D0+anum(i))*frac(i)
      enddo
      anume=amoles-1D0
      gmass01=0D0
      do i=2,7
      gmass01=gmass01+amas(i)*frac(i-1)
      enddo

      return
      end
