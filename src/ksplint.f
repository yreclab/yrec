C$$$$$$
      SUBROUTINE KSPLINT(XA,YA,Y2A,X,Y)
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
            PRINT*, 'Ksplint failure'
            STOP
      ENDIF
C      IF(H.EQ.0D0) STOP 911
      A = (XA(KHI)-X)/H
      B = (X-XA(KLO))/H
      Y = A*YA(KLO)+B*YA(KHI)+
     *    ((A**3-A)*Y2A(KLO)+(B**3-B)*Y2A(KHI))*(H**2)/6.0D0
      RETURN
      END
