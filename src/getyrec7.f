C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C GETY7 - Read a YREC7 format stellar model file into memory
C
C llp  4/16/03
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
      SUBROUTINE GETYREC7(BL,CFENV,CMIXL,DAGE,DDAGE,FTRI,HCOMP,HD,HL,
     * HP,HR,HS,HSTOT,HT,IREAD,ISHORT,JCORE,JENV,LC,LEXCOM,LROT,M,
     * MODEL,OMEGA,PS,RS,SMASS,TEFFL,TLUMX,TRIL,TRIT,TS,
     & ATM,EOS,HIK,LDIFY,LDIFZ,LDISK,LINSTB,LJDOT0,LOK,
     & LOVSTC,LOVSTE,LOVSTM,LPUREZ,LSEMIC,COMPMIX,PDISK,TDISK,WMAX)
C First three lines above are YREC7 inputs
C Last two lines are MODEL2 add-ons

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER*4 (I-K,M)
      IMPLICIT LOGICAL*4(L)

      CHARACTER*4 ATEMP,ATM,HIK,LOK,COMPMIX
      CHARACTER*6 EOS

      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL

      DIMENSION CFENV(9),HCOMP(15,JSON),HD(JSON),HL(JSON),HR(JSON),
     *HP(JSON),HS(JSON),HT(JSON),LC(JSON),OMEGA(JSON),OMEGAL(JSON),
     *PS(3),RS(3),TS(3),TLUMX(8),TRIL(3),TRIT(3)

      save

C Initialization 

C Zero the composition arrays (HCOMP) and the OMEGA array.
C This is agreed upon protection in case they are inadvertently used in the program,
C but not present in the old YREC input data.
      DO I  = 1, JSON
         OMEGA(I) = 0D0
	 DO J = 1, 15
	    HCOMP(J,I) = 0D0
	 ENDDO
      ENDDO    

C  Set Model2-sspecific strings to "?"
      ATM = " ? "
      EOS = " ? "
      HIK = " ? "
      LOK = " ? "
      COMPMIX = "AG93"

C Set Model2-specific flags false
      LDIFY = .FALSE.
      LDIFZ = .FALSE.
      LDISK = .FALSE.
      LINSTB = .FALSE.
      LJDOT0 = .FALSE.
      LOVSTC = .FALSE.
      LOVSTE = .FALSE.
      LOVSTM = .FALSE.
      LPUREZ = .FALSE.
      LSEMIC = .FALSE.

C Set Model2-specific constants to default
      PDISK = 7.2722D-6
      TDISK = 0D0
      WMAX = 3D-4

C End of initialization

C Read in an input model from the LU IREAD file in YREC7 Format

      REWIND(IREAD)

C get the header record
      READ(IREAD,10) ATEMP,MODEL,M,SMASS,TEFFL,BL,HSTOT,
     *        DAGE,DDAGE
 10   FORMAT(A4,1X,2I5,3F8.5,1X,F14.10,F13.9,F13.0)

C Get the flags describing the input physics and the information that
C is stored in the model (rotating or not?, extendec compotition, etc.)
      READ(IREAD,30) LROT,LEXCOM,JCORE,JENV,CMIXL
 30   FORMAT(2(L1,1X),5X,2I4,F7.3)

C get the LUMINOSITIES---PP(1-2-3)-CNO-HE-NU-GRAV
      READ(IREAD,40) (TLUMX(J),J=1,7)
 40   FORMAT(10X,7E10.3)

C If TLUMX are in ergs, convert to solar units.  Decide by 
C comparing to 10**20. If larger, divide by CLSUN.
      CCCMAX = DMAX1(TLUMX(1),TLUMX(2),TLUMX(3),TLUMX(4),TLUMX(5),
     *     DABS(TLUMX(6)),TLUMX(7))
      IF(CCCMAX.GT.1.0D20) THEN
	 DO J = 1,7
	    TLUMX(J) = TLUMX(J)/CLSUN
         ENDDO
      ENDIF

C Get the ENVELOPE DATA
C FTRI is 1,normally.  It is set to -1  if any of the record numbers 
C for the envelope triangle records was set to -1 by WRTLST.
      FTRI = 1D0
      DO 80 I = 1,3
	 READ(IREAD,70) IO,TRIT(I),TRIL(I),PS(I),TS(I),RS(I),
     *        (CFENV(I+I+I-3+J),J = 1,3)
 70      FORMAT(3X,I2,F7.5,4F8.5,3E12.5)
	 IF(IO.LT.0) FTRI = -1D0
 80   CONTINUE

C READ IN HENYEY POINTS IN 4 PARTS
C
C Read FIRST PART:M,R,L,P,T,RHO,CONV(T/F),X,Y,AND Z - one line per shell
      DO 110 I = 1,M
	 READ(IREAD,100) HS(I),HR(I),HL(I),HP(I),HT(I),HD(I),LC(I),
     *        IX,IZ
 100     FORMAT(0PF13.10,F10.7,1PE14.7,0PF10.7,2F10.7,L1,2I6)
	 IF(HS(I).LT.0D0.OR.HS(I).GT.HSTOT) THEN
	    WRITE(ISHORT,1000)
	    WRITE(ISHORT,1050) I
 1000       FORMAT(1X,39('>'),40('<')/1X,'RUN STOPPED')
 1050       FORMAT(' ERROR IN SUBROUTINE GETY7'/1X,'GLITCH IN SHELL',
     *      I3,', SHELL MASS LESS THAN ZERO OR GREATER THAN STAR MASS')
	    STOP
	 ENDIF
	 HCOMP(1,I) = 1.0D-6*DFLOAT(IX)
	 HCOMP(3,I) = 1.0D-6*DFLOAT(IZ)
 110  CONTINUE

C Read SECOND PART:ELEMENT ABUNDANCES: HE3,CNO CYCLE ELEMENTS.
C ABUNDANCES IN SURFACE AND CENTRAL CONVECTION ZONES STORED WITH 1
C VALUE PER ZONE RATHER THAN 1 VALUE PER SHELL
      IF(JENV.LE.JCORE) THEN
	 READ(IREAD,200)(HCOMP(I,JCORE),I=4,11)
	 READ(IREAD,200)(HCOMP(I,JENV),I=4,11)
      ELSE
	 DO 210 J = JCORE,JENV
	    READ(IREAD,200) (HCOMP(I,J),I = 4,11)
 200        FORMAT(8(1PE9.3,1X))
 210     CONTINUE
      ENDIF
      IF(JCORE.GT.1) THEN
C CONVECTIVE CORE- ASSIGN FIRST COMPOSITION VALUE TO SHELLS 1-JCORE
	 DO 230 J = 1,JCORE-1
	    DO 220 I = 4,11
	       HCOMP(I,J) = HCOMP(I,JCORE)
 220        CONTINUE
 230     CONTINUE
      ENDIF
      IF(JENV.LT.M) THEN
C CONVECTIVE SURFACE- ASSIGN LAST COMPOSITION TO SHELLS JENV-M
	 DO 250 J = JENV+1,M
	    DO 240 I = 4,11
	       HCOMP(I,J) = HCOMP(I,JENV)
 240        CONTINUE
 250     CONTINUE
      ENDIF
C DEFINE HE4 = 1 - X - Z - HE3.
      DO 260 I = 1,M
	 HCOMP(2,I) = 1.0D0 - HCOMP(1,I) - HCOMP(3,I) - HCOMP(4,I)
 260  CONTINUE

C READ IN H2,LI6,LI7,BE9 (EXTENDED COMPOSITION)

      IF(LEXCOM) THEN
	 IF(JENV.EQ.1)THEN
C FULLY CONVECTIVE MODEL
	    READ(IREAD,300)(HCOMP(I,1),I=12,15)
 300        FORMAT(4(1PE9.3,1X))
	    DO 310 J = 1,M
	       DO 305 I = 12,15
		  HCOMP(I,J) = HCOMP(I,1)
 305           CONTINUE
 310        CONTINUE
	 ELSE
C GENERAL CASE
C THESE ABUNDANCES ARE READ IN WITH 2 SHELLS PER LINE
	    DO 315 K = JCORE,JENV-1,2
	       READ(IREAD,200)((HCOMP(I,J),I = 12,15),J = K,K+1)
 315        CONTINUE
C IF AN ODD NUMBER OF ABUNDANCES STORED, READ IN LAST VALUE
	    KT = JENV-1 - JCORE
	    IF(MOD(KT,2).NE.0)READ(IREAD,300)(HCOMP(I,K),I = 12,15)
	    IF(JCORE.GT.1) THEN
C CONVECTIVE CORE- ASSIGN FIRST VALUE TO SHELLS 1-JCORE
	       DO 330 J = 1,JCORE-1
		  DO 320 I = 12,15
		     HCOMP(I,J) = HCOMP(I,JCORE)
 320              CONTINUE
 330           CONTINUE
	    ENDIF
	    IF(JENV.LT.M) THEN
C CONVECTIVE SURFACE- ASSIGN LAST VALUE TO SHELLS JENV - M
	       DO 350 J = JENV+1,M
		  DO 340 I = 12,15
		     HCOMP(I,J) = HCOMP(I,JENV)
 340              CONTINUE
 350           CONTINUE
	    ENDIF
	 ENDIF
      ENDIF

C Read in FOURTH PART:  - LOG J/M STORED , 8 SHELLS PER LINE

      IF(LROT) THEN
C READ OMEGA IN. If OMEGA records are missing go to OMEGA BYPASS below 
	READ(IREAD,500,END=9999)(OMEGAL(II),II = 1,M)
 500    FORMAT(0P8F10.7)
	DO 510 I = 1,M
           IF(OMEGAL(I) .LT. 58.9D0) THEN
              OMEGA(I) = 10D0**(-OMEGAL(I))
           ELSE
              OMEGA(I) = 0D0
           ENDIF
 510    CONTINUE
      ENDIF

C KEEP IREAD OPEN
      REWIND IREAD

      RETURN

C  OMEGA BYPASS      
C Come here if OMEGA records are missing -- Can happen if
C a new omega file is being generated (LWNEW is true in STARIN)

9999  WRITE(ISHORT,9998) "GETYREC7: OMEGA records are missing from ",
     *  " input model file - OMEGA array zeroed"
9998  FORMAT(2A)     
      
      DO I  = 1, JSON
         OMEGA(I) = 0D0
      ENDDO    
      
C KEEP IREAD OPEN
      REWIND IREAD

      RETURN
      
      END
