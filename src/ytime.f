C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C YTIME
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE YTIME(EG,HCOMP,HD,HL,HS1,HT,JCORE,M,DELTSY,
     *   HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,
C      *   HF1,HF2,QDP,QDT,JXBEG)  ! KC 2025-05-31
     *   HF1,HF2,JXBEG)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 BE7MFLOC,DELTSY,DL,E,EALPCA,ECA,EG,EGG11,EGG22,EGG33,EGG44,
     *       EGG55,ENU,HCOMP,HD,HF1,HF2,HL,HR1,HR10,HR11,HR12,HR13,HR2,
     *       HR3,HR4,HR5,HR6,HR7,HR8,HR9,HS1,HT,HTMAX,QED,QET,SUM1,TL,X,
     *       XBE9,XC12,XC13,XH2,XHE3,XLI6,XLI7,XN14,XN15,XO16,XO17,XO18,
     *       Y,YCORE,Z
      INTEGER IT,ITMAX,IU,JCORE,JXBEG,M
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
C 10/13/26 MHP via Claude
C code changed to drop COMMON/CTLIM/, declared here but never used.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C MHP 10/02 added missing common block
C 10/13/26 MHP via Claude
C code changed to replace COMMON/NEWEPS/ with explicit arguments: engeb.f
C computes EALPCA and ENU, and coefft.f and ytime.f read them right after
C their own CALL ENGEB, so they are returned as arguments.  main.f, the
C third caller, passes locals it does not use.
      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HS1(JSON),
     * HT(JSON),EG(6)
      DIMENSION HR1(JSON),HR2(JSON),HR3(JSON),HR4(JSON),HR5(JSON),
     *HR6(JSON),HR7(JSON),HR8(JSON),HR9(JSON),HR10(JSON),HR11(JSON),
     *HR12(JSON),HR13(JSON),HF1(JSON),HF2(JSON)
      SAVE
C  STARS WITH A HELIUM LUMINOSITY HAVE A TIMESTEP LIMIT
C       BASED ON THE TIME REQUIRED TO BURN ATIME(4) OF Y AT THE
C       MAXIMUM IN TEMPERATURE OR THE FRACTION ATIME(5) OF Y AT THIS POINT.
C TEST FOR HELIUM FLASH BURNING; HIGH CENTRAL DENSITY IS TAKEN AS
C A SIGN THAT THE MODEL IS A GIANT UNDERGOING A HE FLASH RATHER THAN
C A HORIZONTAL BRANCH STAR.
C       DATA Q3A,QCA/5.85D17,1.7276D18/
      IF (HD(1).GE.5.0D0) THEN
C     SEARCH FOR TEMPERATURE MAXIMUM
       HTMAX = 0.0D0
       ITMAX = 1
       DO 210 IT = 1,M
          IF (HT(IT).GT.HTMAX) THEN
             ITMAX = IT
             HTMAX = HT(IT)
          ENDIF
  210    CONTINUE
C     CALCULATE HELIUM BURNING RATE AT TMAX
       DL = HD(ITMAX)
       TL = HT(ITMAX)
       X = HCOMP(1,ITMAX)
       Y = HCOMP(2,ITMAX)
       Z = HCOMP(3,ITMAX)
       XHE3 = HCOMP(4,ITMAX)
       XC12 = HCOMP(5,ITMAX)
       XC13 = HCOMP(6,ITMAX)
       XN14 = HCOMP(7,ITMAX)
       XN15 = HCOMP(8,ITMAX)
       XO16 = HCOMP(9,ITMAX)
       XO17 = HCOMP(10,ITMAX)
       XO18 = HCOMP(11,ITMAX)
       IF(LEXCOM) THEN
          XH2 = HCOMP(12,ITMAX)
          XLI6 = HCOMP(13,ITMAX)
          XLI7 = HCOMP(14,ITMAX)
          XBE9 = HCOMP(15,ITMAX)
       ENDIF
       IU = ITMAX
C 10/13/26 MHP via Claude
C code changed to pass BE7MFLOC for ENGEB's new BE7MASSFRACTION
C argument, which replaces COMMON/BE7/.  This routine does not use the
C value; only main.f reads it.
         CALL ENGEB(EGG11,EGG22,EGG33,EGG44,EGG55,QED,QET,SUM1,DL,
C      *        TL,QDT,QDP,X,Y,Z,XHE3,XC12,XC13,XN14,XN15,XO16,XO17,
C      *        XO18,XH2,XLI6,XLI7,XBE9,IU,HR1,HR2,HR3,HR4,HR5,HR6,HR7,  ! KC 2025-05-31
     *        TL,X,Y,XHE3,XC12,XC13,XN14,XO16,
     *        XO18,XH2,IU,HR1,HR2,HR3,HR4,HR5,HR6,HR7,
     *        HR8,HR9,HR10,HR11,HR12,HR13,HF1,HF2,BE7MFLOC,EALPCA,ENU)
         E = SUM1
         EG(1) = EGG11
         EG(2) = EGG22
         EG(3) = EGG33
         EG(4) = EGG44
         EG(5) = EGG55
         EG(6) = ENU
         ECA = EALPCA
       IF(EG(5).LT.1.D-22) EG(5) = 1.D-22
       DELTSY=1.0D15/EG(5)
      ELSE
C SET LIMITS ON HE BURNING FOR NON-HELIUM FLASH STARS
       YCORE = 1D0 - HCOMP(3,JCORE)
       IF(YCORE.GE.ATIME(1)) THEN

            DELTSY = MIN(ATIME(4),ATIME(5)*YCORE)
C
          DELTSY = (5.85D17/CLSUN)*DELTSY*(HS1(JCORE)/HL(JCORE))

            ELSE

            DELTSY = (5.85D17/CLSUN)*DELTSY*(HS1(JXBEG-1)/HL(JXBEG-1))

C
         ENDIF
C
      ENDIF

      RETURN
      END
