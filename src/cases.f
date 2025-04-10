
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CASES
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE CASES(P1,P2,M1,M2,Q1,Q2,E1,E2,V1,V2,W1,W2,Z1,Z2,
     *                 Y1,Y2,NCASE)
C
C                                 SHAPE PRESERVING QUADRATIC SPLINES
C                                   BY D.F.MCALLISTER & J.A.ROULIER
C                                     CODED BY S.L.DODD & M.ROULIER
C                                       N.C. STATE UNIVERSITY
C
      REAL*8 P1,P2,M1,M2,Q1,Q2,V1,V2,Z1,Z2,W1,W2,E1,E2,
     *     MBAR1,MBAR2,MBAR3,C1,D1,H1,J1,Y1,Y2,K1,ZTWO
C
C CASES COMPUTES THE KNOTS AND OTHER PARAMETERS OF THE SPLINE ON THE
C INTERVAL (P1,Q1).
C
C
C ON INPUT--
C
C   (P1,P2) AND (Q1,Q2) ARE THE COORDINATES OF THE POINTS OF
C   INTERPOLATION.
C
C   M1 IS THE SLOPE AT (P1,P2).
C
C   M2 IS THE SLOPE AT (Q1,Q2)
C
C   NCASE CONTROLS THE NUMBER AND LOCATION OF THE KNOTS.
C
C
C ON OUTPUT--
C
C   (V1,V2),(W1,W2),(Z1,Z2), AND (E1,E2) ARE THE COORDINATES OF THE
C   KNOTS AND OTHER PARAMETERS OF THE SPLINE ON (P1,Q1). (E1,E2)
C   AND (Y1,Y2) ARE USED ONLY IF NCASE=4.
C
C AND
C
C   CASES DOES NOT ALTER P1,P2,M1,M2,Q1,Q2.
C
C----------------------------------------------------------------------
C
      save

      IF ((NCASE .EQ. 3).OR.(NCASE .EQ. 4)) GO TO 20
      IF (NCASE .EQ. 2) GO TO 10
C
C CALCULATE THE PARAMETERS FOR CASE 1.
      Z1=(P2-Q2+M2*Q1-M1*P1)/(M2-M1)
      ZTWO=P2+M1*(Z1-P1)
      V1=(P1+Z1)/2.D0
      V2=(P2+ZTWO)/2.D0
      W1=(Z1+Q1)/2.D0
      W2=(ZTWO+Q2)/2.D0
      Z2=V2+((W2-V2)/(W1-V1))*(Z1-V1)
      RETURN
C
C CALCULATE THE PARAMETERS FOR CASE 2.
  10  Z1=(P1+Q1)/2.D0
      V1=(P1+Z1)/2.D0
      V2=P2+M1*(V1-P1)
      W1=(Z1+Q1)/2.D0
      W2=Q2+M2*(W1-Q1)
      Z2=(V2+W2)/2.D0
      RETURN
C
C CALCULATE THE PARAMETERS USED IN BOTH CASES 3 AND 4.
  20  C1=P1+(Q2-P2)/M1
      D1=Q1+(P2-Q2)/M2
      H1=2.D0*C1-P1
      J1=2.D0*D1-Q1
      MBAR1=(Q2-P2)/(H1-P1)
      MBAR2=(P2-Q2)/(J1-Q1)
C
      IF (NCASE .EQ. 4) GO TO 50
C
C CALCULATE THE PARAMETERS FOR CASE 3.
      K1=(P2-Q2+Q1*MBAR2-P1*MBAR1)/(MBAR2-MBAR1)
      IF (ABS(M1) .GT. ABS(M2)) GO TO 30
      Z1=(K1+Q1)/2.D0
      GO TO 40
  30  Z1=(K1+P1)/2.D0
  40  V1=(P1+Z1)/2.D0
      V2=P2+M1*(V1-P1)
      W1=(Q1+Z1)/2.D0
      W2=Q2+M2*(W1-Q1)
      Z2=V2+((W2-V2)/(W1-V1))*(Z1-V1)
      RETURN
C
C CALCULATE THE PARAMETERS FOR CASE 4.
  50  Y1=(P1+C1)/2.D0
      V1=(P1+Y1)/2.D0
      V2=M1*(V1-P1) + P2
      Z1=(D1+Q1)/2.D0
      W1=(Q1+Z1)/2.D0
      W2=M2*(W1-Q1) + Q2
      MBAR3=(W2-V2)/(W1-V1)
      Y2=MBAR3*(Y1-V1) + V2
      Z2=MBAR3*(Z1-V1) + V2
      E1=(Y1+Z1)/2.D0
      E2=MBAR3*(E1-V1) + V2
      RETURN
C
      END
