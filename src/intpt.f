C------------------------    GROUP: SR_P     -------------------------------
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C INTPT
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE INTPT(PL,TL,TDVAR,NTM,NRM,IVAR,TLOG,NT,NR,
     1                 VAR1,VAR2,Y,VAROUT)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION TDVAR(NTM,NRM,IVAR),TLOG(NTM),VAR1(IVAR,4),
     1          VAR2(IVAR,4),VAROUT(IVAR),Y(IVAR)
      DIMENSION IRM(4),IR(4,4),IT(4),XX(4)
C 10/13/26 MHP via Claude: removed the unused COMMON/NMLPAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      INTEGER*4 L
      SAVE
      DO 100 N=1,NT
         IF(TLOG(N).GE.TL) GOTO 101
         IT(1)=N
 100  CONTINUE
 101  IF(IT(1).GE.2) IT(1)=IT(1)-1
      ITMAX=NT-3
      IF(IT(1).GT.ITMAX) IT(1)=ITMAX
      DO 150 I=2,4
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C  150  IT(I)=IT(1)+I-1
         IT(I)=IT(1)+I-1
 150  CONTINUE
      DO 210 I=1,4
         IRM(I)=1
         INDT=IT(I)
         PMINI=TDVAR(INDT, 1,2)
         PMAXI=TDVAR(INDT,NR,2)
         IF(PL.GT.PMAXI) THEN
            RETURN
         END IF
         DO 200 M=1,NR
            IF(TDVAR(INDT,M,2).GE.PL) GOTO 201
            IRM(I)=M
 200     CONTINUE
 201     IF(IRM(I).GE.2) IRM(I)=IRM(I)-1
         IRMAX=NR-3
         IF(IRM(I).GT.IRMAX) IRM(I)=IRMAX
 210  CONTINUE
      DO 310 I=1,4
C KC 2025-05-30 fixed "Shared DO termination label"
C          DO 310 J=1,4
         DO 311 J=1,4
            IR(J,I)=IRM(I)+J-1
 311     CONTINUE
 310  CONTINUE
      DO 500 ILIR=1,4
         INDT=IT(ILIR)
         DO 400 I=1,4
            INDR=IR(I,ILIR)
            XX(I)=TDVAR(INDT,INDR,2)
 400     CONTINUE
         DO 410 I=1,4
            INDR=IR(I,ILIR)
C KC 2025-05-30 fixed "Shared DO termination label"
C             DO 410 IV=1,IVAR
            DO 411 IV=1,IVAR
               VAR1(IV,I)=TDVAR(INDT,INDR,IV)
 411        CONTINUE
 410     CONTINUE

         II=IVAR
         ID=IVAR
         NP=4
         L=1
         INTER=1
         CALL LIR(PL,XX,Y,VAR1,II,ID,NP,L,INTER)
         DO 420 IV=1,IVAR
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C  420     VAR2(IV,ILIR) = Y(IV)
            VAR2(IV,ILIR) = Y(IV)
 420     CONTINUE

 500  CONTINUE
      DO 600 I=1,4
         INDT=IT(I)
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C  600  XX(I) = TLOG(INDT)
         XX(I) = TLOG(INDT)
 600  CONTINUE

      II=IVAR
      ID=IVAR
      NP=4
      L=1
      INTER=1

      CALL LIR(TL,XX,VAROUT,VAR2,II,ID,NP,L,INTER)

      RETURN
      END
