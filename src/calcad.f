C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CALCAD: links together and integrates sound speed profiles, for acoustic
C depth to convection zone, acoustic depth of atmosphere
C INPUTS:
C      HR: array of radii for the interiors solution
C      RCZ: physical radius of the convection zone (logged), calculated in wrtout
C      M: last interior point
C      HD: interior's density
C      HP: interior pressure
C      HT: interior temperature
C      BL: logged luminosity
C      FP: Rotational distortion, needed for envelope integration
C      FT: Rotational distortion, needed for envelope integration
C      HSTOT: needed for ENVINT
C      LPRT: needed for ENVINT
C      TEFFL: logged effective temperature
C      HCOMP: vector of compositions for interior
C      NKK: obsolete?
C       DAGE: Age
C       DDAGE: obsolete?
C
C
C
C
C OUTPUTS:
C       Adjusts the values in the common block for acoustic depth:
C            TAUCZN = acoustic depth to CZ / sound travel time from surface-center
C            TCZ = acoustic depth to CZ (seconds)
C            TNORM = sound travel time from surface to center (seconds)
C            DELADJ = adiabatic gradient from OPAL 2006 EOS or SCV EOS
C
C
C
C
C
C COMMON BLOCKED THINGS:
C
C        LCLCD = Logical flag for output of CALCAD files at AGEOUT ages
C        AGEOUT(5) = Ages for which you want output. Hard coded in parmin
C        IACAT =
C        IJLAST = Again, for output
C        LJLAST = Again, for output
C        LJWRT = ouput on/off toggle
C        LADON = toggle on calcad imposed 4d interpolation in opacity
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE CALCAD(HR, RCZL, M, HD, HP, HT, BL, FP, FT, HSTOT,
     *                  LPRT, TEFFL, HCOMP, NKK, DAGE, DDAGE, JENV)
        use params, only : json, nts, nps
      use settings, only : ISHORT  ! /LUOUT/
      use settings, only : STOTAL  ! /COMP/
      use settings, only : CLSUNL, CRSUNL  ! /CONST/
      use settings, only : CLN, C4PIL  ! /CONST1/
      use settings, only : CSIGL, CGL  ! /CONST2/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      REAL*8 HOOD1(7), HOOD2(7), D(7), ANS(1)
      REAL*8 DUM1(4),DUM2(3),DUM3(3),DUM4(3)
      REAL*8 XJ,ZJ,GLJ,RLJ,PLIMJ, BJ
      REAL*8 ABEG0,AMIN0,AMAX0,EBEG0,EMIN0,EMAX0
      REAL*8 STARR(JSON),START(JSON),STARD(JSON),STARX(JSON),STARP(JSON),
     *       STARZ(JSON),STARC(JSON),TNORM,TCZ,TAUCZN,STARCZ(JSON),STARRZ(JSON)
      REAL*8 ATMOSX, ATMOST(JSON),ATMOSD(JSON),ATMOSP(JSON),ADELAD(JSON),ATMOSC(JSON),
     *       ATGAM1(JSON), ATMOSR(JSON),GM1(JSON)
      INTEGER I, K, N, U, ICZ, NN, IENDJ, FLG, V, IATCNT, KTSAV
      INTEGER IDUMJ, KATMJ,KENVJ,KSAHAJ,IXXJ
      DIMENSION RCZL(1), RCZ(1),HR(JSON), HD(JSON), HP(JSON), BJ(1),FPLJ(1),FTLJ(1),
     * FT(JSON),FP(JSON), HCOMP(15,JSON), HT(JSON), HL(JSON)
      LOGICAL LTEST,LPULPTJ,LPRTJ,LSBC0J

      COMMON/ACDPTH/TAUCZN,DELADJ(JSON),TAUHE, TNORM, TCZ, WHE, ICLCD,
     *ACATMR(JSON), ACATMD(JSON), ACATMP(JSON), ACATMT(JSON),TATMOS,
     *LCLCD, AGEOUT(5), IACAT, IJLAST, LJLAST, LJWRT, LADON, LAOLY, IJVS,
     *IJENT, IJDEL, LACOUT
      COMMON/ENVSTRUCT/ENVP(JSON),ENVT(JSON),ENVS(JSON),ENVD(JSON),
     *                 ENVR(JSON),ENVX(JSON),ENVZ(JSON),LCENV(JSON),
     *                 NUMENV,EDELS(3,JSON),EVELS(JSON),EBETAS(JSON)
      COMMON/INTATM/ATMERR,ATMD0,ATMBEG,ATMMIN,ATMMAX
      COMMON/INTENV/ENVERR,ENVBEG,ENVMIN,ENVMAX
      COMMON/SCRTCH/SESUM(JSON),SEG(7,JSON),SBETA(JSON),SETA(JSON),
     *LOCONS(JSON),SO(JSON),SDEL(3,JSON),SFXION(3,JSON),SVEL(JSON)
       COMMON/SOUND/GAM1(JSON),LSOUND
      common/eeos06/esact,eos(10)
      COMMON /LLOT95/ZTAB
      COMMON/ENVGEN/ATMSTP,ENVSTP,LENVG
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50)
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
      COMMON/ATMOS/HRAS,KTTAU,KTTAU0,LTTAU
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *     TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *     TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDT,IDP
      COMMON/OPALEOS/FOPALE,LOPALE,IOPALE,fopale01,lopale01,fopale06,
     *     lopale06,lNumDeriv
C Added for experimantal mass loss section
      COMMON/MASSCHG/DMDT0,FCZDMDT,FTOTDMDT,COMPACC(15),CREIM,
     *               LREIMER,LMDOT
C G Somers 10/14, Add spot common block
      COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH
C G Somers END
      SAVE


C Initialize values:
      TAUCZN=0.0D0
      TCZ= 0.0D0
      TNORM=0.0D0
      WHE= 0.0D0
      TAUHE = 0.0D0
      ATMOSX=0.0D0
      TATMOS = 0.0D0
C      KTSAV = 3

C Need to calculate the sound speed in the envelope: first, stitch
C envelope and interior together (so that T, P, R all agree at fitting
C point. Then calculate sound speed in the envelope and interior
C and integrate.

C First, do the envelope integration to make sure the values in ENVSTRUCT
C are up-to-date (this section of code grabbed from wrtmod). First, integrate the atm and store values with grey atm
      ABEG0 = ATMBEG
      AMIN0 = ATMMIN
      AMAX0 = ATMMAX
      EBEG0 = ENVBEG
      EMIN0 = ENVMIN
      EMAX0 = ENVMAX
      ATMBEG = ATMSTP
      ATMMIN = ATMSTP
      ATMMAX = ATMSTP
      ENVBEG = ENVSTP
      ENVMIN = ENVSTP
      ENVMAX = ENVSTP
      IDUMJ = 0
      BJ = DEXP(CLN*BL)
      FPLJ(1) = FP(M)
      FTLJ(1) = FT(M)
      KATMJ = 0
      KENVJ = 0
      KSAHAJ = 0
      LPULPTJ=.TRUE.
      IXXJ=0
      LPRTJ=.TRUE.
      LSBC0J = .FALSE.
      XJ = HCOMP(1,M)
      ZJ = HCOMP(3,M)
      RLJ = 0.5D0*(BL + CLSUNL - 4.0D0*TEFFL - C4PIL - CSIGL)
      GLJ = CGL + STOTAL - RLJ - RLJ
      PLIMJ = HP(M)
c      IF (KTTAU .EQ. 0) LAOLY = .TRUE.
c      IF (KTTAU .EQ. 3) LAOLY = .FALSE.      ! for grey atm intergration: stores values in common block
C      G Somers 10/14, FOR SPOTTED RUNS, FIND THE PRESSURE AT
C      THE AMBIENT TEMPERATURE ATEFFL
      IF(JENV.EQ.M.AND.SPOTF.NE.0.0.AND.SPOTX.NE.1.0)THEN
            ATEFFL = TEFFL - 0.25*LOG10(SPOTF * SPOTX**4.0 + 1.0 - SPOTF)
      ELSE
            ATEFFL = TEFFL
      ENDIF
      CALL ENVINT(BJ,FPLJ,FTLJ,GLJ,HSTOT,IXXJ,LPRTJ,LSBC0J,
     *         PLIMJ,RLJ,ATEFFL,XJ,ZJ,DUM1,IDUMJ,KATMJ,KENVJ,KSAHAJ,
     *         DUM2,DUM3,DUM4,LPULPTJ)
C      G Somers END



C Stitch interior and envelope together, convert into ESAC06 units
      DO 34, I=1,M
            STARR(I)=DEXP(CLN*HR(I))            ! get unlogged units
            START(I)=DEXP(CLN*HT(I))/1.0D6      ! ESAC06 takes T in units of 10^6K
            STARD(I)=DEXP(CLN*HD(I))
            STARP(I)=DEXP(CLN*HP(I))
            STARX(I)=HCOMP(1,I)
            STARZ(I)=HCOMP(3,M)
34      CONTINUE
      DO 35, I=1,NUMENV-1
            STARR(M+I)=DEXP(CLN*ENVR(I+1))
            START(M+I)=DEXP(CLN*ENVT(I+1))/1.0D6
            STARD(M+I)=DEXP(CLN*ENVD(I+1))
            STARP(M+I)=DEXP(CLN*ENVP(I+1))
            STARX(M+I)=HCOMP(1,M)
            STARZ(M+I)=HCOMP(3,M)
35      CONTINUE


C Call EOS interpolator: Takes OPAL2006 EOS if possible. If OPAL06 is off, uses SCV
C For OPAL 2006 EOS:
      IF (LOPALE06) THEN
            IORDER=9
            IRAD=1
            DO 36, I=1,M+NUMENV-1
                  STX=STARX(I)
                  STT=START(I)
                  STD=STARD(I)
                  CALL ESAC06(STX,ZTAB,STT,STD,IORDER,IRAD,*999)
999                  CONTINUE
                  STARC(I)=1.0D0/SQRT(eos(8)*STARP(I)/STARD(I))
                  DELADJ(I)=1.0D0/eos(9)
                  GM1(I) = eos(8)
36            CONTINUE
      ENDIF
C For SCV EOS: (when OPAL06 is turned off, SCV on for backup, Yale if SCV is off)
      IF ( .NOT. LOPALE06) THEN
            DO 41, I=1,M+NUMENV-1
                  STX=STARX(I)
                  STT=START(I)*1.0D6
                  STD=STARD(I)
                  STDL=DLOG10(STARD(I))
                  STZ=STARZ(I)
                  STTL=DLOG10(STT)
                  STP=STARP(I)
                  STPL=DLOG10(STP)
                  LCALCJ = .TRUE.
C                  CALL EQSCVE(STTL,STT,STPL,STP,STDL,STD,STX,STZ,BETAJ,BETAIJ,BET14J,FXIONJ,RMUJ,
C     *                       AMUJ,EMUJ,ETAJ,QDTJ,QDPJ,QCPJ,DELAJ,LCALCJ)
                  LDERIJ = .FALSE.
                  LATMOJ = .TRUE.
                  CALL EQSTAT2(STTL,STT,STPL,STP,STDL,STD,STX,STZ,BETAJ,BETAIJ,BET14J,FXIONJ,
     *                  RMUJ,AMUJ,EMUJ,ETAJ,QDTJ,QDPJ,QCPJ,DELAJ,QDTTJ,QDTPJ,QATJ,QAPJ,QCPTJ,QCPPJ,
     *                  LDERIJ,LATMOJ,KSAHAJ)

C                  calculate gamma1 (taken from envint example, eqns in chap. 9 of Cox& Giuli):
                  CHRH = 1.0D0/QDPJ
                   CHT = -CHRH*QDTJ
                  CVJ = QCPJ - EXP(CLN*(STPL-STDL-STTL))*CHT**2/CHRH
                  GM1(I) = CHRH*QCPJ/CVJ
                  STARC(I)=1.0D0/SQRT(GM1(I)*STARP(I)/STARD(I))
                  DELADJ(I) = DELAJ
41            CONTINUE
      ENDIF




C Integrate for the full acoustic depth for normalization
      K=NUMENV-1+M-1
      U=MOD((NUMENV-1+M-1),4)
      IF (U.NE.0) THEN
            NN=K+4-U+1
      ELSE
            NN=K+1
      ENDIF
      IF (K.LE.3) THEN
            K=4
            NN=1+1
      ENDIF

      CALL BOOLE(STARR,STARC,K,NN,TNORM)




C Find the location of the CZ, but only if one exists
      IF (JENV.LT.M) THEN
            RCZ=DEXP(CLN*(RCZL+CRSUNL))


C      get the location of the convection zone, and count nonzero entries:
                  IENDJ=0
                  FLG=0
                  DO 22, I=1,K
                        IF (STARR(I).LE.RCZ(1) .AND. STARR(I+1).GE.RCZ(1)) THEN
                              ICZ = I
                        ENDIF

C                  Interpolate to find Cs at the exact CZ radius
                        IF (I.EQ.ICZ .AND. FLG.EQ.0 .AND. ICZ.GT.3) THEN
                              FLG=1
                              DO 26 P=1,7
                                    HOOD1(P)=STARR(ICZ-4+P)
                                    HOOD2(P)=STARC(ICZ-4+P)
26                              CONTINUE
                              CALL SPLINJ(HOOD1,HOOD2,D,7)
                              CALL SPLINT(HOOD1,HOOD2,7,D,RCZ,ANS,KLO,KHI)
                              STARR(ICZ)=RCZ(1)
                              STARC(ICZ)=ANS(1)
                        ENDIF
                        IF (I.EQ.ICZ .AND. FLG.EQ.0 .AND. ICZ.LE.3) THEN
                              FLG=1
                              IF (ICZ .EQ. 1) THEN
                                    RCZ(1) = STARR(ICZ)
                                    ANS(1) = STARC(ICZ)
                              ELSE
                                    DO 66 P=1,7
                                          HOOD1(P)=STARR(ICZ-2+P)
                                          HOOD2(P)=STARC(ICZ-2+P)
66                                    CONTINUE
                                    CALL SPLINJ(HOOD1,HOOD2,D,7)
                                    CALL SPLINT(HOOD1,HOOD2,7,D,RCZ,ANS,KLO,KHI)
                                    STARR(ICZ)=RCZ(1)
                                    STARC(ICZ)=ANS(1)
                              ENDIF
                        ENDIF

22                   CONTINUE
                  DO 27, I=1,K-ICZ+1
                        STARRZ(I)=STARR(ICZ-1+I)
                        STARCZ(I)=STARC(ICZ-1+I)
27                  CONTINUE
C Then call Boole from surface to cz:
            U=MOD((K-ICZ+1),4)
            V=K-ICZ+1
            IF (U.NE.0) THEN
                  NN=K-ICZ+1+4-U+1
            ELSE
                  NN=K-ICZ+1+1
            ENDIF
            CALL BOOLE(STARRZ,STARCZ,V,NN,TCZ)
      ELSE
            TCZ = 0.0d0
      ENDIF

C Deal with the atmosphere seperately
C      Invert vectors and shift units
C      Adopt the atmosphere metallicity to be the same as the last envelope pt.
C      ATMOSX=STARX(M+NUMENV-1)
C Determine length of Atmosphere vector:
C      IATCNT=0
C      DO 56, I=1,JSON-1
C            IF(ACATMR(I) .NE. 0.0 .AND. ACATMR(I+1) .LE. 1.0D-7) THEN
C                   IATCNT=I
C                  GOTO 56
C            END IF
C56      CONTINUE


C Put the atmosphere in actual units, not differential
C      DO 39, I=1,IATCNT-1
C            ACATMR(IATCNT-I)=ACATMR(IATCNT-I+1)+ACATMR(IATCNT-I)
C39      CONTINUE
C      DO 40, I=1,IATCNT
C            ACATMR(I)=ACATMR(I)+STARR(M+NUMENV-1)
C40      CONTINUE

C      DO 37,I=1,IATCNT
C            ATMOSD(I)=DEXP(CLN*ACATMD(IATCNT+1-I))
C            ATMOST(I)=DEXP(CLN*ACATMT(IATCNT+1-I))/1.0D6
C            ATMOSP(I)=DEXP(CLN*ACATMP(IATCNT+1-I))
C            ATMOSR(I)=ACATMR(IATCNT+1-I)
C37      CONTINUE

C      Pass atm vectors to ESAC06
C      IORDER=9
C      IRAD=1
C      DO 38, I=1,IATCNT
C            CALL ESAC06(ATMOSX,ZTAB,ATMOST(I),ATMOSD(I),IORDER,IRAD,*998)
C998            CONTINUE
C            ATMOSC(I)=1.0D0/SQRT(eos(8)*ATMOSP(I)/ATMOSD(I))
C            ADELAD(I)=1.0D0/eos(9)
C            ATGAM1(I)= eos(8)
C38      CONTINUE


C       Then call Boole to do the integration:
C      U=MOD((IATCNT),4)
c      V=IATCNT
c      IF (U.NE.0) THEN
c            NN=V+4-U+1
c      ELSE
c            NN=V+1
c      ENDIF
c
c      CALL BOOLE(ATMOSR,ATMOSC,V,NN,TATMOS)

C Output normalized acoustic depth
      TAUCZN=0.0D0
      TAUCZN=TCZ/TNORM

C Output acoustic depth info to ISHORT
      WRITE(ISHORT,67)TCZ,TNORM,TAUCZN,TATMOS
67       FORMAT(1X,'Acoustic depth to CZ:',F14.8,2X,'Acoustic depth to center',
     *F13.7,2X,'Normalized taucz:',F11.9, 'Acoustic depth of atmopshere:',F16.8,2X)

555            CONTINUE
C--------------------------------------------------------------
C Save all vectors of interest when the end of a kind card is reached.
      IF(LCLCD)THEN

            WRITE(UNIT=ICLCD,FMT=1506) NUMENV, M, ICZ
1506            FORMAT(1X, 'Number of points in envelope:',I5,2X,
     *      'Number of points in interior:',I5,2X,'Index near Rcz:'
     *      ,I5,2X)

                  DO 1505 I=1,M+NUMENV-1
                        IF (I .LE. K-ICZ+1) THEN
                        WRITE(UNIT=ICLCD,FMT=1504),DAGE, STARR(I), STARC(I),
     *                     STARRZ(I), STARCZ(I), DELADJ(I), GM1(I), STARP(I),
     *                     START(I),STARD(I),STARX(I)

                        ELSE
                        WRITE(UNIT=ICLCD,FMT=1504),DAGE, STARR(I), STARC(I),
     *                     0.0d0, 0.0d0, DELADJ(I), GM1(I), STARP(I),
     *                     START(I),STARD(I),STARX(I)

                        ENDIF


1505                  CONTINUE
1504                  FORMAT(1X,11E16.8)
c                  DO 1520 I=1,IATCNT
c                        WRITE(UNIT=IACAT,FMT=1521),DAGE, ATMOSR(I), ATMOSC(I),
c    *                     DELADJ(I), ATGAM1(I), ATMOSP(I), ATMOST(I), ATMOSX
c
c1520                  CONTINUE
c1521                  FORMAT(1X,8E16.8)


      ENDIF



c      DO 444, I=1,JSON
c            ACATMR(I) =0.0d0
c            ACATMP(I) =0.0d0
c            ACATMT(I) =0.0d0
c            ACATMD(I) =0.0d0
c444      CONTINUE










50      CONTINUE
      RETURN

      END

































