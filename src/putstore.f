C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PUTSTORE - Write out a verbose stellar model to the .store file. This program
C            is mostly a clone of wrtlst.f and putmodel2.f, combined.
C
C G Somers  11/14
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 06
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE PUTSTORE(HCOMP,HD,HL,HP,HR,HS,HT,LC,TRIT,TRIL,PS,
     *TS,RS,CFENV,FTRI,TLUMX,JCORE,JENV,MODEL,M,SMASS,TEFFL,BL,HSTOT,
     *DAGE,DDAGE,OMEGA,HS1,ETA2,R0,FP,FT,HJM,HI,CMIXL,XMSOL,COMPMIX)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD

C  PUTSTORE PUTS THE MOST RECENT VERBOSE OUTPUT FILE INTO THE .STORE FILE,
C  EITHER AT SPECIFIED AGES, EVERY NPRTMOD MODELS, OR AT THE END OF RUNS.

C     WRITE MODEL OUT IN ASCII FORMAT
      PARAMETER (JSON=5000)
      PARAMETER (NTS=63, NPS=76)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      CHARACTER*6 EOS
c     CHARACTER*4 ATM, LOK, HIK, COMPMIX
c MHP 4/25 changed LOK name to make it unique, used elsewhere
      CHARACTER*4 ATM, ALOK, HIK, COMPMIX
C MHP 8/25 Removed unused variables
C      CHARACTER*256 FLAOL, FPUREZ
C      CHARACTER*256 FOPALE,FOPALE01,FOPALE06  ! FcondOpacP

C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
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
      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     * HS(JSON),HT(JSON),LC(JSON),TRIT(3),TRIL(3),PS(3),TS(3),RS(3),
     * CFENV(9),TLUMX(8),OMEGA(JSON),FP(JSON),FT(JSON),ETA2(JSON),R0(JSON),
     * HJM(JSON),HI(JSON),ID(JSON),HS1(JSON)
C llp  3/19/03 Add COMMON block /I2O/ for info directly transferred from
C      input to output model - starting with a code for th initial model
C      compostion (COMPMIX)
C 10/13/26 MHP via Claude
C code changed to replace COMMON/I2O/ with an explicit argument.  COMPMIX
C is CHARACTER, which does not belong in a COMMON block.  GETMODEL2,
C GETYREC7 and PUTMODEL2 already took it as an argument; only these three
C files shared it through the block.

C llp 3/19/03 Add required COMMON blocks such that header flags
C     ATM, EOS, HIK and LOK can be determined.
C 10/13/26 MHP via Claude: removed the unused COMMON/ATMOS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 8/17 ADDED EXCEN, C_2 TO COMMON BLOCK FOR MATT ET AL. 2012 CENT. TERM
C 10/13/26 MHP via Claude: removed the unused COMMON/CWIND/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,CONSTFACTOR,STRUCTFACTOR,LJDOT0
C 10/13/26 MHP via Claude: removed the unused COMMON/DEBHU/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/DISK/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/DPMIX/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/NEWOPAC/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/SCVEOS/ declaration
C (no member referenced here; residue of the obsolete-option removals).

C INCLUDE COMMON BLOCKS WITH REQUIRED PHYSICS AND OUTPUT FLAGS
C 10/11/26 MHP via Claude
C code changed to remove LSCRIB from COMMON/CCOUT/: it was declared
C positionally in all 17 files sharing this block but never read or
C written in executable code anywhere, and no namelist file sets it.
      COMMON/CCOUT/LPHHD
C 10/11/26 MHP via Claude
C BUG FIX: this file reads LMILNE below (gating CALL WRTMIL) but never
C declared COMMON/CCOUT2/, so it was an uninitialized local, always
C .FALSE. -- the Milne output call here was dead code. No namelist
C file currently sets LMILNE, so this has no effect on any existing
C run; it only restores the intended behavior if someone enables it.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR,C_2
      COMMON/SCRTCH/SESUM(JSON),SEG(7,JSON),SBETA(JSON),SETA(JSON),
     *LOCONS(JSON),SO(JSON),SDEL(3,JSON),SFXION(3,JSON),SVEL(JSON),SCP(JSON)
      COMMON/SOUND/GAM1(JSON),LSOUND
      COMMON/TEMP2/VES(JSON),VES0(JSON),VSS(JSON),VSS0(JSON),
     *     HLE(JSON),VGSF(JSON),VGSF0(JSON),VMU(JSON)
      COMMON/ROTEN/DEROT(JSON)

      SAVE

C physics flags:
C Determine atmosphere flag, ATM
      IF (KTTAU .EQ. 0) THEN
         ATM='EDD '
      ELSEIF (KTTAU .EQ. 1) THEN
         ATM='KS  '
      ELSEIF (KTTAU .EQ. 2) THEN
         ATM='HRA '
      ELSEIF (KTTAU .EQ. 3) THEN
         ATM='KUR '
      ELSEIF (KTTAU .EQ. 4) THEN
         ATM='ALL '
      ENDIF
C Determine equation of state flag, EOS
      EOS='SAHA  '
      IF (LDH) EOS='SAH+DH'
      IF (LSCV) THEN
         EOS='SCV   '
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
         IF (LDH) THEN
         IF (LOPALE06) EOS='SCV+O6'
            EOS='SCV+DH'
            IF (LOPALE06) EOS='SCDHO6'
         ENDIF
      ELSE
         IF (LOPALE06) THEN
            EOS='OPAL06'
            IF (LDH) EOS='OP6+DH'
         ENDIF
      ENDIF
C Determine low temperature opacities flag, LOK
      ALOK='NONE'
C 9/23/26 MHP via Claude
C code changed to remove the Kurucz 1990 opacity tables
C 9/24/26 MHP via Claude
C code changed to remove the Alexander 1995 opacity tables
C Determine high temperature opacities flag, HIK
      HIK='NONE'
      IF (LOPAL95) HIK='OP95'
C 9/23/26 MHP via Claude
C code changed to remove the LAOL89 opacity tables

      IF(ATM .EQ. ' ? ') THEN
         WRITE(ISHORT,7)
  7      FORMAT('*** YREC7 input file, flags, etc., have been ',
     *          'defaulted.  ***')
      ENDIF

C 09/25 JvS: Add secondary format option that prints stitched interior and envelope 
C points. Output is either in the old format or new format, not both. 
      IF(LSTCH)THEN
          IF(LPHHD)THEN
            WRITE(ISTOR,1013) ! header key
          ! write model physics header. Should only happen upon first model output.
          ! write physics flags:
            WRITE(ISTOR,29) JCORE,JENV,CMIXL,EOS,ATM,ALOK,HIK,LPUREZ,
     &     COMPMIX,LEXCOM,LDIFY,LDIFZ,LSEMIC,LOVSTC,LOVSTE,LOVSTM,
     &     LROT,LINSTB,LJDOT0,LDISK,TDISK,PDISK,WMAX,LSTORE,LSTATM,LSTENV,
     &     LSTMOD,LSTPHYS,LSTROT
   29      FORMAT('#',2I8,F16.10,1X,A6,1X,3(A4,1X),L1,1X,A4,1X,11(L1,1X),
     &     3(1PE18.10),1X,6(L1,1X))
           WRITE(ISTOR,1014) ! profile header
           LPHHD = .FALSE. ! Turn off the physics header fo the rest of the run.
          ENDIF
        CALL STITCH(HCOMP,HR,HP,HD,HS,HT,HL,HS1,OMEGA,ETA2,
     * HI,R0,HJM,FP,FT,TEFFL,HSTOT,BL,M,LC,MODEL,CMIXL)
 1013     FORMAT('# JCORE  JENV  CMIXL  EOS  ATM  ALOK HIK  LPUREZ  COMPMIX',
     1 '  LEXCOM  LDIFY  LDIFZ  LSEMIC  LOVSTC  LOVSTE  LOVSTM',
     1 '  LROT  LINSTB  LJDOT0  LDISK  TDISK  PDISK  WMAX  LSTORE',
     1 '  LSTATM  LSTENV  LSTMOD  LSTPHYS  LSTROT')
 1014     FORMAT(
     1'MODEL SHELL MASS RADIUS LUMINOSITY PRESSURE TEMPERATURE DENSITY OMEGA ',
     1'CONVECTIVE INTERIOR_PT ENV_PT ATM_PT H1 He4 METALS He3 C12 C13 N14 N15 O16 ', 
     1'O17 O18 H2 Li6 Li7 Be9 OPACITY GRAV DELR DEL DELAD V_CONV GAM1 HII HEII HEIII ',
     1'BETA ETA PPI PPII PPIII CNO TRIPLE_ALPHA E_NUC E_NEU E_GRAV CP DLNRHODLNT A ', 
     1'RP/RE FP FT J/M MOMENT DEL_KE V_ES V_GSF V_SS VTOT ')

       ELSE
C write header records
      IF(DAGE .lt. 1d3) THEN
         WRITE(ISTOR,10) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 10      FORMAT(A5,2I8,5F16.11,1PE18.10,0P2F16.12)
      ELSE IF (DAGE .LT. 1D4) THEN
         WRITE(ISTOR,11) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 11      FORMAT(A5,2I8,4F16.12,F16.10,1PE18.10,0P2F16.12)
      ELSE IF (DAGE .LT. 1D5) THEN
         WRITE(ISTOR,12) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 12      FORMAT(A5,2I8,4F16.12,F16.9,1PE18.10,0P2F16.12)
      ELSE
         WRITE(ISTOR,13) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 13      FORMAT(A5,2I8,4F16.12,F16.8,1PE18.10,0P2F16.12)
      ENDIF

C write physics flags:
      WRITE(ISTOR,30) JCORE,JENV,CMIXL,EOS,ATM,ALOK,HIK,LPUREZ,
     &     COMPMIX,LEXCOM,LDIFY,LDIFZ,LSEMIC,LOVSTC,LOVSTE,LOVSTM,
     &     LROT,LINSTB,LJDOT0,LDISK,TDISK,PDISK,WMAX,LSTORE,LSTATM,LSTENV,
     &   LSTMOD,LSTPHYS,LSTROT
   30 FORMAT(2I8,F16.10,1X,A6,1X,3(A4,1X),L1,1X,A4,1X,11(L1,1X),
     &     3(1PE18.10),1X,6(L1,1X))

C write luminosities and output flags
C If TLUMX are in solar units, convert to ergs.  Decide by
C comparing to 10**20, if smaller, multiply by CLSUN

      CCCMAX = DMAX1(TLUMX(1),TLUMX(2),TLUMX(3),TLUMX(4),TLUMX(5),
     *     DABS(TLUMX(6)),TLUMX(7))
      IF(CCCMAX.LE.1.0D20) THEN
       DO J = 1,7
          TLUMX(J) = TLUMX(J) * CLSUN
         ENDDO
      ENDIF
      WRITE(ISTOR,40) (TLUMX(J),J=1,7)
   40 FORMAT('TLUMX',5X,1P7E17.9)

C write ENVELOPE DATA
      DO I = 1,3
         I0 = I
         IF(FTRI.LT.0D0) I0 = -I
         WRITE(ISTOR,50)I0,TRIT(I),TRIL(I),PS(I),TS(I),RS(I),
     &        (CFENV(3*I-3+J),J=1,3)
      ENDDO
   50 FORMAT('ENV',I2,5F16.12,1P3E20.12)

      CALL PINDEX(JXBEG,JXEND,LSHELL,M,ID,IDM)

      IF(LSTMOD)THEN
C write column headings for all per shell information
         WRITE(ISTOR,55)
 55      FORMAT(/,
     1' SHELL       MASS             RADIUS             LUMINOSITY            ',
     1'PRESSURE         TEMPERATURE         DENSITY               OMEGA      ',
     1'    C     H1          He4        METALS         He3             C12   ',
     1'          C13             N14             N15             O16         ',
     1'    O17             O18             H2              Li6             Li7',
     1'             Be9           OPAC       GRAV        DELR        DEL      ',
     1'   DELA       V_CONV     GAM1      HII     HEII     HEIII    BETA      ',
     1'ETA       PPI         PPII       PPIII        CNO         3HE         ',
     1'E_NUC        E_NEU       E_GRAV          A           RP/RE           FP',
     1'            FT           J/M          MOMENT        DEL_KE       V_ES ',
     1'      V_GSF      V_SS       VTOT   ',/)

C write out the requested information.
       CG=DEXP(CLN*CGL)
         DO II = 1,IDM
            I = ID(II)
C write out the basic info
C 9/28/26 MHP via Claude
C code changed to add MODEL to this WRITE, matching FORMAT 62 (which
C already expected it) and fixing a crash ("Expected INTEGER for item
C 2 ... got REAL") present on main itself: FORMAT 62 was widened there
C but this WRITE was never updated to match.
C 10/8/26 MHP via Claude
C code changed to remove the interior/envelope/atmosphere region-flag
C triple added above: after consultation with other developers, this
C doesn't fit the .store header (FORMAT 55 documents no such columns)
C and isn't desired here. This file only ever writes interior points,
C so the flags were always the same hard-coded, uninformative
C .TRUE.,.FALSE.,.FALSE. -- unlike stitch.f, which genuinely needs the
C triple since it writes interior, envelope, and atmosphere rows with
C the same format. MODEL is kept; FORMAT 62 below now supplies only
C LC(I)'s own logical, as it did before the region-flag triple was
C ever added.
            WRITE(ISTOR,62,ADVANCE='no') MODEL,I,HS(I),HR(I),HL(I),
     *         HP(I),HT(I),HD(I),OMEGA(I),LC(I),
     *         (HCOMP(J,I),J=1,15)
C write out additional physics if desired
            IF(LSTPHYS)THEN
             SG = DEXP(CLN*(CGL - 2.0D0*HR(I)))*HS1(I)
               WRITE(ISTOR,63,ADVANCE='no') SO(I),SG,SDEL(1,I),SDEL(2,I),
     *           SDEL(3,I),SVEL(I),GAM1(I),0.0,0.0,0.0,SBETA(I),SETA(I),
     *           (SEG(K,I),K=1,5),SESUM(I),SEG(6,I),SEG(7,I)
c               WRITE(ISTOR,63,ADVANCE='no') SO(I),SG,SDEL(1,I),SDEL(2,I),
c     *           SDEL(3,I),SVEL(I),GAM1(I),SFXION(1,I),SFXION(2,I),SFXION(3,I),
c     *           SBETA(I),SETA(I),(SEG(K,I),K=1,5),SESUM(I),SEG(6,I),SEG(7,I)
            ELSE
               WRITE(ISTOR,63,ADVANCE='no') 0.0,0.0,0.0,0.0,0.0,0.0,0.0,
     *           0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
            ENDIF
C write out additional rotation info if desired
            IF(LSTROT.AND.LROT)THEN
             FM = DEXP(CLN*HS(I))
             DUMA = CC13*OMEGA(I)**2/(CG*FM)*5.D0/(2.D0+ETA2(I))
             A = DUMA * R0(I)**3
             RPOLEQ = (1.0D0 - A)/(1.0D0 + 0.5D0*A)
               VTOT = VES(I)+VGSF(I)+VSS(I)
               WRITE(ISTOR,64) A,RPOLEQ,FP(I),FT(I),HJM(I),HI(I),DEROT(I),
     *            VES(I),VGSF(I),VSS(I),VTOT
            ELSE
               WRITE(ISTOR,64) 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
            ENDIF
         ENDDO
 62   FORMAT(I6,1X,I6,0P2F18.14,1PE24.16,0PF18.14,1X,F18.14,1X,F18.14,1PE24.16,
     &     1X,L1,3(0PF12.9),12(0PE16.8),2X)

 63   FORMAT(1PE10.4,1PE11.3,E12.4,E12.4,E12.4,1PE12.4,0PF9.5,1X,F9.5,1X,F9.5,
     &     1X,F9.5,1X,F9.5,1X,F9.5,E12.4,E12.4,E12.4,E12.4,E12.4,E13.5,E13.5,E13.5)

 64   FORMAT(E14.6,E14.6,E14.6,E14.6,E14.6,E14.6,E14.6,E11.3,E11.3,E11.3,E11.3,
     &     E11.3)

      ENDIF
C now call wrtmod, with the goal of outputting the envelope and atmosphere, or
C if required by LPULSE.
      IF(LSTATM.OR.LSTENV)THEN
       IF(LMILNE) CALL WRTMIL(HCOMP,HD,HL,HP,HR,HS1,M,MODEL)
C        CALL WRTMOD(M,LSHELL,JXBEG,JXEND,JCORE,JENV,HCOMP,HS1,HD,HL,
C      *   HP,HR,HT,LC,MODEL,BL,TEFFL,OMEGA,FP,FT,ETA2,R0,HJM,HI,HS,
C      *   DAGE)  ! KC 2025-05-31
         CALL WRTMOD(M,JENV,HCOMP,HS1,HD,HL,
     *               HP,HR,HT,MODEL,BL,TEFFL,FP,FT,HS,DAGE,CMIXL,XMSOL)
      ENDIF

      WRITE(ISTOR,65)
 65   FORMAT(/,/)

       ENDIF !closes logic block for new vs old store file format

C G Somers END
CCCCCCCCCCCCCCCCCCCCCCCCC

      RETURN
      END

























