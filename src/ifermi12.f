
      double precision function ifermi12(f)
      implicit none
      save


c..this routine applies a rational function expansion to get the inverse
c..fermi-dirac integral of order 1/2 when it is equal to f.
c..maximum error is 4.19d-9.   reference: antia apjs 84,101 1993


c..declare
      integer          i,m1,k1,m2,k2
      double precision f,an,a1(12),b1(12),a2(12),b2(12),rn,den,ff,
     1                 z,drn



c..load the coefficients of the expansion
      data  an,m1,k1,m2,k2 /0.5d0, 4, 3, 6, 5/
      data  (a1(i),i=1,5)/ 1.999266880833d4,   5.702479099336d3,
     1     6.610132843877d2,   3.818838129486d1,
     2     1.0d0/
      data  (b1(i),i=1,4)/ 1.771804140488d4,  -2.014785161019d3,
     1     9.130355392717d1,  -1.670718177489d0/
      data  (a2(i),i=1,7)/-1.277060388085d-2,  7.187946804945d-2,
     1                    -4.262314235106d-1,  4.997559426872d-1,
     2                    -1.285579118012d0,  -3.930805454272d-1,
     3     1.0d0/
      data  (b2(i),i=1,6)/-9.745794806288d-3,  5.485432756838d-2,
     1                    -3.299466243260d-1,  4.077841975923d-1,
     2                    -1.145531476975d0,  -6.067091689181d-2/



      if (f .lt. 4.0d0) then
       rn  = f + a1(m1)
       do i=m1-1,1,-1
        rn  = rn*f + a1(i)
       enddo
       den = b1(k1+1)
       do i=k1,1,-1
        den = den*f + b1(i)
       enddo
       ifermi12 = log(f * rn/den)


      else
       ff = 1.0d0/f**(1.0d0/(1.0d0 + an))
       rn = ff + a2(m2)
       do i=m2-1,1,-1
        rn = rn*ff + a2(i)
       enddo
       den = b2(k2+1)
       do i=k2,1,-1
        den = den*ff + b2(i)
       enddo
       ifermi12 = rn/(den*ff)
      end if
      return
      end
