C $$$$$$
      SUBROUTINE CHKCAL(BL,RL,N,SOLZX,DLDX,DRDX,DLDA,DRDA,LSOL)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/RUNLOOP/ into RUNLOOP_MOD.  A blanket
C USE imports exactly the names the COMMON declaration made global here,
C so it cannot change meaning.  See runloop_mod.f for the block history
C and for why the module declares the types the implicit rules supplied.
      USE RUNLOOP_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 BL,BLP,DA,DLDA,DLDX,DRDA,DRDX,DX,DZ,RL,RLP,SOLZX,ZL,ZLP
      INTEGER N
      LOGICAL*4 LSOL
C     ONLY CALLED FOR EVEN NK, ASSUMES RESCALING ON ODD NK AND EVOLVING
C     ON EVEN NK
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
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
C 10/13/26 MHP via Claude: removed the unused COMMON/SETT/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude
C code changed to replace COMMON/CALSUN/ with explicit arguments.  This
C routine wrote all nine members; only the four derivatives and LSOL are
C read outside it, by main.f, so those are now arguments.  BLP, RLP, DX
C and DA never left this routine and are now locals, kept across calls by
C the blanket SAVE below -- which they need, since BLP and RLP are stored
C on one call and differenced against on the next.
C MHP 6/13 ADD OPTION TO CALIBRATE SOLAR Z/X, SOLAR Z/X, SOLAR AGE
C      COMMON/CALS2/TOLL,TOLR,LCALS
C MHP 10/02 MISSING LOGICAL UNIT IOWR ADDED
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      SAVE
C     DATA TOLL,TOLR/1.0D-5,1.0D-4/
C CHECK TO SEE IF THE MODEL IS A CALIBRATED SOLAR MODEL.
C IF NOT, ESTIMATE CORRECTIONS TO X AND ALPHA.
      IF(ABS(BL).LT.TOLL .AND. ABS(RL).LT.TOLR)THEN
C ADD CHECK FOR Z/X
         IF(LCALSOLZX .AND.CALSOLZX.GT.0.0D0)THEN
            ZL = LOG10(SOLZX)-LOG10(CALSOLZX)
            IF(ABS(ZL).LT.TOLZ)THEN
               LSOL = .TRUE.
               GOTO 9999
            ENDIF
         ELSE
C CALIBRATED SOLAR MODEL.  SET UP OUTPUT FLAGS AND EXIT
            LSOL = .TRUE.
            GOTO 9999
         ENDIF
      ENDIF

c Added code to use pre-determined partial derivatives    LLP  6/28/09
      DLDX = -3.78D0            ! empirical result:  -3.783    RMS error .070
      DRDX = -0.89D0             ! empirical result:  -0.890    RMS error .048
      DLDA = 0.0139D0            ! empirical result:  +0.139    RMS error .0022
      DRDA = -0.050D0            ! empirical result:  -0.0504   RMS error .0059
      GOTO 1234            ! Bypass partial derivative code
c mhp 5/96 added change to compute solar calibration for 3 kind cards
      IF(N.EQ.3)THEN
C     SET UP RUN TO DETERMINE DERIVATIVE OF L AND R WITH RESPECT TO X.
C
C     3.7 is empirical average dL/dX, so trial DX is BL / (dL/dX)   ! llp 6/18/09
c         DX = BL/3.7D0
C         DX = +.01
         RESCAL(2,N+1) = RESCAL(2,1)+DX
C STORE PREVIOUS L AND R.
         XENV0A(N+1) = RESCAL(2,N+1)
         XENV0A(N+2)=XENV0A(N+1)
         XENV0A(N+3)=XENV0A(N+1)
         BLP = BL
         RLP = RL
         GOTO 9999
      ELSE IF(N.EQ.6)THEN
C     EVALUATE DERIVATIVE OF L AND R WITH RESPECT TO X.
c         DLDX = (BL - BLP)/DX
c         DRDX = (RL - RLP)/DX
c         WRITE(IOWR,*) "DX,DLDX,BL,BLP,DRDX,RL,RLP: ",
c     *      DX,DLDX,BL,BLP,DRDX,RL,RLP
C     SET UP RUN TO DETERMINE DERIVATIVE OF L AND R WITH RESPECT TO ALPHA.

C     .042 is typical average dR/dA, so trial DA is RL / (dR/dA)   ! llp 6/18/09
c         DA = RL/0.042D0
         CMIXLA(N+1) = CMIXLA(1)+DA
         CMIXLA(N+2) = CMIXLA(N+1)
         CMIXLA(N+3) = CMIXLA(N+1)
         RESCAL(2,N+1) = RESCAL(2,1)
         XENV0A(N+1)=XENV0A(1)
         XENV0A(N+2)=XENV0A(N+1)
         XENV0A(N+3)=XENV0A(N+1)
         BLP = BL
         RLP = RL
         GOTO 9999
      ELSE IF(N.EQ.9)THEN
C     EVALUATE DERIVATIVE OF L AND R WITH RESPECT TO ALPHA.
         DLDA = (BL - BLP)/DA
         DRDA = (RL - RLP)/DA
         WRITE(IOWR,*) "DA,DLDA,BL,BLP,DRDA,RL,RLP: ",
     *       DA,DLDA,BL,BLP,DRDA,RL,RLP
C     USE DERIVATIVES OF L AND R WITH RESPECT TO X AND ALPHA TO
C     GET IMPROVED GUESSES FOR ALPHA AND X.
         DA = ((BL*DRDX/DLDX-RL)/(DRDA-DLDA*DRDX/DLDX))
         DX = -(BL + DLDA*DA)/DLDX
         CMIXLA(N+1) = CMIXLA(1)+DA
         CMIXLA(N+2) = CMIXLA(N+1)
         CMIXLA(N+3) = CMIXLA(N+1)
         RESCAL(2,N+1) = RESCAL(2,1)+DX
         XENV0A(N+1) = RESCAL(2,N+1)
         XENV0A(N+2) = RESCAL(2,N+1)
         XENV0A(N+3) = RESCAL(2,N+1)
         BLP = BL
         RLP = RL
         WRITE(IOWR,*) "New X, Old X, Calc DX: ",
     *       RESCAL(2,N+1), RESCAL(2,1), DX
         WRITE(IOWR,*) "New A, Old A, Calc DA: ",
     *       CMIXLA(N+1), CMIXLA(1), DA
         GOTO 9999
c      ELSE
      endif   ! terrminate old partial derivative code

 1234 Continue
C     USE DERIVATIVES OF L AND R WITH RESPECT TO X AND ALPHA TO
C     GET IMPROVED GUESSES FOR ALPHA AND X.
         DA = ((BL*DRDX/DLDX-RL)/(DRDA-DLDA*DRDX/DLDX))
         DX = -(BL + DLDA*DA)/DLDX
         CMIXLA(N+1) = CMIXLA(N-2)+DA
         CMIXLA(N+2) = CMIXLA(N+1)
         CMIXLA(N+3) = CMIXLA(N+1)
         IF(LCALSOLZX)THEN
            RESCAL(3,N+1) = RESCAL(3,N-2)*CALSOLZX/SOLZX
            DZ = RESCAL(3,N+1) - RESCAL(3,N-2)
            ZENV0A(N+1) = RESCAL(3,N+1)
            ZENV0A(N+2) = RESCAL(3,N+1)
            ZENV0A(N+3) = RESCAL(3,N+1)
         ENDIF
         RESCAL(2,N+1) = RESCAL(2,N-2)+DX
         XENV0A(N+1) = RESCAL(2,N+1)
         XENV0A(N+2) = RESCAL(2,N+1)
         XENV0A(N+3) = RESCAL(2,N+1)
         WRITE(IOWR,*) "New BL, Old BL, Delta BL: ",
     *       BL, BLP, BL-BLP
         WRITE(IOWR,*) "New RL, Old RL, Delta RL: ",
     *       RL, RLP, RL-RLP
         WRITE(IOWR,*) "New X, Old X, DX: ",
     *       RESCAL(2,N+1), RESCAL(2,N-2), DX
         WRITE(IOWR,*) "New A, Old A, DA: ",
     *       CMIXLA(N+1), CMIXLA(N-2), DA
         IF(LCALSOLZX)THEN
            WRITE(IOWR,*) "New Z, Old Z, DZ: ",
     *       RESCAL(3,N+1), RESCAL(3,N-2), DZ
         ENDIF
         BLP = BL
         RLP = RL
         ZLP = ZL
         GOTO 9999
C      ENDIF
 9999 CONTINUE
      RETURN
      END
