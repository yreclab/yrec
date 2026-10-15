




C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C WRTMIL
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE WRTMIL(HCOMP,HD,HL,HP,HR,HS1,M,MODEL)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/SCRTCH/ into SCRTCH_MOD.
      USE SCRTCH_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/COMP/ into COMP_MOD.
      USE COMP_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/CONSTANTS/ into CONSTANTS_MOD.
      USE CONSTANTS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into IOUNITS_MOD.
      USE IOUNITS_MOD
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
C MHP 8/25 Milne output file is now opened in parmin,unused variables removed
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
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
      DIMENSION HCOMP(15,JSON),HD(JSON),HL(JSON),HP(JSON),HR(JSON),
     *     HS1(JSON)
      REAL*8 NP1
      SAVE

C  FIND THE MILNE INVARIANTS U AND V, ALONG WITH THE INDEX N+1.
C  WRITE THEM OUT TO LOGICAL UNIT IMILNE.
C  HEADER
      SMTOT = DEXP(CLN*STOTAL)/CMSUN
      WRITE(IMILNE,5) MODEL,XENV,ZENV,SMTOT
    5 FORMAT(10X,'MODEL',I5,'  XENV =',1PD10.3,'  ZENV =',D10.3,
     *      '  MASS(SOLAR UNITS) =',D10.3)
C  CALCULATE FOR FIRST POINT(ALWAYS DONE)
      D = DEXP(CLN*HD(1))
      P = DEXP(CLN*HP(1))
      R = DEXP(CLN*HR(1))
      U = C4PI*D*R**3/HS1(1)
      V = DEXP(CLN*CGL)*HS1(1)*D/(P*R)
      W = U*HS1(1)*(SESUM(1)+SEG(7,1))/(HL(1)*CLSUN)
      NP1 = 1.0D0/SDEL(2,1)
      WRITE(IMILNE,10)1,HS1(1),R,P,D,HCOMP(1,1),HL(1),U,V,W,NP1
   10 FORMAT(1X,I4,10(1PE11.3))
C  PRINT OUT EVERY NPRTPT POINTS;LAST POINT ALWAYS PRINTED.
      IEND = 1
      IF(NPRTPT.LE.M) THEN
       IBEG = MAX(2,NPRTPT)
       IEND = M - MOD(M,NPRTPT)
       DO 20 I = IBEG,IEND,NPRTPT
          D = DEXP(CLN*HD(I))
          P = DEXP(CLN*HP(I))
          R = DEXP(CLN*HR(I))
          U = C4PI*D*R**3/HS1(I)
          V = DEXP(CLN*CGL)*HS1(I)*D/(P*R)
          W = U*HS1(I)*(SESUM(I)+SEG(7,I))/(HL(I)*CLSUN)
          NP1 = 1.0D0/SDEL(2,I)
          WRITE(IMILNE,10)I,HS1(I),R,P,D,HCOMP(1,I),HL(I),
     *                      U,V,W,NP1
   20    CONTINUE
      ENDIF
      IF(IEND.LT.M) THEN
C  PRINT OUT LAST POINT IF NPRTPT DOESNT DIVIDE EVENLY INTO M.
       D = DEXP(CLN*HD(M))
       P = DEXP(CLN*HP(M))
       R = DEXP(CLN*HR(M))
       U = C4PI*D*R**3/HS1(M)
       V = DEXP(CLN*CGL)*HS1(M)*D/(P*R)
       W = U*HS1(M)*(SESUM(M)+SEG(7,M))/(HL(M)*CLSUN)
       NP1 = 1.0D0/SDEL(2,M)
       WRITE(IMILNE,10)M,HS1(M),R,P,D,HCOMP(1,M),HL(M),
     *                   U,V,W,NP1
      ENDIF
      CLOSE(IMILNE)
      RETURN
      END
