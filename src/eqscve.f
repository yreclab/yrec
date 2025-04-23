C SUBROUTINE FOR INTERPOLATING IN THE SURFACE ABUNDANCE TABLE OF THE SCV
C EQUATION OF STATE.
      SUBROUTINE EQSCVE(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *AMU,EMU,ETA,QDT,QDP,QCP,DELA,LCALC)
      use params, only : nts, nps
      use settings, only : CLN  ! COMMON/CONST1/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C MHP  5/97 ADDED COMMON BLOCK FOR SCV EOS TABLES
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *     TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *     TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDT,IDP
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
C REPLACE 4-PT LAGRANGE INTERPOLATE WITH 4-PT NATURAL SPLINE
C      DIMENSION ATOMWT(4),QR(4),FT(4),FTD(4),
C     *     FP(4),FPD(4),TEMPT(5),TEMP(4,5),FXION(3)
      DIMENSION FP(4),FPD(4),FT(4),FTD(4)
      DIMENSION ATOMWT(4),QR(4),YTAB(4),Y2(4),
     *     TEMPT(5),TEMP(4,5),FXION(3),TEMPT1(5),TEMPT2(5),
     *     TEMPT3(5),TEMPT1T(5),TEMPT2P(5)
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      DATA CMH,CMHE,CBOLTZ/1.67357D-24,6.646442D-24,1.380658D-16/
      DATA TOLSP,TOLST/0.08D0,0.032D0/
      SAVE
      IF(ABS(X-XENV).GT.1.0D-5 .OR. ABS(Z-ZENV).GT.1.0D-5)THEN
         CALL EQSCVG(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *               AMU,EMU,ETA,QDT,QDP,QCP,DELA,LCALC)
         RETURN
      ENDIF
C FIND GAS PRESSURE (WHICH IS THE QUANTITY WHICH IS TABULATED).
      BETM1 = 1.0D0 - BETA
      PP = DLOG10(BETA*P)
C  CHECK IF THE POINT IS WITHIN THE TABLE
      IF(TL.LT.TLOGX(1) .OR. TL.GT.TLOGX(NTS) .OR. PP.LT.4.0D0)THEN
         LCALC = .FALSE.   ! Error exit - no valid table entry
         RETURN
      ENDIF
C  FIND NEAREST POINTS IN TEMPERATURE.
      IF(TL.LT.TLOGX(IDT+1))THEN
C SEARCH DOWN TO FIND NEAREST 4 TABLE ELEMENTS
         DO I = IDT,1,-1
            IF(TL.GT.TLOGX(I))THEN
               II = I - 1
               GOTO 10
            ENDIF
         END DO
         II = 1
  10     CONTINUE
      ELSE
C SEARCH UP FOR NEAREST 4 TABLE ELEMENTS
         DO I = IDT+2,NTS
            IF(TL.LT.TLOGX(I))THEN
               II = I - 2
               GOTO 20
            ENDIF
         END DO
         II = NTS - 3
  20     CONTINUE
      ENDIF
      IDT = MAX(1,II)
      IDT = MIN(NTS-3,IDT)
      LSMT = .FALSE.
      IF(IDT.EQ.II)THEN
         DTABOVE = TL - TLOGX(IDT+1)
         DTBELOW = TLOGX(IDT+2) - TL
         IF(DTABOVE.LT.TOLST)THEN
            IF(IDT.GT.1)THEN
               LSMT = .TRUE.
               ISMT = -1
               FST = (DTABOVE+TOLST)/(2.0D0*TOLST)
            ENDIF
         ELSE IF(DTBELOW.LT.TOLST)THEN
            IF(IDT.LT.NTS-3)THEN
               LSMT = .TRUE.
               ISMT = 1
               FST = 0.5D0*DTBELOW/TOLST
            ENDIF
         ENDIF
      ENDIF
C  FIND NEAREST POINTS IN PRESSURE.
      JJJ = MIN(NPTSX(IDT)-3,IDP)
      IF(PP.LT.TABLENV(IDT,JJJ+1,1))THEN
C SEARCH DOWN TO FIND NEAREST 4 TABLE ELEMENTS
         DO J = JJJ,1,-1
            IF(PP.GT.TABLENV(IDT,J,1))THEN
               JJ = J - 1
               GOTO 30
            ENDIF
         END DO
         JJ = 1
  30     CONTINUE
         IDP = MAX(1,JJ)
         IDP = MIN(NPTSX(IDT)-3,IDP)
      ELSE
C SEARCH UP FOR NEAREST 4 TABLE ELEMENTS.  NOTE SEARCH IS DONE AT LOWEST
C TEMPERATURE POINT (WITH THE MINIMUM RANGE IN P).
         DO J = JJJ+2,NPTSX(IDT)
            IF(PP.LT.TABLENV(IDT,J,1))THEN
               JJ = J - 2
               GOTO 40
            ENDIF
         END DO
C POINT IS OUTSIDE TABLE; RETURN.
         LCALC = .FALSE.   ! Error exit - no valid table entry
         RETURN
  40     CONTINUE
         IDP = MIN(NPTSX(IDT)-3,JJ)
      ENDIF
      LCALC = .TRUE.
      LSMP = .FALSE.
      IF(IDP.EQ.JJ)THEN
         DPABOVE = PP - TABLENV(IDT,IDP+1,1)
         DPBELOW = TABLENV(IDT,IDP+2,1) - PP
         IF(DPABOVE.LT.TOLSP)THEN
            IF(IDP.GT.1)THEN
               LSMP = .TRUE.
               ISMP = -1
               FSP = (DPABOVE+TOLSP)/(2.0D0*TOLSP)
            ENDIF
         ELSE IF(DPBELOW.LT.TOLSP)THEN
            IF(IDP.LT.NPTSX(IDT)-3)THEN
               LSMP = .TRUE.
               ISMP = 1
               FSP = 0.5D0*DPBELOW/TOLSP
            ENDIF
         ENDIF
      ENDIF
C      DO K = 1,4
C         QR(K) = TLOGX(K+IDT-1)
C      END DO
C      CALL INTERP(QR,FT,FTD,TL)
C      DO K = 1,4
C         QR(K) = TABLENV(IDT,IDP+K-1,1)
C      END DO
C      CALL INTERP(QR,FP,FPD,PP)
      Y = 1.0D0 - X - Z
C INCLUDE RADIATION PRESSURE IN THE EQUATION OF STATE.
      PRAD = BETM1*P
      PGAS = BETA*P
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         DO K = 1,4
            QR(K) = TABLENV(IDT,IDP+K-1,1)
         END DO
         DO J = 1,5
            DO K = 1,4
               YTAB(K) = TABLENV(II,IDP+K-1,J+1)
            END DO
            CALL KSPLINE(QR,YTAB,Y2)
            CALL KSPLINT(QR,YTAB,Y2,PP,Y0)
            TEMP(I,J) = Y0
C            TEMP(I,J)=FP(1)*TABLENV(II,IDP,J+1) +
C     *      FP(2)*TABLENV(II,IDP+1,J+1) + FP(3)*TABLENV(II,IDP+2,J+1)
C     *      + FP(4)*TABLENV(II,IDP+3,J+1)
         END DO
      END DO
C INTERPOLATE IN TEMPERATURE
      DO K = 1,4
         QR(K) = TLOGX(K+IDT-1)
      END DO
      DO J = 1,5
         DO K = 1,4
            YTAB(K) = TEMP(K,J)
         END DO
         CALL KSPLINE(QR,YTAB,Y2)
         CALL KSPLINT(QR,YTAB,Y2,TL,Y0)
         TEMPT(J) = Y0
      END DO
C PERFORM INTERPOLATION AT ADJACENT TEMPERATURE TABLE POINTS
      IF(LSMT)THEN
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1+ISMT
         DO K = 1,4
            QR(K) = TABLENV(IDT,IDP+K-1,1)
         END DO
         DO J = 1,5
            DO K = 1,4
               YTAB(K) = TABLENV(II,IDP+K-1,J+1)
            END DO
            CALL KSPLINE(QR,YTAB,Y2)
            CALL KSPLINT(QR,YTAB,Y2,PP,Y0)
            TEMP(I,J) = Y0
C            TEMP(I,J)=FP(1)*TABLENV(II,IDP,J+1) +
C     *      FP(2)*TABLENV(II,IDP+1,J+1) + FP(3)*TABLENV(II,IDP+2,J+1)
C     *      + FP(4)*TABLENV(II,IDP+3,J+1)
         END DO
      END DO
C INTERPOLATE IN TEMPERATURE
      DO K = 1,4
         QR(K) = TLOGX(K+IDT+ISMT-1)
      END DO
      DO J = 1,5
         DO K = 1,4
            YTAB(K) = TEMP(K,J)
         END DO
         CALL KSPLINE(QR,YTAB,Y2)
         CALL KSPLINT(QR,YTAB,Y2,TL,Y0)
         TEMPT1(J) = Y0
      END DO
      IF(ISMT.EQ.-1)THEN
         DO J = 1,5
            TEMPT1T(J) = TEMPT1(J)+FST*(TEMPT(J)-TEMPT1(J))
         END DO
      ELSE
         DO J = 1,5
            TEMPT1T(J) = TEMPT(J)+FST*(TEMPT1(J)-TEMPT(J))
         END DO
      ENDIF
      ENDIF
C PERFORM INTERPOLATION AT ADJACENT PRESSURE TABLE POINTS
      IF(LSMP)THEN
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         DO K = 1,4
            QR(K) = TABLENV(IDT,IDP+K-1+ISMP,1)
         END DO
         DO J = 1,5
            DO K = 1,4
               YTAB(K) = TABLENV(II,IDP+K-1+ISMP,J+1)
            END DO
            CALL KSPLINE(QR,YTAB,Y2)
            CALL KSPLINT(QR,YTAB,Y2,PP,Y0)
            TEMP(I,J) = Y0
C            TEMP(I,J)=FP(1)*TABLENV(II,IDP,J+1) +
C     *      FP(2)*TABLENV(II,IDP+1,J+1) + FP(3)*TABLENV(II,IDP+2,J+1)
C     *      + FP(4)*TABLENV(II,IDP+3,J+1)
         END DO
      END DO
C INTERPOLATE IN TEMPERATURE
      DO K = 1,4
         QR(K) = TLOGX(K+IDT-1)
      END DO
      DO J = 1,5
         DO K = 1,4
            YTAB(K) = TEMP(K,J)
         END DO
         CALL KSPLINE(QR,YTAB,Y2)
         CALL KSPLINT(QR,YTAB,Y2,TL,Y0)
         TEMPT2(J) = Y0
      END DO
      IF(ISMP.EQ.-1)THEN
         DO J = 1,5
            TEMPT2P(J) = TEMPT2(J)+FSP*(TEMPT(J)-TEMPT2(J))
         END DO
      ELSE
         DO J = 1,5
            TEMPT2P(J) = TEMPT(J)+FSP*(TEMPT2(J)-TEMPT(J))
         END DO
      ENDIF
      ENDIF
C PERFORM INTERPOLATION AT ADJACENT T+P TABLE POINTS
      IF(LSMP .AND. LSMT)THEN
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1 + ISMT
         DO K = 1,4
            QR(K) = TABLENV(IDT,IDP+K-1+ISMP,1)
         END DO
         DO J = 1,5
            DO K = 1,4
               YTAB(K) = TABLENV(II,IDP+K-1+ISMP,J+1)
            END DO
            CALL KSPLINE(QR,YTAB,Y2)
            CALL KSPLINT(QR,YTAB,Y2,PP,Y0)
            TEMP(I,J) = Y0
C            TEMP(I,J)=FP(1)*TABLENV(II,IDP,J+1) +
C     *      FP(2)*TABLENV(II,IDP+1,J+1) + FP(3)*TABLENV(II,IDP+2,J+1)
C     *      + FP(4)*TABLENV(II,IDP+3,J+1)
         END DO
      END DO
C INTERPOLATE IN TEMPERATURE
      DO K = 1,4
         QR(K) = TLOGX(K+IDT-1 + ISMT)
      END DO
      DO J = 1,5
         DO K = 1,4
            YTAB(K) = TEMP(K,J)
         END DO
         CALL KSPLINE(QR,YTAB,Y2)
         CALL KSPLINT(QR,YTAB,Y2,TL,Y0)
         TEMPT3(J) = Y0
      END DO
      ENDIF
      IF(LSMT)THEN
C ADD CHANGES FOR BOTH T AND P INTERPOLATION
         IF(LSMP)THEN
C            WRITE(*,911)(TEMPT(J),J=1,5)
 911        FORMAT(1X,'ORIG ',1P5E16.7)
C            WRITE(*,912)(TEMPT1(J)-TEMPT(J),J=1,5)
 912        FORMAT(1X,'INT T',1P5E16.7)
C            WRITE(*,913)(TEMPT2(J)-TEMPT(J),J=1,5)
 913        FORMAT(1X,'INT P',1P5E16.7)
C            WRITE(*,914)(TEMPT3(J)-TEMPT(J),J=1,5)
 914        FORMAT(1X,'INT PT',1P5E16.7)
            DO J = 1,5
               IF(ISMT.EQ.-1)THEN
C INTERPOLATE IN T AT FIXED P
                  CHGT1 = TEMPT1(J)+FST*(TEMPT(J)-TEMPT1(J))
C INTERPOLATE IN T AT DIFFERENT P
                  CHGT2 = TEMPT3(J)+FST*(TEMPT2(J)-TEMPT3(J))
               ELSE
                  CHGT1 = TEMPT(J)+FST*(TEMPT1(J)-TEMPT(J))
                  CHGT2 = TEMPT2(J)+FST*(TEMPT3(J)-TEMPT2(J))
               ENDIF
               IF(ISMP.EQ.-1)THEN
                  TEMPT(J) = CHGT2+FSP*(CHGT1-CHGT2)
C CHANGE IN P AT FIXED T
C                  CHGP1 = TEMPT2+FSP*(TEMPT(J)-TEMPT2(J))
C CHANGE IN P AT DIFFERENT T
C                  CHGP2 = TEMPT3(J)+FSP*(TEMPT1(J)-TEMPT3(J))
               ELSE
                  TEMPT(J) = CHGT1+FSP*(CHGT2-CHGT1)
C                  CHGP1 = TEMPT(J)+FSP*(TEMPT2(J)-TEMPT(J))
C                  CHGP2 = TEMPT1(J)+FSP*(TEMPT3(J)-TEMPT1(J))
               ENDIF
C               WRITE(*,915)ISMP,ISMT,TEMPT(J),CHGT1,CHGT2,FSP,FST
 915           FORMAT(2I2,1P5E16.7)
            END DO
          ELSE
C ADD T INTERPOLATION CHANGES ONLY
C            WRITE(*,911)(TEMPT(J),J=1,5)
C            WRITE(*,912)(TEMPT1(J)-TEMPT(J),J=1,5)
             DO J = 1,5
                TEMPT(J) = TEMPT1T(J)
             END DO
          ENDIF
       ELSE IF(LSMP)THEN
C ADD P INTERPOLATION CHANGES ONLY
C            WRITE(*,911)(TEMPT(J),J=1,5)
C            WRITE(*,912)(TEMPT2(J)-TEMPT(J),J=1,5)
          DO J = 1,5
             TEMPT(J) = TEMPT2P(J)
          END DO
       ENDIF
C      DO J = 1,5
C         TEMPT(J)=FT(1)*TEMP(1,J) + FT(2)*TEMP(2,J) + FT(3)*TEMP(3,J)
C     *   + FT(4)*TEMP(4,J)
C      END DO
C  DENSITY
      DL = TEMPT(1)
      D = EXP(CLN*DL)
C D LN RHO/ D LN P = QDP
C FOR GAS PRESSURE QDP(TOT) = QDP(X)*X*RHO/RHO(X)+QDP(Y)*Y*RHO/RHO(Y)
C FOR RADIATION PRESSURE QDP = 0, SO QDP(TOT) = QDP(GAS)*P/PGAS
      QDP0 = TEMPT(3)
      QDP = QDP0/BETA
C D LN RHO/ D LN T = QDT (NOTE : D LN P/ D LN T = QPT)
C FOR GAS PRESSURE, CORRECT AS PER QDP
C FOR RADIATION PRESSURE, USE QDT = -QDP*QPT.  CORRECT QPT FOR
C RADIATION PRESSURE AND USE THE CORRECTED QDP, QPT TO GET QDT.
      QDT0 = TEMPT(2)
      QPT0 = -QDT0/QDP0
      QPT = QPT0*BETA + 4.0D0*BETM1
      QDT = -QPT*QDP
C  CP = S*(D LN S/ D LN T)|P IS TABULATED. USE
C  CP = DU/DT + P*(D LN RHO/D LN T)**2/RHO/T/(D LN RHO/ D LN P)
C  TO FIND DU/DT.  THEN INCLUDE THE EFFECTS OF RADIATION PRESSURE
C  ON DU/DT AND THE OTEHR TERMS AND GET A CORRECTED CP.
C CP (GAS PRESSURE ONLY).
      QCP0 = TEMPT(4)
C NOW FIND DU/DT FROM THE ORIGINAL TABLE.
      QUT = TEMPT(5)
C      QUT = QCP0 - PGAS*QDT0**2/QDP0/D/T
C CORRECT DU/DT FOR RADIATION
      UR = 3.0D0*PRAD/D
      QUT = QUT + 4.0D0*UR/T
C CORRECT CP FOR RADIATION PRESSURE
      QCP = QUT - P*QDT*QPT/D/T
C ADIABATIC TEMPERATURE GRADIENT
      DELA = -P*QDT/D/T/QCP

C Get fractions of total particles (including electrons), as follows:
C   XTF_H2  the fraction that is neutral hydrogen molecules, and
C   XTF_He  the fraction thst is neutral helium).
C   These are in column 2 respectively of the SCV hydrogen and
C   Helium tables.
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.

      DO K = 1,4
         QR(K) = TLOGX(K+IDT-1)
      END DO
      CALL INTERP(QR,FT,FTD,TL)
      DO K = 1,4
         QR(K) = TABLENV(IDT,IDP+K-1,1)
      END DO
      CALL INTERP(QR,FP,FPD,PP)

      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,2) +
     *   FP(2)*TABLEX(II,IDP+1,2) + FP(3)*TABLEX(II,IDP+2,2)
     *   + FP(4)*TABLEX(II,IDP+3,2)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,2) +
     *   FP(2)*TABLEY(II,IDP+1,2) + FP(3)*TABLEY(II,IDP+2,2)
     *   + FP(4)*TABLEY(II,IDP+3,2)
      END DO
C INTERPOLATE IN TEMPERATURE
      XTF_H2 = FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      XTF_He = FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)

C Get more fractions of total particles (including electrons), as follows:
C   XTF_H1  the fraction that is neutral hydrogen atoms, and
C   XTF_HeP  the fraction thst is singly ionized helium).
C   These are in column 3 respectively of the SCV hydrogen and
C   Helium tables.
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,3) +
     *   FP(2)*TABLEX(II,IDP+1,3) + FP(3)*TABLEX(II,IDP+2,3)
     *   + FP(4)*TABLEX(II,IDP+3,3)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,3) +
     *   FP(2)*TABLEY(II,IDP+1,3) + FP(3)*TABLEY(II,IDP+2,3)
     *   + FP(4)*TABLEY(II,IDP+3,3)
      END DO
C INTERPOLATE IN TEMPERATURE
      XTF_H1 = FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      XTF_HeP = FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)

C At tis time we can calculate the ramaining particles fractions using conservation
C of particles and coservation of charge.  The variable names are:
C  XTF_H_e  the hycrogen related fraction that is electrons
C  XTF_HP   the hydrogen ralated fraction that is H+ ions
C  XTF_He_e the helium related fraction that is electrons
C  XTF_HePP the helium related fraction that is doubly ionized helium (He++)
C Particle and charge conservation yields:
      XTF_H_e = .5D0*(1D0 - XTF_H2 - XTF_H1)
      XTF_HP = XTF_H_e
      XTF_He_e = (1D0/3D0)*(2D0 - 2D0*XTF_He - XTF_HeP)
      XTF_HePP = 1D0 - XTF_He - XTF_HeP - XTF_He_e

C We are seeking the fraction XHP of hydrogen nuclei that are singly ionized,
C the fraction XHeP of helium huclei that are singly ionized and XHePP, the
C helium fraction that is doubly ionized.
      XHP = XTF_HP / (XTF_H2 + XTF_H1 + XTF_HP)
      XHeP = XTF_HeP / (XTF_He + XTF_HeP + XTF_HePP)
      XHePP = XTF_HePP / (XTF_He + XTF_HeP + XTF_HePP)

C In the same order, these are the desired elements of array XION(3)
      FXION(1) = XHP
      FXION(2) = XHeP
      FXION(3) = XHePP

      RETURN  ! Normal exit. Valid table entry. LCALC is true.

      END
