C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C TRAPZD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE TRAPZD(B1,B2,S,N,RHO,RHOP,SM,SMP,W2,W2P,ETA22,
     *ETA22P,Q,QP,I)
      use settings, only : CLN  ! COMMON/CONST1/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      SAVE
      R0 = B2
      R03 = R0**3
      IF(N.EQ.1) THEN
C  AINT = INT(0=>R0) (RHO/M)*R0'**7*OMEGA**2*(5+ETA2)/(2+ETA2) DR0'
C  Q IS THE INTEGRAND (RO'**7,ETC.) EVALUATED AT R0(I)
C  AINT AND ITS DERIVATIVES W/R/TO R AND THETA ARE NEEDED TO FIND <G>
	 Q = (RHO*W2*R03*(3.0D0+ETA22)/(SM*ETA22))*R03*R0
C        Q(I) = DEXP(CLN*(HD(I)-HS(I)))*OMEGA(I)**2*R0(I)**6
C    *   *(5.0D0+ETA2(I))/(2.0D0+ETA2(I))
	 S = 0.5D0*(B2-B1)*(QP+Q)
	 IT = 1
      ELSE
	 TNM = DFLOAT(IT)
	 DR = B2 - B1
	 DEL = DR/TNM
	 Y = B1 + 0.5D0*DEL
	 SUM = 0.0D0
	 DRHO = (RHO - RHOP)/DR
	 DM = (SM - SMP)/(B2**2 - B1**2)
	 DETA2 = (ETA22 - ETA22P)/DR
	 DW2 = (W2 - W2P)/DR
	 DO 10 J = 1,IT
	    R03T = Y**3
C INTERPOLATE RHO,M,OMEGA,ETA2+2 BETWEEN SHELL I AND SHELL I-1
	    RHOT = RHOP+DRHO*DEL
	    SMT = SMP+DM*(Y**2 - B1**2)
	    W2T = W2P + DW2*DEL
	    ETA22T = ETA22P + DETA2*DEL
C CALCULATE Q BETWEEN SHELLS
	    Q0 = (RHOT*W2T*R03T*(3.0D0+ETA22T)/(SMT*ETA22T))*R03T*Y
C Q0 = RHO*W2*R07T*(3.0D0+ETA22)/(SM*ETA22)
	    SUM = SUM + Q0
	    Y = Y+DEL
 10      CONTINUE
	 S = 0.5D0*(S+DEL*SUM)
	 IT = IT*2
      ENDIF

      RETURN
      END
