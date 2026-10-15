C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PINDEX
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE PINDEX(JXBEG,JXEND,LSHELL,M,ID,IDM)
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD

      PARAMETER (JSON=5000)
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
      DIMENSION ID(JSON)
      SAVE

C  ID IS THE ARRAY OF THE SHELLS TO BE PRINTED OUT;
C  I.E. IF SHELLS 1,3,5,..TO BE PRINTED ID(1)=1,ID(2)=3,..
      ID(1) = 1
      IDM = 2
      IF(LSHELL) THEN
C  PRINT OUT EVERY ZONE IN H-BURNING SHELL
       IF(NPRTPT.LT.JXBEG) THEN
          IBEG = MAX(2,NPRTPT)
          IEND = INT(JXBEG/NPRTPT)*NPRTPT
          DO 10 J = IBEG,IEND,NPRTPT
             ID(IDM) = J
             IDM = IDM + 1
   10       CONTINUE
       ENDIF
       IF(IEND .EQ. JXBEG) THEN
           IXBEG = JXBEG + 1
       ELSE
           IXBEG = JXBEG
       END IF
       DO 20 J = IXBEG,JXEND
          ID(IDM) = J
          IDM = IDM + 1
   20    CONTINUE
       IF(NPRTPT.LT.M) THEN
          IBEG = INT(JXEND/NPRTPT+1)*NPRTPT
          IEND = INT(M/NPRTPT)*NPRTPT
          DO 30 J = IBEG,IEND,NPRTPT
             ID(IDM) = J
             IDM = IDM + 1
   30       CONTINUE
       ENDIF
      ELSE IF(NPRTPT.LT.M) THEN
C  GENERAL CASE; PRINT OUT EVERY NPRTPT POINTS.
       IBEG = MAX(2,NPRTPT)
       IEND = INT(M/NPRTPT)*NPRTPT
       IF (IEND .EQ. M) IEND = IEND - NPRTPT
       DO 40 J = IBEG,IEND,NPRTPT
          ID(IDM) = J
          IDM = IDM + 1
   40    CONTINUE
      ENDIF
      ID(IDM) = M
      RETURN
      END
