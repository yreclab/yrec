C MHP 4/19 Program for extracting rotation distributions at fixed age.
C the underlying input is from the ROTEVOL code.
      IMPLICIT REAL*8 (A-H, O-Z)
      IMPLICIT LOGICAL*4 (L)
C MAXIMUM NUMBER OF MASS TRACKS AND MODELS PER TRACK RESPECTIVELY
      PARAMETER(NTRACK=40,NMOD=20000)
C INPUTS FROM TRACKS - CGS OR SOLAR UNITS AS NOTED
C SAGE = AGE (YR), SL = L/LSUN SR = R/RSUN SM = M/MSUN
C SRCZ = R OF CZ BASE (CGS) SMCZ = MASS OF SURFACE CZ, MSUN
C SI, SIE, SIC = CGS MOMENT OF INERTIA TOTAL, CORE, ENVELOPE
C STAUCZ = CONVECTIVE OVERTURN TIMESCALE (SEC), SP = ATM PRESSURE TAU=2/3
C SXC = CENTRAL X SHEC= POST-MS HE CORE MASS (MSUN), BOTH USED FOR ISOCHRONES
      REAL*8 SAGE(NTRACK,NMOD),SL(NTRACK,NMOD),SR(NTRACK,NMOD),
     * SM(NTRACK,NMOD),SRCZ(NTRACK,NMOD),SMCZ(NTRACK,NMOD),
     * SI(NTRACK,NMOD),SIE(NTRACK,NMOD),SIC(NTRACK,NMOD),
     * STAUCZ(NTRACK,NMOD),SP(NTRACK,NMOD),
     * SXC(NTRACK,NMOD),SHEC(NTRACK,NMOD),STEFF(NTRACK,NMOD)
C NM = VECTOR OF TRACK LENGTHS
      INTEGER*4 NM(NTRACK),IDUM1,IDUM2,NUMROT
C OUTPUT VECTORS - CGS UNITS
C SWE = OMEGA(ENV), SWC = OMEGA(CORE), SJ= TOTAL J SJE = ENVELOPE J
C SJC = CORE J SPROT = SURFACE PERIOD (DAYS)
      REAL*8 SWE(NTRACK,NMOD),SWC(NTRACK,NMOD),SJ(NTRACK,NMOD),
     * SJE(NTRACK,NMOD),SJC(NTRACK,NMOD),SPROT(NTRACK,NMOD)
      REAL*8 FSTRUCT(NTRACK,NMOD),FCZ(NTRACK,NMOD),
     *       FCEN(NTRACK,NMOD),FAC_CEN(NTRACK,NMOD),B_BSOL(NTRACK,NMOD),
     *       DMDT(NTRACK,NMOD)
C PERMIT UP TO 40 ROTATION CASES
      REAL*8 TDISK0(40),PDISK0(40),A(4),B(4),AGE
      SAVE
      NUMROT=31
      IOUT=20
      AGE = 0.690
      WRITE(IOUT,101)
 101  FORMAT(12X,'MASS',11X,'PINIT',12X,'PROT',10X,'OMEGAE',10X,
     *      'ROSSBY',12X,'TEFF',10X,'L/LSUN',10X,
     *      'R/RSUN',11X,'TAUCZ',12X,'ITOT',12X,
     *      'JTOT')
      DO III=1,NUMROT
         IIN = 59+III
C OUTPUT DATA
         OPEN(UNIT=IIN,STATUS='UNKNOWN')
         READ(IIN,93) INUMT
 93      FORMAT(17X,I4)
         READ(IIN,95)(IDUM1,NM(JJ),DUM1,DUM2,JJ=1,INUMT)
 95      FORMAT(2I5,2F8.4)
C READ HEADER
         J = 1
         K = 1
         READ(IIN,90)IDUM1,IDUM2,SAGE(J,K),SL(J,K),SR(J,K),STEFF(J,K),
     *   SMCZ(J,K),SRCZ(J,K),SXC(J,K),SI(J,K),SIE(J,K),
     *   STAUCZ(J,K),SHEC(J,K),SP(J,K),SM(J,K),SPROT(J,K),
     *   SIC(J,K),SWC(J,K),SWE(J,K),SJ(J,K),SJC(J,K),SJE(J,K),
     *   FAC_CEN(J,K),B_BSOL(J,K),DMDT(J,K)
 90      FORMAT(/2I4,23E16.8)
         DO K = 2,NM(J)
            READ(IIN,100)IDUM1,IDUM2,SAGE(J,K),SL(J,K),SR(J,K),STEFF(J,K),
     *      SMCZ(J,K),SRCZ(J,K),SXC(J,K),SI(J,K),SIE(J,K),
     *      STAUCZ(J,K),SHEC(J,K),SP(J,K),SM(J,K),SPROT(J,K),
     *      SIC(J,K),SWC(J,K),SWE(J,K),SJ(J,K),SJC(J,K),SJE(J,K),
     *      FAC_CEN(J,K),B_BSOL(J,K),DMDT(J,K)
 100        FORMAT(2I4,23E16.8)
         END DO
         DO J = 2,INUMT
            DO K = 1,NM(J)
               READ(IIN,100)IDUM1,IDUM2,SAGE(J,K),SL(J,K),SR(J,K),
     *         STEFF(J,K),SMCZ(J,K),SRCZ(J,K),SXC(J,K),SI(J,K),SIE(J,K),
     *         STAUCZ(J,K),SHEC(J,K),SP(J,K),SM(J,K),SPROT(J,K),
     *         SIC(J,K),SWC(J,K),SWE(J,K),SJ(J,K),SJC(J,K),SJE(J,K),
     *         FAC_CEN(J,K),B_BSOL(J,K),DMDT(J,K)
            END DO
         END DO
C NOW EXTRACT ISOCHRONE FILE AND WRITE OUT THE RESULT
         DO J = 1,INUMT
            IF(NM(J).LT.4)GOTO 105
            DO K = 3,NM(J)-1
C FIND FIRST TRACK ABOVE THE TARGET AGE
               IF(SAGE(J,K).GT.AGE)THEN
               KK = K - 2
               DO I = 1,4
                  A(I)=SAGE(J,KK+I-1)
               END DO
               X = AGE
               CALL INTRP2(A,B,X)
               SOMEGAE = B(1)*SWE(J,KK)+B(2)*SWE(J,KK+1)+
     *                    B(3)*SWE(J,KK+2)+B(4)*SWE(J,KK+3)
               SPERIOD = B(1)*SPROT(J,KK)+B(2)*SPROT(J,KK+1)+
     *                    B(3)*SPROT(J,KK+2)+B(4)*SPROT(J,KK+3)
               SITOT = B(1)*SI(J,KK)+B(2)*SI(J,KK+1)+
     *                    B(3)*SI(J,KK+2)+B(4)*SI(J,KK+3)
               STEMP = B(1)*STEFF(J,KK)+B(2)*STEFF(J,KK+1)+
     *                    B(3)*STEFF(J,KK+2)+B(4)*STEFF(J,KK+3)
               SLUM = B(1)*SL(J,KK)+B(2)*SL(J,KK+1)+
     *                    B(3)*SL(J,KK+2)+B(4)*SL(J,KK+3)
               SRAD = B(1)*SR(J,KK)+B(2)*SR(J,KK+1)+
     *                    B(3)*SR(J,KK+2)+B(4)*SR(J,KK+3)
               STCZ = B(1)*STAUCZ(J,KK)+B(2)*STAUCZ(J,KK+1)+
     *                    B(3)*STAUCZ(J,KK+2)+B(4)*STAUCZ(J,KK+3)
               SJTOT = B(1)*SJ(J,KK)+B(2)*SJ(J,KK+1)+
     *                    B(3)*SJ(J,KK+2)+B(4)*SJ(J,KK+3)
               IF(STCZ.GT.0.0)THEN
                  SROSS = SPERIOD*3.6e3*24.0/STCZ
               ELSE
                  STOP911
               ENDIF
               GOTO 110
               ENDIF
            END DO
 105        CONTINUE
C NO VALID ENTRY AT THIS MASS AND AGE. ASSIGN 9999 VALUES
               SOMEGAE = -9999.0
               SPERIOD = -9999.0
               SITOT = -9999.0
               STEMP = -9999.0
               SLUM = -9999.0
               SRAD = -9999.0
               STCZ = -9999.0
               SJTOT = -9999.0
               SROSS = -9999.0
 110        CONTINUE
            WRITE(IOUT,120)SM(J,1),SPROT(J,1),SPERIOD,SOMEGAE,
     *      SROSS,STEMP,SLUM,SRAD,STCZ,SITOT,SJTOT
 120        FORMAT(1P11E16.8)
         END DO
      END DO
      STOP
      END
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C INTEP2
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE INTRP2(A,B,X)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION A(4),B(4)
      SAVE
C INTRP2 IS A 4-POINT LAGRANGIAN INTERPOLATION SCHEME WITHOUT DERIVATIVES
      A43 = A(4) - A(3)
      A42 = A(4) - A(2)
      A41 = A(4) - A(1)
      A32 = A(3) - A(2)
      A31 = A(3) - A(1)
      A21 = A(2) - A(1)
      D1 = -A21*A31*A41
      D2 = A21*A32*A42
      D3 = -A31*A32*A43
      D4 = A41*A42*A43
      XA1 = X - A(1)
      XA2 = X - A(2)
      XA3 = X - A(3)
      XA4 = X - A(4)
      B(1) = (XA2*XA3*XA4)/D1
      B(2) = (XA1*XA3*XA4)/D2
      B(3) = (XA1*XA2*XA4)/D3
      B(4) = (XA1*XA2*XA3)/D4
      RETURN
      END

