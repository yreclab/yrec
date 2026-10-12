C------------------------    GROUP: SR_P     -------------------------------
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C INTPT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE INTPT(PL,TL,TDVAR,NTM,NRM,IVAR,TLOG,NT,NR,
     1                 VAR1,VAR2,Y,VAROUT)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION TDVAR(NTM,NRM,IVAR),TLOG(NTM),VAR1(IVAR,4),
     1          VAR2(IVAR,4),VAROUT(IVAR),Y(IVAR)
      DIMENSION IRM(4),IR(4,4),IT(4),XX(4)
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
      INTEGER*4 L
      SAVE
      DO 100 N=1,NT
         IF(TLOG(N).GE.TL) GOTO 101
         IT(1)=N
 100  CONTINUE
 101  IF(IT(1).GE.2) IT(1)=IT(1)-1
      ITMAX=NT-3
      IF(IT(1).GT.ITMAX) IT(1)=ITMAX
      DO 150 I=2,4
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C  150  IT(I)=IT(1)+I-1
         IT(I)=IT(1)+I-1
 150  CONTINUE
      DO 210 I=1,4
         IRM(I)=1
         INDT=IT(I)
         PMINI=TDVAR(INDT, 1,2)
         PMAXI=TDVAR(INDT,NR,2)
         IF(PL.GT.PMAXI) THEN
            RETURN
         END IF
         DO 200 M=1,NR
            IF(TDVAR(INDT,M,2).GE.PL) GOTO 201
            IRM(I)=M
 200     CONTINUE
 201     IF(IRM(I).GE.2) IRM(I)=IRM(I)-1
         IRMAX=NR-3
         IF(IRM(I).GT.IRMAX) IRM(I)=IRMAX
 210  CONTINUE
      DO 310 I=1,4
C KC 2025-05-30 fixed "Shared DO termination label"
C          DO 310 J=1,4
         DO 311 J=1,4
            IR(J,I)=IRM(I)+J-1
 311     CONTINUE
 310  CONTINUE
      DO 500 ILIR=1,4
         INDT=IT(ILIR)
         DO 400 I=1,4
            INDR=IR(I,ILIR)
            XX(I)=TDVAR(INDT,INDR,2)
 400     CONTINUE
         DO 410 I=1,4
            INDR=IR(I,ILIR)
C KC 2025-05-30 fixed "Shared DO termination label"
C             DO 410 IV=1,IVAR
            DO 411 IV=1,IVAR
               VAR1(IV,I)=TDVAR(INDT,INDR,IV)
 411        CONTINUE
 410     CONTINUE

         II=IVAR
         ID=IVAR
         NP=4
         L=1
         INTER=1
         CALL LIR(PL,XX,Y,VAR1,II,ID,NP,L,INTER)
         DO 420 IV=1,IVAR
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C  420     VAR2(IV,ILIR) = Y(IV)
            VAR2(IV,ILIR) = Y(IV)
 420     CONTINUE

 500  CONTINUE
      DO 600 I=1,4
         INDT=IT(I)
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C  600  XX(I) = TLOG(INDT)
         XX(I) = TLOG(INDT)
 600  CONTINUE

      II=IVAR
      ID=IVAR
      NP=4
      L=1
      INTER=1

      CALL LIR(TL,XX,VAROUT,VAR2,II,ID,NP,L,INTER)

      RETURN
      END
