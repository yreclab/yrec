C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     QUADEOSS01
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      function quadeos01(ic,i,x,y1,y2,y3,x1,x2,x3)

c..... this function performs a quadratic interpolation.

      IMPLICIT REAL*8 (A-H,O-Z)
      dimension  xx(3),yy(3),xx12(30),xx13(30),xx23(30),xx1sq(30)
     . ,xx1pxx2(30)
      save

      xx(1)=x1
      xx(2)=x2
      xx(3)=x3
      yy(1)=y1
      yy(2)=y2
      yy(3)=y3
        if(ic .eq. 0) then
          xx12(i)=1D0/(xx(1)-xx(2))
          xx13(i)=1D0/(xx(1)-xx(3))
          xx23(i)=1D0/(xx(2)-xx(3))
          xx1sq(i)=xx(1)*xx(1)
          xx1pxx2(i)=xx(1)+xx(2)
        endif
      c3=(yy(1)-yy(2))*xx12(i)
      c3=c3-(yy(2)-yy(3))*xx23(i)
      c3=c3*xx13(i)
      c2=(yy(1)-yy(2))*xx12(i)-xx1pxx2(i)*c3
      c1=yy(1)-xx(1)*c2-xx1sq(i)*c3
      quadeos01=c1+x*(c2+x*c3)
      return
      end
