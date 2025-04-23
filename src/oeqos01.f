CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C     2001 OPAL Equation of State
C
C     LLP   August 10, 2003
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Routines associated with 2001 OPAL EOS
C
C     SUBROUTINE OEOS01
C     SUBROUTINE ESAC01
C     SUBROUTINE T6RINTEOS01
C     SUBROUTINE READCOEOS01
C     FUNCTION QUADEOS01
C     FUNCTION GMASS01
C     SUBROUTINE RADSUB01
C     FUNCTION RHOOFP01
C     SUBROUTINE EQBOUND01

C     SUBROUTINE MU is also used


C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     OEQOS01
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      SUBROUTINE OEQOS01(T10,T,P10,P,D10,D,XC,Z,BETA,BETAI,
     1 BETA14,RMU,AMU,EMU,QDT,QDP,QCP,DELA,*)
      use params, only : ivarx, cnvs, zero, mx, mv, nr => nr01, nt => nt01
      use settings, only : ISHORT  ! COMMON/LUOUT/
      use settings, only : CGAS, CA3  ! COMMON/CONST2/

      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT LOGICAL*4(L)

      DIMENSION ATOMWT(4)
      COMMON/COMP/XENV,ZENV,ZENVM,AMUENV,FXENV(12),XNEW,ZNEW,STOTAL,
     *     SENV
      COMMON/CTLIM/ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TENV,TGCUT
      COMMON/CCOUT2/LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH

      common/eeos/esact,eos(mv)

      DATA NZP1/12/
      DATA ATOMWT/0.9921D0,0.24975D0,0.08322D0,0.4995D0/

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
      IF(T6.LT.0.0020D0.OR.T6.GT.100.0D0)RETURN 1
      X=XC
      ZTAB=Z

      R=RHOOFP01(X,ZTAB,T6,P12,IRAD)
      IF(R.LE.-998.0D0)THEN
         RETURN 1
      ENDIF
      D=R
      D10=DLOG10(D)

      CALL ESAC01(X,ZTAB,T6,R,IORDER,IRAD,*999)

c      IF(ABS((P12-EOS(1))/P12).GT.0.5D-6)THEN
c         WRITE(ISHORT,*)'***** RUN TERMINATED --ERROR IN OEQOS01 PTOT'
c         WRITE(ISHORT,*) 'P12,EOS(1) Differ: P12,EOS(1),T6,R,X,ZTAB=',
c     *         P12,EOS(1),T6,R,X,ZTAB
c         STOP ' ERROR IN OEQOS01 PTOT'
c      ENDIF
C      QDP=1.0D0/EOS(6)
      QDP=1.0D0/EOS(5)
C      QDT= -EOS(7)/ EOS(6)
      QDT= -EOS(6)/ EOS(5)

C      QCP=1.0D6*EOS(5)*EOS(8)/EOS(6)
      QCP=1.0D6*EOS(4)*EOS(7)/EOS(5)
C      DELA=1.0D0/EOS(9)
      DELA=1.0D0/EOS(8)

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
