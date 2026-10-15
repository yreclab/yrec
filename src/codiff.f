C $$$$$$
C       SUBROUTINE CODIFF(DELTS,HRU,HV,IMIN,IMAX,LC,LCZ,M,RMID,COD,COD2)  ! KC 2025-05-31
      SUBROUTINE CODIFF(HRU,M,RMID,COD,COD2,VFC)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD

C 2/91 SUBROUTINE ALTERED TO ALLOW DIFFERENT FC'S FOR DIFFERENT
C      MECHANISMS (COMMON BLOCK VMULT2)

      PARAMETER (JSON=5000)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 10/13/26 MHP via Claude
C VFC is now a dummy argument, formerly COMMON/VARFC/.
      DIMENSION VFC(JSON)
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 10/13/26 MHP via Claude: removed the unused COMMON/INTVAR/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      ! old version: COMMON/INTVR2/AMUM(JSON),THDIFM(JSON),VISCM(JSON),WM(JSON)
      !COMMON/INTVR2/AMUMI(JSON),THDIFMI(JSON),VISCMI(JSON),WM(JSON)
C 10/13/26 MHP via Claude: removed the unused COMMON/MDPHY/ declaration
C (no member referenced here; residue of the obsolete-option removals).
      COMMON/TEMP2/VES(JSON),VES0(JSON),VSS(JSON),VSS0(JSON),
     *     HLE(JSON),VGSF(JSON),VGSF0(JSON),VMU(JSON)
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
C 10/9/26 MHP via Claude
C code changed to convert COMMON/ADVEC/ to a plain local array:
C declared only in this file (confirmed via a codebase-wide scan), so
C there's nothing to share via COMMON. The existing blanket SAVE
C statement below already preserves its values across calls, same as
C COMMON did.
      DIMENSION FADV(JSON),FADV0(JSON)
C 10/13/26 MHP via Claude
C code changed to replace COMMON/VARFC/ with an explicit argument: seculr.f
C clears VFC, GETFC fills it and CODIFF reads it, all inside seculr.f's
C call tree, so seculr.f now owns the storage.
C MHP 9/93
C       DIMENSION HRU(JSON),HV(JSON),COD(JSON),LC(JSON),LCZ(JSON),  ! KC 2025-05-31
      DIMENSION HRU(JSON),COD(JSON),RMID(JSON),COD2(JSON)
C MHP 02/12 PERMIT CONSTANT DIFFUSION COEFFICIENT
C KC 2025-05-30 reordered common block elements
C       COMMON/MAG/LCODM,CODM
      SAVE

C  THIS SR DETERMINES THE RUN OF CHARACTERISTIC VELOCITY LENGTH
C  SCALES FOR THE DIFFUSION EQUATIONS.
C
C  INPUT VARIABLES
C
C       DECLARED:
C  HRU : RUN OF RADIUS (UNLOGGED) OF THE MIDPOINTS OF THE SHELLS.
C  M : NUMBER OF SHELLS.
C  HV : RUN OF CHARACTERISTIC DIFFUSION VELOCITIES.
C  LC : FLAG SET T IF ZONE IS CONVECTIVE.
C  LCZ : FLAG SET T IF ZONE IS CONVECTIVE FOR ANGULAR MOMENTUM
C        TRANSPORT PURPOSES(I.E. INCLUDES OVERSHOOT REGIONS).
C  M : NUMBER OF SHELLS.
C  FC,FO,FW : USER PARAMETERS.  THE DIFFUSION COEFFICIENTS
C  CAN BE MODIFIED BY THESE THREE PARAMETERS.
C  VELM : RUN OF CONVECTIVE VELOCITIES.
C
C  OUTPUT VARIABLES
C
C       DECLARED
C  COD : RUN OF DIFFUSION COEFFICENTS FOR ANGULAR MOMENTUM TRANSPORT.
C  COD2 : SAME, WITH RESPECT TO COMPOSITION TRANSPORT.
C  RMID : RMID(I) IS DEFINED AS THE AVERAGE OF HRU(I) AND HRU(I-1).
C       FROM COMMON BLOCKS:
C       IN COMMON BLOCKS
C  HLE : RUN OF CHARACTERSITIC VELOCITY LENGTH SCALES.
C
C  NOTE ON STORAGE: COD,V, AND HLE ARE CALCULATED AT THE MIDPOINT
C  BETWEEN MASS POINTS. ELEMENT I CONTAINS THE INFORMATION FOR THE
C  (I,I-1) INTERFACE.

      HLE(1) = 0.0D0
      RMID(1) = 0.0D0
      DO I = 2,M
         HLE(I) = 0.0D0
         RMID(I) = 0.5D0*(HRU(I)+HRU(I-1))
      END DO
C MHP 9/14 ADDED LOOP TO ALLOW A CONSTANT BACKGROUND DIFFUSION COEFFICIENT
      CON1 = C4PI*FW
      IF(.NOT.LCODM)THEN
         IF(.NOT.LVFC) THEN
            CON2 = CON1*FC
            DO I = 2,M
               COD(I)=CON1*(VES(I)+VGSF(I)+VSS(I))*RMID(I)
               COD2(I)=CON2*(FESC*VES(I)+FGSFC*VGSF(I)+FSSC*VSS(I))
     *              *RMID(I)
C               HLE(I)=RMID(I)
            END DO
         ELSE
            DO I = 2,M
               COD(I) = CON1*(VES(I)+VGSF(I)+VSS(I))*RMID(I)
               COD2(I) = COD(I)*VFC(I)
C               HLE(I) = RMID(I)
            END DO
         ENDIF
      ELSE
         IF(.NOT.LVFC) THEN
            CON2 = CON1*FC
            DO I = 2,M
               COD(I)=CON1*(CODM+(VES(I)+VGSF(I)+VSS(I))*RMID(I))
               COD2(I)=CON2*(FESC*VES(I)+FGSFC*VGSF(I)+FSSC*VSS(I))
     *                 *RMID(I)
            END DO
         ELSE
            DO I = 2,M
               COD(I) = CON1*(VES(I)+VGSF(I)+VSS(I))*RMID(I)
               COD2(I) = COD(I)*VFC(I)
C MHP 8/13 ADD D.C. AFTER SCALE FACTOR FOR MIXING APPLIED
               COD(I) = COD(I)+CON1*CODM
            END DO
         ENDIF
      ENDIF
C OPTION TO SUPPRESS ANGULAR MOMENTUM TRANSPORT (BUT PERMIT MIXING).
      IF(LNOJ)THEN
         DO I = 2,M
            COD(I) = 0.0D0
         END DO
      ENDIF
      RETURN
      END
