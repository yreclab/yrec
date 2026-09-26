CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C     2006 OPAL Equation of State
C
C     LLP   October 17, 2006
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Routines associated with 2001 OPAL EOS
C
C     SUBROUTINE OEOS06
C     SUBROUTINE ESAC06
C     SUBROUTINE T6RINTEOS06
C     SUBROUTINE READCOEOS06
C     FUNCTION QUADEOS06
C     FUNCTION GMASS06
C     SUBROUTINE RADSUB06
C     FUNCTION RHOOFP06
C     SUBROUTINE EQBOUND06

C     SUBROUTINE MU is also used


C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     OEQOS06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      SUBROUTINE OEQOS06(T10,T,P10,P,D10,D,XC,Z,BETA,BETAI,
     1 BETA14,RMU,AMU,EMU,QDT,QDP,QCP,DELA,*)

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      parameter (mx=5,mv=10,nr=169,nt=197)
      PARAMETER ( IVARX = 25 )
      PARAMETER (CNVS = 0.434294481D0 )
      PARAMETER (ZERO = 0.0D0)

C       DIMENSION ATOMWT(4)
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON/CTLIM/ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TENV,TGCUT
C 9/25/26 MHP via Claude
C code changed to merge COMMON/CONST/, COMMON/CONST1/, COMMON/CONST2/,
C and COMMON/CONST3/ into a single COMMON/CONSTANTS/
      COMMON/CONSTANTS/CLSUN,CLSUNL,CLNSUN,CMSUN,CMSUNL,CRSUN,CRSUNL,
     *  CMBOL,CLN,CLNI,C4PI,C4PIL,C4PI3L,CC13,CC23,CPI,CGAS,CA3,CA3L,
     *  CSIG,CSIGL,CGL,CMKH,CMKHN,CDELRL,CMIXL2,CMIXL3,CLNDP,CSECYR
      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH
C 9/25/26 MHP via Claude
C code changed to consolidate all I/O logical unit numbers, previously
C scattered across COMMON/LUOUT/, COMMON/LUNUM/, COMMON/ALEX06/,
C COMMON/ACDPTH/, COMMON/NEWOPAC/, COMMON/LOPAL95/, COMMON/ATMOS2/,
C COMMON/ALATM03/, COMMON/OPALEOS/, and COMMON/SCV2/, into a single
C COMMON/IOUNITS/
      COMMON/IOUNITS/ILAST,IDEBUG,ITRACK,ISHORT,IMILNE,IMODPT,ISTOR,
     *  IOWR,IFIRST,IRUN,ISTAND,IFERMI,IOPMOD,IOPENV,IOPATM,ISNU,
     *  IALEX06,ICLCD,IJLAST,IOPUREZ,IcondOpacP,ILIV95,IOATM,IOATMA,
     *  IOPALE,ISCVH,ISCVHE,ISCVZ

      common/eeos06/esact,eos(mv)

C      DATA NZP1/12/
C      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/

      SAVE
C
      iorder=9  ! gives all 1st and 2nd order data. See instructions
c                  in esac01.
c     NOTE: irad=0 does not add radiation; irad=1 adds radiation
      irad=1     ! does add radiation  corrections

      T=10.0D0**T10
      P=10.0D0**P10
      T6=T/1.0D6
      P12=P/1.0D12
      IF(T6.LT.0.001870D0.OR.T6.GT.200.0D0)RETURN 1
      X=XC
      ZTAB=Z

C       R=RHOOFP06(X,ZTAB,T6,P12,IRAD)  ! KC 2025-05-31
      R=RHOOFP06(X,T6,P12,IRAD)
      IF(R.LE.-998.0D0)THEN
         RETURN 1
      ENDIF
      D=R
      D10=DLOG10(D)

C       CALL ESAC06(X,ZTAB,T6,R,IORDER,IRAD,*999)  ! KC 2025-05-31
      CALL ESAC06(X,T6,R,IORDER,IRAD,*999)

c      IF(ABS((P12-EOS(1))/P12).GT.0.5D-6)THEN
c         WRITE(ISHORT,*)'***** RUN TERMINATED --ERROR IN OEQOS06 PTOT'
c         WRITE(ISHORT,*) 'P12,EOS(1) Differ: P12,EOS(1),T6,R,X,ZTAB=',
c     *         P12,EOS(1),T6,R,X,ZTAB
c         STOP ' ERROR IN OEQOS06 PTOT'
c      ENDIF

      QDP=1.0D0/EOS(6)                ! O2006 EOS(6) is dlogP/dlogRho at const T6
      QDT= -EOS(7)/ EOS(6)            ! O2006 EOS(7) is dlogp/dlogT6 at const Rho
      QCP=1.0D6*EOS(5)*EOS(8)/EOS(6)  ! O2006 EOS(5) is the specific heat. dE/dT6
                                      !              at const Vol
                                      ! O2006 EOS(8) is gamma1
      DELA=1.0D0/EOS(9)               ! O2006 EOS(9) is gamma2/(gamma2-1)

      BETA14=(2.521971383D-3*T6*T6)*(T6*T6/P12)
      BETA=1.0D0-BETA14
      BETAI=1.0D0/BETA
      RMU=P*BETA/(D*T)
      CALL MU(T,P,D,XC,Z,RMU2,AMU,EMU,BETA)
      IF(EMU.LE.0.0D0)THEN
      EMU=0.0D0
      AMU=RMU/CGAS-EMU
      ENDIF

      RETURN
  999 WRITE(ISHORT, *)'WARNNING... OPAL TBL FAIL'

      RETURN 1
      END
