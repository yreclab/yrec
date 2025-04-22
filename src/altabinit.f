C	Subroutine ALTABINIT

C PURPOSE
C To analyze the internal Allard-format tables provided by ALFILEIN, verifying them 
C and creating needed additoinal tables and elements.

C Several steps are taken:
C 1. Find the minimum (TEFFLmin) and maximum (TEFFLmax) permissable values of TEFFL. These are 
C    one row's width below the bottom and above the top of the table. Because the first level 
C    of interpolation is in GL, only a single minimum and maximum value of TEFFL are needed.
C 2. For each row in GL, find the index of the smallest element (iGLmin) and the index of the 
C    largest element (iGLmax). There is one pair of these for each TEFFL.
C 3. For each row in GL, find the the minimum (GLmin) and maximum (GLmax) permissable value of 
C    GL. These are one column's width less than the row minimum in GL and one column's width 
C    greater than the column maximum. There is one pair of these for each TEFFL.
C 4. Validate the table. (a) Ensure that there are no invalid elements inside the table, i.e.,  
C    no invalid element between the row's iGLmin and iGLmax. This check is made for every TEFFL.  
C    (b) Ensure that every row has at least 4 valid entries and that there are at least 4 columns.


	SUBROUTINE ALTABINIT
       use parmin90, only : ISHORT  ! COMMON/LUOUT/

      PARAMETER(NTA=250,NGA=25)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)
	LOGICAL*4 LALTPTau100
      CHARACTER*256 FALLARD

      COMMON /ALATM01/ TEFFLs(NTA),GLs(NGA),FeHs(NGA),      ! Shared: ALFILEIN, ALTABINIT and ALSURFP 
     x   ALPHAs(NGA),PLs(NTA,NGA),P100Ls(NTA,NGA),T100Ls(NTA,NGA),
     x   LOldNextGen,nTEFF,nGL,nFeH,nALPHA
      COMMON /ALATM02/ GLmin(NTA),GLmax(NTA),IGLmin(NTA),      ! Shared: ALTABINIT and ALSURFP
     x   IGLmax(NTA),TEFFLmin,TEFFLmax,GLXmin,GLXmax
      COMMON /ALATM03/ ALATM_FeH,ALATM_Alpha,LALTPTau100,  ! Shared: ALFILEIN, 
     x       IOATMA					           ! ALSURFP and PARMIN
	COMMON /ALATM04/ DUMMY1,DUMMY2,FALLARD,DUMMY3,DUMMY4
	COMMON /ALATM05/ AL_TEFFLmin,AL_TEFFLmax

C 1. Find the minimum (TEFFLmin) and maximum (TEFFLmax) permissable values of TEFFL. These are 
C    one row's width below the bottom and above the top of the table. Because the first level 
C    of interpolation is in GL, only a single minimum and maximum value of TEFFL are needed.
	AL_TEFFLmin = TEFFLs(1)
	AL_TEFFLmax = TEFFLs(nTEFF)
	TEFFLmin = TEFFLs(1) - (TEFFLs(2)-TEFFLs(1))
	TEFFLmax = TEFFLs(nTeff) + (TEFFLs(nTeff)-TEFFLs(nTeff-1))
	
C 2. For each row in GL, find the index of the smallest element (iGLmin) and the index of the 
C    largest element (iGLmax). There is one pair of these for each TEFFL.
	do i = 1, nTeff
	   do j = 1, nGL
	      if(PLs(i,j) .gt. -998D0) then
	         iGLmin(i) = j
	         goto 100
	      endif
	   enddo
  100    continue
	   do j = nGL, 1, -1
	      if(PLs(i,j) .gt. -998D0) then
	         iGLmax(i) = j
	         goto 110
	      endif
	   enddo
  110    continue

	enddo	

C 3. For each row in GL, find the the minimum (GLmin) and maximum (GLmax) permissable value of 
C    GL. These are one column's width less than the row minimum in GL and one column's width 
C    greater than the column maximum. There is one pair of these for each TEFFL.

	GLXmin = 999D0
	GLXmax = -999D0
	do i = 1, nTeff
	   j1 = iGLmin(i)
	   j2 = iGLmax(i)
	   GLmin(i) = GLs(j1) - 4D0*(GLs(j1+1) - GLs(j1))
	   if(GLmin(i) .lt. GLXmin) GLXmin = GLmin(i)
	   GLmax(i) = GLs(j2) + (GLs(j2) - GLs(j2-1))
	   if(GLmax(i) .gt. GLXmax) GLXmax = GLmax(i)
	enddo
	
C 4. Validate the table. (a) Ensure that there are no invalid elements inside the table, i.e.,  
C    no invalid element between the row's iGLmin and iGLmax. This check is made for every TEFFL.  

	LBadTable = .false.
	do i = 1, nTeff
	   j1 = iGLmin(i)
	   j2 = iGLmax(i)
	   do j = j1, j2
	      if(PLs(i,j) .lt. -998D0) then
	        LBadTable = .true.
	        write(ISHORT,900) 'ALTABINIT: Bad input Allard Table: ',
     x           'TEFF, GL: ', 10D0**TEFFLs(i), GLs(j)
 900		  format(2A,F5.0,F7.2)
            endif
	   enddo
	enddo
	
C    (b) Ensure that every row has at least 4 valid entries and that there are at least 4 columns.
	if(nTeff .lt. 4) then 
	   LBadTable = .true.
	   write(ISHORT,910) 'ALTABINIT: Bad input Allard Table: ',
     x      'Less than 4 rows: nTeff = ',nTeff
 910	   format(A,I3)
      endif
	do i = 1, nTeff
	   j1 = iGLmin(i)
	   j2 = iGLmax(i)
	   if ((j2 - j1 + 1) .lt. 4) then
	      LBadTable = .true.
	      write(ISHORT,920) 'ALTABINIT: Bad input Allard Table: ',
     x        'Row with less that 4 elements: i,#,Teff,GLMin,GLmax: ', 
     x         i,j2-j1+1,10D0**TEFFLs(i),GLmin(i),GLmax(i)
 920		format(2A,2I4,2X,3F7.2)
         endif
	enddo
	
	if (LBadTable) goto 9999		! If bad table, go to error exit
	
	return			! If good table, return
	
 9999	continue
 	write(*,*)
 	write(*,*)'******** ALTABINIT: Program Terminated ********'
 	write(*,*)
 	write(ISHORT,*)
 	write(ISHORT,*)'******** ALTABINIT: Program Terminated ********'
 	write(ISHORT,*)
 	CALL ALPRINT
 	STOP
 	
 	END
 			
