C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C HSOLVE
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE HSOLVE(M,HHA,HHB,HSRF)

      PARAMETER(JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION HHA(4,2,JSON),HHB(4,JSON),HSRF(6)
      SAVE

      DIV = 1.0D0/(HSRF(1) - HHA(3,1,M))
      PIVOT = (HSRF(4) - HHA(4,1,M))*DIV
      HHB(1,1) = HSRF(3) - HHB(3,M)
      HHB(2,1) = (HSRF(6) - HHB(4,M)) - PIVOT*HHB(1,1)
      QTEMP  = HSRF(2) - HHA(3,2,M)
      QQQT = HHB(2,1)/(HSRF(5)-HHA(4,2,M)-PIVOT*QTEMP )
      QQQP = DIV*(HHB(1,1) - QQQT*QTEMP)
      DO 10 I=2,M
         IM = M + 2 - I
         PSTORE    = HHB(1,IM) - QQQP*HHA(1,1,IM) - QQQT*HHA(1,2,IM)
         TSTORE    = HHB(2,IM) - QQQP*HHA(2,1,IM) - QQQT*HHA(2,2,IM)
         HHB(3,IM) = HHB(3,IM) - QQQP*HHA(3,1,IM) - QQQT*HHA(3,2,IM)
         HHB(4,IM) = HHB(4,IM) - QQQP*HHA(4,1,IM) - QQQT*HHA(4,2,IM)
         HHB(1,IM) = QQQP
         HHB(2,IM) = QQQT
         QQQP = PSTORE
         QQQT = TSTORE
 10   CONTINUE
      HHB(1,1) = QQQP
      HHB(2,1) = QQQT
      HHB(3,1) = HHB(3,1) - QQQP*HHA(3,1,1) - QQQT*HHA(3,2,1)
      HHB(4,1) = HHB(4,1) - QQQP*HHA(4,1,1) - QQQT*HHA(4,2,1)

      RETURN
      END
