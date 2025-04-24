C-------------------------    GROUP: SR_PX    -------------------------------
C
C     MHD INTERPOLATION PACKAGE
C     PRESSURE AS ARGUMENT INTERPOLATION IN X, Z FIXED
C
C     INPUT   PGL = LOG10 (GAS PRESSURE [DYN/CM2])
C             TL  = LOG10 (TEMPERATURE [K])
C             XC  = HYDROGEN ABUNDANCE (BY MASS)
C
C     OUTPUT  RL  = LOG10 (DENSITY [G/CM3])        : ARGUMENT
C             OTHER (SEE SEPARATE INSTRUCTIONS)    : COMMON/MHDOUT/...
C
C     ERROR   IERR = 1 SIGNALS PGL,TL OUTSIDE THE DOMAIN OF TABLES
C             (OTHERWISE IERR = 0).
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHDPX
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MHDPX(PL,TL,XC,RL)
      use params, only : nchem0
      use settings, only : ISHORT, IOWR  ! /LUOUT/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C     S/R MHDSTX MUST BE CALLED IN MAIN.
C     CALLS VARIABLE-X VERSION
      PARAMETER( IVARC=25)
      COMMON/MHDOUT/VARMHD(IVARC)
      SAVE

      CALL MHDPX1(PL,TL,XC)
C     IERR = 0
      RL =VARMHD(1)
      RETURN
  999 CONTINUE
      WRITE(IOWR,*) 'ERROR (MHD): OUT OF TABLE RANGE. RETURN'
      WRITE(ISHORT,*) 'ERROR (MHD): OUT OF TABLE RANGE. RETURN'
      STOP
      END
