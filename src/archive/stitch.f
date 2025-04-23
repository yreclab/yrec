	SUBROUTINE STITCH(HCOMP,HR,HP,HD,HG,HS,HT,FP,FT,TEFFL,HSTOT,BL,M,
     *HCOMPF,HRF,HPF,HDF,HSF,HTF,MM,LC)
      use parmin90, only : CLSUNL  ! COMMON/CONST/
      use parmin90, only : CLN, C4PIL  ! COMMON/CONST1/
      use parmin90, only : CSIGL  ! COMMON/CONST2/
	IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
	PARAMETER (JSON=5000)
	REAL*8 DUM1(4),DUM2(3),DUM3(3),DUM4(3)
	COMMON/ENVGEN/ATMSTP,ENVSTP,LENVG
      COMMON/INTATM/ATMERR,ATMD0,ATMBEG,ATMMIN,ATMMAX
      COMMON/INTENV/ENVERR,ENVBEG,ENVMIN,ENVMAX
	COMMON/ENVSTRUCT/ENVP(JSON),ENVT(JSON),ENVS(JSON),ENVD(JSON),
     *                 ENVR(JSON),ENVX(JSON),ENVZ(JSON),LCENV(JSON),
     *                 NUMENV,EDELS(3,JSON),EVELS(JSON),EBETAS(JSON)
	DIMENSION HCOMP(15,JSON),HR(JSON),HP(JSON),HD(JSON),HG(JSON),HS(JSON),
     *	HT(JSON),FP(JSON),FT(JSON),HCOMPF(15,JSON),HRF(JSON),HPF(JSON),
     *	HDF(JSON),HSF(JSON),HTF(JSON),LC(JSON)
C G Somers 10/14, Add spot common block
        COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH
C G Somers END
C G Somers 3/17, ADDING NEW TAUCZ COMMON BLOCK
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
	SAVE
C
C
C STITCH: Pieces together the interior and envelope portions of the stellar
C model. 
C
C INPUTS:
C	HCOMP: array of compositions
C	HR: radius, interior only, logged
C	HP: pressure (interior, logged)
C	HD: density (interior, logged)
C	HG: gravity (interior, logged)
C	HS: mass (interior, logged)
C	HT: temperature (interior,logged)
C	FP: rotational distortion (pressure)
C	FT: rotational distortion (temp)
C	TEFFL: logged effective temperature
C	HSTOT: total mass, logged, in grams
C	BL: 
C	M: number of shells in the interior
C
C
C OUTPUTS:
C	HCOMPF: full run of compositions, interior + envelope (+ atmosphere, if grey)
C	HRF: full run of radii, logged
C	HPF: full run of pressures, logged
C	HDF: full run of densities, logged
C	HGF: full run of gravities, logged
C	MM: number of shells in interior + envelope (+atmosphere)


C Begin by "dropping a sinkline" with the envelope intergrator
 		ABEG0 = ATMBEG
		AMIN0 = ATMMIN
		AMAX0 = ATMMAX
		EBEG0 = ENVBEG
		EMIN0 = ENVMIN
		EMAX0 = ENVMAX
		ATMBEG = ATMSTP
		ATMMIN = ATMSTP
		ATMMAX = ATMSTP
		ENVBEG = ENVSTP
		ENVMIN = ENVSTP
		ENVMAX = ENVSTP
		IDUM = 0
		B = DEXP(CLN*BL)	
		FPL = FP(M)
	 	FTL = FT(M)	
		KATM = 0
	 	KENV = 0
	 	KSAHA = 0
C MHP 2/12 OMITTED OVERWRITE OF GLOBAL FLAG
C		LPULPT=.TRUE.
		IXX=0
		LPRT=.FALSE.
		LSBC0 = .FALSE.
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
     *		PLIM,RL,ATEFFL,X,Z,DUM1,IDUM,KATM,KENV,KSAHA,
     *		DUM2,DUM3,DUM4,LPULPT)	
C G Somers END
C	Stitch everything together
	DO I=1,M
		DO J=1,15
			HCOMPF(J,I) = HCOMP(J,I)
		ENDDO
		HRF(I) = HR(I)
		HPF(I) = HP(I)
		HDF(I) = HD(I)
		HSF(I) = HS(I)
		HTF(I) = HT(I)

	ENDDO
	MM = M+NUMENV
	DO I=M+1,MM
		DO J=1,15
			HCOMPF(J,I) = HCOMP(J,M)
		ENDDO
		HRF(I) = ENVR(I-M)
		HPF(I) = ENVP(I-M)
		HDF(I) = ENVD(I-M)
		HSF(I) = ENVS(I-M)+HSTOT
		HTF(I) = ENVT(I-M)

		
	ENDDO
C	Save Pphot: - now done in envint
C	PPHOT = ENVP(NUMENV)

	RETURN
	END









