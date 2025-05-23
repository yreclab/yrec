CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     HRA   EVALUATE FIT TO HARVARD REFERENCE ATMOSPHERE T-TAU
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     SPEED THIS UP BY PUTTING CONTSTANTS IN VARIABLES
C     TAKES TAU AND RETURNS LOG10(T)
      REAL*8 FUNCTION HRA(TAU)
      IMPLICIT REAL*8 (A-H,O-Z)
      SAVE
      TL = LOG10(TAU)
      X = 3.81152046471D0
      X = X + 0.146133736471D0*TL
      TL2 = TL*TL
      X = X + 0.0267719174279D0*TL2
      TL3 = TL2*TL
      X = X - 0.029280655317D0*TL3
      TL4 = TL3*TL
      X = X - 0.0123814456666D0*TL4
      TL5 = TL4*TL
      X = X + 0.00285734990893D0*TL5
      TL6 = TL5*TL
      X = X + 0.0024575213331D0*TL6
      TL7 = TL6*TL
      X = X + 0.000521560431455D0*TL7
      TL8 = TL7*TL
      X = X + 4.71770176883D-5*TL8
      TL9 = TL8*TL
      X = X + 1.58685112637D-6*TL9
      HRA = X
      RETURN
      END 
