C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHDPX1
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MHDPX1(PL,TL,X)
C
C     MHDST MUST BE CALLED IN MAIN.                                            
C     INTERPOLATION IN TABLES WITH DIFFERENT X AND FIXED Z                     
      PARAMETER( IVARX=25,NDIMT=8 )                                            
C     TL < TLIM1:         LOWER PART OF ZAMS TABLES                          
C     TLIM1 < TL < TLIM2: UPPER PART OF ZAMS TABLES                          
C     TL > TLIM2:         CENTRE TABLES                                      
C     TMINI,TMAXI:        TEMPERATURE INTERVAL COVERED                       
C                         BY THE TABLES                                      
C                                                                              
      IMPLICIT REAL*8 (A-H,O-Z)                                                
      IMPLICIT LOGICAL*4(L)
      DIMENSION VAROUT(NDIMT,IVARX),XC(NDIMT)                                  
      COMMON/LUOUT/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,IOWR

      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH
      COMMON/TTTT/TLIM1,TLIM2,TMINI,TMAXI                                      
C     QUANTITIES FOR INTERPOLATION IN X 
      DIMENSION VARI1(IVARX,4),IX(4),XX(4)                                     
      INTEGER*4 L
C     OUTPUT
      COMMON/MHDOUT/VARFIN(IVARX)                                              
      SAVE
C     READ FROM APPROPRIATE TABLES                                      
C     AND FILL ARRAYS VAROUT AND XC                                     
C     CAN WE DO IT?                                                     
C
C     IRANGE = 1 
      IF(TL.LT.TMINI .OR. TL.GT.TMAXI) THEN
C         IRANGE = 0
          GO TO 999
      END IF                                                                   
C     LOWER ZAMS TABLES                                                 
      IF(TL.LT.TLIM1) THEN                                                     
         DO 10 I=1,3                                                           
         ITBL = -I                                                             
         CALL MHDPX2(PL,TL,ITBL,VAROUT,XC,NDIMT)                        
 10      CONTINUE                                                              
      ELSE IF(TL.LT.TLIM2) THEN                                                
C     UPPER ZAMS TABLES                                                 
         DO 20 I=1,3                                                           
         ITBL = I                                                              
         CALL MHDPX2(PL,TL,ITBL,VAROUT,XC,NDIMT)                        
 20      CONTINUE                                                              
      ELSE                                                                     
C     CENTRE TABLES                                                     
         DO 30 I=1,5                                                           
C        OFFSET (+3) TO ACCESS CENTER TABLES                    
         ITBL = I + 3                                                          
         CALL MHDPX2(PL,TL,ITBL,VAROUT,XC,NDIMT)                        
 30      CONTINUE                                                              
      END IF                                                                   
C     INTERPOLATION IN X
      IF(TL.LE.TLIM2) THEN                                                     
C        QUADRATIC NEWTON (EQUIDISTANT XC'S) 
         X0 = XC(1)                                                            
         H  = XC(2) - XC(1)                                                    
         IF(ABS(XC(3)-XC(2)-H).GT.1.D-4) THEN                                  
            WRITE(IOWR,*) 'ERROR (MHD): NON-EQUIDISTANT ZAMS TABLES.'
            WRITE(IOWR,*) 'XC(1-3)= ',XC(1),XC(2),XC(3)
            WRITE(ISHORT,*) 'ERROR (MHD): NON-EQUIDISTANT ZAMS TABLES.'
            WRITE(ISHORT,*) 'XC(1-3)= ',XC(1),XC(2),XC(3)
            STOP                                                               
         END IF                                                                
C         IF( ( XC(3).GT.XC(1) .AND. (X.GT.XC(3) .OR. X.LT.XC(1)))             
C    1                               .OR.                                      
C    2       ( XC(3).LT.XC(1) .AND. (X.GT.XC(1) .OR. X.LT.XC(3))) )            
C    3   THEN
C        END IF
         DO 100 IV=1,IVARX                                                     
         Y0 = VAROUT(1,IV)                                                     
         Y1 = VAROUT(2,IV)                                                     
         Y2 = VAROUT(3,IV)                                                     
         CALL QUINT(X,X0,H,Y0,Y1,Y2,VARFIN(IV))                                
 100     CONTINUE                                                              
      ELSE                                                                     
C     CUBIC LAGRANGIAN (ARBITRARILY SPACED XC'S)                              
C     USE 4 HIGHEST XC(I)'S, IF POSSIBLE.                       
C     DISTINGUISH CASE WHERE THE XC(I), I=4..8,                 
C     INCREASE OR DECREASE.                                     
         IF(XC(4).LT.XC(8)) THEN                                               
            IXMIN = 5                                                          
            IF(X.LT.XC(5)) IXMIN=4                                             
         ELSE                                                                  
            IXMIN = 4                                                          
            IF(X.LT.XC(7)) IXMIN=5                                             
         END IF                                                                
         DO 200 I=1,4                                                          
 200     IX(I)=IXMIN+I-1                                                       
         DO 250 I =1,4                                                         
         XX(I) = XC(IX(I))                                                     
         DO 250 IV=1,IVARX                                                     
         VARI1(IV,I) = VAROUT(IX(I),IV)                                        
 250     CONTINUE                                                              
         II=IVARX                                                              
         ID=IVARX                                                              
         NP=4                                                                  
         L=1                                                                   
         INTER=1                                                               
         CALL LIR(X,XX,VARFIN,VARI1,II,ID,NP,L,INTER)                          
      END IF                                                                   
  999 RETURN
1000  FORMAT(' RESULTS FROM MHDPX2, ITBL,X = ',I6,1PE15.7/)                    
1001  FORMAT(12(/1X,1P5E15.6))                                                 
5001  FORMAT(1X,'******* WARNING: EXTRAPOLATION IN X (QUINT) ',                
     1          'PL,TL,X = ',3F12.6)                                           
5011  FORMAT(1X,'******* WARNING: EXTRAPOLATION IN X (LIR) ',                  
     1          'PL,TL,X = ',3F12.6)                                           
9001  FORMAT(' ERROR IN MHDPX1. TL OUT OF RANGE. TL,TMINI,TMAXI=',             
     1 /1X,1P3E13.6)                                                           
      END                                                                      
