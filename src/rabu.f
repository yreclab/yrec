C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C RABU
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE RABU(IR,NCHEM0,NCHEM,ATWT,ABUN,ABFRCS,GASMU)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION ATWT(NCHEM0),ABUN(NCHEM0),ABFRCS(NCHEM0)
C 10/13/26 MHP via Claude: removed the unused COMMON/NMLPAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      SAVE
C     NCHEM,ATWT,ABUN,ABFRCS ARE OUTPUT
C     READ(IR,99) NCHEM,(ATWT(IC),ABUN(IC),ABFRCS(IC),
C    1       IC=1,NCHEM),GASMU
      READ(IR   ) NCHEM,(ATWT(IC),ABUN(IC),ABFRCS(IC),
     1       IC=1,NCHEM),GASMU
      IF(NCHEM0.LT.NCHEM) THEN
         STOP
      END IF
      RETURN
C  99   FORMAT(1X,I5,(/1X,3E15.7))
C 9009  FORMAT(' ERROR IN RABU. NCHEM READ FROM TABLE IS',
C      1 ' BIGGER THAN THE VALUE USED IN THE COMMONS.',
C      2 ' NCHEM0,NCHEM= ',/1X,2I8)
      END
