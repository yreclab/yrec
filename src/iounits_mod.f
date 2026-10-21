C
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C IOUNITS_MOD
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C 10/14/26 MHP via Claude
C code changed to convert COMMON/IOUNITS/ into this module.
C
C Imported with a blanket USE, the convention for the conversion.
C All 58 files declared this block identically, so the USE
C imports exactly the names the declaration already made global in
C each scoping unit and cannot change meaning.
C
C The types restate what the implicit rules supplied: L is
C LOGICAL*4, I/J/K/M/N are INTEGER*4, everything else REAL*8.
C SAVE is explicit rather than relying on module variables being
C implicitly saved, which holds only from Fortran 2008 while ifort
C Classic predates it.  That matches COMMON's semantics.
      MODULE IOUNITS_MOD

      IMPLICIT NONE
      SAVE

      INTEGER*4 :: ILAST
      INTEGER*4 :: IDEBUG
      INTEGER*4 :: ITRACK
      INTEGER*4 :: ISHORT
      INTEGER*4 :: IMILNE
      INTEGER*4 :: IMODPT
      INTEGER*4 :: ISTOR
      INTEGER*4 :: IOWR
      INTEGER*4 :: IFIRST
      INTEGER*4 :: IRUN
      INTEGER*4 :: ISTAND
      INTEGER*4 :: IFERMI
      INTEGER*4 :: IOPMOD
      INTEGER*4 :: IOPENV
      INTEGER*4 :: IOPATM
      INTEGER*4 :: ISNU
      INTEGER*4 :: IALEX06
      INTEGER*4 :: ICLCD
      INTEGER*4 :: IJLAST
      INTEGER*4 :: IOPUREZ
      INTEGER*4 :: IcondOpacP
      INTEGER*4 :: ILIV95
      INTEGER*4 :: IOATM
      INTEGER*4 :: IOATMA
      INTEGER*4 :: IOPALE
      INTEGER*4 :: ISCVH
      INTEGER*4 :: ISCVHE
      INTEGER*4 :: ISCVZ
      INTEGER*4 :: ISOUND

      END MODULE IOUNITS_MOD
