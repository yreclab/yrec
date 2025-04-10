*********************************************************
      SUBROUTINE LUDCMP(A,N,NP,INDX,D)

      IMPLICIT REAL*8(A-H,O-Z)

C     .. Parameters ..
      INTEGER NMAX
C      REAL TINY
      PARAMETER (NMAX=100,TINY=1.0D-20)
C     ..
C     .. Scalar Arguments ..
C      REAL D
      INTEGER N,NP
C     ..
C     .. Array Arguments ..
      DIMENSION A(NP,NP)
      INTEGER INDX(N)
C     ..
C     .. Local Scalars ..
C      REAL AAMAX,DUM,SUM
      INTEGER I,IMAX,J,K
C     ..
C     .. Local Arrays ..
      DIMENSION VV(NMAX)
      SAVE
C     ..
C     .. Intrinsic Functions ..
      INTRINSIC ABS
C     ..
      D = 1.D0
      DO 12 I = 1,N
          AAMAX = 0.D0
          DO 11 J = 1,N
              IF (ABS(A(I,J)).GT.AAMAX) AAMAX = ABS(A(I,J))
   11     CONTINUE
          IF (AAMAX.EQ.0D0) STOP 'Singular matrix.'
          VV(I) = 1.D0/AAMAX
   12 CONTINUE
      DO 19 J = 1,N
          IF (J.GT.1) THEN
              DO 14 I = 1,J - 1
                  SUM = A(I,J)
                  IF (I.GT.1) THEN
                      DO 13 K = 1,I - 1
                          SUM = SUM - A(I,K)*A(K,J)
   13                 CONTINUE
                      A(I,J) = SUM
                  END IF

   14         CONTINUE
          END IF

          AAMAX = 0.D0
          DO 16 I = J,N
              SUM = A(I,J)
              IF (J.GT.1) THEN
                  DO 15 K = 1,J - 1
                      SUM = SUM - A(I,K)*A(K,J)
   15             CONTINUE
                  A(I,J) = SUM
              END IF

              DUM = VV(I)*ABS(SUM)
              IF (DUM.GE.AAMAX) THEN
                  IMAX = I
                  AAMAX = DUM
              END IF

   16     CONTINUE
          IF (J.NE.IMAX) THEN
              DO 17 K = 1,N
                  DUM = A(IMAX,K)
                  A(IMAX,K) = A(J,K)
                  A(J,K) = DUM
   17         CONTINUE
              D = -D
              VV(IMAX) = VV(J)
          END IF

          INDX(J) = IMAX
          IF (J.NE.N) THEN
              IF (A(J,J).EQ.0D0) A(J,J) = TINY
              DUM = 1.D0/A(J,J)
              DO 18 I = J + 1,N
                  A(I,J) = A(I,J)*DUM
   18         CONTINUE
          END IF

   19 CONTINUE
      IF (A(N,N).EQ.0D0) A(N,N) = TINY
      RETURN

      END
