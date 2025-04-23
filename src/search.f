C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SEARCH
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SEARCH(XTAB,NUM,S,LCN,FND)
C
C                                 SHAPE PRESERVING QUADRATIC SPLINES
C                                   BY D.F.MCALLISTER & J.A.ROULIER
C                                     CODED BY S.L.DODD & M.ROULIER
C                                       N.C. STATE UNIVERSITY
C
      use params, only : json
      REAL*8 XTAB(JSON),S
      INTEGER FND,FIRST
C
C SEARCH CONDUCTS A BINARY SEARCH FOR S. SEARCH IS CALLED ONLY IF S IS
C BETWEEN XTAB(1) AND XTAB(NUM).
C
C ON INPUT--
C
C   XTAB CONTAINS THE ABSCISSAS OF THE DATA POINTS OF INTERPOLATION.
C
C   NUM IS THE DIMENSION OF XTAB
C
C   S IS THE VALUE WHOSE RELATIVE POSITION IN XTAB IS LOCATED BY SEARCH.
C
C
C ON OUTPUT--
C
C   FND IS SET EQUAL TO 1 IF S IS FOUND IN XTAB AND IS SET EQUAL TO 0
C   OTHERWISE.
C
C   LCN IS THE INDEX OF THE LARGEST VALUE IN XTAB FOR WHICH XTAB(I)
C   .LT. S.
C
C AND
C
C   SEARCH DOES NOT ALTER XTAB,NUM,S.
C
C----------------------------------------------------------------------
C
      save

      FIRST=1
      LAST=NUM
      FND=0
C
      IF (XTAB(1) .NE. S) GO TO 10
      LCN=1
      FND=1
      RETURN
C
  10  IF (XTAB(NUM) .NE. S) GO TO 20
      LCN=NUM
      FND=1
      RETURN
C
C IF (LAST-FIRST) .EQ. 1, S IS NOT IN XTAB.  SET POSITION EQUAL TO
C FIRST.
  20  IF ((LAST-FIRST) .EQ. 1) GO TO 30
C
      MIDDLE=(FIRST+LAST)/2
C
C CHECK IF S .EQ. XTAB(MIDDLE). IF NOT, CONTINUE THE SEARCH IN THE
C APPROPRIATE HALF OF THE VECTOR XTAB.
      IF (XTAB(MIDDLE) - S) 40,50,60
C
  30  LCN=FIRST
      RETURN
  40  FIRST=MIDDLE
      GO TO 20
  50  LCN=MIDDLE
      FND =1
      RETURN
  60  LAST=MIDDLE
      GO TO 20
      END
