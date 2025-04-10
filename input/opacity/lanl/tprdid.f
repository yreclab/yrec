ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Subroutine:          TPRDID  
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c This routine reads the first 8 bytes of a element or mixture
c file and verifies that it is the correct file.
c
      subroutine tprdid(io, num, ierror, lmix)
      character*4 id1, id2
      logical lmix
      character*2 element(20), elemlasl(20)
      common /elem/ element, elemlasl
      read(io) id1, id2
      if (lmix) then
	 if((id1(1:2).eq.element(3)) .and. (id2(3:4)
     1       .eq. element(num))) then
	     ierror = 0
	 else
	     ierror = 1
	 endif
      else
	 if (id1(3:4) .eq. elemlasl(num)) then
	     ierror = 0
	 else
	     ierror = 1
	 end if
      end if
      return
      end
