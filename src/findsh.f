C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C FINDSH
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE FINDSH(HCOMP,HL,LC,M,JCORE,JENV,JXBEG,JXEND,JXMID,
     *                  LSHELL)
C 10/15/26 MHP via Claude
C code changed to take JSON from DIMENSIONS_MOD instead of declaring
C PARAMETER(JSON=5000) here.
      USE DIMENSIONS_MOD
C 10/14/26 MHP via Claude
C code changed to convert COMMON/NMLPAR/ into NMLPAR_MOD.
      USE NMLPAR_MOD
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
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
C 10/13/26 MHP via Claude
C code changed to drop COMMON/CTLIM/, declared here but never used.
      DIMENSION HCOMP(15,JSON),HL(JSON),LC(JSON)
      DATA DLMIN,DXMIN/1.0D-5,1.0D-5/
      SAVE
C   SR FINDSH LOCATES THE OUTER EDGE OF A CENTRAL CONVECTION ZONE AND THE INNER
C   EDGE OF A SURFACE C.Z.  IT ALSO LOCATES THE BEGINNING,CENTER,AND END OF
C   A HYDROGEN-BURNING SHELL IF APPLICABLE.
C ** TO BE ADDED **
C   LOCATING THE EXACT EDGES OF CENTRAL AND SURFACE C.Z.'S AND ADDING
C   POINTS AT THE EDGES.
C
C INPUT VARIABLES:
C DECLARED:
C   HCOMP : RUN OF MASS FRACTION OF THE VARIOUS CHEMICAL SPECIES.
C   HL : RUN OF LUMINOSITY AS A FUNCTION OF MASS (SOLAR UNITS).
C   LC : FLAG SET T IF A SHELL IS CONVECTIVE.
C   M : NUMBER OF POINTS IN THE MODEL.
C IN COMMON BLOCKS :
C   ATIME(1) : USER PARAMETER; IF X < ATIME(1) THEN THE PROGRAM CONSIDERS
C        THE STAR TO HAVE A HYDROGEN-BURNING SHELL RATHER THAN A HYDROGEN-
C        BURNING CORE.
C LOCAL VARIABLES :
C   DLMIN : THE OUTER EDGE OF THE H-BURNING SHELL IS DEFINED AS THE POINT
C        WHERE THE CHANGE IN LUMINOSITY FROM ONE SHELL TO THE NEXT
C        IS LESS THAN ENDSHL.
C   DXMIN : THE OUTER EDGE OF THE H-BURNING SHELL IS REACHED WHEN X DIFFERS
C        FROM THE SURFACE VALUE BY LESS THAN DXMIN REGARDLESS OF THE
C        LUMINOSITY TEST.
C
C OUTPUT VARIABLES :
C   JCORE : OUTERMOST POINT IN THE CONVECTIVE CORE (1=NO CONVECTIVE CORE)
C   JENV : INNERMOST POINT IN THE SURFACE C.Z. (M=NO SURFACE C.Z.)
C   LSHELL : FLAG SET T IF THE PROGRAM CONSIDERS THE MODEL TO HAVE A
C        HYDROGEN-BURNING SHELL.
C   IF LSHELL=T THEN THE FOLLOWING ARE COMPUTED :
C   JXBEG : FIRST SHELL WITH X > ATIME(1).
C   JXMID : FIRST SHELL WHERE X EXCEEDS 1/2 THE SURFACE VALUE.
C   JXEND : LAST SHELL WHERE L(I)-L(I-1) > ENDSHL OR X IS WITHIN 1.0E-5
C        OF THE SURFACE VALUE.
CCC H-SHELL VALUES
      JXBEG = 1
      JXMID = 1
      JXEND = 1
      LSHELL = .FALSE.
C  IF CENTRAL X BELOW THRESHOLD THEN CALCULATE H SHELL VALUES
      IF(HCOMP(1,1).LE.ATIME(1)) THEN
       LSHELL = .TRUE.
       XMID = 0.50D0*HCOMP(1,M)
       XLEND = DLMIN*HL(M)
C  FIND BEGINNING(JXBEG), MIDDLE(JXMID) AND END(JXEND) OF H SHELL
       DO 10 I = 1,M
c          IF(HCOMP(1,I).LE.1.0D-10) THEN  ! Changed after discussion with Marc
          IF(HCOMP(1,I).LE.ATIME(1)) THEN ! to force consistency with above LLP 9/24/08
             JXBEG = JXBEG+1
             JXMID = JXMID+1
          ELSE IF(HCOMP(1,I).LE.XMID) THEN
             JXMID = JXMID+1
          ELSE IF(HL(I) - HL(I-1).LT.XLEND) THEN
c               write(*,*)'luminosity criteria'
             GOTO 20
          ELSE IF(HCOMP(1,M) - HCOMP(1,I).LT.DXMIN) THEN
c               write(*,*)'composition criteria'
             GOTO 20
          ENDIF
   10    CONTINUE
       I = M
   20    JXEND = I
      ENDIF
CCC FIND BOUNDARY OF CENTRAL CONVECTION ZONE.
      DO 30 I = 1,M
       IF(.NOT.LC(I)) GOTO 40
   30 CONTINUE
   40 IF(I.GT.1) THEN
       JCORE = I-1
      ELSE
       JCORE = 1
      ENDIF
CCC FIND BOUNDARY OF SURFACE C.Z.
      DO 50 I = M,1,-1
       IF(.NOT.LC(I)) GOTO 60
   50 CONTINUE
   60 IF(I.LT.M) THEN
       JENV = I+1
      ELSE
       JENV = M
      ENDIF
C  FOR A FULLY CONVECTIVE STAR (JENV=1),TURN THE CONVECTIVE CORE OFF(JCORE=1).
C  THIS IS DONE BECAUSE JCORE IS USED IN COMPUTING THE NUCLEAR TIMESTEP,
C  AND PUTTING IT AT THE SURFACE DOES STRANGE THINGS.
      IF(JENV.EQ.1) JCORE = 1
      RETURN
      END
