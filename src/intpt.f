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
