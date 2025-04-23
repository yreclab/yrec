
c ********* Added by Grant Newsham 9/06
c
c Currently sets up just hydrogen, helium, carbon and oxygen for
c use in neutrino loss calculations
c
c Returns not only neutrino loss (snu)  but the derivatives of the loss
c with respect to the temperature and density (dsnudt and dsnudd.)
c


      subroutine neutrino(temp,den,x,y,zc,zo,snu,dsnudt,dsnudd)
      implicit real*8 ( a-h, o-z )
      integer          ionmax
      parameter        (ionmax=4)
      real*8 xmass(ionmax),ymass(ionmax),aion(ionmax),zion(ionmax)
c
c..set the mass fractions, z's and a's of the composition
c..hydrogen


      aion(1)  = 1.0d0
      zion(1)  = 1.0d0


c..helium


      aion(2)  = 4.0d0
      zion(2)  = 2.0d0


c..carbon 12


      aion(3)  = 12.0d0
      zion(3)  = 6.0d0


c..oxygen 16


      aion(4)  = 16.0d0
      zion(4)  = 8.0d0



         xmass(1) = x
         xmass(2) = y
         xmass(3) = zc
         xmass(4) = zo


       call nulosses(temp,den,snu,xmass,ymass,aion,zion,dsnudt,dsnudd)


        return
        end
