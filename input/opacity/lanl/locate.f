ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     LOCATE
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Given an array XX of length N, and given a value X, returns
c a value J such that X is between XX(j) and XX(J+1).  X=0 or N
c then out of range.
c
      subroutine locate(xx, n, x, j)
      dimension xx(n)
      jl = 0
      ju = n+1
 10   if (ju-jl.gt.1) then
	 jm = (ju+jl)/2
	 if((xx(n).gt.xx(1)).eqv.(x.gt.xx(jm))) then
	    jl = jm
	 else
	    ju = jm
	 end if
	 go to 10
      end if
      j = jl
      return
      end
