C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     RADSUB01
C 
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
      subroutine radsub01 (t6,density,moles,tmass)
      
      parameter (mx=5,mv=10,nr=169,nt=191)
      IMPLICIT REAL*8 (A-H,O-Z)
      real*8 moles,k,molenak,Na
      common/eeos/esact,eos(mv)
      common/beos/ iri(10),index(10),nta(nr),zz(mx)

      data Na/6.0221367e+23/, k/1.380658e-16/, unitf/0.9648530/, 
     x unitfold/0.965296/, c/2.9979245e+10/, sigma/5.67051e-5/
     x , sigmac/1.8914785e-15/, sigmacc/1.8914785e-3/, aprop/83.14510/
      SAVE
      
cPhysical constants
c       Na=6.0221367e+23
c       k =1.380658e-16 !   erg/degree K
c       Na*k=6.0221367E+23*1.380658e-16 erg/degree K=8.314510E+7 erg/degree K
c           =8.314510e+7*11604.5 erg/eV=0.9648575E+12 erg/eV
c           Define unitf= Na*k/e+12=0.9648575
c           unitf=0.9648530  ! obtained with latest physical constants
c           unitfold=0.965296   ! old units- still used in the EOS code
c           In these units energy/density is in units of Mb-CC/gm
c           Pressure is in units of E+12 bars=Mb
c       sigma is the Stefan-Boltzmann constant
c       sigma=5.67051E-5 !   erg /(s*cm**2*K**4)
c       c=2.99792458E+10 !   cm/sec

c     rat=sigma/c    ! dyne/(cm**2*K**4)

c     rat=rat*1.e+24  !   Convert degrees K to units 10**6 K (T replaced with T6)
      rat=sigmacc

      molenak=moles*aprop  ! Mb-cc/unit T6
      pr=4D0/3D0*rat*t6**4   ! Mb 
      er=3D0*pr/density   ! Mb-cc/gm
      sr=4D0/3D0*er/t6   ! Mb-cc/(gm-unit T6)

c-----Calculate EOS without radiation correction
      pt=eos(iri(1))
      et=eos(iri(2))
      st=eos(iri(3))
      chir=eos(iri(5))*eos(iri(1))/pt
      chitt=(eos(iri(1))*eos(iri(6)))/pt
      cvtt=(eos(iri(4))*molenak/tmass)
      gam3pt_norad=pt*chitt/(cvtt*density*t6)
      gam1t_norad=chir+chitt*gam3pt_norad
      gam2pt_norad=gam1t_norad/gam3pt_norad
c---- End  no radiation calculation

c---- Calculate EOS with radiation calculation
      pt=eos(iri(1))+pr
      et=eos(iri(2))+er
      st=eos(iri(3))+sr
      chir=eos(iri(5))*eos(iri(1))/pt
      chitt=(eos(iri(1))*eos(iri(6))+4D0*pr)/pt
c     gam1t(jcs,i)=(p(jcs,i)*gam1(jcs,i)+4D0/3D0*pr)/pt(jcs,i)
c     gam2pt(jcs,i)=(gam2p(jcs,i)*p(jcs,i)+4D0*pr)/pt(jcs,i)
c     gam3pt(jcs,i)=gam1t(jcs,i)/gam2pt(jcs,i)
      cvtt=(eos(iri(4))*molenak/tmass+4D0*er/t6)
      gam3pt=pt*chitt/(cvtt*density*t6)                              ! DIRECT
      gam1t=chir+chitt*gam3pt !eq 16.16 Landau_Lifshitz (Stat. Mech) ! DIRECT
      gam2pt=gam1t/gam3pt                                            ! DIRECT
c-----End Eos calculations with radiation

c     normalize cvt to 3/2 when gas is ideal,non-degenerate,
c     fully-ionized, and has no radiation correction
c     cvt=(eos(5)*molenak/tmass+4.*er/t6)
c    x  /molenak
      eos(iri(1))=pt
      eos(iri(2))=et
      eos(iri(3))=st
      eos(iri(4))=cvtt
      eos(iri(5))=chir
      eos(iri(6))=chitt
c-----Add difference between EOS with and without radiation.  cvtt
c       calculation is not accurate enough to give accurate results using
c       eq. 16.16 Landau&Lifshitz (SEE line labeled DIRECT)
      eos(iri(7))=eos(iri(7))+gam1t-gam1t_norad
      eos(iri(8))=eos(iri(8))+gam2pt-gam2pt_norad
      eos(iri(9))=eos(iri(9))+gam3pt-gam3pt_norad
      return
      end
