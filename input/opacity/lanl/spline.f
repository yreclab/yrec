cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  SUBROUTINE spline
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Taken from Numerical Recipes, Press et al, p88
c Given arrays x and y of length n containing a tabulated funcition,
c i.e. y[i] = f(x[i]) with x[1] < x[2] < ... x[n], and given values
c yp1 and ypn for the first derivative of the interpolating function
c at points 1 and n, respectively, this routine returns and array y2
c of length n which contains the second derivatives of the interpolating
c function at the tabulated points x[i].  If yp1 and/or ypn are equal
c to 1.0e30 or larger, the routine is signalled to set the corresponding
c boundary condition for a natural spline, with zero second derivative
c on that boundary.
      subroutine spline(x, y, n, yp1, ypn, y2)
      parameter(nmax=100)
      dimension x(n), y(n), y2(n), u(nmax)
      if (yp1 .gt. 0.99e30) then
	 y2(1) = 0.0
	 u(1) = 0.0
      else
	 y2(1) = -0.5
	 u(1) = (3./(x(2)-x(1)))*((y(2)-y(1))/(x(2)-x(1))-yp1)
      endif
      do i=2, n-1
	 sig = (x(i)-x(i-1))/(x(i+1)-x(i-1))
	 p = sig*y2(i-1)+2.0
	 y2(i) = (sig-1.0)/p
	 u(i) = (6.0*((y(i+1)-y(i))/(x(i+1)-x(i))-(y(i)-y(i-1))
     1          /(x(i)-x(i-1)))/(x(i+1)-x(i-1))-sig*u(i-1))/p
      end do
      if (ypn .gt. 0.99e30) then
	 qn = 0.0
	 un = 0.0
      else
	 qn = 0.5
	 un = (3./(x(n)-x(n-1)))*(ypn-(y(n)-y(n-1))/(x(n)-x(n-1)))
      end if
      y2(n) = (un-qn*u(n-1))/(qn*y2(n-1)+1.0)
      do k=n-1, 1, -1
	 y2(k) = y2(k)*y2(k+1)+u(k)
      enddo
      return
      end
