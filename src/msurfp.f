      SUBROUTINE MSURFP(TEFFL,GL,LPRT)
C LMB 06/2026
C SIMILAR TO SURFP EXCEPT USES THE NEW MARCS
C TABLE SIZES AND APPROPRIATELY SIZED COMMON BLOCK


C PARAMETERS NT AND NG FOR TABULATED SURFACE PRESSURES.
      PARAMETER(NT=57,NG=11)
      PARAMETER(NTC=76,NGC=11) ! NTC/NGC FOR KURUCZ-CASTELLI ATM
C LMB 05/26 ADD NTM AND NGM FOR MARCS ATM
      PARAMETER(NTM=33,NGM=13)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C MHP 8/25 Removed file names from common block
C      CHARACTER*256 FATM

      COMMON/ATMPRT/TAU,AP,AT,AD,AO,AFXION(3)
C LMB 05/26
      COMMON/ATMOS2M/ATMPLM(NTM,NGM),ATMTLM(NTM),
     *              ATMGLM(NGM) ! ATMGLM = ATMosphere Gravity (Log), MARCS
C MHP 8/25 Removed file names from common block
C JMH 8/18/91
C      COMMON/ATMOS2/ATMPL(NT,NG),ATMTL(NT),
C     *              ATMGL(NG),ATMZ,IOATM,FATM
      COMMON/ATMOS2/ATMPL(NT,NG),ATMTL(NT),
     *              ATMGL(NG),ATMZ,IOATM
      COMMON/FAC/IMIN(NT),IMINMAX(NT),IMIN2(NTC),IMINMAX2(NTC),
     *              IMIN3(NTM),IMINMAX3(NTM)
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
      DIMENSION QT(4),QG(4),PP(4),DUM(3),QGG(3),QS(3),PTAB(4),
     *          YT(4),YG(4)
      SAVE
C MSURFP INTERPOLATES IN TEMPERATURE USING A 4-POINT LAGRANGIAN
C INTERPOLATOR, AND INTERPOLATES IN GRAVITY THE SAME WAY IF 4 OR
C MORE POINTS ARE AVAILABLE.  IT WILL QUIT IF THE DESIRED DATA POINT
C HAS TEFF OR LOG G MORE THAN ONE TABLE POINT FROM THE DATA.
C
C CHECK TO ENSURE THAT DATA IS WITHIN TABLE
      IF(TEFFL.LT.3.39D0 .OR. GL.LT.-0.5D0) THEN
         WRITE(IOWR,911)TEFFL,GL
         WRITE(ISHORT,911)TEFFL,GL
  911    FORMAT(1X,'DESIRED ATMOSPHERE OUTSIDE TABLE RANGE'/
     *          ' LOG TEFF',F10.6,' LOG G',F10.6/' RUN STOPPED')
         STOP
      ENDIF

C LMB: For some reason, IMIN3 gets modified between setups.f and msurfp.f
C This was causing errors by setting the first 5 values of IMIN3 = 0
C So if IMIN3(1) == 0, re-find the IMIN3 and IMINMAX3 values
      IF (IMIN3(1).EQ.0) THEN
         DO J = 1,NTM
            LCATCH = .FALSE.
            DO K = NGM,1,-1
               IF(ATMPLM(J,K).LE.0.0D0)THEN
                  IF(LCATCH)THEN
                     IMIN3(J) = K + 1  ! IMIN3 records the lowest logg with a pressure
                     GOTO 7
                  ENDIF
               ELSE
                  IF(.NOT.LCATCH) IMINMAX3(J) = K ! record the highest gravity with a pressure 
                  LCATCH = .TRUE. ! at non-negative pressure value, turn off the catch so IMIN3 can be set.  
               ENDIF
            END DO
            IMIN3(J) = 1
   7         CONTINUE
            IF(.NOT.LCATCH) IMIN3(J) = NGM ! if all P values at a given T are -999, set IMIN3  to the number of gravity terms. This will make the code break.
         END DO
      END IF

C TEMPERATURE INTERPOLATION INDICES: QT
      DO J = 1,NTM
         IF(TEFFL.LE.ATMTLM(J))GOTO 10
      END DO
      J = NTM ! finds largest index i at which Teff <= ATMTL(i)
   10 CONTINUE
      JJ = MAX(1,J-2) ! prevent interp. from reaching outside table on the lower end 
      JJ = MIN(NTM-3,JJ) ! prevent interp. from reaching outside table on the upper end
      DO K = 1,4
         QT(K) = ATMTLM(JJ+K-1)
      END DO
      ! Check if LOGG is outside of the uneven edges of the grid:
      IF(GL.GT.ATMGLM(IMINMAX3(JJ)) .OR. GL.LT.ATMGLM(IMIN3(JJ)))THEN
         WRITE(IOWR,912)GL,TEFFL,ATMGLM(IMIN3(JJ)),ATMGLM(IMINMAX3(JJ))
         WRITE(ISHORT,912)GL,TEFFL,ATMGLM(IMIN3(JJ)),ATMGLM(IMINMAX3(JJ))
  912    FORMAT(1X,'DESIRED ATMOSPHERE LOGG OF', F10.6,' IS OUTSIDE TABLE RANGE AT'/
     *          ' LOG TEFF',F10.6,': RANGE IS',F10.6, 'TO',F10.6/' RUN STOPPED')
         STOP
      ENDIF
C GRAVITY INTERPOLATION FACTORS.
      DO 20 J = JJ,JJ+3
         N = J-JJ+1 ! index
C CHECK IF 4 LOGT VALUES AVAILABLE - OTHERWISE, USE 3 POINT LAGRANGIAN
C OR LINEAR INTERPOLATION.
         IF(ATMTLM(J).GT.3.87D0)THEN
            IF(ATMTLM(J).GT.3.89D0)THEN
C LINEAR INTERPOLATION
               FX = (GL-ATMGLM(NGM-1))/(ATMGLM(NGM)-ATMGLM(NGM-1))
               PP(N)=ATMPLM(J,NGM-1)+FX*(ATMPLM(J,NGM)-ATMPLM(J,NGM-1))
            ELSE
C 3-POINT LAGRANGIAN INTERPOLATION.
               DO K = 1,3
                  QS(K) = ATMGLM(NGM-3+K)
               END DO
               CALL INTER3(QS,QGG,DUM,GL)
               PP(N)=ATMPLM(J,NGM-2)*QGG(1)+ATMPLM(J,NGM-1)*QGG(2)+
     *               ATMPLM(J,NGM)*QGG(3)
            ENDIF
            GOTO 20
         ENDIF
         IF(GL.GE.ATMGLM((IMINMAX3(J)-1)))THEN
C DESIRED LOG G ABOVE SECOND TO TOP TABLE LOG G - USE TOP 4 LOG G VALUES.
            DO KK = 1,4
               QG(KK)=ATMGLM(IMINMAX3(J)-4+KK) !QG is the logg values for interpolation
               PTAB(KK) = ATMPLM(J,IMINMAX3(J)-4+KK) ! PTAB is the pressures for interpolation
            END DO
            CALL KSPLINE(QG,PTAB,YG)
            CALL KSPLINT(QG,PTAB,YG,GL,Y0)
            PP(N) = Y0
            GOTO 20
         ENDIF
C GENERAL CASE - FIND 4 NEAREST POINTS IN GRAVITY THAT ARE IN THE TABLE.
C G Somers changed NG to IMINMAX in the next line. This prevents the
C code from using -999 to interpolate in some instances.
         DO K = IMINMAX3(J)-3,IMIN3(J),-1
            ! check if logg is below the 2nd highest
            ! and above the 2nd lowest
            IF(GL.LT.ATMGLM(K+2).AND.GL.GE.ATMGLM(K+1))THEN 
               DO KK = 1,4
                  QG(KK) = ATMGLM(K+KK-1)
                  PTAB(KK) = ATMPLM(J,K+KK-1)
               END DO
               CALL KSPLINE(QG,PTAB,YG)
!                IF(GL .LE. 0.505) THEN
!                   WRITE(IOWR,913)QG(1),ATMTLM(J),PTAB(1),PTAB(2),PTAB(3),PTAB(4)
!   913              FORMAT(1X,'LOGG(1)', F10.2,' TEFFL',F10.2,' PTAB',F10.2,F10.2,F10.2,F10.2)
!                ENDIF
               CALL KSPLINT(QG,PTAB,YG,GL,Y0)
               PP(N) = Y0
               GOTO 20
            ENDIF
         END DO
C DESIRED LOG G BELOW 2ND LOWEST TABLE ENTRY - USE FIRST 4 POINTS.
         DO K = 1,4
            QG(K) = ATMGLM(K+IMIN3(J)-1)
            PTAB(K) = ATMPLM(J,K+IMIN3(J)-1)
         END DO
         CALL KSPLINE(QG,PTAB,YG)
!          IF(GL .LE. 0.505) THEN
!             WRITE(IOWR,913)QG(1),TEFFL,PTAB(1),PTAB(2),PTAB(3),PTAB(4)
!   913       FORMAT(1X,'LOGG', F10.2,' TEFFL',F10.2,' PTAB',F10.2,F10.2, F10.2,F10.2)
!          ENDIF
         CALL KSPLINT(QG,PTAB,YG,GL,Y0)
         PP(N) = Y0
   20 CONTINUE
C INTERPOLATE IN TEMPERATURE TO FIND CORRECT LOG P.
      CALL KSPLINE(QT,PP,YT)
      CALL KSPLINT(QT,PP,YT,TEFFL,Y0)
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
