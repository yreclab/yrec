C---------------------------  GROUP: SR_X  -------------------------------     
C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C MHDST
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE MHDST(IR1,IR2,IR3,IR4,IR5,IR6,IR7,IR8)                        
      IMPLICIT REAL*8 (A-H,O-Z)                                                
      IMPLICIT LOGICAL*4(L)

      PARAMETER( IVARC=20,IVARX=25,NCHEM0=6)                                   
      PARAMETER( NT1M=16,NT2M=79,NTXM=10,NR1M=87,NR2M=21,NRXM=21 )             
C     ZAMS TABLES (LABELLED BY A,B,C)  
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
C     TL<TLIM1:       LOWER PART OF ZAMS TABLES                              
C     TLIM1<TL<TLIM2: UPPER PART OF ZAMS TABLES                              
C     TL>TLIM2:       VARIABLE X TABLES                                      
      COMMON/TTTT/TLIM1,TLIM2,TMINI,TMAXI                                      
      DIMENSION TDDUM(NT1M,NR1M,IVARC),TLDUM(NT1M)                             
C     WORKING STORAGE FOR NUMERICAL X-DERIVATIVES. COMMON TO ALL 
C     X-TABLES 
      DIMENSION TLOGD(NT2M),TLOGU(NT2M)                                        
      DIMENSION TDDIF0(NT2M,NR2M,IVARC)                                        
      DIMENSION TDDIFD(NT2M,NR2M,IVARC)                                        
      DIMENSION TDDIFU(NT2M,NR2M,IVARC)                                        
      DIMENSION ATWD(NCHEM0),ABUD(NCHEM0),ABFRCD(NCHEM0)                       
      DIMENSION ATWU(NCHEM0),ABUU(NCHEM0),ABFRCU(NCHEM0)                       
      SAVE
C                                                                              
C     DEFINE, WITH UNUSED STATEMENTS, STORAGE FOR VARIABLES             
C     THAT WOULD OTHERWISE ONLY APPEAR AS FORMAL PARAMETERS             
C     IN THIS SUBROUTINE. VICIOUS BUGS CAN BE THE RESULT IF             
C     THIS STORAGE WERE NOT PROVIDED (REMEMBER: FORTRAN IS NOT          
C     A RECURSIVE LANGUAGE.)                                            
      NCHEM = 0                                                                
      DRDUM = 0.D0                                                               
      NTDUM = 0                                                                
      NRDUM = 0                                                                
C     READ ZAMS TABLES 
      IF(IR1.GT.0) THEN                                                        
         IDX = 0                                                               
         CALL MHDST1(IR1,IDX,NT1M,NR1M,IVARC,NT2M,NR2M,IVARC,NCHEM0,           
     1               NT1,NR1,NT2,NR2,TLOG1,TLOG2,TDVR1A,TDVR2A,                
     2               DRH1,DRH2,NCHEM,ATWTA,ABUNA,ABFRCA,GASMA,                 
     3               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     4               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
      IF(IR2.GT.0) THEN                                                        
         IDX = 0                                                               
         CALL MHDST1(IR2,IDX,NT1M,NR1M,IVARC,NT2M,NR2M,IVARC,NCHEM0,           
     .               NT1,NR1,NT2,NR2,TLOG1,TLOG2,TDVR1B,TDVR2B,                
     .               DRH1,DRH2,NCHEM,ATWTB,ABUNB,ABFRCB,GASMB,                 
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
      IF(IR3.GT.0) THEN                                                        
         IDX = 0                                                               
         CALL MHDST1(IR3,IDX,NT1M,NR1M,IVARC,NT2M,NR2M,IVARC,NCHEM0,           
     .               NT1,NR1,NT2,NR2,TLOG1,TLOG2,TDVR1C,TDVR2C,                
     .               DRH1,DRH2,NCHEM,ATWTC,ABUNC,ABFRCC,GASMC,                 
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
C     READ CENTRE TABLES 
      IF(IR4.GT.0) THEN                                                        
         IDX = 1                                                               
         CALL MHDST1(IR4,IDX,NT1M,NR1M,IVARC,NTXM,NRXM,IVARX,NCHEM0,           
     .               NTDUM,NRDUM,NTX,NRX,TLDUM,TLOGX,TDDUM,TDVRX1,             
     .               DRDUM,DRHX,NCHEM,ATWT1,ABUN1,ABFRC1,GASM1,                
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
      IF(IR5.GT.0) THEN                                                        
         IDX = 1                                                               
         CALL MHDST1(IR5,IDX,NT1M,NR1M,IVARC,NTXM,NRXM,IVARX,NCHEM0,           
     .               NTDUM,NRDUM,NTX,NRX,TLDUM,TLOGX,TDDUM,TDVRX2,             
     .               DRDUM,DRHX,NCHEM,ATWT2,ABUN2,ABFRC2,GASM2,                
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
      IF(IR6.GT.0) THEN                                                        
         IDX = 1                                                               
         CALL MHDST1(IR6,IDX,NT1M,NR1M,IVARC,NTXM,NRXM,IVARX,NCHEM0,           
     .               NTDUM,NRDUM,NTX,NRX,TLDUM,TLOGX,TDDUM,TDVRX3,             
     .               DRDUM,DRHX,NCHEM,ATWT3,ABUN3,ABFRC3,GASM3,                
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
      IF(IR7.GT.0) THEN                                                        
         IDX = 1                                                               
         CALL MHDST1(IR7,IDX,NT1M,NR1M,IVARC,NTXM,NRXM,IVARX,NCHEM0,           
     .               NTDUM,NRDUM,NTX,NRX,TLDUM,TLOGX,TDDUM,TDVRX4,             
     .               DRDUM,DRHX,NCHEM,ATWT4,ABUN4,ABFRC4,GASM4,                
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
      IF(IR8.GT.0) THEN                                                        
         IDX = 1                                                               
         CALL MHDST1(IR8,IDX,NT1M,NR1M,IVARC,NTXM,NRXM,IVARX,NCHEM0,           
     .               NTDUM,NRDUM,NTX,NRX,TLDUM,TLOGX,TDDUM,TDVRX5,             
     .               DRDUM,DRHX,NCHEM,ATWT5,ABUN5,ABFRC5,GASM5,                
     .               TLOGD,TLOGU,TDDIF0,TDDIFD,TDDIFU,ATWD,ATWU,               
     .               ABUD,ABUU,ABFRCD,ABFRCU)                                  
      END IF                                                                   
C     TEMPERATURE LIMITS 
      TMINI = TLOG1(  1)                                                       
      TLIM1 = TLOG1(NT1)                                                       
      IF (IR4.LE.0) THEN                                                       
         TLIM2 = TLOG2(NT2)                                                    
         TMAXI = TLIM2                                                         
      ELSE                                                                     
         TLIM2 = TLOGX(  1)                                                    
         TMAXI = TLOGX(NTX)                                                    
      END IF                                                                   
      IF(IR4.LE.0) GOTO 500                                                    
  500 CONTINUE
8002  FORMAT('      AT. WEIGHT     NUMBER ',                                   
     & 'ABUNDANCE  MASS FRACTION',(/1X,1P3G16.7))                              
8003  FORMAT(/' MEAN MOLECULAR WEIGHT = ',F12.7//)                             
      RETURN                                                                   
      END                                                                      
