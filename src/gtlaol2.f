C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     GET LAOL2 OPACITY
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE GTLAOL2(DL,TL,X,O,OL, QOD, QOT)
      use settings, only : ISHORT  ! COMMON/LUOUT/

C DBG 5/94 Identical to GTLAOL except gets opacity from second table
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      REAL*8 DL,TL,X,O,OL,QOD,QOT
      CHARACTER*256 FLAOL, FLAOL2, FPUREZ, FOPAL2
      REAL*8 RSCLZC,RSCLZM1, RSCLZM2
      DIMENSION TOP(104),TR(104),TDOR(104), DODR(52), DODRX(4)
      DIMENSION TOP1(52),TT(52), TDOT(52), DODTX(4)
      DIMENSION TOP2(4),XX(4)
      COMMON/NWLAOL/OLAOL(12,104,52), OXA(12), OT(52), ORHO(104),
     *  TOLLAOL, IOLAOL, NUMOFXYZ, NUMRHO, NUMT, LLAOL, LPUREZ,
     *  IOPUREZ, FLAOL, FPUREZ
      COMMON/NWLAOL2/OLAOL2(12,104,52), OXA2(12), OT2(52),
     *        ORHO2(104), NXYZ2,NRHO2,NT2
      COMMON/SLAOL/SLAOLL(12,104,52),SRHOL(12,104,52),
     *  SDORL(12,104,52), NUMRS(12,52)
      COMMON/SLAOL2/SLAOLL2(12,104,52),SRHOL2(12,104,52),
     *  SDORL2(12,104,52), NUMRS2(12,52)
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *             IOLAOL2, IOOPAL2, NK,
     *             LZRAMP, FLAOL2, FOPAL2
      SAVE
C
C     1. CUBIC SPLINE INTERPOLATE IN DENSITY
C     2. CUBIC SPLINE INTERPOLATE IN TEMPERATURE
C     3. LINEAR INTERPOLATE IN COMPOSITION
C     IF WITHIN TOLLAOL OF EDGE THEN LINEAR EXTRAPOLATE
C
C     TOLLAOL PERMITS SOME EXTRAPLOATION BEYOND TABLE EDGE.
      TOLL = LOG(TOLLAOL)
C     FACTOR = 3.0E-1
      RX = X
      RTL = TL
C     RTL1 = TL+FACTOR
C     RTL2 = TL-FACTOR
      RDL = DL
      CALL LOCATE(OT2,NT2,RTL,JT)
      CALL LOCATE(OXA2,NXYZ2,RX,JX)
      IF (JX .EQ. NXYZ2) THEN
          JX = NXYZ2-1
      END IF
      IF (JX .EQ. 0) THEN
          JX = 1
      END IF
      NUMXS = 0
      JXP1 = JX + 1
      DO IX=JX, JXP1
         NUMTS = 0
C        GET RANGE OF FOUR TT SURROUNDING T
         CALL XRNG4(JT,NT2,JT1,JT2)
         DO IT=JT1, JT2
            NUMS = NUMRS2(IX,IT)
            IF(NUMS .GE. 4) THEN
               DO IR=1, NUMS
                  TOP(IR) = SLAOLL2(IX,IR,IT)
                  TR(IR) = SRHOL2(IX,IR,IT)
                  TDOR(IR) = SDORL2(IX,IR,IT)
               END DO
               IF (RDL.GT.TR(1) .AND. RDL.LT.TR(NUMS)) THEN
                  CALL SPLINT(TR,TOP,NUMS,TDOR,RDL, ROL, KLO, KHI)
                  NUMTS = NUMTS+1
                  TOP1(NUMTS) = ROL
                  TT(NUMTS) = OT2(IT)
                  DODR(NUMTS)=(TOP(KHI)-TOP(KLO))/(TR(KHI)-TR(KLO))
               ELSE IF (RDL.GT.TR(1)-TOLL .AND. RDL.LE.TR(1)) THEN
C                 PUT LINEAR EXTRAPOLATION ROUTINES HERE
                  SLOPE = (TOP(2)-TOP(1))/(TR(2)-TR(1))
                  ROL = TOP(1)+SLOPE*(RDL-TR(1))
C                 CALL SPLINT(TR,TOP,NUMS,TDOR,RDL, ROL1, KLO, KHI)
                  NUMTS = NUMTS+1
                  TOP1(NUMTS) = ROL
                  TT(NUMTS) = OT2(IT)
                  DODR(NUMTS) = SLOPE
               ELSE IF (RDL.GE.TR(NUMS) .AND.
     *                  RDL.LT.TR(NUMS)+TOLL) THEN
C                 PUT LINEAR EXTRAPOLATION ROUTINES HERE
                  SLOPE = (TOP(NUMS-1)-TOP(NUMS))/
     *                    (TR(NUMS-1)-TR(NUMS))
                  ROL = TOP(NUMS)+SLOPE*(RDL-TR(NUMS))
C                 CALL SPLINT(TR,TOP,NUMS,TDOR,RDL, ROL1, KLO, KHI)
                  NUMTS = NUMTS+1
                  TOP1(NUMTS) = ROL
                  TT(NUMTS) = OT2(IT)
                  DODR(NUMTS) = SLOPE
               END IF
            ELSE
               WRITE(ISHORT,120)DL,TL
  120          FORMAT(' OUTSIDE OPACITY TABLE #2, IN DENSITY.  ',
     *        'LOG(RHO)=',1PE12.3, ' LOG(T)=', 1PE12.3)
               STOP
            END IF
         END DO
         IF(NUMTS .GE. 4) THEN
            CALL CSPLINE(TT,TOP1,NUMTS,1.0D30,1.0D30,TDOT)
            CALL SPLINT(TT,TOP1,NUMTS,TDOT,RTL, ROL, KLO, KHI)
            NUMXS = NUMXS + 1
            TOP2(NUMXS) = ROL
            SLOPE=(DODR(KHI)-DODR(KLO))/(TT(KHI)-TT(KLO))
            DODRX(NUMXS)=DODR(KLO)+SLOPE*(RTL-TT(KLO))
            DODTX(NUMXS) = (TOP1(KHI)-TOP1(KLO))/(TT(KHI)-TT(KLO))
            XX(NUMXS) = OXA2(IX)
         ELSE
            WRITE(ISHORT,121)DL,TL
  121       FORMAT(' OUTSIDE OPACITY TABLE #2, IN TEMPERATURE.  ',
     *     'LOG(RHO)=',1PE12.3, ' LOG(T)=', 1PE12.3)
            STOP
         END IF
      END DO
      IF (NUMXS .GE. 2) THEN
         SLOPE = (TOP2(2)-TOP2(1))/(XX(2)-XX(1))
         ROL = TOP2(1)+SLOPE*(X-XX(1))
C        SLOPE = (QOT2-QOT1)/(XX(2)-XX(1))
         SLOPE = (DODTX(2)-DODTX(1))/(XX(2)-XX(1))
         QOT = DODTX(1) + SLOPE*(X-XX(1))
         SLOPE = (DODRX(2)-DODRX(1))/(XX(2)-XX(1))
         QOD = DODRX(1)+SLOPE*(X-XX(1))
         IF(ROL .GT. 35) THEN
            O = 1.0D35
            OL = 35.0D0
         ELSE
            O = 10.0D0**ROL
            OL = ROL
         END IF
      ELSE
         WRITE(ISHORT,122)DL,TL
  122    FORMAT(' OUTSIDE OPACITY TABLE #2.  ',
     *  'LOG(RHO)=',1PE12.3, ' LOG(T)=', 1PE12.3)
          STOP
      END IF
      RETURN
      END
