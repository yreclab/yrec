C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C
C     READCOEOS06
C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

      subroutine readcoeos06

c..... The purpose of this subroutine is to read the OPAL 2006 EOS data tables

      parameter (mx=5,mv=10,nr=169,nt=197)
      IMPLICIT REAL*8 (A-H,O-Z)
      real*8 moles
      LOGICAL*4 lopale06,LNumDeriv
C MHP 8/25 Remove unused variables
C 9/24/26 MHP via Claude
C code changed to remove the OPAL 1995/2001 equations of state
      character*1 blank
      common/aeos06/  xz(mx,mv,nt,nr),
     . t6list(nr,nt),rho(nr),t6a(nt),esk(nt,nr),esk2(nt,nr),dfsx(mx)
     . ,dfs(nt),dfsr(nr),midx,mf,xa(mx)
C 10/9/26 MHP via Claude
C code changed to rename AEOS06's M member to MIDX throughout: M is
C such a universally-used name elsewhere in this codebase (e.g. shell
C count in calcad.f) that keeping it here was just asking for a
C future collision. Used in this file as the composition/mixture-axis
C loop index below.
C KC 2025-05-30 reordered common block elements
C       common/beos06/ iri(10),index(10),nta(nr),zz(mx),nra(nt)
C 10/9/26 MHP via Claude
C code changed to merge COMMON/EEOS06/, COMMON/AAEOS06/, COMMON/BBEOS06/,
C and COMMON/BEOS06/ into COMMON/EOS06MISC/ (see esac06.f for the full
C rationale). AEOS06 and EEEOS06 are left untouched.
      common/eos06misc/esact,eos(mv),q(4),h(4),xxh,
     .     l1,l2,l3,l4,k1,k2,k3,k4,ip,iq,
     .     zz(mx),iri(10),index(10),nta(nr),nra(nt)
      common/eeeos06/ epl(mx,nt,nr),xx(mx)
C Amu_M and alogNe were incorrectly dimensoned Amu_M(mx,nr) and alogNe(mx,nr).
C the required dimensions are Amu_M(nr,nt) alogNe(nr,nt), which is much larger.
C Something was being overwritten.         llp 8/19/08
C     x    amu_M(mx,nr),alogNe(mx,nr),rhogr(mx,nr),frac(mx,6),
C KC 2025-05-30 reordered common block elements
C       common/eeeeos06/moles(mx),xin(mx),tmass(mx),icycuse(mx,nr),
C 10/9/26 MHP via Claude
C code changed to convert COMMON/EEEEOS06/ to plain local arrays:
C declared only in this file (confirmed via a codebase-wide scan), so
C there's nothing to share via COMMON -- and nothing here reads these
C values back after they're populated either, so this subroutine's
C value-across-calls behavior is unaffected either way (it's only
C ever called once, from esac06.f). Added SAVE below anyway, which
C costs nothing (a SAVE'd local array and a COMMON-block array are
C both ordinary static storage, same footprint) and protects against
C any future refactor that calls this more than once.
      dimension moles(mx),xin(mx),tmass(mx),
     x    amu_M(nr,nt),alogNe(nr,nt),rhogr(mx,nr),frac(mx,6),
C      x    alogr(nr,nt)
     x    alogr(nr,nt),icycuse(mx,nr)
      save
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
C 10/12/26 MHP via Claude
C code changed to extend COMMON/NMLPAR/ to 234 members, adding the
C namelist variables that the physics routines read from 27 COMMON
C blocks which also held derived or working members.  Those blocks keep
C only their non-namelist members; five of them -- NEWMX, VMULT,
C PMMWIND, CCOUT1 and ENVGEN -- had nothing left and are gone.
C Derivation-only namelist variables from the same blocks went to
C COMMON/NMLBYPASS/ instead, not here.
C
C Declared identically in all 121 files that hold any of these members.
C Generated from one member list, so every copy is byte-identical; the
C linker's 'size of symbol changed' warning is the check that they are.
      COMMON/NMLPAR/
     * ALATM_FeH,ALATM_Alpha,LALTPTau100,SLI6,SLI7,SBE91,SBE92,SBE93,
     * CMIN,ABSTOL,RELTOL,KEMMAX,TOLL,TOLR,TOLZ,LCALS,LCALSOLZX,
     * CALSOLZX,CALSOLAGE,LDEBUG,LCORR,LMILNE,LTRACK,LSTPCH,LRWSH,
     * CSTMIXING,CSTDIFFMIX,LCORE,MCORE,FCORE,DTWIND,LPTIME,DTDIF,
     * DJOK,ITDIF1,ITDIF2,LEXCOM,LTRIST,DT_GS,XMIN,YMIN,LTHOULFIT,
     * FGRY,FGRZ,LTHOUL,LDIFZ,LNEWDIF,LDIFLI,GRTOL,ILAMBDA,NITER_GS,
     * LDIFY,LKUTHE,ATMERR,ATMD0,ATMBEG,ATMMIN,ATMMAX,ENVERR,ENVBEG,
     * ENVMIN,ENVMAX,CODM,LCODM,DMDT0,FCZDMDT,FTOTDMDT,COMPACC(15),
     * CREIM,LREIMER,LMDOT,XNEWCP,INEWCP,LNEWCP,LREL,NITER4,LNEWS,
     * LSNU,XENV0A(50),ZENV0A(50),CMIXLA(50),LSENV0A(50),SENV0A(50),
     * LNOJ,lopale06,lNumDeriv,POA,POB,POC,POMAX,LPOUT,WNEW,WALPCZ,
     * ACFPFT,ITFP1,ITFP2,LROT,LINSTB,LWNEW,LSOLID,IMPJMOD,SPOTF,
     * SPOTX,LSDEPTH,ITRVER,FESC,FSSC,FGSFC,IES,IGSF,IMU,VNEW(12),
     * WEAKSCREENING,KTTAU,KTTAU0,LTTAU,XLS,XLSTOL,STEFF,SR,LTEFF,
     * LCALST,LSTORE,LSTATM,LSTENV,LSTMOD,LSTPHYS,LSTROT,LSTCH,
     * NPRTMOD,NPRTPT,NPOINT,TRIDT,TRIDL,LNEW0,NMODLS(50),LFIRST(50),
     * NUMRUN,SSTANDARD(17),ATIME(14),TCUT(5),TSCUT,TENV0,TENV1,TGCUT,
     * HTOLER(5,2),FCORR0,FCORRI,HPTTOL(12),NITER1,NITER2,NITER3,WMAX,
     * EXMD,EXW,EXTAU,EXR,EXM,EXL,EXPR,CONSTFACTOR,EXCEN,LJDOT0,
     * ETADH0,ETADH1,LDH,TDISK,PDISK,LDISK,DPENV,ALPHAC,ALPHAE,ALPHAM,
     * BETAC,LOVSTC,LOVSTE,LOVSTM,LSEMIC,LADOV,LOVMAX,ATMSTP,ENVSTP,
     * LSOLWIND,LMIXTURE,LISOTOPE,FRAC_C,FRAC_N,FRAC_O,R12_13,R16_18,
     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,ZOPAL951,TMOLMIN,
     * TMOLMAX,TOLLAOL,LALEX06,LOPAL95,LPUREZ,LcondOpacP,LNULOS1,
     * OPTOL,LNEWTCZ,LCALCENV,PMMSOLP,PMMSOLW,PMMSOLTAU,LMWIND,
     * LROSSBY,LBSCALE,LPULSE,IPVER,LSCV,ENDAGE(50),SETDT(50),
     * END_DCEN(50),END_XCEN(50),END_YCEN(50),LVFC,LDIFAD,FW,FC,FES,
     * FGSF,FMU,FSS,RCRIT,RSCLZC(50),RSCLZM1(50),RSCLZM2(50),LZRAMP

      save
      blank=' '


        if (itimeco .ne. 12345678) then
        do i=1,mx
          do j=1,mv
            do k=1,nt
              do l=1,nr
                xz(i,j,k,l)=1.D+35
              enddo
            enddo
          enddo
        enddo
        do j = 1,mv
        eos(j) = 1D0
      enddo
        itimeco=12345678
        endif

      close (2)
c.....read  tables
C MHP 8/25 Moved opening of file to parmin
      do 3 midx=1,mx
      read (IOPALE,'(3x,f6.4,3x,f12.9,11x,f10.7,17x,f10.7)')
     x  xin(midx),zz(midx),moles(midx),tmass(midx)
      read (IOPALE,'(21x,e14.7,4x,e14.7,3x,e11.4,3x,e11.4,3x,e11.4,
     x 4x,e11.4)') (frac(midx,i),i=1,6)
      read (IOPALE,'(a)') blank
      do 2 jcs=1,nr
      read (IOPALE,'(2i5,2f12.7,17x,e15.7)') numtot,icycuse(midx,jcs)
     x  ,dum,dum,rhogr(midx,jcs)
      if(numtot .ne. jcs) then
         write (ISHORT,'(" OEOS06 Data file incorrect: numtot,jcs= "
     x   ,  2i5)') numtot,jcs
         stop
      endif
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
      if (icycuse(midx,jcs) .lt. nta(jcs)) then
         write (ISHORT,'("Problem with OEOS96 data files: X=",f6.4,
     X         " density=",e14.4)') xin(midx), rhogr(midx,jcs)
         stop
      endif
      do  i=1,icycuse(midx,jcs)
      if (i .gt. nta(jcs)) then
         read (IOPALE,'(a)') blank
         go to 4
      endif
      read (IOPALE,'(f11.6,1x,f6.4,e11.4,2e13.6,2e11.3,5f10.6)')
     x t6list(jcs,i),amu_M(jcs,i),alogNe(jcs,j),
     x (xz(midx,index(iv),i,jcs),iv=1,9)
    4 continue
      enddo
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
      read(IOPALE,'(a)') blank
    2 continue
      read(IOPALE,'(a)') blank
    3 continue

      do i=1,nt
         if(t6list(1,i) .eq. 0D0) then
            write(ISHORT,'("READCOEOS06: Error:",i4,
     $           "-th T6 value is zero")') i
            stop
         endif
         t6a(i)=t6list(1,i)
      enddo
      do 12 i=2,nt
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C    12 dfs(i)=1D0/(t6a(i)-t6a(i-1))
        dfs(i)=1D0/(t6a(i)-t6a(i-1))
   12 continue
      rho(1)=rhogr(1,1)
      do 13 i=2,nr
C KC 2025-05-30 fixed "DO termination statement which is not END DO or CONTINUE"
C       rho(i)=rhogr(1,i)
C    13 dfsr(i)=1D0/(rho(i)-rho(i-1))
         rho(i)=rhogr(1,i)
         dfsr(i)=1D0/(rho(i)-rho(i-1))
   13 continue
      do i=2,mx
      dfsx(i)=1D0/(xx(i)-xx(i-1))
      enddo
      CLOSE (IOPALE)

      return
      end
