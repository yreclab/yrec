C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C QGAUSS
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE QGAUSS(G0G,GINVG,SPHIG,B,R0,HS,AINT,Q,W2,A,I)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 10/13/26 MHP via Claude: removed the unused COMMON/CONSTANTS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      DIMENSION R0(JSON),HS(JSON)
      DIMENSION X(5),W(5)
      DATA X/.14887433898163D0,.43339539412925D0,.67940956829902D0,
     *.86506336668899D0,.97390652851717D0/
      DATA W/.29552422471475D0,.26926671931D0,.21908636251598D0,
     *.14945134915058D0,.06667134430869D0/
      SAVE

      XM = 0.5D0*B
      XR = XM
      G0G = 0.0D0
      GINVG = 0.0D0
      SPHIG = 0.0D0
      DO 10 J = 1,5
       DX = XR*X(J)
       CALL FUNC(XM+DX,G,S,R0,HS,AINT,Q,W2,A,I)
       CALL FUNC(XM-DX,G2,S2,R0,HS,AINT,Q,W2,A,I)
       G0G = G0G+W(J)*(G*S+G2*S2)
       GINVG = GINVG+W(J)*(S/G+S2/G2)
       SPHIG = SPHIG+W(J)*(S+S2)
   10 CONTINUE
      G0G = G0G*XR
      GINVG = GINVG*XR
      SPHIG = SPHIG*XR
      RETURN
      END
