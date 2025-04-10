ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Function:               FFETA
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c This function returns ffeta calculated from a rational polynomial
c approximation.
c
      function ffeta(eta)
c     by using one of 6 polynomials i 3/2(eta)
c     is computed
      if (eta .gt. 1.e+05) go to 6000
      if (eta .gt. 10.0) go to 5000
      if (eta .gt. 3.0) go to 4000
      if (eta .gt. -2.0) go to 2000
      eeta=exp(eta)
      ffeta=((((((eeta/129.6418147-.0113402303)*eeta+.0178885437)*
     1  eeta-.03125)*eeta+.0641500298)*eeta-.176776695)*eeta+1.0)*
     2  eeta*(.75*1.77245385)
      return
 2000 ffeta=.1758009896+1.5*(((((( -.0001066018*eta-
     1  .00047150892)*eta+.00469520575)*eta+.05636582666)*
     2  eta+.268098335)*eta+.678091)*eta+.6513262112)
      return
 3000 ffeta=1.15279031+1.5*(((((( .000081733*eta-.001202982)*
     1  eta+.005151675)*eta+.0556078333)*eta+.26819)*
     2  eta+.678091)*eta)
      return
 4000 ffeta=10.3536987+1.5*((((((-.303295167e-5*eta+
     1  .16516628e-3)*eta-.42073325e-2)*eta+.0901841667)*
     2  eta+.1961444)*eta+.757064709)*eta-6.16859689)
      return
 5000 eta12=sqrt(eta)
      eta32=eta12*eta
      eta52=eta32*eta
      eta72=eta52*eta
      etasq=eta*eta
      eta112=eta72*etasq
      eta152=eta112*etasq
      ffeta=134.270211-134.270185+.4*eta52+2.4674010*
     1   eta12-.7102746/eta32-2.771862428/eta72-
     2   44.1300036/eta112-1641.825466/eta152
      return
 6000 ffeta = .4 * eta**2.5
      return
      end
