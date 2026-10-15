C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C WRTMOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C       SUBROUTINE WRTMOD(M,LSHELL,JXBEG,JXEND,JCORE,JENV,HCOMP,HS1,HD,
C      *HL,HP,HR,HT,LC,MODEL,BL,TEFFL,OMEGA,FP,FT,ETA2,R0,HJM,HI,HS,
C      * DAGE)  ! KC 2025-05-31
      SUBROUTINE WRTMOD(M,JENV,HCOMP,HS1,HD,
     *HL,HP,HR,HT,MODEL,BL,TEFFL,FP,FT,HS,DAGE,CMIXL,XMSOL)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/LABEL/ into LABEL_MOD.
      USE LABEL_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/SOUND/ into SOUND_MOD.
      USE SOUND_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/SCRTCH/ into SCRTCH_MOD.
      USE SCRTCH_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE1/ into PULSE1_MOD.
      USE PULSE1_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PUALPHA/ into PUALPHA_MOD.
      USE PUALPHA_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/DEBHU/ into DEBHU_MOD.
      USE DEBHU_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/COMP/ into COMP_MOD.
      USE COMP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
      IMPLICIT LOGICAL*4(L)
      IMPLICIT REAL*8(A-H,O-Z)

C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
C 9/25/26 MHP via Claude
C code changed to add ISOUND (Csound.dat unit) to COMMON/IOUNITS/
C 9/24/26 MHP via Claude
C code changed to remove dead ILLDAT, IKUR from COMMON/LUNUM/
C 9/24/26 MHP via Claude
C code changed to remove dead IDYN from COMMON/LUNUM/
C 9/25/26 MHP via Claude
C code changed to remove dead COMMON/LUNUM/ISCOMP (declared,
C assigned a unit number, but never opened or read anywhere)
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
C 10/13/26 MHP via Claude: removed the unused COMMON/CCOUT/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 9/24/26 MHP via Claude
C code changed to pass CMIXL as an explicit argument instead of via
C common block, to reduce implicit global state ahead of the F90
C module conversion
C DBG PULSE
C 10/13/26 MHP via Claude
C code changed to replace COMMON/PULSE/ with an explicit argument.  main.f
C snapshots XMSOL=SMASS and wrtmod.f is the only reader; it is a snapshot,
C not the running SMASS, so it cannot be replaced by the mass already in
C scope there.
C 10/13/26 MHP via Claude: removed the unused COMMON/PULSE2/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C MHP 7/96 COMMON BLOCK INSERTED FOR SOUND SPEED
C DBG
C DBG 7/92 COMMON BLOCK ADDED TO COMPUTE DEBYE-HUCKEL CORRECTION.
C DBG 7/95 To store variables for pulse output
C 10/13/26 MHP via Claude: removed the unused COMMON/ROTEN/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      DIMENSION HCOMP(15,JSON),DUM1(4),DUM2(3),DUM3(3),DUM4(3)
C      *HS1(JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),HT(JSON),LC(JSON)
C       DIMENSION OMEGA(JSON),FP(JSON),FT(JSON),ETA2(JSON),ID(JSON)
C       DIMENSION R0(JSON),HJM(JSON),HI(JSON),HS(JSON)  ! KC 2025-05-31
      DIMENSION HS(JSON),HS1(JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     *          HT(JSON)
      DIMENSION FP(JSON),FT(JSON),ID(JSON)
C KC 2025-05-30 addressed warning messages from Makefile.legacy
C      DATA IHEADR/4H****/

C G Somers 10/14, Add spot common block, and store common block.
C 10/13/26 MHP via Claude: removed the unused COMMON/TEMP2/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude: removed the unused COMMON/QUADD/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C G Somers END

      SAVE

         print*,'wrtmod LSOUND 1: ',LSOUND

      IF(LSOUND)THEN

         print*,'wrtmod LSOUND 2: ',LSOUND

CFD 10/09 Add an extra output to plot the sound speed profile easyly
C 9/25/26 MHP via Claude
C code changed to use the managed ISOUND unit (opened once in PARMIN
C against the user-configurable FSOUND filename) instead of a
C hardcoded unit 500/'Csound.dat'
         WRITE(ISOUND,9124)
 9123    FORMAT(1X,I6,1X,2F12.8,1P,3E16.8)
 9124    FORMAT(1X,'Shell#',5x,'R/Rsun',7x,'M/Msun',7x,'Cs',15x,'Rho')
CFD end
         DO I = 1,M
            FR = EXP(CLN*HR(I))/CRSUN
            FM = EXP(CLN*HS(I))/CMSUN
            XX1 = FM/FR**3
            XXX = -EXP(CLN*(CGL+HS(I)+HD(I)-HP(I)-HR(I)))
            XX2 = -XXX/GAM1(I)
            XX3 = GAM1(I)
            XX4 = -XX2-XXX*(PQDP(I)+SDEL(2,I)*PQDT(I))
            XX5 = EXP(CLN*(C4PIL+HD(I)+3.0D0*HR(I)-HS(I)))
            SV = 1.0D-5*SQRT(GAM1(I)*EXP(CLN*(HP(I)-HD(I))))
            WRITE(IMODPT,123)FR,FM,XX1,XX2,XX3,XX4,XX5,SV
 123        FORMAT(1X,2F12.8,1P6E16.8)
CFD 10/09 Add an extra output to plot the sound speed profile easyly
            WRITE(ISOUND,9123)I,FR,FM,SV,HD(I),HT(I)
CFD end

C  DERIVATIVES OF DP/DR, DRHO/DR
            IF(I.LT.M) THEN
              RMID = 0.5D0*(EXP(CLN*HR(I))+EXP(CLN*HR(I+1)))
              DR = EXP(CLN*HR(I+1)) - EXP(CLN*HR(I))
              DIVP = 0.5D0*(GAM1(I)*EXP(CLN*HP(I))+
     *              GAM1(I+1)*EXP(CLN*HP(I+1)))*DR
              DIVR = 0.5D0*(EXP(CLN*HD(I))+EXP(CLN*HD(I+1)))*DR
              QPR1 = EXP(CLN*(CGL+HS(I)+HD(I)-2.0D0*HR(I)))
              QDR1 = EXP(CLN*(HD(I)-HP(I)))*PQDP(I)*QPR1
              QPR2 = EXP(CLN*(CGL+HS(I+1)+HD(I+1)-2.0D0*HR(I+1)))
              QDR2 = EXP(CLN*(HD(I+1)-HP(I+1)))*PQDP(I+1)*QPR1
              QQPR = (QPR1-QPR2)/DIVP
              QQDR = (QDR1-QDR2)/DIVR
              WRITE(IMODPT,124)RMID/CRSUN,QPR1,QDR1,QQPR,QQDR
 124          FORMAT(1X,F11.7,1P4E16.8)
            ENDIF
         END DO
      ENDIF
C
C G Somers 11/14 LCHEMO BLOCK REMOVED, AS THIS INFO IS ALREADY IN .STORE.
C
C DBG PULSE: PRINT OUT PULSATION ENV AND ATM IN ENVINT
C G Somers 11/14 CHANGE TO NEW I/O FLAGS.
      IF(LSTATM .OR. LSTENV .OR. LPULSE) THEN
C  INTEGRATE AN ENVELOPE FROM THE SURFACE TO THE CONVERGED MODEL,
C  PRINTING OUT THE RESULTS.
C  SET UP FLAGS AND COUNTERS.
       LSBC0 = .FALSE.
       IF(LSTORE)LPRT = .TRUE.
       KATM = 0
       KENV = 0
       KSAHA = 0
C  SAVE THE INTEGRATION STEP PARAMETERS AND ENFORCE THE SPACING
C  REQUESTED FOR PRINTOUT PURPOSES.
       ABEG0 = ATMBEG
       AMIN0 = ATMMIN
       AMAX0 = ATMMAX
       EBEG0 = ENVBEG
       EMIN0 = ENVMIN
       EMAX0 = ENVMAX
       ATMBEG = ATMSTP
       ATMMIN = ATMSTP
       ATMMAX = ATMSTP
       ENVBEG = ENVSTP
       ENVMIN = ENVSTP
       ENVMAX = ENVSTP
       B = DEXP(CLN*BL)
       RL = 0.5D0*(BL + CLSUNL - 4.0D0*TEFFL - C4PIL - CSIGL)
       GL = CGL + STOTAL - RL - RL
       X = HCOMP(1,M)
       Z = HCOMP(3,M)
       FPL = FP(M)
       FTL = FT(M)
       IXX=0
       HSTOT = STOTAL
       PLIM = HP(M)
C DBG PULSE: ADDED ARGUEMENT TO ENVINT TO TURN ON/OFF PULSE OUTPUT
         LPULPT = LPULSE
            IF (LDH) THEN
               XXDH = HCOMP(1,M)
               YYDH = HCOMP(2,M)+HCOMP(4,M)
               ZZDH = HCOMP(3,M)
               ZDH(1) = HCOMP(5,M)+HCOMP(6,M)
               ZDH(2) = HCOMP(7,M)+HCOMP(8,M)
               ZDH(3) = HCOMP(9,M)+HCOMP(10,M)+HCOMP(11,M)
            END IF
C MHP 10/02  define ISTORE - used in ENVINT
         IDUM = 0
C G Somers 10/14, FOR SPOTTED RUNS, FIND THE
C PRESSURE AT THE AMBIENT TEMPERATURE ATEFFL
        IF(JENV.EQ.M.AND.SPOTF.NE.0.0.AND.SPOTX.NE.1.0)THEN
            ATEFFL = TEFFL - 0.25*LOG10(SPOTF * SPOTX**4.0 + 1.0 - SPOTF)
       ELSE
          ATEFFL = TEFFL
       ENDIF
       CALL ENVINT(B,FPL,FTL,GL,HSTOT,IXX,LPRT,LSBC0,PLIM,RL,
     *               ATEFFL,X,Z,DUM1,IDUM,KATM,KENV,KSAHA,DUM2,
     *               DUM3,DUM4,LPULPT,CMIXL)
C G Somers END
       ATMBEG = ABEG0
       ATMMIN = AMIN0
       ATMMAX = AMAX0
       ENVBEG = EBEG0
       ENVMIN = EMIN0
       ENVMAX = EMAX0
      ENDIF
C
C G Somers 11/14 LCONZO (convection zone info) block deleted.
C
C G Somers 11/14 LJOUT (rotation info) block deleted.
C
      FSI = DEXP(-CLN*STOTAL)
C DBG PULSE: WRITE HEADER INFORMATION FOR PULSE MODEL
      IF(LPULSE) THEN
         RSURFL = 0.5D0*(BL - C4PIL - CSIGL - 4.0D0*TEFFL + CLSUNL)
         TEMPR = RSURFL - CRSUNL
         QSMASS = XMSOL
         WRITE (IOPMOD, 5001) MODEL,IDM,IPVER,QSMASS,
     1         TEFFL,BL,TEMPR, DAGE, CMIXL, XENV0, ZENV0
 5001    FORMAT(' MODEL#=', I5, '  NUMBER OF SHELLS IN MODEL=',I5,
     *          ' VER=',I2,/,
     *          ' MASS=',F8.5, '  LOG(TEFF)=',F8.5,/, ' LOG(L/LSUN)=',
     *          F16.10, '  LOG(R/RSUN)=',F16.10, /,
     *          ' AGE=', 1PE12.5,' GYR',/,
     *          ' MIXING LENGTH PARAMETER=', 0PF16.10,/,
     *          ' ZAMS (X,Z)=', 2F18.10)
      END IF
      DO 220 J = 1,IDM
       I = ID(J)
       FS = FSI*HS1(I)
C
C G Somers 11/14 FINAL LSCRIB BLOCK DELETED
C
C DBG WRITE PULSE MODEL
C       PRINT*, 'LPULSE=',LPULSE
         IF (LPULSE.AND.LSTORE) THEN
C MHP 10/02 uncommented pelpf statement, used later in i/o
C         PELPF = CGAS * DEXP(CLN*(HT(I) + HD(I)))* PEMU(I)
C          ADDED X AND Z TO OUTPUT
         IF ((J.EQ.2).AND.(I.EQ.1)) GOTO 5003
         IF(IPVER.EQ.1) THEN
         PELPF = CGAS * DEXP(CLN*(HT(I) + HD(I)))* PEMU(I)
         WRITE(IOPMOD, 5052)HR(I),FS,HL(I),HT(I),HD(I),
     *          HP(I), SESUM(I),SO(I), PQDP(I), PQED(I),
     *          PQET(I), PQOD(I), PQOT(I), SDEL(2,I),SDEL(3,I),
     *          PQCP(I), PRMU(I), PQDT(I), PELPF
         ELSE IF (IPVER.EQ.2) THEN
         WRITE(IOPMOD, 6052)HR(I),FS,HL(I),HT(I),HD(I),
     *      HP(I), SESUM(I),SO(I), PQDP(I), PQED(I),
     *      PQET(I), PQOD(I), PQOT(I), SDEL(2,I),SDEL(3,I),
     *      PQCP(I), PRMU(I), PQDT(I), HCOMP(1,I),HCOMP(3,I)
         ELSE IF (IPVER.EQ.3) THEN
C DBG 7/95 Modifed to include mixing length variables
         WRITE(IOPMOD, 6053)HR(I),FS,HL(I),HT(I),HD(I),VALFMLT(I),
     *      HP(I), SESUM(I),SO(I), PQDP(I), PQED(I),VPHMLT(I),
     *      PQET(I), PQOD(I), PQOT(I), SDEL(2,I),SDEL(3,I),VCMXMLT(I),
     *      PQCP(I), PRMU(I), PQDT(I), HCOMP(1,I),HCOMP(3,I)
         END IF
 5003      CONTINUE
 5052      FORMAT(5E16.9,/,5E16.9,/,5E16.9,/,5E16.9)
 6052      FORMAT(5E23.16,/,5E23.16,/,5E23.16,/,5E23.16)
 6053      FORMAT(6E23.16,/,6E23.16,/,6E23.16,/,5E23.16)
      END IF
C DBG END
  220 CONTINUE
C
C G Somers 11/14 REMOVED LONG BLOCK
C
      RETURN
      END
