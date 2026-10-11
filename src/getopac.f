C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     GETOPAC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE GETOPAC(DL,TL,X,Z,O,OL,QOD,QOT,FXION)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      REAL*8 FXION(3)
C MHP 8/25 Removed unused variables
C      CHARACTER*256 FLAOL, FPUREZ, FKUR2, FcondOpacP
C OPACITY COMMON BLOCKS - modified 3/09
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove dead opacity-table Z-value inputs
C 9/24/26 MHP via Claude
C code changed to merge COMMON /MISCOPAC/ and COMMON/NWLAOL/ into
C COMMON /NEWOPAC/
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
      COMMON/NEWOPAC/ZOPAL951,TMOLMIN,TMOLMAX,TOLLAOL,LALEX06,LOPAL95,
     *  L2Z,LLAOL,LPUREZ,LcondOpacP
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON/OPTAB/OPTOL,ZSI,IDT,IDD(4)
      SAVE
C
C     THIS SUBROUTINE CALCULATES THE OPACITY FOR A GIVEN X AND Z.
C     IF LDIFZ=T OR LZRAMP=T THEN INTERPOLATE BETWEEN TWO Z TABLES.
C     IN A SMALL T RANGE THE ATMOSPHERE AND INTERIOR OPACITY ARE
C     RAMPED FROM ONE TO THE OTHER.
C
C
C     GET ATMOSPHERE OPACITY
C
      LGOTATM = .FALSE.
      IF(TL.LE.TMOLMAX)THEN
         IF (LALEX06) THEN
            CALL GETALEX06(DL,TL,X,Z, SO, SOL,SQOD,SQOT)
          LGOTATM = .TRUE.
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/23/26 MHP via Claude
C added trap for no molecular (low-T) opacity table chosen
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
         ELSE
            WRITE(ISHORT,*)'NO MOLECULAR OPACITY TABLE CHOSEN',
     *      ' RUN STOPPED. X Z TL=',X,Z,TL
            STOP
         END IF
      ENDIF
  100 CONTINUE

C     GET INTERIOR OPACITY IF NEEDED

      IF (TL .LT. TMOLMIN.AND.LGOTATM) GOTO 1000

C     HELIUM BURNING REGION (HB EVOLUTION) USE PURE Z TABLE
C mhp 7/12 Altered logic of the opacities in the He burnng
C regime.  Switched to exclusive usage of OPAL below 50 million K
C     and switched the ramp to above Z = 0.1.
c$$$  JCZ 211125 changing temperature limit to 7.0 to accommodate
C     semiconvection+overshoot HB models, which can reach lower core temperatures
      IF((Z .GT. 0.1D0) .AND. (TL.GT.7.0D0)) THEN
         IF(.NOT.LPUREZ) THEN
            WRITE(ISHORT, *)' ERROR: Z>0.10 T > 5 X 10^7 K',
     *        ' NEED PURE Z TABLE TO CONTINUE. Z,LOG T=',Z, TL
              STOP
       END IF
       CALL GTPURZ(DL,TL,OZ,OLZ,QODZ,QOTZ)
         IF (LOPAL95) THEN
C MHP 7/12 INTERPOLATE TO MAXIMUM Z IN TABLE
             ZIT = 0.1D0
             CALL GETOPAL95(DL,TL,X,ZIT,O,OL,QOD,QOT)
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables; added trap
C for no opacity table chosen
         ELSE
            WRITE(ISHORT,*)'NO OPACITY TABLE CHOSEN',
     *      ' RUN STOPPED. X Z TL=',X,Z,TL
            STOP
         END IF
       SLOPE = (OL-OLZ)/(ZIT-1.0D0)
       OL = OLZ + (Z-1.0D0)*SLOPE
       O = 10.0D0**OL
       SLOPE = (QOD-QODZ)/(ZIT-1.0D0)
       QOD = QODZ + (Z-1.0D0)*SLOPE
       SLOPE = (QOT-QOTZ)/(ZIT-1.0D0)
       QOT = QOTZ + (Z-1.0D0)*SLOPE
C      ELSE
      ELSE IF((Z.GT.0.12D0) .OR. ((ABS(Z-ZENV) .GT. OPTOL)
     *      .AND..NOT.L2Z .AND. .NOT.LOPAL95))THEN
C     JCZ 211125 changed to 10^7 K in message to reflect above change in logic.
         WRITE(ISHORT,*)' Z>0.12 T < 10^7 K',
     *   ' OUTSIDE OPAL OPACITY TABLE RANGE OR Z',
     *   ' OUTSIDE SINGLE TABLE USED.Z,ZENV,LOG T=',Z,ZENV,TL
         STOP
C
C     NOT HELIUM BURNING REGION (HB EVOLUTION) OR L2Z=T AND
C     Z STILL NOT TOO LARGE IN CORE (<.15) SO CAN USE
C     SECOND Z TABLE RATHER THAN PURE Z TABLE
C
C      IF (LOPAL95) THEN
      ELSE IF (LOPAL95) THEN
         CALL GETOPAL95(DL,TL,X,Z,O,OL,QOD,QOT)
C 9/23/26 MHP via Claude
C code changed to remove the OPAL92 opacity tables
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables
C MHP 7/12 INSERT FINAL TRAP - NO OPACITY COMPUTED
C SHOULD NOT BE ABLE TO GET HERE.
      ELSE
         WRITE(ISHORT,*)'NO OPACITY TABLE CHOSEN',
     *   ' RUN STOPPED. X Z TL=',X,Z,TL
         STOP
      END IF
C      END IF
C
 1000 CONTINUE
C     DO A RAMP BETWEEN SURFACE AND INTERIOR OPACITY

      IF (LGOTATM .AND. TL .LE. TMOLMAX) THEN
         IF( TL.GE.TMOLMIN) THEN
C             RR = DL - 3.0D0*(TL-6.0D0)
C             WRITE(*,*)RR,TL,OL,SOL
            RMPWT = (TL-TMOLMIN)/(TMOLMAX-TMOLMIN)
            O = RMPWT*O + (1.0D0-RMPWT)*SO
            OL = DLOG10(O)
            QOD = RMPWT*QOD + (1.0D0-RMPWT)*SQOD
            QOT = RMPWT*QOT + (1.0D0-RMPWT)*SQOT
       ELSE
            O = SO
            OL = SOL
            QOD = SQOD
            QOT = SQOT
       END IF
      END IF
C     DO CONDUCTIVE OPACITY CORRECTION
      IF (LcondOpacP) THEN
C Get Potekhin conductive opacity
            CALL condOpacPInt(DL,TL,X,Z,OC,OCL,QODC,QOTC,FXION,LCONDO)
      ELSE
         LCONDO = .FALSE.
      END IF

      IF (.NOT. LCONDO) THEN
C If we get here we have no Potekhin opacity, so we
C try for Hubbard Lampe
         IF(TL.LT.4.2D0) THEN
            RETURN
         ELSE IF(DL.LT.(2.0D0*TL-13.0D0)) THEN
            RETURN
         ELSE
C Do Hubbard Lampe conductive opacity calculation
          COND = DLOG10(1.0D0-0.6D0*X) - 14.6196D0 -
     *             (3.5853D0+0.1386D0*DL)*DL +
     *             (5.1324D0-0.3219D0*TL)*TL + 0.3901D0*DL*TL
          OC = 10.0D0**COND
            QODC = 0.3901D0*TL - 0.2772D0*DL - 3.5853D0
            QOTC = 0.3901D0*DL - 0.6438D0*TL + 5.1324D0
         ENDIF
      ENDIF

      OX = O   ! Save the radiative opacity stuff
      QODX = QOD
      QOTX = QOT
C Add the opacities apppropriately
      O = OX*OC/(OX + OC)  ! e.g. 1/O = 1/OX + 1/OC
      OL = DLOG10(O)
      QOD = (QODX + QODC - (OX*QODX + OC*QODC)/(OX + OC))
      QOT = (QOTX + QOTC - (OX*QOTX + OC*QOTC)/(OX + OC))

      RETURN
      END
