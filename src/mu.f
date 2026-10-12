C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MU
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MU(T,P,D,X,Z,RMU,AMU,EMU,BETA)

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION ATOMWT(4)
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON/CTLIM/ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TENV,TGCUT
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR
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
C       DATA NZP1/12/
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      SAVE

C SET UP FRACTIONAL ABUNDANCES
      DFX1 = (X - XENV)
      DFX12 = (Z - ZENV)
      IF(DABS(DFX1) + DABS(DFX12) .LT. 1.0D-5) THEN
C USE ENVELOPE ABUNDANCES
         AMU = AMUENV
      ELSE
         DFX1 = DFX1*ATOMWT(1)
         DFX12 = DFX12*ATOMWT(3)
         DFX4 = (XENV+ZENV -X-Z)*ATOMWT(2)
C ASSUME EXCESS Z(METALS) IS IN THE FORM OF CARBON(12)
         AMU = AMUENV + DFX1 + DFX4 + DFX12
      ENDIF
      EE=((BETA*P)/(D*T*CGAS*AMU))-1.0D0
      EMU=EE*AMU
      RMU=CGAS*(AMU+EMU)

      RETURN
      END
