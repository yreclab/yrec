C                                                                              
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHDPX2
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MHDPX2(PL,TL,ITBL,VAROUT,XCOMP,NDIMT)                  
      PARAMETER( IVARC=20,IVARX=25,NCHEM0=6)                                   
      PARAMETER( NT1M=16,NT2M=79,NTXM=10,NR1M=87,NR2M=21,NRXM=21 )             
C     ZAMS TABLES (LABELLED BY A,B,C)
      IMPLICIT REAL*8 (A-H,O-Z)                                                
      IMPLICIT LOGICAL*4(L)

      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH
      COMMON/TAB1A/TDVR1A(NT1M,NR1M,IVARC),TLOG1(NT1M),NT1,NR1,DRH1            
      COMMON/TAB2A/TDVR2A(NT2M,NR2M,IVARC),TLOG2(NT2M),NT2,NR2,DRH2            
      COMMON/TAB1B/TDVR1B(NT1M,NR1M,IVARC)                                     
      COMMON/TAB2B/TDVR2B(NT2M,NR2M,IVARC)                                     
      COMMON/TAB1C/TDVR1C(NT1M,NR1M,IVARC)                                     
      COMMON/TAB2C/TDVR2C(NT2M,NR2M,IVARC)                                     
      COMMON/CHEA/ATWTA(NCHEM0),ABUNA(NCHEM0),ABFRCA(NCHEM0),GASMA             
      COMMON/CHEB/ATWTB(NCHEM0),ABUNB(NCHEM0),ABFRCB(NCHEM0),GASMB             
      COMMON/CHEC/ATWTC(NCHEM0),ABUNC(NCHEM0),ABFRCC(NCHEM0),GASMC             
C     CENTRE TABLES (LABELLED BY 1,2,3,4,5)
      COMMON/TABX1/TDVRX1(NTXM,NRXM,IVARX),TLOGX(NTXM),NTX,NRX,DRHX            
      COMMON/TABX2/TDVRX2(NTXM,NRXM,IVARX)                                     
      COMMON/TABX3/TDVRX3(NTXM,NRXM,IVARX)                                     
      COMMON/TABX4/TDVRX4(NTXM,NRXM,IVARX)                                     
      COMMON/TABX5/TDVRX5(NTXM,NRXM,IVARX)                                     
      COMMON/CHE1/ATWT1(NCHEM0),ABUN1(NCHEM0),ABFRC1(NCHEM0),GASM1             
      COMMON/CHE2/ATWT2(NCHEM0),ABUN2(NCHEM0),ABFRC2(NCHEM0),GASM2             
      COMMON/CHE3/ATWT3(NCHEM0),ABUN3(NCHEM0),ABFRC3(NCHEM0),GASM3             
      COMMON/CHE4/ATWT4(NCHEM0),ABUN4(NCHEM0),ABFRC4(NCHEM0),GASM4             
      COMMON/CHE5/ATWT5(NCHEM0),ABUN5(NCHEM0),ABFRC5(NCHEM0),GASM5             
      SAVE
C     NOMENCLATURE FOR ACCESSING THE TABLES                                    
C     ZAMS TABLES                                                              
C     ITBL = -1   : TDVR1A                                                     
C     ITBL =  1   : TDVR2A                                                     
C     ITBL = -2   : TDVR1B                                                     
C     ITBL =  2   : TDVR2B                                                     
C     ITBL = -3   : TDVR1C                                                     
C     ITBL =  3   : TDVR2C                                                     
C     CONTRAL (VARIABLE X) TABLES                                              
C     ITBL =  4   : TDVRX1                                                     
C     ITBL =  5   : TDVRX2                                                     
C     ITBL =  6   : TDVRX3                                                     
C     ITBL =  7   : TDVRX4                                                     
C     ITBL =  8   : TDVRX5                                                     
C     NOTE: THE SAME OUTPUT VARIABLES VAROUT(ITBL,.) IS USED                   
C           FOR ITBL=1 AND -1, 2 AND -2, 3 AND -3, RESPECTIVELY.               
      DIMENSION VVAR1(IVARX,4),VVAR2(IVARX,4),VY(IVARX),VARO(IVARX)            
      DIMENSION VAROUT(NDIMT,IVARX),XCOMP(NDIMT)                               
C     IRANGE = 1     
      CALL ZERO(VARO,IVARX)                                                    
C     MAIN SELECTION OF TABLES 
C     ZAMS TABLES                                                     
      IF  (ITBL.EQ.-1) THEN                                                    
         CALL INTPT (PL,TL,TDVR1A,NT1M,NR1M,IVARC,TLOG1,NT1,NR1,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 20 I=1,IVARC                                                       
20       VAROUT(1,I) = VARO(I)                                                 
         XCOMP(1)    = ABFRCA(1)                                               
      ELSE IF (ITBL.EQ. 1) THEN                                                
         CALL INTPT (PL,TL,TDVR2A,NT2M,NR2M,IVARC,TLOG2,NT2,NR2,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 30 I=1,IVARC                                                       
30       VAROUT(1,I) = VARO(I)                                                 
         XCOMP(1)    = ABFRCA(1)                                               
      ELSE IF (ITBL.EQ.-2) THEN                                                
         CALL INTPT (PL,TL,TDVR1B,NT1M,NR1M,IVARC,TLOG1,NT1,NR1,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 40 I=1,IVARC                                                       
40       VAROUT(2,I) = VARO(I)                                                 
         XCOMP(2)    = ABFRCB(1)                                               
      ELSE IF (ITBL.EQ. 2) THEN                                                
         CALL INTPT (PL,TL,TDVR2B,NT2M,NR2M,IVARC,TLOG2,NT2,NR2,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 50 I=1,IVARC                                                       
50       VAROUT(2,I) = VARO(I)                                                 
         XCOMP(2)    = ABFRCB(1)                                               
      ELSE IF (ITBL.EQ.-3) THEN                                                
         CALL INTPT (PL,TL,TDVR1C,NT1M,NR1M,IVARC,TLOG1,NT1,NR1,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 60 I=1,IVARC                                                       
60       VAROUT(3,I) = VARO(I)                                                 
         XCOMP(3)    = ABFRCC(1)                                               
      ELSE IF (ITBL.EQ. 3) THEN                                                
         CALL INTPT (PL,TL,TDVR2C,NT2M,NR2M,IVARC,TLOG2,NT2,NR2,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 70 I=1,IVARC                                                       
70       VAROUT(3,I) = VARO(I)                                                 
         XCOMP(3)    = ABFRCC(1)                                               
C     CENTER TABLES                                                   
      ELSE IF (ITBL.EQ. 4) THEN                                                
         CALL INTPT (PL,TL,TDVRX1,NTXM,NRXM,IVARX,TLOGX,NTX,NRX,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 100 I=1,IVARX                                                      
100      VAROUT(4,I) = VARO(I)                                                 
         XCOMP(4)    = ABFRC1(1)                                               
      ELSE IF (ITBL.EQ. 5) THEN                                                
         CALL INTPT (PL,TL,TDVRX2,NTXM,NRXM,IVARX,TLOGX,NTX,NRX,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 110 I=1,IVARX                                                      
110      VAROUT(5,I) = VARO(I)                                                 
         XCOMP(5)    = ABFRC2(1)                                               
      ELSE IF (ITBL.EQ. 6) THEN                                                
         CALL INTPT (PL,TL,TDVRX3,NTXM,NRXM,IVARX,TLOGX,NTX,NRX,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 120 I=1,IVARX                                                      
120      VAROUT(6,I) = VARO(I)                                                 
         XCOMP(6)    = ABFRC3(1)                                               
      ELSE IF (ITBL.EQ. 7) THEN                                                
         CALL INTPT (PL,TL,TDVRX4,NTXM,NRXM,IVARX,TLOGX,NTX,NRX,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 130 I=1,IVARX                                                      
130      VAROUT(7,I) = VARO(I)                                                 
         XCOMP(7)    = ABFRC4(1)                                               
      ELSE IF (ITBL.EQ. 8) THEN                                                
         CALL INTPT (PL,TL,TDVRX5,NTXM,NRXM,IVARX,TLOGX,NTX,NRX,               
     1               VVAR1,VVAR2,VY,VARO)                                
         DO 140 I=1,IVARX                                                      
140      VAROUT(8,I) = VARO(I)                                                 
         XCOMP(8)    = ABFRC5(1)                                               
      END IF                                                                   
C     END SELECTION OF TABLES
      RETURN  
  999 RETURN
      END                                                                      
