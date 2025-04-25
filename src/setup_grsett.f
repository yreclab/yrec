C $$$$$$
      SUBROUTINE SETUP_GRSETT(DT,HQPR,HR,HD,HS1,HT,LC,M,STOT,COD1,COD2,
     *             HCOMP,HRU,HTU,IBEGIN,IEND,LALLCZ,QCOD1X,QCOD2X)

      use params, only : json
      use settings, only : ISHORT  ! /LUOUT/
      use settings, only : CLN, CC13  ! /CONST1/
      use settings, only : XMIN, YMIN, LTHOULFIT  ! /GRAVS2/
      use settings, only : FGRY, FGRZ, LTHOUL, LDIFZ  ! /GRAVS3/
      use settings, only : ILAMBDA  ! /GRAVST/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      COMMON/CONFAC/CON_RAD,CON_MASS,CON_TEMP,CON_TIME
      COMMON/SCRTCH/SESUM(JSON),SEG(7,JSON),SBETA(JSON),SETA(JSON),
     *LOCONS(JSON),SO(JSON),SDEL(3,JSON),SFXION(3,JSON),SVEL(JSON)
C MHP 3/94 ADDED METAL DIFFUSION
      COMMON/GRAVSZ/COD1Z(JSON),COD2Z(JSON),QCOD1Z(JSON),QCOD2Z(JSON)
C MHP 8/94 ADDED I/O FOR DIFFUSION
      COMMON/GSCOF/APP(JSON),ATP(JSON),APZP(JSON),ATZP(JSON)
C      COMMON/GSCOF2/TAPP(JSON),TATP(JSON),TCLP(JSON),TAPZP(JSON),
C     *              TATZP(JSON)
CFD 10/09 ADDED COMMON BLOCK FOR EXTRA MIXING. IT MIMIC SOME MIXING BY AFFECTING
C        THE SETTLING COEFFICIENT DIRECTLY (in setup_grsett.f)
      COMMON/CMIXING/CSTMIXING, CSTDIFFMIX
C
      DIMENSION HQPR(JSON),HR(JSON),HS1(JSON),HT(JSON),LC(JSON),
     *          HRU(JSON),HTU(JSON),COD1(JSON),COD2(JSON),QCOD1X(JSON),
     *          QCOD2X(JSON),HCOMP(15,JSON),HD(JSON)
C MHP 8/94 ADDED ATOMIC WEIGHTS AND CHARGES FOR H,HE,FE,ELECTRONS -
C     NEEDED FOR FULL THOUL COEFFICIENTS
      DIMENSION ATOMWT(4),ZSPEC(4),TAP(4),TAT(4),TAC(4,4),
     *          TCL(4,4),XFRAC(4)
c     additional variables to be declared for variable ln lambda
c     intermediate variables:
      REAL*8 ZXA,AC,NI,CZ,XIJ,NE,AO,LAMBDAD,LAMBDA,C(4)
      REAL*8 LN_LAMBDA
      DATA ATOMWT/1.008D0,4.004D0,55.86D0,5.486D-4/
      DATA ZSPEC/1.0D0,2.0D0,26.0D0,-1.0D0/
      DATA NSPEC/4/
      SAVE


C     OUTPUT VARIABLES :
C
C     HRU - VECTOR OF UNLOGGED RADII IN BAHCALL AND LOEB UNITS.
C     HTU - VECTOR OF UNLOGGED TEMPERATURES IN BAHCALL AND LOEB UNITS.
C     IBEGIN - FIRST ZONE FOR DIFFUSION PURPOSES (EITHER THE FIRST MODEL POINT
C          OR THE OUTERMOST POINT OF A CENTRAL CONVECTION ZONE).
C     IEND - LAST ZONE FOR DIFFUSION PURPOSES (EITHER THE LAST MODEL POINT OR
C        THE INNERMOST POINT OF A SURFACE CONVECTION ZONE).
C     THE VECTORS HQPR AND HS1, AND THE SCALARS DT AND STOT, ARE ALSO CONVERTED
C     TO BAHCALL AND LOEB UNITS.
C     CONSTANTS DEFINED :
C     CLN = CONVERSION FACTOR FROM LN TO LOG10
C     CRSUN_BAH = SOLAR RADIUS (CM)
C     CSECYR_BAH = NUMBER OF SECONDS IN A YEAR.
      CRSUN_BAH=6.9598D10
      CSECYR_BAH=3.1558D7
C     LALLCZ=T FOR FULLY CONVECTIVE MODEL(AND IF TRUE, DIFFUSION IS SKIPPED).
      LALLCZ=.FALSE.
C     CHECK FOR CONVECTIVE CORE.
      IF(LC(1))THEN
         DO 10 I=2,M
            IF(.NOT.LC(I))GOTO 20
   10    CONTINUE
C        DIFFUSION NOT COMPUTED FOR FULLY CONVECTIVE MODELS.
         LALLCZ=.TRUE.
         WRITE(ISHORT,15)
   15    FORMAT(1X,' FULLY CONVECTIVE MODEL - NO SETTLING')
         GOTO 9999
   20    CONTINUE
C        COMPUTE OVERSHOOT (TO BE ADDED).
         IBEGIN = I-1
      ELSE
         IBEGIN = 1
      ENDIF
C MHP 6/90 CHECK FOR HYDROGEN-EXHAUSTED CORE.
      DO 23 I = IBEGIN,M
         IF(HCOMP(1,I).GT.XMIN)GOTO 25
   23 CONTINUE
C     HYDROGEN-FREE MODEL - EXIT.
      WRITE(ISHORT,16)XMIN
   16 FORMAT(1X,'X BELOW ',F9.6,' IN WHOLE MODEL-NO SETTLING')
      LALLCZ = .TRUE.
      GOTO 9999
   25 CONTINUE
      IBEGIN = I
C     CHECK FOR CONVECTIVE ENVELOPE.
      IF(LC(M))THEN
         DO 30 I=M-1,2,-1
            IF(.NOT.LC(I))GOTO 40
   30    CONTINUE
   40    CONTINUE
C        COMPUTE OVERSHOOT (TO BE ADDED).
         IEND = I+1
      ELSE
         IEND = M
      ENDIF
C     CHECK FOR HELIUM-EXHAUSTED SURFACE.
C     OUTER POINT IS SET WHEREVER Y>YMIN.
      DO 45 I=IEND,1,-1
         IF(HCOMP(2,I).GT.YMIN) GOTO 47
   45 CONTINUE
C     HYDROGEN-FREE MODEL - EXIT.
      WRITE(ISHORT,17)YMIN
   17 FORMAT(1X,'Y BELOW ',F9.6,' IN WHOLE MODEL-NO SETTLING')
      LALLCZ = .TRUE.
      GOTO 9999
   47 CONTINUE
      IEND = I
C     CON_MASS=CONVERSION FACTOR FOR MASS.
C     CON_RADIUS=CONVERSION FACTOR FOR RADIUS.
C     CON_TEMP=CONVERSION FACOTR FOR TEMPERATURE.
C     CON_TIME=CONVERSION FACTOR FOR TIME.
      CON_RAD=1.0D0/CRSUN_BAH
      CON_MASS=1.0D-2*CON_RAD**3
      CON_TEMP=1.0D-7
C     INCLUDES FACTOR OF 2.2 FROM LN LAMBDA
      CON_TIME=2.7D13*CSECYR_BAH
C     CONVERT LOG(RADIUS) AND LOG(TEMPERATURE) TO NATURAL UNITS.
C     ALSO CONVERT NATURAL UNITS TO BAHCALL AND LOEB UNITS.
      DO 50 I=1,M

         HRU(I)=EXP(CLN*HR(I))*CON_RAD
         HTU(I)=EXP(CLN*HT(I))*CON_TEMP
         HS1(I)=HS1(I)*CON_MASS
         HQPR(I)=HQPR(I)/CON_RAD
C        SDEL(2,I)=0.4D0   !COMMENT OUT IN REAL CODE
   50 CONTINUE
      DT=DT/CON_TIME
      STOT=STOT*CON_MASS
C     SET UP DIFFUSION COEFFICIENTS.
C     MODIFIED BY BC MAY/90 -- VALID FOR ALL X WITH VARIABLE LN LAMBDA
C     GENERAL EQUATION IS
C     DX/DT = (D/DR(D1)+D/DR(D2 DX/DR))/(RHO*R**2), WHERE
C     D1 = R**2/LN LAMBDA  * X  * T**5/2 * (DLNP/DR) * (1-X) *
C          [5/4 + DEL*6*(X-0.32)/(5.4+6.3X-4.5X**2)]
C     D2 = R**2/LN LAMBDA * T**5/2 * (X+3)/(X+1)/(3+5X)
      DO 60 I = 1,M

         X = HCOMP(1,I)
C MHP 10/02 INITIALIZED X - WAS NOT DONE PRIOR TO USAGE IN SHELL 1
         IF(ILAMBDA.EQ.2)THEN
C           Noerdlinger's formula (1977 A&A 57,407) for LN LAMBDA:
C           Ln Lambda = -19.7 - ln[4/(3*X + 1)]/2 - ln(rho)/2 + 1.5*ln(T)
            LN_LAMBDA=-1.97D1 - 0.5D0*LOG(1.0D0/(0.75D0*X+0.25D0))
     *                -0.5D0*HD(I)*CLN + 1.5D0*HT(I)*CLN
         ELSE IF(ILAMBDA.EQ.3)THEN
C           Loeb's formula (1989 Phys. Rev. D 39, 1009) for LN LAMBDA
C           ln lambda = -19.105747 - ln(rho)/2 + 1.5*ln(T)
            LN_LAMBDA=-1.9105747D1-0.50D0*HD(I)*CLN+1.5D0*HT(I)*CLN
         ELSE
            LN_LAMBDA = 2.2D0
         END IF
C
         FAC=FGRY*HRU(I)**2*HTU(I)**2.5D0/LN_LAMBDA
C         X = HCOMP(1,I)
         Z = HCOMP(3,I) + HCOMP(4,I)
         ZZ = HCOMP(3,I)
         X2 = X*X
         IF(.NOT.LTHOUL)THEN
            XZ = X*Z
            X3 = X2*X
            FAC2=5.4D0+6.3D0*X-4.5D0*X2
            COD1(I)=FAC*HQPR(I)*(X - X2 - XZ)*(1.25D0+
     *           SDEL(2,I)*6.0D0*(X+0.32D0)/FAC2)
            COD2(I)=FAC*(X+3.0D0)/(5.0D0*X2 + 8.0D0*X + 3.0D0)
            QCOD1X(I)=FAC*HQPR(I)*( (1.0D0-2.0D0*X-Z)*(1.25D0+
     *      (6.0D0*SDEL(2,I)*(X+0.32D0))/FAC2)+(X-X2-XZ)*6.0D0*
     *          SDEL(2,I)*(3.384D0+2.88D0*X+4.5D0*X2)/FAC2**2 )
            QCOD2X(I)=-FAC*(5.0D0*X2 + 3.0D1*X + 2.1D1)/
     *              (5.0D0*X2 + 8.0D0*X + 3.0D0)**2
         ELSE
            XFRAC(1) = HCOMP(1,I)
            XFRAC(2) = HCOMP(2,I)
            XFRAC(3) = HCOMP(3,I)
            IF(.NOT.LTHOULFIT)THEN
               IF(ILAMBDA.EQ.4)THEN
                  RHO = EXP(CLN*HD(I))
                  T = EXP(CLN*HT(I))
c                 calculate concentrations from mass fractions:
                  ZXA=0.D0
                  DO II=1,NSPEC-1
                   ZXA=ZXA+ZSPEC(II)*XFRAC(II)/ATOMWT(II)
                  ENDDO
                  DO II=1,NSPEC-1
                     C(II)=XFRAC(II)/(ATOMWT(II)*ZXA)
                  ENDDO
                  C(NSPEC)=1.D0
c                 calculate density of electrons (NE) from mass density (RHO):
                  AC=0.D0
                  DO II=1,NSPEC
                   AC=AC+ATOMWT(II)*C(II)
                  ENDDO
                  NE=RHO/(1.6726D-24*AC)
c                 calculate interionic distance (AO):
                  NI=0.D0
                  DO II=1,NSPEC-1
                     NI=NI+C(II)*NE
                  ENDDO
                  AO=(0.23873D0/NI)**CC13
c                 calculate Debye length (LAMBDAD):
                  CZ=0.D0
                  DO II=1,NSPEC
                   CZ=CZ+C(II)*ZSPEC(II)**2
                  ENDDO
                  LAMBDAD=6.9010D0*SQRT(T/(NE*CZ))
c                 calculate LAMBDA to use in Coulomb logarithm:
                  LAMBDA=MAX(LAMBDAD,AO)
c                 calculate Coulomb logarithms:
                  DO II=1,NSPEC
                   DO JJ=1,NSPEC
                      XIJ=2.3939D3*T*LAMBDA/ABS(ZSPEC(II)*ZSPEC(JJ))
                      TCL(II,JJ)=0.81245D0
     *                       *LOG(1.D0+0.18769D0*XIJ**1.2D0)
                   ENDDO
                  ENDDO
               ELSE
                  DO II = 1,NSPEC
                     DO JJ = 1,NSPEC
                        TCL(II,JJ) = LN_LAMBDA
                     END DO
                  END DO
               ENDIF
               CALL THDIFF(NSPEC,ATOMWT,ZSPEC,XFRAC,TCL,TAP,TAT,TAC)
               AP = -TAP(1)
               AT = -SDEL(2,I)*TAT(1)
            ELSE
               AP = 1.58D0 - 2.42D0*X + 0.844D0*X2
               AT = SDEL(2,I)*(1.90D0 - 2.69D0*X + 0.805D0*X2)
            ENDIF
            AC = 1.15D0 - 1.42D0*X + 0.647D0*X2
            QAPX = -2.42D0 + 1.688D0*X
            QATX = SDEL(2,I)*(-2.69D0 + 1.61D0*X)
            QACX = -1.42D0 + 1.294D0*X
CFD 10/09 Mimic Mixing to reduce settling.
C            COD1(I) = FAC*HQPR(I)*X*(AP+AT)
            COD1(I) = CSTMIXING*FAC*HQPR(I)*X*(AP+AT)
            COD2(I) = CSTMIXING*FAC*AC
            QCOD1X(I) = FAC*HQPR(I)*(AP+AT+X*(QAPX+QATX))
            QCOD2X(I) = FAC*QACX
         ENDIF
C        METAL DIFFUSION, USING THE THOUL ET AL. COEFFICIENTS FOR FULLY
C        IONIZED IRON.
         IF(LDIFZ)THEN

            FAC=FGRZ*HRU(I)**2*HTU(I)**2.5D0/LN_LAMBDA
            IF(LTHOUL)THEN
               IF(LTHOULFIT)THEN
                  AP = -0.157D0 -0.511D0*X + 0.389D0*X2
                  AT = SDEL(2,I)*(-1.36D0 - 1.42D0*X + 0.549D0*X2)
               ELSE
                  AP = -TAP(3)
                  AT = -SDEL(2,I)*TAT(3)
               ENDIF
               AH = -0.0375D0 -0.193D0*X + 0.107D0*X2
CFD 10/09 Mimic Mixing to reduce settling (cstmixing)
C         and add the uncertainties of differential mixing (cstdiffmix).
C
C old ver      COD1Z(I) = FAC*HQPR(I)*ZZ*(AP+AT)
               COD1Z(I) = CSTDIFFMIX*CSTMIXING*FAC*HQPR(I)*ZZ*(AP+AT)
C              POSITIVE DIFFUSION COEFFICIENTS NEEDED!
C old ver.     COD2Z(I) = ABS(FAC*AH)
C old ver.     QCOD1Z(I) = FAC*HQPR(I)*(AP+AT)
               COD2Z(I) = CSTMIXING*ABS(FAC*AH)
               QCOD1Z(I) = CSTMIXING*FAC*HQPR(I)*(AP+AT)
               QCOD2Z(I) = 0.0D0
            ENDIF
         ENDIF
C
C If using Noerdlinger's formula for LN LAMBDA, have a new term
C in D(D1)/DX
         IF(ILAMBDA.EQ.2)  THEN
           QCOD1X(I)=QCOD1X(I) + COD1(I)*1.5D0/
     *     (LN_LAMBDA*(3.0D0*X+1.0D0))
       END IF
   60 CONTINUE
 9999 CONTINUE
      RETURN
      END
