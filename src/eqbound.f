C MHP 8/98 SUBROUTINE TO CHECK IF POINT IS WITHIN
C OPAL EOS TABLE.
      SUBROUTINE EQBOUND(T,DL,DL0,FAC,LTAB,LRAMP)
      use params, only : mx, mv, nr => nreos, nt => nteos
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/A/  XZ(MX,MV,NT,NR),
     *T6LIST(NR,NT),RHO(NR),T6A(NT),ESK(NT,NR),ESK2(NT,NR),DFSX(MX),
     * DFS(NT),DFSR(NR),XA(MX),M,MF
      COMMON/RMPOPEOS/RMX(NT),KRA(NT),KT
      SAVE
      T6 = T*1.0D-6
C EXIT IF OUTSIDE TABLE IN RHO
      IF(DL.LT.-14D0 .OR. DL.GT.5.0D0)THEN
         GOTO 9999        ! Out of Table in density. Go to Error exit
      ENDIF
C FIND NEAREST TABLE ELEMENT IN T.
      IF(T6.LT.T6A(KT))THEN
         DO I = KT+1,NT
            IF(T6.GE.T6A(I))THEN
               KT = I - 1
               GOTO 10
            ENDIF
         END DO
         TT = T6A(NT)
C SR CALL SHOULD HAVE BEEN STOPPED OUTSIDE TABLE BOUNDS; STOP CODE
         WRITE(*,5)T6,TT,KT
  5      FORMAT(' ERROR IN OPAL EOS: OUTSIDE TABLE IN T6',2F10.6,I5)
         STOP
 10      CONTINUE
      ELSE
         DO I = KT,1,-1
            IF(T6.LE.T6A(I))THEN
               KT = I
               GOTO 20
            ENDIF
         END DO
         TT = T6A(1)
C SR CALL SHOULD HAVE BEEN STOPPED OUTSIDE TABLE BOUNDS; STOP CODE
         WRITE(*,5)T6,TT,KT
         STOP
 20      CONTINUE
      ENDIF
      FT = (T6 - T6A(KT+1))/(T6A(KT)-T6A(KT+1))
C DEFINE TABLE EDGE IN RHO BY LINEAR INTERPOLATION.
      DLIM = RMX(KT+1)
C      DLIM = RMX(KT+1)+FT*(RMX(KT)-RMX(KT+1))
      DLIM = LOG10(DLIM)
C DEFINE BEGINNING OF RAMP IN THE SAME FASHION -
C RAMP IS DEFINED AS ONE TABLE ELEMENT WIDE.
C      DLIM2 = RHO(KRA(KT+1)-1)+FT*(RHO(KRA(KT)-1)-
C     *        RHO(KRA(KT+1)-1))
      DLIM2 = RHO(KRA(KT+1)-1)
      DLIM2 = LOG10(DLIM2)
C CHECK IF WITHIN TABLE BOUNDS IN RHO
      IF(DL.GT.DLIM)THEN
C         WRITE(*,*)T6,DL,DLIM
         GOTO 9999     ! Out of table in density. Go to error exit
      ENDIF

C  If we get here, the point is in the table.
      LTAB = .TRUE.

C  Now we check if ramping is needed.
C  First we check if ramping in temperature is needed.
c      WRITE(*,911)DL,DLIM,DLIM2
c 911  FORMAT(3F11.4)
      IF(T6.LE.T6A(NT-1))THEN
         LRAMP = .TRUE.
         FAC = (T6-T6A(NT))/(T6A(NT-1)-T6A(NT))
      ELSE IF(T6.GE.T6A(2))THEN
         LRAMP = .TRUE.
         FAC = (T6A(1)-T6)/(T6A(1)-T6A(2))
      ELSE IF(DL.GE.DLIM2)THEN
C  If we get here, ramping in density is needed.
         LRAMP = .TRUE.
         FAC = (DLIM-DL)/(DLIM-DLIM2)
C         WRITE(*,912)DL,DL0,DLIM,DLIM2,FAC
C 912     format(' high rho ramp',5f9.6)
      ELSE
C        If we get here, we are in the middel of the table and
C        no ramping is needed.
         LRAMP = .FALSE.
      ENDIF

      RETURN

C Error Exit.
 9999 CONTINUE
      LTAB = .FALSE.       ! Not in table
      LRAMP = .TRUE.       ! Turn on ramping
      FAC = 0D0            ! Set ramping factor to zero
C                            This way, out of table results are ramped to zero.
      RETURN
      END
