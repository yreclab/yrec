C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHDST1
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MHDST1(IR,IDX,NT1M,NR1M,IVAR1,NT2M,NR2M,IVAR2,NCHEM0,         
     .                  NT1,NR1,NT2,NR2,TLOG1,TLOG2,TDVAR1,TDVAR2,             
     .                  DRH1,DRH2,NCHEM,ATWT,ABUN,ABFRCS,GASMU,                
     .                  TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,            
     .                  ABUD,ABUU,ABFRCD,ABFRCU)                               
      IMPLICIT REAL*8 (A-H,O-Z)                                                
      IMPLICIT LOGICAL*4(L)

      DIMENSION TLOG1(NT1M),TDVAR1(NT1M,NR1M,IVAR1),                           
     .          TLOG2(NT2M),TDVAR2(NT2M,NR2M,IVAR2),                           
     .          ATWT(NCHEM0),ABUN(NCHEM0),ABFRCS(NCHEM0)                       
      DIMENSION TLOGD(NT2M),TLOGU(NT2M)                                        
      DIMENSION TDDIF0(NT2M,NR2M,IVAR1)                                        
      DIMENSION TDDIFD(NT2M,NR2M,IVAR1)                                        
      DIMENSION TDDIFU(NT2M,NR2M,IVAR1)                                        
      DIMENSION ATWD(NCHEM0),ABUD(NCHEM0),ABFRCD(NCHEM0)                       
      DIMENSION ATWU(NCHEM0),ABUU(NCHEM0),ABFRCU(NCHEM0)                       
      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH
      SAVE
      IF(IDX.EQ.0) THEN                                                        
          IFILES = 1                                                           
      ELSE                                                                     
          IFILES = 3                                                           
      END IF                                                                   
      DO 400 IIDX=1,IFILES                                                     
C     READ(IR,98,END=1000) IVARR,IDXR,IRESCR,DDX                               
      READ(IR,   END=1000) IVARR,IDXR,IRESCR,DDX                               
      IF(IVAR1.LT.IVARR) THEN                                                  
         STOP                                                                  
      END IF                                                                   
      IF(IDX.NE.IDXR) THEN                                                     
         STOP                                                                  
      END IF                                                                   
      IF(IIDX.EQ.1) THEN                                                       
          IRESCO= 0                                                            
      ELSE IF(IIDX.EQ.2) THEN                                                  
          IRESCO=-1                                                            
      ELSE IF(IIDX.EQ.3) THEN                                                  
          IRESCO= 1                                                            
      END IF                                                                   
      IF(IRESCO.NE.IRESCR) THEN                                                
         STOP   
      END IF                                                                   
      IF(IIDX.EQ.1) CALL RABU(IR,NCHEM0,NCHEM,ATWT,ABUN,ABFRCS,GASMU)          
      IF(IIDX.EQ.2) CALL RABU(IR,NCHEM0,NCHEM,ATWD,ABUD,ABFRCD,GASXD)          
      IF(IIDX.EQ.3) CALL RABU(IR,NCHEM0,NCHEM,ATWU,ABUU,ABFRCU,GASXU)          
C     READ(IR,1001) NT1,NT2,DRH1,DRH2                                          
      READ(IR     ) NT1,NT2,DRH1,DRH2                                          
      IF(IDX.EQ.1 .AND. NT1.NE.0) THEN                                         
          STOP                                                                 
      END IF                                                                   
      IF(NT1.GT.0) THEN                                                        
         CALL RTAB(IR,NT1M,NR1M,IVAR1,NT1,NR1,TLOG1,TDVAR1)                    
      END IF                                                                   
      IF(IDX.EQ.1) THEN                                                        
       IF(IIDX.EQ.1) CALL RTAB(IR,NT2M,NR2M,IVAR1,NT2,NR2,TLOG2,TDDIF0)        
       IF(IIDX.EQ.2) CALL RTAB(IR,NT2M,NR2M,IVAR1,NT2,NR2,TLOGD,TDDIFD)        
       IF(IIDX.EQ.3) CALL RTAB(IR,NT2M,NR2M,IVAR1,NT2,NR2,TLOGU,TDDIFU)        
      ELSE IF(IDX.EQ.0) THEN                                                   
       CALL RTAB(IR,NT2M,NR2M,IVAR2,NT2,NR2,TLOG2,TDVAR2)                      
      END IF                                                                   
 400  CONTINUE                                                                 
      IF(IDX.EQ.0) GOTO 450                                                    
C     IF IDX=1: CHECK TABLES FOR CORRECT COMPOSITION CONSTRUCTION           
C     AND PERFORM NUMERICAL DERIVATIVES W.R.T. X                  
      CXLIM = 0.05D0*ABS(DDX)                                                    
      IF( ABS(ABFRCS(1)-ABFRCD(1)-DDX).GT.CXLIM  .OR.                          
     .    ABS(ABFRCS(1)-ABFRCU(1)+DDX).GT.CXLIM  .OR.                          
     .    ABS(ABFRCS(2)-ABFRCD(2)+DDX).GT.CXLIM  .OR.                          
     .    ABS(ABFRCS(2)-ABFRCU(2)-DDX).GT.CXLIM )    GOTO 500                  
      DO 420 IC=3,NCHEM                                                        
      IF( ABS(ABFRCS(IC)-ABFRCU(IC)).GT.CXLIM )      GOTO 500                  
      IF( ABS(ABFRCS(IC)-ABFRCD(IC)).GT.CXLIM )      GOTO 500                  
 420  CONTINUE                                                                 
      DO 430 JT=1,NT2                                                          
      IF(TLOG2(JT).NE.TLOGD(JT)) GOTO 600                                      
      IF(TLOG2(JT).NE.TLOGU(JT)) GOTO 600                                      
 430  CONTINUE                                                                 
C     NUMERICAL DERIVATIVES W.R.T. X                                         
      DO 440 N =1,NT2                                                          
      DO 440 M =1,NR2                                                          
      DO 435 IV=1,IVAR1                                                        
435   TDVAR2(N,M,IV)=TDDIF0(N,M,IV)                                            
C                                                                              
C     EXTENDED SET OF VARIABLES (TDVAR2(N,M,IVAR1+1...IVAR2))             
C     FOR T-RHO REGIONS WITH INHOMOGENEOUS COMPOSITION.                   
C     IN THE COMMENTS,R AND T DENOTE LOG10(RHO) AND LOG10(T).             
C     DLOG10(P)/DX,DLOG10(U)/DX,DDELAD/DX,DLOG10(CP)/DX                   
      TDVAR2(N,M,21)=(TDDIFU(N,M, 2)-TDDIFD(N,M, 2))/(2.D0*DDX)                  
      TDVAR2(N,M,22)=(TDDIFU(N,M, 3)-TDDIFD(N,M, 3))/(2.D0*DDX)                  
      TDVAR2(N,M,23)=(TDDIFU(N,M, 8)-TDDIFD(N,M, 8))/(2.D0*DDX)                  
      TDVAR2(N,M,24)=(TDDIFU(N,M, 9)-TDDIFD(N,M, 9))/(2.D0*DDX)                  
C     SPACE-HOLDER VARIABLE (LIKE VAR(20))                       
      TDVAR2(N,M,25)=8888844444.D0                                               
  440 CONTINUE                                                                 
C     NORMAL EXIT                                                 
 450  CONTINUE
      RETURN                                                                   
C     ERROR EXIT AND ERROR MESSAGES                               
  500 CONTINUE
      STOP                                                                     
 600  CONTINUE
      STOP                                                                     
 1000 CONTINUE
      STOP                                                                     
 98   FORMAT(1X,3I5,F13.5)                                                     
 99   FORMAT(1X,I5,(/1X,3E15.7))                                               
1001  FORMAT(2I5,2F10.6)                                                       
8001  FORMAT(' CORRECT TABLE CONSTRUCTION FOR X-DERIVATIVES.',                 
     1       ' CENTROID COMPOSITION IS:'//)                                    
8002  FORMAT('      AT. WEIGHT     NUMBER ',                                   
     1 'ABUNDANCE  MASS FRACTION',(/1X,1P3G16.7))                              
8003  FORMAT(/' MEAN MOLECULAR WEIGHT = ',F12.7//)                             
9006  FORMAT(' ERROR IN MHDST1. IVARR READ FROM TABLE IS',                     
     1 ' BIGGER THAN THE VALUE USED IN THE COMMONS.',                          
     2 ' IVAR,IVARR= ',/1X,2I8)                                                
9007  FORMAT(' ERROR IN MHDST1. IDXR READ FROM TABLE IS INCORRECT',            
     1 ' IDX,IDXR= ',/1X,2I8)                                                  
9008  FORMAT(' ERROR IN MHDST1. IRESCR READ FROM TABLE IS INCORRECT',          
     1 ' IRESCO,IRESCR= ',/1X,2I8)                                             
9010  FORMAT(' ERROR IN MHDST1. NT1 AND IDX ARE INCONSISTENT',                 
     1 ' IDX,NT1,NT2 ',/1X,3I8)                                                
9800  FORMAT(' ERROR IN TABLE CONSTRUCTION FOR X-DERIVATIVES',                 
     1       ' CENTRAL, LOWER, UPPER TABLE: N(ELEMENT),ABFRCS(N)'//)           
9810  FORMAT(1X,I5,F15.9)                                                      
9820  FORMAT(/)                                                                
9850  FORMAT(' ERROR IN TABLE CONSTRUCTION FOR X-DERIVATIVES:',                
     1       ' TEMPERATURES WRONG: J,TLOW(J),TCENT(J),TUPP(J)'//)              
9860  FORMAT(1X,I5,3F15.9)                                                     
9900  FORMAT(' EOF REACHED IN INPUT FILE. ERROR STOP. IR,IDX = ',2I5)          
      END                                                                      
