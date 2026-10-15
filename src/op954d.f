C
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     OP954D
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE OP954D(O,OL,QOD,QOT)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/OP95INTERP/ into OP95INTERP_MOD.
      USE OP95INTERP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/LLOT95A/ into LLOT95A_MOD.
      USE LLOT95A_MOD
C MHP 7/98 GET OPAL95 OPACITY FROM FULL SET OF OPACITY TABLES.
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C FULL SET OF TABLES: OPACITY AS A FUNCTION OF Z AND X, T, RHO/T6**3
C TABLES ARE INCREMENTED IN SETS OF NZ*NX.  SO THE TABLES FOR THE
C THIRD METAL ABUNDANCE (3 X 10**-4)BEGIN AT TABLE 21 AND END AT TABLE 30.
C FOR THE HIGH VALUES OF Z, THE NUMBER OF X TABLES IS NOT THE SAME (I.E.
C X<0.9 FOR Z=0.1).
C FOR EACH COMPOSITION A FULL GRID IN (T,RHO/T6**3) IS RETAINED.
C INDICES FOR INTERPOLATION IN Z,X,T, AND R; INTERPOLATION FACTORS FOR
C Z,X,T, AND R (AND DERIVATIVE FACTORS FOR T AND RHO); AND DATA FOR
C LINEAR EXTRAPOLATION WHEN OUTSIDE THE TABLE IN RHO.
C 10/9/26 MHP via Claude
C code changed to merge COMMON/OP95INDX/, COMMON/OP95FACT/, and
C COMMON/OP95EXT/ into COMMON/OP95INTERP/ (see getopal95.f for the
C full rationale).
C 10/13/26 MHP via Claude
C code changed to rename COMMON/OP95INTERP/'s RL and RLL to RHO_T63L and
C RHO_T63LL.  RL is log(rho/T6**3), set here as RL = DL - 3*(TL-6); the
C old names clash with RL and RLL as used for radius throughout the rest
C of the code, which is why main.f declared only a 10-member prefix of
C this block to avoid importing them.  With the clash gone main.f can
C declare the full block, which a USE statement will require once this
C becomes a module.
      DIMENSION C(4),QC(4),CC(4),CCT(4),CCD(4),CZ(4),CZT(4),CZD(4)
      SAVE
C FIND OPACITY AT EACH OF THE 4 NEARBY VALUES OF Z
      DO K = 1,4
         IZ = NZ(JZ+K-1)
C FIND OPACITY AT EACH OF THE 4 NEARBY VALUES OF X
         DO J = 1,4
            IXZ = JX(K,J)+IZ
C FOR EACH X, GET CAPPA FOR 4 VALUES OF T
            DO I = 1,4
               IT = JT + I - 1
C FOR EACH T, GET CAPPA FOR 4 VALUES OF R
               ID = JD(I)
C LOG CAPPA AT DESIRED RHO FOR EACH OF THE 4 DESIRED T.
               C(I) = BD(I,1)*CAPPA2(IXZ,IT,ID) +
     *                BD(I,2)*CAPPA2(IXZ,IT,ID+1)
     *               + BD(I,3)*CAPPA2(IXZ,IT,ID+2)
     *              + BD(I,4)*CAPPA2(IXZ,IT,ID+3)
C D LOG CAPPA/D LOG R FOR EACH OF THE 4 DESIRED T.
               QC(I) = BDD(I,1)*CAPPA2(IXZ,IT,ID)
     *               + BDD(I,2)*CAPPA2(IXZ,IT,ID+1)
     *                + BDD(I,3)*CAPPA2(IXZ,IT,ID+2)
     *               + BDD(I,4)*CAPPA2(IXZ,IT,ID+3)
            END DO
C CHECK ON WHETHER RHO IS OUTSIDE OF THE TABLE AND NEEDS EXTRAPOLATION
            IF(LEXTL)THEN
C FACTOR IN R
               DELTAR = RHO_T63L-RHO_T63LL
C CORRECT CAPPA BY USING THE DERIVATIVE AT THE BOUNDARY.
               DO I = 1,4
                  C(I) = C(I)+DELTAR*QC(I)
               END DO
            ELSE IF(LEXTH)THEN
               DO I = 1,4
                  IF(LEXH(I))THEN
                     DELTAR = RHO_T63L - RLH(I)
                     C(I) = C(I)+DELTAR*QC(I)
                  ENDIF
               END DO
            ENDIF
C INTERPOLATE FOR LOG CAPPA IN T.
            CC(J) = BT(1)*C(1) + BT(2)*C(2) + BT(3)*C(3)
     *            + BT(4)*C(4)
C D LOG CAPPA/D LOG T
            CCT(J) = BTT(1)*C(1) + BTT(2)*C(2) + BTT(3)*C(3)
     *             + BTT(4)*C(4)
C D LOG CAPPA/D LOG R
            CCD(J) = BT(1)*QC(1) + BT(2)*QC(2) + BT(3)*QC(3)
     *             + BT(4)*QC(4)
         END DO
C INTERPOLATE FOR LOG CAPPA IN X.
         CZ(K) = BX(K,1)*CC(1) + BX(K,2)*CC(2) + BX(K,3)*CC(3) +
     *           BX(K,4)*CC(4)
C INTERPOLATE FOR QOT IN X.
         CZT(K) = BX(K,1)*CCT(1) + BX(K,2)*CCT(2) + BX(K,3)*CCT(3) +
     *            BX(K,4)*CCT(4)
C INTERPOLATE FOR QOD IN X.
         CZD(K) = BX(K,1)*CCD(1) + BX(K,2)*CCD(2) + BX(K,3)*CCD(3) +
     *            BX(K,4)*CCD(4)
      END DO
C INTERPOLATE FOR LOG CAPPA IN Z.
      OL = BZ(1)*CZ(1) + BZ(2)*CZ(2) + BZ(3)*CZ(3) +
     *     BZ(4)*CZ(4)
C INTERPOLATE FOR QOT IN Z.
      QOT = BZ(1)*CZT(1) + BZ(2)*CZT(2) + BZ(3)*CZT(3) +
     *     BZ(4)*CZT(4)
C INTERPOLATE FOR QOD IN Z.
      QOD = BZ(1)*CZD(1) + BZ(2)*CZD(2) + BZ(3)*CZD(3) +
     *     BZ(4)*CZD(4)
C CORRECT FROM DERIVATE AT FIXED R TO DERIVATIVE AT FIXED RHO.
      QOT = QOT - 3.0D0*QOD
      O = 1.0D1**OL
      RETURN
      END
