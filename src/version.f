C----------------------------------------
C  YREC version value assignment
C----------------------------------------
#define YREC_VERSION '202602'

#ifndef GIT_HASH
#define GIT_HASH 'unknown'
#endif

      SUBROUTINE SETVERSION(YRECVER,GITHASH)
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE.
      IMPLICIT NONE
      CHARACTER*10 YRECVER
      ! Short git commit hash + indicator if working tree was not clean
      CHARACTER*20 GITHASH
C 10/13/26 MHP via Claude
C code changed to replace COMMON/VERSION/ with explicit arguments.  These
C are CHARACTER, which does not belong in a COMMON block; SETVERSION sets
C them and parmin.f is the only reader, so main.f now holds them and
C passes them to both.
      YRECVER = YREC_VERSION
      GITHASH = GIT_HASH
      END
