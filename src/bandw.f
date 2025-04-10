C $$$$$$
      SUBROUTINE BANDW(A,NM,M1,M2,B)
      PARAMETER (JSON=5000, NMAX=8000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      INTEGER*4 M1,M2,NM
      REAL*8 A(NMAX,10),B(NMAX),TINY
      PARAMETER (TINY=1.D-20)
      INTEGER*4 I,J,K
      SAVE
C INITIAL STEP: DIAGONALIZE TERMS INVOLVING OMEGA(1)
C AND THEN STEP THROUGH ITS FIRST THROUGH THIRD
C DERIVATIVES.  THEN PROCEED TO THE SECOND SHELL AND
C REPEAT, GOING TO THE BOTTOM.  THE REMAINDER OF THE
C TERMS CAN THEN BE REMOVED THROUGH BACKSUBSTITUTION.
C      DO I = 1,NM-5,4
C INITIAL STEP: DIAGONALIZE OMEGA(II) TERM.
C         I1 = I+1
C         I2 = I+2
C         I3 = I+3
C         I4 = I+4
C         PIVOT = A(I,5)
      DO I = 1,NM-5
         IF(ABS(A(I,5)).LT.TINY)THEN
            WRITE(*,911)I,(A(I,J),J=1,10)
            STOP 999
         ENDIF
 911     FORMAT(I5,1P10E12.3)
         B(I) = B(I)/A(I,5)
         DO J = 6,10
C         DO J = 5,10
            A(I,J) = A(I,J)/A(I,5)
         END DO
         DO J = I+1,I+4
            IMJ = I - J
            IMJ5 = 5 + IMJ
C            WRITE(*,*)I,J,IMJ5
            B(J) = B(J) - A(J,IMJ5)*B(I)
            DO K = IMJ5+1,10+IMJ
C               WRITE(*,*)I,J,K,IMJ5,K+J-I
               A(J,K) = A(J,K)-A(J,IMJ5)*A(I,K+J-I)
            END DO
         END DO
      END DO
      DO I = NM-4,NM-1
         II = NM-I
         IF(ABS(A(I,5)).LT.TINY)THEN
            WRITE(*,911)I,(A(I,J),J=1,10)
            STOP 999
         ENDIF
         B(I) = B(I)/A(I,5)
C         WRITE(*,*)I,B(I),A(I,5)
C         DO J = 5,5+II
         DO J = 6,5+II
            A(I,J) = A(I,J)/A(I,5)
         END DO
C         WRITE(*,*)I,(J,A(I,J),J=6,5+II)
         DO J = I+1,NM
            IMJ = I - J
            IMJ5 = 5 + IMJ
            B(J) = B(J) - A(J,IMJ5)*B(I)
C            WRITE(*,*)I,J,B(I),B(J),IMJ5,A(J,IMJ5)
            DO K = IMJ5+1,IMJ5+II
               A(J,K) = A(J,K)-A(J,IMJ5)*A(I,K+J-I)
C               WRITE(*,*)I,J,K,A(J,K),IMJ5,A(J,IMJ5),
C     *                   K+J-I,A(I,K+J-I)
            END DO
         END DO
      END DO            
      IF(ABS(A(NM,5)).LT.TINY) STOP 999
      B(NM) = B(NM)/A(NM,5)
C      WRITE(*,*)NM,B(NM),A(NM,5)
C      WRITE(*,912)((A(I,JJ),JJ=1,10),B(I),I=1,NM)
C 912  FORMAT(1P11E12.3)
      
C D2W/DR2 TERM
C         PIVOT = A(I+2,3)
C         B(I1) = B(I1) - A(I1,4)*B(I)
C         DO J = 5,9
C         DO J = 4,9
C            A(I1,J) = A(I1,J)-A(I1,4)*A(I,J+1)
C         END DO
C DW/DR (II) TERM
C         PIVOT = A(I+2,3)
C         B(I2) = B(I2)-A(I2,3)*B(I)
C         DO J = 4,8
C         DO J = 3,8
C            A(I2,J) = A(I2,J)-A(I2,3)*A(I,J+2)
C         END DO
C OMEGA(II+1) TERM
C         PIVOT = A(I+4,1)
C         B(I4) = B(I4)-A(I4,1)*B(I)
C         DO J = 1,6
C         DO J = 2,6
C            A(I4,J)= A(I4,J)-A(I4,1)*A(I,J+4)
C         END DO
C 3 NONZERO ENTRIES ABOVE I FOR THE NEXT TWO
C COLUMNS
C         DO J = I1,I2
C DIAGONALIZE ROW
C         IF(ABS(A(J,5)).LT.TINY)THEN
C            WRITE(*,911)J,(A(J,K),K=1,10)
C            STOP999
C         ENDIF
C            B(J)= B(J)/A(J,5)
C            K1 = 10 - J + I
C            DO K = 6,K1
C            DO K = 5,K1
C               A(J,K) = A(J,K)/A(J,5)
C            END DO
C CORRECT RHS
C            DO K = J+1,J+3
C               K2 = 5 - K + J
C               B(K) = B(K) - A(K,K2)*B(J)
C CORRECT LHS
C               K3 = K2 + 1
C               K4 = K3 + K1 - 6
C               DO JJ = K3,K4
C               DO JJ = K3-1,K4
C                  A(K,JJ) = A(K,JJ)-A(K,K2)*A(J,JJ+K-J)
C                  A(K,JJ) = A(K,JJ)-A(K,K2)*A(J,6+JJ-K3)
C               END DO
C            END DO
C         END DO
C D3W/DR3 TERM
C         K1 = 7
C CORRECT RHS
C         DO J = I3+1,I3+2
C            K2 = 5 - J + I3
C            B(J) = B(J) - A(J,K2)*B(I3)
C CORRECT LHS
C            K3 = K2 + 1
C            DO JJ = K3,K3+1
C            DO JJ = K3-1,K3+1
C               A(J,JJ) = A(J,JJ) - A(J,K2)*A(I3,JJ+J-I3)
C            END DO
C         END DO
C      END DO
C FINAL 2 ENTRIES ARE A BIT SIMPLER.
C      NM1 = NM - 1
C      IF(ABS(A(NM1,5)).LT.TINY)STOP999
C      B(NM1) = B(NM1)/A(NM1,5)
C      A(NM1,6) = A(NM1,6)/A(NM1,5)
C      IF(ABS(A(NM,5)).LT.TINY)STOP999
C      B(NM) = B(NM)/A(NM,5)
C      WRITE(*,912)((A(I,JJ),JJ=1,10),B(I),I=1,NM)
C 912  FORMAT(1P11E12.3)
C BACKSUBSTITUTION
C      DO I = NM,6,-4
      DO I = NM,6,-1
C REMOVE ENTRIES IN LAST COLUMN
C         DO J = I-1,I-5,-1
C            B(J) = B(J) - B(I)*A(J,5+I-J)
         DO J = -1,-5,-1
            B(I+J) = B(I+J) - B(I)*A(I+J,5-J)
         END DO
C         DO J = I-2,I-5,-1
C            B(J) = B(J) - B(I-1)*A(J,4+I-J)
C         END DO
C         DO J = I-3,I-5,-1
C            B(J) = B(J) - B(I-2)*A(J,3+I-J)
C         END DO
C         DO J = I-4,I-5,-1
C            B(J) = B(J) - B(I-3)*A(J,2+I-J)
C         END DO
C         DO J = I,I-3,-1
C            DO K = J-1,I-5,-1
C               KK = 5 + I - K
C               B(K) = B(K)-B(J)*A(K,KK)               
C            END DO
C         END DO
      END DO      
      DO I = 5,2,-1
         JJ = -(I-1)
         DO J = -1,JJ,-1
            B(I+J) = B(I+J) - B(I)*A(I+J,5-J)
         END DO
      END DO
C      B(1) = B(1) - B(2)*A(1,6)
      RETURN
      END
