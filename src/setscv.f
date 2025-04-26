c     This is to evaluate the EOS with the new tables and call eqstat to
c     compute the new equation of state and compare to the old one...

      SUBROUTINE SETSCV

      use params, only : nts, nps
      use settings, only : XENV, ZENV  ! /COMP/
      use settings, only : CLN, CC13  ! /CONST1/
      use settings, only : CA3  ! /CONST2/
      use tables, only : TLOGX, TABLEX, TABLEY, SMIX, TABLEZ, TABLENV, NPTSX, IDP  ! /SCVEOS/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION ATOMWT(4),QR(3),FT(3),FTD(3),FP(3),FPD(3)
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      DATA CMH,CMHE,CBOLTZ/1.67357D-24,6.646442D-24,1.380658D-16/
      SAVE

C  READ IN EQUATION OF STATE TABLES FOR HYDROGEN AND HELIUM
      DO I = 1, NTS
         DO J = 1, NPTSX(I)
C  COMPUTE DU/DT - NEEDED FOR SPECIFIC HEAT DERIVATIVES
C  CP = T (DS/DT)|P = S(D LN S/D LN T)|P (EQ 1)
C AND CP = DU/DT + P*(D LN RHO/D LN T)**2/(RHO*T*D LN RHO/D LN P) (EQ 2)
C DU/DT CAN BE INFERRED FROM EQ 1 AND THE SECOND TERM IN EQ 2, ALL OF
C WHICH ARE CONTAINED IN THE TABLES.
            TABLEX(I,J,12) = EXP(CLN*TABLEX(I,J,5))*TABLEX(I,J,9) -
     *      EXP(CLN*(TABLEX(I,J,1)-TABLEX(I,J,4)-TLOGX(I)))*
     *      TABLEX(I,J,7)**2/TABLEX(I,J,8)
            TABLEY(I,J,12) = EXP(CLN*TABLEY(I,J,5))*TABLEY(I,J,9) -
     *      EXP(CLN*(TABLEY(I,J,1)-TABLEY(I,J,4)-TLOGX(I)))*
     *      TABLEY(I,J,7)**2/TABLEY(I,J,8)
C COMPUTE THE ENTROPY OF MIXING.
C NUMBER DENSITY OF HYDROGEN AND HELIUM
            Y = 1.0D0-XENV
            YM1 = 1.0D0 - Y
            DENX = EXP(CLN*TABLEX(I,J,4))
            DENY = EXP(CLN*TABLEY(I,J,4))
            DMIX = 1.0D0/(YM1/DENX + Y/DENY)
            HNUM = 2.0D0*YM1*DMIX/CMH/
     *             (1.0D0+3.0D0*TABLEX(I,J,2)+TABLEX(I,J,3))
            HENUM = 3.0D0*Y*DMIX/CMHE/
     *              (1.0D0 + 2.0D0*TABLEY(I,J,2) + TABLEY(I,J,3))
C HYDROGEN AND HELIUM ELECTRON NUMBER DENSITIES
            HNUME = 0.5D0*HNUM*(1.0D0 - TABLEX(I,J,2) - TABLEX(I,J,3))
            HENUME = CC13*HENUM*(2.0D0 - 2.0D0*TABLEY(I,J,2) -
     *               TABLEY(I,J,3))
            TOTE = HNUME + HENUME
            HNUME = MAX(HNUME,1.0D0)
            HENUME = MAX(HENUME,1.0D0)
            TOTE = MAX(TOTE,1.0D0)
            IF(HNUM .EQ. 0.0D0 .OR. HENUM .EQ. 0.0D0)THEN
               SMIX(I,J) = 0.0D0
            ELSE
               BE = (CMH/CMHE)*(Y/YM1)
               GA = 1.5D0*(1.0D0 + TABLEX(I,J,3)+ 3.0D0*
     *              TABLEX(I,J,2))/(1.0D0+2.0D0*TABLEY(I,J,2)+
     *              TABLEY(I,J,3))
               XD = 1.0D0 - TABLEX(I,J,2) - TABLEX(I,J,3)
               YD = 2.0D0 - 2.0D0*TABLEY(I,J,2) - TABLEY(I,J,3)
               IF(XD.GT.0.0D0)THEN
                 DE = 1.5D0*YD*BE*GA/XD
               ELSE
                 DE = 0.0D0
               ENDIF
               IF(YD.GT.0.0D0)THEN
                  DEI = XD/(1.5D0*YD*BE*GA)
               ELSE
                  DEI = 0.0D0
               ENDIF
               TNUM = HNUM + HENUM
               SMIX(I,J) = YM1/CMH*2.0D0/(1.0D0+TABLEX(I,J,3)+
     *         3.0D0*TABLEX(I,J,2))*(DLOG(1.0D0+BE*GA)-HNUME/TNUM*
     *         DLOG(1.0D0 + DE)+BE*GA*DLOG(1.0D0+1.0D0/BE/GA)-
     *         HENUME/TNUM*DLOG(1.0D0+DEI))
               SMIX(I,J) = CBOLTZ*SMIX(I,J)
            ENDIF
         END DO
      END DO
C  NOW COMPUTE EQUATION OF STATE VARIABLES FOR THE SURFACE MIXTURE.
      DO I=1,NTS
         TL = TLOGX(I)
         T = (10.0D0**TL)
C TEMPERATURE INTERPOLATION FACTORS
        IF(I.EQ.1)THEN
           IDT = 1
        ELSE IF(I.EQ.NTS)THEN
           IDT = I - 2
        ELSE
           IDT = I - 1
        ENDIF
        DO K = 1,3
           QR(K) = CLN*TLOGX(K+IDT-1)
        END DO
        TLN = CLN*TL
        CALL INTER3(QR,FT,FTD,TLN)
         DO J=1,NPTSX(I)
            PL = TABLEX(I,J,1)
            DL = TABLEX(I,J,4)
            X = XENV
            Z = ZENV
            Y = 1.0D0 - X - Z
            P = (10.0D0**PL)
C INCLUDE RADIATION PRESSURE IN THE EQUATION OF STATE.
            PRAD = CA3*(T**2)**2
            PGAS = P
            P = (P + PRAD)
            PL = LOG10(P)
C  DENSITY : ADD INVERSELY : 1/RHO = X/RHO(X) + Y/RHO(Y) + Z/RHO(Z)
            DENX = EXP(CLN*TABLEX(I,J,4))
            DENY = EXP(CLN*TABLEY(I,J,4))
            DENZ = EXP(CLN*TABLEZ(I,J,4))
            D = 1.0D0/(X/DENX + Y/DENY + Z/DENZ)
            DL = LOG10(D)
C D LN RHO/ D LN P = QDP
C FOR GAS PRESSURE QDP(TOT) = QDP(X)*X*RHO/RHO(X)+QDP(Y)*Y*RHO/RHO(Y)
C FOR RADIATION PRESSURE QDP = 0, SO QDP(TOT) = QDP(GAS)*P/PGAS
            QDP0 = TABLEX(I,J,8)*X*(D/DENX)+TABLEY(I,J,8)*Y*(D/DENY)
     *             + TABLEZ(I,J,13)*Z*(D/DENZ)
C D LN RHO/ D LN T = QDT (NOTE : D LN P/ D LN T = QPT)
C FOR GAS PRESSURE, CORRECT AS PER QDP
C FOR RADIATION PRESSURE, USE QDT = QDP*QPT.  CORRECT QPT FOR
C RADIATION PRESSURE AND USE THE CORRECTED QDP, QPT TO GET QDT.
            QDT0 = X*(D/DENX)*TABLEX(I,J,7)+Y*(D/DENY)*TABLEY(I,J,7)
     *             +Z*(D/DENZ)*TABLEZ(I,J,10)
            QPT0 = -QDT0/QDP0
            SX = EXP(CLN*TABLEX(I,J,5))
            SY = EXP(CLN*TABLEY(I,J,5))
C ENTROPY.  OBEYS ADDITIVE VOLUME RULE, BUT ALSO NEED TO INCLUDE THE
C ENTROPY OF MIXING.
            S0 = X*SX + Y*SY + SMIX(I,J)
            QSMIXT = FTD(1)*SMIX(IDT,J)+FTD(2)*SMIX(IDT+1,J)+
     *               FTD(3)*SMIX(IDT+2,J)
C D LN S/ D LN T
            QST0 = (X*SX*TABLEX(I,J,9) + Y*SY*TABLEY(I,J,9) +
     *              QSMIXT)/S0
C  CP = S*(D LN S/ D LN T)|P IS TABULATED. USE
C  CP = DU/DT + P*(D LN RHO/D LN T)**2/RHO/T/(D LN RHO/ D LN P)
C  TO INCLUDE THE EFFECTS OF RADIATION PRESSURE.
C CP (GAS PRESSURE ONLY).
            QCP0 = S0*QST0 + Z*(EXP(CLN*TABLEZ(I,J,7)) +
     *             PGAS*TABLEZ(I,J,10)**2/TABLEZ(I,J,13)/DENZ/T)
C NOW FIND DU/DT FROM THE ORIGINAL TABLE.
            QUT = QCP0 - PGAS*QDT0**2/QDP0/D/T
C NOW STORE THE RELEVANT VARIABLES IN A TABLE FOR THE ENVELOPE
C MIXTURE.
            TABLENV(I,J,1) = TABLEX(I,J,1)
            TABLENV(I,J,2) = DL
            TABLENV(I,J,3) = QDT0
            TABLENV(I,J,4) = QDP0
            TABLENV(I,J,5) = QCP0
            TABLENV(I,J,6) = QUT
         END DO
      END DO
C NOW FIND THE FOLLOWING DERIVATIVES NUMERICALLY :
C D QDT/ D LN T
C D QDT/ D LN P
C D LN CP / D LN P
C D LN CP / D LN T
C D LN DEL(AD) / D LN P
C D LN DEL(AD) / D LN T
      DO I = 1, NTS
C TEMPERATURE INTERPOLATION FACTORS
        IF(I.EQ.1)THEN
           IDT = 1
        ELSE IF(I.EQ.NTS)THEN
           IDT = I - 2
        ELSE
           IDT = I - 1
        ENDIF
        DO K = 1,3
           QR(K) = CLN*TLOGX(K+IDT-1)
        END DO
        TL = CLN*TLOGX(I)
        CALL INTER3(QR,FT,FTD,TL)
        T = EXP(TL)
        DO J = 1, NPTSX(I)
C PRESSURE INTERPOLATION FACTORS
           IF(J.EQ.1)THEN
              IDP = 1
           ELSE IF(J.EQ.NPTSX(I))THEN
              IDP = J - 2
           ELSE
              IDP = J - 1
           ENDIF
           DO K = 1,3
              QR(K) = CLN*TABLENV(I,IDP+K-1,1)
           END DO
           PL = CLN*TABLENV(I,J,1)
           CALL INTER3(QR,FP,FPD,PL)
C DERIVATIVES OF D LN RHO/ D LN T
           QDTP = TABLENV(I,IDP,3)*FPD(1)+TABLENV(I,IDP+1,3)*FPD(2)
     *           +TABLENV(I,IDP+2,3)*FPD(3)
           QDTT = TABLENV(IDT,J,3)*FTD(1)+TABLENV(IDT+1,J,3)*FTD(2)
     *           +TABLENV(IDT+2,J,3)*FTD(3)
C DERIVATIVES OF LN CP
           DO K = 1,3
              QR(K) = DLOG(TABLENV(I,IDP+K-1,5))
           END DO
           QCPP = QR(1)*FPD(1)+QR(2)*FPD(2)+QR(3)*FPD(3)
           DO K = 1,3
              ii = IDT+K-1
            jj = min(NPTSX(ii),j)
            QR(K) = DLOG(TABLENV(ii,jj,5))
           END DO
           QCPT = QR(1)*FTD(1)+QR(2)*FTD(2)+QR(3)*FTD(3)
C DERIVATIVES OF DU/DT
           DO K = 1,3
              ii = IDT+K-1
            jj = min(NPTSX(ii),j)
            QR(K) = TABLENV(ii,jj,6)
              QR(K) = TABLENV(IDT+K-1,J,6)
           END DO
           QAT = QR(1)*FTD(1)+QR(2)*FTD(2)+QR(3)*FTD(3)
           DO K = 1,3
              QR(K) = TABLENV(I,IDP+K-1,6)
           END DO
           QAP = QR(1)*FPD(1)+QR(2)*FPD(2)+QR(3)*FPD(3)
C D/D LN RHO (D LN P/D LN RHO)
           DO K = 1,3
              QR(K) = CLN*TABLENV(I,IDP+K-1,2)
           END DO
           DLN = CLN*TABLENV(I,J,2)
           CALL INTER3(QR,FP,FPD,DLN)
           QPDD = FPD(1)/TABLENV(I,IDP,4)+FPD(2)/TABLENV(I,IDP+1,4)
     *           +FPD(3)/TABLENV(I,IDP+2,4)
           TABLENV(I,J,7) = QDTP
           TABLENV(I,J,8) = QDTT
           TABLENV(I,J,9) = QPDD
           TABLENV(I,J,10) = QCPT
           TABLENV(I,J,11) = QAP
           TABLENV(I,J,12) = QAT
        END DO
      END DO

      RETURN
      END
