C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SIMEQC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SIMEQC(A,M,N)

      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(56)
      SAVE

      JJ=-N
      DO 65 J=1,N
      JY=J+1
      JJ=JJ+N+1
      BIGA=0.0D0
      IT=JJ-J
      DO 30 I=J,N
      IJ=IT+I
      IF(DABS(BIGA).GE.DABS(A(IJ))) GO TO 30
      BIGA=A(IJ)
      IMAX=I
   30 CONTINUE
      IF(DABS(BIGA).EQ.0.0D0) GOTO 1010
      GOTO 1012
 1010 WRITE (5,1011)
 1011 FORMAT (1X,'STOPPED AT 1010')
      STOP29
 1012 IA=J+N*(J-2)
      IT=IMAX-J
      DO 50 K=J,M
      IA=IA+N
      IB=IA+IT
      SAVE=A(IA)
      A(IA)=A(IB)
      A(IB)=SAVE
      A(IA)=A(IA)/BIGA
   50 CONTINUE
      IF(J.EQ.N) GO TO 70
      IA=N*(J-1)
      DO 64 IX=JY,N
      IB=IA+IX
      IT=J-IX
      DO 60 JX=JY,M
      IC=N*(JX-1)+IX
      ID=IC+IT
      A(IC)=A(IC)-A(IB)*A(ID)
   60 CONTINUE
   64 CONTINUE
   65 CONTINUE
   70 NY=N-1
      IT=N*N
      DO 85 J=1,NY
      IA=IT-J
      IC=N*M
      IB=IC-J
      DO 80 K=1,J
      A(IB)=A(IB)-A(IA)*A(IC)
      N1=M-1
      IG=IB
      IH=IC
   75 IF(N1.LE.N) GO TO 78
      IG=IG-N
      IH=IH-N
      A(IG)=A(IG)-A(IA)*A(IH)
      N1=N1-1
      GO TO 75
   78 IA=IA-N
      IC=IC-1
   80 CONTINUE
   85 CONTINUE
      RETURN
      END
