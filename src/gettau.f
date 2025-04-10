CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                               GETTAU                              C
C                           G Somers, 3/17                         C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE GETTAU(HCOMP,HR,HP,HD,HG,HS1,HT,FP,FT,TEFFL,HSTOT,BL,M,
     *                  LC,RBCZ)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER (JSON=5000)
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR
      COMMON/ENVGEN/ATMSTP,ENVSTP,LENVG
      COMMON/INTATM/ATMERR,ATMD0,ATMBEG,ATMMIN,ATMMAX
      COMMON/INTENV/ENVERR,ENVBEG,ENVMIN,ENVMAX
      COMMON/CONST1/CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI
      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL
      COMMON/CONST2/CGAS,CA3,CA3L,CSIG,CSIGL,CGL,CMKH,CMKHN
      COMMON/ENVSTRUCT/ENVP(JSON),ENVT(JSON),ENVS(JSON),ENVD(JSON),
     *                 ENVR(JSON),ENVX(JSON),ENVZ(JSON),LCENV(JSON),
     *                 NUMENV,EDELS(3,JSON),EVELS(JSON),EBETAS(JSON)
      COMMON/SCRTCH/SESUM(JSON),SEG(7,JSON),SBETA(JSON),SETA(JSON),
     * LOCONS(JSON),SO(JSON),SDEL(3,JSON),SFXION(3,JSON),SVEL(JSON)
      DIMENSION HCOMP(15,JSON),HR(JSON),HP(JSON),HD(JSON),HG(JSON),HS1(JSON),
     *	HT(JSON),FP(JSON),FT(JSON),HCOMPF(15,JSON),HRF(JSON),HPF(JSON),
     *	HDF(JSON),HSF(JSON),HTF(JSON),LC(JSON),HGF(JSON),HVF(JSON),
     *  DELF1(JSON),DELF2(JSON),LCF(JSON)
      REAL*8 DUM1(4),DUM2(3),DUM3(3),DUM4(3)
      INTEGER*4 KATM, KENV, KSAHA
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
      COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH
      SAVE
C
C This routine devises a new, systematic method for determining the
C convective overturn timescale. It will calculate the overturn timescale
C one pressure scale height above the BCZ for whichever of the following three
C conditions holds.
C
C 1) 1 PSCA above the BCZ is in the interior model.
C 2) 1 PSCA above the BCZ is in the envelope model.
C 3) The BCZ is in the interior, but 1 PSCA above is in the envelope.
C 
C If none of these are satisfied, TAUCZ is set to 0.0.
C
C If 1): Call ENVINT to determine PPHOT, TAUINT(NEW) to determine TAUCZ
C If 2): Call ENVINT to determine PPHOT, which calls TAUCAL for TAUCZ.
C If 3): Stitch together interior and envelope.

      TAUCZ = 0.0
      PPHOT = 0.0

C Check if 1 PSCA above BCZ is within envelope. If so, only the interior
C model should be considered for TAUCZ. Set LCALCENV = .FALSE.. If not,
C have ENVINT calculate the full structure, and stitch the envelope
C and interior together.
C
C Determine where the BCZ is.
      DO 71 I = M-1,1,-1
         IF(.NOT.LC(I)) GOTO 81
   71 CONTINUE
      LALLCZ = .TRUE.
      I = 0
   81 IMAX = I + 1
C Compare the pressure there to the surface pressure.
      CHKPRS = HP(IMAX)-HP(M)
C IF CHKPRS > 1.0, AT LEAST 3 PSCAS, SO LOOK INTERIOR.
C IF CHKPRS < 1.0, 1 PSCA UP MIGHT BE IN ENV. STITCH TOGETHER.
C FINALLY, IF LNEWTCZ = .FALSE., MAKE SURE TO CALC AN ENV.
      IF(CHKPRS.LT.1.0.OR..NOT.LNEWTCZ)THEN
         LCALCENV = .TRUE.
      ELSE
         LCALCENV = .FALSE.
      ENDIF
C
C CALL ENVINT
C
      FPL = FP(M)
      FTL = FT(M)	
      IDUM = 0
      B = DEXP(CLN*BL)	
      KATM = 0
      KENV = 0
      KSAHA = 0
      IXX=0
      LPRT=.TRUE.
      LSBC0 = .FALSE.
      LPULPT = .FALSE.
      X = HCOMP(1,M)
      Z = HCOMP(3,M)
      RL = 0.5D0*(BL + CLSUNL - 4.0D0*TEFFL - C4PIL - CSIGL)
      GL = CGL + HSTOT - RL - RL      	
      PLIM = HP(M)
C G Somers 10/14, FOR SPOTTED RUNS, FIND THE
C PRESSURE AT THE AMBIENT TEMPERATURE ATEFFL
      IF(LC(M).AND.SPOTF.NE.0.0.AND.SPOTX.NE.1.0)THEN
         ATEFFL = TEFFL - 0.25*LOG10(SPOTF*SPOTX**4.0+1.0-SPOTF)
      ELSE
         ATEFFL = TEFFL
      ENDIF
      CALL ENVINT(B,FPL,FTL,GL,HSTOT,IXX,LPRT,LSBC0,
     *      PLIM,RL,ATEFFL,X,Z,DUM1,IDUM,KATM,KENV,KSAHA,
     *      DUM2,DUM3,DUM4,LPULPT)	
C PPHOT is now set, and structure variables are caluclated if
C LCALCENV = .TRUE..
C
C IF LNEWTCZ IS FALSE, THEN TAUCZ WILL HAVE BEEN SET IN ENVINT, IF THE
C TOP OF THE INTERIOR MODEL IS RADIATIVE. CHECK IF TAUCZ = 0.0. IF NOT,
C THEN GO TO THE END.
C
      IF (TAUCZ.NE.0.0) GOTO 100
C
C COLLECT THE NECESSARY STRUCTURE VARIABLES INTO DUMMY VECTORS.
      MM = M
      DO I=1,MM
         DO J=1,15
            HCOMPF(J,I) = HCOMP(J,I)
         ENDDO
         HRF(I) = HR(I)
         HPF(I) = HP(I)
         HDF(I) = HD(I)
         HSF(I) = HS1(I)
         HGF(I) = HS1(I)*EXP(CLN*(CGL-2.0D0*HR(I)))
         HTF(I) = HT(I)

         HVF(I) = SVEL(I)
         DELF1(I) = SDEL(1,I)
         DELF2(I) = SDEL(3,I)
         LCF(I) = LC(I)
      ENDDO
C
      IF(LCALCENV.AND.LNEWTCZ)THEN
C IF CHKPRS < 1, THEN STITCH THE ENVELOPE ONTO THE INTERIOR.
C ENVELOPE WAS JUST INTEGRATED IN ENVINT ABOVE, SO USE THAT RUN.
C THIS CODE BORROWED FROM STITCH.F. 
         MM = M+NUMENV-1
         DO I=M+1,MM
            DO J=1,15
               HCOMPF(J,I) = HCOMP(J,M+1)
            ENDDO
            HRF(I) = ENVR(I-M+1)
            HPF(I) = ENVP(I-M+1)
            HDF(I) = ENVD(I-M+1)
            HSF(I) = EXP(CLN*(HSTOT+ENVS(I-M+1)))
            HGF(I) = HSF(I)*EXP(CLN*(CGL-2.0D0*HRF(I)))
            HTF(I) = ENVT(I-M+1)

            HVF(I) = EVELS(I-M+1)
            DELF1(I) = EDELS(1,I-M+1)
            DELF2(I) = EDELS(2,I-M+1)
            LCF(I) = LCENV(I-M+1)
         ENDDO
      ENDIF
C CALL TAUINT
      IF(LNEWTCZ)THEN
         CALL TAUINTNEW(HCOMPF,HS2,HSF,LCF,HRF,HPF,HDF,HGF,MM,M,HVF,
     *                  DELF1,DELF2,HSTOT,RBCZ)
      ELSE
         CALL TAUINT(HCOMPF,HS2,HSF,LCF,HRF,HPF,HDF,HGF,MM,HVF,
     *               DELF1,DELF2,HSTOT)
      ENDIF
C RETURN FULL FUNCTIONALITY TO ENVINT
 100  CONTINUE
      LCALCENV = .TRUE.
      RETURN
      END
