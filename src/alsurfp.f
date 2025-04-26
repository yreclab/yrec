C      Subroutine ALSURFP

C PURPOSE
C To obtain the desired properties of stellar and sub-stellar atmospheres from atmospheric
C tables developed by France Allard, et al. Given Log(Teff) and GL, ASURFP returns Log(P) at
C this Teff and GL, as well as Log(P) and Log(T) at Tau = 100 for this Teff and GL.

C Currently supported input formats include the old Allard, et al, circa 1999 NextGen format,
C to which we are adding the newer 2007 NextGen format. As other formats become available, we
C anticipate being able to handle those also.

C Results are obtained by doing 4-point Lagrange interpolation in two dimensions, in TeffL and
C GL. This means we will be interpolating (or extrapolating) over sixteen points in four rows
C of four. We require that the desired Teff and GL are within the limits of the extended range
C of the table. The extended range for GL is from one column's width past the lowest GL on the
C left to one column's width past the highest GL on the right for the current row. The extended
C range for TeffL is defined in the same manner as for the columns. Note that the limits are on
C a row by row and column by column basis. If the request TeffL, GL point is outside the table,
C the progam is terminated with a definitive error message.

C ARGUMENTS OF TABLE LOOKUP SUBROUTINE

C TeffL      - Input argument. Value of TL at which the results are desired.
C GL            - Input argument. Value of GL at which the results are desired.
C AP            - Output argument to COMMON /ATMPRT/. Value of Log(Pressure) for the
C              associated input TeffL and GL If LATMTPTau100 is .FALSE. it is PL
C              at TEFFL,GL. If .TRUE. it is PL at TAU=100 for the starting TEFFL,GL.
C AT            - Output argument to COMMON /ATMPRT/. Value of Log(Temperature) for the
C              associated input TeffL and GL If LATMTPTau100 is .FALSE. it is TEFFL.
C              If .TRUE. it is TL at TAU=100 for the starting TEFFL,GL.
C LPRT        Input argument: If .TRUE. print Log(P) at the associated Log(Teff)  to ISHORT and IMODPT.
C LAlFail   Output argument. If .TRUE. the specified TeffL/GL is outside the Allard tables. The
C           calling routine should set KTTAU to 0 to change to a gray atmosphere, or KTTAU to 3 for
C           aKurucz atmosphere.
C
C Internal Arrays
C TEFFLs      1-D Array of T=TeffL table elements - one for each TeffL. (Columns)
C GLs            1-D Array of G = GL table elements - one for each GL. (Rows)
C PLs            2-D array of assoiated PL's for the matching T in TEFFLs and the matching G in GLA.
C            - One for each TeffL by One for each GL
C P100Ls      2-D array of assoiated P100L's for the matching T in TEFFLs and  the matching G in GLA.
C             - One for each TeffL by One for each GL
C T100Ls      2-D array of assoiated T100L's for the matching T in TEFFLs and  the matching G in GLA.
C             - One for each TeffL by One for each GL

C In addition, we define the following auxiliarry arrays

C For each row (or GL):
C GLmin      Minimum acceptable GL (including extrapolation) for this row.   - One for each TeffL
C GLmax      Maximum acceptable GL (including extrapolation) for this row.   - One for each TeffL
C IGLmin      Row index of first acceptable GL in table (excludes extrapolation) - One for each TeffL
C IGLmax      Row index of first acceptable GL in table (excludes extrapolation) - One for each TeffL

C For teh Table
C TEFFLmin            Minimum acceptable TeffL (Including extrapolation) for the table
C TEFFLmax            Maximum acceptable TeffL (including extrapolation) for the table.

C OVERALL LOGIC

C I      Determine if TeffL and GL are within overall limits of the table. If TEFFL is greater than the
C     max of all table TL's or less than the minimum, or GL is of the same nature, the program has
C     failed.  To fail, write diagnostic message and go to error exit.

C II      Locate TL and GL in table. This gives us a column index, iGL, and a row index, iTL. The subtable
C     used for Lagrange interpolation will        have four rows of four elements. Find indices such that
C     each row is in the table.  Start with TeffL. If it is out of the table, adjust the TeffL index
C     such that all four rows are in the table. Then for each row asjust the GL index such that the
C     row is in the table. If this is not possible, the program has failed. To fail, write diagnostic
C     message and go to error exit.

C III      Next we do four-point-Lagrange-interpolation in GL in the first row, then the second, then the
C     third, then the fourth rows. We obtain, for each row, the associated Log(P), Log(P100) and
C     Log(T100) for each row's specific TL.

C  IV      To get our desired results, we interpolate the results from III. PL is the result of 4-point
C     Lagrange interpolation in TL using the four Log(P)'s obtained in III above. Likewist P100L and
C     T100L.

C       If LPRT  is .TRUE. print Log(P) at the associated Log(Teff) to ISHORT and IMODPT.

      SUBROUTINE ALSURFP(TEFFL,GL,LPRT,LAlFail)
      use settings, only : ISHORT, IMODPT, ISTOR  ! /LUOUT/
      use settings, only : LALTPTau100  ! /ALATM03/

      PARAMETER(NTA=250,NGA=25)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)

      COMMON/ATMPRT/TAU,AP,AT,AD,AO,AFXION(3)
      COMMON /ALATM01/ TEFFLs(NTA),GLs(NGA),FeHs(NGA),      ! Shared: ALFILEIN, ALTABINIT and ALSURFP
     x   ALPHAs(NGA),PLs(NTA,NGA),P100Ls(NTA,NGA),T100Ls(NTA,NGA),
     x   LOldNextGen,nTEFF,nGL,nFeH,nALPHA
      COMMON /ALATM02/ GLmin(NTA),GLmax(NTA),IGLmin(NTA),      ! Shared: ALTABINIT and ALSURFP
     x   IGLmax(NTA),TEFFLmin,TEFFLmax,GLXmin,GLXmax

      Dimension iGL(4),PL1(4),P100L1(4),
     x    T100L1(4),PL2(4),P100L2(4),T100L2(4)

      SAVE

C       Determine if TeffL and GL are within overall limits of the table. If TEFFL is greater than the
C    max of all table TL's or GL is greater than the max or less than the min. Under these
C    circumstances we want to switch to another kind of atmosphere by changing KTTAU. Most likely
C    the calling routine should set KTTAU to 0, to specify a gray atmosphere.

      LBadPoint = .false.       ! presume we have started at a good point

      if(TEFFL .ge. TEFFLmax) then
         LBadPoint = .true.
         write(ISHORT,*)
         write(ISHORT,*)'ALSURFP: TEFFL greater than TeffLmax: '
         write(ISHORT,*)'    TEFFLmin,TEFFL,TEFFLmax; ',
     x         TEFFLmin,TEFFL,TEFFLmax
         Write(*,*)
         write(*,*)'ALSURFP: TEFFL greater than TeffLmax: '
         write(*,*)'    TEFFLmin,TEFFL,TEFFLmax; ',
     x         TEFFLmin,TEFFL,TEFFLmax
      endif


      if((GL .ge. GLXmax) .or. (GL .le. GLXmin)) then
         LBadPoint = .true.
         write(ISHORT,*)
         Write(*,*)
         write(ISHORT,*)'ALSURFP: GL out of max range: '
         write(ISHORT,*)'    GLXmin,GL,GLXmax; ',
     x         GLXmin,GL,GLXmax
         write(*,*)'ALSURFP: GL out of max range: '
         write(*,*)'    GLXmin,GL,GLXmax; ',
     x         GLXmin,GL,GLXmax
      endif

      if(LBadPoint) then
         LAlFail = .TRUE.  ! We are above the table in Teffl, or outside the table in GL
                           ! Set LAlFail so calling routine can take appropiate action
           return
        else
         LAlFail = .FALSE.  ! We are not above the table in Teffl, and inside the table in GL
      endif

C    If TeffL is less than TeffLmin, the program has failed.  We write a diagnostic message and go
C    to the error exit.

      if(TEFFL .le. TEFFLmin) then
         write(ISHORT,*)
         write(ISHORT,*)'ALSURFP: TEFFL less than TEFFLmin: '
         write(ISHORT,*)'    TEFFLmin,TEFFL,TEFFLmax; ',
     x         TEFFLmin,TEFFL,TEFFLmax
         Write(*,*)
         write(*,*)'ALSURFP: TEFFL less than TEFFLmin: '
        write(*,*)'    TEFFLmin,TEFFL,TEFFLmax; ',
     x         TEFFLmin,TEFFL,TEFFLmax
        go to 9999        ! End program at Error Exit
      endif

C II      Locate TEFFL and GL in table. This gives us a column index, iGL, and a row index, iTEFFL. The
C     subtable used for Lagrange interpolation will have four rows of four elements. Find indices such
C     that each row is in the table.  Start with TeffL. If it is out of the table, adjust the TeffL
C     index such that all four rows are in the table. Then for each row asjust the GL index such that the
C     row is in the table. If this is not possible, the program has failed. To fail, write diagnostic
C     message and go to error exit.

C First locate TEFFL
      CALL LOCATE(TEFFLs,nTEFF,TEFFL,iTEFFL) ! returns row 2 in Teffs for 4x4 Lagrange
      iTEFFL = iTEFFL-1  ! Change to row 1 of 4x4 square in TEFFLs
      if(iTEFFL .lt. 1) iTEFFL = 1                ! Be sure it is safe to do 4-point Lagrange interpolation
      if(iTEFFL .gt. (nTEFF - 3)) iTEFFL = nTEFF - 3

C Now find the right index for each row.
      do i = 1, 4      ! Start with iTEFFL and go up to iTEFFL=3
         i1 =  iTEFFL+i-1      ! current row pointer - index in TEFFLs aray (0 to 3)
         j1 = iGLmin(i1)         ! lowest valid entry in this row
         j2 = iGLmax(i1)         ! higest valid entry in this row
         n = j2-j1+1          ! number of OK columns
         call locate(GLs(j1),n,GL,j3)  ! Returns offset in GLs such that GL is >= GLs(jl1+j3-1)
                        ! and GL,GLs(JL1+j3)
         iGL(i) = j1+j3-1      ! Save the offset
         iGL(i) = iGL(i)-1  ! Change from col 2 to column 1 in GLs direction of 4x4 square
C FIrst make sure it is safe to do 4-point Lagrange interpolaltion
         if(iGL(i) .lt. j1) iGL(i) = j1
         if(iGL(i) .gt. (j2 - 3)) iGL(i) = j2 - 3

C Next, make sue that GL is in range in the current row.  If not, set out of table flag
         if((GL .lt. GLmin(i1)) .or. (GL .gt. GLmax(i1))) then      ! and exit
            LBadPoint = .true.
            write(ISHORT,*)
            write(ISHORT,*)'ALSURFP: GL out of extended range: '
            write(ISHORT,*)'    GLmin,GL,GLmax; ',
     x         GLmin(i1),GL,GLmax(i1)
            write(*,*)
            write(*,*)'ALSURFP: GL out of extended range: '
           write(*,*)'    GLmin,GL,GLmax; ',
     x         GLmin(i1),GL,GLmax(i1)
           LAlFail = .TRUE.
           return
        endif
      enddo


C III      Next we do four-point-Lagrange-interpolation in GL in the first row, then the second, then the
C     third, then the fourth rows. We obtain, for each row, the associated Log(P), Log(P100) and
C     Log(T100) for each row's specific TL.

C Do the Lagrange interpolation in GL
      do i = 1, 4      ! Start with iTEFFL and go up to iTEFFL=3, a row at a time
         i1 = iTEFFL + i -1   ! Index in TEFFL array (0 to 3)
         do j= 1, 4
            j1 = iGL(i) + j -1  ! Index in GL array - from iGL(i) to iGL(i)+3
            PL1(j) = PLs(i1,j1)        ! Get this row's four working PL's
            P100L1(j) = P100Ls(i1,j1)  ! Get this row's four working P100L's
            T100L1(j) = T100Ls(i1,j1)  ! Get this row's four working T100L's
         enddo
         j1 = iGL(i)
         CALL POLINT(GLs(j1),PL1,4,GL,PL2(i),dy)
         CALL POLINT(GLs(j1),P100L1,4,GL,P100L2(i),dy)
         CALL POLINT(GLs(j1),T100L1,4,GL,T100L2(i),dy)
      enddo
C Now do final 4-point Lagrange inerpolations in TEFFL
      IF(.NOT. LALTPTau100) THEN
C   Current standard alternative. PL for TEFFL,GL, TL=TEFFL
         CALL POLINT(TEFFLs(iTEFFL),PL2,4,TEFFL,AP,dy)
         AT = TEFFL
      ELSE
         CALL POLINT(TEFFLs(iTEFFL),P100L2,4,TEFFL,AP,dy)
         CALL POLINT(TEFFLs(iTEFFL),T100L2,4,TEFFL,AT,dy)
      ENDIF

C We now have obtained the needed temparatures and pressures

C If requested, WRITE OUT INFORMATION TO THE MODEL FILE.
      IF (LPRT) THEN
         IF(LALTPTau100) then
            WRITE(ISHORT,70)
            WRITE(ISTOR,70)
70          FORMAT('********PL,TL at Tau=100 INTERPOLATED'
     *          , ' FROM ALLARD TABULATED VALUES********')
         ELSE
            WRITE(ISHORT,71)
            WRITE(ISTOR,71)
71          FORMAT('********PL,TL at T=TEFF,GL INTERPOLATED '
     *         , 'FROM ALLARD TABULATED VALUES********')
         ENDIF
         WRITE(ISHORT,72) TEFFL,GL,AT,AP
         WRITE(ISTOR,72) TEFFL,GL,AT,AP
72       FORMAT(' ',20X,'LOG(Teffl) =',F10.5,' ,LOG(G) =' ,F10.5,
     x       ', LOG(T) =',F10.5,', Log(P) =', F10.5)
      ENDIF

C If not requested via LPRT, WRITE OUT INFORMATION TO THE SHORT FILE.
      IF (.not. LPRT) THEN
        IF(LALTPTau100) then
           WRITE(ISHORT,73)
73         FORMAT('ALSURFP:  PL,TL at Tau=100 INTERPOLATED'
     *         , ' FROM ALLARD TABULATED VALUES:')
        ELSE
           WRITE(ISHORT,74)
74         FORMAT('ALSURFP: PL,TL at T=TEFF,GL INTERPOLATED '
     *         , 'FROM ALLARD TABULATED VALUES:')
        ENDIF
        WRITE(ISHORT,75) TEFFL,GL,AT,AP
75      FORMAT(' ',10X,'LOG(Teffl) =',F10.5,', LOG(G) =',F10.5,
     x      ', LOG(T) =',F10.5,', Log(P) =',F10.5)
      ENDIF





      RETURN

 9999      continue
       write(*,*)
       write(*,*)'******** ALSURFP: Program Terminated ********'
       write(*,*)
       write(ISHORT,*)
       write(ISHORT,*)'******** ALSURF: Program Terminated ********'
       write(ISHORT,*)
       STOP     ! eliminate for testing

       END

C End if inputs are valid




