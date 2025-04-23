C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MU
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MU(T,P,D,X,Z,RMU,AMU,EMU,BETA)
      use settings, only : XENV, ZENV, AMUENV  ! COMMON/COMP/
      use settings, only : CGAS  ! COMMON/CONST2/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION ATOMWT(4)
      COMMON/CTLIM/ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TENV,TGCUT
      DATA NZP1/12/
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/
      SAVE

C SET UP FRACTIONAL ABUNDANCES
      DFX1 = (X - XENV)
      DFX12 = (Z - ZENV)
      IF(DABS(DFX1) + DABS(DFX12) .LT. 1.0D-5) THEN
C USE ENVELOPE ABUNDANCES
         AMU = AMUENV
      ELSE
         DFX1 = DFX1*ATOMWT(1)
         DFX12 = DFX12*ATOMWT(3)
         DFX4 = (XENV+ZENV -X-Z)*ATOMWT(2)
C ASSUME EXCESS Z(METALS) IS IN THE FORM OF CARBON(12)
         AMU = AMUENV + DFX1 + DFX4 + DFX12
      ENDIF
      EE=((BETA*P)/(D*T*CGAS*AMU))-1.0D0
      EMU=EE*AMU
      RMU=CGAS*(AMU+EMU)

      RETURN
      END
