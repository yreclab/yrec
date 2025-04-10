cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c SUBROUTINE splint
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Taken from Numerical Recipes, Press, et al, p89.
c Given the arrays xa and ya of length n, which tabulate a function
c (with the xa[i]'s in order), and given the array y2a, which is the
c output of spline above, and given a value of x, this routine returns
c a cubic-spline interpolated value y.
      subroutine splint(xa, ya, n, y2a, x, y)
      dimension xa(n), ya(n), y2a(n)
      klo = 1
      khi = n
    1 if (khi-klo .gt. 1) then
	 k = (khi+klo)/2
	 if (xa(k) .gt. x) then
	    khi = k
	 else
	    klo = k
	 end if
	 goto 1
      end if
      h = xa(khi) - xa(klo)
      if (h .eq. 0.) then
c error
      endif
      a = (xa(khi)-x)/h
      b = (x - xa(klo))/h
      y = a*ya(klo)+b*ya(khi)+
     1    ((a**3-a)*y2a(klo)+(b**3-b)*y2a(khi))*(h**2)/6.0
      return
      end
