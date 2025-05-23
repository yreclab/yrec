C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C SETLLO
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE SETLLO
C DBG 5/94 Modified to read in second opacity table at different Z

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4 (L)
      PARAMETER (NUMT=50)
      PARAMETER (NUMD=17)
      PARAMETER (NUMX=3)
      PARAMETER (NUMXT=NUMT*NUMX)
      DIMENSION GRIDY(NUMX),GRIDZ(NUMX)
      PARAMETER (CONST=11604.5D0)
      CHARACTER*256 FLAOL2, FOPAL2
      CHARACTER*256 FLAST, FFIRST, FRUN, FSTAND, FFERMI,
     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
     3    FLLDAT, FSNU, FSCOMP, FKUR, 
     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
      COMMON/LUNUM/IFIRST, IRUN, ISTAND, IFERMI,
     1    IOPMOD, IOPENV, IOPATM, IDYN,
     2    ILLDAT, ISNU, ISCOMP, IKUR
      COMMON/LUFNM/ FLAST, FFIRST, FRUN, FSTAND, FFERMI,
     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
     3    FLLDAT, FSNU, FSCOMP, FKUR, 
     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
C GRID ENTRIES FOR TEMPERATURE, AND ABUNDANCE (X)
      COMMON /GLLOT/GRIDT(NUMT),GRIDX(NUMX),GRHOT3(NUMD)
C LL OPACITY
      COMMON /LLOT/OPACITY(NUMXT,NUMD),NUMXM,NUMTM
C DBG 5/94 for different Z
      COMMON /GLLOT2/GRIDT2(NUMT),GRIDX2(NUMX),GRHOT32(NUMD)
      COMMON /LLOT2/OPACITY2(NUMXT,NUMD),NUMXM2,NUMTM2
C
      COMMON/GRAVS3/FGRY,FGRZ,LTHOUL,LDIFZ
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *             IOLAOL2, IOOPAL2, NK,
     *             LZRAMP, FLAOL2, FOPAL2
C OPACITY COMMON BLOCKS - modified 3/09
      COMMON /NEWOPAC/ZLAOL1,ZLAOL2,ZOPAL1,ZOPAL2, ZOPAL951,
     +       ZALEX1, ZKUR1, ZKUR2,TMOLMIN,TMOLMAX,LALEX06,  
     +       LLAOL89,LOPAL92,LOPAL95,LKUR90,LALEX95,L2Z 
      SAVE

CC OPEN TABLE
      OPEN(UNIT=ILLDAT,FILE=FLLDAT)
      DO 10 I=1,NUMX
CC READ GRID POINT FOR ABUNDANCE
CC READ NUMBER OF GRIDS FOR DENSITY, AND TEMPERATURE
        READ(ILLDAT,190,END=97)GRIDX(I),GRIDZ(I)
        GRIDY(I)=1.0D0-GRIDX(I)-GRIDZ(I)
  190    FORMAT(33X,F7.4,2X,F7.4)
         READ(ILLDAT,'()')
CC READ  LOG(DENSITY/TEMPERATURE**3)
            READ(ILLDAT, 200)(GRHOT3(ID), ID=1, NUMD)
  200    FORMAT (6X, 17F7.1)
C         READ(ILLDAT,'()')
CC READ GRID VALUES FOR TEMPERATURE, AND OPACITY TABLE
         DO 20 K=1, NUMT
         READ(ILLDAT,196,END=93)GRIDTK,
     +          (OPACITY(K+(I-1)*NUMT,ID),ID=1,NUMD)
         GRIDT(K)=DLOG10(GRIDTK)
   20    CONTINUE
   93    NUMTM=K-1
  196    FORMAT(18F7.3)
C         READ(ILLDAT,'()')
C
   10 CONTINUE
CC CLOSE THE TABLE WE HAVE READ
   97 CLOSE(ILLDAT,ERR=99)
      NUMXM=I-1
C
C DBG 5/94 Second Opacity Table read here
      IF (L2Z) THEN
         OPEN(UNIT=IOOPAL2,FILE=FOPAL2)
         DO 510 I=1,NUMX
            READ(IOOPAL2,190,END=597)GRIDX2(I),GRIDZ(I)
            GRIDY(I)=1.0D0-GRIDX2(I)-GRIDZ(I)
            READ(IOOPAL2,'()')
            READ(IOOPAL2, 200)(GRHOT32(ID), ID=1, NUMD)
            DO 520 K=1, NUMT
               READ(IOOPAL2,196,END=593)GRIDTK,
     +          (OPACITY2(K+(I-1)*NUMT,ID),ID=1,NUMD)
               GRIDT2(K)=DLOG10(GRIDTK)
  520       CONTINUE
  593       NUMTM2=K-1
  510    CONTINUE
  597    CLOSE(IOOPAL2,ERR=99)
         NUMXM2=I-1
      END IF
C
      CALL YLLOC

      RETURN
   99 STOP 'ERROR IN FILE CLOSING'
      END
