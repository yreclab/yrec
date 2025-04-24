C$$$$$$
      SUBROUTINE TAUINT(HCOMP,HS2,HS1,LCZ,HR,HP,HD,HG,M,SVEL,DEL1,DEL2)
      use params, only : json
      use settings, only : CMSUN  ! /CONST/
      use settings, only : CLN  ! /CONST1/
      use settings, only : CGL  ! /CONST2/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/DEUTER/DRATE(JSON),DRATE0(JSON),FMASSACC,JCZ
      COMMON/ROT/WNEW,WALPCZ,ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW
      COMMON/JTEST/ IMAX1, IMAX2, LJVS
C Needs access to this common block: grants knowledge of envellope
      COMMON/ENVSTRUCT/ENVP(JSON),ENVT(JSON),ENVS(JSON),ENVD(JSON),
     *                 ENVR(JSON),ENVX(JSON),ENVZ(JSON),LCENV(JSON),
     *                 NUMENV,EDELS(3,JSON),EVELS(JSON)
C G Somers 3/17, ADDING NEW TAUCZ COMMON BLOCK
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
      DIMENSION HCOMP(15,JSON),HS2(JSON),LCZ(JSON),
     *     XSUM(15), HR(JSON), HP(JSON), HD(JSON), HG(JSON), HS1(JSON),
     *     DEL1(JSON), DEL2(JSON), SVEL(JSON)
      SAVE


C JVS 02/12 CALCULATE THE LOCAL CONVECTIVE OVERTURN TIMESCALE AT THE BASE
C OF THE CZ. IN OLDER VERSIONS THIS WAS ONLY DONE FOR ROTATING MODELS;
C THIS MAKES IT SO TAUCZ IS CALCULATED FOR ALL MODELS.
C THIS CODE SNAGGED FROM MIDMOD
C  DETERMINE EXTENT OF SURFACE CONVECTION ZONE.
      LALLCZ = .FALSE.
C JVS Allows the last point to be stable.
      IF(LCZ(M) .OR. LCZ(M-1))THEN
C  SURFACE C.Z. EXISTS.  FIND LOWEST SHELL (IMAX), WHICH IS ALSO THE
C  UPPERMOST ZONE CONSIDERED FOR STABILITY AGAINST ROTATIONALLY INDUCED MIXING.
         DO 71 I = M-1,1,-1
            IF(.NOT.LCZ(I)) GOTO 81
   71    CONTINUE
         LALLCZ = .TRUE.
         I = 0
   81    IMAX = I + 1
C  HSTOP IS THE MASS AT THE TOP OF THE C.Z.
C  HSBOT IS THE MASS AT THE BOTTOM OF THE C.Z.
         HSTOP = HS1(M)
         IF(IMAX.GT.1)THEN
            HSBOT = 0.5D0*(HS1(IMAX)+HS1(IMAX-1))
         ELSE
            HSBOT = 0.0D0
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

      IF(LCZSUR)THEN
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
            ENVRCL = HR(IMAX-1)+FX*(HR(IMAX)-HR(IMAX-1))
            ENVRC = EXP(CLN*ENVRCL)
            PS2 = EXP(CLN*(HP(IMAX)-HD(IMAX)))/HG(IMAX)
            PS1 = EXP(CLN*(HP(IMAX-1)-HD(IMAX-1)))/HG(IMAX-1)
            PSCA = PS1 + FX*(PS2-PS1)
            RTESTL = DLOG10(ENVRC+PSCA)
C FIND V
            DO K = IMAX+1,M
               IF(HR(K).GT.RTESTL)THEN
                  FX = (RTESTL-HR(K-1))/(HR(K)-HR(K-1))
                  CVEL = SVEL(K-1)+FX*(SVEL(K)-SVEL(K-1))
                  GOTO 85
               ENDIF
            END DO
            ! One pressure scale height overshoots edge of interior
            ! calculation. Stitch on the envelope for more room
            DO K = 2,NUMENV
               IF(ENVR(K).GT.RTESTL .AND. EVELS(K) .GT. 0.0)THEN
                  FX = (RTESTL-HR(M))/(ENVR(K)-HR(M))
                  CVEL = SVEL(M)+FX*(EVELS(K)-SVEL(M))
                  GOTO 85
               ENDIF
            END DO
            CVEL = SVEL(M)
 85         CONTINUE
C DEFINE TAUCZ
            TAUCZ = PSCA/CVEL

         ELSE
C INFER HP
            IF(.NOT.LROT)THEN
               HG(1)=HS1(1)*EXP(CLN*(CGL-2.0D0*HR(1)))
            ENDIF
            PSCA2 = EXP(CLN*(HP(1)-HD(1)))/HG(1)
            RTEST2 = EXP(CLN*HR(1))
            IF(PSCA2.LE.RTEST2)THEN
C HP < R AT THE FIRST POINT.  ASSUME V CONSTANT INSIDE AND HP = K/R FOR
C SLOWLY VARYING DENSITY AND PRESSURE NEAR THE CENTER.
               CVEL = SVEL(1)
               PSCA = (PSCA2*RTEST2)**0.5D0
               TAUCZ = PSCA/CVEL
            ELSE
               DO K = 2,M
                  PSCA1 = PSCA2
                  RTEST1 = RTEST2
                  IF(.NOT.LROT)THEN
                     HG(K)=HS1(K)*EXP(CLN*(CGL-2.0D0*HR(K)))
                  ENDIF
                  PSCA2 = EXP(CLN*(HP(K)-HD(K)))/HG(K)
                  RTEST2 = EXP(CLN*HR(K))
C FIND LOCATION WHERE HP = R
                  IF(PSCA2.LE.RTEST2)THEN
                     FX = (RTEST1-PSCA1)/((PSCA2-RTEST2)-(PSCA1-RTEST1))
C FIND V
                     CVEL = SVEL(K-1)+FX*(SVEL(K)-SVEL(K-1))
                     PSCA = PSCA1+FX*(PSCA2-PSCA1)
C DEFINE TAUCZ
                     TAUCZ = PSCA/CVEL
                     GOTO 95
                  ENDIF
               END DO
               K = M
               CVEL = SVEL(M)
               PSCA = PSCA2
               TAUCZ = PSCA/CVEL
 95            CONTINUE
            ENDIF
         ENDIF
      ELSE
         TAUCZ = 0.0D0
      ENDIF

C--------------------------------------------------------------
C                  OPEN(UNIT=100,FILE='diagnostic.out',STATUS='OLD')
C                  DO 1505 I=1,M
C                  IF (LCZ(I)) HOLD = 1.0
C                  IF (.NOT.LCZ(I)) HOLD = 0.0
C                              WRITE(100,1504), HS2(I), HS1(I), HR(I),HOLD,
C     *                  DEL1(I), DEL2(I), SVEL(I),
C1505                  CONTINUE
C1504                  FORMAT(1X,7E16.8)
C                  CLOSE(100)
C----------------------------------------------------------------

C END JVS
      RETURN
      END
