
C***********************************************************************
      SUBROUTINE T6RINTERP(SLR,SLT)
      use params, only : mx, mv, nr => nreos, nt => nteos
      use settings, only : ISHORT  ! COMMON/LUOUT/
      IMPLICIT REAL*8 (A-H,O-Z)
C     THE PURPOSE OF THIS SUBROUTINE IS TO INTERPOLATE IN T6 AND RHO
      SAVE
      COMMON/EE/ EPL(MX,NT,NR),XX(MX)
      COMMON/AA/ Q(4),H(4),XXH
      COMMON/A/  XZ(MX,MV,NT,NR),
     .T6LIST(NR,NT),RHO(NR),T6A(NT),ESK(NT,NR),ESK2(NT,NR),DFSX(MX),
     . DFS(NT),DFSR(NR),XA(MX),M,MF
      COMMON/BB/L1,L2,L3,L4,K1,K2,K3,K4,IP,IQ
      COMMON/E/ ESACT,EOS(MV)
C
      IU=0
      IS=0

      DO KX=K1,K1+IP
          IW=1
        IU=IU+1
        H(IU)=QUAD(IS,IW,SLR,ESK(KX,L1),ESK(KX,L2),ESK(KX,L3),
     X  RHO(L1),RHO(L2),RHO(L3))
          IF(IQ. EQ. 3) THEN
            IW=2
            Q(IU)=QUAD(IS,IW,SLR,ESK(KX,L2),ESK(KX,L3),ESK(KX,L4),
     X      RHO(L2),RHO(L3),RHO(L4))
          ENDIF
        IS=1
      ENDDO
C
      IS=0
      IW=1
C..... EOS(I) IN LOWER-RIGHT 3X3(I=I1,I1+2 J=J1,J1+2)
      ESACT=QUAD(IS,IW,SLT,H(1),H(2),H(3),T6A(K1),T6A(K2),T6A(K3))
        IF (IQ. EQ. 3) THEN
C.....    EOS(I) UPPER-RIGHT 3X3(I=I1+1,I1+3 J=J1,J1+2)
          ESACTQ=QUAD(IS,IW,SLT,Q(1),Q(2),Q(3),T6A(K1),T6A(K2),T6A(K3))
        ENDIF
        IF(IP .EQ. 3) THEN
C.....    EOS(I) IN LOWER-LEFT 3X3.
          ESACT2=QUAD(IS,IW,SLT,H(2),H(3),H(4),T6A(K2),T6A(K3),T6A(K4))
C.....    EOS(I) SMOOTHED IN LEFT 3X4
          DIX=(T6A(K3)-SLT)*DFS(K3)
          ESACT=ESACT*DIX+ESACT2*(1.D0-DIX)
        ENDIF
        IF(IQ .EQ. 3) THEN

C.....     EOS(I) IN UPPER-RIGHT 3X3.
          ESACTQ2=QUAD(IS,IW,SLT,Q(2),Q(3),Q(4),T6A(K2),T6A(K3),T6A(K4))
          ESACTQ=ESACTQ*DIX+ESACTQ2*(1.D0-DIX)
        ENDIF
C
        IF(IQ .EQ. 3) THEN
          DIX2=(RHO(L3)-SLR)*DFSR(L3)
            IF(IP .EQ. 3) THEN
C.....        EOS(I) SMOOTHED IN BOTH LOG(T6) AND LOG(R)
              ESACT=ESACT*DIX2+ESACTQ*(1.D0-DIX2)
            ENDIF
        ENDIF
        IF (ESACT .GT. 1.D+15) THEN
          WRITE(ISHORT,'("INTERPOLATION INDICES OUT OF RANGE",
     X              ";PLEASE REPORT CONDITIONS.")')
          STOP
        ENDIF

      RETURN
      END
