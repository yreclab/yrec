C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MU
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MU(T,P,D,X,Z,RMU,AMU,EMU,BETA)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/COMP/ into COMP_MOD.
      USE COMP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 AMU,ATOMWT,BETA,D,DFX1,DFX12,DFX4,EE,EMU,P,RMU,T,X,Z


      DIMENSION ATOMWT(4)
C 10/13/26 MHP via Claude: removed the unused COMMON/NMLPAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 10/13/26 MHP via Claude
C code changed to drop COMMON/CTLIM/, declared here but never used.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C       DATA NZP1/12/
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
