C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C CHKSCAL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE CHKSCAL(BL, TEFFL, DAGE, NK,ALRI,LSTAR,LPASSR)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/RUNLOOP/ into RUNLOOP_MOD.  ONLY lists
C the members this routine references, so no unused name from the block
C is imported.  See runloop_mod.f for the block history and for why the
C module declares the types the implicit rules used to supply.
      USE RUNLOOP_MOD, ONLY: RESCAL, LENDAG
C     ONLY CALLED FOR EVEN NK, ASSUMES RESCALING ON ODD NK AND EVOLVING
C     ON EVEN NK
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 10/13/26 MHP via Claude
C code changed to replace COMMON/CALSTAR/ with explicit arguments.
C setscal.f initializes ALRI, LSTAR and LPASSR, chkscal.f reads and
C updates ALRI and sets the two flags, and main.f reads the flags; main.f
C calls both routines, so it now owns all three.  ALRI is read as well as
C written inside chkscal.f and is carried across calls there, which
C main.f's blanket SAVE preserves exactly as the block did.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR,C_2
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
     * WEAKSCREENING,KTTAU,KTTAU0,LTTAU,XLS,XLSTOL,STEFF,SR,LTEFF,
     * LCALST,LSTORE,LSTATM,LSTENV,LSTMOD,LSTPHYS,LSTROT,LSTCH,
     * NPRTMOD,NPRTPT,NPOINT,TRIDT,TRIDL,LNEW0,NMODLS(50),LFIRST(50),
     * NUMRUN,SSTANDARD(17),ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TGCUT,
     * HTOLER(5,2),FCORR0,FCORRI,HPTTOL(12),NITER1,NITER2,NITER3,WMAX,
     * EXMD,EXW,EXTAU,EXR,EXM,EXL,EXPR,CONSTFACTOR,EXCEN,LJDOT0,
     * ETADH0,ETADH1,LDH,TDISK,PDISK,LDISK,DPENV,ALPHAC,ALPHAE,ALPHAM,
     * BETAC,LOVSTC,LOVSTE,LOVSTM,LSEMIC,LADOV,LOVMAX,ATMSTP,ENVSTP,
     * LSOLWIND,LMIXTURE,LISOTOPE,FRAC_C,FRAC_N,FRAC_O,R12_13,R16_18,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,ZOPAL951,TMOLMIN,
     * TMOLMAX,TOLLAOL,LALEX06,LOPAL95,LPUREZ,LcondOpacP,LNULOS1,
     * OPTOL,LNEWTCZ,LCALCENV,PMMSOLP,PMMSOLW,PMMSOLTAU,LMWIND,
     * LROSSBY,LBSCALE,LPULSE,IPVER,LSCV,ENDAGE(50),SETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50),LVFC,LDIFAD,FW,FC,FES,
     * FGSF,FMU,FSS,RCRIT,RSCLZC(50),RSCLZM1(50),RSCLZM2(50),LZRAMP
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
C 10/12/26 MHP via Claude
C code changed to demote BLI, AGER, BLR, BLRP and AGEI from
C COMMON/CALSTAR/ to locals of this routine.  All five are written and
C read only here -- BLI/AGEI at the interpolation setup, BLR/AGER/BLRP in
C the radius-matching iteration below -- while main.f, parmin.f and
C setscal.f merely carried them positionally.  The blanket SAVE below
C keeps their values across calls exactly as COMMON storage did, which
C BLRP relies on, being set on one call and read on the next.  Only
C ALRI, LSTAR and LPASSR are genuinely shared; setscal.f initializes
C those three.
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      COMMON/IOUNITS/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,
     *  IOWR,IFIRST,IRUN,ISTAND,IFERMI,IOPMOD,IOPENV,IOPATM,ISNU,
     *  IALEX06,ICLCD,IJLAST,IOPUREZ,IcondOpacP,ILIV95,IOATM,IOATMA,
     *  IOPALE,ISCVH,ISCVHE,ISCVZ,ISOUND
      SAVE
C     LSTAR     T - have got a star at Teff and L
C     LPASSR    T - on run have just passed Teff
C     XLS       Luminosity (L/Lsun) wanted by adjusting Y
C     XLSTOL    tolerance wanted for luminosity
C     LTEFF     T - specify Teff for star
C               F - specify R/Rsun for star
C     STEFF     Effective temperature of star (K) or...
C     SR        Radius of star (R/Rsun)
C     TEFF      Teff of current model
C     ALR       log(R/Rsun) of current model
C     ALRI      log(R/Rsun) of previous model
C     DAGE      age of current model (Gyr)
C     AGEI      age of previous model (Gyr)
C     AGER      age of model at R*
C     BL        luminosity of current model log(L/Lsun)
C     BLI       luminosity of previous model
C     BLR       luminosity of model at R
C     BLRP      luminosity of model at R* of previous run
C     XP        X of previous run = RESCAL(2, NK-1)
C
C     Check if star has passed R*.
C     If not store L and age and return.
      LPASSR=.FALSE.
      TEFF = 10.0D0**TEFFL
      ALR = SQRT((10.0D0**BL)*CLSUN/(C4PI*CSIG))/(TEFF*TEFF*CRSUN)
      IF(ALR.GT.ALRI) THEN
         IF(.NOT.(ALR.GT.SR.AND.ALRI.LE.SR)) THEN
              BLI = BL
              AGEI = DAGE
              ALRI = ALR
              RETURN
          END IF
      ELSE
          IF (.NOT.(ALR.LT.SR.AND. ALRI.GE.SR)) THEN
              BLI = BL
              AGEI = DAGE
              ALRI = ALR
              RETURN
           END IF
      ENDIF
C
C     Check if track has passed through Teff the right number of
C     times. If not store L and age and return.
C ZZZ
      WRITE(*,*) ' Just passed R*'
      WRITE(ITRACK,*) '#Just passed R*'
      LPASSR = .TRUE.
C
C     Have previous L,Age and current L,Age (one before R* and
C     one after R*).  Interpolate to get L,Age at R*
      DLDR = (BL-BLI)/(ALR-ALRI)
      BLR = BL + DLDR*(SR-ALR)
      DADR = (DAGE-AGEI)/(ALR-ALRI)
      AGER = DAGE + DADR*(SR-ALR)
      WRITE(*,*) ' X, LogL/Lsun at R* =', RESCAL(2,NK-1), BLR
      WRITE(ITRACK,*) '#X, LogL/Lsun at R* =', RESCAL(2,NK-1), BLR
      IF (ABS(10.0D0**BLR-XLS) .LE. XLSTOL) THEN
C        Get here then have track that passes through specified
C        L and R. Use age at R for final
C        run to stop at that age. Do one more run
C        stopping at interpolated age.
         LSTAR=.TRUE.
       LENDAG(NK+1) = .TRUE.
       ENDAGE(NK+1) = AGER*1.0D9
       LENDAG(NK+2) = .TRUE.
       ENDAGE(NK+2) = AGER*1.0D9
       RESCAL(2,NK+1) = RESCAL(2,NK-1)
       XENV0A(NK+1) = RESCAL(2,NK+1)
       XENV0A(NK+2) = XENV0A(NK+1)
C
      WRITE(*,*) ' Have hit R* & L*, prepare final run to age:',
     1  AGER
      WRITE(ITRACK,*)'#Have hit R* & L*, prepare final run to age:',
     1  AGER
         RETURN
      ELSE
         IF (NK .EQ. 2) THEN
C           First time through. Save L and X at R*.
C           Add 0.01 to Y. Start next run.
            BLRP = BLR
          XP = RESCAL(2,NK-1)
          X = XP - 0.01D0
          RESCAL(2,NK+1) = X
          XENV0A(NK+1) = X
          XENV0A(NK+2) = X
C
      WRITE(*,*) ' NK=2, Y=Y+0.01, Setup next run, X=', X
      WRITE(ITRACK,*) '#NK=2, Y=Y+0.01, Setup next run, X=', X
            RETURN
       ELSE
C           If NK=4,6,8,... (second and more times through) then
C           Use current and previous values of L at R and X to calculate
C           dX/dlogL. Save L.  Start next run.
            X = RESCAL(2, NK-1)
          XP = RESCAL(2, NK-3)
            DXDL = (X-XP)/(BLR-BLRP)
          X = DXDL*(LOG10(XLS)-BLR)+X
C
      WRITE(*,*) ' Setup next run, NK, X =', NK, X
      WRITE(ITRACK, *) ' Setup next run, NK, X =', NK, X
          BLRP = BLR
          RESCAL(2,NK+1) = X
          XENV0A(NK+1) = X
          XENV0A(NK+2) = X
       END IF
      ENDIF
      RETURN
      END
