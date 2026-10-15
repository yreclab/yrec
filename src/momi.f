C $$$$$$
C       SUBROUTINE MOMI(ETA2,HD,HR,HS,HS2,JSTART,JEND,OMEGA,R0,HI,QIW,M)  ! KC 2025-05-31
      SUBROUTINE MOMI(ETA2,HR,HS,HS2,JSTART,JEND,OMEGA,R0,HI,QIW)
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

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C 10/11/26 MHP via Claude
C code changed to remove LSCRIB from COMMON/CCOUT/: it was declared
C positionally in all 17 files sharing this block but never read or
C written in executable code anywhere, and no namelist file sets it.
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
C 10/13/26 MHP via Claude: removed the unused COMMON/CCOUT/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
C 10/13/26 MHP via Claude: removed the unused COMMON/IOUNITS/ declaration
C (no member referenced here; residue of the obsolete-option removals).
C       DIMENSION HD(JSON),HR(JSON),HS2(JSON),R0(JSON),ETA2(JSON),HI(JSON)  ! KC 2025-05-31
      DIMENSION HR(JSON),HS2(JSON),R0(JSON),ETA2(JSON),HI(JSON)
      DIMENSION OMEGA(JSON),HS(JSON),QIW(JSON)
      SAVE

C  FIND THE MOMENT OF INERTIA (HI) AND DI/D(OMEGA) (QIW).
C  MOMI ASSUMES THAT SHAPE HAS ALREADY BEEN CALLED.
C  MOMENT OF INERTIA IS CALCULATED BY THE METHOD USED IN WAI-YUEN LAW'S
C  THESIS(YALE,1980) P.61.
      IF(JSTART.EQ.1) THEN
         R0P = 0.0D0
         RPHIP = 0.0D0
      ELSE
         R0P = DLOG(R0(JSTART - 1))
         RPHIP = CLN*HR(JSTART - 1)
      ENDIF
      CON = CC13*5.0D0/DEXP(CLN*CGL)
      IF(WALPCZ.NE.0.0D0)THEN
         DO I = JSTART,JEND
            HI(I) = CC23*HS2(I)*EXP(CLN*2.0D0*HR(I))
            QIW(I) = 0.0D0
         END DO
         IF(JSTART.EQ.1)THEN
             RAD = 0.5D0*(HR(1)+HR(2))
             HI(1) = 0.4D0*HS2(1)*EXP(CLN*2.0D0*RAD)
         ENDIF
         RETURN
      ENDIF
      DO 20 I = JSTART,JEND
C  QR0R = D LN R0/ D LN R
C
         QR0R = 1.0D0
         H0 = CC23*HS2(I)*DEXP(CLN*2.0D0*HR(I))
         R03 = R0(I)**3
         RPHI3 = DEXP(CLN*3.0D0*HR(I))
         R0R = (R03/RPHI3)*R0(I)**2
         A = CON*OMEGA(I)**2*R03/(DEXP(CLN*HS(I))*(2.0D0+ETA2(I)))
         ETA2X = ETA2(I)
C  EVALUATE INTEGRAL AT THE ZONE CENTER
         CALL INTMOM(A,ETA2X,QR0R,R0R,HIM,QIWM)
         HI(I) = HIM*HS2(I)
         QIW(I) = QIWM*HS2(I)
         R0P = DLOG(R0(I))
         RPHIP = CLN*HR(I)
   20 CONTINUE

      RETURN
      END
