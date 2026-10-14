C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SURFBC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SURFBC(TRIT,TRIL,CFENV,PS,TS,RS,FTRI,ISTORE,ESTORE,
C      *       LNEW,LRESET,LSBC,KSAHA,KENV,KATM,HSTOT,BL,  ! KC 2025-05-31
     *       LNEW,LRESET,KSAHA,KENV,KATM,HSTOT,BL,
     *       TEFFL,X,Z,FPL,FTL,LFLP,PLIM,LC,M,CMIXL)

      PARAMETER(JSON=5000)
C INPUTS   LNEW = .T.    START UP WITH 3 NEW ENVELOPES ABOUT(TEFFL,BL)
C INPUTS   LRESET = .T.  REDO ALL 3 ENVELOPES AND RETRIANGULATE IF NEED
C BOTH LNEW AND LRESET ARE RESET TO .FALSE.
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
     *  IOPALE,ISCVH,ISCVHE,ISCVZ,ISOUND
      DIMENSION LTRI(3),TRIT(3),TRIL(3),CFENV(9),PS(3),TS(3),RS(3),
     *     ESTORE(4),LC(JSON)
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
C 10/13/26 MHP via Claude: removed the unused COMMON/CENV/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR,C_2
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON /ALATM05/ AL_TEFFLmin,AL_TEFFLmax

C 10/13/26 MHP via Claude: removed the unused COMMON/ATMOS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      DATA NUMENV/0/

C G Somers END

      SAVE
C MHP 9/01
      IF(KTTAU .EQ. 3) THEN
         IF(TEFFL.GE. 3.95D0) THEN
            write(*,*)
            WRITE(*,5) TEFFL
 5          FORMAT('LOG TEFF OF ',F7.3,' ABOVE 3.95 - SWITCH'
     *             ,'TO GRAY ATMOSPHERE BOUNDARY CONDITION')
            write(*,*)
            KTTAU = 0
            LNEW = .TRUE.
C MHP 06/13 Remember that flag is switched
            LTTAU = .TRUE.
         ENDIF
      ENDIF
      IF(KTTAU. EQ. 4) THEN
         IF(TEFFL.GE. AL_TEFFLmax) THEN
            write(*,*)
            WRITE(*,7) TEFFL,AL_TEFFLmax
 7          FORMAT('LOG TEFF OF ',F7.3,' ABOVE Allard Table max ',F7.3
     *             ,'  - SWITCH TO GRAY ATMOSPHERE BOUNDARY CONDITION')
            write(*,*)
            KTTAU = 0
            LNEW = .TRUE.
C MHP 06/13 Remember that flag is switched
            LTTAU = .TRUE.
         ENDIF
      ENDIF
      IF(LTTAU)THEN
         IF(KTTAU0.EQ.3.AND.TEFFL.LT.3.95D0)THEN
            KTTAU = KTTAU0
            LTTAU = .FALSE.
            WRITE(*,9) TEFFL
 9          FORMAT('LOG TEFF OF ',F7.3,' BELOW 3.95 - SWITCH'
     *      ,' BACK TO KURUCZ ATMOSPHERE BOUNDARY CONDITION')
         ELSE IF(KTTAU0.EQ.4.AND.TEFFL.LT.AL_TEFFLmax)THEN
            KTTAU = KTTAU0
            LTTAU = .FALSE.
            WRITE(*,11) TEFFL,AL_TEFFLmax
 11         FORMAT('LOG TEFF OF ',F7.3,' below Allard Table max ',F7.3
     *     ,'  - SWITCH BACK TO ALLARD ATMOSPHERE BOUNDARY CONDITION')
         ENDIF
      ENDIF
      LFLP = .FALSE.
C IF LNEW0, REDO ALL 3 ENVELOPES EVERY MODEL
      IF(LNEW.OR.LRESET) THEN
C REDO ALL THREE ENVELOPES
       LTRI(1) = .FALSE.
       LTRI(2) = .FALSE.
       LTRI(3) = .FALSE.
       ISTORE = 0
       TRIERR = 0.0D0
       LRESET = .FALSE.
      ELSE
       LTRI(1) = .TRUE.
       LTRI(2) = .TRUE.
       LTRI(3) = .TRUE.
       TRIERR = 0.0D0
      ENDIF
      IF(LNEW) THEN
C STARTING PROCEDURE
       FTRI = +1.0D0
       TRIT(3) = TEFFL
       TRIT(1) = TRIT(3) - 0.5D0*TRIDT
       TRIT(2) = TRIT(1) + TRIDT
       TRIL(3) = BL + 0.5D0*TRIDL
       TRIL(1) = TRIL(3) - TRIDL
       TRIL(2) = TRIL(1)
       LNEW = .FALSE.
      ELSE
C CHECK TRIANGULATION OF POINT (TEFFL,BL)
 10      CONTINUE
       DO 20 I1 = 1,3
          I2 = MOD(I1,3) + 1
          I3 = MOD(I2,3) + 1
          TEMP = FTRI*((TRIL(I2)-TRIL(I3))*(TEFFL-TRIT(I2)) +
     *           (TRIT(I3)-TRIT(I2))*(BL  -TRIL(I2)) )
          IF(TEMP.LT.-TRIERR) THEN
             FTRI = -FTRI
             TRIT(I1) = TRIT(I2) + TRIT(I3) - TRIT(I1)
             TRIL(I1) = TRIL(I2) + TRIL(I3) - TRIL(I1)
             LTRI(I1) = .FALSE.
             TRIERR = 0.0D0
             GOTO 10
          ENDIF
 20      CONTINUE
      ENDIF
C COMPUTE NEW ENVELOPES IF NECESSARY
      LRENV = .FALSE.
      DO 40 I = 1,3
       IF(.NOT.LTRI(I)) THEN
C NEW ENVELOPE NEEDED
          LFLP = .TRUE.
          TEFFL = TRIT(I)
          B = DEXP(CLN*TRIL(I))
          RL = 0.5D0*(TRIL(I) + CLSUNL - 4.0D0*TEFFL - C4PIL - CSIGL)
          GL = CGL + STOTAL - RL - RL
          NUMENV = NUMENV + 1
C G Somers 11/14, LPENV FUNCTIONALITY NOW INCLUDED IN LSTENV.
            LPENV = .FALSE.
C          LPENV = MOD(NUMENV,NPENV).EQ.0
C          IF(.NOT.LSTORE) LPENV = .FALSE.
C          IF(LPENV) THEN
C             WRITE(ISHORT,30) I,TRIT(I),TRIL(I)
C 30            FORMAT(/,' NEW ENVELOPE NO.',I2,' LOG(TE) =',F9.5,
C     *              '  LOG(L) =',F8.5)
C          ENDIF
C G Somers END
          IXX=I
          LSBC0 = .TRUE.
C DBG PULSE: DO NOT DO PULSE OUTPUT
            LPULPT = .FALSE.
C G Somers 10/14, FOR SPOTTED RUNS, FIND THE
C PRESSURE AT THE AMBIENT TEMPERATURE ATEFFL
          IF(LC(M).AND.SPOTF.NE.0.0.AND.SPOTX.NE.1.0)THEN
               ATEFFL = TEFFL - 0.25*LOG10(SPOTF * SPOTX**4.0 + 1.0 - SPOTF)
          ELSE
             ATEFFL = TEFFL
          ENDIF
          CALL ENVINT(B,FPL,FTL,GL,HSTOT,IXX,LPENV,LSBC0,PLIM,RL,
     *           ATEFFL,X,Z,ESTORE,ISTORE,KATM,KENV,KSAHA,PS,
     *           RS,TS,LPULPT,CMIXL)
C G Somers END
          LRENV = .TRUE.
       ENDIF
 40   CONTINUE
      IF(LRENV) THEN
C RECOMPUTE COEFFICIENTS
       TEMP = 1.0D0/(TS(2)-TS(1))
       TEMP1 = (TS(3)-TS(1))*TEMP
       TEMP2 = 1.0D0/(PS(3)-PS(1)-TEMP1*(PS(2)-PS(1)))
       CFENV(1) = (  RS(3)-  RS(1)-TEMP1*(  RS(2)-  RS(1)))*TEMP2
       CFENV(4) = (TRIL(3)-TRIL(1)-TEMP1*(TRIL(2)-TRIL(1)))*TEMP2
       CFENV(7) = (TRIT(3)-TRIT(1)-TEMP1*(TRIT(2)-TRIT(1)))*TEMP2
       CFENV(2) = (  RS(2)-  RS(1)-CFENV(1)*(PS(2)-PS(1)))*TEMP
       CFENV(5) = (TRIL(2)-TRIL(1)-CFENV(4)*(PS(2)-PS(1)))*TEMP
       CFENV(8) = (TRIT(2)-TRIT(1)-CFENV(7)*(PS(2)-PS(1)))*TEMP
       CFENV(3) =   RS(1) - CFENV(1)*PS(1) - CFENV(2)*TS(1)
       CFENV(6) = TRIL(1) - CFENV(4)*PS(1) - CFENV(5)*TS(1)
       CFENV(9) = TRIT(1) - CFENV(7)*PS(1) - CFENV(8)*TS(1)
       WRITE(ISHORT,50)(I,LTRI(I),TRIT(I),TRIL(I),PS(I),TS(I),RS(I),
     *        (CFENV(I+I+I-3+J),J=1,3), I=1,3)
 50      FORMAT(' ENVELOPE TRIANGLE  LOG(TE)  LOG(L)   LOG(P)   LOG(T)',
     *        3X,'LOG(R)   COEFFICIENTS'/I14,L1,2X,5F9.5,8X,'LOG(R)',
     *        3F10.5/ I14,L1,2X,5F9.5,5X,'LOG(L/L0)',3F10.5/
     *        I14,L1,2X,5F9.5,7X,'LOG(TE)',3F10.5)
C  60      FORMAT(' COUNTS  KATM',I5,'  KENV',I5,'  KSAHA',I5)
      ELSE
       WRITE(ISHORT,70)
 70      FORMAT(' ENVELOPE TRIANGLE NOT CHANGED')
      ENDIF
      RETURN
      END
