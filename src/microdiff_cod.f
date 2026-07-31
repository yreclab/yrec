CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C MICRODIFF_COD
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE MICRODIFF_COD(NPT,ESPEC,ER,EDEN,ETEM,EHQPR,EDELR,
     *                ECOD1,ECOD2,EDXDR,THEA,THEZ,J)

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/GRAVS3/FGRY,FGRZ,LTHOUL,LDIFZ
      COMMON/CONST1/ CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      COMMON/SCRTCH/SESUM(JSON),SEG(7,JSON),SBETA(JSON),SETA(JSON),
     *       LOCONS(JSON),SO(JSON),SDEL(3,JSON),SFXION(3,JSON),SVEL(JSON),SCP(JSON)
      COMMON/THEAGE/DAGE
      DIMENSION ER(JSON),ESPEC(3,JSON),EDEN(JSON),ETEM(JSON),  ! ED(JSON)
     *          EHQPR(JSON),EDELR(JSON),ECOD1(JSON),ECOD2(JSON),
     *          ATOMWT(4),ZSPEC(4),XFRAC(4),TCL(4,4),TAP(4),TAT(4),TAC(4,4),
     *          FACS(JSON),APS(JSON),ATS(JSON),AHS(JSON),ADS(JSON),
C      *          HYDCON(JSON),EDXDR(JSON),FGRLI(4)  ! KC 2025-05-31
     *          HYDCON(JSON),EDXDR(JSON)

      REAL*8 ZXA,AC,NI,CZ,XIJ,NE,AO,LAMBDAD,LAMBDA,CONCEN(4)
      REAL*8 LN_LAMBDA
      DATA NSPEC/4/
C       DATA FGRLI/1.0,1.0,1.0,1.0/
      SAVE
C G Somers 5/15: THIS IS A SUBROUTINE WRITEN TO CALCULATE THE DIFFUSION
C COEFFICIENT ON THE EQUALLY-SPACED GRID USED FOR LIGHT ELEMENT DIFFUSION.
C THIS CODE TAKES IN THE NECESSARY PARAMETERS ON THE EQUAL GRID (NAMELY
C HCOMP(1,I), HCOMP(2,I), HCOMP(13-15,I), DENSITY, TEMPERATURE, HQPR,
C AND DELR(2,I)
C
C SET UP THE ATOMIC WEIGHT AND CHARGE MATRICIES
      ATOMWT(1) = 1.008D0
      ATOMWT(2) = 4.004D0
      ATOMWT(3) = THEA
      ATOMWT(4) = 5.486D-4
      ZSPEC(1) = 1.0D0
      ZSPEC(2) = 2.0D0
      ZSPEC(3) = THEZ
      ZSPEC(4) = -1.0D0
C SET LN_LAMBDA, CON_RAD, AND CON_TEMP.
      LN_LAMBDA = 2.2
      CON_RAD=1.0D0/6.9598D10
      CON_TEMP=1.0D-7
C CALCULATE DIFFUSION COEFFICIENTS FOR EACH LAYER.
      DO 5 I = 1,NPT
         XFRAC(1) = ESPEC(1,I)
         XFRAC(2) = ESPEC(2,I)
         XFRAC(3) = ESPEC(3,I)
c make sure XFRAC = 0.0 isn't used for diff coefficients
         IF (XFRAC(1).LT.1.0D-24) XFRAC(1) = 1.0D-24
         IF (XFRAC(2).LT.1.0D-24) XFRAC(2) = 1.0D-24
         IF (XFRAC(3).LT.1.0D-24) XFRAC(3) = 1.0D-24
c        calculate concentrations from mass fractions:
         ZXA=0.D0
         DO II=1,NSPEC-1
             ZXA=ZXA+ZSPEC(II)*XFRAC(II)/ATOMWT(II)
         ENDDO
         DO II=1,NSPEC-1
            CONCEN(II)=XFRAC(II)/(ATOMWT(II)*ZXA)
         ENDDO
         CONCEN(NSPEC)=1.D0
c        save the hydrogen concentration when X is diffused.
         IF(J.EQ.1) HYDCON(I) = CONCEN(1)
c        now check whether the Thoul routine must be run. if not,
c        write COD1 = COD2 = 0. If its the first shell in the depleted
C        zone, permit the calculations so that AD is correct.
         IF(ESPEC(J,I).EQ.0.0.AND.I.NE.NPT)THEN
            IF(ESPEC(J,I+1).EQ.0.0)THEN
               ADS(I) = 0.0
               GOTO 5
            ENDIF
         ENDIF
c        set relevant physical variables.
         RHO = EDEN(I)
         T = ETEM(I)
c        calculate density of electrons (NE) from mass density (RHO):
         AC=0.D0
         DO II=1,NSPEC
          AC=AC+ATOMWT(II)*CONCEN(II)
         ENDDO
         NE=RHO/(1.6726D-24*AC)
c        calculate interionic distance (AO):
         NI=0.D0
         DO II=1,NSPEC-1
            NI=NI+CONCEN(II)*NE
         ENDDO
         AO=(0.23873D0/NI)**CC13
c        calculate Debye length (LAMBDAD):
         CZ=0.D0
         DO II=1,NSPEC
          CZ=CZ+CONCEN(II)*ZSPEC(II)**2
         ENDDO
         LAMBDAD=6.9010D0*SQRT(T/(NE*CZ))
c        calculate LAMBDA to use in Coulomb logarithm:
         LAMBDA=MAX(LAMBDAD,AO)
c        calculate Coulomb logarithms:
         DO II=1,NSPEC
            DO JJ=1,NSPEC
               XIJ=2.3939D3*T*LAMBDA/ABS(ZSPEC(II)*ZSPEC(JJ))
               TCL(II,JJ)=0.81245D0
     *         *LOG(1.D0+0.18769D0*XIJ**1.2D0)
          ENDDO
         ENDDO
c
c        calculate the diffusion coefficients
c
         CALL THDIFF(NSPEC,ATOMWT,ZSPEC,XFRAC,TCL,TAP,TAT,TAC)
C
         HRU_I = ER(I)
         HTU_I = T*CON_TEMP
c         FAC=FGRLI(KK)*HRU_I**2*HTU_I**2.5D0/LN_LAMBDA
         FAC=HRU_I**2*HTU_I**2.5D0/LN_LAMBDA
c        collect the first diffusion terms for hydroden.
c        collect the third diffusion terms for everything else.
         AP = -TAP(J)
         AT = -TAT(J)*EDELR(I)
         AH = -TAC(J,1)
         AD = -TAC(J,J)
c        store the numbers so the hydrogen gradient can finish
c        being calculated; then use them later.
         FACS(I) = FAC
         APS(I) = AP
         ATS(I) = AT
         AHS(I) = AH
         ADS(I) = AD
    5 CONTINUE
      DO 10 I = 1,NPT
         FAC = FACS(I)
         AP = APS(I)
         AT = ATS(I)
         AH = AHS(I)
         AD = ADS(I)
c
c        The general diffusion velocity is written as:
c        Ap(D)*dlnP/dR + At(D)*dlnT/dR + Ax(D)*dlnX/dR + Ad(D)*dlnD/dR
c        The first two terms are pressure and temperature gradients, and
c        the last two terms are the hydrogen gradient and the diffused element
c        gradient. For hydrogren diffusion, we can neglect the third term, as
c        it is the same as the final term. For metal diffusion, we need all
c        four. (see Thoul et al. 1994 for details)
c
C        calculate the hydrogen gradient if diffusing X, then set
C        the local gradient to 0 to remove 2nd self-diff term.
C        look it up otherwise.
C
C        only calculate the gradient on the hydrogen call.
C        set the gradient at first and last points to 0.
c
         IF(J.EQ.1)THEN
            DLNCDR = 1.0
            IF (I.EQ.1) THEN
               DLNCDR = 0.0
            ELSEIF (I.EQ.NPT) THEN
               DLNCDR = 0.0
            ELSE
               CONI = LOG(HYDCON(I))
               CONIP1 = LOG(HYDCON(I+1))
               CONIM1 = LOG(HYDCON(I-1))
               DRADI = ER(I+1)-ER(I)
               T1 = (CONI-CONIM1)/DRADI
               T2 = (CONIP1-CONI)/DRADI
               DLNCDR = 0.5*(T1+T2)
            ENDIF
            EDXDR(I) = DLNCDR
c           zero out gradient for hydrogen abundance, as stated above.
            DLNCDR = 0.0
         ELSE
c           if not the hydrogen call, retrieve the gradient
            DLNCDR = EDXDR(I)
         ENDIF
         ECOD1(I) = FAC*(EHQPR(I)*(AP+AT)+DLNCDR*AH)*ESPEC(J,I)
         ECOD2(I) = FAC*AD
   10 CONTINUE
      RETURN
      END
