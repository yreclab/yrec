C********************************************************************
      REAL*8 FUNCTION RHOOFP(X,ZTAB,T6,P,IRAD)
      use params, only : mx, mv, nr => nreos, nt => nteos
      use parmin90, only : ISHORT  ! COMMON/LUOUT/
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON/LREADCO/ITIME
      COMMON/A/  XZ(MX,MV,NT,NR),  
     .T6LIST(NR,NT),RHO(NR),T6A(NT),ESK(NT,NR),ESK2(NT,NR),DFSX(MX),
     . DFS(NT),DFSR(NR),XA(MX),M,MF
      COMMON/B/ ZZ(MX),IRI(10),INDEX(10),NTA(NR)
      COMMON/E/ ESACT,EOS(MV)
      DIMENSION NRA (NT)
      DATA SIGMACC/1.8914785D-3/
      DATA (NRA(I),I=1,NT)/7*77,2*76,2*74,2*72,2*70,68,67,66,65,64,
     X 63,61,60,59,58,57,55,54,53,52,51,2*49,48,2*47,46,2*45,
     X 15*44,2*37/
      SAVE
      RAT=SIGMACC
      PR=0.0D0
C      IF(IRAD .EQ. 1) PR=4.D0/3.D0*RAT*T6**4   ! MB 
      PNR=P-PR

      IF (ITIME .NE. 12345678) THEN
      XDBG = 0.5D0
      T6DBG = 1.0D0
      RDBG = 0.001D0
      IDBG = 1
      CALL ESAC (XDBG,ZTAB,T6DBG,RDBG,IDBG,IRAD,*999)
      ENDIF

        ILO=2
        IHI=MX
    8   IF(IHI-ILO .GT. 1) THEN
          IMD=(IHI+ILO)/2
            IF(X .LE. XA(IMD)+1.D-7) THEN
              IHI=IMD
            ELSE
              ILO=IMD
            ENDIF
          GO TO 8
        ENDIF
        MLO=ILO

        ILO=NT
        IHI=2
   11     IF(ILO-IHI .GT. 1) THEN
          IMD=(IHI+ILO)/2
           IF (T6 .EQ. T6LIST(1,IMD)) THEN
           ILO=IMD
           GO TO 14
           ENDIF
            IF(T6 .LE. T6LIST(1,IMD)) THEN
              IHI=IMD
            ELSE
              ILO=IMD
            ENDIF
          GO TO 11
          ENDIF
   14     KLO=ILO
      
      PMAX=XZ(MLO,1,KLO,NRA(KLO))*T6*RHO(NRA(KLO))+
     + IRAD*4.D0/3.D0*RAT*T6**4
      PMIN=XZ(MLO,1,KLO,1)*T6*RHO(1)+
     + IRAD*4.D0/3.D0*RAT*T6**4
      IF((PNR .GT. 1.25D0*PMAX) .OR. (PNR .LT. PMIN)) THEN
C      WRITE(ISHORT,'(" THE REQUESTED PRESSURE-TEMPERATURE NOT IN ",
C     *       "TABLE")')
C     STOP
C      WRITE(ISHORT,'("PNR, PMAX,PMIN=",3E14.4)') PNR,PMAX,PMIN
      GO TO 999
      ENDIF
      
      RHOG1=RHO(NRA(KLO))*PNR/PMAX
      CALL ESAC (X,ZTAB,T6,RHOG1,1,IRAD,*999)
      P1=EOS(1)
        IF(P1 .GT. PNR) THEN
          P2=P1
          RHOG2=RHOG1
          RHOG1=0.2D0*RHOG1
          IF(RHOG1 .LT. 1.D-14) RHOG1=1.D-14
          CALL ESAC (X,ZTAB,T6,RHOG1,1,IRAD,*999)
          P1=EOS(1)
        ELSE
          RHOG2=5.D0*RHOG1
C          IF(RHOG2 .GT. RHO(KLO)) RHOG2=RHO(KLO) ! Corrected below  llp 8/19/08
          IF(RHOG2 .GT. RHO(NRA(KLO))) RHOG2=RHO(NRA(KLO)) ! Had wrong pointer, see RHOG1= ten lines up
          CALL ESAC (X,ZTAB,T6,RHOG2,1,IRAD,*999)
          P2=EOS(1)
        ENDIF

      ICOUNT=0
    1 CONTINUE
      ICOUNT=ICOUNT+1
      RHOG3=RHOG1+(RHOG2-RHOG1)*(PNR-P1)/(P2-P1)
      CALL ESAC (X,ZTAB,T6,RHOG3,1,IRAD,*999)
      P3=EOS(1)
C      IF (ABS((P3-PNR)/PNR) .LT. 1.D-5) THEN
      IF (ABS((P3-PNR)/PNR) .LT. 0.5D-7) THEN
      RHOOFP=RHOG3
C      WRITE(ISHORT,*)RHOG3,P,PNR,P3
C      WRITE(ISHORT,*)X,ZTAB,T6,P,RHOG3,IORDER,IRAD
      RETURN
      ENDIF
      IF (P3 .GT. PNR) THEN
        RHOG2=RHOG3
        P2=P3
        IF (ICOUNT .LT. 11) GO TO 1
C        WRITE(ISHORT,'("NO CONVERGENCE AFTER 10 TRIES")')
        GOTO 999
C        STOP
      ELSE
        RHOG1=RHOG3
        P1=P3
        IF (ICOUNT .LT. 11) GO TO 1
C        WRITE(ISHORT,'("NO CONVERGENCE AFTER 10 TRIES")')
        GOTO 999
C        STOP
      ENDIF
  999 CONTINUE
      RHOOFP=-999.0D0
C      WRITE(ISHORT,'("FAIL TO FIND RHO")')
      RETURN
      END
