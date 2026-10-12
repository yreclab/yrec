C      Subroutine ALTABINIT

C PURPOSE
C To analyze the internal Allard-format tables provided by ALFILEIN, verifying them
C and creating needed additoinal tables and elements.

C Several steps are taken:
C 1. Find the minimum (TEFFLmin) and maximum (TEFFLmax) permissable values of TEFFL. These are
C    one row's width below the bottom and above the top of the table. Because the first level
C    of interpolation is in GL, only a single minimum and maximum value of TEFFL are needed.
C 2. For each row in GL, find the index of the smallest element (iGLmin) and the index of the
C    largest element (iGLmax). There is one pair of these for each TEFFL.
C 3. For each row in GL, find the the minimum (GLmin) and maximum (GLmax) permissable value of
C    GL. These are one column's width less than the row minimum in GL and one column's width
C    greater than the column maximum. There is one pair of these for each TEFFL.
C 4. Validate the table. (a) Ensure that there are no invalid elements inside the table, i.e.,
C    no invalid element between the row's iGLmin and iGLmax. This check is made for every TEFFL.
C    (b) Ensure that every row has at least 4 valid entries and that there are at least 4 columns.


      SUBROUTINE ALTABINIT

      PARAMETER(NTA=250,NGA=25)
      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      IMPLICIT INTEGER*4(I,J,K,M,N)
      LOGICAL*4 LALTPTau100
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
      COMMON /ALATM01/ TEFFLs(NTA),GLs(NGA),FeHs(NGA),      ! Shared: ALFILEIN, ALTABINIT and ALSURFP
     x   ALPHAs(NGA),PLs(NTA,NGA),P100Ls(NTA,NGA),T100Ls(NTA,NGA),
     x   LOldNextGen,nTEFF,nGL,nFeH,nALPHA
      COMMON /ALATM02/ GLmin(NTA),GLmax(NTA),IGLmin(NTA),      ! Shared: ALTABINIT and ALSURFP
     x   IGLmax(NTA),TEFFLmin,TEFFLmax,GLXmin,GLXmax
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
C MHP 8/25 Removed character file names from common block
      COMMON /ALATM04/ DUMMY1,DUMMY2,DUMMY3,DUMMY4
      COMMON /ALATM05/ AL_TEFFLmin,AL_TEFFLmax

C 1. Find the minimum (TEFFLmin) and maximum (TEFFLmax) permissable values of TEFFL. These are
C    one row's width below the bottom and above the top of the table. Because the first level
C    of interpolation is in GL, only a single minimum and maximum value of TEFFL are needed.
      AL_TEFFLmin = TEFFLs(1)
      AL_TEFFLmax = TEFFLs(nTEFF)
      TEFFLmin = TEFFLs(1) - (TEFFLs(2)-TEFFLs(1))
      TEFFLmax = TEFFLs(nTeff) + (TEFFLs(nTeff)-TEFFLs(nTeff-1))

C 2. For each row in GL, find the index of the smallest element (iGLmin) and the index of the
C    largest element (iGLmax). There is one pair of these for each TEFFL.
      do i = 1, nTeff
         do j = 1, nGL
            if(PLs(i,j) .gt. -998D0) then
               iGLmin(i) = j
               goto 100
            endif
         enddo
  100    continue
         do j = nGL, 1, -1
            if(PLs(i,j) .gt. -998D0) then
               iGLmax(i) = j
               goto 110
            endif
         enddo
  110    continue

      enddo

C 3. For each row in GL, find the the minimum (GLmin) and maximum (GLmax) permissable value of
C    GL. These are one column's width less than the row minimum in GL and one column's width
C    greater than the column maximum. There is one pair of these for each TEFFL.

      GLXmin = 999D0
      GLXmax = -999D0
      do i = 1, nTeff
         j1 = iGLmin(i)
         j2 = iGLmax(i)
         GLmin(i) = GLs(j1) - 4D0*(GLs(j1+1) - GLs(j1))
         if(GLmin(i) .lt. GLXmin) GLXmin = GLmin(i)
         GLmax(i) = GLs(j2) + (GLs(j2) - GLs(j2-1))
         if(GLmax(i) .gt. GLXmax) GLXmax = GLmax(i)
      enddo

C 4. Validate the table. (a) Ensure that there are no invalid elements inside the table, i.e.,
C    no invalid element between the row's iGLmin and iGLmax. This check is made for every TEFFL.

      LBadTable = .false.
      do i = 1, nTeff
         j1 = iGLmin(i)
         j2 = iGLmax(i)
         do j = j1, j2
            if(PLs(i,j) .lt. -998D0) then
              LBadTable = .true.
              write(ISHORT,900) 'ALTABINIT: Bad input Allard Table: ',
     x           'TEFF, GL: ', 10D0**TEFFLs(i), GLs(j)
 900              format(2A,F5.0,F7.2)
            endif
         enddo
      enddo

C    (b) Ensure that every row has at least 4 valid entries and that there are at least 4 columns.
      if(nTeff .lt. 4) then
         LBadTable = .true.
         write(ISHORT,910) 'ALTABINIT: Bad input Allard Table: ',
     x      'Less than 4 rows: nTeff = ',nTeff
 910         format(A,I3)
      endif
      do i = 1, nTeff
         j1 = iGLmin(i)
         j2 = iGLmax(i)
         if ((j2 - j1 + 1) .lt. 4) then
            LBadTable = .true.
            write(ISHORT,920) 'ALTABINIT: Bad input Allard Table: ',
     x        'Row with less that 4 elements: i,#,Teff,GLMin,GLmax: ',
     x         i,j2-j1+1,10D0**TEFFLs(i),GLmin(i),GLmax(i)
 920            format(2A,2I4,2X,3F7.2)
         endif
      enddo

      if (LBadTable) goto 9999            ! If bad table, go to error exit

      return                  ! If good table, return

 9999      continue
       write(*,*)
       write(*,*)'******** ALTABINIT: Program Terminated ********'
       write(*,*)
       write(ISHORT,*)
       write(ISHORT,*)'******** ALTABINIT: Program Terminated ********'
       write(ISHORT,*)
       CALL ALPRINT
       STOP

       END

