

C*************************************************************************
      SUBROUTINE ESAC (XH,ZTAB,T6,R,IORDER,IRAD,*)
      use params, only : mx, mv, nr => nreos, nt => nteos
      use settings, only : ISHORT  ! COMMON/LUOUT/

      IMPLICIT REAL*8 (A-H,O-Z)

C..... THE PURPOSE OF THIS SUBROUTINE IS TO INTERPOLATE
C      THE EQUATION OF STATE AND ITS DERIVATIVES IN X, T6, DENSITY
C        IZI=0 RECALULATE TABLE INDICES TO USE; =1 KEEP PREVIOUS

C        XH=HYDROGEN MASS FRACTION
C        ZTAB IS METAL FRACTION OF THE EOSDATA TABLES YOU ARE USING.
C           INCLUDED ONLY FOR PURPOSE OF PREVENTING MISMATCH
C        T6=T6=TEMPERATURE IN MILLIONS OF DEGREES KELVIN
C        R=RHO=RHO=DENSITY(G/CM**3)
C..... TO USE ESAC INSERT COMMON/E/ ESACT,EOS(10) IN THE CALLING ROUTINE.
C      THIS COMMON CONTAINS THE INTERPOLATED EOS VALUES FOR THE EOS
C
C..... EOS(I) ARE OBTAINED FROM A QUADRADIC INTERPOLATION AT
C      FIXED T6 AT THREE VALUES OF RHO; FOLLOWED BY QUADRATIC
C      INTERPOLATION ALONG T6. RESULTS SMOOTHED BY MIXING
C      OVERLAPPING QUADRATICS.
C         DEFINITIONS:
C
C            T6 IS THE TEMPERATURE IN UNITS OF 10**6 K
C
C            RHO IS THE DENSITY IN GRAMS/CC
C            R=RHO/T6**3

C            EOS(1) IS THE PRESSURE IN MEGABARS (10**12DYNE/CM**2)
C YCK NO USE EOS(2) IS ENERGY IN 10**12 ERGS/GM. ZERO IS ZERO T6
C YCK NO USE EOS(3) IS THE ENTROPY IN UNITS OF ENERGY/T6
C YCK NO USE EOS(4) IS DE/DRHO AT CONSTANT T6
C            EOS(5) IS THE SPECIFIC HEAT, DE/DT6 AT CONSTANT V.
C            EOS(6) IS DLOGP/DLOGRHO AT CONSTANT T6.
C                   COX AND GUIL1 EQ 9.82
C            EOS(7) IS DLOGP/DLOGT6 AT CONXTANT RHO.
C                   COX AND GUIL1 EQ 9.81
C            EOS(8) IS GAMMA1. EQS. 9.88 COX AND GUILI.
C            EOS(9) IS GAMMA2/(GAAMMA2-1). EQS. 9.88 COX AND GUILI
C            EOS(10) IS GAMMA3-1. EQS 9.88 COX AND GUILI

C            IORDER SETS MAXIMUM INDEX FOR EOS(I);I.E., IORDER=1
C                   GIVES JUST THE PRESSURE
C
C            IRAD  IF =0 NO RADIATION CORRECTION; IF =1 ADDS RADIATION

C            INDEX(I),I=1,10  SETS ORDER IN WHICH THE EQUATION OF STATE
C            VARIABLES ARE STORED IN EOS(I).  ABOVE ORDER CORRESPONDS
C            TO BLOCK DATA STATEMENT:
C                 DATA (INDEX(I),I=1,10)/1,2,3,4,5,6,7,8,9,10/.
C            IF YOU, FOR EXAMPLE, ONLY WANT TO RETURN GAMMA1: SET IORDER=1
C            AND SET: DATA (INDEX(I),I=1,10)/8,2,3,4,5,6,7,1,9,10/
C
C
      SAVE
      REAL*8 MOLES
      CHARACTER BLANK*1
      COMMON/LREADCO/ITIME
      COMMON/EE/ EPL(MX,NT,NR),XX(MX)
      COMMON/AA/ Q(4),H(4),XXH
      COMMON/A/  XZ(MX,MV,NT,NR),
     .T6LIST(NR,NT),RHO(NR),T6A(NT),ESK(NT,NR),ESK2(NT,NR),DFSX(MX),
     . DFS(NT),DFSR(NR),XA(MX),M,MF
      COMMON/B/ ZZ(MX),IRI(10),INDEX(10),NTA(NR)
      COMMON/BB/L1,L2,L3,L4,K1,K2,K3,K4,IP,IQ
      COMMON/E/ ESACT,EOS(MV)
      DIMENSION FRAC(7)
      DATA APROP/83.1446304D0/

      BLANK=' '
      IF (IORDER .GT. 10 ) THEN
         WRITE(ISHORT,'(" IORDER CANNOT EXCEED 10")')
      ENDIF
      IF ((IRAD .NE. 0) .AND. (IRAD .NE. 1)) THEN
         WRITE(ISHORT,'(" IRAD MUST BE 0 OR 1")')
         STOP
      ENDIF

      XXI=XH
      RI=R

      SLT=T6
      SLR=R

      IF(ITIME .NE. 12345678) THEN
        ITIME=12345678
        DO I=1,10
          DO J=1,10
            IF  (INDEX(I) .EQ. J) IRI(I)=J
          ENDDO
        ENDDO
        DO  I=1,MX
          XX(I)=XA(I)
        ENDDO
C
C..... READ THE DATA FILES
        CALL READCO
        Z=ZZ(1)

        IF(Z+XH-1.D-6 .GT. 1.0D0 ) GO TO 61
      ENDIF
C
C
C..... DETERMINE T6,RHO GRID POINTS TO USE IN THE
C      INTERPOLATION.
      IF((SLT .GT. T6A(1)).OR.(SLT .LT. T6A(NT))) GO TO 62
      IF((SLR .LT. RHO(1)).OR.(SLR .GT. RHO(NR))) GO TO 62
C
C
C
        ILO=2
        IHI=MX
    8   IF(IHI-ILO .GT. 1) THEN
          IMD=(IHI+ILO)/2
            IF(XH .LE. XA(IMD)+1.D-7) THEN
              IHI=IMD
            ELSE
              ILO=IMD
            ENDIF
          GO TO 8
        ENDIF
        I=IHI
        MF=I-2
        MG=I-1
        MH=I
        MI=I+1
        MF2=MI
        IF (XH .LT. 1.D-6) THEN
        MH=1
        MH=1
        MG=1
        MI=2
        MF2=1
        ENDIF
        IF((XH .LE. XA(2)+1.D-7) .OR. (XH .GE. XA(MX-2)-1.D-7)) MF2=MH
C
        ILO=2
        IHI=NR
   12     IF(IHI-ILO .GT. 1) THEN
          IMD=(IHI+ILO)/2
           IF (SLR .EQ. RHO(IMD)) THEN
           IHI=IMD
           GO TO 13
           ENDIF
            IF(SLR .LE. RHO(IMD)) THEN
              IHI=IMD
            ELSE
              ILO=IMD
            ENDIF
          GO TO 12
          ENDIF
   13     I=IHI
        L1=I-2
        L2=I-1
        L3=I
        L4=L3+1
C
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
   14     I=ILO
        K1=I-2
        K2=I-1
        K3=I
        K4=K3+1
      IF (K3 .EQ. 0) THEN
      WRITE(ISHORT,'(" IHI,ILO,IMD",3I5)')
      ENDIF


C     CHECK TO DETERMINE IF INTERPOLATION INDICES FALL WITHIN
C     TABLE BOUNDARIES.  CHOOSE LARGEST ALLOWED SIZE.
      SUM1=0.0D0
      SUM2=0.0D0
      SUM23=0.0D0
      SUM33=0.0D0
      DO M=MF,MF+3
        DO IR=L1,L1+1
          DO IT=K1,K1+1
            SUM1=SUM1+XZ(M,1,IT,IR)
          ENDDO
        ENDDO
        DO IR=L1,L1+2
          DO IT=K1,K1+2
            SUM2=SUM2+XZ(M,1,IT,IR)
          ENDDO
        ENDDO
        DO IR=L1,L1+2
          DO IT=K1,K1+3
            SUM23=SUM23+XZ(M,1,IT,IR)
          ENDDO
        ENDDO
        DO IR=L1,L1+3
          DO IT=K1,K1+3
            SUM33=SUM33+XZ(M,1,IT,IR)
          ENDDO
        ENDDO
      ENDDO
      IQ=2
      IP=2
      IF (SUM2 .GT. 1.D+30) THEN
        IF (SUM1 .LT. 1.D+25 ) THEN
          K1=K3-3
          K2=K1+1
          K3=K2+1
          L1=L3-3
          L2=L1+1
          L3=L2+1
          GO TO 15
            ELSE
          GO TO 65
        ENDIF
      ENDIF
      IF (SUM23 .LT. 1.D+30) IP=3
      IF (SUM33 .LT. 1.D+30) IQ=3

      IF(T6 .GE. T6LIST(1,2)+1.D-7) IP=2
      IF(SLR .LE. RHO(2)+1.D-15) IQ=2

      IF(L3 .EQ. NR) IQ=2

   15 CONTINUE
      DO 124 IV=1,IORDER
      DO 123 M=MF,MF2

      IS=0

C__________
      DO IR=L1,L1+IQ
        DO IT=K1,K1+IP
        EPL(M,IT,IR)=XZ(M,IV,IT,IR)
        IS=1
        ENDDO
      ENDDO
  123 CONTINUE
      IF((ZZ(MG) .NE. ZZ(MF)) .OR. (ZZ(MH) .NE. ZZ(MF))) THEN
        WRITE(ISHORT,'("Z DOES NOT MATCH Z IN EOSDATA FILES YOU ARE"
     X ," USING")')
        STOP
      ENDIF
      IF(Z .NE. ZZ(MF)) GO TO 66
      IS=0
      IW=1
      DO 45 IR=L1,L1+IQ
        DO IT=K1,K1+IP
          IF (MF2 .EQ. 1) THEN
          ESK(IT,IR)=EPL(MF,IT,IR)
          GO TO 46
          ENDIF
          ESK(IT,IR)=QUAD(IS,IW,XH,EPL(MF,IT,IR),EPL(MG,IT,IR)
     X    ,EPL(MH,IT,IR),XX(MF),XX(MG),XX(MH))
          IF(ESK(IT,IR) .GT. 1.D+20) THEN
          WRITE(ISHORT,'(" PROBLEM IT IR,L3,K3,IQ,IP=", 6I5)') IT,IR
     X    ,L3,K3,IQ,IP
          WRITE(ISHORT,'(3E12.4)')  (EPL(MS,IT,IR),MS=MF,MF+2)
          ENDIF
          IS=1
   46     CONTINUE
        ENDDO
   45 CONTINUE

      IF (MI .EQ. MF2) THEN  ! INTERPOLATE BETWEEN QUADRATICS
      IS=0
      IW=1
       DIXR=(XX(MH)-XH)*DFSX(MH)
      DO 47 IR=L1,L1+IQ
        DO IT=K1,K1+IP
          ESK2(IT,IR)=QUAD(IS,IW,XH,EPL(MG,IT,IR),EPL(MH,IT,IR)
     X    ,EPL(MI,IT,IR),XX(MG),XX(MH),XX(MI))
          IF(ESK(IT,IR) .GT. 1.D+20) THEN
          WRITE(ISHORT,'(" PROBLEM IT IR,L3,K3,IQ,IP=", 6I5)') IT,IR
     X    ,L3,K3,IQ,IP
          WRITE(ISHORT,'(3E12.4)')  (EPL(MS,IT,IR),MS=MG,MG+2)
          ENDIF
          ESK(IT,IR)=ESK(IT,IR)*DIXR+ESK2(IT,IR)*(1.D0-DIXR)
          IS=1
        ENDDO
   47 CONTINUE


      ENDIF

      IS=0
C
C..... COMPLETED X INTERPOLATION. NOW INTERPOLATE T6 AND RHO ON A
C      4X4 GRID. (T6A(I),I=I1,I1+3),RHO(J),J=J1,J1+3)).PROCEDURE
C      MIXES OVERLAPPING QUADRATICS TO OBTAIN SMOOTHED DERIVATIVES.
C
C
      CALL T6RINTERP(SLR,SLT)
      EOS(IV)=ESACT
  124 CONTINUE

      P0=T6*R
      EOS(IRI(1))=EOS(IRI(1))*P0   ! INTERPOLATED IN P/PO
      EOS(IRI(2))=EOS(IRI(2))*T6   ! INTERPOLATED IN E/T6
C YCK >    EOS(IRI(4))=EOS(IRI(4))/SQRT(R*T6) ! INTERP DE/DR/SQRT(R/T6)
      TMASS=GMASS(XH,Z,MOLES,EGROUND,FRACZ,FRAC)
      IF (IRAD .EQ. 1) THEN
      CALL RADSUB (T6,R,MOLES,TMASS)
      ELSE
      EOS(IRI(5))=EOS(IRI(5))*MOLES*APROP/TMASS
      ENDIF
      RETURN

   61 WRITE(ISHORT,'(" MASS FRACTIONS EXCEED UNITY (61)")')
      WRITE(ISHORT,*)Z, XH
      STOP
   62 WRITE(ISHORT,'(" T6/LOGR OUTSIDE OF TABLE RANGE (62)")')
      WRITE(ISHORT,*)T6A(1), SLT, T6A(NT)
      WRITE(ISHORT,*) RHO(1),SLR, RHO(NR)
      RETURN 1

   65 WRITE(ISHORT,'("T6/LOG RHO IN EMPTY REGION OF TABLE (65)")')
      WRITE(ISHORT,'("XH,T6,R=", 3E12.4)') XH,T6,R
      RETURN 1

   66 WRITE(ISHORT,'(" Z DOES NOT MATCH Z IN EOSDATA* FILES YOU ARE",
     . " USING (66)")')
      WRITE(ISHORT,'("MF,ZZ(MF)=",I5,E12.4)') MF,ZZ(MF)
      WRITE(ISHORT,'("  IQ,IP,K3,L3,XH,T6,R,Z= ",4I5,4E12.4)')
     X IP,IQ,K3,L3,XH,T6,R,Z
      STOP

      END
