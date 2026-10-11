C      Subroutine ALPRINT

C PURPOSE
C To print the internal Allard-format tables and auxilliary information provided
C by ALFILEIN and verified by ALTABINIT.



      SUBROUTINE ALPRINT

      PARAMETER(NTA=250,NGA=25)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)
      LOGICAL*4 LALTPTau100
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      COMMON/IOUNITS/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,
     *  IOWR,IFIRST,IRUN,ISTAND,IFERMI,IOPMOD,IOPENV,IOPATM,ISNU,
     *  IALEX06,ICLCD,IJLAST,IOPUREZ,IcondOpacP,ILIV95,IOATM,IOATMA,
     *  IOPALE,ISCVH,ISCVHE,ISCVZ
      COMMON /ALATM01/ TEFFLs(NTA),GLs(NGA),FeHs(NGA),      ! Shared: ALFILEIN, ALTABINIT and ALSURFP
     x   ALPHAs(NGA),PLs(NTA,NGA),P100Ls(NTA,NGA),T100Ls(NTA,NGA),
     x   LOldNextGen,nTEFF,nGL,nFeH,nALPHA
      COMMON /ALATM02/ GLmin(NTA),GLmax(NTA),IGLmin(NTA),      ! Shared: ALTABINIT and ALSURFP
     x   IGLmax(NTA),TEFFLmin,TEFFLmax,GLXmin,GLXmax
      COMMON/ALATM03/ALATM_FeH,ALATM_Alpha,LALTPTau100
C MHP 8/25 Removed character file names from common block
      COMMON /ALATM04/ DUMMY1,DUMMY2,DUMMY3,DUMMY4

      SAVE

      TEFFLmin = TEFFLs(1) - (TEFFLs(2)-TEFFLs(1))
      TEFFLmax = TEFFLs(nTeff) + (TEFFLs(nTeff)-TEFFLs(nTeff-1))

      write(ISHORT,*)
      write(ISHORT,*)' **************** Allard Table  ***************'
      write(ISHORT,*)
      write(ISHORT,*)'nTeff= ',nTeff,' ,nGL=',nGL
      write(ISHORT,*)'nFeH= ',nFeH,' ,nAlpha=',nAlpha
      write(ISHORT,*)
      write(ISHORT,*)'TEFFLmin= ',TEfflmin,' ,TEFFLmax= ',Tefflmax
      write(ISHORT,*)'GLXmin=',GLXmin,' GLXmax=',GLXmax
      write(ISHORT,*)
      write(ISHORT,900)' PL @ Teff','GL ->',(GLs(j),j=1,nGL)
 900      format(A10,16X,A,20(5X,F6.2,5X))
      write(ISHORT,*)
      write(ISHORT,*) 'PL at Teff,GL'
      write(ISHORT,*)
      do i = 1, nTeff
         write(ISHORT,910) i,10D0**TEFFLs(i),iGLmin(i),iGLmax(i),
     x       GLmin(i),GLmax(i),(PLs(i,j),j=1,nGL)
 910     Format(I5,F6.0,2I4,2F6.2,1P20E16.8)
      enddo
      write(ISHORT,*)
      write(ISHORT,*) 'PL at Tau=100'
      write(ISHORT,*)
      do i = 1, nTeff
         write(ISHORT,910) i,10D0**TEFFLs(i),iGLmin(i),iGLmax(i),
     x       GLmin(i),GLmax(i),(P100Ls(i,j),j=1,nGL)
      enddo
      write(ISHORT,*)
      write(ISHORT,*) 'TL at Tau=100'
      write(ISHORT,*)
      do i = 1, nTeff
         write(ISHORT,910) i,10D0**TEFFLs(i),iGLmin(i),iGLmax(i),
     x       GLmin(i),GLmax(i),(T100Ls(i,j),j=1,nGL)
      enddo
      write(ISHORT,*)


       END

