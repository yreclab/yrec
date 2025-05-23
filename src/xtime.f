C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C XTIME
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE XTIME(HD,HCOMP,HL,HS1,HS2,HT,HYDLUM,JCORE,JXMID,M,
     *   DELTSH,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,
     *   HR13,HF1,HF2,JXBEG)
      PARAMETER(JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      COMMON/CTLIM/ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TENV,TGCUT
      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL
      COMMON/CONST3/CDELRL,CMIXL,CMIXL2,CMIXL3,CLNDP,CSECYR
      COMMON/CT3/LPTIME
      COMMON/FLAG/LEXCOM
C MHP 10/02 ADDED MISSING DIMENSION STATEMENTS!
      DIMENSION HCOMP(15,JSON),HL(JSON),HS1(JSON),HT(JSON),HS2(JSON),
     * HR1(JSON),HR2(JSON),HR3(JSON),HR4(JSON),HR5(JSON),HR6(JSON),
     * HR7(JSON),HR8(JSON),HR9(JSON),HR10(JSON),HR11(JSON),HR12(JSON),
     * HR13(JSON),HF1(JSON),HF2(JSON),HD(JSON)
      SAVE
C  THIS SR FINDS THE TIMESTEP BASED ON HYDROGEN BURNING.
C  FOR STARS WITH CENTRAL X > ATIME(1) THE TIMESTEP
C       IS THE TIME NEEDED TO BURN THE MINIMUM OF ATIME(2) OF
C       X AT THE CENTER OR THE FRACTION ATIME(3) OF THE CENTRAL X.
C  STARS WITH CENTRAL X < ATIME(1) ARE CONSIDERED BY THE PROGRAM
C       TO HAVE A HYDROGEN SHELL BURNING SOURCE.  THE TIMESTEP IS THE
C       MINIMUM OF THE TIME REQUIRED TO BURN ATIME(7) OF X AT THE SHELL
C       MIDPOINT OR TO BURN THE MASS FRACTION ATIME(6) OF X IN THE
C       ENTIRE STAR.
C H-CORE BURNING TIME CRITERION
C **NOTE THAT FOR A CONVECTIVE CORE, THE TIMESTEP IS BASED ON THE TIME
C   NEEDED TO BURN THE GIVEN FRACTION OF HYDROGEN IN THE CORE AND NOT
C   JUST IN THE CENTRAL SHELL.
      IF(HCOMP(1,1).GE.ATIME(1)) THEN
	 DX = MIN(ATIME(2),ATIME(3)*HCOMP(1,JCORE))
	 DELTSH =(6.00D18/CLSUN)*(HS1(JCORE)/HL(JCORE))*DX
	 RETURN
      ENDIF
C H-SHELL BURNING CRITERION
C LIMIT TOTAL MASS OF HYDROGEN BURNED.
C      DX = ATIME(6)*HCOMP(1,M)*(CMSUN/CLSUN)
      DX = ATIME(6)*HCOMP(1,M)*(CMSUN/CLSUN)
      DELTSH = 6.00D18*DX/HYDLUM
C LIMIT X-DEPLETION AT SHELL MID-POINT.
C CALL NUCLEAR REACTION SR'S TO FIND DXDT AT THE SHELL MIDPOINT.
      IBEGIN=JXMID
      IEND=JXMID
         DL = HD(IEND)
         TL = HT(IEND)
         X = HCOMP(1,IEND)
         Y = HCOMP(2,IEND)
         Z = HCOMP(3,IEND)
         XHE3 = HCOMP(4,IEND)
         XC12 = HCOMP(5,IEND)
         XC13 = HCOMP(6,IEND)
         XN14 = HCOMP(7,IEND)
         XN15 = HCOMP(8,IEND)
         XO16 = HCOMP(9,IEND)
         XO17 = HCOMP(10,IEND)
         XO18 = HCOMP(11,IEND)
         XH2 = HCOMP(12,IEND)
         XLI6 = HCOMP(13,IEND)
         XLI7 = HCOMP(14,IEND)
        XBE9 = HCOMP(15,IEND)
C SETUP NUCLEAR ENERGY TERMS
      CALL RATES(DL,TL,X,Y,Z,XHE3,XC12,XC13,XN14,XN15,
     *     XO16,XO17,XO18,XH2,XLI6,XLI7,XBE9,IEND,HR1,HR2,HR3,HR4,
     *     HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12,HR13,HF1,HF2)
      CALL EQBURN(HF1,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,
     *     HR12,HS2,HT,IBEGIN,IEND,DCDT,DODT,DXDT,DYDT,XC12,XO16,X,Z)
      IF(DXDT.LT.0.0D0 .AND. ATIME(7).GT.0.0D0) THEN
         DELTSH2 = ABS(CSECYR*1.0D9*ATIME(7)/DXDT)
         DELTSH = MIN(DELTSH,DELTSH2)
      ENDIF
      RETURN
      END
