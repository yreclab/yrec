C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C REDUCE
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE REDUCE(I,HHA,HHB,HL,HMAX,HP,HR,HS,HT,QP0,QP,QPR0,QPR,
     1QPP0,QPP,QT0,QT,QTR0,QTR,QTL0,QTL,QTP0,QTP,QTT0,QTT,QR0,QR,QRR0,
     2QRR,QRP0,QRP,QRT0,QRT,QL0,QL,QLP0,QLP,QLT0,QLT)
      use params, only : json
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION Q(4,4),HHA(4,2,JSON),HHB(4,JSON),HL(JSON),HMAX(4),
     1HP(JSON),HR(JSON),HS(JSON),HT(JSON)
      COMMON/CONST1/ CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      SAVE
C DEFINE R.H.S
      SD05 = 0.5D0*(HS(I)-HS(I-1))
      HHB(1,I) = SD05*(QP0 + QP) - (HP(I) - HP(I-1))
      HMAX(1) = DMAX1(HMAX(1),DABS(HHB(1,I)))
      HHB(2,I) = SD05*(QT0 + QT) - (HT(I) - HT(I-1))
      HMAX(2) = DMAX1(HMAX(2),DABS(HHB(2,I)))
      HHB(3,I) = SD05*(QR0 + QR) - (HR(I) - HR(I-1))
      HMAX(3) = DMAX1(HMAX(3),DABS(HHB(3,I)))
      HHB(4,I) = SD05*(QL0 + QL) - (HL(I) - HL(I-1))
      HMAX(4) = DMAX1(HMAX(4),DABS(HHB(4,I)))
      SD05 = SD05*CLN
C ELIMINATE COLUMNS 1 AND 2
      PIVOT = -SD05*QPR0
      Q(1,1) = (-1.0D0-SD05*QPP0) - PIVOT*HHA(3,1,I-1)
      Q(1,2) =                  - PIVOT*HHA(3,2,I-1)
      HHB(1,I) = HHB(1,I) - PIVOT*HHB(3,I-1)
      PIVOT = -SD05*QTR0
      PIVOTB= -SD05*QTL0
      Q(2,1) = -SD05*QTP0      -PIVOT*HHA(3,1,I-1)-PIVOTB*HHA(4,1,I-1)
      Q(2,2) =(-1.0D0-SD05*QTT0)-PIVOT*HHA(3,2,I-1)-PIVOTB*HHA(4,2,I-1)
      HHB(2,I) = HHB(2,I) - PIVOT*HHB(3,I-1) - PIVOTB*HHB(4,I-1)
      PIVOT = -1.0D0 - SD05*QRR0
      Q(3,1) = -SD05*QRP0 - PIVOT*HHA(3,1,I-1)
      Q(3,2) = -SD05*QRT0 - PIVOT*HHA(3,2,I-1)
      HHB(3,I) = HHB(3,I) - PIVOT*HHB(3,I-1)
      Q(4,1) = -SD05*QLP0 + HHA(4,1,I-1)
      Q(4,2) = -SD05*QLT0 + HHA(4,2,I-1)
      HHB(4,I) = HHB(4,I) + HHB(4,I-1)
C REDUCE 4*4 MATRIX
C PIVOT ON ROW-4 AND COLUMN-6
      HHA(4,1,I) = -SD05*QLP
      HHA(4,2,I) = -SD05*QLT
      PIVOT = -SD05*QTL
      Q(2,1) = Q(2,1) - PIVOT*Q(4,1)
      Q(2,2) = Q(2,2) - PIVOT*Q(4,2)
      HHB(2,I) = HHB(2,I) - PIVOT*HHB(4,I)
      HHA(2,1,I) = -SD05*QTP      - PIVOT*HHA(4,1,I)
      HHA(2,2,I) = (1.0D0-SD05*QTT) - PIVOT*HHA(4,2,I)
C PIVOT ON ROW-3 AND COLUMN-5
      DIV = 1.0D0/(1.0D0 - SD05*QRR)
      Q(3,1) = Q(3,1)*DIV
      Q(3,2) = Q(3,2)*DIV
      HHB(3,I) = HHB(3,I)*DIV
      DIV = -SD05*DIV
      HHA(3,1,I) = DIV*QRP
      HHA(3,2,I) = DIV*QRT
      PIVOT = -SD05*QPR
      Q(1,1) = Q(1,1) - PIVOT*Q(3,1)
      Q(1,2) = Q(1,2) - PIVOT*Q(3,2)
      HHB(1,I) = HHB(1,I) - PIVOT*HHB(3,I)
      HHA(1,1,I) = (1.0D0-SD05*QPP) - PIVOT*HHA(3,1,I)
      HHA(1,2,I) =                - PIVOT*HHA(3,2,I)
      PIVOT = -SD05*QTR
      Q(2,1) = Q(2,1) - PIVOT*Q(3,1)
      Q(2,2) = Q(2,2) - PIVOT*Q(3,2)
      HHB(2,I) = HHB(2,I) - PIVOT*HHB(3,I)
      HHA(2,1,I) = HHA(2,1,I) - PIVOT*HHA(3,1,I)
      HHA(2,2,I) = HHA(2,2,I) - PIVOT*HHA(3,2,I)
C PIVOT ON ROW-2 AND COLUMN-4
      DIV = 1.0D0/Q(2,2)
      Q(2,1) = Q(2,1)*DIV
      HHB(2,I) = HHB(2,I)*DIV
      HHA(2,1,I) = HHA(2,1,I)*DIV
      HHA(2,2,I) = HHA(2,2,I)*DIV
      DO 2 J=1,4
      IF(J.EQ.2) GO TO 2
      Q(J,1) = Q(J,1) - Q(J,2)*Q(2,1)
      HHB(J,I) = HHB(J,I) - Q(J,2)*HHB(2,I)
      HHA(J,1,I) = HHA(J,1,I) - Q(J,2)*HHA(2,1,I)
      HHA(J,2,I) = HHA(J,2,I) - Q(J,2)*HHA(2,2,I)
    2 CONTINUE
C PIVOT ON ROW-1 AND COLUMN-3
      DIV = 1.0D0/Q(1,1)
      HHB(1,I) = HHB(1,I)*DIV
      HHA(1,1,I) = HHA(1,1,I)*DIV
      HHA(1,2,I) = HHA(1,2,I)*DIV
      DO 4 J=2,4
      HHB(J,I) = HHB(J,I) - Q(J,1)*HHB(1,I)
      HHA(J,1,I) = HHA(J,1,I) - Q(J,1)*HHA(1,1,I)
      HHA(J,2,I) = HHA(J,2,I) - Q(J,1)*HHA(1,2,I)
    4 CONTINUE
      RETURN
      END
