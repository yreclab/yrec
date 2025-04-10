   
C***********************************************************************
      BLOCK DATA
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MX=5,MV=10,NR=77,NT=56)
      COMMON/AA/ Q(4),H(4),XXH
      COMMON/A/  XZ(MX,MV,NT,NR),  
     .T6LIST(NR,NT),RHO(NR),T6A(NT),ESK(NT,NR),ESK2(NT,NR),DFSX(MX),
     . DFS(NT),DFSR(NR),XA(MX),M,MF
      COMMON/B/ ZZ(MX),IRI(10),INDEX(10),NTA(NR)
      DATA (XA(I),I=1,MX)/0.0D0,0.2D0,0.4D0,0.6D0,0.8D0/
      DATA (NTA(I),I=1,NR)/37*56,7*54,
     X 39,37,36,34,33,31,31,30,29,28,27,26,26,25,24,23,22,21,21,20,
     X 19,18,17,16,15,15,13,13,11,11,9,9,7/
      DATA (INDEX(I),I=1,10)/1,2,3,4,5,6,7,8,9,10/
      SAVE
      END
