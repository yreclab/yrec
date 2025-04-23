C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C FUNC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE FUNC(X,G,S,R0,HS,AINT,Q,W2,A,I)

      use params, only : json
      use settings, only : CLN, C4PI, CC13  ! COMMON/CONST1/
      use settings, only : CGL  ! COMMON/CONST2/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION R0(JSON),HS(JSON)
      SAVE

      CS = DCOS(X)*DSIN(X)
      SS = DSIN(X)**2
C P2 = .5*(3COS(X)**2 - 1) = .5(3*(1-SIN(X)**2) - 1) = 1 - 1.5*SIN(X)**2
      P2 = 1.0D0 - 1.5D0*SS
C DERIVATIVES OF R0 WITH RESPECT TO R AND THETA
      QR0R = 1.0D0/(1.0D0 - 4.0D0*A*P2)
      QR0T = 3.0D0*CS*A*QR0R/(1.0D0 - A*P2)
C USE THE RELATION FOR R ON AN EQUIPOTENTIAL
      R = R0(I)*(1.0D0 - A*P2)
      R2 = R**2
      CONST = C4PI*CC13/(R2*R2)
C CALCULATE THE DERIVATIVES OF PHI WITH RESPECT TO R AND THETA
C D(PHI)/DR = GM/R2 + 12PI*G*P2*AINT/5R**4 -4PI*G*P2*Q*(DR0/DR)/5R**3
C -OMEGA**2*R*SIN(THETA)**2 - ASSUME DR0/DR = 1
      QPHIR=DEXP(CLN*(CGL+HS(I)))/R2 - CONST*P2*(3.0D0*AINT
     *     - R*Q*QR0R) - W2*R*SS
C D(PHI)/D(THETA) = 4PI*G*3DCOS(THETA)DSIN(THETA)*AINT/5R**4 -
C 4PI*G*P2*Q*DR0/D(THETA)/5R**4 - OMEGA**2*R*DCOS(THETA)SIN(THETA)
      QPHITH = CONST*(P2*Q*QR0T-3.0D0*AINT*CS) - W2*R*CS
      G = DSQRT(QPHIR**2 + QPHITH**2)
      S = C4PI*R*DSIN(X)*R0(I)*
     *     DSQRT((1.0D0-A*P2)**2 + (3.0D0*CS*A)**2)

      RETURN
      END
