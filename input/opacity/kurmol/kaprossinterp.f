      PROGRAM KAPROSSINTERP
      DIMENSION AKAP1(5),AKAP2(5),AKAP3(5) 
      read *,WT1,WT2
      PRINT *,WT1,WT2
      READ(1,5)
      READ(1,5)
      READ(2,5)
      READ(2,5)
      WRITE(3,22)
   22 format(/' ROSSELAND MASS ABSORPTION COEFFICENTS'/ 
     1' logT logP  0km/s  1km/s  2km/s  4km/s  8km/s  log Ne   log Na  l
     2og rho IPloCM-1')
c 3.32-2.00 -5.200 -5.188 -5.169 -5.139 -5.104  5.29314 10.53958-13.12598   0.002
      do 8 it=1,56
      do 6 iP =1,38
      READ(1,5)TABT,TABP,AKAP1,ANE,ANA,TABR
      READ(2,5)TABT,TABP,AKAP2,ANE,ANA,TABR
      DO 4 IV=1,5
    4 AKAP3(IV)=WT1*AKAP1(IV)+WT2*AKAP2(IV)
      WRITE(3,5)TABT,TABP,AKAP3,ANE,ANA,TABR
    5 format(f5.2,f5.2,5F7.3,f9.5,f9.5,f9.5,f8.3,3F9.5)
    9 format(/f5.2,f5.2,5F7.3,f9.5,f9.5,f9.5,f8.3,3F9.5)
    6 continue
    8 continue
      CALL EXIT
      END
