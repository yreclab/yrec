C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C TPGRAD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE TPGRAD(TL,T,PL,P,D,RL,SL,B,O,QDT,QDP,QOT,QOD,QCP,
     *DEL,DELR,DELA,QDTT,QDTP,QAT,QAP,QACT,QACP,QACR,QCPT,QCPP,
     *VEL,LDERIV,LCONV,FPL,FTL,TEFFL)

      use params, only : json
      use settings, only : ISHORT  ! COMMON/LUOUT/
      use settings, only : CLSUNL  ! COMMON/CONST/
      use settings, only : CLN  ! COMMON/CONST1/
      use settings, only : CGL  ! COMMON/CONST2/
      use settings, only : CDELRL, CMIXL, CMIXL2, CMIXL3  ! COMMON/CONST3/
      use settings, only : TGCUT  ! COMMON/CTLIM/

C  DL,OL,X,Z,LOCOND USED BY OPACTY
C COMPUTES RADIATIVE GRADIENT AND COMPARES WITH ADIABATIC GRADIENT
C COMPUTES CONVECTIVE GRADIENT VIA MIXING LENGTH THEORY IF APPLICABLE
C ASSUMES EQSTAT AND OPACTY HAVE BEEN CALLED
C RETURNS LCONV = .TRUE. IF CONVECTIVE
C         DELR = RADIATIVE GRADIENT
C         DEL = ACTUAL GRADIENT
C          QACT,QACP = NAT-LOG DERIVATIVES OF THE CONVECTIVE GRADIENT
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/DPMIX/DPENV,ALPHAC,ALPHAE,ALPHAM,BETAC,IOV1,IOV2,
     *      IOVIM, LOVSTC, LOVSTE, LOVSTM, LSEMIC, LADOV, LOVMAX
C DBG 7/95 To store variables for pulse output
      COMMON/PUALPHA/ALFMLT,PHMLT,CMXMLT,
     *     VALFMLT(JSON),VPHMLT(JSON),VCMXMLT(JSON)
C G Somers 09/14, Add spot common block
      COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH
C G Somers END
      DATA VTOL/1.0D-10/
      SAVE

      ALFMLT=0.0D0
      PHMLT=0.0D0
      CMXMLT=0.0D0
      DELR = O*B*DEXP(CLN*(PL - SL - 4D0*TL + CLSUNL - CGL + CDELRL))*
     *FTL/FPL
      DELDEL = DELR - DELA
      IF(DELDEL.LE.1.0D-6) THEN
C ZONE IS RADIATIVE
	 LCONV = .FALSE.
	 DEL = DELR
	 VEL=0.0D0
         IF (LADOV .AND. IOVIM.GE.IOV1 .AND. IOVIM.LE.IOV2
     *       .AND. IOVIM.NE.-1) THEN
            DEL = DELA
         END IF
	 GOTO 200
      ENDIF
C ZONE IS CONVECTIVE
      LCONV = .TRUE.
      DEL = DELA
C SKIP MIXING LENGTH THEORY FOR CORES
      IF(TL.GT.TGCUT) THEN
         VEL = 1.0D-11
	 IF(LDERIV) THEN
C DERIVATIVES OF CONVECTIVE GRADIENT
	    QACT = QAT
	    QACP = QAP
	    QACR = 0.0D0
	 ENDIF
	 GOTO 200
      ENDIF
C G Somers 9/14, Add the ability to include spots, which alter
C the radiative flux in the convective reigons. This is done by
C setting the flux to Lspotted = L/[f*x^4 + (1-f)], where f is the
C spot filling factor and x is the temperature contrast between
C the spotted surface and the normal surface (0 <= x <= 1). We also
C alter the surface boundary condition used in envint.f, by looking
C up the pressure at the un-spotted T (ATEFFL) instead of Teff.
C
C We have also included the ability to have the temperature contrast
C SPOTX vary with depth, as is the case in stars. In this case, SPOTX
C is locally determined by X(T) = 1 - (1-Xsurf)(ATeff/T), where ATeff
C is the surface temperature of the unspotted regions. This is the
C analytic expression resulting from a user specified Xsurf, the
C assumption of magnetic equipartition at the surface (Pmag = Psurf/2),
C and the assumption of constant Pmag with depth.
C
C This flux alters DELR, so recalculate DELDEL with the correction. Only
C do this if the spot filling factor is non-zero, and the envelope is
C convective.
      IF(SPOTF .NE. 0.00)THEN
         IF(LSDEPTH)THEN
            ATEFFL = TEFFL - 0.25*LOG10(SPOTF * SPOTX**4.0 + 1.0 - SPOTF)
            DEEPX = 1.0 - (1.0 - SPOTX)*(10.**ATEFFL)/(10.**TL)
         ELSE
            DEEPX = SPOTX
         ENDIF
         DELDEL = DELR/(SPOTF * DEEPX**4.0 + 1.0 - SPOTF) - DELA
      ENDIF
C G Somers END
      G = DEXP(CLN*(CGL + SL - RL - RL))
      PRESHT = P/(D*G)
      PHI = CMIXL*D*O*PRESHT
      PHI2 = PHI*PHI
      PHIPHI = 1.0D0/(1.0D0 + CMIXL2*PHI2)
C SOLVE CUBIC A3*V**3 + V**2 + A1*V - 1.0 = 0.0
C ENSURE THAT THE SQUARE ROOT BEING TAKEN IS THAT OF A
C POSITIVE NUMBER
      TEST = DELDEL*G*(-QDT)/PRESHT
      IF(TEST.GT.0.0D0)THEN
         A1 = CMIXL3*PHIPHI*T**3*O/(QCP*DSQRT(TEST))
      ELSE
C ODD CONVERGENCE PROBLEM; WRITE DIAGNOSTIC AND CONTINUE.
         WRITE(*,201)DELDEL,QDT,TEST
 201     FORMAT('***WARNING***'/'TPGRAD TRIED TO TAKE SQUARE ROOT',
     *          ' OF NEGATIVE NUMBER - ASSUMED ADIABATIC CONVECTION'/
     *          ' DELDEL ',1PE12.3,' QDT ',E12.3,' DISC. ',E12.3)
      WRITE(*,911)O,B,PL,SL,TL,FTL,FPL,DELR,DELA,RL
 911  FORMAT(1P10E12.3)
          STOP 912
C         GOTO 15
      ENDIF
C      A1 = CMIXL3*PHIPHI*T**3*O/(QCP*DSQRT(DELDEL*G*(-QDT)/PRESHT))
      V = 1.0D0/A1
      A3 = 0.75D0*PHI2*PHIPHI/A1
      A3P = 3.0D0*A3
      IF(A3.GT.1.0D+3) V = A3**(-0.333333333D0)
      DO 10 ITER = 1,25
	 V = DMIN1(V,1.0D0)
	 VP = A1 + V*(2.0D0 + V*A3P)
	 VD = (-1.0D0 + V*(A1 + V*(1.0D0 + V*A3)))/VP
	 VD = VD*(1.0D0 + VD*(1.0D0 + V*A3P)/VP)
	 V = V - VD
	 IF(DABS(VD).LT.VTOL) GOTO 30
   10 CONTINUE
 15   CONTINUE
      WRITE(ISHORT,20) PL,TL,O,QCP,QDT
   20 FORMAT(' -----CUBIC NON-CONVERGENCE(PL,TL,CAPPA,CP,QDT)='
     *       ,2F10.6/1P3E12.6)
C ASSUME ADIABATIC CONVECTION
      VEL = 1.0D-11
      IF(LDERIV) THEN
C DERIVATIVES OF CONVECTIVE GRADIENT
	 QACT = QAT
         QACP = QAP
         QACR = 0.0D0
      ENDIF
      GOTO 200
   30 DDEL = DELDEL*V*(V+A1)
      DEL = DELA + DDEL
C CALCULATE CONVECTIVE VELOCITY
      TEST = G*(-QDT)*PRESHT*DELDEL
      IF(TEST.GT.0.0D0)THEN
         VEL = V*DSQRT(G*(-QDT)*(CMIXL**2)*PRESHT*DELDEL/8.0D0)
      ELSE
         VEL = 1.0D0-11
      ENDIF
      DELPM=DEL-V*V*DELDEL
      RRR = 10.0D0**RL
      IF(LDERIV) THEN
C DERIVATIVES OF CONVECTIVE GRADIENT
	 QDELAT = QAT*DELA
	 QDELAP = QAP*DELA
	 TEMPOT = QOD*QDT + QOT
	 TEMPOP = QOD*QDP
	 QDDELT = ((-4.0D0 + TEMPOT)*DELR - QDELAT)/DELDEL
	 QDDELP = ((+1.0D0 + TEMPOP)*DELR - QDELAP)/DELDEL
	 TEMP1 = 2.0D0*CMIXL2*PHI2*PHIPHI
	 QA1T = TEMPOT*(1D0-TEMP1)-QCPT-0.5D0*(QDT+QDDELT+QDTT/QDT)+3D0
	 QA1P = TEMPOP*(1D0-TEMP1)-TEMP1-QCPP-0.5D0
     *          *(QDP+QDDELP+QDTP/QDT) + 0.5D0
	 QA1R = -2.0D0*TEMP1 + 2.0D0
	 QA3T = 2.0D0*PHIPHI*TEMPOT - QA1T
	 QA3P = 2.0D0*PHIPHI*(1.0D0+TEMPOP) - QA1P
	 QA3R = 4.0D0*PHIPHI - QA1R
	 TEMP1 = A1*V
	 TEMP2 = A3*V*V*V
	 TEMP3 = 1.0D0/VP
	 QVT = -(TEMP1*QA1T + TEMP2*QA3T)*TEMP3
	 QVP = -(TEMP1*QA1P + TEMP2*QA3P)*TEMP3
	 QVR = -(TEMP1*QA1R + TEMP2*QA3R)*TEMP3
	 TEMP1 = DELDEL*(A1+V+V)
	 TEMP2 = DELDEL*A1*V
	 DELI = 1.0D0/DEL
	 QACT = (QDELAT+QDDELT*DDEL+TEMP1*QVT+TEMP2*QA1T)*DELI
	 QACP = (QDELAP+QDDELP*DDEL+TEMP1*QVP+TEMP2*QA1P)*DELI
	 QACR = (TEMP1*QVR+TEMP2*QA1R)*DELI
      ENDIF
  200 CONTINUE

      RETURN
      END
