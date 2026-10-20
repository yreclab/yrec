C $$$$$$
      SUBROUTINE WCZIMP(HD,HJM,HR,HS,HS2,ISTART,IEND,ETA2,HI,OMEGA,
     *               QIW,R0,M)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 CJNEW,CJTOT,CMTOT,ETA2,HD,HI,HJM,HR,HS,HS2,OMEGA,QIW,R0,W0
      INTEGER IEND,ISTART,J,JEND,JSTART,M

C 10/12/26 MHP via Claude
C code changed to extend COMMON/NMLPAR/ to 234 members, adding the
C namelist variables that the physics routines read from 27 COMMON
C blocks which also held derived or working members.  Those blocks keep
C only their non-namelist members; five of them -- NEWMX, VMULT,
C PMMWIND, CCOUT1 and ENVGEN -- had nothing left and are gone.
C Derivation-only namelist variables from the same blocks went to
C COMMON/NMLBYPASS/ instead, not here.
C
C Declared identically in all 121 files that hold any of these members.
C Generated from one member list, so every copy is byte-identical; the
C linker's 'size of symbol changed' warning is the check that they are.
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      DIMENSION HD(JSON),HJM(JSON),HR(JSON),HS(JSON),HS2(JSON),
     *  ETA2(JSON),HI(JSON),OMEGA(JSON),QIW(JSON),R0(JSON)
      SAVE

C JNT 2025/09/03 copy of 2025/05/14 TO MAKE THE CODE ENFORCE
C SPECIFIC ROTATION PROFILES

C JNT 2025/09/03 COPY OF 2015/05/07 ADD IEND.LT.M TO ENFORCE SB
C ROTATION IN CONVECTIVE ZONES THAT ARE NOT THE SURFACE CONVECTIVE
C ZONE EVEN IF WALPCZ IS TURNED ON (I.E. WALPCZ NOW ONLY AFFECTS
C SURFACE CONVECTION ZONES)
C JVS 2026/02/13: REVERTED GT TO GE 
      IF((WALPCZ.GE.0.0D0) .OR. (LSOLID) .OR. (IMPJMOD.EQ.1) .OR. (IEND.LT.M)) THEN
C  SOLID BODY ROTATION IN CONVECTIVE REGIONS.
         CALL SOLID(HD,HJM,HR,HS,HS2,ISTART,IEND,ETA2,HI,OMEGA,
     *              QIW,R0,M)     
C JNT 2025/09/03 COPY OF 2015/05/14 ADD OPTION TO MAKE EVERYTHING
C BELOW THE SURFACE CONVECTION ZONE ROTATE AS A SOLID BODY, 
C DETACHED FROM WHAT IS HAPPENING IN THE CONVECTION ZONE
      ELSE IF(IMPJMOD.EQ.2)THEN
         CJTOT = HJM(ISTART)*HS2(ISTART)
         CMTOT = DEXP(CLN*WALPCZ*HR(ISTART))*HI(ISTART)
         DO 30 J = ISTART+1,IEND
            CJTOT = CJTOT + HJM(J)*HS2(J)
            CMTOT = CMTOT + DEXP(CLN*WALPCZ*HR(J))*HI(J)
   30    CONTINUE      
 
C  ASSIGN NEW RUN OF J/M IN THE C.Z. AND FIND THE NEW RUN OF OMEGA.
         W0 = CJTOT/CMTOT
         DO 31 J = ISTART,IEND
            OMEGA(J) = W0*DEXP(CLN*WALPCZ*HR(J))
            HJM(J) = OMEGA(J)*HI(J)/HS2(J)
            JSTART = J
            JEND = J
            CALL SOLID(HD,HJM,HR,HS,HS2,JSTART,JEND,ETA2,HI,
     *                 OMEGA,QIW,R0,M)
   31    CONTINUE
         IF (ISTART.GT.1) THEN
            CALL SOLID(HD,HJM,HR,HS,HS2,1,ISTART-1,ETA2,HI,
     *                 OMEGA,QIW,R0,M)
         ENDIF
C JNT 2025/09/04 REPLICATING 2015/05/14 ADD OPTION TO MAKE 
C EVERYTHING BELOW THE SURFACE CONVECTION ZONE ROTATE AS A
C SOLID BODY AT THE RATE OF THE BASE OF THE CONVECTION ZONE.
      ELSE IF(IMPJMOD.EQ.3) THEN
         CJTOT = HJM(1)*HS2(1)
         CMTOT = DEXP(CLN*WALPCZ*HR(ISTART))*HI(1)
         IF (ISTART.GT.1) THEN
            DO 32 J = 2,ISTART
               CJTOT = CJTOT + HJM(J)*HS2(J)
               CMTOT = CMTOT + DEXP(CLN*WALPCZ*HR(ISTART))*HI(J)
   32       CONTINUE
         ENDIF
         DO 33 J = (ISTART+1),IEND
            CJTOT = CJTOT + HJM(J)*HS2(J)
            CMTOT = CMTOT + DEXP(CLN*WALPCZ*HR(J))*HI(J)
   33    CONTINUE
C  ASSIGN NEW RUN OF J/M IN THE C.Z. AND FIND THE NEW RUN OF OMEGA.

         W0 = CJTOT/CMTOT
         DO 34 J = ISTART,IEND
            OMEGA(J) = W0*DEXP(CLN*WALPCZ*HR(J))
            HJM(J) = OMEGA(J)*HI(J)/HS2(J) 
            JSTART = J
            JEND = J
            CALL SOLID(HD,HJM,HR,HS,HS2,JSTART,JEND,ETA2,HI,
     *                 OMEGA,QIW,R0,M)
   34    CONTINUE         
         IF (ISTART.GT.1) THEN
            DO 35 J = 1,(ISTART-1)
               OMEGA(J) = OMEGA(ISTART)
               HJM(J) = OMEGA(J)*HI(J)/HS2(J) 
   35       CONTINUE   
            CALL SOLID(HD,HJM,HR,HS,HS2,1,ISTART-1,ETA2,HI,
     *                 OMEGA,QIW,R0,M)
         ENDIF              
        
         
      
      ELSE IF((WALPCZ.LE.-2.0D0) .AND. (IMPJMOD.EQ.0))THEN
C  CONSTANT SPECIFIC ANGULAR MOMENTUM PER UNIT MASS IN THE C.Z.
C  FIND TOTAL MASS AND ANGULAR MOMENTUM OF C.Z.
         CJTOT = HJM(ISTART)*HS2(ISTART)
         CMTOT = HS2(ISTART)
         DO 36 J = ISTART+1,IEND
            CJTOT = CJTOT + HJM(J)*HS2(J)
            CMTOT = CMTOT + HS2(J)
   36    CONTINUE
C  ASSIGN NEW RUN OF J/M IN THE C.Z. AND FIND THE NEW RUN OF OMEGA.
         CJNEW = CJTOT/CMTOT
         DO 40 J = ISTART,IEND
            HJM(J) = CJNEW
            OMEGA(J) = CJNEW*HS2(J)/HI(J)
            JSTART = J
            JEND = J
            CALL SOLID(HD,HJM,HR,HS,HS2,JSTART,JEND,ETA2,HI,
     *                 OMEGA,QIW,R0,M)
   40    CONTINUE
      ELSE
C  GENERAL LAW FOR OMEGA IN C.Z.: OMEGA = C*R**WALPCZ,WHERE C IS A CONSTANT
C  FOR THE ENTIRE C.Z. IF THIS HOLDS, THE RUN OF J/M CAN BE FOUND BY
C  SOLVING FOR THE CONSTANT BY REQUIRING THAT THE TOTAL J OF THE C.Z. BE
C  CONSERVED AND THEN USING J/M=C*R**WALPCZ*(MOMENT OF INERTIA PER UNIT
C  MASS).
C  FIND TOTAL MASS AND ANGULAR MOMENTUM OF C.Z.
         CJTOT = HJM(ISTART)*HS2(ISTART)
         CMTOT = DEXP(CLN*WALPCZ*HR(ISTART))*HI(ISTART)
         DO 50 J = ISTART+1,IEND
            CJTOT = CJTOT + HJM(J)*HS2(J)
            CMTOT = CMTOT + DEXP(CLN*WALPCZ*HR(J))*HI(J)
   50    CONTINUE
C  ASSIGN NEW RUN OF J/M IN THE C.Z. AND FIND THE NEW RUN OF OMEGA.
         W0 = CJTOT/CMTOT
         DO 60 J = ISTART,IEND
            OMEGA(J) = W0*DEXP(CLN*WALPCZ*HR(J))
            HJM(J) = OMEGA(J)*HI(J)/HS2(J)
            JSTART = J
            JEND = J
            CALL SOLID(HD,HJM,HR,HS,HS2,JSTART,JEND,ETA2,HI,
     *                 OMEGA,QIW,R0,M)
   60    CONTINUE
      ENDIF
      RETURN
      END
