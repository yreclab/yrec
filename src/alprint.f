C      Subroutine ALPRINT

C PURPOSE
C To print the internal Allard-format tables and auxilliary information provided
C by ALFILEIN and verified by ALTABINIT.



      SUBROUTINE ALPRINT
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ALATM02/ into ALATM02_MOD.
      USE ALATM02_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ALATM01/ into ALATM01_MOD.
      USE ALATM01_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD

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
C 10/13/26 MHP via Claude: removed the unused COMMON/NMLPAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 8/25 Removed character file names from common block
C 10/13/26 MHP via Claude
C code changed to remove COMMON/ALATM04/: its four members DUMMY1..DUMMY4
C are placeholders that no file references in executable code.  Removing
C it also retires the hazard behind the earlier alfilein.f fix, where a
C mis-indented EXTERNAL was absorbed into this declaration and renamed
C DUMMY4.

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

