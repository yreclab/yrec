C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C AEOS06_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/20/26 MHP via Claude
C code changed to convert COMMON/AEOS06/ into this module, completing
C stages 3 and 4 (KNOWN_ISSUES.md issue 37).
C
C Imported with a blanket USE, the convention for the conversion.
C All 6 declarations of this block were identical, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what every declaring unit already gave them
C explicitly: MIDX and MF are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
C
C The dimension parameters are PRIVATE: they are OPAL06 table
C dimensions, which each importing unit also declares (issue 10).
C
C XA's initializer moved here from esac06.f, because DATA on a
C USE-associated name is rejected.  The literal text is copied
C verbatim, so the stored values are unchanged.
      MODULE AEOS06_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: MX = 5
      INTEGER*4, PARAMETER, PRIVATE :: MV = 10
      INTEGER*4, PARAMETER, PRIVATE :: NR = 169
      INTEGER*4, PARAMETER, PRIVATE :: NT = 197

      REAL*8    :: XZ(MX,MV,NT,NR)
      REAL*8    :: T6LIST(NR,NT)
      REAL*8    :: RHO(NR)
      REAL*8    :: T6A(NT)
      REAL*8    :: ESK(NT,NR)
      REAL*8    :: ESK2(NT,NR)
      REAL*8    :: DFSX(MX)
      REAL*8    :: DFS(NT)
      REAL*8    :: DFSR(NR)
      INTEGER*4 :: MIDX
      INTEGER*4 :: MF
      REAL*8    :: XA(MX)

      DATA XA/0.0,0.2,0.4,0.6,0.8/

      END MODULE AEOS06_MOD
