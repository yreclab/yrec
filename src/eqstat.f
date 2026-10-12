
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C   EQSTAT - New front end to equation of state routines
C            Provided to allow numerical differentiation of
C            current EOS routines by calling old EOS routine
C            (now called EQSTAT2) at aappropriated P and T
C            points in support of numerical differentiation.
C                                                                 LLP  10-22-06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      SUBROUTINE EQSTAT(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,LDERIV,
     *LATMO,KSAHA)
c
c  Input Arguments: TL, PL, X, Z, LDERIV, LATMO
c
c  Output Arguments: T, P, D, DL, BETA, BETAI, BETA14, FXION, RMU, AMU,
c          EMU, QDT, QDP, QCP, DELA, QDTT, QDTP, QAT, QAP, QCPT, QCPP,
c
c  Update (Input and Output) Arguments: KSAHA
c

      PARAMETER (NTS=63, NPS=76)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      COMMON/IOUNITS/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,
     *  IOWR,IFIRST,IRUN,ISTAND,IFERMI,IOPMOD,IOPENV,IOPATM,ISNU,
     *  IALEX06,ICLCD,IJLAST,IOPUREZ,IcondOpacP,ILIV95,IOATM,IOATMA,
     *  IOPALE,ISCVH,ISCVHE,ISCVZ
C       DIMENSION ATOMWT(4),FXION(3),ATOMW2(12)  ! FX(12)  ! KC 2025-05-31
      DIMENSION FXION(3)
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON/CTLIM/ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TENV,TGCUT
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
C 9/25/26 MHP via Claude
C code changed to fix XXDY -> XXDH, matching every other file that
C declares COMMON/DEBHU/ (pre-existing name-only inconsistency; this
C slot was never read or written by name in this file)
      COMMON/DEBHU/CDH,ETADH0,ETADH1,ZDH(18),XXDH,
     1     YYDH,ZZDH,DHNUE(18),LDH
C YCK 2/95 OPAL eos
C LLP 2001 OPAL eos Mar 2003
C LLP 2006 OPAL eos Oct 2006
C LLP Add Use Numerical Derivatives flag, LNumDeriv   7/07
C MHP 8/25 Remove unused variables
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
C 10/12/26 MHP via Claude
C code changed to merge 35 single-purpose namelist COMMON blocks into one
C COMMON/NMLPAR/, declared identically in all 89 files that held any of
C them.  Merged, in this member order:
C   ALATM03, BURNSCS, BURTOL, CALS2, CCOUT2, CHRONE, CMIXING, CORE, CT2
C   CT3, DIFUS, FLAG, GOVS, GRAVS2, GRAVS3, GRAVS4, GRAVST, HEFLSH, INTATM
C   INTENV, MAG, MASSCHG, NEWCMP, NEWENG, NEWXYM, NOTRAN, OPALEOS, PO
C   ROT, SBROT, SPOTS, TRACK, VMULT2, VNEWCB, WEAK
C
C Every member is a namelist variable the physics routines read, so this
C is the single block the F90 module conversion will become.  Blocks that
C also hold derived or working members are left for a later pass, and
C COMMON/IOUNITS/, COMMON/INTPAR/ and COMMON/CONSTANTS/ stay out by
C agreement.  No member is CHARACTER.
C
C Each file declares the FULL block rather than a leading prefix: a
C DATA-initialized short declaration of a longer block silently
C corrupts memory, and the linker's 'size of symbol changed' warning is
C the only signal.  The declaration below is generated from one list, so
C all 89 copies are byte-identical.
      COMMON/NMLPAR/
     * ALATM_FeH,ALATM_Alpha,LALTPTau100,SLI6,SLI7,SBE91,SBE92,SBE93,
     * CMIN,ABSTOL,RELTOL,KEMMAX,TOLL,TOLR,TOLZ,LCALS,LCALSOLZX,
     * CALSOLZX,CALSOLAGE,LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH,LRWSH,
     * CSTMIXING,CSTDIFFMIX,LCORE,MCORE,FCORE,DTWIND,LPTIME,DTDIF,
     * DJOK,ITDIF1,ITDIF2,LEXCOM,LTRIST,DT_GS,XMIN,YMIN,LTHOULFIT,
     * FGRY,FGRZ,LTHOUL,LDIFZ,LNEWDIF,LDIFLI,GRTOL,ILAMBDA,NITER_GS,
     * LDIFY,LKUTHE,ATMERR,ATMD0,ATMBEG,ATMMIN,ATMMAX,ENVERR,ENVBEG,
     * ENVMIN,ENVMAX,CODM,LCODM,DMDT0,FCZDMDT,FTOTDMDT,COMPACC(15),
     * CREIM,LREIMER,LMDOT,XNEWCP,INEWCP,LNEWCP,LREL,NITER4,LNEWS,
     * LSNU,XENV0A(50),ZENV0A(50),CMIXLA(50),LSENV0A(50),SENV0A(50),
     * LNOJ,lopale06,lNumDeriv,POA,POB,POC,POMAX,LPOUT,WNEW,WALPCZ,
     * ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW,LSOLID,IMPJMOD,SPOTF,
     * SPOTX,LSDEPTH,ITRVER,FESC,FSSC,FGSFC,IES,IGSF,IMU,VNEW(12),
     * WEAKSCREENING
C MHP 3/94 ADDED METAL DIFFUSION
C MHP  5/97 ADDED COMMON BLOCK FOR SCV EOS TABLES
C 10/9/26 MHP via Claude
C code changed to rename this slot IDT -> IDTSCV: parmin.f and
C starin.f also declare COMMON/OPTAB/'s own, unrelated IDT, so this
C slot was called IDTT there as a workaround. Renamed to IDTSCV
C everywhere COMMON/SCVEOS/ is declared for one consistent name.
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *     TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *     TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDTSCV,IDP
C       DATA NZP1/12/
C       DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
C       DATA SCALET,SCALES/0.500D0, 2.000D0/
C       DATA ATOMW2/23.0D0,26.99D0,24.32D0,55.86D0,28.1D0,12.015D0,
C      *            1.008D0,16.0D0,14.01D0,39.96D0,20.19D0,4.004D0/
      SAVE

c  LDERIV: if true, provide derivatives needed for relaxation, else don't

c  LNumDeriv - if true derivatives are calculated numerically. else get
c              them the old way using Yale EOS.
c              LNumDeriv is part of the PARMIN PHYSICS namelist.

      PLO = PL
      TLO = TL
      LATMOx = LATMO
      KSSAHAx = KSAHA

      IF(LDERIV .AND. LNumDeriv) THEN
c Get Numerical Derivatives of Current EOS    LLP  8/5/07
c If both derivatives and numerical derivatives are requested.

c A central difference approximation using values on both sides of
c TL and then PL is used. The error term in this approximation of
c the derivatives is of order h**2, where h is the interval. The
c error term when one sided derivatives are used is of order h.

            dpl = .150d0    ! the approximate table intervals
            dtl = .030d0

            dpl = dpl * .01d0   ! Empirically, scaling the intervals down
            dtl = dtl * .01d0   ! by 100 seemed to work best.

            dpl2 = 2D0 * dpl
            dtl2 = 2D0 * dtl

            DL1 = DL   ! Initialize DL1 and D1 to called values.
            D1 = D     ! This can avoid problems in initial table lookups

            TTL = TL + dtl   ! Get derivatives wrt T.
            T = 10.0D0**TTL
            LDERIV2=.FALSE.
            CALL EQSTAT2(TTL,T,PL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *         FXION,RMU,AMU,EMU,ETA,QDT1,QDP1,QCP1,DELA1,QDTTx,
     *         QDTPx,QATx,QAPx,QCPTx,QCPPx,LDERIV2,LATMOx,KSAHAx)

            TTL = TL - dtl
            T = 10.0D0**TTL
            LDERIV2=.FALSE.
            CALL EQSTAT2(TTL,T,PL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *         FXION,RMU,AMU,EMU,ETA,QDT2,QDP2,QCP2,DELA2,QDTTx,
     *         QDTPx,QATx,QAPx,QCPTx,QCPPx,LDERIV2,LATMOx,KSAHAx)
            QDTT1 = (QDT1-QDT2)/dtl2/CLN
            QCPT1 = (DLOG10(QCP1)-DLOG10(QCP2))/dtl2
            QAT1 = (DLOG10(DELA1)-DLOG10(DELA2))/dtl2
            TL = TLO
            T = 10.0D0**TLO   ! Restore original T

            PPL = PL + dpl
            P = 10.0D0**PPL
            LDERIV2=.FALSE.
            CALL EQSTAT2(TL,T,PPL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *         FXION,RMU,AMU,EMU,ETA,QDT1,QDP1,QCP1,DELA1,QDTTx,
     *         QDTPx,QATx,QAPx,QCPTx,QCPPx,LDERIV2,LATMOx,KSAHAx)
            PPL = PL - dpl
            P = 10.0D0**PPL
            LDERIV2=.FALSE.
            CALL EQSTAT2(TL,T,PPL,P,DL1,D1,X,Z,BETA,BETAI,BETA14,
     *         FXION,RMU,AMU,EMU,ETA,QDT2,QDP2,QCP2,DELA2,QDTTx,
     *         QDTPx,QATx,QAPx,QCPTx,QCPPx,LDERIV2,LATMOx,KSAHAx)
            PL = PLO
            P = 10.0D0**PLO   ! Restore original P
            QDTP1 = (QDT1-QDT2)/dpl2/CLN
            QCPP1 = (DLOG10(QCP1)-DLOG10(QCP2))/dpl2
            QAP1 = (DLOG10(DELA1)-DLOG10(DELA2))/dpl2

            QDTT = QDTT1
            QDTP = QDTP1
            QAT = QAT1
            QAP = QAP1
            QCPP = QCPP1
            QCPT = QCPT1
        ENDIF

      TL = TLO    ! Restore original TL and PL.
      PL = PLO

      IF (LDERIV .AND. .NOT. LNumDeriv) THEN
         LDERIV2=.TRUE.   ! Need derivatives and have no numerical ones.
                          ! Call eqstat2 and request derivatives
         CALL EQSTAT2(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *   AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTT,QDTP,QAT,QAP,QCPT,QCPP,
     *   LDERIV2,LATMO,KSAHA)
      ELSE
         LDERIV2=.FALSE.  ! We either already have numerical derivatives
                        ! or do not need any derivatives.
                          ! Call eqstat2 and request no derivatives
         CALL EQSTAT2(TL,T,PL,P,DL,D,X,Z,BETA,BETAI,BETA14,FXION,RMU,
     *   AMU,EMU,ETA,QDT,QDP,QCP,DELA,QDTTx,QDTPx,QATx,QAPx,QCPTx,
     *   QCPPx,LDERIV2,LATMO,KSAHA)
c            Note that the QDTT,QDTP,QAT,QAP,QCPT,QCPP OUTPUTS are to
c            dummy variables so they can not affect the previously
c            calculated second derivatives.
      ENDIF

      RETURN
      END
