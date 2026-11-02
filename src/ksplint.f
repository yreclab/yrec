C$$$$$$
      SUBROUTINE KSPLINT(XA,YA,Y2A,X,Y)
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
C 10/30/26 MHP via Claude
C code changed to USE IOUNITS_MOD for ISHORT, so the error stop below
C also reports to the .short file (issue 38).
      USE IOUNITS_MOD
      IMPLICIT NONE
      INTEGER K,KHI,KLO,NM
      PARAMETER(NM=4)
      REAL*8 XA(NM),YA(NM),Y2A(NM),X,Y,H,A,B
      SAVE
      KLO = 1
      KHI = NM
 1    CONTINUE
      IF(KHI-KLO.GT.1)THEN
         K = (KHI+KLO)/2
         IF(XA(K).GT.X)THEN
            KHI = K
         ELSE
            KLO = K
         ENDIF
         GOTO 1
      ENDIF
c      WRITE(*,*)KHI,KLO,XA(KHI),XA(KLO),X
      H = XA(KHI) - XA(KLO)
      IF(H.EQ.0D0) THEN
            WRITE(*,900)XA(KLO),X
            WRITE(ISHORT,900)XA(KLO),X
 900        FORMAT(' KSPLINT: TWO ABSCISSAE COINCIDE AT',1PE14.6,
     *             ' X',E14.6/' RUN STOPPED')
C 10/30/26 MHP via Claude: bare STOP -> STOP 1, the run-time error code (issue 38).
            STOP 1
      ENDIF
C      IF(H.EQ.0D0) STOP 911
      A = (XA(KHI)-X)/H
      B = (X-XA(KLO))/H
      Y = A*YA(KLO)+B*YA(KHI)+
     *    ((A**3-A)*Y2A(KLO)+(B**3-B)*Y2A(KHI))*(H**2)/6.0D0
      RETURN
      END
