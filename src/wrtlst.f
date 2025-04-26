C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 06
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHP 10/02 NKK removed from declared variable list
      SUBROUTINE WRTLST(IWRITE,HCOMP,HD,HL,HP,HR,HS,HT,LC,TRIT,TRIL,PS,
     *TS,RS,CFENV,FTRI,TLUMX,JCORE,JENV,MODEL,M,SMASS,TEFFL,BL,HSTOT,
     *DAGE,DDAGE,OMEGA)

C  WRTLST WRITES THE CONVERGED MODEL TO LAST MODEL A(STORES LAST
C  CONVERGED MODEL) AND STORE MODELS D(EVERY NPUNCH MODELS)

C     WRITE MODEL OUT IN ASCII FORMAT
      use params, only : json, nts, nps
      use settings, only : ILAST, ISHORT, IOWR  ! /LUOUT/
      use settings, only : CMIXL  ! /CONST3/
      use settings, only : LOVSTC, LOVSTE, LOVSTM, LSEMIC  ! /DPMIX/
      use settings, only : LEXCOM  ! /FLAG/
      use settings, only : LROT, LINSTB  ! /ROT/
      use settings, only : LDH  ! /DEBHU/
      use settings, only : LDIFZ  ! /GRAVS3/
      use settings, only : LDIFY  ! /GRAVST/
      use settings, only : KTTAU  ! /ATMOS/
      use tables, only : LPUREZ  ! /NWLAOL/
      use settings, only : LOPALE, LOPALE01, LOPALE06  ! /OPALEOS/
      use settings, only : LLAOL89, LOPAL92, LOPAL95, LKUR90, LALEX95  ! /NEWOPAC/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      CHARACTER*6 EOS
      CHARACTER*4 ATM, LOK, HIK, COMPMIX

      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     * HS(JSON),HT(JSON),LC(JSON),TRIT(3),TRIL(3),PS(3),TS(3),RS(3),
     * CFENV(9),TLUMX(8),OMEGA(JSON)
C llp  3/19/03 Add COMMON block /I2O/ for info directly transferred from
C      input to output model - starting with a code for th initial model
C      compostion (COMPMIX)
      COMMON /I2O/ COMPMIX

c      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,CONSTFACTOR,STRUCTFACTOR,LJDOT0
C MHP 8/17 ADDED EXCEN, C_2 TO COMMON BLOCK FOR MATT ET AL. 2012 CENT. TERM
      COMMON/CWIND/WMAX,EXMD,EXW,EXTAU,EXR,EXM,EXL,EXPR,CONSTFACTOR,
     *             STRUCTFACTOR,EXCEN,C_2,LJDOT0
      COMMON/DISK/SAGE,TDISK,PDISK,LDISK
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDTT,IDP


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
         IF (LOPALE) EOS='SCV+OP'
         IF (LOPALE01) EOS='SCV+O1'
         IF (LDH) THEN
         IF (LOPALE06) EOS='SCV+O6'
            EOS='SCV+DH'
            IF (LOPALE) EOS='SCVDHO'
            IF (LOPALE01) EOS='SCDHO1'
            IF (LOPALE06) EOS='SCDHO6'
         ENDIF
      ELSE
         IF (LOPALE) THEN
            EOS='OPAL  '
            IF (LDH) EOS='OPA+DH'
         ENDIF
         IF (LOPALE01) THEN
            EOS='OPAL01'
            IF (LDH) EOS='OP1+DH'
         ENDIF
         IF (LOPALE06) THEN
            EOS='OPAL06'
            IF (LDH) EOS='OP6+DH'
         ENDIF
      ENDIF
C Determine low temperature opacities flag, LOK
      LOK='NONE'
      IF (LALEX95) LOK='ALEX'
      IF (LKUR90) LOK='KURZ'
C Determine high temperature opacities flag, HIK
      HIK='NONE'
      IF (LOPAL95) HIK='OP95'
      IF (LOPAL92) HIK='OP92'
      IF (LLAOL89) HIK='LL89'

      CALL PUTMODEL2(BL,CFENV,CMIXL,DAGE,DDAGE,FTRI,HCOMP,HD,HL,
     * HP,HR,HS,HSTOT,HT,IWRITE,ISHORT,JCORE,JENV,LC,LEXCOM,LROT,M,
     * MODEL,OMEGA,PS,RS,SMASS,TEFFL,TLUMX,TRIL,TRIT,TS,
     & ATM,EOS,HIK,LDIFY,LDIFZ,LDISK,LINSTB,LJDOT0,LOK,
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
