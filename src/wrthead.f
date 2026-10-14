C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C WRTHEAD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C write the headers for all the appropriate output files

C 10/9/26 MHP via Claude
C code changed to pass NK as an explicit argument instead of via
C COMMON/ZRAMP/, which this file otherwise never used (NK was its only
C member ever referenced here). See the CALL WRTHEAD site in main.f,
C which already has NK as its own local run-index variable.
      SUBROUTINE WRTHEAD (SMASS,CMIXL,NK)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/RUNLOOP/ into RUNLOOP_MOD.  A blanket
C USE imports exactly the names the COMMON declaration made global here,
C so it cannot change meaning.  See runloop_mod.f for the block history
C and for why the module declares the types the implicit rules supplied.
      USE RUNLOOP_MOD

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C MHP 8/25 Removed character file names from common block
C MHP 10/02 added proper dimensions for flaol2, fopal2
C      CHARACTER*256 FISO,FLAOL2, FOPAL2
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
      COMMON/LABEL/XENV0,ZENV0
C 10/13/26 MHP via Claude: removed the unused COMMON/CONSTANTS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/24/26 MHP via Claude
C code changed to pass CMIXL as an explicit argument instead of via
C common block, to reduce implicit global state ahead of the F90
C module conversion
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
C 9/24/26 MHP via Claude
C code changed to remove dead ILLDAT, IKUR from COMMON/LUNUM/
C 9/24/26 MHP via Claude
C code changed to remove dead IDYN from COMMON/LUNUM/
C 9/25/26 MHP via Claude
C code changed to remove dead COMMON/LUNUM/ISCOMP (declared,
C assigned a unit number, but never opened or read anywhere)
C MHP 8/25 Removed character file names from common block
C 9/25/26 MHP via Claude
C code changed to remove the LISO isochrone-output option
      SAVE

      IF (IRESCA(NK) .EQ. 1) THEN
         WRITE(IOWR, 47) NK, XENV0, ZENV0, CMIXL, NMODLS(NK)
      ELSE IF (IRESCA(NK) .EQ. 2) THEN
         WRITE(IOWR, 48) NK, XENV0, ZENV0, CMIXL, NMODLS(NK)
      ELSE IF (IRESCA(NK) .EQ. 3) THEN
         WRITE(IOWR, 49) NK, XENV0, ZENV0, CMIXL, NMODLS(NK)
      END IF
  47  FORMAT(/, ' RUN=',I2,' EVOLVE  ', ' X=',F8.6,
     *       ' Z=',F8.6,' CMIXL=', F8.6, ' NO.MODS=', I5)
  48  FORMAT(/, ' RUN=',I2,' RESCALE ', ' X=',F8.6,
     *       ' Z=',F8.6,' CMIXL=', F8.6, ' NO.MODS=', I5)
  49  FORMAT(/, ' RUN=',I2,' RESCALE&EVOLVE ', ' X=',F8.6,
     *       ' Z=',F8.6,' CMIXL=', F8.6, ' NO.MODS=', I5)

      IF (LTRACK .AND. LFIRST(NK)) THEN
C ITRVER identifies version of track out file.  If you change
C the track out file then change this version number.
         WRITE(ITRACK, 1500)ITRVER,SMASS,XENV0,ZENV0,CMIXL
 1500    FORMAT('#Version=',i3,'  Mtot/Msun =',1PE16.8,
     *        '  Initial: X =',1PE16.8,' Z =',1PE16.8,
     *        '  Mix. length =', 1PE16.8)
         IF(ITRVER .EQ. 0) THEN
c            WRITE(ITRACK, 1503)
c 1503       FORMAT(
c     1'# Model #, shells, AGE(Gyr), log(L/Lsun), log(R/Rsun), log(g),',
c     1' log(Teff), Mconv. core (Msun), Mconv. env, R,T,Rho,P,cappa env',/,
c     2'# Central: log(T), log(RHO), log(P), BETA, ETA, X, Y, Z',/,
c     3'# Luminosity: ppI, ppII, ppIII, CNO, triple-alpha,',
c     3' He-C, gravity, neutrinos (old)',/,
c     3'# Cl SNU, Ga SNU, Neutrinos (1E10 erg/CM^2 at earth): pp, pep, hep, Be7,',
c     3' B8, N13, O15, F17 2xdiagnostic',/,
c     4'# Central Abundances: He3, C12, C13, N14, N15, O16,',
c     4' O17, O18',/,
c     5'# Surface Abundances: He3, C12, C13, N14, N15, O16,',
c     5' O17,O18 H2, Li6, Li7, Be9 X Y Z Z/X',/,
c     6'# Jtot, KE rot tot, total I, CZ I, Omega center, surface, Prot (day), Vrot (km/s), TauCZ (sec) ',/,
c     7'# H shell loc: mass frac-base, midpoint, top; radius frac-',
c     7'base, midpoint, top, Pphot, mass (msun)')
C G Somers 11/14; Added option to create .track file header. Uncomment the following
C block if desired.
            WRITE(ITRACK, 1504)
C 1504       FORMAT(
C     1'# ',/,
C     2'#    Step    Shls     Age (Gyr)      log(L/Lsun)    log(R/Rsun)        log(g)        log(Teff)',
C     2'       Mconv.core      Mconv.env     Rcore     Tcore      Rho_core     P_core     kappa_env   ',
C     2' log(T)_cen     log(Rho)_cen     log(P)_cen        BETA             ETA            X_cen      ',
C     2'     Y_cen           Z_cen          ppI_lum         ppII_lum       ppIII_lum        CNO_lum   ',
C     2'    3-alpha_lum       He-C_lum        gravity       OLD NUTRINOS   Cl SNU    Ga SNU    **pp** ',
C     2'   **pep**   **hep**   **Be7**   **B8**    **N13**   **O15**   **F17**  **diag1** **diag2**   ',
C     2'   He3_cen        C12_cen         C13_cen         N14_cen         B10_cen         O16_cen     ',
C     2'    B11_cen         O18_cen         He3_surf        C12_surf        C13_surf        N14_surf  ',
C     2'      B10_surf        O16_surf        B11_surf        O18_surf        H2_surf         Li6_surf',
C     2'        Li7_surf        Be9_surf         X_surf          Y_surf          Z_surf         Z/X_su',
C     2'rf          Jtot         KE_rot_tot       total I           CZ I         Omega_surf      Omega',
C     2'_cen       Prot (days)     Vrot (km/s)     TauCZ (s)       Mfrac_base      Mfrac_midp      Mfr',
C     2'ac_top       Rfrac_base      Rfrac_midp      Rfrac_top         P_phot           Mass     ',/,
C     2'# ')
 1504       FORMAT(
     1'# ',/,
     2'     Step    Shls         Age_gyr       LogL_lsun       LogR_rsun           Log_g',
     2'        log_Teff        Mco_core         Mco_env     Rco_env     Tco_env     Dco_env',
     2'     Pco_env     Oco_env        LogT_cen        LogD_cen        logP_cen        Beta_cen',
     2'         Eta_cen           X_cen           Y_cen           Z_cen        ppI_lsun',
     2'       ppII_lsun      ppIII_lsun        CNO_lsun         3a_lsun        HeC_lsun',
     2'      Egrav_lsun       Neut_lsun    Cl_snu    Ga_snu   pp_neut  pep_neut  hep_neut',
     2'  Be7_neut   B8_neut  N13_neut  O15_neut  F17_neut     diag1     diag2         He3_cen',
     2'         C12_cen         C13_cen         N14_cen         N15_cen         O16_cen',
     2'         O17_cen         O18_cen         He3_sur         C12_sur         C13_sur',
     2'         N14_sur         N15_sur         O16_sur         O17_sur         O18_sur',
     2'          H2_sur         Li6_sur         Li7_sur         Be9_sur           X_sur',
     2'           Y_sur           Z_sur         Z_X_sur            Jtot      KE_rot_tot',
     2'           I_tot            I_cz       Omega_sur       Omega_cen      Prot_sur_d',
     2'        Vrot_kms         TauCZ_s    MHshell_base     MHshell_mid     MHshell_top',
     2'    RHshell_base     RHShell_mid     RHshell_top       logP_phot       Mass_msun',/,
     2'# ')
C G Somers END.
         ELSE IF(ITRVER .EQ. 1) THEN
            WRITE(ITRACK, 1505)
 1505       FORMAT(
     1'# Model #, shells, AGE, log(L/Lsun), log(R/Rsun), log(g),',
     1' log(Teff), Mconv. core, Mconv. env.)' ,/,
     2'# Central: log(T), log(RHO), log(P), BETA, ETA, X, Y, Z',/,
     3'# Luminosity: ppI, ppII, ppIII, CNO, triple-alpha,',
     3' He-C, gravity, neutrinos (old)',/,
     3' Neutrinos (1E10 erg/CM^2 at earth): pp, pep, hep, Be7,',
     3' B8, N13, O15, F17',/,
     4'# Central Abundances: He3, C12, C13, N14, N15, O16,',
     4' O17, O18',/,
     5'# Surface Abundances: He3, C12, C13, N14, N15, O16,',
     5' O17,O18',/,
     6'    "        " cont: H2, Li6, Li7, Be9',/,
     7'# H shell loc: mass frac-base, midpoint, top; radius frac-',
     7'base, midpoint, top')
         ELSE IF(ITRVER .EQ. 2) THEN
            WRITE(ITRACK, 1505)
            WRITE(ITRACK, 1510)
 1510       FORMAT(
     1' Jtot, K.E. Rotation, OMEGAsurf, OMEGAcenter')
         ELSE IF(ITRVER .EQ. 3) THEN
          WRITE(ITRACK, 1515)
 1515       FORMAT(
     1'#Model #, shells, AGE, log(L/Lsun), log(R/Rsun), log(g),',
     1' log(Teff), Mconv. core, Mconv. env., % Grav Energy, X env')
         END IF
      END IF

      RETURN
      END
