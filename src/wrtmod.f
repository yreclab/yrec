C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C WRTMOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE WRTMOD(M,LSHELL,JXBEG,JXEND,JCORE,JENV,HCOMP,HS1,HD,
     *HL,HP,HR,HT,LC,MODEL,BL,TEFFL,OMEGA,FP,FT,ETA2,R0,HJM,HI,HS,
     * DAGE)
      PARAMETER (JSON=5000)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT REAL*8(A-H,O-Z)

      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
      COMMON/LUNUM/IFIRST, IRUN, ISTAND, IFERMI,
     1    IOPMOD, IOPENV, IOPATM, IDYN,
     2    ILLDAT, ISNU, ISCOMP, IKUR
      COMMON/LABEL/XENV0,ZENV0
      COMMON/CCOUT/LSTORE,LSTATM,LSTENV,LSTMOD,LSTPHYS,LSTROT,LSCRIB
      COMMON/CCOUT1/NPENV,NPRTMOD,NPRTPT,NPOINT
      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL
      COMMON/CONST1/ CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      COMMON/CONST2/CGAS,CA3,CA3L,CSIG,CSIGL,CGL,CMKH,CMKHN
      COMMON/CONST3/CDELRL,CMIXL,CMIXL2,CMIXL3,CLNDP,CSECYR
      COMMON/ENVGEN/ATMSTP,ENVSTP,LENVG
      COMMON/FLAG/LEXCOM
      COMMON/INTATM/ATMERR,ATMD0,ATMBEG,ATMMIN,ATMMAX
      COMMON/INTENV/ENVERR,ENVBEG,ENVMIN,ENVMAX
      COMMON/ROT/WNEW,WALPCZ,ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW
      COMMON/SCRTCH/SESUM(JSON),SEG(7,JSON),SBETA(JSON),SETA(JSON),
     *LOCONS(JSON),SO(JSON),SDEL(3,JSON),SFXION(3,JSON),SVEL(JSON)
C DBG PULSE
      COMMON/PULSE/XMSOL,LPULSE,IPVER
      COMMON/PULSE1/PQDP(JSON),PQED(JSON),PQET(JSON),
     *   PQOD(JSON), PQOT(JSON), PQCP(JSON), PRMU(JSON),
     *   PQDT(JSON),PEMU(JSON),LPUMOD
      COMMON/PULSE2/QQDP,QQED,QQET,QQOD,QQOT,QDEL,
     *      QDELA, QQCP, QRMU, QTL, QPL, QDL, QO, QOL,
     *      QT, QP, QQDT, QEMU, QD, QFS
C MHP 7/96 COMMON BLOCK INSERTED FOR SOUND SPEED
      COMMON/SOUND/GAM1(JSON),LSOUND
C DBG
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
      COMMON/DEBHU/CDH,ETADH0,ETADH1,ZDH(18),XXDH,
     1             YYDH,ZZDH,DHNUE(18),LDH
C DBG 7/95 To store variables for pulse output
      COMMON/PUALPHA/ALFMLT,PHMLT,CMXMLT,
     *             VALFMLT(JSON),VPHMLT(JSON),VCMXMLT(JSON)
      COMMON/ROTEN/DEROT(JSON)
      DIMENSION HCOMP(15,JSON),DUM1(4),DUM2(3),DUM3(3),DUM4(3),
     *HS1(JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),HT(JSON),LC(JSON)
      DIMENSION OMEGA(JSON),FP(JSON),FT(JSON),ETA2(JSON),ID(JSON)
      DIMENSION R0(JSON),HJM(JSON),HI(JSON),HS(JSON)
      DATA IHEADR/4H****/

C G Somers 10/14, Add spot common block, and store common block.
      COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH
      COMMON/TEMP2/VES(JSON),VES0(JSON),VSS(JSON),VSS0(JSON),
     *     HLE(JSON),VGSF(JSON),VGSF0(JSON),VMU(JSON)
      COMMON/QUADD/PHISP(JSON),PHIROT(JSON),PHIDIS(JSON),RAT(JSON)
C G Somers END

      SAVE

         print*,'wrtmod LSOUND 1: ',LSOUND

      IF(LSOUND)THEN
         
         print*,'wrtmod LSOUND 2: ',LSOUND

CFD 10/09 Add an extra output to plot the sound speed profile easyly
         open(unit=500,file='Csound.dat',status='unknown')
         WRITE(500,9124)
 9123    FORMAT(1X,I6,1X,2F12.8,1P,3E16.8)
 9124    FORMAT(1X,'Shell#',5x,'R/Rsun',7x,'M/Msun',7x,'Cs',15x,'Rho')
CFD end
         DO I = 1,M
            FR = EXP(CLN*HR(I))/CRSUN
            FM = EXP(CLN*HS(I))/CMSUN
            XX1 = FM/FR**3
            XXX = -EXP(CLN*(CGL+HS(I)+HD(I)-HP(I)-HR(I)))
            XX2 = -XXX/GAM1(I)
            XX3 = GAM1(I)
            XX4 = -XX2-XXX*(PQDP(I)+SDEL(2,I)*PQDT(I))
            XX5 = EXP(CLN*(C4PIL+HD(I)+3.0D0*HR(I)-HS(I)))
            SV = 1.0D-5*SQRT(GAM1(I)*EXP(CLN*(HP(I)-HD(I))))
            WRITE(IMODPT,123)FR,FM,XX1,XX2,XX3,XX4,XX5,SV
 123        FORMAT(1X,2F12.8,1P6E16.8)
CFD 10/09 Add an extra output to plot the sound speed profile easyly
            WRITE(500,9123)I,FR,FM,SV,HD(I),HT(I)
CFD end

C  DERIVATIVES OF DP/DR, DRHO/DR
            IF(I.LT.M) THEN
              RMID = 0.5D0*(EXP(CLN*HR(I))+EXP(CLN*HR(I+1)))
              DR = EXP(CLN*HR(I+1)) - EXP(CLN*HR(I))
              DIVP = 0.5D0*(GAM1(I)*EXP(CLN*HP(I))+
     *              GAM1(I+1)*EXP(CLN*HP(I+1)))*DR
              DIVR = 0.5D0*(EXP(CLN*HD(I))+EXP(CLN*HD(I+1)))*DR
              QPR1 = EXP(CLN*(CGL+HS(I)+HD(I)-2.0D0*HR(I)))
              QDR1 = EXP(CLN*(HD(I)-HP(I)))*PQDP(I)*QPR1
              QPR2 = EXP(CLN*(CGL+HS(I+1)+HD(I+1)-2.0D0*HR(I+1)))
              QDR2 = EXP(CLN*(HD(I+1)-HP(I+1)))*PQDP(I+1)*QPR1
              QQPR = (QPR1-QPR2)/DIVP
              QQDR = (QDR1-QDR2)/DIVR
              WRITE(IMODPT,124)RMID/CRSUN,QPR1,QDR1,QQPR,QQDR
 124          FORMAT(1X,F11.7,1P4E16.8)
            ENDIF
         END DO
      ENDIF
C
C G Somers 11/14 LCHEMO BLOCK REMOVED, AS THIS INFO IS ALREADY IN .STORE.
C
C DBG PULSE: PRINT OUT PULSATION ENV AND ATM IN ENVINT
C G Somers 11/14 CHANGE TO NEW I/O FLAGS.
      IF(LSTATM .OR. LSTENV .OR. LPULSE) THEN
C  INTEGRATE AN ENVELOPE FROM THE SURFACE TO THE CONVERGED MODEL,
C  PRINTING OUT THE RESULTS.
C  SET UP FLAGS AND COUNTERS.
	 LSBC0 = .FALSE.
	 IF(LSTORE)LPRT = .TRUE.
	 KATM = 0
	 KENV = 0
	 KSAHA = 0
C  SAVE THE INTEGRATION STEP PARAMETERS AND ENFORCE THE SPACING
C  REQUESTED FOR PRINTOUT PURPOSES.
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
	 B = DEXP(CLN*BL)
	 RL = 0.5D0*(BL + CLSUNL - 4.0D0*TEFFL - C4PIL - CSIGL)
	 GL = CGL + STOTAL - RL - RL
	 X = HCOMP(1,M)
	 Z = HCOMP(3,M)
	 FPL = FP(M)
	 FTL = FT(M)
	 IXX=0
	 HSTOT = STOTAL
	 PLIM = HP(M)
C DBG PULSE: ADDED ARGUEMENT TO ENVINT TO TURN ON/OFF PULSE OUTPUT
         LPULPT = LPULSE
            IF (LDH) THEN
               XXDH = HCOMP(1,M)
               YYDH = HCOMP(2,M)+HCOMP(4,M)
               ZZDH = HCOMP(3,M)
               ZDH(1) = HCOMP(5,M)+HCOMP(6,M)
               ZDH(2) = HCOMP(7,M)+HCOMP(8,M)
               ZDH(3) = HCOMP(9,M)+HCOMP(10,M)+HCOMP(11,M)
            END IF
C MHP 10/02  define ISTORE - used in ENVINT
         IDUM = 0
C G Somers 10/14, FOR SPOTTED RUNS, FIND THE
C PRESSURE AT THE AMBIENT TEMPERATURE ATEFFL
        IF(JENV.EQ.M.AND.SPOTF.NE.0.0.AND.SPOTX.NE.1.0)THEN
            ATEFFL = TEFFL - 0.25*LOG10(SPOTF * SPOTX**4.0 + 1.0 - SPOTF)
	 ELSE
	    ATEFFL = TEFFL
	 ENDIF
	 CALL ENVINT(B,FPL,FTL,GL,HSTOT,IXX,LPRT,LSBC0,PLIM,RL,
     *               ATEFFL,X,Z,DUM1,IDUM,KATM,KENV,KSAHA,DUM2,
     *               DUM3,DUM4,LPULPT)
C G Somers END
	 ATMBEG = ABEG0
	 ATMMIN = AMIN0
	 ATMMAX = AMAX0
	 ENVBEG = EBEG0
	 ENVMIN = EMIN0
	 ENVMAX = EMAX0
      ENDIF
C
C G Somers 11/14 LCONZO (convection zone info) block deleted.
C
C G Somers 11/14 LJOUT (rotation info) block deleted.
C
      FSI = DEXP(-CLN*STOTAL)
C DBG PULSE: WRITE HEADER INFORMATION FOR PULSE MODEL
      IF(LPULSE) THEN
         RSURFL = 0.5D0*(BL - C4PIL - CSIGL - 4.0D0*TEFFL + CLSUNL)
         TEMPR = RSURFL - CRSUNL
         QSMASS = XMSOL
         WRITE (IOPMOD, 5001) MODEL,IDM,IPVER,QSMASS,
     1         TEFFL,BL,TEMPR, DAGE, CMIXL, XENV0, ZENV0
 5001    FORMAT(' MODEL#=', I5, '  NUMBER OF SHELLS IN MODEL=',I5,
     *          ' VER=',I2,/,
     *          ' MASS=',F8.5, '  LOG(TEFF)=',F8.5,/, ' LOG(L/LSUN)=',
     *          F16.10, '  LOG(R/RSUN)=',F16.10, /,
     *          ' AGE=', 1PE12.5,' GYR',/,
     *          ' MIXING LENGTH PARAMETER=', 0PF16.10,/,
     *          ' ZAMS (X,Z)=', 2F18.10)
      END IF
      DO 220 J = 1,IDM
	 I = ID(J)
	 FS = FSI*HS1(I)
C
C G Somers 11/14 FINAL LSCRIB BLOCK DELETED
C
C DBG WRITE PULSE MODEL
C	 PRINT*, 'LPULSE=',LPULSE
         IF (LPULSE.AND.LSTORE) THEN
C MHP 10/02 uncommented pelpf statement, used later in i/o
C	   PELPF = CGAS * DEXP(CLN*(HT(I) + HD(I)))* PEMU(I)
C          ADDED X AND Z TO OUTPUT
	   IF ((J.EQ.2).AND.(I.EQ.1)) GOTO 5003
	   IF(IPVER.EQ.1) THEN
	   PELPF = CGAS * DEXP(CLN*(HT(I) + HD(I)))* PEMU(I)
	   WRITE(IOPMOD, 5052)HR(I),FS,HL(I),HT(I),HD(I),
     *          HP(I), SESUM(I),SO(I), PQDP(I), PQED(I),
     *          PQET(I), PQOD(I), PQOT(I), SDEL(2,I),SDEL(3,I),
     *          PQCP(I), PRMU(I), PQDT(I), PELPF
         ELSE IF (IPVER.EQ.2) THEN
	   WRITE(IOPMOD, 6052)HR(I),FS,HL(I),HT(I),HD(I),
     *      HP(I), SESUM(I),SO(I), PQDP(I), PQED(I),
     *      PQET(I), PQOD(I), PQOT(I), SDEL(2,I),SDEL(3,I),
     *      PQCP(I), PRMU(I), PQDT(I), HCOMP(1,I),HCOMP(3,I)
         ELSE IF (IPVER.EQ.3) THEN
C DBG 7/95 Modifed to include mixing length variables
	   WRITE(IOPMOD, 6053)HR(I),FS,HL(I),HT(I),HD(I),VALFMLT(I),
     *      HP(I), SESUM(I),SO(I), PQDP(I), PQED(I),VPHMLT(I),
     *      PQET(I), PQOD(I), PQOT(I), SDEL(2,I),SDEL(3,I),VCMXMLT(I),
     *      PQCP(I), PRMU(I), PQDT(I), HCOMP(1,I),HCOMP(3,I)
         END IF
 5003      CONTINUE
 5052      FORMAT(5E16.9,/,5E16.9,/,5E16.9,/,5E16.9)
 6052      FORMAT(5E23.16,/,5E23.16,/,5E23.16,/,5E23.16)
 6053      FORMAT(6E23.16,/,6E23.16,/,6E23.16,/,5E23.16)
      END IF
C DBG END
  220 CONTINUE
C
C G Somers 11/14 REMOVED LONG BLOCK
C
      RETURN
      END
