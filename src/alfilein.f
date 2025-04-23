C	Subroutine ALFILEIN

C PURPOSE
C To read Allard atmosphere information files into the appropriate input arrays
C and calculate associated auxilliary information. These files contain the
C desired properties of stellar and substellar atmospheres from atmospheric
C tables developed by France Allard, et al. These properties include Log(P)
C at Teff and GL, as well as Log(P) and Log(T) at Tau = 100 for this Teff and
C GL. Currently supported input formats include the old Allard, et al, circa
C 1999 NextGen format, to which we are adding the newer 2007 NextGen format.
C As other formats become available, weanticipate being able to handle those also.

C Input files may be in Old NextGen file format or in the new Allard Atmosphere
C file format. This format, is of a conceptually different style from the old.
C The data part of the new file format has one record for each Teff, GL, FE/h,
C Alpha. The rest of that record contains the associated PL @ T=Teff,
C PL @ Tau=100 and TL @ Tau100. In other words the new format has one data record
C for each item in the table. The old format had one record for each GL in the
C table. This new format is more flexible in supporting future needs.

C The contents of these files are put into the arrays and elements used by the
C Allard Atmosphere table lookup routine, ALSURFP. In addition, we fill any vacant
C entries in the table with -999.0. A value of -999. in the table identifies the
C entry as "invalid." In addition, key auxililiary arrays, as described below, are
C created.






       SUBROUTINE ALFILEIN
       use settings, only : ISHORT  ! COMMON/LUOUT/
C
C Parameters NTA and NGA are respectively the maximum expected numbers
C of Teff's and GL's we expect to encounter, even in future tables
C The maximum nuber of Teff's in the current table is nTeff, and the
C associated max number of GL's is nGL.

      PARAMETER(NTA=250,NGA=25)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)
      CHARACTER*256 FALLARD
      CHARACTER*35 inrec
      CHARACTER*256 inrec2
	DIMENSION TEFFs(NTA)
	LOGICAL*4 LALTPTau100

      COMMON /ALATM01/ TEFFLs(NTA),GLs(NGA),FeHs(NGA),      ! Shared: ALFILEIN, ALTABINIT and ALSURFP
     x   ALPHAs(NGA),PLs(NTA,NGA),P100Ls(NTA,NGA),T100Ls(NTA,NGA),
     x   LOldNextGen,nTEFF,nGL,nFeH,nALPHA
      COMMON /ALATM03/ ALATM_FeH,ALATM_Alpha,LALTPTau100,  ! Shared: ALFILEIN,
     x       IOATMA					           ! ALSURFP and PARMIN
	COMMON /ALATM04/ DUMMY1,DUMMY2,FALLARD,DUMMY3,DUMMY4

     EXTERNAL sort_shell

      SAVE

C set output arrays to invalid values
	do i = 1,NTA
	   TEFFLs(i) = -999.D0
	   do j = 1,NGA
	      GLs(j) = -999.D0
	      PLs(i,j) = -999.D0
	      P100Ls(i,j) = -999.D0
	      T100Ls(i,j) = -999.D0
	   enddo
	enddo
C the input file name is in FALLARD and its unit number is IOATMA
      OPEN(IOATMA,FILE=FALLARD,STATUS='OLD',ERR= 899)
      goto 900

 899	continue
 	write(*,*)
 	write(*,*) 'ALFILEIN: Allard File OPEN Failure'
 	write(*,*) '     Unit-Number, FIle-Name are: ',
     x     ioatma,fallard
 	goto 9999	! Error exit

 900	continue
C Decide what kind of input file
      read(ioatma,901) inrec
 901  format(a)
	rewind(ioatma)
	if(inrec(4:7) .eq. '3.50') goto 100  ! Old NextGen file type
	if (inrec(4:9) .eq. 'ALLARD') goto 200  ! Allard file type
C If we get here, the input file is invalid
	write(ISHORT,*)'*** Invalid Allard Atmosphere input file ***'
	Write(ISHORT,*) "First record was '",inrec,"'"
	write(*,*)'*** Invalid Allard Atmosphere input file ***'
	Write(*,*) "First record was '",inrec,"'"
	goto 9999   ! The error exit

C Process old-stype nextgen input file.
 100	CONTINUE
 	LOldNextGen = .TRUE.
 	write(ishort,*) 'ALFileIn: File Description: 1999 NEXTGEN',
     x     ' (Old NEXTGEN)'

C Ensure that we are not requesting PL,TL at Tau-100. These are not
C present in the old Nextgen 1 files. If requested, fail
	If(LATMTPTau100) then
	   write(*,*)
	   write(*,*) 'ALFileIN: Invalid old Allard input file ',
     x         'for requested PT,TL at Tau=100'
	   write(ISHORT,*)
	   write(ISHORT,*) 'ALFileIN: Invalid old Allard input file ',
     x         'for requested PT,TL at Tau=100'
	   goto 9999  ! The ERROR EXIT
	endif
C READ RANGE OF GRAVITIES
	nTeff = 54
	nGL = 5
      READ(IOATMA,905)(GLs(I),I=1,nGL)
 905  FORMAT(5F7.2/)
c 	read(ioatma,*)

C READ RANGE OF TEMPERATURES
      READ(IOATMA,907)(TEFFLs(I),I=1,nTeff)
 907  FORMAT(10(1P5E16.8,/),1P4E16.8,/)
c 	read(ioatma,*)
      READ(IOATMA,909)((PLs(J,I),I=1,nGL),J=1,nTeff)
 909  FORMAT(1P5E16.8)
      CLOSE(IOATMA)
	Goto 500	! NORMAL EXIT
C Old Nextgen input file has been read an put into the proper arrays

C Process new-style Allard Atmosphere file
 200	CONTINUE
 	LOldNextGen = .FALSE.
	read(ioatma,911) nhdr, inrec2  ! nhdr is number of header recoreds to skip over
 911	format(i2,X,a)
 	write(ishort,912) 'ALFilein: New Allard Atm: File Description: ',inrec2(1:47)
 912  format(2a)
C Skip over rest of header, if any
	if(nhdr .gt. 1) then
	  do i = 2, nhdr
	    read(ioatma,*)
	  enddo
      endif
	nGL = 0
	nTeff = 0
	nFeH = 0
	nALPHA = 0
	irecno = 0

C First we read the file to count the # of Teff,GL,Fe/H and Alpha's

 299	read(IOATMA,915,end=400,err=399) Teff,GL,FeH,Alpha ! Process first record(s)
 915	format(F6.0,3F6.2)
	irecno=irecno+1

C If the record does not have the correct FeH and Alpha, we skip it
	if((DABS(FeH-ALATM_FeH).gt.1D-5) .or.
     x       (DABS(Alpha-ALATM_Alpha).gt.0D0)) then
         goto 299  ! On to next record. Stay in this part until we get an acceptable record
      endif
	nTeff = 1    ! Initialize counters and variables after reading first record
	nGL = 1
	nFeH = 1
	nALPHA = 1
	Teffs(nTeff) = Teff
	GLs(nGL) = GL
	FeHs(nFeH) = FeH
	ALPHAs(nAlpha) = Alpha

 300	read(IOATMA,915,end=400,err=399) Teff,GL,FeH,Alpha
	irecno=irecno+1

C If the record does not have the correct FeH and Alpha, we skip it
	if((DABS(FeH-ALATM_FeH).gt.1D-5) .or.
     x       (DABS(Alpha-ALATM_Alpha).gt.0D0)) then
         goto 316  ! On to next record
	endif

C  Now check Teffs, increase counter if needed
       do i = 1,nTeff  ! Skip out if any old Teff is a match
        if (DABS(Teff-Teffs(i)) .lt.1D-6) goto 310
      enddo
        nTeff = nTeff+1      ! count the nextTeff's
        Teffs(nTeff) = Teff  ! save the new Teff in array Teffs
 310  CONTINUE

c Now check GLs, increase counter if needed
      do i = 1,nGL  ! Skip out if any old GL is a match
        if (DABS(GL-GLs(i)) .lt.1D-6) goto 312
      enddo
        nGL = nGL+1      ! count the next GL
        GLs(nGL) = GL  ! save the new GL in array GLs
 312  CONTINUE


c Now check FeHs, increase counter if needed
      do i = 1,nGL  ! Skip out if any old FeH is a match
        if (DABS(FeH-FeHs(i)) .lt.1D-6) goto 314
      enddo
        nFeH = nFeH+1      ! count the next FeH
        FeHs(nFeH) = FeH  ! save the new FeH in array FeHs
 314  CONTINUE

c Now check ALPHAs, increase counter if needed
      do i = 1,nGL  ! Skip out if any old ALPHA is a match
        if (DABS(ALPHA-ALPHAs(i)) .lt.1D-6) goto 316
      enddo
        nALPHA = nALPHA+1      ! count the next ALPHA
        ALPHAs(nALPHA) = ALPHA  ! save the new ALPHA in array ALPHAs
 316  CONTINUE

	goto 300 ! go on to next record

C File Read error exit
 399	continue
 	write(*,*)
 	write(*,*)'AtTabInit Pass 1 File Error '
 	write(*,*)
 	goto 9999

 400	continue
c 	write(*,*) 'nTeff,nGL,nFeH,nALPHA: ',nTeff,nGL,nFeH,nALPHA

C  Now we have unsorted Teff,GL,Fe/H and Alpha's.
C The next step is to sort them
	call sort_shell(nTeff,Teffs)
	call sort_shell(nGL,GLs)
	call sort_shell(nFeH,FeHs)
	call sort_shell(nALPHA,ALPHAs)

C Now we can rewind the input file and start over for real
	rewind(ioatma)  ! go back to the beginning of the file

C  Skip over header
	do i = 1,nhdr
	   read(ioatma,*)
	enddo

 410 	read(IOATMA,920,END=500,ERR=499) Teff,GL,FeH,Alpha,PL,
     x       P100L,T100
 920	format(F6.0,3F6.2,1P4D16.8)

C If the record does not have the correct FeH and Alpha, we skip it
	if((DABS(FeH-ALATM_FeH).gt.1D-5) .or.
     x       (DABS(Alpha-ALATM_Alpha).gt.0D0)) then
         goto 440  ! On to next record
      endif

      do i = 1,nTeff  ! Skip out when we find the matching Teff
        if (DABS(Teff-Teffs(i)) .lt.1D-6) then
           I1 = i
           goto 420
        endif
      enddo
      write(*,*) 'ALFilein: Impossible failure #1'
      Write(*,*) 'Teff of ', Teff, ' not in Teff table.'
      goto 9999  ! The error exit

 420  CONTINUE
      do j = 1,nGL  ! Skip out when we find the a matching GL
        if (DABS(GL-GLs(j)) .lt.1D-6) then
           j1 = j
           goto 430
        endif
      enddo
      write(*,*) 'ALFilein: Impossible failure #2'
      Write(*,*) 'GL of ', GL, ' not in GL table.'
      goto 9999  ! The error exit

 430	CONTINUE

C we now verify that we have the correct FeH and Alpha

      if (DABS(FeH -ALATM_FeH) .ge. 1D-6)  goto 440     ! Wrong FeH, bypass item
      if (DABS(Alpha -ALATM_Alpha) .ge. 1D-6)  goto 440 ! Wrong Alpha, bypass item


C We now have the correct indices for our tables, i1 for the Teff-direction
C and j1 for the GL direction

 	TEFFLs(I1) = LOG10(Teff)  ! We need log(teff), but up to now we've been using Teff
 	GLs(j1) = GL
 	PLs(i1,j1) = PL
 	P100Ls(i1,j1) = P100L
 	T100Ls(i1,j1) = T100

 440  continue
 	goto 410   ! Back to process the next record

 499	continue
 	write(*,*)
 	write(*,*)'AtTabInit File Read error'
 	write(*,*)
 	goto 9999

 500	continue  ! We heve finished with the input file and entered all inputs

	CALL ALTABINIT   ! Initialize Allard tables

 	return

 9999	continue    ! THE ERROR EXIT
 	write(*,*)
 	write(*,*)
 	write(*,*) '**************** PROGRAM ALFilein TERMINATED ',
     x       '@ 9999 **************'
 	write(*,*)
 	write(*,*)
 	write(*,*)
 	write(ISHORT,*)
 	write(ISHORT,*) '**************** PROGRAM ALFilein TERMINATED ',
     x      '@ 9999 *************'
 	write(ISHORT,*)
 	write(ISHORT,*)
      STOP 9999

	end	! END OF ALINITTAB

C ************* End of ALFilein *************************


C Numerical Recipes Shell sort

      SUBROUTINE sort_shell(nn,A)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION A(nn)
	INTEGER*4 nn,n,inc,i,j
C Sorts an array A(1:nn) into ascending numerical order by Shell's method (diminishing
C incremental sort) nn is input. A is replaced on output by its sorted arrangement

	if (nn .eq. 1) return			! Exit if only one element
	n=nn
	inc=1
    1 inc=3*inc+1 				! Determin starting increment
	if (inc .le. n) goto 1
    2	continue
	   inc=inc/3				! Loop over the partial sorts
	   do i=inc+1,n
		v=A(i)				! Outer loop of straight insertion
		j=i
    3  	if (A(j-inc) .gt. v) then	! Inner loop of straight insertion
		   A(j)=A(j-inc)
		   j=j-inc
		   if (j .le. inc) goto 4
		goto 3
		endif
    4 	A(j)=v
	   enddo
	if (inc .gt. 1) goto 2
	return
	END


C ************* End of sort_shell *************************

