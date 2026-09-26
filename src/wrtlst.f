C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 06
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHP 10/02 NKK removed from declared variable list
      SUBROUTINE WRTLST(IWRITE,HCOMP,HD,HL,HP,HR,HS,HT,LC,TRIT,TRIL,PS,
     *TS,RS,CFENV,FTRI,TLUMX,JCORE,JENV,MODEL,M,SMASS,TEFFL,BL,HSTOT,
     *DAGE,DDAGE,OMEGA,CMIXL)

C  WRTLST WRITES THE CONVERGED MODEL TO LAST MODEL A(STORES LAST
C  CONVERGED MODEL) AND STORE MODELS D(EVERY NPUNCH MODELS)

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
      COMMON/IOUNITS/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,
     *  IOWR,IFIRST,IRUN,ISTAND,IFERMI,IOPMOD,IOPENV,IOPATM,ISNU,
     *  IALEX06,ICLCD,IJLAST,IOPUREZ,IcondOpacP,ILIV95,IOATM,IOATMA,
     *  IOPALE,ISCVH,ISCVHE,ISCVZ
      COMMON/FLAG/LEXCOM
      COMMON/HEFLSH/LKUTHE
      COMMON/ROT/WNEW,WALPCZ,ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW
      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     * HS(JSON),HT(JSON),LC(JSON),TRIT(3),TRIL(3),PS(3),TS(3),RS(3),
     * CFENV(9),TLUMX(8),OMEGA(JSON)
C llp  3/19/03 Add COMMON block /I2O/ for info directly transferred from
C      input to output model - starting with a code for th initial model
C      compostion (COMPMIX)
      COMMON /I2O/ COMPMIX

C llp 3/19/03 Add required COMMON blocks such that header flags
C     ATM, EOS, HIK and LOK can be determined.
      COMMON/ATMOS/HRAS,KTTAU,KTTAU0,LTTAU
c      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,CONSTFACTOR,STRUCTFACTOR,LJDOT0
C MHP 8/17 ADDED EXCEN, C_2 TO COMMON BLOCK FOR MATT ET AL. 2012 CENT. TERM
      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,EXL,EXPR,CONSTFACTOR,
     *             STRUCTFACTOR,EXCEN,C_2,LJDOT0
      COMMON/DEBHU/CDH,ETADH0,ETADH1,ZDH(18),XXDH,
     1             YYDH,ZZDH,DHNUE(18),LDH
      COMMON/DISK/SAGE,TDISK,PDISK,LDISK
      COMMON/DPMIX/DPENV,ALPHAC,ALPHAE,ALPHAM,BETAC,IOV1,IOV2,
     *      IOVIM, LOVSTC, LOVSTE, LOVSTM, LSEMIC, LADOV, LOVMAX
      COMMON/GRAVST/GRTOL,ILAMBDA,NITER_GS,LDIFY
      COMMON/GRAVS3/FGRY,FGRZ,LTHOUL,LDIFZ
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
      COMMON/NEWOPAC/ZOPAL951,TMOLMIN,TMOLMAX,TOLLAOL,LALEX06,LOPAL95,
     *  L2Z,LLAOL,LPUREZ,LcondOpacP
C MHP 8/25 Remove file names from common blocks
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
      COMMON/OPALEOS/lopale06,lNumDeriv
C 9/24/26 MHP via Claude
C code changed to pass CMIXL as an explicit argument instead of via
C common block, to reduce implicit global state ahead of the F90
C module conversion
C 9/25/26 MHP via Claude
C code changed to fix IDTT -> IDT, matching most other files that
C declare COMMON/SCVEOS/ (pre-existing name-only inconsistency; this
C slot was never read or written by name in this file)
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDT,IDP


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
C JNT 06/14
      ELSEIF (KTTAU .EQ. 5) THEN
         ATM='K/C '
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
C Determine low temperature opacities flag, ALOK
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

      CALL PUTMODEL2(BL,CFENV,CMIXL,DAGE,DDAGE,FTRI,HCOMP,HD,HL,
     * HP,HR,HS,HSTOT,HT,IWRITE,ISHORT,JCORE,JENV,LC,LEXCOM,LROT,M,
     * MODEL,OMEGA,PS,RS,SMASS,TEFFL,TLUMX,TRIL,TRIT,TS,
     & ATM,EOS,HIK,LDIFY,LDIFZ,LDISK,LINSTB,LJDOT0,ALOK,
     & LOVSTC,LOVSTE,LOVSTM,LPUREZ,LSEMIC,COMPMIX,PDISK,TDISK,WMAX)
C First three lines above are YREC7 inputs
C Last two lines are MODEL2 add-ons



      WRITE(IOWR,360) MODEL,M,TEFFL,BL,DAGE
  360 FORMAT(I6,'  #SHELLS=', I4, '  LogTeff=',F8.5,
     *       '  Log(L/Lsun)=',F8.5,'  Age=',F12.5)
      IF(IWRITE.EQ.11) THEN
       WRITE(ISHORT,330) MODEL,IWRITE
      ELSE
       WRITE(ISHORT,340) MODEL,DAGE,IWRITE
      ENDIF
  330 FORMAT(' DUMPED MODEL',I5,'  FILE',I3)
  340 FORMAT(' DUMPED MODEL',I5,' AGE',F13.9,'  FILE',I3)
      IF(IWRITE.EQ.ILAST) REWIND ILAST
      RETURN
      END
