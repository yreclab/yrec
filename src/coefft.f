C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C COEFFT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE COEFFT(DELTS,M,HD,HHA,HHB,HHC,HL,HMAX,HP,HPP,HR,HS,HS1,
     *HS2,HT,HTT,HCOMP,LC,TLUMX,LATMO,LDERIV,LMIX,LOCOND,QDT,QDP,KSAHA,
C      *MODEL,FP,FT,HKEROT,HKEROTO,JENV,TEFFL)  ! KC 2025-05-31
     *FP,FT,HKEROT,HKEROTO,JENV,TEFFL,CMIXL)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/SOUND/ into SOUND_MOD.
      USE SOUND_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/SCRTCH/ into SCRTCH_MOD.
      USE SCRTCH_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ROTEN/ into ROTEN_MOD.
      USE ROTEN_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/ROTDER/ into ROTDER_MOD.
      USE ROTDER_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE2/ into PULSE2_MOD.
      USE PULSE2_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE1/ into PULSE1_MOD.
      USE PULSE1_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PUALPHA/ into PUALPHA_MOD.
      USE PUALPHA_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/MASSCHG2/ into MASSCHG2_MOD.
      USE MASSCHG2_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/GRAB/ into GRAB_MOD.
      USE GRAB_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/FLUXES/ into FLUXES_MOD.
      USE FLUXES_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/DPMIX/ into DPMIX_MOD.
      USE DPMIX_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/DEBHU/ into DEBHU_MOD.
      USE DEBHU_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 AMU,B,BE7MFLOC,BETA,BETA14,BETAI,CCCQL,CHRH,CHT,CMIXL,CV,D,
     *       DEL,DELA,DELR,DELTS,DELTSI,DL,DT,E,EALPCA,ECA,EG,EGG11,
     *       EGG22,EGG33,EGG44,EGG55,EGNEUT,EGRAV,EMU,ENTR,ENTR1,ENTR2,
     *       ENTR3,ENU,ESUMI,ETA,ETOT,FP,FPL,FT,FTL,FXION,HCOMP,HD,HF1,
     *       HF2,HHA,HHB,HHC,HKEROT,HKEROTO,HL,HMAX,HP,HPP,HPPP,HR,HR1,
     *       HR10,HR11,HR12,HR13,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HS,HS1,
     *       HS2,HT,HTT,HTTT,O,OL,P,PL,QACP,QACR,QACT,QAP,QAT,QCP,QCPP,
     *       QCPT,QDP,QDT,QDTP,QDTT,QED,QET,QL,QL0,QLP,QLP0,QLT,QLT0,
     *       QOD,QOT,QP0,QPP,QPP0,QPR,QPR0,QR,QR0,QRP,QRP0,QRR,QRR0,QRT,
     *       QRT0,QT0,QTEMP,QTL0,QTP,QTP0,QTR,QTR0,QTT,QTT0,RL,RMU,SL,
     *       SUM1,T,TEFFL,THL,TIME,TIMEI,TL,TLUMX,VEL,X,XBE9,XC12,XC13,
     *       XH2,XHE3,XLI6,XLI7,XN14,XN15,XO16,XO17,XO18,Y,Z
      INTEGER IM,IM1,IU,J,JENV,KSAHA,M
      LOGICAL*4 LATMO,LC,LCONV,LDERIV,LMIX,LNTRPY,LOCOND
C 2/91 MHP FLAG TO TOGGLE BETWEEN OLD/NEW ENERGY GENERATION ROUTINES
C ADDED (COMMON BLOCK NEWENG).

C 10/13/26 MHP via Claude: removed the unused COMMON/IOUNITS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/11/26 MHP via Claude
C code changed to remove LSCRIB from COMMON/CCOUT/: it was declared
C positionally in all 17 files sharing this block but never read or
C written in executable code anywhere, and no namelist file sets it.
C 10/12/26 MHP via Claude
C code changed to extend COMMON/NMLPAR/ to 234 members, adding the
C namelist variables that the physics routines read from 27 COMMON
C blocks which also held derived or working members.  Those blocks keep
C only their non-namelist members; five of them -- NEWMX, VMULT,
C PMMWIND, CCOUT1 and ENVGEN -- had nothing left and are gone.
C Derivation-only namelist variables from the same blocks went to
C COMMON/NMLBYPASS/ instead, not here.
C
C Declared identically in all 121 files that hold any of these members.
C Generated from one member list, so every copy is byte-identical; the
C linker's 'size of symbol changed' warning is the check that they are.
C 10/13/26 MHP via Claude: removed the unused COMMON/CCOUT/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 9/24/26 MHP via Claude
C code changed to pass CMIXL as an explicit argument instead of via
C common block, to reduce implicit global state ahead of the F90
C module conversion
C 10/13/26 MHP via Claude
C code changed to drop COMMON/CTLIM/, declared here but never used.
C 10/12/26 MHP via Claude
C code changed to remove COMMON/OPTAB/ entirely.  Once OPTOL moved to the
C consolidated namelist block, every remaining member was write-only:
C ZSI appeared only in a DATA statement in parmin.f, and IDT and IDD were
C assigned the constants 15 and 5 in coefft.f, envint.f, physic.f and
C starin.f and read nowhere in the code.  They are leftovers from the
C removed opacity-table interpolation schemes.
C DBG PULSE
C 10/13/26 MHP via Claude
C code changed to drop COMMON/PULSE/, declared here but never used.
C DBG
C*** MHP 5/90 ADD COMMON BLOCK FOR SOLAR NEUTRINO I/O
C*** MHP 5/91 ADD COMMON BLOCK FOR ENERGY FROM ALPHA CAPTURE REACTIONS
C  AND LOSSES FROM NEUTRINO-COOLED CORES IN EVOVLED STARS.
C 10/13/26 MHP via Claude
C code changed to replace COMMON/NEWEPS/ with explicit arguments: engeb.f
C computes EALPCA and ENU, and coefft.f and ytime.f read them right after
C their own CALL ENGEB, so they are returned as arguments.  main.f, the
C third caller, passes locals it does not use.
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
C DBG 7/95 To store variables for pulse output
C MHP 7/96 COMMON BLOCK ADDED FOR SOUND SPEED
C MHP 06/02 COMMON BLOCK ADDED FOR DERIVATIVES OF
C CAPPA AND EPSILON
C 10/13/26 MHP via Claude
C code changed to drop the write-only members SQOD and SQED from
C COMMON/ROTDER/.  coefft.f assigned both and nothing ever read them;
C setupv.f, the block's only reader, uses SQOT, SQET and FRACNUC.  That
C frees 10,000 words.  The block itself stays: coefft.f and setupv.f sit
C in different phases -- setupv.f is reached via seculr.f -- so passing
C the rest explicitly would mean threading 15,000-word arrays through
C main.f and GETW.

C JVS 10/11 Common block for He3+He3 luminosity
C JVS end

      DIMENSION FXION(3),EG(6),TLUMX(8),HD(JSON),HHA(4,2,JSON),
     *HHB(4,JSON),HHC(JSON),HL(JSON),HMAX(4),HP(JSON),HPP(JSON),
     *HR(JSON),HS(JSON),HS1(JSON),HS2(JSON),HT(JSON),HTT(JSON),LC(JSON),
     *HCOMP(15,JSON),FP(JSON),FT(JSON)
      DIMENSION HF1(JSON),HF2(JSON),HR1(JSON),HR2(JSON),HR3(JSON),
     *HR4(JSON),HR5(JSON),HR6(JSON),HR7(JSON),HR8(JSON),HR9(JSON),
     *HR10(JSON),HR11(JSON),HR12(JSON),HR13(JSON)
      DIMENSION HKEROT(JSON),HKEROTO(JSON)
      SAVE

C 7/91 MHP
C ZERO OUT SOLAR NEUTRINO FLUXES.
C FLUXTOT = TOTAL FLUX OF EACH OF THE NEUTRINOS PRODUCED IN THE SUN
      IF(LSNU) THEN
         DO 5 J = 1,10
            FLUXTOT(J) = 0.0D0
   5     CONTINUE
      ENDIF
C MHP 10/02 QFPR,QFTR NOT USED - OMIT
c      IF(.NOT.LROT) THEN
C       QFPR = 0.0D0
C       QFTR = 0.0D0
c      ENDIF
      LOCOND = .TRUE.
      LDERIV = .TRUE.
      LATMO = .FALSE.
      LMIX = .FALSE.
      LNTRPY = DELTS.GT.0.0D0
      IF(LNTRPY) THEN
       DELTSI = 1.0D0/DELTS
       TIME = 3.1558D7
       TIMEI = 3.1688D-8
      ENDIF
      DO 10 J = 1,8
       TLUMX(J) = 0.0D0
   10 CONTINUE
      DO 30 IM = 1,M
C SET UP LOCAL VARIABLES FOR CALLS TO BASIC PHYSICS ROUTINES
       THL = 0.0D0
       SL = HS(IM)
       TL = HT(IM)
       PL = HP(IM)
       RL = HR(IM)
       B = HL(IM)
       X = HCOMP(1,IM)
       Y = HCOMP(2,IM)
       Z = HCOMP(3,IM)
       XHE3 = HCOMP(4,IM)
       XC12 = HCOMP(5,IM)
       XC13 = HCOMP(6,IM)
       XN14 = HCOMP(7,IM)
       XN15 = HCOMP(8,IM)
       XO16 = HCOMP(9,IM)
       XO17 = HCOMP(10,IM)
       XO18 = HCOMP(11,IM)
C MHP 05/02 DEFINE THESE ALWAYS; THEY
C ARE PASSED TO THE SR ANYWAY.
C       IF(LEXCOM) THEN
          XH2 = HCOMP(12,IM)
          XLI6 = HCOMP(13,IM)
          XLI7 = HCOMP(14,IM)
          XBE9 = HCOMP(15,IM)
C       ENDIF
       IU = IM
       DL = HD(IM)
       FPL = FP(IM)
        FTL = FT(IM)
C 9/22/26 MHP via Claude
C code changed to remove the MHD equation of state
         IF (LDH) THEN
            XXDH = HCOMP(1,IM)
            YYDH = HCOMP(2,IM)+HCOMP(4,IM)
            ZZDH = HCOMP(3,IM)
            ZDH(1) = HCOMP(5,IM)+HCOMP(6,IM)
            ZDH(2) = HCOMP(7,IM)+HCOMP(8,IM)
            ZDH(3) = HCOMP(9,IM)+HCOMP(10,IM)+HCOMP(11,IM)
         END IF
         CALL EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *        AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,
     *        QCPP,LDERIV,LATMO,KSAHA)
C DBG 12/95 GET OPACITY
         CALL GETOPAC(DL, TL, X, Z, O, OL, QOD, QOT, FXION)
         IOVIM = IM
         CALL TPGRAD(TL,T,PL,P,D,RL,SL,B,O,QDT,QDP,QOT,QOD,QCP,DEL,
     *        DELR,DELA,QDTT,QDTP,QAT,QAP,QACT,QACP,QACR,QCPT,QCPP,
     *        VEL,LDERIV,LCONV,FPL,FTL,TEFFL,CMIXL)
       HD(IM) = DL
C COMPUTE DERIVATIVES
c       IF(LROT) THEN
C  CALCULATE D(LOG FP)/D(LOG R) AND D(LOG FT)/D(LOG R)
c            IF(IM.GT.1) THEN
c             IF(IM.LT.M) THEN
c              QFPR = (DLOG(FP(IM+1)) - DLOG(FP(IM-1)))/
c     *                 (CLN*(HR(IM+1) - HR(IM-1)))
c              QFTR = (DLOG(FT(IM+1)) - DLOG(FT(IM-1)))/
c     *                 (CLN*(HR(IM+1) - HR(IM-1)))
c             ELSE
c              QFPR = (DLOG(FP(M)) - DLOG(FP(M-1)))/
c     *                 (CLN*(HR(M) - HR(M-1)))
c              QFTR = (DLOG(FT(M)) - DLOG(FT(M-1)))/
c     *                 (CLN*(HR(M) - HR(M-1)))
c             ENDIF
c          ELSE
c             QFPR = (DLOG(FP(2)) - DLOG(FP(1)))/
c     *              (CLN*(HR(2) - HR(1)))
c             QFTR = (DLOG(FT(2)) - DLOG(FT(1)))/
c     *              (CLN*(HR(2) - HR(1)))
c          ENDIF
c       ENDIF
       QTEMP = C4PIL + RL + RL + RL
       QR =+DEXP(CLN*(SL - DL - QTEMP))
       QRR = - QR - QR - QR
       QRP = -QR*QDP
       QRT = -QR*QDT
       QP =-DEXP(CLN*(CGL + SL + SL - PL - QTEMP - RL ))*FP(IM)
C       QPR = -QP - QP - QP - QP*(1.0D0 - QFPR)
       QPR = -QP - QP - QP - QP
       QPP = -QP
       LC(IM) = LCONV
       QT = DEL*QP
       QTR = -QT - QT - QT - QT
C       QTR = -QT - QT - QT - QT*(1.0D0 - QFTR)
       IF(.NOT.LCONV) THEN
C TEMPERATURE GRADIENT IS RADIATIVE
          QTL = CLNI*QT/B
          QTP = QT*QOD*QDP
          QTT = QT*(-4.0D0 + QOT + QOD*QDT)
       ELSE
C TEMPERATURE GRADIENT IS CONVECTIVE
          QTL = 0.0D0
          QTP = QT*(-1.0D0 + QACP)
          QTT = QT*QACT
          QTR = QTR + QT*QACR
       ENDIF
       QL = 0.0D0
       QLT = 0.0D0
       QLP = 0.0D0
       IF(TL.GT.TCUT(1)) THEN
C SET UP NUCLEAR ENERGY TERMS
C 10/13/26 MHP via Claude
C code changed to pass BE7MFLOC for ENGEB's new BE7MASSFRACTION
C argument, which replaces COMMON/BE7/.  This routine does not use the
C value; only main.f reads it.
            CALL ENGEB(EGG11,EGG22,EGG33,EGG44,EGG55,QED,QET,SUM1,DL,
C      *           TL,QDT,QDP,X,Y,Z,XHE3,XC12,XC13,XN14,XN15,XO16,XO17,
C      *           XO18,XH2,XLI6,XLI7,XBE9,IU,HR1,HR2,HR3,HR4,HR5,HR6,HR7,  ! KC 2025-05-31
     *           TL,X,Y,XHE3,XC12,XC13,XN14,XO16,
     *           XO18,XH2,IU,HR1,HR2,HR3,HR4,HR5,HR6,HR7,
     *           HR8,HR9,HR10,HR11,HR12,HR13,HF1,HF2,BE7MFLOC,EALPCA,ENU)
            E = SUM1
            EG(1) = EGG11
            EG(2) = EGG22
            EG(3) = EGG33
            EG(4) = EGG44
            EG(5) = EGG55
            EG(6) = ENU
            ECA = EALPCA
C 7/91 MHP
C CONVERT NEUTRINO FLUX RATES (UNITS 10**10 ERGS PER GM)
C TO UNITS OF 10**10 ERGS BY MULTIPLYING BY THE MASS.
            IF(LSNU) THEN
               DO 17 J = 1,10
                  FLUXTOT(J) = FLUXTOT(J) + FLUX(J)*HS2(IM)
 17            CONTINUE
            ENDIF
            DO 20 J = 1,6
               TLUMX(J) = TLUMX(J) + (HS2(IM)/CLSUN)*EG(J)
               THL = THL + (HS2(IM)/CLSUN)*EG(J)
 20         CONTINUE
C JVS 10/11 Calculate the He3+He3 and sum of He3+He3 and He3+He4 luminosity
            UMHE33(IM) = (HS2(IM)/CLSUN)*ENGHE3
            UMHEAL(IM) = (HS2(IM)/CLSUN)*HE3ALL
C JVS end
            TLUMX(8)=TLUMX(8)+(HS2(IM)/CLSUN)*ECA
            THL = THL + (HS2(IM)/CLSUN)*ECA
            QL = E
            QLT = QLT + QET + QED*QDT
            QLP = QLP + QED*QDP
         ENDIF
         IF(LNTRPY) THEN
C SET UP ENTROPY TERMS
            DT = DELTSI
            IF(LMDOT.AND.DMDT0.GT.0.0D0)THEN
               IF(IM.GE.JENV)THEN
                  HTTT = HTT(IM)+DLOGT
                  HPPP = HPP(IM)+DLOGP
               ELSE
                  HTTT = HTT(IM)
                  HPPP = HPP(IM)
               ENDIF
            ELSE
               HTTT = HTT(IM)
               HPPP = HPP(IM)
            ENDIF
            IF(HCOMP(1,IM).GT.0.01D0 .AND. DELTS.LT.TIME)DT = TIMEI
            ENTR1 = P*QDT/D
            ENTR2 = ENTR1/DELA
            ENTR = (ENTR2*HTTT - ENTR1*HPPP)*CLN
            ENTR3 = ENTR2*CLN*HTTT
C            ENTR = (ENTR2*HTT(IM) - ENTR1*HPP(IM))*CLN
C            ENTR3 = ENTR2*CLN*HTT(IM)
            EGRAV = DT*ENTR
            HHC(IM) = EGRAV
            TLUMX(7) = TLUMX(7) + (HS2(IM)/CLSUN)*EGRAV
            QL = QL + EGRAV
            QLP = QLP + DT*(ENTR*(1.0D0-QDP+QDTP)-ENTR1 - ENTR3*QAP)
            QLT = QLT + DT*(ENTR*(-QDT+QDTT) + ENTR2 - ENTR3*QAT)
C 7/92 INCLUDE CHANGE IN ROTATIONAL KINETIC ENERGY IN ENERGY EQUATION.
            IF(LROT)THEN
               DEROT(IM) = DT*(HKEROT(IM)-HKEROTO(IM))/HS2(IM)
               QL = QL - DEROT(IM)
            ENDIF
C ADD CHANGE IN ENTROPY FROM ACCRETED MATERIAL
C            IF(LMDOT.AND.DMDT0.GT.0.0D0)THEN
C               IF(IM.GE.JENV)THEN
C                  QACC = - T*SCEN*DMDT0/CSECYR/SMASS0
C                  WRITE(*,*)QL,QACC
C                  QL = QL + QACC
C               ENDIF
C            ENDIF
         ENDIF
         CCCQL = CLNSUN*HS1(IM)
         QL = CCCQL*QL
         QLP = CCCQL*QLP
         QLT = CCCQL*QLT
         IF(IM.GT.1) THEN
C REDUCE MATRIX FOR PAIR OF POINTS (IM-1,IM)
            IM1 = IM
            CALL REDUCE(IM1,HHA,HHB,HL,HMAX,HP,HR,HS,HT,QP0,QP,QPR0,
     *      QPR,QPP0,QPP,QT0,QT,QTR0,QTR,QTL0,QTL,QTP0,QTP,QTT0,QTT,
     *      QR0,QR,QRR0,QRR,QRP0,QRP,QRT0,QRT,QL0,QL,QLP0,QLP,QLT0,QLT)
         ELSE
C SETUP CENTRAL BOUNDARY CONDITIONS
            HHA(3,1,1) = CC13*QDP
            HHA(3,2,1) = CC13*QDT
            HHB(3,1) = -CC13*(C4PI3L + DL - SL) - RL
            HHA(4,1,1) = -QLP
            HHA(4,2,1) = -QLT
            HHB(4,1) = CLNI*QL - B
         ENDIF
         QP0 = QP
         QPR0 = QPR
         QPP0 = QPP
         QT0 = QT
         QTR0 = QTR
         QTL0 = QTL
         QTP0 = QTP
         QTT0 = QTT
         QR0 = QR
         QRR0 = QRR
         QRP0 = QRP
         QRT0 = QRT
         QL0 = QL
         QLP0 = QLP
         QLT0 = QLT
C MHP 02/12 REMOVED RESTRICTIONS ON WHERE INTERMEDIATE VARIABLES
C SUCH AS OPACITY ARE SAVED; PRIOR RESTRICTIONS WERE BASED ON OBSOLETE
C MEMORY RESTRICTIONS IN LEGACY CODE
C         IF(LMDOT.AND.DMDT0.GT.0.0D0)THEN
         SVEL(IM) = VEL
C         ENDIF
C  STORE VARIABLES FOR OUTPUT IN SCRIB2 IF MODEL IS TO BE PRINTED OUT
C DBG PULSE STORE VARIABLES FOR PULSATION OUPUT
C DBG 3/91 CHANGED TO ALWAYS EXECUTE THIS STUFF
C         LONG = MOD(MODEL,NPRT2).EQ.0 .OR. LROT
C MHP 10/02 LSHORT NOT USED, OMIT
C         LSHORT = .NOT.LONG .AND. MOD(MODEL,NPRT1).EQ.0
C  ZERO OUT NUCLEAR ENERGY TERMS IF T < NUCLEAR CUTOFF.
         IF(HT(IM).LT.TCUT(1)) THEN
            SESUM(IM) = 0.0D0
            SEG(7,IM) = HHC(IM)
            DO J = 1,6
               SEG(J,IM) = 0.0D0
           END DO
         ELSE
C         ELSE IF(LONG) THEN
C  LONG OUTPUT NEEDED
            SESUM(IM) = EG(1)+EG(2)+EG(3)+EG(4)+EG(5)
            SEG(6,IM) = EG(6)
            SEG(7,IM) = HHC(IM)
            IF(SESUM(IM).GT.1.0D-22) THEN
               ESUMI = 1.0D0/SESUM(IM)
            ELSE
               ESUMI = 0.0D0
            ENDIF
            DO J = 1,5
               SEG(J,IM) = EG(J)*ESUMI
              END DO
C  SHORT OUTPUT ONLY
C         ELSE
C            SESUM(IM) = EG(1)+EG(2)+EG(3)+EG(4)+EG(5)
C            SEG(6,IM) = EG(6)
C            SEG(7,IM) = HHC(IM)
         ENDIF
         SBETA(IM) = BETA
         SETA(IM) = ETA
         LOCONS(IM) = LOCOND
         SO(IM) = O
         SDEL(1,IM) = DELR
         SDEL(2,IM) = DEL
         SDEL(3,IM) = DELA
         DO J = 1,3
            SFXION(J,IM) = FXION(J)
         END DO
         SVEL(IM) = VEL
         SCP(IM) = QCP
C MHP 02/12 COMMENTED CODE OUT, AS REPLICATED BELOW
C         IF(LSOUND) THEN
C MHP 7/96 CALCULATION OF GAMMA1 FROM GUENTHER 1995 P.C.
C            CHRH = 1.0D0/QDP
C            CHT = -CHRH*QDT
C            CV = QCP - EXP(CLN*(HP(IM)-HD(IM)-HT(IM)))*CHT**2/CHRH
C            GAM1(IM) = CHRH*QCP/CV
C            PQDP(IM) = QDP
C         ENDIF

C JVS 01/11 always want gamma:
            CHRH = 1.0D0/QDP
            CHT = -CHRH*QDT
            CV = QCP - EXP(CLN*(HP(IM)-HD(IM)-HT(IM)))*CHT**2/CHRH
            GAM1(IM) = CHRH*QCP/CV
            PQDP(IM) = QDP
            PQDT(IM) = QDT
C JVS END


         IF(LROT)THEN
            SQOT(IM) = QOT
C MHP 10/02 variable index error
            IF(SESUM(IM).GT.0.0D0)THEN
C            IF(SESUM(I).GT.0.0D0)THEN
C               ETOT = SESUM(I)
C               EGNEUT = SEG(6,I)+SEG(7,I)
               ETOT = SESUM(IM)
               EGNEUT = SEG(6,IM)+SEG(7,IM)
               FRACNUC(IM) = (ETOT - EGNEUT)/ETOT
            ELSE
               FRACNUC(IM) = 0.0D0
            ENDIF
            SQET(IM) = QET
         ENDIF
C DBG PULSE
         IF (LPULSE) THEN
            PQDP(IM) = QDP
            PQED(IM) = QED
            PQET(IM) = QET
            PQOD(IM) = QOD
            PQOT(IM) = QOT
            PQCP(IM) = QCP
            PRMU(IM) = RMU
            PEMU(IM) = EMU
            PQDT(IM) = QDT
            VALFMLT(IM) = ALFMLT
            VPHMLT(IM) = PHMLT
            VCMXMLT(IM) = CMXMLT
         END IF
 30   CONTINUE

      RETURN
      END
