c..
c..
c.. neutrino loss subroutine modified by G. Newsham
c.. from codes of N. Itoh & F. Timmes
c.. (9/06)
c..
c..
c.. Currently uses just the carbon coefficients for the bremsstrahlung
c.. neutrino losses (the differences for other elements is slight.)
c.. We also currently set the fermi temperature cuttoff at 0.01 Tfermi.
c.. This is applicable for helium but will need to be amended for
c.. carbon and oxygen white dwarfs and cores of AGB stars.
c..
c..




      subroutine nulosses(temp,den,snu,xmass,ymass,aion,zion,
     &                     dsnudt,dsnudd)


      implicit none
      save


c..tests the neutrino loss rate routine


c..ionmax  = number of isotopes in the network
c..xmass   = mass fractions
c..ymass   = molar fractions
c..aion    = number of nucleons
c..zion    = number of protons


      integer          ionmax
      parameter        (ionmax=4)
      double precision xmass(ionmax),ymass(ionmax),
     1                 aion(ionmax),zion(ionmax),temp,den,abar,zbar,
     2                 snu,dsnudt,dsnudd,dsnuda,dsnudz



c..get abar and zbar
      call azbar(xmass,aion,zion,ionmax,
     1           ymass,abar,zbar)



c..get the neutrino losses
      call sneut(temp,den,abar,zbar,
     1            snu,dsnudt,dsnudd,dsnuda,dsnudz)



      return
      end


      subroutine azbar(xmass,aion,zion,ionmax,
     1                 ymass,abar,zbar)
      implicit none
      save


c..input
c..mass fractions     = xmass(1:ionmax)
c..number of nucleons = aion(1:ionmax)
c..charge of nucleus  = zion(1:ionmax)
c..number of isotopes = ionmax


c..output:
c..molar abundances        = ymass(1:ionmax),
c..mean number of nucleons = abar
c..mean nucleon charge     = zbar



c..declare
      integer          i,ionmax
      double precision xmass(ionmax),aion(ionmax),zion(ionmax),
     1                 ymass(ionmax),abar,zbar,zbarxx,ytot1


      zbarxx  = 0.0d0
      ytot1   = 0.0d0
      do i=1,ionmax
       ymass(i) = xmass(i)/aion(i)
       ytot1    = ytot1 + ymass(i)
       zbarxx   = zbarxx + zion(i) * ymass(i)
      enddo
      abar   = 1.0d0/ytot1
      zbar   = zbarxx * abar
      return
      end
