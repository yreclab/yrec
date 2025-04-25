C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C SETUPS
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE SETUPS(V)
      use params, only : json, nt, ng, ntc, ngc, nts, nps, nta, nga
      use settings, only : IFERMI, FFERMI, ISHORT  ! /LUNUM/, /LUFNM/, /LUOUT/
      use settings, only : XENV  ! /COMP/
      use settings, only : CLSUN, CLSUNL, CLNSUN, CMSUN, CMSUNL, CRSUN, CRSUNL, CMBOL  ! /CONST/
      use settings, only : CLN, CLNI, C4PI, C4PIL, C4PI3L, CC13, CC23, CPI  ! /CONST1/
      use settings, only : CGAS, CA3, CA3L, CSIG, CSIGL, CGL, CMKH  ! /CONST2/
      use settings, only : CDELRL, CMIXL2, CMIXL3, CLNDP, CSECYR  ! /CONST3/
      use settings, only : CDH, DHNUE  ! /DEBHU/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C DBGLAOL
      REAL*8 OLAOL,OXA,OT,ORHO,TOLLAOL

      INTEGER DUM2, DUM4
      REAL*8 DUM1, DUM3
      CHARACTER*256 FLAOL, FPUREZ
      CHARACTER*256 FATM
      CHARACTER*256 FSCVH,FSCVHE,FSCVZ

C DBGLAOL
      COMMON/NWLAOL/OLAOL(12,104,52),OXA(12),OT(52),ORHO(104),TOLLAOL,
     *  IOLAOL, NUMOFXYZ, NUMRHO, NUMT, LLAOL, LPUREZ, IOPUREZ,
     *  FLAOL, FPUREZ
      DIMENSION V(12)
      COMMON/CCR/DVAL(43),ETAT8(43),DTABLE(5,43,20),IDEN(261)
      COMMON/MHD/LMHD,IOMHD1,IOMHD2,IOMHD3,IOMHD4,IOMHD5,IOMHD6,
     1     IOMHD7, IOMHD8
      COMMON/ATMOS/HRAS,KTTAU,KTTAU0,LTTAU
      COMMON/ATMOS2/ATMPL(NT,NG),ATMTL(NT),
     *              ATMGL(NG),ATMZ,IOATM,FATM
C JNT 06/14
      COMMON/ATMOS2C/ATMPLC(NTC,NGC),ATMTLC(NTC),
     *              ATMGLC(NGC)
C MHP 8/92 COMMON BLOCK ADDED FOR LOWER EDGE OF TABLE IN LOG G.
      COMMON/FAC/IMIN(NT),IMINMAX(NT),JP,KP(4),IMIN2(NTC),IMINMAX2(NTC)
C MHP  5/97 ADDED COMMON BLOCK FOR SCV EOS TABLES
      COMMON/SCVEOS/TLOGX(NTS),TABLEX(NTS,NPS,12),
     *TABLEY(NTS,NPS,12),SMIX(NTS,NPS),TABLEZ(NTS,NPS,13),
     *TABLENV(NTS,NPS,12),NPTSX(NTS),LSCV,IDT,IDP
      COMMON/SCV2/FSCVH,FSCVHE,FSCVZ,ISCVH,ISCVHE,ISCVZ

      SAVE

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C SETUP CONSTANTS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      CLNDP = DLOG(10.0D0)
      CLN = CLNDP
      CLNI = 1.0D0/CLN
c Luminosity of Sun
      CLSUNL = DLOG10(CLSUN)
      CLNSUN = CLN/CLSUN
c Mass of Sun
      CMSUN = 1.9891D33
      CMSUNL = DLOG10(CMSUN)
C Radius of Sun
      CRSUNL = DLOG10(CRSUN)
C Bolometric magnitude of the sun
      CMBOL = 4.79D0
C No. of seconds per year and other mathematical constants
      CSECYR = 3.1558D7
      CC13 = 1.0D0/3.0D0
      CC23 = CC13 + CC13
      CPI = 3.1415926535898D0
      C4PI = 4.0D0*CPI
      C4PIL = DLOG10(C4PI)
      C4PI3L = DLOG10(CC13*C4PI)
C Speed of Light
      CC = 2.99792458D10
C Stefan-Boltzmann constant
      CSIG = 5.67051D-5
      CSIGL = DLOG10(CSIG)
C radiation constant/3
      CA3 = CSIG*4.0D0/(3.0D0*CC)
      CA3L = DLOG10(CA3)
C molar gas constant
      CGAS = 8.314510D7
C log of Gravitational constant G=6.67259D-8
      CGL = -7.17571D0
C mass of the electron
      CMELEC = 9.1093897D-28
c Boltzmann constant
      CBOLTZ = 1.380658D-16
c Planck's constant
      CPLNCK = 6.6260755D-27
      CMKH = 1.50D0*DLOG10(2.0D0*CPI*CMELEC)+2.5D0*DLOG10(CBOLTZ)-
     *       3.0D0*DLOG10(CPLNCK)
      CDELRL = -C4PI3L - CSIGL - DLOG10(16.0D0)
      CMIXL2 = CC13
      CMIXL3 = 16.0D0*DSQRT(2.0D0)*CSIG
C DBG CALCULATE DEBYE-HUCKEL CONSTAND CDH
C mass hydrogen atom (gm)
      HMASS = 1.0D0/6.0222137D23
C charge electron (ESU)
      ELEC=4.802D-10
      CDH = -SQRT(CPI/(CBOLTZ*HMASS*HMASS*HMASS))*ELEC*ELEC*ELEC/3.0D0
C Electric charge of C,N,O,Ne,Na,Mg,Al,Si,P,S,Cl,Ar,Ca,Ti,Cr,Mn,Fe,Ni
      DHNUE(1) = 6.0D0
      DHNUE(2) = 7.0D0
      DHNUE(3) = 8.0D0
      DHNUE(4) = 10.0D0
      DHNUE(5) = 11.0D0
      DHNUE(6) = 12.0D0
      DHNUE(7) = 13.0D0
      DHNUE(8) = 14.0D0
      DHNUE(9) = 15.0D0
      DHNUE(10) = 16.0D0
      DHNUE(11) = 17.0D0
      DHNUE(12) = 18.0D0
      DHNUE(13) = 20.0D0
      DHNUE(14) = 22.0D0
      DHNUE(15) = 24.0D0
      DHNUE(16) = 25.0D0
      DHNUE(17) = 26.0D0
      DHNUE(18) = 28.0D0
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     EVALUATE TAU = 2/3 TEMPERATURE FOR HRA
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      HRAS = HRA(CC23)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     SET UP OPACITY TABLES
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      CALL SETUPOPAC(XENV, V)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     READ IN MHD EOS TABLES
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      IF(LMHD) THEN
           CALL MHDTBL
      ENDIF
C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C INPUT F-TABLES FOR DEGENERATE EQUATION OF STATE
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C  OPEN DATA FILES
      OPEN(UNIT=IFERMI,FILE=FFERMI,FORM='FORMATTED',STATUS='OLD')
      READ(IFERMI,150)  (DVAL(I), I = 1,43)
      READ(IFERMI,150)  (ETAT8(I), I = 1,43)
      READ(IFERMI,160) (I,J,(DTABLE(K,I,J),K=1,5),NCARDS=1,860)
  150 FORMAT(8X,9F8.4)
  160 FORMAT(2I5,5F12.7)
      REWIND IFERMI
      K1 = 1
      DO 180 I=1,41
C MHP 10/02 SHOULD BE INT(DVAL,ETC.)
       IF (DVAL(I+1).LE.DVAL(I)) THEN
C       IF (INT(DVAL(I+1)).LE.INT(DVAL(I))) THEN
          WRITE(ISHORT,1000) I
 1000       FORMAT(1X,39('>'),40('<')/1X,'ERROR IN SUBROUTINE SETUPS'/
     *      1X,'GLITCH IN FERMI TABLE ELEMENT',I4/1X,'RUN STOPPED')
          STOP
       ENDIF
       K = INT((DVAL(I+1) - DVAL(I))*20.0D0 + 0.10D0)
       K2 = K1 + K - 1
       IF (I.EQ.41)  K2 = 261
       DO 170 J=K1,K2
          IDEN(J) = I
  170    CONTINUE
       K1 = K2 + 1
  180 CONTINUE

C  CLOSE EQUATION OF STATE FILE.
      CLOSE(IFERMI)
C JMH 8/18/91
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C INPUT PRESSURE TABLE FOR SURFACE BOUNDARY CONDITIONS
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      IF ((KTTAU .EQ. 3) .OR. (KTTAU .EQ. 4)) THEN
C OPEN SURFACE PRESSURE TABLE
        OPEN(IOATM,FILE=FATM, STATUS='OLD')
C GET ABUNDANCE:
        READ(IOATM,200) ATMZ
  200   FORMAT(1X,10X,1PE16.8,/)
C GET VALUES OF LOG Teff:
        READ(IOATM,201) (ATMTL(I),I=1,NT)
  201   FORMAT(1P4E16.8,13(/1P4E16.8),/1PE16.8,/)
C GET VALUES OF LOG G:
        READ(IOATM,202) (ATMGL(I),I=1,NG)
  202   FORMAT(1P4E16.8,/1P4E16.8,/1P3E16.8,/)
C GET GRID OF LOG PRESSURE VALUES:
        DO 205 J=1,NT
          READ(IOATM,203) (ATMPL(J,I),I=1,NG)
  203     FORMAT(1P4E16.8,/1P4E16.8,/1P3E16.8)
  205   CONTINUE
        REWIND IOATM
        CLOSE(IOATM)
C       G Somers 5/15; added a catch that allows the code to work
C                      if the highest gravity P value for a specific
C                      temperature is -999. LCATCH is set to true
C                      once the first valid P is read, and it can
C                      set the minimum P thereafter.
         DO J = 1,NT
            LCATCH = .FALSE.
            DO K = NG,1,-1
               IF(ATMPL(J,K).LE.0.0D0)THEN
C                 check if the first non-999 value has been reached.
C                 if so, set IMIN.
                  IF(LCATCH)THEN
                     IMIN(J) = K + 1
                     GOTO 5
                  ENDIF
               ELSE
C                 if we have reached a non-negative pressure value,
C                 turn off the catch so IMIN can be set. also record
C                 the highest gravity with a pressure for later int.
                  IF(.NOT.LCATCH) IMINMAX(J) = K
                  LCATCH = .TRUE.
               ENDIF
            END DO
            IMIN(J) = 1
    5       CONTINUE
C           if all of the P values at a given T are -999, set IMIN
C           to the number of gravity terms. in responce, the code
C           should break when trying to find surface P.
            IF(.NOT.LCATCH) IMIN(J) = NG
         END DO
C        G Somers 5/15 END
C MHP 6/97 ADDED OPTION FOR ALLARD MODEL ATMOSPHERES; USED INSTEAD OF
C KURUCZ FOR TEFF < 10,000 K.
         IF(KTTAU .EQ. 4)THEN
C            ATMZA = 0.02D0
          CALL ALFileIn      ! Get Allard Atmospheres files and
         ENDIF                  ! initialize tables. 9/23/08 LLP


C JNT 6/14 ADD OPTION FOR NEW KURUCZ/CASTELLI ATMOSHPERES
      ELSE IF (KTTAU .EQ. 5) THEN
C OPEN SURFACE PRESSURE TABLE
        OPEN(IOATM,FILE=FATM, STATUS='OLD')
C GET ABUNDANCE:
        READ(IOATM,200) ATMZ
C GET VALUES OF LOG Teff:
        READ(IOATM,206) (ATMTLC(I),I=1,NTC)
  206   FORMAT(1P4E16.8,18(/1P4E16.8),/)
C GET VALUES OF LOG G:
        READ(IOATM,208) (ATMGLC(I),I=1,NGC)
  208   FORMAT(1P4E16.8,/1P4E16.8,/1P3E16.8,/)
C GET GRID OF LOG PRESSURE VALUES:
        DO 207 J=1,NTC
          READ(IOATM,203) (ATMPLC(J,I),I=1,NGC)
  207   CONTINUE
        REWIND IOATM
        CLOSE(IOATM)
C       G Somers 5/15; added a catch that allows the code to work
C                      if the highest gravity P value for a specific
C                      temperature is -999. LCATCH is set to true
C                      once the first valid P is read, and it can
C                      set the minimum P thereafter.
        DO J = 1,NTC
           LCATCH = .FALSE.
           DO K = NGC,1,-1
              IF(ATMPLC(J,K).LE.0.0D0)THEN
C                check if the first non-999 value has been reached.
C                if so, set IMIN2.
                 IF(LCATCH)THEN
                    IMIN2(J) = K + 1
                    GOTO 6
                 ENDIF
              ELSE
C                if we have reached a non-negative pressure value,
C                turn off the catch so IMIN2 can be set. also record
C                the highest gravity with a pressure for later int.
                 IF(.NOT.LCATCH) IMINMAX2(J) = K
                 LCATCH = .TRUE.
              ENDIF
           END DO
           IMIN2(J) = 1
    6      CONTINUE
C          if all of the P values at a given T are -999, set IMIN
C          to the number of gravity terms. in responce, the code
C          should break when trying to find surface P.
           IF(.NOT.LCATCH) IMIN2(J) = NG
        END DO
C END JNT 6/14
      ENDIF

C MHP 5/97 ADDED OPTION FOR NEW SCV EQUATION OF STATE TABLES.
      IF(LSCV)THEN
         OPEN(UNIT=ISCVH,FILE=FSCVH,STATUS='OLD')
         OPEN(UNIT=ISCVHE,FILE=FSCVHE,STATUS='OLD')
         OPEN(UNIT=ISCVZ,FILE=FSCVZ,STATUS='OLD')
C  READ IN EQUATION OF STATE TABLES FOR HYDROGEN AND HELIUM
         DO I = 1, NTS
            READ(ISCVH,1) TLOGX(I),NPTSX(I)
            READ(ISCVHE,1) DUM1,DUM2
            READ(ISCVZ,1) DUM3,DUM4
    1       FORMAT(F5.2,I4)
C TABLE GRID POINTS IN T, P(T) ARE THE SAME - NPTSY AND TLOGX
C READ IN TO RETAIN PARALLEL COMMON BLOCK STRUCTURE.
            DO J = 1, NPTSX(I)
               READ(ISCVH,2) (TABLEX(I,J,K),K=1,11)
               READ(ISCVHE,2) (TABLEY(I,J,K),K=1,11)
    2          FORMAT(F6.2,1P2E13.5,0P,8F9.4)
            END DO
C  READ IN METAL EQUATION OF STATE TABLE; COMPUTED USING THE PRATHER
C EQUATION OF STATE IN THE OLD YALE CODE.
            DO J = NPTSX(I),1,-1
               READ(ISCVZ,3)(TABLEZ(I,J,K),K=1,13)
 3             FORMAT(F6.2,12F9.4)
            END DO
         END DO
      ENDIF

      RETURN
      END
