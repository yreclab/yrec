C$$$$$$
C       SUBROUTINE TAUINT(HCOMP,HS2,HS1,LCZ,HR,HP,HD,HG,M,SVEL,DEL1,DEL2)  ! KC 2025-05-31
      SUBROUTINE TAUINT(HS1,LCZ,HR,HP,HD,HG,M,SVEL,DEL1,DEL2)
      PARAMETER(JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 10/13/26 MHP via Claude: removed the unused COMMON/COMP/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/DEUTER/ declaration
C (no member referenced here; residue of the obsolete-option removals).
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
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR
C 10/13/26 MHP via Claude
C code changed to remove COMMON/JTEST/: IMAX1, IMAX2 and LJVS are
C referenced nowhere in executable code.  The only code that used LJVS is
C a commented-out block in wrtout.f, removed with it.
C Needs access to this common block: grants knowledge of envellope
C KC 2025-05-30 reordered common block elements
C JvS 08/25 Updated with new elements
      COMMON/ENVSTRUCT/ENVP(JSON),ENVT(JSON),ENVS(JSON),ENVD(JSON),
     *     ENVR(JSON),ENVX(JSON),ENVZ(JSON),LCENV(JSON),
     *     EDELS(3,JSON),EVELS(JSON),EBETAS(JSON),
     *     EGAM1(JSON),EQCP(JSON),EFXIONS(3,JSON),
     *     ENVO(JSON), ENVL(JSON),EQDT(JSON),NUMENV     
C G Somers 3/17, ADDING NEW TAUCZ COMMON BLOCK
      COMMON/OVRTRN/TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
C       DIMENSION HCOMP(15,JSON),HS2(JSON),LCZ(JSON),
      DIMENSION LCZ(JSON),
     *     HR(JSON), HP(JSON), HD(JSON), HG(JSON), HS1(JSON),  ! XSUM(15)
     *     DEL1(JSON), DEL2(JSON), SVEL(JSON)
      SAVE


C JVS 02/12 CALCULATE THE LOCAL CONVECTIVE OVERTURN TIMESCALE AT THE BASE
C OF THE CZ. IN OLDER VERSIONS THIS WAS ONLY DONE FOR ROTATING MODELS;
C THIS MAKES IT SO TAUCZ IS CALCULATED FOR ALL MODELS.
C THIS CODE SNAGGED FROM MIDMOD
C  DETERMINE EXTENT OF SURFACE CONVECTION ZONE.
      LALLCZ = .FALSE.
C JVS Allows the last point to be stable.
      IF(LCZ(M) .OR. LCZ(M-1))THEN
C  SURFACE C.Z. EXISTS.  FIND LOWEST SHELL (IMAX), WHICH IS ALSO THE
C  UPPERMOST ZONE CONSIDERED FOR STABILITY AGAINST ROTATIONALLY INDUCED MIXING.
         DO 71 I = M-1,1,-1
            IF(.NOT.LCZ(I)) GOTO 81
   71    CONTINUE
         LALLCZ = .TRUE.
         I = 0
   81    IMAX = I + 1
C  HSTOP IS THE MASS AT THE TOP OF THE C.Z.
C  HSBOT IS THE MASS AT THE BOTTOM OF THE C.Z.
         HSTOP = HS1(M)
         IF(IMAX.GT.1)THEN
            HSBOT = 0.5D0*(HS1(IMAX)+HS1(IMAX-1))
         ELSE
            HSBOT = 0.0D0
         ENDIF
C  LCZSUR=T IF A SURFACE C.Z.DEEP ENOUGH FOR ANGULAR MOMENTUM LOSS EXISTS
         IF((HSTOP-HSBOT)/CMSUN.GT.0.0D0)THEN
            LCZSUR = .TRUE.
         ELSE
            LCZSUR= .FALSE.
         ENDIF
      ELSE
C  NO SURFACE C.Z.
         IMAX = M
         LCZSUR = .FALSE.
      ENDIF

      IF(LCZSUR)THEN
         IF(.NOT.LALLCZ)THEN
            IF(.NOT.LROT)THEN
               HG(IMAX)=HS1(IMAX)*EXP(CLN*(CGL-2.0D0*HR(IMAX)))
               HG(IMAX-1)=HS1(IMAX-1)*EXP(CLN*(CGL-2.0D0*HR(IMAX-1)))
            ENDIF
C PINPOINT RCZ
            DD2 = DEL1(IMAX-1)-DEL2(IMAX-1)
            DD1 = DEL1(IMAX)-DEL2(IMAX)
            FX = DD2/(DD2-DD1)
C INFER HP
            ENVRCL = HR(IMAX-1)+FX*(HR(IMAX)-HR(IMAX-1))
            ENVRC = EXP(CLN*ENVRCL)
            PS2 = EXP(CLN*(HP(IMAX)-HD(IMAX)))/HG(IMAX)
            PS1 = EXP(CLN*(HP(IMAX-1)-HD(IMAX-1)))/HG(IMAX-1)
            PSCA = PS1 + FX*(PS2-PS1)
            RTESTL = DLOG10(ENVRC+PSCA)
C FIND V
            DO K = IMAX+1,M
               IF(HR(K).GT.RTESTL)THEN
                  FX = (RTESTL-HR(K-1))/(HR(K)-HR(K-1))
                  CVEL = SVEL(K-1)+FX*(SVEL(K)-SVEL(K-1))
                  GOTO 85
               ENDIF
            END DO
            ! One pressure scale height overshoots edge of interior
            ! calculation. Stitch on the envelope for more room
            DO K = 2,NUMENV
               IF(ENVR(K).GT.RTESTL .AND. EVELS(K) .GT. 0.0)THEN
                  FX = (RTESTL-HR(M))/(ENVR(K)-HR(M))
                  CVEL = SVEL(M)+FX*(EVELS(K)-SVEL(M))
                  GOTO 85
               ENDIF
            END DO
            CVEL = SVEL(M)
 85         CONTINUE
C DEFINE TAUCZ
            TAUCZ = PSCA/CVEL

         ELSE
C INFER HP
            IF(.NOT.LROT)THEN
               HG(1)=HS1(1)*EXP(CLN*(CGL-2.0D0*HR(1)))
            ENDIF
            PSCA2 = EXP(CLN*(HP(1)-HD(1)))/HG(1)
            RTEST2 = EXP(CLN*HR(1))
            IF(PSCA2.LE.RTEST2)THEN
C HP < R AT THE FIRST POINT.  ASSUME V CONSTANT INSIDE AND HP = K/R FOR
C SLOWLY VARYING DENSITY AND PRESSURE NEAR THE CENTER.
               CVEL = SVEL(1)
               PSCA = (PSCA2*RTEST2)**0.5D0
               TAUCZ = PSCA/CVEL
            ELSE
               DO K = 2,M
                  PSCA1 = PSCA2
                  RTEST1 = RTEST2
                  IF(.NOT.LROT)THEN
                     HG(K)=HS1(K)*EXP(CLN*(CGL-2.0D0*HR(K)))
                  ENDIF
                  PSCA2 = EXP(CLN*(HP(K)-HD(K)))/HG(K)
                  RTEST2 = EXP(CLN*HR(K))
C FIND LOCATION WHERE HP = R
                  IF(PSCA2.LE.RTEST2)THEN
                     FX = (RTEST1-PSCA1)/((PSCA2-RTEST2)-(PSCA1-RTEST1))
C FIND V
                     CVEL = SVEL(K-1)+FX*(SVEL(K)-SVEL(K-1))
                     PSCA = PSCA1+FX*(PSCA2-PSCA1)
C DEFINE TAUCZ
                     TAUCZ = PSCA/CVEL
                     GOTO 95
                  ENDIF
               END DO
               K = M
               CVEL = SVEL(M)
               PSCA = PSCA2
               TAUCZ = PSCA/CVEL
 95            CONTINUE
            ENDIF
         ENDIF
      ELSE
         TAUCZ = 0.0D0
      ENDIF

C--------------------------------------------------------------
C                  OPEN(UNIT=100,FILE='diagnostic.out',STATUS='OLD')
C                  DO 1505 I=1,M
C                  IF (LCZ(I)) HOLD = 1.0
C                  IF (.NOT.LCZ(I)) HOLD = 0.0
C                              WRITE(100,1504), HS2(I), HS1(I), HR(I),HOLD,
C     *                  DEL1(I), DEL2(I), SVEL(I),
C1505                  CONTINUE
C1504                  FORMAT(1X,7E16.8)
C                  CLOSE(100)
C----------------------------------------------------------------

C END JVS
      RETURN
      END
