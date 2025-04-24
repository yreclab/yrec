
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C RSCALE
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE RSCALE(HL,HCOMP,HS,HSTOT,M,NK,SMASS,LC)
C DBG 5/94 Added rescaling of Z in core ZRAMP stuff.
      use params, only : json
      use settings, only : ISHORT  ! /LUOUT/
      use settings, only : RESCAL  ! /CKIND/
      use settings, only : XENV, ZENV, XNEW, ZNEW, STOTAL, SENV  ! /COMP/
      use settings, only : CMSUN  ! /CONST/
      use settings, only : CLN  ! /CONST1/

      IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT LOGICAL*4(L)
      CHARACTER*256 FLAOL2, FOPAL2
C MHP 5/91 COMMON BLOCK ADDED TO FIX CORE RESCALING.
      COMMON/LABEL/XENV0,ZENV0
C MHP 10/24 ADDED NEW CONTROLS FOR ALTERING THE HEAVY ELEMENT MIXTURE
C THEY ARE USED IN STARIN. THE OLD ENTRIES (XNEWCP->ANEWCP) ARE USED HERE
c      COMMON/NEWCMP/XNEWCP,INEWCP,LNEWCP,LREL,ACOMP
      COMMON/NEWCMP/XNEWCP,INEWCP,LNEWCP,LREL
c      ISETMIX,ISETISO,
c     * LMIXTURE,LISOTOPE,FRAC_C,FRAC_N,FRAC_O,R12_13,R14_15,R16_17,R16_18,ZXMIX,
c     * XH2_INI,XHE3_INI,XLI6_INI,XLI7_INI,XBE9_INI,XB10_INI,XB11_INI
C COMMON/NEWCMP/XNEWCP,INEWCP,LNEWCP,LREL,ANEWCP
C DBG 5/94 ZRAMP stuff.
      COMMON/ZRAMP/RSCLZC(50), RSCLZM1(50), RSCLZM2(50),
     *     IOLAOL2, IOOPAL2, NK2,
     *     LZRAMP, FLAOL2, FOPAL2
      DIMENSION HCOMP(15,JSON),HS(JSON),HL(JSON),LC(JSON)
      SAVE

c ************
c      write(*,*)
c      write(*,*)'Entering rscale ',HSTOT-HS(M)
c ************

      IF(RESCAL(2,NK).GT.0.0D0) THEN
C  RESCALE X BY MULTIPLYING ALL SHELL X VALUES BY THE RATIO (XNEW/XOLD)
C  WHERE XOLD = OLD SURFACE X VALUE
C  THIS METHOD OK FOR BOTH HORIZONTAL BRANCH AND MAIN SEQUENCE STARS
         IF(RESCAL(2,NK).LE.1.0D0) THEN
            XFACT = RESCAL(2,NK)/DMAX1(XNEW,1.0D-20)
            DO 10 I = 1,M
               HCOMP(1,I) = DMIN1(RESCAL(2,NK),HCOMP(1,I)*XFACT)
   10       CONTINUE
            XNEW = RESCAL(2,NK)
            XENV0 = RESCAL(2,NK)
C DBG 4/95 BUG FIX XENV IS USED IN SOME ROUTINES AND NOT XENV0 SO CHANGE
C     XENV WHENEVER X IS CHANGED.
C MHP 7/99 THIS IS NOT A BUG, IT IS NECESSARY.
C XENV IS USED TO SET THE INITIAL MU FOR THE YALE EQUATION OF STATE,
C AND IT SHOULD NOT BE CHANGED AFTER THE FIRST RUN.
C            XENV = XENV0
         ELSE
C  DESIRED X >100%; X NOT CHANGED
C            ACOMP = ' X '
            I1 = 2
            WRITE(ISHORT,1000)NK,RESCAL(I1,NK)
 1000       FORMAT(1X,'ERROR IN SUBROUTINE RSCALE'/1X,'RESCALING OF X',
     *      ' IN KIND CARD #',I3,1X,'FAILED - DESIRED COMP',F9.6/1X,
     *      'GREATER THAN UNITY.  X NOT RESCALED')
         ENDIF
      ENDIF
      IF(RESCAL(3,NK).GE.0.0D0) THEN
C  RESCALE Z BY ADDING (RESCAL(3,NK)-OLD Z) TO EACH Z VALUE IN THE STAR
C  THE CNO CYCLE ELEMENTS AND HE3 ARE MULTIPLIED BY THE RATIO OF THE
C  DESIRED NEW Z TO THE OLD Z - LIGHT ELEMENT ABUNDANCES ARE LEFT ALONE
         IF(RESCAL(3,NK).LE.1.0D0) THEN
            DELZ = RESCAL(3,NK) - ZNEW
            DO 30 J = 1,M
               ZFACT=DMAX1(0.D0,HCOMP(3,J)+DELZ)/(HCOMP(3,J)+1.D-30)
               HCOMP(3,J) = DMAX1(0.0D0,HCOMP(3,J)+DELZ)
               DO 20 I = 5,11
                  HCOMP(I,J) = HCOMP(I,J)*ZFACT
   20          CONTINUE
   30       CONTINUE
            ZNEW = RESCAL(3,NK)
            ZENV0 = RESCAL(3,NK)
C DBG 4/95 BUG FIX ZENV IS USED IN MANY ROUTINES AND NOT ZENV0 SO CHANGE
C     ZENV WHENEVER Z IS CHANGED.
            ZENV = ZENV0
         ELSE
C  DESIRED Z >100%; Z NOT CHANGED
C            ACOMP = ' Z '
            I1 = 3
            WRITE(ISHORT,1002)NK,RESCAL(I1,NK)
 1002       FORMAT(1X,'ERROR IN SUBROUTINE RSCALE'/1X,'RESCALING OF Z',
     *      ' IN KIND CARD #',I3,1X,'FAILED - DESIRED COMP',F9.6/1X,
     *      'GREATER THAN UNITY.  Z NOT RESCALED')
         ENDIF
      ENDIF
      IF(HCOMP(1,1).GT.1.0D-10) THEN
c ************
c      write(*,*)'Entering MS change ',HSTOT-HS(M)
c ************

C  MAIN SEQUENCE RESCALING - MASS AND SINGLE ELEMENT.
         IF(LNEWCP.AND.XNEWCP.GE.0.0D0) THEN
C  RESCALE THE ABUNDANCE OF ONE ELEMENT OTHER THAN X,Y,Z
C  JNEWCP = INDEX OF ELEMENT TO BE CHANGED IN MATRIX HCOMP
C  IF LREL = T, ABUNDANCE IS RELATIVE TO SURFACE HYDROGEN ABUNDANCE
C  ON A LOGARITHMIC SCALE WHERE X ABUNDANCE = 12.0
C  E.G. AN ABUNDANCE OF 3.0 MEANS 1.0D-9* SURFACE H ABUNDANCE
            IF(LREL) XNEWCP = DEXP(CLN*(XNEWCP-12.0D0))*HCOMP(1,M)
            IF(XNEWCP.LT.1.0D0) THEN
               DO 35 I = 1,M
                  HCOMP(INEWCP,I) = XNEWCP
   35          CONTINUE
            ELSE
C  ERROR - RESCALED ABUNDANCE >100% - ABUNDANCE NOT CHANGED
C               ACOMP = ANEWCP
               WRITE(ISHORT,1004)ICOMP,NK,XNEWCP
 1004       FORMAT(1X,'ERROR IN SUBROUTINE RSCALE'/1X,'RESCALING OF ',
     *      'SPECIES ',I3,' IN KIND CARD # ',I3,' FAILED - DESIRED COMP',F9.6/1X,
     *      'GREATER THAN UNITY.  Z NOT RESCALED')
            ENDIF
         ENDIF
C  RESCALE STAR MASS BY MULTIPLYING ALL MASS POINTS IN THE STAR BY
C  A SCALE FACTOR(MNEW/MOLD) WHILE LEAVING ALL OTHER LOCAL VARIABLES
C  UNCHANGED.
         IF(RESCAL(1,NK).GT.0.0D0) THEN
            HSTOT1 = DLOG10(RESCAL(1,NK)/SMASS)
            HSTOT = HSTOT + HSTOT1
            SMASS = RESCAL(1,NK)
            STOTAL = HSTOT
            DO 40 I = 1,M
               HS(I) = HS(I) + HSTOT1
   40       CONTINUE
         ENDIF
      ELSE
C  HORIZONTAL BRANCH RESCALING;CORE MASS AND TOTAL MASS.
C  FOR TOTAL MASS,TREAT AS MAIN SEQUENCE BUT ONLY CHANGE
C  THE MASS POINTS OUTSIDE THE H-BURNING SHELL;
C  FOR CORE MASS CHANGE THE POINTS INSIDE THE H-BURNING
C  SHELL AND CORRESPONDINGLY REDUCE/INCREASE THE MASS OUTSIDE
C  THE SHELL.
c ************
c      write(*,*)'Entering HB scale ',HSTOT-HS(M)
c ************


         IF(RESCAL(1,NK).GT.0.0D0.OR.RESCAL(4,NK).GT.0.0D0) THEN
C  RESCALE MASS AND/OR CORE MASS
C  FIND H-BURNING SHELL.
C

C ************* Added call to FINDSHELL (gn - 10/05)**************

            CALL FINDSH(HCOMP,HL,LC,M,JCORE,JENV,JXBEG,JXEND,JXMID,
     *                  LSHELL)
C ****************************************************************

C FIND CORE, ENVELOPE, AND H-BURNING SHELL MASSES.
            COROLD = EXP(CLN*HS(JXBEG-1))/CMSUN
            ENVOLD = (EXP(CLN*HSTOT)-EXP(CLN*HS(JXEND)))/CMSUN
            ENVOLD2 = (EXP(CLN*HS(M))-EXP(CLN*HS(JXEND)))/CMSUN
            SHLOLD = (EXP(CLN*HS(JXEND))-EXP(CLN*HS(JXBEG-1)))/CMSUN
            DENV = 0.0D0
            DCOR = 0.0D0
            WRITE(ISHORT,63)COROLD,SHLOLD,ENVOLD,SMASS
   63       FORMAT(1X,'HB-OLD MASSES: CORE ',
     *      F9.6,' SHELL ',F9.6,' ENV ',F9.6,' TOTAL',F9.6)
         ENDIF

         IF(RESCAL(1,NK).GT.0.0D0) THEN

C MASS RESCALING : ADD OR SUBTRACT MASS FROM THE ENVELOPE OUTSIDE
C THE H-BURNING SHELL (ONLY).
C
C ENSURE THAT THE NEW ENVELOPE MASS IS POSITIVE.


            DENV = RESCAL(1,NK) - SMASS
            ENVNEW = ENVOLD + DENV

c ** Reduce either total mass outside core OR the standard envelope only ***
            IF((((10D0**HSTOT)/CMSUN)-COROLD).GE.0.01D0) THEN
c ************
      write(*,*)'Entering old method ',(10**HSTOT-10**HS(M))/
     *                                 (10**HS(M)-10**HS(JXBEG-1))
      write(*,*)'SENV ',10**HSTOT - 10**HS(M)
      write(*,*)'Envelope ',10**HS(M) - 10**HS(JXBEG-1)
c ************

c **************************************************************************
c               write(*,*)JXBEG-1,JXMID,JXEND,M
            IF(ENVNEW.LE.0.0D0)THEN
               WRITE(ISHORT,69)ENVOLD,ENVOLD+DENV,RESCAL(1,NK),SMASS
   69          FORMAT(1X,'ERROR IN SUBROUTINE RSCALE'/1X,
     *         'DESIRED NEW ENVELOPE MASS LESS THAN ZERO'/1X,
     *         'OLD ENVELOPE MASS ',1PE9.2,' NEW ENVELOPE ',E9.2,
     *         ' NEW AND OLD TOTAL MASS ',2E10.2)
               STOP
            ENDIF

c ***** Calculate scale factor for mass rescaling *****

c            HSTOT1 = DLOG10(RESCAL(1,NK)/SMASS)
        SFACTOR =(RESCAL(1,NK)-EXP(CLN*HS(JXEND))/CMSUN)/
     *                          (SMASS-EXP(CLN*HS(JXEND))/CMSUN)

c *****************************************************

c            HSTOT = HSTOT + HSTOT1
        HSTOT=DLOG10(10**HS(JXEND)+SFACTOR*(10**HSTOT-10**HS(JXEND)))

            SMASS = RESCAL(1,NK)
            STOTAL = HSTOT
            DO 70 I = JXEND+1,M
        HS(I)=DLOG10(10**HS(JXEND)+SFACTOR*(10**HS(I)-10**HS(JXEND)))
   70       CONTINUE
            ENVOLD = ENVNEW
c *****
c            write(*,*)'Mass difference ',DENV
c            write(*,*)'HSTOT1 ',HSTOT1
c            write(*,*)'SFACTOR ',DLOG10(SFACTOR)
c ************
c      write(*,*)'leaving old method ',HSTOT-HS(M)
c ************

         ELSE

c ************
      write(*,*)'Entering new method ',(10**HSTOT-10**HS(M))/
     *                                 (10**HS(M)-10**HS(JXBEG-1))
      write(*,*)'SENV ',10**HSTOT - 10**HS(M)
      write(*,*)'Envelope ',10**HS(M) - 10**HS(JXBEG-1)
c ************
c           *** print debug info ***
c            write(*,*)JXBEG-1,JXMID,JXEND,M
c            write(*,*)(10**HS(JXBEG-1))/CMSUN,' core'
c            write(*,*)(10**HS(JXMID))/CMSUN,' mid'
c            write(*,*)(10**HS(JXEND))/CMSUN,' end'
c            write(*,*)(10**HS(M))/CMSUN,' M'
c            write(*,*)(10**HSTOT)/CMSUN,' total'
            CHKENV = ((10**HSTOT)/CMSUN)-COROLD
            IF(CHKENV.LE.0.0D0)THEN
               WRITE(ISHORT,69)ENVOLD,ENVOLD+DENV,RESCAL(1,NK),SMASS
               STOP
            ENDIF

c **** Calculate scale factor *****

c           HSTOT1 = DLOG10(RESCAL(1,NK)/SMASS)
        SFACTOR =(RESCAL(1,NK)-EXP(CLN*HS(JXBEG-1))/CMSUN)/
     *                          (SMASS-EXP(CLN*HS(JXBEG-1))/CMSUN)
c        write(*,*)'hstot1',(10**HSTOT1)
c        write(*,*)'smass',SMASS

c            HSTOT = HSTOT + HSTOT1
       HSTOT=DLOG10(10**HS(JXBEG-1)+SFACTOR*(10**HSTOT-10**HS(JXBEG-1)))

            SMASS = RESCAL(1,NK)
            STOTAL = HSTOT
            DO 78 I = JXBEG,M
      HS(I)=DLOG10(10**HS(JXBEG-1)+SFACTOR*(10**HS(I)-10**HS(JXBEG-1)))
 78     CONTINUE
            ENVOLD = (EXP(CLN*HSTOT)-EXP(CLN*HS(JXEND)))/CMSUN
            ENVTOTAL=(EXP(CLN*HS(M))-EXP(CLN*HS(JXBEG-1)))/CMSUN
c            write(*,*)'total envelope ',ENVTOTAL
c            write(*,*)'HSTOT1 ',HSTOT1
c            write(*,*)'SFACTOR ',DLOG10(SFACTOR)

c ************
c      write(*,*)'leaving new method ',HSTOT-HS(M)
c ************

         ENDIF
         ENDIF
c ******************************************************************

         IF(RESCAL(4,NK).GT.0.0D0) THEN

C RESCALE CORE MASS.
C THE MASS OF THE H-BURNING SHELL IS HELD FIXED, AND MASS IS TRANSFERRED
C FROM THE CORE TO THE ENVELOPE (OR VICE VERSA).
C

            SHLP= (EXP(CLN*HS(JXEND)))
            DCOR = RESCAL(4,NK) - COROLD
            DENV = - DCOR
            ENVNEW = ENVOLD2 + DENV
            IF(ENVNEW.LE.0.0D0)THEN
               WRITE(ISHORT,71)ENVOLD,ENVNEW,RESCAL(4,NK),COROLD
   71          FORMAT(1X,'ERROR IN SUBROUTINE RSCALE'/1X,
     *         'NEW ENVELOPE MASS LESS THAN ZERO BECAUSE OF CORE',
     *         ' RESCALING'/1X,
     *         'OLD ENVELOPE MASS ',1PE10.2,' NEW ENVELOPE ',E10.2,
     *         ' NEW AND OLD CORE MASS ',2E10.2)
               STOP
            ENDIF
            HSTOT1 = DLOG10(RESCAL(4,NK)/COROLD)
            DO 80 I = 1,JXBEG-1
               HS(I) = HS(I) + HSTOT1
   80       CONTINUE

C  HOLD H-SHELL MASS CONSTANT;SHIFT IS THE CHANGE IN THE
C  UNLOGGED MASS OF EACH POINT IN THE H SHELL.
            SHIFT = DCOR*CMSUN
            DO 90 I = JXBEG,JXEND
               TEMP = EXP(CLN*HS(I))
               HS(I) = LOG10(TEMP + SHIFT)
   90       CONTINUE
C  NOW SHRINK OR EXPAND THE ENVELOPE MASS TO RETAIN TOTAL CONSTANT MASS.
C

        SFACTOR =(EXP(CLN*HS(M))-EXP(CLN*HS(JXEND)))/
     *                          (EXP(CLN*HS(M))-SHLP)

            DO 100 I = JXEND+1,M
        HS(I)=DLOG10(10**HS(M)-SFACTOR*(10**HS(M)-10**HS(I)))
  100       CONTINUE

         ENDIF

         IF(RESCAL(1,NK).GT.0.0D0.OR.RESCAL(4,NK).GT.0.0D0)THEN
            CORNEW = EXP(CLN*HS(JXBEG-1))/CMSUN
            ENVNEW = (EXP(CLN*HSTOT)-EXP(CLN*HS(JXEND)))/CMSUN
            SHLNEW = (EXP(CLN*HS(JXEND))-EXP(CLN*HS(JXBEG-1)))/CMSUN
            WRITE(ISHORT,101)CORNEW,SHLNEW,ENVNEW,SMASS
  101       FORMAT(1X,'HB-RESCALED MASSES: CORE ',
     *      F9.6,' SHELL ',F9.6,' ENV ',F9.6,' TOTAL ',F9.6)

         ENDIF
      ENDIF
C  CHANGE Y TO REFLECT NEW X,Z, AND HE3 VALUES.
      DO 110 I = 1,M
         HCOMP(2,I) = 1.0D0-HCOMP(1,I)-HCOMP(3,I)-HCOMP(4,I)
  110 CONTINUE
C
C DBG 5/94 rescale interior Z if LZRAMP flag is T.
C Z is linearly adjusted from RSCLZC at the center to surface Z at
C mass fraction RSCLZM.  Compensate changing Z with X.
      IF(LZRAMP.AND.(RSCLZC(NK).GT.0D0).AND.(RSCLZM1(NK).GT.0D0)
     *     .AND.(RSCLZM2(NK).GT.0D0))THEN
            SLOPE = (ZNEW - RSCLZC(NK))/(RSCLZM2(NK)-RSCLZM1(NK))
            DO I = 1,M
               FS = 10.0D0**HS(I)/(SMASS*CMSUN)
               IF (FS .LT. RSCLZM1(NK)) THEN
                  ZFACT = (HCOMP(3,I)-RSCLZC(NK))/HCOMP(3,I)
                  HCOMP(3,I) = RSCLZC(NK)
                  HCOMP(1, I) = 1.0D0-HCOMP(3,I)-HCOMP(4,I)-HCOMP(2,I)
                  DO J = 5,11
                      HCOMP(J,I) = HCOMP(J,I)*ZFACT
                  ENDDO
               ELSE IF (FS .LT. RSCLZM2(NK)) THEN
                  ZP = (FS-RSCLZM1(NK))*SLOPE+RSCLZC(NK)
                  ZFACT = (HCOMP(3,I)-ZP)/HCOMP(3,I)
                  HCOMP(3, I) = ZP
                  HCOMP(1, I) = 1.0D0-HCOMP(3,I)-HCOMP(4,I)-HCOMP(2,I)
                  DO J = 5,11
                      HCOMP(J,I) = HCOMP(J,I)*ZFACT
                  ENDDO
               END IF
            ENDDO
      END IF
c ************
c      write(*,*)'Leaving rscale ',HSTOT-HS(M)
c ************
c      IF(HSTOT.LT.HS(M)) STOP
      RETURN
      END
