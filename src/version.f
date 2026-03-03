C----------------------------------------
C  YREC version value assignment
C----------------------------------------
#define YREC_VERSION '202602'

#ifndef GIT_HASH
#define GIT_HASH 'unknown'
#endif

      SUBROUTINE SETVERSION()
      CHARACTER*10 YRECVER
      ! Short git commit hash + indicator if working tree was not clean
      CHARACTER*20 GITHASH
      COMMON/VERSION/ YRECVER, GITHASH
      YRECVER = YREC_VERSION
      GITHASH = GIT_HASH
      END
