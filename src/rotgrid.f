C $$$$$$
      SUBROUTINE ROTGRID(COD,COD2,HD,HI,HJMSAV,HL,HP,HR,HRU,HS,HS1,HS2,
     *                   HSTOT,IBEG,IEND,LCZ,M,WSAV,DR,ECOD,
     *                   ECOD2,EI,EJ,EM,EW,LDUM2)
      PARAMETER (JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL
      COMMON/CONST1/CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      COMMON/CONST2/CGAS,CA3,CA3L,CSIG,CSIGL,CGL,CMKH,CMKHN
      COMMON/CTOL/HTOLER(5,2),FCORR0,FCORRI,FCORR,HPTTOL(12),NITER1,
     *     NITER2,NITER3
      COMMON/EGRID/CHI(JSON),ECHI(JSON),ES1(JSON),DCHI,NTOT
      COMMON/MDPHY/AMUM(JSON),CPM(JSON),DELM(JSON),DELAM(JSON),
     *             DELRM(JSON),ESUMM(JSON),OM(JSON),QDTM(JSON),
     *             THDIFM(JSON),VELM(JSON),VISCM(JSON),EPSM(JSON)
      COMMON/SPLIN/XVAL(JSON),YVAL(JSON),XTAB(JSON),YTAB(JSON)  
C MHP 05/02
      COMMON/DIFAD/ECOD3(JSON),ECOD4(JSON)
      COMMON/DIFAD2/VESA(JSON),VESA0(JSON),VESD(JSON),VESD0(JSON)
      COMMON/VARFC/VFC(JSON),LVFC,LDIFAD
      COMMON/VMULT/FW,FC,FO,FES,FGSF,FMU,FSS,RCRIT
C INPUT VARIABLES
      DIMENSION HD(JSON),HI(JSON),HJMSAV(JSON),HL(JSON),HP(JSON),
     *          HR(JSON),HRU(JSON),HS(JSON),HS1(JSON),HS2(JSON),
     *          LCZ(JSON),WSAV(JSON),COD(JSON),COD2(JSON)
C OUTPUT VARIABLES
      DIMENSION ECOD(JSON),ECOD2(JSON),EI(JSON),EJ(JSON),EM(JSON),
     *          EW(JSON),EI0(JSON)
C FLAG THE SPECIAL CASE OF A SINGLE UNSTABLE INTERFACE AND EXIT
      SAVE
      IF(IEND-IBEG.LE.1)THEN
         LDUM2 = .TRUE.
         GOTO 9999
      ELSE
         LDUM2 = .FALSE.
      ENDIF
C DEFINE A GRID OF EQUALLY SPACED POINTS.
      CALL GETGRID(HL,HP,HS,IBEG,IEND,M)
C GETGRID HAS DEFINED A SET OF CO-ORDINATES (CHI) AND EQUALLY SPACED
C MASS POINTS.  NOW FIND THE OTHER QUANTITIES OF INTEREST AT ZONE 
C CENTERS:
C J/M (TO GET JTOT)
C I/MR^2 (TO GET ITOT)
C OMEGA
C R (NEEDED FOR I CALCULATION) - STORED IN YVAL
      NTAB = IEND - IBEG + 1
      DO I = 1,NTAB
         II = IBEG + I - 1
         XTAB(I) = CHI(I)
         YTAB(I) = HR(II)
      END DO
      DO I = 1,NTOT
         XVAL(I) = ECHI(I)
      END DO
      CALL OSPLIN(XVAL,YVAL,XTAB,YTAB,NTAB,NTOT)
C I/MR^2
      DO I = 1,NTAB
         II = IBEG + I - 1
         YTAB(I) = HI(II)/(HS2(II)*HRU(II)**2)
      END DO
C MHP 05/02 STORE I/MR^2 FOR LATER USE IN
C DIFFUSION COEFFICIENTS FOR ANGULAR MOMENTUM
C TRANSPORT
      CALL OSPLIN(XVAL,EI0,XTAB,YTAB,NTAB,NTOT)
C J/M 
      DO I = 1,NTAB
         II = IBEG + I - 1
         YTAB(I) = HJMSAV(II)
      END DO
      CALL OSPLIN(XVAL,EJ,XTAB,YTAB,NTAB,NTOT)
C OMEGA
      DO I = 1,NTAB
         II = IBEG + I - 1
         YTAB(I) = WSAV(II)
      END DO
      CALL OSPLIN(XVAL,EW,XTAB,YTAB,NTAB,NTOT)
C CONVERT TO TOTAL I AND TOTAL J OF THE ZONES.
C INTERMEDIATE POINTS
      DO I = 2, NTOT-1
         EM(I) = 0.5D0*(ES1(I+1)-ES1(I-1))
C MHP 05/02 CHANGED TO REFLECT THE FACT THAT
C THE INFO PREVIOUSLY STORED IN EI IS NOW IN EI0
         EI(I) = EI0(I)*EM(I)*EXP(CLN*2.0D0*YVAL(I))
         EJ(I) = EJ(I)*EM(I)
      END DO
C SPECIAL TREATMENT OF THE BOUNDARIES; CAN BE CONVECTIVE.
C IF CONVECTIVE SUM OVER ALL SHELLS.  CARE IS NEEDED TO DO BOOK-KEEPING
C PROPERLY AT THE EDGES - TOP IS HALFWAY TO EQUALLY SPACED POINT, NOT
C HALFWAY TO EDGE OF UNEQUALLY SPACED ORIGINAL SET OF POINTS.
C
C CENTER
      EMTOP = 0.5D0*(ES1(2)+ES1(1))
      IF(IBEG.GT.1)THEN
         EMBOT = 0.5D0*(HS1(IBEG)+HS1(IBEG-1))
      ELSE
         EMBOT = 0.0D0
      ENDIF
      EM(1) = EMTOP - EMBOT
C MHP 05/02 CHANGED TO REFLECT THE FACT THAT
C THE INFO PREVIOUSLY STORED IN EI IS NOW IN EI0
      EI(1) = EI0(1)*EM(1)*HRU(IBEG)**2
      EJ(1) = EJ(1)*EM(1)
      IF(IBEG.GT.1)THEN
         DO II = IBEG-1,1,-1
            IF(.NOT.LCZ(II))THEN
               I0 = I + 1
               GOTO 10
            ENDIF
            EM(1) = EM(1)+HS2(II)
            EI(1) = EI(1)+HI(II)
            EJ(1) = EJ(1)+HJMSAV(II)*HS2(II)
         END DO
         I0 = 1
 10      CONTINUE
      ELSE
         I0 = 1
      ENDIF
C SURFACE
      EMBOT = 0.5D0*(ES1(NTOT)+ES1(NTOT-1))
      IF(IEND.LT.M)THEN
         EMTOP = 0.5D0*(HS1(IEND)+HS1(IEND+1))
      ELSE
         EMTOP = EXP(CLN*HSTOT)
      ENDIF
      EM(NTOT) = EMTOP - EMBOT
C MHP 05/02 CHANGED TO REFLECT THE FACT THAT
C THE INFO PREVIOUSLY STORED IN EI IS NOW IN EI0
      EI(NTOT) = EI0(NTOT)*EM(NTOT)*HRU(IEND)**2
      EJ(NTOT) = EJ(NTOT)*EM(NTOT)
      IF(IEND.LT.M)THEN
         DO II = IEND+1,M
            IF(.NOT.LCZ(II))THEN
               I1 = I -1
               GOTO 20
            ENDIF
            EM(NTOT) = EM(NTOT)+HS2(II)
            EI(NTOT) = EI(NTOT)+HI(II)
            EJ(NTOT) = EJ(NTOT)+HJMSAV(II)*HS2(II)
         END DO
         I1 = M
 20      CONTINUE
      ELSE
         I1 = M
      ENDIF
C NOW SOLVE FOR QUANTITIES NEEDED AT THE ZONE EDGES.  THESE ARE
C RELATED TO THE DIFFUSION COEFFICIENTS.  UNLIKE THE EQUALLY SPACED
C GRID IN R, WE NEED TO INCLUDE A JACOBIAN TERM FOR THE TRANSFORMATION
C OF VARIABLES.
C DIFFUSION COEFFICIENT FOR ANGULAR MOMENTUM - ASSUME CONSTANT BELOW 
C BOTTOM INTERFACE OR ABOVE TOP INTERFACE
      XTAB(1) = CHI(1)
      YTAB(1) = COD(IBEG+1)
      DO I = 2,NTAB
         II = IBEG + I - 1
         XTAB(I) = 0.5D0*(CHI(I)+CHI(I-1))
         YTAB(I) = COD(II)
      END DO
      NTABB = NTAB + 1
      XTAB(NTABB) = CHI(NTAB)
      YTAB(NTABB) = COD(IEND)
      XVAL(1) = CHI(1)
      DO I = 2, NTOT
         XVAL(I) = ECHI(I)-0.5D0*DCHI
      END DO
      CALL OSPLIN(XVAL,ECOD,XTAB,YTAB,NTABB,NTOT)
C DIFFUSION COEFFICIENT FOR MIXING - ASSUME CONSTANT BELOW 
C BOTTOM INTERFACE OR ABOVE TOP INTERFACE
      YTAB(1) = COD2(IBEG+1)
      DO I = 2,NTAB
         II = IBEG + I - 1
         YTAB(I) = COD2(II)
      END DO
      YTAB(NTABB) = COD2(IEND)
      CALL OSPLIN(XVAL,ECOD2,XTAB,YTAB,NTABB,NTOT)
C ADD DIFFUSION PLUS ADVECTION TREATMENT IF DESIRED
      IF(LDIFAD)THEN
         FAC = 0.2D0*C4PI*FW
         YTAB(1) = FAC*VESA(IBEG + 1)
         DO I = 2,NTAB
            II = IBEG + I - 1
            YTAB(I) = FAC*VESA(II)
         END DO
         YTAB(NTABB) = FAC*VESA(IEND)
         CALL OSPLIN(XVAL,ECOD3,XTAB,YTAB,NTABB,NTOT)
         YTAB(1) = FAC*VESD(IBEG + 1)
         DO I = 2,NTAB
            II = IBEG + I - 1
            YTAB(I) = FAC*VESD(II)
         END DO
         YTAB(NTABB) = FAC*VESD(IEND)
         CALL OSPLIN(XVAL,ECOD4,XTAB,YTAB,NTABB,NTOT)
C MHP 05/02 NOTE THAT THE COMPOSITION DIFFUSION COEFFICIENTS
C SHOULD BE ADDED TO THE DIFFUSIVE PART OF THE DIFFUSION + ADVECTION
C ANGULAR MOMENTUM TRANSPORT; C.F. ZAHN 1992.  ESSENTIALLY THE
C ORIGINAL VESD TERM IS THE DIFFUSIVE COMPONENT FROM HORIZONTAL
C TRANSPORT WHILE THE COD2 TERM REPRESENTS THE DIFFUSIVE COMPONENT
C FROM VERTICAL TRANSPORT.
         DO I = 1, NTOT
            ECOD4(I) = ECOD4(I) + ECOD2(I)
         END DO
      ENDIF
C PRODUCT OF RHO R^2 BY D CHI/DR
      DM = HPTTOL(2)
      DL = HPTTOL(9)*HL(M)*CLSUN
      DP = HPTTOL(11)
      DO I = 1, NTAB
         II = IBEG + I - 1
         XTAB(I) = CHI(I)
C D CHI/DR = 1/DM*( D LOG M/DR) + 1/DL*(DL/DR) - 1/DP*(D LOG P/DR)
C OR, USING FAC = 4*PI*RHO*R**2
C D CHI/DR = FAC/(LN 10 * DM * M) + FAC*EPSILON/DL + RHO*GM/(LN10*DP*R**2)
C STORED IN YVAL
         FAC = C4PI*EXP(CLN*(HD(II)+2.0D0*HR(II)))
         QCHIR = FAC/(CLN*DM*HS1(II))+FAC*EPSM(II)/DL+
     *   EXP(CLN*(CGL+HD(II)+HS(II)-HP(II)-2.0D0*HR(II)))/(CLN*DP) 
         YTAB(I) = HD(II) + LOG10(QCHIR) + 2.0D0*HR(II)
      END DO
      CALL OSPLIN(XVAL,YVAL,XTAB,YTAB,NTAB,NTOT)
C NOW ADD MULTIPLICATIVE FACTORS TO DIFFUSION COEFFICIENTS
C NOTE THAT A FACTOR OF 4PI HAS ALREADY BEEN INCLUDED IN
C CODIFF.
      DO I = 1, NTOT
         ECOD2(I) = ECOD2(I)*EXP(CLN*YVAL(I))
      END DO
C PRODUCT OF RHO R^4 BY D CHI/DR - STORED IN YVAL
C MHP 05/02 ADDED FACTOR OF I/MR^2 - 2/3 FOR A SPHERICAL SHELL
      DO I = 1, NTAB
         II = IBEG + I - 1
C         YTAB(I) = YTAB(I) + 2.0D0*HR(II) + LOG10(EI0(I))
         YTAB(I) = YTAB(I)  + LOG10(HI(II)/HS2(II))
      END DO
      CALL OSPLIN(XVAL,YVAL,XTAB,YTAB,NTAB,NTOT)
C NOW ADD MULTIPLICATIVE FACTORS TO DIFFUSION COEFFICIENTS
      DO I = 1, NTOT
         ECOD(I) = ECOD(I)*EXP(CLN*YVAL(I))
      END DO
C MHP 05/02
      IF(LDIFAD)THEN
         DO I = 1,NTOT
            ECOD3(I) = ECOD3(I)*EXP(CLN*YVAL(I))
            ECOD4(I) = ECOD4(I)*EXP(CLN*YVAL(I))
         END DO
      ENDIF
C REDEFINE DR AS DCHI
      DR = DCHI
 9999 CONTINUE
      RETURN
      END
