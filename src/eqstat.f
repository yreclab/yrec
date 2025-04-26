
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

      use params, only : nts, nps
      use settings, only : CLN  ! /CONST1/
      use settings, only : LNumDeriv  ! /OPALEOS/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION FX(12),ATOMWT(4),FXION(3),ATOMW2(12)
      DATA NZP1/12/
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      DATA SCALET,SCALES/0.500D0, 2.000D0/
      DATA ATOMW2/23.0D0,26.99D0,24.32D0,55.86D0,28.1D0,12.015D0,
     *            1.008D0,16.0D0,14.01D0,39.96D0,20.19D0,4.004D0/
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
