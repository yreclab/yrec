C $$$$$$
      SUBROUTINE SETCAL(FACAGE)

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C      CHARACTER*256 FLAOL2, FOPAL2
C MHP 6/13 ADD OPTION TO CALIBRATE SOLAR Z/X, SOLAR Z/X, SOLAR AGE
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
      COMMON /CKIND/RESCAL(4,50),NMODLS(50),IRESCA(50),LFIRST(50),
     1        NUMRUN
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50)
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
      COMMON/CALSUN/DLDX,DRDX,DLDA,DRDA,BLP,RLP,DX,DA,LSOL
C MHP 8/25 Removed character file names from common block
C 9/24/26 MHP via Claude
C code changed to remove dead IOOPAL2 from COMMON/ZRAMP/
C 10/9/26 MHP via Claude
C code changed to remove NK from COMMON/ZRAMP/: it was only ever a
C redundant copy of the run-index loop variable main.f already passes
C explicitly to the subroutines that need it (STARIN/RSCALE), and was
C never read by name in this file.
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *             IOLAOL2,
     *             LZRAMP
      SAVE

C SET UP RUN TO CALIBRATE A SOLAR MODEL.
C THIS CONSISTS OF SETTING THE NUMBER OF RUNS TO THE MAXIMUM (50),
C AND COPYING THE RELEVANT PARAMETERS FROM THE FIRST TWO RUNS TO
C THE NEXT SERIES OF 24 CALIBRATING RUNS.
c mhp 5/96 changed to do solar models in 3 runs rather than 2.
      NUMRUN = 48
      DO I = 2,48
         XENV0A(I) = XENV0A(1)
         ZENV0A(I) = ZENV0A(1)
         CMIXLA(I) = CMIXLA(1)
         LSENV0A(I) = LSENV0A(1)
         SENV0A(I) = SENV0A(1)
      END DO
      DO I = 4,46,3
         IRESCA(I) = IRESCA(1)
         LFIRST(I) = .TRUE.
         NMODLS(I) = NMODLS(1)
         RSCLZC(I) = RSCLZC(1)
         RSCLZM1(I) = RSCLZM1(1)
         RSCLZM2(I) = RSCLZM2(1)
         DO J = 1,4
            RESCAL(J,I) = RESCAL(J,1)
         END DO
      END DO
C MHP 06/13 HARDWIRE RUN 2 TO 1D8 YEARS AND RUN3 TO CALSOLAGE YEARS
      ENDAGE(2) = 1.0D8*FACAGE
C      ENDAGE(2) = ENDAGE(2)*FACAGE
      SETDT(2) = SETDT(2)*FACAGE
      ENDAGE(3) = CALSOLAGE*FACAGE
C      ENDAGE(3) = ENDAGE(3)*FACAGE
      SETDT(3) = SETDT(3)*FACAGE
      DO I = 5,47,3
         IRESCA(I) = 1
         LFIRST(I) = .FALSE.
         NMODLS(I) = NMODLS(2)
         ENDAGE(I) = ENDAGE(2)
         LENDAG(I) = LENDAG(2)
         SETDT(I) = SETDT(2)
         LSETDT(I) = LSETDT(2)
      END DO
      DO I = 6,48,3
         IRESCA(I) = 1
         LFIRST(I) = .FALSE.
         NMODLS(I) = NMODLS(3)
         ENDAGE(I) = ENDAGE(3)
         LENDAG(I) = LENDAG(3)
         SETDT(I) = SETDT(3)
         LSETDT(I) = LSETDT(3)
      END DO
      LSOL = .FALSE.
      RETURN
      END
