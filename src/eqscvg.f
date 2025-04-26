C SUBROUTINE FOR INTERPOLATING IN THE GENERAL ABUNDANCE TABLES OF THE SCV
C EQUATION OF STATE.
      SUBROUTINE EQSCVG(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *AMU,EMU,ETA,QDT,QDP,QCP,DELA,LCALC)

      use params, only : nts, nps
      use settings, only : CLN  ! /CONST1/
      use tables, only : TLOGX, TABLEX, TABLEY, SMIX, TABLEZ, TABLENV, NPTSX, IDP  ! /SCVEOS/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION ATOMWT(4),QR(4),FT(4),FTD(4),
     *     FP(4),FPD(4),TEMP(4,3),FXION(3)
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      DATA CMH,CMHE,CBOLTZ/1.67357D-24,6.646442D-24,1.380658D-16/
      SAVE

C FIND GAS PRESSURE (WHICH IS THE QUANTITY WHICH IS TABULATED).
      BETM1 = 1.0D0 - BETA
      PP = DLOG10(BETA*P)
C  CHECK IF THE POINT IS WITHIN THE TABLE
      IF(TL.LT.TLOGX(1) .OR. TL.GT.TLOGX(NTS) .OR. PP.LT.4.0D0)THEN
         LCALC = .FALSE.
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
         IDT = MAX(1,II)
         IDT = MIN(NTS-3,IDT)
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
         IDT = MAX(1,II)
         IDT = MIN(NTS-3,IDT)
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
c         WRITE(*,5)TL,PL
         LCALC = .FALSE.
         RETURN
  40     CONTINUE
         IDP = MIN(NPTSX(IDT)-3,JJ)
      ENDIF
      LCALC = .TRUE.
      DO K = 1,4
         QR(K) = TLOGX(K+IDT-1)
      END DO
      CALL INTERP(QR,FT,FTD,TL)
      DO K = 1,4
         QR(K) = TABLENV(IDT,IDP+K-1,1)
      END DO
      CALL INTERP(QR,FP,FPD,PP)
      Y = 1.0D0 - X - Z
C INCLUDE RADIATION PRESSURE IN THE EQUATION OF STATE.
      PRAD = BETM1*P
      PGAS = BETA*P
C DENSITY FOR X=1, Y=1, Z=1
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,4) +
     *   FP(2)*TABLEX(II,IDP+1,4) + FP(3)*TABLEX(II,IDP+2,4)
     *   + FP(4)*TABLEX(II,IDP+3,4)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,4) +
     *   FP(2)*TABLEY(II,IDP+1,4) + FP(3)*TABLEY(II,IDP+2,4)
     *   + FP(4)*TABLEY(II,IDP+3,4)
         TEMP(I,3)=FP(1)*TABLEZ(II,IDP,4) +
     *   FP(2)*TABLEZ(II,IDP+1,4) + FP(3)*TABLEZ(II,IDP+2,4)
     *   + FP(4)*TABLEZ(II,IDP+3,4)
      END DO
C INTERPOLATE IN TEMPERATURE
      DENXL= FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      DENX = EXP(CLN*DENXL)
      DENYL= FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)
      DENY = EXP(CLN*DENYL)
      DENZL= FT(1)*TEMP(1,3) + FT(2)*TEMP(2,3) + FT(3)*TEMP(3,3)
     *         + FT(4)*TEMP(4,3)
      DENZ = EXP(CLN*DENZL)
C  DENSITY
      D = 1.0D0/(X/DENX + Y/DENY + Z/DENZ)
      DL = LOG10(D)
      DDX = X*D/DENX
      DDY = Y*D/DENY
      DDZ = Z*D/DENZ
C D LN RHO/ D LN P = QDP
C FOR GAS PRESSURE QDP(TOT) = QDP(X)*X*RHO/RHO(X)+QDP(Y)*Y*RHO/RHO(Y)
C FOR RADIATION PRESSURE QDP = 0, SO QDP(TOT) = QDP(GAS)*P/PGAS
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,8) +
     *   FP(2)*TABLEX(II,IDP+1,8) + FP(3)*TABLEX(II,IDP+2,8)
     *   + FP(4)*TABLEX(II,IDP+3,8)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,8) +
     *   FP(2)*TABLEY(II,IDP+1,8) + FP(3)*TABLEY(II,IDP+2,8)
     *   + FP(4)*TABLEY(II,IDP+3,8)
         TEMP(I,3)=FP(1)*TABLEZ(II,IDP,13) +
     *   FP(2)*TABLEZ(II,IDP+1,13) + FP(3)*TABLEZ(II,IDP+2,13)
     *   + FP(4)*TABLEZ(II,IDP+3,13)
      END DO
C INTERPOLATE IN TEMPERATURE
      QDPX= FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      QDPY= FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)
      QDPZ= FT(1)*TEMP(1,3) + FT(2)*TEMP(2,3) + FT(3)*TEMP(3,3)
     *         + FT(4)*TEMP(4,3)
      QDP0 = QDPX*DDX + QDPY*DDY + QDPZ*DDZ
      QDP = QDP0/BETA
C D LN RHO/ D LN T = QDT (NOTE : D LN P/ D LN T = QPT)
C FOR GAS PRESSURE, CORRECT AS PER QDP
C FOR RADIATION PRESSURE, USE QDT = -QDP*QPT.  CORRECT QPT FOR
C RADIATION PRESSURE AND USE THE CORRECTED QDP, QPT TO GET QDT.
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.zdiffOPEOSfinalewkop95zscv1.full
      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,7) +
     *   FP(2)*TABLEX(II,IDP+1,7) + FP(3)*TABLEX(II,IDP+2,7)
     *   + FP(4)*TABLEX(II,IDP+3,7)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,7) +
     *   FP(2)*TABLEY(II,IDP+1,7) + FP(3)*TABLEY(II,IDP+2,7)
     *   + FP(4)*TABLEY(II,IDP+3,7)
         TEMP(I,3)=FP(1)*TABLEZ(II,IDP,10) +
     *   FP(2)*TABLEZ(II,IDP+1,10) + FP(3)*TABLEZ(II,IDP+2,10)
     *   + FP(4)*TABLEZ(II,IDP+3,10)
      END DO
C INTERPOLATE IN TEMPERATURE
      QDTX= FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      QDTY= FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)
      QDTZ= FT(1)*TEMP(1,3) + FT(2)*TEMP(2,3) + FT(3)*TEMP(3,3)
     *         + FT(4)*TEMP(4,3)
      QDT0 = QDTX*DDX + QDTY*DDY + QDTZ*DDZ
      QPT0 = -QDT0/QDP0
      QPT = QPT0*BETA + 4.0D0*BETM1
      QDT = -QPT*QDP
C  CP = S*(D LN S/ D LN T)|P IS TABULATED. USE
C  CP = DU/DT + P*(D LN RHO/D LN T)**2/RHO/T/(D LN RHO/ D LN P)
C  TO FIND DU/DT.  THEN INCLUDE THE EFFECTS OF RADIATION PRESSURE
C  ON DU/DT AND THE OTHER TERMS AND GET A CORRECTED CP.
C CP (GAS PRESSURE ONLY).
C NOTE THAT UNLIKE THE ENVELOPE TABLE, WE NEED TO INTERPOLATE IN
C ENTROPY S, D LN S/D LNT, AND ENTROPY OF MIXING, THEN CALCULATE
C DU/DT
C  ENTROPY AND ENTROPY OF MIXING
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,5) +
     *   FP(2)*TABLEX(II,IDP+1,5) + FP(3)*TABLEX(II,IDP+2,5)
     *   + FP(4)*TABLEX(II,IDP+3,5)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,5) +
     *   FP(2)*TABLEY(II,IDP+1,5) + FP(3)*TABLEY(II,IDP+2,5)
     *   + FP(4)*TABLEY(II,IDP+3,5)
         TEMP(I,3)=FP(1)*SMIX(II,IDP) +
     *   FP(2)*SMIX(II,IDP+1) + FP(3)*SMIX(II,IDP+2)
     *   + FP(4)*SMIX(II,IDP+3)
      END DO
C INTERPOLATE IN TEMPERATURE
      SXL= FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      SX = EXP(CLN*SXL)
      SYL= FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)
      SY = EXP(CLN*SYL)
      SM= FT(1)*TEMP(1,3) + FT(2)*TEMP(2,3) + FT(3)*TEMP(3,3)
     *         + FT(4)*TEMP(4,3)
      QSMT = FTD(1)*LOG10(TEMP(1,3)) + FTD(2)*LOG10(TEMP(2,3))
     *     + FTD(3)*LOG10(TEMP(3,3))
     *         + FTD(4)*LOG10(TEMP(4,3))
      S0 = X*SX + Y*SY + SM
C D LN S/ D LN T (X AND Y) AND DU/DT (Z)
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
      DO I = 1,4
         II = IDT+I-1
         TEMP(I,1)=FP(1)*TABLEX(II,IDP,9) +
     *   FP(2)*TABLEX(II,IDP+1,9) + FP(3)*TABLEX(II,IDP+2,9)
     *   + FP(4)*TABLEX(II,IDP+3,9)
         TEMP(I,2)=FP(1)*TABLEY(II,IDP,9) +
     *   FP(2)*TABLEY(II,IDP+1,9) + FP(3)*TABLEY(II,IDP+2,9)
     *   + FP(4)*TABLEY(II,IDP+3,9)
         TEMP(I,3)=FP(1)*TABLEZ(II,IDP,7) +
     *   FP(2)*TABLEZ(II,IDP+1,7) + FP(3)*TABLEZ(II,IDP+2,7)
     *   + FP(4)*TABLEZ(II,IDP+3,7)
      END DO
C INTERPOLATE IN TEMPERATURE
      QSTX= FT(1)*TEMP(1,1) + FT(2)*TEMP(2,1) + FT(3)*TEMP(3,1)
     *         + FT(4)*TEMP(4,1)
      QSTY= FT(1)*TEMP(1,2) + FT(2)*TEMP(2,2) + FT(3)*TEMP(3,2)
     *         + FT(4)*TEMP(4,2)
      QUTZL= FT(1)*TEMP(1,3) + FT(2)*TEMP(2,3) + FT(3)*TEMP(3,3)
     *         + FT(4)*TEMP(4,3)
      QUTZ = EXP(CLN*QUTZL)
      QST0 = X*SX*QSTX + Y*SY*QSTY + SM*QSMT
      QCP0 = QST0 + Z*(QUTZ + PGAS*QDTZ**2/QDPZ/DENZ/T)
C NOW FIND DU/DT FROM THE ORIGINAL TABLE.
      QUT = QCP0 - PGAS*QDT0**2/QDP0/D/T
C CORRECT DU/DT FOR RADIATION
      UR = 3.0D0*PRAD/D
      QUT = QUT + 4.0D0*UR/T
C CORRECT CP FOR RADIATION PRESSURE
      QCP = QUT + P*QDT**2/QDP/D/T
C ADIABATIC TEMPERATURE GRADIENT
      DELA = -P*QDT/D/T/QCP

C Get fractions of total particles (including electrons), as follows:
C   XTF_H2  the fraction that is neutral hydrogen molecules, and
C   XTF_He  the fraction thst is neutral helium).
C   These are in column 2 respectively of the SCV hydrogen and
C   Helium tables.
C INTERPOLATE IN PRESSURE AT 4 DIFFERENT TEMPERATURE POINTS.
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

      RETURN    ! Primay exit. Success. LCALC is true.

      END
