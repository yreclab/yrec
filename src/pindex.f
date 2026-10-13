C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PINDEX
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE PINDEX(JXBEG,JXEND,LSHELL,M,ID,IDM)

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
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
C 10/13/26 MHP via Claude: removed the unused COMMON/CCOUT/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      DIMENSION ID(JSON)
      SAVE

C  ID IS THE ARRAY OF THE SHELLS TO BE PRINTED OUT;
C  I.E. IF SHELLS 1,3,5,..TO BE PRINTED ID(1)=1,ID(2)=3,..
      ID(1) = 1
      IDM = 2
      IF(LSHELL) THEN
C  PRINT OUT EVERY ZONE IN H-BURNING SHELL
       IF(NPRTPT.LT.JXBEG) THEN
          IBEG = MAX(2,NPRTPT)
          IEND = INT(JXBEG/NPRTPT)*NPRTPT
          DO 10 J = IBEG,IEND,NPRTPT
             ID(IDM) = J
             IDM = IDM + 1
   10       CONTINUE
       ENDIF
       IF(IEND .EQ. JXBEG) THEN
           IXBEG = JXBEG + 1
       ELSE
           IXBEG = JXBEG
       END IF
       DO 20 J = IXBEG,JXEND
          ID(IDM) = J
          IDM = IDM + 1
   20    CONTINUE
       IF(NPRTPT.LT.M) THEN
          IBEG = INT(JXEND/NPRTPT+1)*NPRTPT
          IEND = INT(M/NPRTPT)*NPRTPT
          DO 30 J = IBEG,IEND,NPRTPT
             ID(IDM) = J
             IDM = IDM + 1
   30       CONTINUE
       ENDIF
      ELSE IF(NPRTPT.LT.M) THEN
C  GENERAL CASE; PRINT OUT EVERY NPRTPT POINTS.
       IBEG = MAX(2,NPRTPT)
       IEND = INT(M/NPRTPT)*NPRTPT
       IF (IEND .EQ. M) IEND = IEND - NPRTPT
       DO 40 J = IBEG,IEND,NPRTPT
          ID(IDM) = J
          IDM = IDM + 1
   40    CONTINUE
      ENDIF
      ID(IDM) = M
      RETURN
      END
