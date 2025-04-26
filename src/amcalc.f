C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C AMCALC
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      SUBROUTINE AMCALC(SMASS,BL,TEFFL)
      use settings, only : CLSUNL, CRSUN  ! /CONST/
      use settings, only : CLN, C4PIL  ! /CONST1/
      use settings, only : CSIGL  ! /CONST2/
      use settings, only : AWIND, LROSSBY, PMMSOLP, PMMSOLTAU  ! /PMMWIND/
      use settings, only : EXTAU, EXR, EXM, EXL, EXPR, STRUCTFACTOR  ! /CWIND/
      use settings, only : TAUCZ, TAUCZ0, PPHOT, PPHOT0, FRACSTEP  ! /OVRTRN/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)

      SAVE

C G Somers, 6/16
C THIS SHORT SUBROUTINE WILL USE THE DELIVERED STRUCTURAL VARIABLES TO DETERMINE
C THE STRENGTH OF THE TORQUE, ACCORDING TO THE MATT ET AL. (2012) FORMULATION.
C
C COLLECT THE RELEVANT STRUCTURE VARIABLES, AND
C     MASS
      RMASS = SMASS
C     RADIUS
      RL = 0.5D0*(BL+CLSUNL-C4PIL-CSIGL-4.D0*TEFFL)
      RTOT  = DEXP(CLN*RL)
      RRAD = RTOT/CRSUN
C     LUMINOSITY
      RLUM = 10.**BL
C     PHOTOSPHERIC PRESSURE
      RPHOT = 10.**(PPHOT0+FRACSTEP*(PPHOT-PPHOT0))/(10.**PMMSOLP)
C     CONVECTIVE OVERTURN TIMESCALE
      IF(LROSSBY)THEN
         RTAU = (TAUCZ0+FRACSTEP*(TAUCZ-TAUCZ0))/PMMSOLTAU
      ELSE
         RTAU = 1.
      ENDIF
C     COMBINE THEM ALL
      STRUCTFACTOR = RMASS**EXM * RRAD**EXR * RLUM**EXL * RPHOT**EXPR
     *               * RTAU**EXTAU
      RETURN
      END
