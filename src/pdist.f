C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PDIST
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

C calculates the distance the star has travelled in the HR diagram
C if far enough, output pulsation model
C MHP 8/25 passed file names directly and removed common block with file names
C 10/9/26 MHP via Claude
C code changed to pass NK as an explicit argument instead of via
C COMMON/ZRAMP/, which this file otherwise never used (NK was its only
C member ever referenced here). See the CALL PDIST site in main.f,
C which already has NK as its own local run-index variable.
      SUBROUTINE PDIST(POL1,POT1,POA1,POLEN,BL,TEFFL,MODELN,NK,FPATM,
     * FPENV,FPMOD)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      CHARACTER*256 COUT,CTEMP
C Removed variables not used in the routine
      CHARACTER*256 FPMOD, FPENV, FPATM
C MHP 10/02 added proper dimensions to last 2 variables
      COMMON/THEAGE/DAGE
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
      COMMON/PULSE/XMSOL,LPULSE,IPVER
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead ILLDAT, IKUR from COMMON/LUNUM/
C 9/24/26 MHP via Claude
C code changed to remove dead IDYN from COMMON/LUNUM/
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
C 9/25/26 MHP via Claude
C code changed to remove dead COMMON/LUNUM/ISCOMP (declared,
C assigned a unit number, but never opened or read anywhere)
C MHP 8/25 Removed common block with file names
C      COMMON/LUFNM/ FLAST, FFIRST, FRUN, FSTAND, FFERMI,
C     1    FDEBUG, FTRACK, FSHORT, FMILNE, FMODPT,
C     2    FSTOR, FPMOD, FPENV, FPATM, FDYN,
C     3    FLLDAT, FSNU, FSCOMP, FKUR,
C     4    FMHD1, FMHD2, FMHD3, FMHD4, FMHD5, FMHD6, FMHD7, FMHD8
      SAVE

      TM1 = BL-POL1
      TM2 = TEFFL-POT1
      TM3 = DAGE-POA1
      TMP1 = POA*TM1*POA*TM1
      TMP2 = POB*TM2*POB*TM2
      TMP3 = POC*TM3*POC*TM3
      POLEN = POLEN+TMP1+TMP2+TMP3
      POL1 = BL
      POT1 = TEFFL
      POA1 = DAGE
      IF (POLEN .GE. POMAX) THEN
          LPULSE = .TRUE.
          POLEN = 0.0D0
          IOCCOL = INDEX(FPMOD,' ')-1
          IF (MODELN.LT.10000)THEN
             WRITE(CTEMP,'(I2.2,''_'',I4.4)')NK, MODELN
             COUT = FPMOD(1:IOCCOL) // CTEMP(1:7)
          ELSE
             WRITE(CTEMP,'(I2.2,''_'',I5.5)')NK, MODELN
             COUT = FPMOD(1:IOCCOL) // CTEMP(1:8)
          ENDIF
          OPEN(IOPMOD,FILE=COUT,STATUS='NEW',FORM='FORMATTED')
          IOCCOL = INDEX(FPENV,' ')-1
          IF (MODELN.LT.10000)THEN
             WRITE(CTEMP,'(I2.2,''_'',I4.4)')NK, MODELN
             COUT = FPENV(1:IOCCOL) // CTEMP(1:7)
          ELSE
             WRITE(CTEMP,'(I2.2,''_'',I5.5)')NK, MODELN
             COUT = FPENV(1:IOCCOL) // CTEMP(1:8)
          ENDIF
          OPEN(IOPENV,FILE=COUT,STATUS='NEW',FORM='FORMATTED')
          IOCCOL = INDEX(FPATM,' ')-1
          IF (MODELN.LT.10000)THEN
             WRITE(CTEMP,'(I2.2,''_'',I4.4)')NK, MODELN
             COUT = FPATM(1:IOCCOL) // CTEMP(1:7)
          ELSE
             WRITE(CTEMP,'(I2.2,''_'',I5.5)')NK, MODELN
             COUT = FPATM(1:IOCCOL) // CTEMP(1:8)
          ENDIF
          OPEN(IOPATM,FILE=COUT,STATUS='NEW',FORM='FORMATTED')
       ELSE
          CLOSE(IOPMOD)
          CLOSE(IOPENV)
          CLOSE(IOPATM)
          LPULSE = .FALSE.
       END IF
       WRITE(IOWR,276)POLEN,TM1,TM2,TM3
       WRITE(ISHORT,276)POLEN,TMP1,TMP2,TMP3
 276   FORMAT(5X,' LEN SQ=',1PE10.3, '  D L=',1PE10.3,
     *        '  D Te=',1PE10.3,'  D AGE=',1PE10.3)

       RETURN
       END
