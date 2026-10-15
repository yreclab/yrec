C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C DIMENSIONS_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/15/26 MHP via Claude
C code changed to hold the code's own structural array dimensions in
C one place, replacing a PARAMETER statement repeated in every file
C that needed it.
C
C JSON is the maximum number of shells.  It is a property of the
C code's own arrays, not of any input data file, so one global value
C is correct by construction: there is no table that could want a
C different JSON.  It was declared identically as PARAMETER(JSON=5000)
C in 108 files.
C
C This module deliberately holds ONLY dimensions of that kind.  The
C input-table dimensions do NOT belong here, because the same name
C carries different values for different tables: NUMT is 70 for the
C OPAL95 opacities and 85 for Alexander 2006, NT is 57 for the
C surface-pressure tables and 197 for the OPAL06 equation of state,
C and NTA/NGA differ between the old and current Allard formats.  One
C module cannot hold NUMT twice.  Each table module declares its own
C PRIVATE copy instead, so those values coexist by scope with no
C renaming -- see KNOWN_ISSUES.md issue 26.
C
C Per-routine scratch bounds are excluded for the same reason: NMAX is
C 15, 42, 100 and 8000 in five different routines, sizing local
C workspace.
C
C PUBLIC, unlike the PRIVATE copies the block modules carry, since
C exporting it is the entire point.  A file gaining USE DIMENSIONS_MOD
C must drop its own PARAMETER(JSON=5000): keeping both is a conflict
C error, and that clash is why the block modules made theirs PRIVATE.
      MODULE DIMENSIONS_MOD

      IMPLICIT NONE

      INTEGER*4, PARAMETER :: JSON = 5000

      END MODULE DIMENSIONS_MOD
