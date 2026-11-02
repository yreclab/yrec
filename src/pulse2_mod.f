C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C PULSE2_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/PULSE2/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 4 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
      MODULE PULSE2_MOD

      IMPLICIT NONE
      SAVE

      REAL*8 :: QQDP
      REAL*8 :: QQED
      REAL*8 :: QQET
      REAL*8 :: QQOD
      REAL*8 :: QQOT
      REAL*8 :: QDEL
      REAL*8 :: QDELA
      REAL*8 :: QQCP
      REAL*8 :: QRMU
      REAL*8 :: QTL
      REAL*8 :: QPL
      REAL*8 :: QDL
      REAL*8 :: QO
      REAL*8 :: QOL
      REAL*8 :: QT
      REAL*8 :: QP
      REAL*8 :: QQDT
      REAL*8 :: QEMU
      REAL*8 :: QD
      REAL*8 :: QFS

      END MODULE PULSE2_MOD
