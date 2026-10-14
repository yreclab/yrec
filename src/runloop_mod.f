C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C RUNLOOP_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/RUNLOOP/ into this module.  First module
C in the code, and the pattern the other blocks follow.
C
C RUNLOOP was itself the 10/13/26 merge of COMMON/CKIND/ and COMMON/SETT/:
C what was left of the per-run-loop control state once their namelist
C members moved to the consolidated block.  All four members are
C dimensioned on 50, the maximum number of runs -- not a shell or table
C extent -- and they are written by parmin.f, setcal.f, setscal.f and
C chkscal.f.  These are defined per large loop, not per model.
C
C The types restate what the old implicit typing gave each name, so the
C storage is unchanged:
C   RESCAL  R is in O-Z        -> IMPLICIT REAL*8(A-H,O-Z)
C   IRESCA  I is in no rule    -> default implicit INTEGER
C   LENDAG  L                  -> IMPLICIT LOGICAL*4(L)
C   LSETDT  L                  -> IMPLICIT LOGICAL*4(L)
C
C IRESCA is worth a note.  Only parmin.f carried IMPLICIT INTEGER*4(I,...);
C the other nine files left I to the default implicit rule, which is
C INTEGER*4 as built here but would become INTEGER*8 under
C -fdefault-integer-8, silently disagreeing with parmin.f.  Declaring
C INTEGER*4 here removes that latent inconsistency rather than preserving
C it.
C
C No member has a DATA statement, which is what makes this block a safe
C pilot: DATA on a USE-associated variable is illegal ("Cannot change
C attributes of USE-associated symbol"), so blocks that initialize their
C members need their initialization moved into the module itself.
C
C SAVE is stated explicitly rather than relying on module variables being
C implicitly saved, since that became implicit only in Fortran 2008 and
C ifort Classic predates it.  This matches COMMON's semantics exactly.
C
C Importers use USE ... , ONLY: and name just the members they reference,
C so no routine can capture a name it does not use.  That is the failure
C the RL/RLL rename had to pre-empt: a blanket USE imports every name in
C the block.
      MODULE RUNLOOP_MOD

      IMPLICIT NONE
      SAVE

      REAL*8    :: RESCAL(4,50)
      INTEGER*4 :: IRESCA(50)
      LOGICAL*4 :: LENDAG(50)
      LOGICAL*4 :: LSETDT(50)

      END MODULE RUNLOOP_MOD
