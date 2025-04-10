C $$$$$$
      SUBROUTINE CHKCAL(BL,RL,N,SOLZX)
C     ONLY CALLED FOR EVEN NK, ASSUMES RESCALING ON ODD NK AND EVOLVING
C     ON EVEN NK
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON /CKIND/RESCAL(4,50),NMODLS(50),IRESCA(50),LFIRST(50),
     1        NUMRUN
C MHP 10/24 ADDED STOP CRITERIA FOR CENTRAL H,D,AND HE4
      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50)
C      COMMON/SETT/ENDAGE(50),SETDT(50),LENDAG(50),LSETDT(50)
      COMMON /NEWXYM/XENV0A(50),ZENV0A(50),CMIXLA(50),LSENV0A(50),
     * SENV0A(50)
      COMMON/CALSUN/DLDX,DRDX,DLDA,DRDA,BLP,RLP,DX,DA,LSOL
C MHP 6/13 ADD OPTION TO CALIBRATE SOLAR Z/X, SOLAR Z/X, SOLAR AGE
      COMMON/CALS2/TOLL,TOLR,TOLZ,LCALS,LCALSOLZX,CALSOLZX,CALSOLAGE
C      COMMON/CALS2/TOLL,TOLR,LCALS
C MHP 10/02 MISSING LOGICAL UNIT IOWR ADDED
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
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
      DLDX = -3.78D0		! empirical result:  -3.783    RMS error .070
      DRDX = -0.89D0 		! empirical result:  -0.890    RMS error .048
      DLDA = 0.0139D0		! empirical result:  +0.139    RMS error .0022
      DRDA = -0.050D0		! empirical result:  -0.0504   RMS error .0059
      GOTO 1234		! Bypass partial derivative code
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
