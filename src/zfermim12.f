
      double precision function zfermim12(x)
      implicit none
      save


c..this routine applies a rational function expansion to get the fermi-dirac
c..integral of order -1/2 evaluated at x. maximum error is 1.23d-12.
c..reference: antia apjs 84,101 1993


c..declare
      integer          i,m1,k1,m2,k2
      double precision x,an,a1(12),b1(12),a2(12),b2(12),rn,den,xx


c..load the coefficients of the expansion
      data  an,m1,k1,m2,k2 /-0.5d0, 7, 7, 11, 11/
      data  (a1(i),i=1,8)/ 1.71446374704454d7,    3.88148302324068d7,
     1                     3.16743385304962d7,    1.14587609192151d7,
     2                     1.83696370756153d6,    1.14980998186874d5,
     3                     1.98276889924768d3,    1.0d0/
      data  (b1(i),i=1,8)/ 9.67282587452899d6,    2.87386436731785d7,
     1                     3.26070130734158d7,    1.77657027846367d7,
     2                     4.81648022267831d6,    6.13709569333207d5,
     3                     3.13595854332114d4,    4.35061725080755d2/
      data (a2(i),i=1,12)/-4.46620341924942d-15, -1.58654991146236d-12,
     1                    -4.44467627042232d-10, -6.84738791621745d-8,
     2                    -6.64932238528105d-6,  -3.69976170193942d-4,
     3                    -1.12295393687006d-2,  -1.60926102124442d-1,
     4                    -8.52408612877447d-1,  -7.45519953763928d-1,
     5                     2.98435207466372d0,    1.0d0/
      data (b2(i),i=1,12)/-2.23310170962369d-15, -7.94193282071464d-13,
     1                    -2.22564376956228d-10, -3.43299431079845d-8,
     2                    -3.33919612678907d-6,  -1.86432212187088d-4,
     3                    -5.69764436880529d-3,  -8.34904593067194d-2,
     4                    -4.78770844009440d-1,  -4.99759250374148d-1,
     5                     1.86795964993052d0,    4.16485970495288d-1/



      if (x .lt. 2.0d0) then
       xx = exp(x)
       rn = xx + a1(m1)
       do i=m1-1,1,-1
        rn = rn*xx + a1(i)
       enddo
       den = b1(k1+1)
       do i=k1,1,-1
        den = den*xx + b1(i)
       enddo
       zfermim12 = xx * rn/den
c..
      else
       xx = 1.0d0/(x*x)
       rn = xx + a2(m2)
       do i=m2-1,1,-1
        rn = rn*xx + a2(i)
       enddo
       den = b2(k2+1)
       do i=k2,1,-1
        den = den*xx + b2(i)
       enddo
       zfermim12 = sqrt(x)*rn/den
      end if
      return
      end

