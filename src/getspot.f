CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                               GETSPOT                             C
C                           A.Ash 7/26                              C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      SUBROUTINE GETSPOT(M,TEFFL)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      PARAMETER (JSON=5000)
      COMMON/SPOTS/SPOTF,SPOTX,LSDEPTH,LEVOLSPOTS,SPOTEX,FSPOTSCALE,RO_SCALE,FSPOT_SOL,KSPOT,FSPOT,ATEFFL
      COMMON/DISK/SAGE,TDISK,PDISK,LDISK
      COMMON/SURFW/OMEGASURF
      COMMON/OVRTRN/LNEWTCZ,LCALCENV,TAUCZ,TAUCZ0,PPHOT,PPHOT0,FRACSTEP
      SAVE
C Determine if spot evolution takes place
      
        IF(LEVOLSPOTS)THEN
          IF((OMEGASURF.EQ.0.0d0).AND.(TAUCZ.EQ.0.0d0))THEN
             RO_STAR=RO_SCALE
          ELSEIF(OMEGASURF.EQ.0.0d0)THEN
             RO_STAR = (2 * 3.14150)/(PDISK * TAUCZ)
          ELSEIF(TAUCZ.EQ.0.0d0)THEN
             IF(TAUCZ0.EQ.0.0d0)THEN
                RO_STAR = RO_SCALE
             ELSE
                RO_STAR = (2 * 3.14150)/(OMEGASURF * TAUCZ0)
             ENDIF
          ELSE 
             RO_STAR = (2*3.14159)/(OMEGASURF*TAUCZ)
          ENDIF  
          
C        WRITE(*,203) RO_STAR
C 203     FORMAT("ROSTAR", 1Pe12.3) 
          
C          ENDIF 
C Add toggle for different spotevol formulations - scale with user defined
C Fspotscale, scale with the sun, ...
          
          IF(KSPOT.EQ.0)THEN !Most generic spotevol form 
             FSPOT = FSPOTSCALE * ((RO_SCALE/MAX(RO_STAR,RO_SCALE))**(SPOTEX))

          ELSEIF(KSPOT.EQ.1)THEN !Log Rossby form from Cao + 2022

             FSPOT = (FSPOTSCALE * MAX(LOG10(RO_STAR),LOG10(RO_SCALE)))-SPOTEX

             IF(FSPOT.LE.0.0d0)THEN
               FSPOT=0.0d0
             ELSE
               FSPOT = FSPOT
             ENDIF

C The solar scaled case (KSPOT = 2) is going to become the default case. I need to fix the BC for saturated -> solar spot filling fraction at solar age. 
          ELSEIF(KSPOT.EQ.2)THEN !Scale to Solar spot filling fraction and Ro

             SOLTAU=9.40730218D5    
             SOLPROT=25.4*2.41D1*3.6D3
             RO_SOL = SOLPROT/SOLTAU
             FSPOT = FSPOT_SOL * (MAX(RO_STAR,RO_SCALE)/RO_SOL)**(SPOTEX)

             IF(FSPOT.GE.1.0d0)THEN
               FSPOT=1.0d0
             ELSE
               FSPOT = FSPOT
             ENDIF

          ENDIF     
      ELSE
          FSPOT = SPOTF
       
       
      
        
      ENDIF
C      WRITE(*,204) FSPOT
C 204  FORMAT("FSPOT", 1Pe12.3) 

C      IF(FSPOT.EQ.0.0)THEN
C         ATEFFL = TEFFL
C      ELSE
              
C         ATEFFL = TEFFL - 0.25*LOG10(FSPOT * SPOTX**4.0 + 1.0 - FSPOT)
C      ENDIF       
      
      RETURN
      END

