C LLP  10/16/06 SUBROUTINE TO CHECK IF POINT IS WITHIN
C OPAL 2006 EOS TABLE.

C       SUBROUTINE EQBOUND06(T,DL,DL0,FAC,LTAB,LRAMP)  ! KC 2025-05-31
      SUBROUTINE EQBOUND06(T,DL,FAC,LTAB,LRAMP)
C 10/20/26 MHP via Claude
C code changed to replace implicit typing with IMPLICIT NONE and
C explicit declarations.
      IMPLICIT NONE
      REAL*8 D,DFS,DFSR,DFSX,DL,DRAMPF,EOS,ESACT,ESK,ESK2,FAC,H,Q,RHO,T,
     *       T6,T6A,T6LIST,TRAMPF,XA,XXH,XZ,ZZ
      INTEGER INDEX,IRI,MF,MIDX,MV,MX,NR,NRA,NT,NTA
      LOGICAL*4 LRAMP,LTAB
      Integer*4 l1,l2,l3,l4,k1,k2,k3,k4,ip,iq,k,l
      parameter (mx=5,mv=10,nr=169,nt=197)
      common/aeos06/  xz(mx,mv,nt,nr),
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),midx,mf,xa(mx)
C 10/9/26 MHP via Claude
C code changed to rename AEOS06's M member to MIDX: M is such a
C universally-used name elsewhere in this codebase (e.g. shell count
C in calcad.f) that keeping it here was just asking for a future
C collision. M is genuinely used (as a composition/mixture-axis
C index) in esac06.f and readcoeos06.f; declared but never read or
C written by name in this file.
C KC 2025-05-30 reordered common block elements
C       common/beos06/ iri(10),index(10),nta(nr),zz(mx),nra(nt)
C 10/9/26 MHP via Claude
C code changed to merge COMMON/EEOS06/, COMMON/AAEOS06/, COMMON/BBEOS06/,
C and COMMON/BEOS06/ into COMMON/EOS06MISC/ (see esac06.f for the full
C rationale). AEOS06 (above) is left untouched.
      common/eos06misc/esact,eos(mv),q(4),h(4),xxh,
     .     l1,l2,l3,l4,k1,k2,k3,k4,ip,iq,
     .     zz(mx),iri(10),index(10),nta(nr),nra(nt)

      SAVE
      T6 = T*1.0D-6
      D = 10D0**DL

C EXIT IF OUTSIDE TABLE IN RHO
      IF((D.LT.rho(1)) .OR. (D.GE.rho(nr)))THEN
         GOTO 9999        ! Out of Table in density. Go to out of table exit.
      ENDIF

C Exit if outside table in T6
      IF((T6 .GT. T6a(1)) .OR. (T6 .LE. T6a(nt))) THEN
         GOTO 9999        ! Out of Table in temperature. Go to out of table exit.
      ENDIF

C Initialize
      DRampF = 1D0   ! Initialize density ramp factor to 1
      TRampF = 1D0   ! Initialize temperature ramp factor to 1
      LTAB = .TRUE.  ! Presume that T6,D point is in OPAL table
      LRAMP = .FALSE. ! presume ramping is not needed,
                      ! i.e. we are not in the border of the table.

C Check for easy borders
      IF(T6 .GT. T6a(2)) THEN
          TRampF = (T6-T6a(1))/(t6a(2)-T6a(1)) ! Ramp in temperature
          LRAMP = .TRUE.
      ENDIF
      IF(D .LT. rho(2)) THEN
          DRampF = (D - rho(1))/(rho(2)-rho(1)) ! Ramp in density
          LRAMP = .TRUE.
      ENDIF

C Find a k such that T6a(k-1) >= T6 > T6a(k)
C and an l such that rho(l-1) <  D  <= rho(l)
C The ESAC06 variables (k=)k3 and (l-)l2 are close to what we need.
C A linear search will work fine.
      k = k3
 10   IF(T6 .LE. T6a(k)) then
        k = k+1
        goto 10
      ENDIF
 20   If( T6 .GT. T6a(k-1)) THEN
        k = k-1
        goto 20
      ENDIF
C We now have: T6a(k-1) >= T6 > T6a(k)

      l = l2
 30   IF(D .GT. rho(l)) THEN
        l = l+1
        goto 30
      ENDIF
 40   IF(D .LE. rho(l-1)) THEN
        l = l-1
        goto 40
      ENDIF
C We now have: rho(l-1) <  D  <= rho(l)

C For a given temperature in array T6a with index k, e.e., T6a(k), element
C nra(k) of array nra contains the index to the max allowed density in
C array rho. So, for a given T6a(k), the associated D must be less than
C rho(nra(k)). A valid index in array rho must be less than or equal to
C nra(k)

      IF(l .GT. nra(k)) then
        goto 9999       ! Out of table exit in density.
      ENDIF
      IF(l .EQ. nra(k)) THEN
        LRAMP = .TRUE.
        DRampF = (rho(l)-D)/(rho(l)-rho(l-1))
      ENDIF

C For a given density in array rho with index l, i.e., rho(l), element
C nta(l) of array nta contains the index to the min allowed temperature
C in array T6a. So for a given rho(l), the associated T6 must be
C greater than T6a(nta(l)). (Note that T6a is a decreasing array.) A
C valid index in T6a must be less than or equal to nta(l).

      IF(k .GT. nta(l)) then
        goto 9999      ! Out of table exit in temperature
      ENDIF
      IF(k .EQ. nta(l)) THEN
        LRAMP = .TRUE.
        TRampF = (T6-T6a(k))/(T6a(k-1)-T6A(k))
      ENDIF

      FAC = DRampF * TRampF
      return

C OUT OF TABLE EXIT
 9999 CONTINUE
      LTAB = .FALSE.       ! Not in table
      LRAMP = .TRUE.       ! Turn on ramping
      FAC = 0D0            ! Set ramping factor to zero
C                            This way, out of table results are ramped to zero.
      RETURN

      END
c
