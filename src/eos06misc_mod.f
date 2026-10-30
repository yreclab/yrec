C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C EOS06MISC_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/20/26 MHP via Claude
C code changed to convert COMMON/EOS06MISC/ into this module, completing
C stages 3 and 4 (KNOWN_ISSUES.md issue 37).
C
C Imported with a blanket USE, the convention for the conversion.
C All 9 declarations of this block were identical, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what every declaring unit already gave them
C explicitly.  L1-L4 are INTEGER*4 despite the L: calcad.f, the one
C declaring file with an IMPLICIT LOGICAL*4(L) rule, always typed them
C INTEGER*4 explicitly.  SAVE is explicit rather than relying on module
C variables being implicitly saved, which holds only from Fortran 2008
C while ifort Classic predates it.  That matches COMMON's semantics.
C
C The dimension parameters are PRIVATE: they are OPAL06 table
C dimensions, which each importing unit also declares (issue 10).
C
C The INDEX, NTA and NRA initializers moved here from esac06.f, because
C DATA on a USE-associated name is rejected.  The value lists are copied
C verbatim.  The originals used implied-DO lists covering each whole
C array, written here as whole-array DATA, which stores the same values.
      MODULE EOS06MISC_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4, PARAMETER, PRIVATE :: MX = 5
      INTEGER*4, PARAMETER, PRIVATE :: MV = 10
      INTEGER*4, PARAMETER, PRIVATE :: NR = 169
      INTEGER*4, PARAMETER, PRIVATE :: NT = 197

      REAL*8    :: ESACT
      REAL*8    :: EOS(MV)
      REAL*8    :: Q(4)
      REAL*8    :: H(4)
      REAL*8    :: XXH
      INTEGER*4 :: L1
      INTEGER*4 :: L2
      INTEGER*4 :: L3
      INTEGER*4 :: L4
      INTEGER*4 :: K1
      INTEGER*4 :: K2
      INTEGER*4 :: K3
      INTEGER*4 :: K4
      INTEGER*4 :: IP
      INTEGER*4 :: IQ
      REAL*8    :: ZZ(MX)
      INTEGER*4 :: IRI(10)
      INTEGER*4 :: INDEX(10)
      INTEGER*4 :: NTA(NR)
      INTEGER*4 :: NRA(NT)

      DATA INDEX/1,2,3,4,5,6,7,8,9,10/
      DATA NTA/87*197,7*191,190,2*189,185,179,170,2*149,
     x  133,125,123,122,120,115,113,107,102,2*80,72,68,66,64,62,56,54,
     x  52,51,2*50,49,47,2*45,43,42,28*40,39,37,36,35,34,32,31,30,
     x  29,27,26/
      DATA NRA/ 26*169, 168, 2*167, 166, 165, 164,
     x   2*163, 162, 161, 160, 2*159, 158, 2*130, 129, 2*128,
     x   2*126, 2*125, 124, 122, 121, 2*120, 2*119, 6*118, 2*117,
     x   2*116, 2*115, 4*114, 8*113, 22*111, 5*110, 6*109, 2*108,
     x   5*107, 2*106, 105, 2*104, 8*103, 16*102, 21*100, 9* 99,
     x   6* 98, 4* 97, 95, 94, 6* 87/

      END MODULE EOS06MISC_MOD
