C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C GETMODEL2 - Read a Model2 format stellar model file into memory
C
C llp  4/16/03
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
      SUBROUTINE GETMODEL2(BL,CFENV,CMIXL,DAGE,DDAGE,FTRI,HCOMP,HD,HL,
     * HP,HR,HS,HSTOT,HT,IREAD,ISHORT,JCORE,JENV,LC,LEXCOM,LROT,M,
     * MODEL,OMEGA,PS,RS,SMASS,TEFFL,TLUMX,TRIL,TRIT,TS,
     & ATM,EOS,HIK,LDIFY,LDIFZ,LDISK,LINSTB,LJDOT0,ALOK,
     & LOVSTC,LOVSTE,LOVSTM,LPUREZ,LSEMIC,COMPMIX,PDISK,TDISK,WMAX)
C First three lines above are YREC7 inputs
C Last two lines are MODEL2 add-ons
C MHP 4/25 chanted LOK to ALOK to avoid variable name conflicts
      
      PARAMETER (JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      CHARACTER*6 EOS
      CHARACTER*5 ATEMP
c     CHARACTER*4 ATM, LOK, HIK, COMPMIX
c MHP 4/25 changed LOK name to make it unique, used elsewhere
      CHARACTER*4 ATM, ALOK, HIK, COMPMIX

      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL


      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     &     HS(JSON),HT(JSON),LC(JSON),TRIT(3),TRIL(3),PS(3),TS(3),RS(3),
     &     CFENV(9),TLUMX(8),OMEGA(JSON)
     
      save

      REWIND(IREAD)
      
C get the header record
      READ(IREAD,10) ATEMP,MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *   DDAGE,HS(1),HS(M)
 10   FORMAT(A5,2I8,5F16.12,1PE18.10,0P2F16.12)

C Get the flags describing the input physics and the information that
C is stored in the model (rotating or not?, extendec compotition, etc.)
      READ(IREAD,30) JCORE,JENV,CMIXL,EOS,ATM,ALOK,HIK,LPUREZ,
     &     COMPMIX,LEXCOM,LDIFY,LDIFZ,LSEMIC,LOVSTC,LOVSTE,LOVSTM,
     &     LROT,LINSTB,LJDOT0,LDISK,TDISK,PDISK,WMAX
   30 FORMAT(2I8,F16.10,1X,A6,1X,3(A4,1X),L1,1X,A4,1X,11(L1,1X),
     &     3(1PE18.10))

C Get the  LUMINOSITIES---PP(1-2-3)-CNO-HE-NU-GRAV 
C CONVERT TO SOLAR LUMINOSITIES
      READ(IREAD,40) (TLUMX(J),J=1,7)
c   40 FORMAT('TLUMX',5X,1P7E17.9)
   40 FORMAT(10X,1P7E17.9)

C If TLUMX are in ergs, convert to solar units.  Decide by 
C comparing to 10**20.  IF larger, divide by CLSUN.
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
      DO I = 1,3
         READ(IREAD,50)IO,TRIT(I),TRIL(I),PS(I),TS(I),RS(I),
     &        (CFENV(3*I-3+J),J=1,3)
         IF(IO .LT. 0) FTRI = -1D0
      ENDDO
c   50 FORMAT('ENV',I2,5F16.12,1P3E20.12)
   50 FORMAT(4X,I2,5F16.12,1P3E20.12)

C Skip over column headings for per-shell data
      READ(IREAD,*)
      READ(IREAD,*)
      READ(IREAD,*)

C Read per-shell data (HENYEY POINGS)
      DO I = 1,M
         READ(IREAD,60) K,HS(I),HR(I),HL(I),HP(I),HT(I),HD(I),
     *      OMEGA(I),LC(I),(HCOMP(J,I),J=1,15)
       ENDDO
 60   FORMAT(I6,0P2F18.14,1PE24.16,0P3F18.14,1PE24.16,1x,L1,
     &     3(0PF12.9),12(0PE16.8))

      RETURN
      END
