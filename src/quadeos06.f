C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     QUADEOSS06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      function quadeos06(ic,i,x,y1,y2,y3,x1,x2,x3)
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 C1,C2,C3,QUADEOS06,X,X1,X2,X3,XX,XX12,XX13,XX1PXX2,XX1SQ,
     *       XX23,Y1,Y2,Y3,YY
      INTEGER I,IC

c..... this function performs a quadratic interpolation.

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
      c2=(yy(1)-yy(2))*xx12(i)-(xx1pxx2(i))*c3
      c1=yy(1)-xx(1)*c2-xx1sq(i)*c3
      quadeos06=c1+x*(c2+x*c3)
      return
      end
