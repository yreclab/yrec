CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C     condOpacPInt -  Calculate  Conductive Opacities based on Chirs
C                     Burke's conductive opacity code and callin
C                     on Potehkin code and table.
C
C                      LLP    5/31/04
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      SUBROUTINE condOpacPInt(DL,TL,X,Z,OC,OCL,QODC,QOTC,FXION,LCONDO)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      REAL*8 FXION(3)
      DATA AH1,AHe4,AOx /1.008D0,4.004D0,16D0/
      save

C Get fractional abundances in nubers of atoms of H1, He4 and metals (Ox)
      Y=1.0D0-X-Z
      WtH1Base  = (X/AH1)  / (X/AH1 + Y/AHe4 + Z/AOx)
      WtHe4Base = (Y/AHe4) / (X/AH1 + Y/AHe4 + Z/AOx)
      WtOxBase  = (Z/AOx)  / (X/AH1 + Y/AHe4 + Z/AOx)

C In addition we now weight the H1, He and Ox by oncly
C considering those atoms H1 and He4 atomos which are
C charged. FXION(1) is the fraction of H1 atoms that are
C (singly) charged. FXION(2) is the fraction of He4 atoms
C that are singly charged and FXION(3) the fractoin that
C are doubly charged.  It is presumed that the metals (Ox)
C are fully ionized in first approximation. Because of
C their low abundance (tyically less than 2% divided by
C the atomic mass
       WtH1 = WtH1Base * FXION(1) ! (FXION(1)/1D0 is the fraction
       WtHe4 = WtHe4Base * (FXION(2) + 2D0*FXION(3))/2D0
       WtOx = WtOxBase

C We initially presume no significant conductive opacity
       LCONDO=.FALSE.
c       OC = 1D50
c       OCL = LOG10(OC)
       OCL = 9.9998D0
       OC = 10D0**OCL
       QODC = OC
       QOTC = OC

       RL = DL - 3.0D0*(TL-6.0D0)
C     DO CONDUCTIVE OPACITY CORRECTION in fully ionized approximation
      IF(TL.GE.3.0D0.AND.TL.LE.9.0D0.AND.DL.LE.9.75D0) THEN
         IF (DL.GE.-6.0D0) THEN
           CALL CondOpacP(1.0D0,TL,DL,CONDXL,QODCX,QOTCX)
           CALL CondOpacP(2.0D0,TL,DL,CONDYL,QODCY,QOTCY)
           CALL CondOpacP(8.0D0,TL,DL,CONDZL,QODCZ,QOTCZ)

           CONDX = 10.0D0**(-CONDXL)
           CONDY = 10.0D0**(-CONDYL)
           CONDZ = 10.0D0**(-CONDZL)

           CONDL = -LOG10(WtH1*CONDX + WtHe4*CONDY + WtOx*CONDZ)
c           CONDL = LOG10( (X + 1D0) / 2D0 ) -
c     *             LOG10( X*CONDX + .5D0*Y*CONDY + .5D0*z*CONDZ)

           QODC = CONDL * (WtH1*QODCX + WtHe4*QODCY + WtOx*QODCZ)
c           QODC = 2D0 * CONDL / ( 1D0 + X ) *
c     *          (X*CONDX*QODCX +.5D0*Y*CONDY*QODCY +.5D0*Z*COBDZ*QODCZ)

            QOTC = CONDL * (WtH1*QODCX + WtHe4*QODCY + WtOx*QODCZ)
c           QOTC = 2D0 * CONDL / ( 1D0 + X ) *
c     *          (X*CONDX*QOTCX +.5D0*Y*CONDY*QOTCY +.5D0*Z*CONDZ*QOTCZ)

         OCL = -3.5194D0+3.0D0*TL-DL-CONDL
           QODC = -1.0D0-QODC
           QOTC = 3.0D0-QOTC
           LCONDO=.TRUE.
           OC = 10.0D0**OCL
         END IF
         IF (DL.LT.-6.0D0.AND.RL.GE.0.0D0) THEN
C Extrapolate Conductive opacity
           CALL CondOpacP(1.0D0,TL,-6.0D0,CONDXL,QODC,QOTC)
           CALL CondOpacP(2.0D0,TL,-6.0D0,CONDYL,CRAP,CRAP2)
           CALL CondOpacP(8.0D0,TL,-6.0D0,CONDZL,CRAP,CRAP2)

           CONDX = 10.0D0**(-CONDXL)
           CONDY = 10.0D0**(-CONDYL)
           CONDZ = 10.0D0**(-CONDZL)

           CONDL = LOG10(WtH1*CONDX + WtHe4*CONDY + WtOx*CONDZ)
c           CONDL = LOG10( (X + 1D0) / 2D0 ) -
c     *            LOG10( X*CONDX + .5D0*Y*CONDY + .5D0*Z*CONDZ)

           OCL = -3.5194D0+3.0D0*TL+6.0D0-CONDL
           QODC = -1.0D0-QODC
           QOTC = 3.0D0-QOTC
           OCL = OCL + QODC*(-6.0D0-DL)
           OC = 10.0D0**OCL
           LCONDO=.TRUE.
         END IF
      END IF

      RETURN
      END



