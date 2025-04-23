C$$$$$$
      SUBROUTINE TAUCAL(HCOMP,HS2,HS1,LCZ,HR,HP,HD,HG,M,SVEL,DEL1,DEL2,MINT)
      use params, only : json
      use parmin90, only : CMSUN  ! COMMON/CONST/
      use parmin90, only : CLN  ! COMMON/CONST1/
      use parmin90, only : CGL  ! COMMON/CONST2/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      INTEGER*4 IMAX
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
	COMMON/DEUTER/DRATE(JSON),DRATE0(JSON),FMASSACC,JCZ
      COMMON/ROT/WNEW,WALPCZ,ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW
C G Somers 3/17, ADDING NEW TAUCZ COMMON BLOCK
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
      DIMENSION HCOMP(15,JSON),HS2(JSON),LCZ(JSON),
     *     XSUM(15), HR(JSON), HP(JSON), HD(JSON), HG(JSON), HS1(JSON),
     *     DEL1(JSON), DEL2(JSON), SVEL(JSON)  
      SAVE



C JVS 02/12 CALCULATE THE LOCAL CONVECTIVE OVERTURN TIMESCALE AT THE BASE 
C OF THE CZ. IN OLDER VERSIONS THIS WAS ONLY DONE FOR ROTATING MODELS; 
C THIS MAKES IT SO TAUCZ IS CALCULATED FOR ALL MODELS. THIS PARTICULAR SUBROUTINE
C DOES CALCULATES THE OVERTURN TIMESCALES IN MODELS WHERE THE CZ IS WITHIN
C THE ENVELOPE

C THIS CODE SNAGGED FROM MIDMOD

C  DETERMINE EXTENT OF SURFACE CONVECTION ZONE.
      LALLCZ = .FALSE.
C JVS Allows the last point to be stable.
C JVS 05/14 removed requirement for last point to be convective, since this routine
C is only called from ENVINT, the near surface points in the envelope are often 
C radiative, despite the fact that a convective envelope exists. Code now checks
C to make sure there is a CZ somewhere in the envelope.
C      IF(LCZ(M) .OR. LCZ(M-1) .OR. LCZ(M-2))THEN



C  SURFACE C.Z. EXISTS.  FIND LOWEST SHELL (IMAX), WHICH IS ALSO THE 
C  UPPERMOST ZONE CONSIDERED FOR STABILITY AGAINST ROTATIONALLY INDUCED MIXING.
C         DO 71 I = M-1,1,-1
C            IF(.NOT.LCZ(I)) GOTO 81
C   71    CONTINUE
C         LALLCZ = .TRUE.
C         I = 0
C   81    IMAX = I + 1

C DEAL THE POSSIBILITY OF TWO OR MORE SURFACE CONVECTION ZONES IN THE ENVELOPE
	  LFLAG = .FALSE.
	  LTWOCZ = .FALSE.
	  LCZEX = .FALSE. ! Flag for the existence of a CZ
        DO 71 I = M-1,1,-1
            IF(.NOT.LCZ(I) .AND. .NOT. LFLAG .AND. LCZEX) THEN ! EXITING CZ
			IMAX = I+1
			LFLAG = .TRUE.  
		ELSE IF (LFLAG .AND. LCZ(I)) THEN ! TWO CZS WITH RADIATIVE ZONE BETWEEN
			LFLAG = .FALSE.
			LTWOCZ = .TRUE.
			ICZTOP = I
		ELSE IF( LCZ(I) .AND. .NOT. LCZEX) THEN !First convective point from surface
			LCZEX = .TRUE.
		ENDIF
   71    CONTINUE
	   IF(IMAX .LT. 1)THEN 
	        LALLCZ = .TRUE.
	   ENDIF     

      IF(LCZEX) THEN ! REPLACES "IF(LCZ(M)" THEN JVS 05/14	


C  HSTOP IS THE MASS AT THE TOP OF THE C.Z.
C  HSBOT IS THE MASS AT THE BOTTOM OF THE C.Z.
         HSTOP = HS1(M)
         IF(IMAX.GT.1)THEN
            HSBOT = 0.5D0*(HS1(IMAX)+HS1(IMAX-1))
         ELSE
            HSBOT = HS1(1)
         ENDIF
C  LCZSUR=T IF A SURFACE C.Z.DEEP ENOUGH FOR ANGULAR MOMENTUM LOSS EXISTS
         IF((HSTOP-HSBOT)/CMSUN.GT.0.0D0)THEN
            LCZSUR = .TRUE.
         ELSE
            LCZSUR= .FALSE.
         ENDIF
      ELSE
C  NO SURFACE C.Z.
         IMAX = M
         LCZSUR = .FALSE.
      ENDIF

C JVS 10/11/13 Concerned that this is inappropriate for LCZSUR = FALSE. 
C Should never be the case, but removed it.
C      IF(LCZSUR)THEN
         IF(.NOT.LALLCZ)THEN
            IF(.NOT.LROT)THEN
               HG(IMAX)=HS1(IMAX)*EXP(CLN*(CGL-2.0D0*HR(IMAX)))
               HG(IMAX-1)=HS1(IMAX-1)*EXP(CLN*(CGL-2.0D0*HR(IMAX-1)))
            ENDIF
C PINPOINT RCZ
            DD2 = DEL1(IMAX-1)-DEL2(IMAX-1)
            DD1 = DEL1(IMAX)-DEL2(IMAX)
            FX = DD2/(DD2-DD1)
C INFER HP
            ENVRL = HR(IMAX-1)+FX*(HR(IMAX)-HR(IMAX-1))
            ENVR = EXP(CLN*ENVRL)
            PS2 = EXP(CLN*(HP(IMAX)-HD(IMAX)))/HG(IMAX)
            PS1 = EXP(CLN*(HP(IMAX-1)-HD(IMAX-1)))/HG(IMAX-1)
            PSCA = PS1 + FX*(PS2-PS1)
            RTESTL = DLOG10(ENVR+PSCA)
C JVS 03/14 WHEN THERE ARE TWO CZS, THE DEEPER ONE CAN BE ~HP THICK. IN 
C THIS CASE, WE"LL WANT AND AVERAGE CONVECTIVE VELOCITY ACROSS THE REGION
C--------------------------------------------------------------
		TOL = 0.5
C		IF(ABS(1.0 - ((DEXP(CLN*(RTESTL-HR(IMAX))) - 1.0)/
C     *         (DEXP(CLN*(HR(ICZTOP)-HR(IMAX))) - 1.0))) .LT. TOL
C     *          .AND. LTWOCZ) THEN
		IF((ABS(1.0 - ((DEXP(CLN*(RTESTL-HR(IMAX))) - 1.0)/
     *         (DEXP(CLN*(HR(ICZTOP)-HR(IMAX))) - 1.0))) .LT. TOL) .OR. LTWOCZ) THEN
			! TAKE AVERAGE CONV VELOCITY
			CVEAVG = 0.0
C			DENOM = ABS(HS1(ICZTOP)-HS1(IMAX))/DEXP(CLN*STOTAL) ! MASS IN CZ 
			DENOM = 0.0
			UMER = 0.0
			CZWIDE = ABS(DEXP(CLN*HR(ICZTOP))-DEXP(CLN*HR(IMAX))) 			
			DO J=IMAX,ICZTOP,1
				DENOM = DENOM + HS2(J)
				UMER = UMER+ 0.5d0*(SVEL(J)+SVEL(J+1))*HS2(J)
			ENDDO
			CVEAVG = UMER/DENOM
			TAUCZ = CZWIDE/CVEAVG
		ELSE  
C 		(ORIGINAL ROUTINE)
C 		FIND V
           	      DO K = IMAX+1,M
               		IF(HR(K).GT.RTESTL)THEN
                 	   		FX = (RTESTL-HR(K-1))/(HR(K)-HR(K-1))
                 	   		CVEL = SVEL(K-1)+FX*(SVEL(K)-SVEL(K-1))
                 	   		GOTO 85
               		ENDIF
              	END DO
              	CVEL = SVEL(M)
 85          	CONTINUE
C            	DEFINE TAUCZ
            	TAUCZ = PSCA/CVEL
		ENDIF

C JVS 10/11/13
C         ELSE
CC INFER HP
C            IF(.NOT.LROT)THEN
C               HG(1)=HS1(1)*EXP(CLN*(CGL-2.0D0*HR(1)))
C            ENDIF
C            PSCA2 = EXP(CLN*(HP(1)-HD(1)))/HG(1)
C            RTEST2 = EXP(CLN*HR(1))
C            IF(PSCA2.LE.RTEST2)THEN
CC HP < R AT THE FIRST POINT.  ASSUME V CONSTANT INSIDE AND HP = K/R FOR
CC SLOWLY VARYING DENSITY AND PRESSURE NEAR THE CENTER.
C               CVEL = SVEL(1)
C               PSCA = (PSCA2*RTEST2)**0.5D0
C               TAUCZ = PSCA/CVEL
C            ELSE
C               DO K = 2,M
C                  PSCA1 = PSCA2
C                  RTEST1 = RTEST2
C                  IF(.NOT.LROT)THEN
C                     HG(K)=HS1(K)*EXP(CLN*(CGL-2.0D0*HR(K)))
C                  ENDIF
C                  PSCA2 = EXP(CLN*(HP(K)-HD(K)))/HG(K)
C                  RTEST2 = EXP(CLN*HR(K))
CC FIND LOCATION WHERE HP = R
C                  IF(PSCA2.LE.RTEST2)THEN
C                     FX = (RTEST1-PSCA1)/((PSCA2-RTEST2)-(PSCA1-RTEST1))
CC FIND V
C                     CVEL = SVEL(K-1)+FX*(SVEL(K)-SVEL(K-1))
C                     PSCA = PSCA1+FX*(PSCA2-PSCA1)
CC DEFINE TAUCZ
C                     TAUCZ = PSCA/CVEL
C                     GOTO 95
C                  ENDIF
C               END DO
C               K = M
C               CVEL = SVEL(M)
C               PSCA = PSCA2
C               TAUCZ = PSCA/CVEL
C 95            CONTINUE
C            ENDIF
C         ENDIF
      ELSE
         TAUCZ = 0.0D0
      ENDIF
	print*, 'TauCal'

C END JVS

      RETURN
      END
