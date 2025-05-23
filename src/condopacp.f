** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*  This subroutine interpolates the electron thermal conductivity       *
*               from the data file "condall.d"                          *
*  ---------------------------------------------------  Version 23.05.99
      subroutine CondOpacP(Zion,TLG,RLG,CK,DRK,DTK)
* Input: Zion - ion charge, TLG - lg(T[K]), RLG - lg(rho[g/cc])
* Output: CK - Log_{10} thermal conductivity (kappa) [CGS units]
*         DRK - d log kappa / d log rho
*         DTK - d log kappa / d log T
***      (it is also possible to obtain all second derivatives)      ***

C     This Subroutine interpolates thermal conductivity from 
C     a precalculated table condall.d available at 
C     http://www.ioffe.rssi.ru/astro/conduct
C     For theoretical base of this calculation, see
C      A.Y.Potekhin, D.A.Baiko, P.Haensel, D.G.Yakovlev, 1999
C                  Astron. Astrophys. 346, 345.      
C     Extension from strongly- to weakly-degenerate regime
C     has been done using the thermal averaging - for example
C         A.Y.Potekhin, 1999, Astron. Astrophys. 351, 787.  
C     Please quote these publication when using this program
C     SOURCE DATA FILE 'condall.d' MUST BE IN YOUR
C      CURRENT DIRECTORY
C     Please address any questions/comments to Alexander Potekhin:
C     e-mail: palex@astro.ioffe.rssi.ru

      implicit double precision (A-H), double precision (O-Z)
      save
      parameter (MAXT=19,MAXR=64,MAXZ=15)
!!! NB: These parameters must be consistent with the table "condall.d"!!!
      dimension AT(MAXT),AR(MAXR),AZ(MAXZ),AKAP(MAXT,MAXR,MAXZ)
      data KRUN/-1/

C The following three lines provide and interface to PARMIN in order to 
C locate the Potekhin files.
      COMMON /MISCOPAC/IKUR2,FKUR2,IcondOpacP,FcondOpacp,LcondOpacP
      LOGICAL*4 LcondOpacP
      CHARACTER*256 FKUR2,FcondOpacP
	if (KRUN.ne.12345) then ! Reading
         IP = IcondOpacP
         open(IP,file=FcondOpacP,status='OLD')
c         print*,'Reading thermal conductivity data...'
         read(IP,'(A)') ! skip the first line
        do IZ=1,MAXZ
           read(IP,*) Z,(AT(IT),IT=1,MAXT)
           AZ(IZ)=dlog10(Z)
          do IR=1,MAXR
             read(IP,*) AR(IR),(AKAP(IT,IR,IZ),IT=1,MAXT)
          enddo
	enddo
         close(IP)
         KRUN=12345
         IZ=MAXZ/2+1
         IT=MAXT/2+1
         IR=MAXR/2+1
c         print*,'Potekhin Conductivity File read in.'
      endif
      ZLG=dlog10(Zion)
      call HUNT(AZ,MAXZ,ZLG,IZ)
      if (IZ.eq.0.or.IZ.eq.MAXZ) stop'CONINTER: Z out of range'
      call HUNT(AT,MAXT,TLG,IT)

C      if (IT.eq.0.or.IT.eq.MAXT) stop'CONINTER: T out of range'
	if (IT.eq.0.or.IT.eq.MAXT) then 
			print*, AZ
			print*, MAXZ, TLG, IZ
			stop'CONINTER: T out of range'
	endif

      call HUNT(AR,MAXR,RLG,IR)
      if (IR.eq.0.or.IR.eq.MAXR) stop'CONINTER: rho out of range'
      ITM=max0(1,IT-1)
      ITP=min0(MAXT,IT+2)
      IRM=max0(1,IR-1)
      IRP=min0(MAXR,IR+2)
* Cubic interpolation in RLG:
* Z0:
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(ITM,IRM,IZ),AKAP(ITM,IR,IZ),
     *   AKAP(ITM,IR+1,IZ),AKAP(ITM,IRP,IZ),
     *   CKTMZ0,DRKTMZ0,DR2KTMZ0,XR)
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(IT,IRM,IZ),AKAP(IT,IR,IZ),
     *   AKAP(IT,IR+1,IZ),AKAP(IT,IRP,IZ),
     *   CKT0Z0,DRKT0Z0,DR2KT0Z0,XR)
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(IT+1,IRM,IZ),AKAP(IT+1,IR,IZ),
     *   AKAP(IT+1,IR+1,IZ),AKAP(IT+1,IRP,IZ),
     *   CKT1Z0,DRKT1Z0,DR2KT1Z0,XR)
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(ITP,IRM,IZ),AKAP(ITP,IR,IZ),
     *   AKAP(ITP,IR+1,IZ),AKAP(ITP,IRP,IZ),
     *   CKTPZ0,DRKTPZ0,DR2KTPZ0,XR)
* Z1:
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(ITM,IRM,IZ+1),AKAP(ITM,IR,IZ+1),
     *   AKAP(ITM,IR+1,IZ+1),AKAP(ITM,IRP,IZ+1),
     *   CKTMZ1,DRKTMZ1,DR2KTMZ1,XR)
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(IT,IRM,IZ+1),AKAP(IT,IR,IZ+1),
     *   AKAP(IT,IR+1,IZ+1),AKAP(IT,IRP,IZ+1),
     *   CKT0Z1,DRKT0Z1,DR2KT0Z1,XR)
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(IT+1,IRM,IZ+1),AKAP(IT+1,IR,IZ+1),
     *   AKAP(IT+1,IR+1,IZ+1),AKAP(IT+1,IRP,IZ+1),
     *   CKT1Z1,DRKT1Z1,DR2KT1Z1,XR)
      call CINTERP3(AR(IRM),AR(IR),AR(IR+1),AR(IRP),RLG,IR,MAXR,
     *   AKAP(ITP,IRM,IZ+1),AKAP(ITP,IR,IZ+1),
     *   AKAP(ITP,IR+1,IZ+1),AKAP(ITP,IRP,IZ+1),
     *   CKTPZ1,DRKTPZ1,DR2KTPZ1,XR)
* Linear interpolation in ZLG:
      XZ1=(ZLG-AZ(IZ))/(AZ(IZ+1)-AZ(IZ))
      XZ0=1D0-XZ1
      CKTM=XZ0*CKTMZ0+XZ1*CKTMZ1
      DRKTM=XZ0*DRKTMZ0+XZ1*DRKTMZ1
      DR2KTM=XZ0*DR2KTMZ0+XZ1*DR2KTMZ1
      CKT0=XZ0*CKT0Z0+XZ1*CKT0Z1
      DRKT0=XZ0*DRKT0Z0+XZ1*DRKT0Z1
      DR2KT0=XZ0*DR2KT0Z0+XZ1*DR2KT0Z1
      CKT1=XZ0*CKT1Z0+XZ1*CKT1Z1
      DRKT1=XZ0*DRKT1Z0+XZ1*DRKT1Z1
      DR2KT1=XZ0*DR2KT1Z0+XZ1*DR2KT1Z1
      CKTP=XZ0*CKTPZ0+XZ1*CKTPZ1
      DRKTP=XZ0*DRKTPZ0+XZ1*DRKTPZ1
      DR2KTP=XZ0*DR2KTPZ0+XZ1*DR2KTPZ1
* Cubic interpolation in TLG:
      call CINTERP3(AT(ITM),AT(IT),AT(IT+1),AT(ITP),TLG,IT,MAXT,
     *   CKTM,CKT0,CKT1,CKTP, ! input: values of lg kappa
     *   CK,DTK,DT2K,XT) ! lg kappa, d lg k / d lg T, d2 lg k / d2 lg T
      call CINTERP3(AT(ITM),AT(IT),AT(IT+1),AT(ITP),TLG,IT,MAXT,
     *   DRKTM,DRKT0,DRKT1,DRKTP, ! input: values of d lg k / d lg rho
     *   DRK,DRTK,DRT2K,XT) ! d lg k / d lg rho, d2 lgk/(d lgT d lg rho)
      return
      end

      subroutine CINTERP3(ZM,Z0,Z1,ZP,Z,N0,MXNV,VM,V0,V1,VP,
     &   VF,DF,D2,XH)
* Given 4 values of Z and 4 values of V, find VF corresponding to 5th Z
*                                                       Version 23.05.99
*   Output: VF - interpolated value of function
*           DF - interpolated derivative
*           D2 - interpolated second derivative
*           XH - fraction of the path from N0 to N0+1
      implicit double precision (A-H), double precision (O-Z)
      if (N0.le.0.or.N0.ge.MXNV) stop'CINTERP: N0 out of range'
      X=Z-Z0
      H=Z1-Z0   ! basic interval
      XH=X/H
      if (N0.gt.1) then
         HM=Z0-ZM  ! left adjoint interval
         V01=((V1-V0)/H**2+(V0-VM)/HM**2)/
     /   (1D0/H+1D0/HM) ! left derivative
      endif
      if (N0.lt.MXNV-1) then
         HP=ZP-Z1 ! right adjoint interval
         V11=((V1-V0)/H**2+(VP-V1)/HP**2)/
     /   (1D0/H+1D0/HP) ! right derivative
      endif
      if (N0.gt.1.and.N0.lt.MXNV-1) then   ! Cubic interpolation
         C2=3D0*(V1-V0)-H*(V11+2D0*V01)
         C3=H*(V01+V11)-2D0*(V1-V0)
         VF=V0+V01*X+C2*XH**2+C3*XH**3
         DF=V01+(2D0*C2*XH+3D0*C3*XH**2)/H
         D2=(2D0*C2+6D0*C3*XH)/H**2
         goto 10
      endif
      if (N0.eq.1) then   ! Quadratic interpolation
         C2=V0-V1+V11*H
         VF=V1-V11*(H-X)+C2*(1D0-XH)**2
         DF=V11-2D0*C2*(1D0-XH)/H
         D2=2D0*C2/H**2
      else  ! N0=MXNV-1
         C2=V1-V0-V01*H
         VF=V0+V01*X+C2*XH**2
         DF=V01+2D0*C2*XH/H
         D2=2D0*C2/H**2
      endif
   10 return
      end

      subroutine HUNT(XX,N,X,JLO)
*   W.H.Press, B.P.Flannery, S.A.Teukolsky, W.T.Vetterling
*   Numerical Receipes(Cambridge Univ., 1986)
*     Given an array XX of length N, and given a value X,
*     returns a value JLO such that X is between XX(JLO) and XX(JLO+1).
*     XX must be monotonic, either increasing or decreasing. 
*     JLO=0 or JLO=N is returned to indicate that X is out of range.
*     JLO on input is taken as the initial guess for JLO on output.
      implicit double precision (A-H), double precision (O-Z)
      dimension XX(*)
      logical ASCND
      ASCND=XX(N).gt.XX(1) ! true if ascending order, false otherwise
      if (JLO.le.0.or.JLO.gt.N) then ! Input guess not useful.
         JLO=0
         JHI=N+1
         goto 3 ! go immediately to bisection
      endif
      INC=1 ! set the hunting increment
      if (X.ge.XX(JLO).eqv.ASCND) then ! Hunt up:
    1     JHI=JLO+INC
        if (JHI.gt.N) then ! Done hunting, since off end of table
           JHI=N+1
        elseif (X.ge.XX(JHI).eqv.ASCND) then ! Not done hunting
           JLO=JHI
           INC=INC+INC
           goto 1
        endif
      else ! Hunt down:
         JHI=JLO
    2    JLO=JHI-INC
        if (JLO.lt.1) then ! Done hunting, since off end of table
           JLO=0
        elseif (X.lt.XX(JLO).eqv.ASCND) then ! Not done hunting
           JHI=JLO
           INC=INC+INC ! so double the increment
           goto 2      ! and try again
        endif ! Done hunting, value bracketed
      endif
*   Hunt is done, so begin the final bisection phase:
    3 if (JHI-JLO.eq.1) return
      JM=(JHI+JLO)/2
      if (X.ge.XX(JM).eqv.ASCND) then
         JLO=JM
      else
         JHI=JM
      endif
      goto 3
      end
