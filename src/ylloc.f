C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C YLLOC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE YLLOC
C DBG 5/94 Modified to include ZRAMP and ZDIFF stuff (second opacity table)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4 (L)
      PARAMETER (NUMT=50)
      PARAMETER (NUMD=17)
      PARAMETER (NUMX=3)
      PARAMETER (NUMXT=NUMT*NUMX)
      PARAMETER (NUM4D=4*NUMD)
C MHP 10/02 made array dimensions consistent
      PARAMETER (NP=100)
      DIMENSION C(4,NP),XD(NUMD)
C      DIMENSION C(4,NUMD),XD(NUMD)
      COMMON /GLLOT/GRIDT(NUMT),GRIDX(NUMX),GRHOT3(NUMD)
      COMMON /LLOT/OPACITY(NUMXT,NUMD),NUMXM,NUMTM
      COMMON /LINTPL/ CFORD(NUMXT,NUM4D),NDS(NUMXT),NDD(NUMXT)
C DBG 5/94 different Z tables
      COMMON /GLLOT2/GRIDT2(NUMT),GRIDX2(NUMX),GRHOT32(NUMD)
      COMMON /LLOT2/OPACITY2(NUMXT,NUMD),NUMXM2,NUMTM2
      COMMON /LINTPL2/ CFORD2(NUMXT,NUM4D),NDS2(NUMXT),NDD2(NUMXT)
C OPACITY COMMON BLOCKS - modified 3/09
      COMMON /NEWOPAC/ZLAOL1,ZLAOL2,ZOPAL1,ZOPAL2, ZOPAL951,
     +       ZALEX1, ZKUR1, ZKUR2,TMOLMIN,TMOLMAX,LALEX06,
     +       LLAOL89,LOPAL92,LOPAL95,LKUR90,LALEX95,L2Z
      SAVE
      DO 1 IX=1,NUMXM
      DO 2 IT=1,NUMTM
       INDEX1=IT+(IX-1)*NUMTM
       JD=0
        IDS=1
        IDF=NUMD
        DO 3 ID=IDS,IDF
          CHKD=GRHOT3(ID)
          CHKO=OPACITY(IT+NUMT*(IX-1),ID)
C >>>> CHECK THE EMPTY REGION
          IF(CHKO.LE.-9.999D0)GO TO 3
          IF(JD.LE.0)THEN
             NDS(INDEX1)=ID
             IF(ID.NE.1)STOP ' CHECK NDS '
          ENDIF
          JD=JD+1
          XD(JD)=CHKD
C >>>> CHECK THE OPACITY VALUE IN THE TABLE
          C(1,JD)=CHKO
    3   CONTINUE
        NDD(INDEX1)=JD
        IF(JD.LE.1)GO TO 2
        CALL YSPLIN(XD,C,JD)
        DO 100 J=1,JD
        DO 200 I=1,4
         INDEX2=I+(J-1)*4
         CFORD(INDEX1,INDEX2)=C(I,J)
  200   CONTINUE
  100   CONTINUE
    2 CONTINUE
    1 CONTINUE
C
C DBG 5/94 ZRAMP stuff
      IF (L2Z) THEN
         DO IX=1,NUMXM2
            DO IT=1,NUMTM2
               INDEX1=IT+(IX-1)*NUMTM2
               JD=0
               IDS=1
               IDF=NUMD
               DO ID=IDS,IDF
                  CHKD=GRHOT32(ID)
                  CHKO=OPACITY2(IT+NUMT*(IX-1),ID)
                  IF(CHKO.LE.-9.999D0)GO TO 503
                  IF(JD.LE.0)THEN
                     NDS2(INDEX1)=ID
                     IF(ID.NE.1)STOP ' CHECK NDS2 '
                  ENDIF
                  JD=JD+1
                  XD(JD)=CHKD
                  C(1,JD)=CHKO
  503             CONTINUE
               ENDDO
               NDD2(INDEX1)=JD
               IF(JD.LE.1)GO TO 502
               CALL YSPLIN(XD,C,JD)
               DO J=1,JD
                  DO I=1,4
                     INDEX2=I+(J-1)*4
                     CFORD2(INDEX1,INDEX2)=C(I,J)
                  ENDDO
               ENDDO
  502          CONTINUE
            ENDDO
         ENDDO
      END IF

      RETURN
      END
