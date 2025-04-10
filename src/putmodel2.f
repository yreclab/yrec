C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PUTMMODEL2 - Write out a stallar model in MODEL2 format
C
C llp  4/16/03
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE PUTMODEL2(BL,CFENV,CMIXL,DAGE,DDAGE,FTRI,HCOMP,HD,HL,
     * HP,HR,HS,HSTOT,HT,IWRITE,ISHORT,JCORE,JENV,LC,LEXCOM,LROT,M,
     * MODEL,OMEGA,PS,RS,SMASS,TEFFL,TLUMX,TRIL,TRIT,TS,
     & ATM,EOS,HIK,LDIFY,LDIFZ,LDISK,LINSTB,LJDOT0,LOK,
     & LOVSTC,LOVSTE,LOVSTM,LPUREZ,LSEMIC,COMPMIX,PDISK,TDISK,WMAX)
C First three lines above are YREC7 inputs
C Last two lines are MODEL2 add-ons

C  Write output model in MODEL2 format

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      CHARACTER*6 EOS
      CHARACTER*4 ATM, LOK, HIK, COMPMIX

      COMMON/CONST/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,CMBOL


      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     &     HS(JSON),HT(JSON),LC(JSON),TRIT(3),TRIL(3),PS(3),TS(3),RS(3),
     &     CFENV(9),TLUMX(8),OMEGA(JSON)

      save

C PUTYMODEL2 writes the model provided to it out to the LU IWRITE file.
C Any error messages go to LU ISHORT.

      IF(ATM .EQ. ' ? ') THEN
         WRITE(ISHORT,7)
  7      FORMAT('*** YREC7 input file, flags, etc., have been ',
     *          'defaulted.  ***')
      ENDIF	 
     
C write header records
      IF(DAGE .lt. 1d3) THEN
         WRITE(IWRITE,10) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 10      FORMAT(A5,2I8,5F16.11,1PE18.10,0P2F16.12)
      ELSE IF (DAGE .LT. 1D4) THEN 
         WRITE(IWRITE,11) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 11      FORMAT(A5,2I8,4F16.12,F16.10,1PE18.10,0P2F16.12)
      ELSE IF (DAGE .LT. 1D5) THEN
         WRITE(IWRITE,12) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 12      FORMAT(A5,2I8,4F16.12,F16.9,1PE18.10,0P2F16.12)
      ELSE 
         WRITE(IWRITE,13) 'MOD2 ',MODEL,M,SMASS,TEFFL,BL,HSTOT,DAGE,
     *      DDAGE,HS(1),HS(M)
 13      FORMAT(A5,2I8,4F16.12,F16.8,1PE18.10,0P2F16.12)
      ENDIF

C write physics flags:
      WRITE(IWRITE,30) JCORE,JENV,CMIXL,EOS,ATM,LOK,HIK,LPUREZ,
     &     COMPMIX,LEXCOM,LDIFY,LDIFZ,LSEMIC,LOVSTC,LOVSTE,LOVSTM,
     &     LROT,LINSTB,LJDOT0,LDISK,TDISK,PDISK,WMAX
   30 FORMAT(2I8,F16.10,1X,A6,1X,3(A4,1X),L1,1X,A4,1X,11(L1,1X),
     &     3(1PE18.10))

C write luminosities
C If TLUMX are in solar units, convert to ergs.  Decide by 
C comparing to 10**20, if smaller, multiply by CLSUN

      CCCMAX = DMAX1(TLUMX(1),TLUMX(2),TLUMX(3),TLUMX(4),TLUMX(5),
     *     DABS(TLUMX(6)),TLUMX(7))
      IF(CCCMAX.LE.1.0D20) THEN
	 DO J = 1,7
	    TLUMX(J) = TLUMX(J) * CLSUN
         ENDDO
      ENDIF
      WRITE(IWRITE,40) (TLUMX(J),J=1,7)
   40 FORMAT('TLUMX',5X,1P7E17.9)

C write ENVELOPE DATA
      DO I = 1,3
         I0 = I
         IF(FTRI.LT.0D0) I0 = -I
         WRITE(IWRITE,50)I0,TRIT(I),TRIL(I),PS(I),TS(I),RS(I),
     &        (CFENV(3*I-3+J),J=1,3)
      ENDDO
   50 FORMAT('ENV',I2,5F16.12,1P3E20.12)

C write column headings for all per shell information
      WRITE(IWRITE,*)
      WRITE(IWRITE,55) ' SHELL','MASS       ','RADIUS      ',
     *  'LUMINOSITY       ','PRESSURE     ','TEMPERATURE   ',
     *  'DENSITY     ','OMEGA         ',' C','  H1     ','   He4    ',
     *  '   METALS  ','He3      ','C12      ','C13      ','N14      ',
     *  'N15      ','O16      ','O17      ','O18      ','H2       ',
     *  'Li6      ','Li7      ','Be9      '
 55   FORMAT(A6,2A18,A24,3A18,A24,A2,3A12,12A16)
      WRITE(IWRITE,*)

C LLP 4/16/03  Output OMEGA rather Log10(OMEGA), a change from YREC7 files

C write per shell information, one line per shell
      DO I = 1,M
         WRITE(IWRITE,60) I,HS(I),HR(I),HL(I),HP(I),HT(I),HD(I),
     *      OMEGA(I),LC(I),(HCOMP(J,I),J=1,15)
       ENDDO
 60   FORMAT(I6,0P2F18.14,1PE24.16,0P3F18.14,1PE24.16,1x,L1,
     &     3(0PF12.9),12(0PE16.8))

      RETURN
      END
