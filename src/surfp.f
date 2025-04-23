      SUBROUTINE SURFP(TEFFL,GL,LPRT)

      use params, only : nt, ng, ntc, ngc
      use settings, only : ISHORT, IOWR  ! COMMON/LUOUT/
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      CHARACTER*256 FATM

      COMMON/ATMPRT/TAU,AP,AT,AD,AO,AFXION(3)
      COMMON/ATMOS2/ATMPL(NT,NG),ATMTL(NT),
     *              ATMGL(NG),ATMZ,IOATM,FATM
      COMMON/FAC/IMIN(NT),IMINMAX(NT),JP,KP(4),IMIN2(NTC),IMINMAX2(NTC)
      DIMENSION QT(4),QG(4),PP(4),DUM(3),QGG(3),QS(3),PTAB(4),
     *          YT(4),YG(4)
      SAVE
C SURFPL INTERPOLATES IN TEMPERATURE USING A 4-POINT LAGRANGIAN
C INTERPOLATOR, AND INTERPOLATES IN GRAVITY THE SAME WAY IF 4 OR
C MORE POINTS ARE AVAILABLE.  IT WILL QUIT IF THE DESIRED DATA POINT
C HAS TEFF OR LOG G MORE THAN ONE TABLE POINT FROM THE DATA.
C
C CHECK TO ENSURE THAT DATA IS WITHIN TABLE.

      IF(TEFFL.LT.3.5D0 .OR. GL.LT.-0.5D0)THEN
         WRITE(IOWR,911)TEFFL,GL
         WRITE(ISHORT,911)TEFFL,GL
  911    FORMAT(1X,'DESIRED ATMOSPHERE OUTSIDE TABLE RANGE'/
     *          ' LOG TEFF',F10.6,' LOG G',F10.6/' RUN STOPPED')
         STOP
      ENDIF
C TEMPERATURE INTERPOLATION FACTORS.
      DO J = 1,NT
         IF(TEFFL.LE.ATMTL(J))GOTO 10
      END DO
      J = NT
   10 CONTINUE
      JJ = MAX(1,J-2)
      JJ = MIN(NT-3,JJ)
      DO K = 1,4
         QT(K) = ATMTL(JJ+K-1)
      END DO
C      CALL INTRP2(QR,QT,TEFFL)
      JP = JJ
C GRAVITY INTERPOLATION FACTORS.
      DO 20 J = JJ,JJ+3
         N = J-JJ+1
C CHECK IF 4 LOG VALUES AVAILABLE - OTHERWISE, USE 3 POINT LAGRANGIAN
C OR LINEAR INTERPOLATION.
         IF(ATMTL(J).GT.4.5D0)THEN
            IF(ATMTL(J).GT.4.55D0)THEN
C LINEAR INTERPOLATION
               FX = (GL-ATMGL(NG-1))/(ATMGL(NG)-ATMGL(NG-1))
               PP(N)=ATMPL(J,NG-1)+FX*(ATMPL(J,NG)-ATMPL(J,NG-1))
               KP(N) = NG-1
            ELSE
C 3-POINT LAGRANGIAN INTERPOLATION.
               DO K = 1,3
                  QS(K) = ATMGL(NG-3+K)
               END DO
               CALL INTER3(QS,QGG,DUM,GL)
               PP(N)=ATMPL(J,NG-2)*QGG(1)+ATMPL(J,NG-1)*QGG(2)+
     *               ATMPL(J,NG)*QGG(3)
               KP(N) = NG-2
            ENDIF
            GOTO 20
         ENDIF
         IF(GL.GE.ATMGL(NG-1))THEN
C DESIRED LOG G ABOVE SECOND TO TOP TABLE LOG G - USE TOP 4 LOG G VALUES.
            DO KK = 1,4
               QG(KK)=ATMGL(NG-4+KK)
               PTAB(KK) = ATMPL(J,NG-4+KK)
            END DO
C            CALL INTRP2(QR,QG,GL)
            CALL KSPLINE(QG,PTAB,YG)
            CALL KSPLINT(QG,PTAB,YG,GL,Y0)
C            PP(N) = ATMPL(J,NG-3)*QG(1)+ATMPL(J,NG-2)*QG(2)+
C     *              ATMPL(J,NG-1)*QG(3)+ATMPL(J,NG)*QG(4)
            PP(N) = Y0
            KP(N) = NG-3
            GOTO 20
         ENDIF
C GENERAL CASE - FIND 4 NEAREST POINTS IN GRAVITY THAT ARE IN THE TABLE.
C G Somers, I changed NG to IMINMAX in the next line. This prevents the
C code from using -999 to interpolate in some instances.
         DO K = IMINMAX(J)-3,IMIN(J),-1
            IF(GL.LT.ATMGL(K+2).AND.GL.GE.ATMGL(K+1))THEN
               KK = MAX(IMIN(J),K)
               KK = MIN(NG-3,KK)
               DO KKK = 1,4
                  QG(KKK) = ATMGL(KK+KKK-1)
                  PTAB(KKK) = ATMPL(J,KK+KKK-1)
               END DO
               CALL KSPLINE(QG,PTAB,YG)
               CALL KSPLINT(QG,PTAB,YG,GL,Y0)
               PP(N) = Y0
C               CALL INTRP2(QR,QG,GL)
C               PP(N) = ATMPL(J,KK)*QG(1)+ATMPL(J,KK+1)*QG(2)+
C     *                 ATMPL(J,KK+2)*QG(3)+ATMPL(J,KK+3)*QG(4)
               KP(N) = KK
               GOTO 20
            ENDIF
         END DO
C DESIRED LOG G BELOW 2ND TABLE ENTRY -USE FIRST 4 POINTS.
         DO K = 1,4
            QG(K) = ATMGL(K+IMIN(J)-1)
            PTAB(K) = ATMPL(J,K+IMIN(J)-1)
         END DO
         CALL KSPLINE(QG,PTAB,YG)
         CALL KSPLINT(QG,PTAB,YG,GL,Y0)
         PP(N) = Y0
C         CALL INTRP2(QR,QG,GL)
C         II = IMIN(J)
C         PP(N) = ATMPL(J,II)*QG(1)+ATMPL(J,II+1)*QG(2)+
C     *           ATMPL(J,II+2)*QG(3)+ATMPL(J,II+3)*QG(4)
         KP(N) = IMIN(J)
   20 CONTINUE
C INTERPOLATE IN TEMPERATURE TO FIND CORRECT LOG P.
      CALL KSPLINE(QT,PP,YT)
      CALL KSPLINT(QT,PP,YT,TEFFL,Y0)
C      AP = PP(1)*QT(1)+PP(2)*QT(2)+PP(3)*QT(3)+PP(4)*QT(4)
      AP = Y0
      AT = TEFFL
C WRITE OUT INFORMATION TO THE MODEL FILE.
      IF (LPRT) THEN
        WRITE(ISHORT,70)
        WRITE(ISTOR,70)
70      FORMAT('********PRESSURE AT T=TEFF INTERPOLATED FROM TABULATED'
     *         ,  ' VALUES********')
        WRITE(ISHORT,71) TEFFL,AP
        WRITE(ISTOR,71) TEFFL,AP
71      FORMAT(' ',20X,'LOG (Teff) =',F10.5,' LOG P =',F10.5)
      ENDIF
      RETURN
      END
