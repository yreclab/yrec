C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CONVEC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE CONVEC(HCOMP,HD,HP,HR,HS,HT,LC,M,MRZONE,MXZONE,MXZON0,
     *                  JCORE,JENV,NRZONE,NZONE,NZONE0)
      PARAMETER (JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/DPMIX/DPENV,ALPHAC,ALPHAE,ALPHAM,BETAC,IOV1,IOV2,
     *      IOVIM, LOVSTC, LOVSTE, LOVSTM, LSEMIC, LADOV, LOVMAX
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR

      DIMENSION HCOMP(15,JSON),HD(JSON),HP(JSON),HR(JSON),HS(JSON),
     *          HT(JSON),LC(JSON),MRZONE(13,2),MXZONE(12,2),MXZON0(12,2)
      SAVE
C CONVEC DETERMINES THE BOUNDARIES OF CONVECTIVE REGIONS WITH AND
C    WITHOUT OVERSHOOT.
C *IMPORTANT NOTE*
C IN THE EVOLUTION CODE, OVERSHOOT IS ASSUMED TO BE OVERMIXING :
C    SHELLS IN THE OVERSHOOT REGION ARE MIXED WITH THE ADJACENT CONVECTION
C    ZONE, BUT STILL USE THE RADIATIVE TEMPERATURE GRADIENT.
C
C INPUT VARIABLES :
C
C HCOMP,HD,HP,HR,HS,HT : MASS FRACTIONS OF SPECIES, AND RUN OF
C    DENSITY,PRESSURE,RADIUS, MASS, AND TEMPERATURE RESPECTIVELY.
C    USED TO DETERMINE THE EXTENT OF OVERSHOOT REGIONS.
C LC : FLAG THAT IS T IF A SHELL IS CONVECTIVE AND F IF IT IS RADIATIVE.
C LOVSTC,LOVSTE,LOVSTM : FLAGS SET T IF OVERSHOOT IS TO BE COMPUTED FOR
C    CENTRAL, SURFACE, AND INTERMEDIATE CONVECTION ZONES RESPECTIVELY.
C M : NUMBER OF SHELLS IN THE MODEL.
C
C OUTPUT VARIABLES :
C 
C JCORE, JENV : IDS OF THE EDGES OF THE SURFACE AND CENTRAL CONVECTION
C    ZONES RESPECTIVELY. JCORE=1 AND JENV=M IF THE ZONES IN QUESTION
C    DON'T EXIST.
C MXZON0,MXZONE : ARRAYS GIVING THE STARTING AND ENDING SHELLS IN MIXED
C    REGIONS.  MXZON0 REFERS TO THE BOUNDARIES WITHOUT OVERSHOOT, AND
C    MXZONE REFERS TO THE BOUNDARIES WITH OVERSHOOT.  THE ZONES ARE STORED
C    IN PAIRS, I.E. ELEMENTS (3,1) AND (3,2) ARE THE FIRST AND LAST
C    MIXED SHELLS IN THE THIRD CONVECTION ZONE OUT FROM THE CENTER.
C NZONE,NZONE0 : NUMBER OF DISTINCT MIXED REGIONS WITH AND WITHOUT
C    OVERSHOOT.  THEY CAN BE DIFFERENT BECAUSE OVERSHOOT CAN CAUSE TWO
C    NEARBY CONVECTION ZONES TO MERGE.
C MRZONE,NRZONE : THE LOCATIONS OF RADIATIVE REGIONS AND THE NUMBER OF
C    CONTIGUOUS RADIATIVE REGIONS.  NEEDED BECAUSE MIX TREATS BURNING
C    IN RADIATIVE AND CONVECTIVE REGIONS DIFFERENTLY.  THESE ARE DEFINED IN
C    THE SAME WAY AS THE ANALOGOUS CONVECTIVE VARIABLES.
C
C LOCATE BOUNDARIES OF STANDARD CONVECTION ZONES

      J = 1
      LCC = .FALSE.
      LC(M+1) = .FALSE.
      DO 11 I = 1,M + 1
         IF(.NOT.LC(I)) GO TO 10
C CONVECTION ZONE
         IF(LCC) GO TO 11
C START OF CONVECTION ZONE
         LCC = .TRUE.
         I1 = I
         GO TO 11
   10    IF(.NOT.LCC) GO TO 11
C   END OF CONVECTION ZONE
         LCC = .FALSE.
         IF(I1.NE.I-1)THEN
            MXZONE(J,1) = I1
            MXZONE(J,2) = I - 1
            J = J + 1
         ENDIF
         IF(J.LT.12) GO TO 11
         WRITE(ISHORT,661)
  661    FORMAT(' -----TOO MANY MIX ZONES')
         GO TO 12
   11 CONTINUE
   12 CONTINUE

C MHP 5/91 LOGIC CHANGE TO AVOID PROBLEMS IF NO CZ IN MODEL(NZONE=0)
C SKIP REST OF SR IF THERE ARE NO CONVECTION ZONES.
      IF(J.EQ.1)THEN
         JCORE = 1
         JENV = M
         NZONE0 = 0
         NZONE = 0
         NRZONE = 1
         MRZONE(1,1) = 1
         MRZONE(1,2) = M
         GOTO 9999
      ENDIF
      NZONE = J-1
      DO 20 I = 1,NZONE
         MXZON0(I,1) = MXZONE(I,1)
         MXZON0(I,2) = MXZONE(I,2)
   20 CONTINUE
      NZONE0 = NZONE
C FIND OUTER EDGE OF THE CONVECTIVE CORE (JCORE) AND INNER EDGE OF THE 
C CONVECTIVE ENVELOPE (JENV) BEFORE OVERSHOOT.
      IF(MXZONE(1,1).EQ.1) THEN
C CENTRAL CONVECTION ZONE EXISTS IF TRUE.
         IF(MXZONE(1,2).EQ.M)THEN
C FULLY CONVECTIVE STAR IF TRUE.
            JCORE = 1
            JENV = 1
            NRZONE = 0
            GOTO 9999
         ELSE
            JCORE = MXZONE(1,2)
         ENDIF
      ELSE
         JCORE = 1
      ENDIF
      IF(MXZONE(NZONE,2).EQ.M) THEN
C SURFACE CONVECTION ZONE EXISTS IF TRUE.
         JENV = MXZONE(NZONE,1)
      ELSE
         JENV = M
      ENDIF
C  ADD CONVECTIVE OVERSHOOT IF NEEDED; THE SIZE OF THE OVERSHOOT REGION IS
C  COMPUTED AND THE EDGES IN MXZONE ARE MOVED TO THE EDGES OF THE
C  OVERSHOOT REGIONS.
      IF(.NOT.LOVSTC .AND. .NOT.LOVSTE .AND. .NOT.LOVSTM) GOTO 100
      CALL OVERSH(HCOMP,HD,HP,HR,HS,HT,M,MXZONE,MXZON0,NZONE)
C  CHECK FOR MERGERS OF NEARBY CONVECTION ZONES CAUSED BY OVERSHOOT.
      IF(NZONE.EQ.1)GOTO 100
      J = 1
   85 CONTINUE
C  CHECK IF 'TOP' OF ONE REGION IS ABOVE 'BOTTOM' OF THE NEXT ONE.
      IF(MXZONE(J,2).GE.MXZONE(J+1,1))THEN
C  IF THIS OCCURS, TWO CONVECTION ZONES HAVE MERGED.
         WRITE(ISHORT,93)((MXZONE(K,K1),K1=1,2),K=J,J+1),MXZONE(J,1),
     *              MXZONE(J+1,2)
   93    FORMAT(2X,'CONVECTION ZONES MERGED DUE TO OVERSHOOT'/2X,
     *          'OLD',2('[',I3,'-',I3,']'),' NEW','[',I3,'-',I3,']')
         MXZONE(J+1,1) = MXZONE(J,1)
         DO 90 K = J,NZONE-1
            DO 95 J2 = 1,2
               MXZONE(K,J2) = MXZONE(K+1,J2)
   95       CONTINUE
   90    CONTINUE
         NZONE = NZONE - 1
         IF(J.LE.NZONE-1)THEN
            GOTO 85
         ELSE
            GOTO 100
         ENDIF
      ENDIF
      J = J + 1
      IF(J.LE.NZONE-1) GOTO 85
  100 CONTINUE
C NOW DETERMINE THE NUMBER OF RADIATIVE REGIONS.
C CHECK FOR A RADIATIVE REGION BELOW THE FIRST CONVECTION ZONE.
      IF(MXZONE(1,1).GT.1)THEN
         NRZONE = 1
         MRZONE(1,1) = 1
         MRZONE(1,2) = MXZONE(1,1)-1
      ELSE
         NRZONE = 0
      ENDIF
C LOCATE ALL RADIATIVE REGIONS BETWEEN CONVECTION ZONES.
      IF(NZONE.GT.1)THEN
         DO 110 I = 1, NZONE-1
            NRZONE = NRZONE + 1
            MRZONE(NRZONE,1) = MXZONE(I,2) + 1
            MRZONE(NRZONE,2) = MXZONE(I+1,1) - 1
  110    CONTINUE
      ENDIF
C CHECK FOR A RADIATIVE REGION ABOVE THE LAST CONVECTION ZONE.
      IF(MXZONE(NZONE,2).LT.M)THEN
         NRZONE = NRZONE + 1
         MRZONE(NRZONE,1) = MXZONE(NZONE,2) + 1
         MRZONE(1,2) = M
      ENDIF
 9999 CONTINUE

      RETURN
      END
