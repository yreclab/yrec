C $$$$$$
C MHP 6/00 SUBROUTINE.  MIXING AND BURNING ARE PERFORMED SEQUENTIALLY
C FOR AN INCREASING NUMBER OF SUBSTEPS FOR A GIVEN TOTAL STEP.  THIS ROUTINE
C EXTRAPOLATES TO ZERO TIMESTEP, 
      SUBROUTINE BSROTMIX(DELTS,HCOMP,IEST,M,JBEG,NSPEC,NSEQ,LCONV)
      use params, only : json
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      DIMENSION HCOMP(15,JSON),NSEQ(11),X(11),D(15,JSON),JJ(15)
      COMMON/BSBURN/HCOMPI(11,15,JSON),HCOMPA(15,JSON),HCOMPE(15,JSON)
      LOGICAL*4 LDO(15), LCNO(JSON),LHE3(JSON)
      SAVE
C      SAVE X,D,JJ,LDO,NMAX,LCNO,LCNCHECK
C DETERMINE WHICH SPECIES REQUIRE CALCULATION
      IF(IEST.EQ.1)THEN
         DO J = JBEG,NSPEC
            LDO(J) = .FALSE.
            DO I = M,1,-1
               IF(HCOMP(J,I).GT.1.0D-14)THEN
                  LDO(J) = .TRUE.
                  GOTO 5
               ENDIF
            END DO
 5          CONTINUE
         END DO
         IF(LDO(4))THEN
            DO I = 1,M
               IF(HCOMP(4,I).GT.1.0D-24)THEN
                  LHE3(I) = .TRUE.
               ELSE
                  LHE3(I) = .FALSE.
               ENDIF
            END DO
         ENDIF
C CHECK FOR ALTERNATE METHOD FOR DOING CNO ABUNDANCES; SOLVE FOR
C C13/C12, N14/C12, O16/N14, SUM OF CNO NUCLEI RATHER THAN FOR
C THE INDIVIDUAL ABUNDANCES OF C12,C13,N14,O16.
         IF(LDO(5).AND.LDO(6).AND.LDO(7).AND.LDO(9))THEN
            LCNCHECK = .TRUE.
            DO I = 1,M
               IF(HCOMP(5,I).GT.1.0D-24 .AND. HCOMP(6,I).GT.1.0D-24
     *   .AND. HCOMP(7,I).GT.1.0D-24 .AND. HCOMP(9,I).GT.1.0D-24)THEN
                  LCNO(I) = .TRUE.
               ELSE
                  LCNO(I) = .FALSE.
               ENDIF
            END DO
         ELSE
            LCNCHECK = .FALSE.
            DO I = 1,M
               LCNO(I) = .FALSE.
            END DO
         ENDIF
         ICOUNT = 1
         DO I = JBEG,NSPEC
            IF(LDO(I))THEN
               JJ(ICOUNT) = I
               ICOUNT = ICOUNT+1
            ENDIF
         END DO
         NMAX = ICOUNT - 1
         IF(NMAX.LT.1)STOP999
      ENDIF
C STORE CURRENT RESULTS IN VECTOR OF COMPOSITION (HCOMPA) AND 
C ERROR (DCOMPA)
      DO J1 = 1,NMAX
         J = JJ(J1)
         DO I = 1,M
            HCOMPA(J,I) = HCOMP(J,I)
            HCOMPE(J,I) = HCOMP(J,I)
         END DO
      END DO 
C EXTRAPOLATE IN THE LOG OF HE3 RATHER THAN ABSOLUTE ABUNDANCE
      IF(LDO(4))THEN
         DO I = 1,M
            IF(LHE3(I))THEN
               HCOMPA(4,I) = LOG(HCOMP(4,I))
               HCOMPE(4,I) = HCOMPA(4,I)
            ENDIF
         END DO
      ENDIF
      IF(LCNCHECK)THEN
         DO I = 1,M
            IF(LCNO(I))THEN
               X12 = HCOMP(5,I)
               X13 = HCOMP(6,I)
               X14 = HCOMP(7,I)
               X16 = HCOMP(9,I)
C VECTOR 5: C13/C12
               HCOMPA(5,I) = X13/X12
               HCOMPE(5,I) = HCOMPA(5,I)
C VECTOR 6: N14/C12
               HCOMPA(6,I) = X14/X12
               HCOMPE(6,I) = HCOMPA(6,I)
C VECTOR 7: O16/N14
               HCOMPA(7,I) = X16/X14
               HCOMPE(7,I) = HCOMPA(7,I)
C VECTOR 9: C12/12 + C13/13 + N14/14 + O16/16
               HCOMPA(9,I) = X12/12.0D0 + X13/13.0D0 + X14/14.0D0
     *                     + X16/16.0D0
               HCOMPE(9,I) = HCOMPA(9,I)
            ENDIF
         END DO
      ENDIF
C SET CURRENT RESULTS AS THE INITIAL EXTRAPOLATION FOR THE FIRST SET OF
C TIME STEPS AND EXIT.
      X(IEST) = (DELTS/DFLOAT(NSEQ(IEST)))**2
      IF(IEST.EQ.1)THEN
         DO J1 = 1,NMAX
            J = JJ(J1)
            DO I = 1,M
               HCOMPI(IEST,J,I) = HCOMP(J,I)
            END DO
         END DO
         IF(LDO(4))THEN
            DO I = 1,M
               IF(LHE3(I))THEN
                  HCOMPI(IEST,4,I) = LOG(HCOMP(4,I))
               ENDIF
            END DO
         ENDIF
         IF(LCNCHECK)THEN
            DO I = 1,M
               IF(LCNO(I))THEN
                  HCOMPI(IEST,5,I) = HCOMPA(5,I)
                  HCOMPI(IEST,6,I) = HCOMPA(6,I)
                  HCOMPI(IEST,7,I) = HCOMPA(7,I)
                  HCOMPI(IEST,9,I) = HCOMPA(9,I)
               ENDIF
             END DO
          ENDIF 
        LCONV = .FALSE.
      ELSE
C POLYNOMIAL FUNCTION EXTRAPOLATON
C CURRENT STEPSIZE
         XEST = X(IEST)
         DO J1 = 1,NMAX
            J = JJ(J1)
            DO I = 1,M
               D(J,I) = HCOMP(J,I)
            END DO
         END DO
         IF(LDO(4))THEN
            DO I = 1,M
               IF(LHE3(I))THEN
                  D(4,I) = LOG(HCOMP(4,I))
               ENDIF
            END DO
         ENDIF
         IF(LCNCHECK)THEN
            DO I = 1,M
               IF(LCNO(I))THEN
                  X12 = HCOMP(5,I)
                  X13 = HCOMP(6,I)
                  X14 = HCOMP(7,I)
                  X16 = HCOMP(9,I)
C VECTOR 5: C13/C12
                  D(5,I) = X13/X12
C VECTOR 6: N14/C12
                  D(6,I) = X14/X12
C VECTOR 7: O16/N14
                  D(7,I) = X16/X14
C VECTOR 9: C12/12 + C13/13 + N14/14 + O16/16
                  D(9,I) = X12/12.0D0 + X13/13.0D0 + X14/14.0D0
     *                   + X16/16.0D0
               ENDIF
            END DO
         ENDIF
         DO K1 = 1,IEST-1
            DELTA = 1.0D0/(X(IEST-K1)-XEST)
            F1 = XEST*DELTA
            F2 = X(IEST-K1)*DELTA
            DO J1 = 1,NMAX
               J = JJ(J1)
               DO I = 1,M
                  Q = HCOMPI(K1,J,I)
                  HCOMPI(K1,J,I) = HCOMPE(J,I)
                  DELTA = D(J,I) - Q
                  HCOMPE(J,I) = F1*DELTA
                  D(J,I) = F2*DELTA
                  HCOMPA(J,I) = HCOMPA(J,I)+HCOMPE(J,I)
               END DO
            END DO
         END DO
         DO J1 = 1,NMAX
            J = JJ(J1)
            DO I = 1,M
               HCOMPI(IEST,J,I) = HCOMPE(J,I)
            END DO
         END DO
C NOW CHECK IF ERROR IS WITHIN TOLERANCE
         ERRMAX = 1.0D-30
         IMAX = 1
         JMAX = 1
         DO J1 = 1,NMAX
            J = JJ(J1)
            DO I = 1,M
               IF(HCOMPA(J,I).GT.1.0D-12)THEN
                  Q = HCOMPE(J,I)/HCOMPA(J,I)
                  IF(ABS(Q).GT.ERRMAX)THEN
                     IMAX = I
                     JMAX = J
                     ERRMAX=ABS(Q)
                  ENDIF
               ENDIF
            END DO
         END DO
c         WRITE(*,*)HCOMP(JMAX,IMAX),HCOMPA(JMAX,IMAX)
         WRITE(*,10)IEST,ERRMAX,JMAX,IMAX,HCOMP(JMAX,IMAX),
     *              HCOMPA(JMAX,IMAX)
         IF(ERRMAX.LT.1.0D-3)LCONV=.TRUE.
         IF(LCONV)THEN
 10      FORMAT(5X,'ITER',I3,' MAX ERR ',1PE10.2,' SPECIES ',I3,
     *          ' SHELL ',I5,' ABUND',2E12.4)
C NOW CONVERT BACK TO ABSOLUTE ABUNDANCES.
            IF(LDO(4))THEN
               DO I =1,M
                  IF(LHE3(I))THEN
                     HCOMPA(4,I)=EXP(HCOMPA(4,I))
                  ENDIF
               END DO
            ENDIF
            IF(LCNCHECK)THEN
               DO I = 1,M
                  IF(LCNO(I))THEN
C VECTOR NINE IS C12/12+ C13/13 + N14/14 + O16/16.
C THEREFORE, C12 = SUMCNO/(1/12 + C13/C12*1/13 + N14/C12*1/14 +
C O16/N14*N14/C12*1/16)
                     SUM = (1.0D0/12.0D0) + (HCOMPA(5,I)/13.0D0) + 
     *                     (HCOMPA(6,I)/14.0D0)
     *                   + (HCOMPA(6,I)*HCOMPA(7,I)/16.0D0)
                     X12 = HCOMPA(9,I)/SUM
                     X13 = HCOMPA(5,I)*X12
                     X14 = HCOMPA(6,I)*X12
                     X16 = HCOMPA(7,I)*X14
c       WRITE(*,911)X12,X13,X14,X16,HCOMPA(5,I),HCOMPA(6,I),
c     *             HCOMPA(7,I),HCOMPA(9,I),SUM
c 911   FORMAT(1P9E10.2)
                     HCOMPA(5,I) = X12
                     HCOMPA(6,I) = X13
                     HCOMPA(7,I) = X14
                     HCOMPA(9,I) = X16
                  ENDIF
               END DO
            ENDIF
            DO J1 = 1,NMAX
               J = JJ(J1)
               DO I = 1,M
                  HCOMP(J,I) = HCOMPA(J,I)
                  IF(HCOMP(J,I).LT.1.0D-24)HCOMP(J,I)=0.0D0
               END DO
            END DO
         ENDIF
      ENDIF
      RETURN
      END
