
# The name for the executable can be changed after the NAME =

NAME = yrec

FFILES = \
alex06tab.f		alfilein.f		alprint.f \
alsurfp.f		altabinit.f		alx8th.f \
alxtbl.f		alxztab.f		amcalc.f \
bandw.f			blkdta000.f		boole.f \
bsrotmix.f		bsstep.f		bursmix.f \
calcad.f		cases.f			ccoeft.f \
checkc.f		checkj.f		chkcal.f \
chkscal.f		choose.f		codiff.f \
coefft.f		condopacp.f		condopacpint.f \
convec.f		cowind.f		crrect.f \
cspline.f		ctridi.f		dadcoeft.f \
dburn.f			dburnm.f		dcoeft.f \
deutrate.f		engeb.f			entime.f \
envint.f		eq2mod.f		eqbound.f \
eqbound01.f		eqbound06.f		eqburn.f \
eqrelv.f		eqsaha.f		eqscve.f \
eqscvg.f		eqstat.f		eqstat2.f \
equal_to_model.f	esac.f			esac01.f \
esac06.f		findex.f		findsh.f \
fpft.f			func.f			get_imp_diffco.f \
getalex06.f		getfc.f			getgrid.f \
getmodel2.f		getnewenv.f		getopac.f \
getopal95.f		getqua.f		getrot.f \
gettau.f		getw.f			getyrec7.f \
gmass.f			gmass01.f		gmass06.f \
grsett.f		gtlaol.f		gtlaol2.f \
gtpurz.f		hpoint.f		hra.f \
hsolve.f		hsubp.f			htimer.f \
ifermi12.f		inter3.f		interp.f \
intmom.f		intpol.f		intpt.f \
intrp2.f		kcsurfp.f		kemcom.f \
kspline.f		ksplint.f		kurucz.f \
kurucz2.f		lax_wendrof1.f		lax_wendrof2.f \
liburn.f		liburn2.f		lir.f \
lirate88.f		ll4th.f			ll95tbl.f \
locate.f		lubksb.f		ludcmp.f \
main.f			massloss.f		mcowind.f \
mdot.f			meqos.f			meval.f \
mhdpx.f			mhdpx1.f		mhdpx2.f \
mhdst.f			mhdst1.f		mhdtbl.f \
microdiff.f		microdiff_cod.f		microdiff_etm.f \
microdiff_mte.f		microdiff_run.f		microdiff_setup.f \
midmod.f		mix.f			mixcom.f \
mixcz.f			mixgrid.f		mmid.f \
model_to_equal.f	momi.f			mu.f \
mwind.f			ndifcom.f		neutrino.f \
nulosses.f		oeqos.f			oeqos01.f \
oeqos06.f		op952d.f		op953d.f \
op954d.f		op95xtab.f		op95ztab.f \
osplin.f		oversh.f		ovrot.f \
parmin.f		pdist.f			physic.f \
pindex.f		polint.f		ptime.f \
putmodel2.f		putstore.f		putyrec7.f \
qatm.f			qenv.f			qgauss.f \
quad.f			quadeos01.f		quadeos06.f \
quint.f			rabu.f			radsub.f \
radsub01.f		radsub06.f		rates.f \
ratext.f		rdlaol.f		rdzlaol.f \
readalex06.f		readco.f		readcoeos01.f \
readcoeos06.f		reduce.f		remap.f \
rhoofp.f		rhoofp01.f		rhoofp06.f \
rotgrid.f		rotmix.f		rscale.f \
rtab.f			sconvec.f		search.f \
seculr.f		setcal.f		setkrz.f \
setllo.f		setscal.f		setscv.f \
setup_grsett.f		setupopac.f		setups.f \
setupv.f		shape.f			simeqc.f \
slopes.f		sneut.f			solid.f \
splinc.f		spline.f		splinj.f \
splinnr.f		splint.f		splintd2.f \
splnr.f			starin.f		stitch.f \
sulaol.f		surfbc.f		surfopac.f \
surfp.f			t6rinteos01.f		t6rinteos06.f \
t6rinterp.f		taucal.f		tauint.f \
tauintnew.f		thdiff.f		tpgrad.f \
trapzd.f		tridia.f		tridiag_gs.f \
vcirc.f			viscos.f		wcz.f \
wind.f			wrthead.f		wrtlst.f \
wrtmil.f		wrtmod.f		wrtmonte.f \
wrtout.f		wtime.f			xrng4.f \
xtime.f			yalo3d.f		ykoeff.f \
yllo2d.f		yllo2d2.f		yllo3d.f \
yllo3d2.f		ylloc.f			ysplin.f \
ytime.f			zero.f			zfermim12.f \
zsulaol.f

# This part specifies the compiler options, and can be used to move 
# the executable to a target location by uncommenting the mv and 
# specifying a target for the move.

FFLAGS =  -ffixed-line-length-132 -w -O3 

SRSFILES = $(FFILES)

OBJFILES = $(FFILES:.f=.o)

#$(NAME):	$(OBJFILES)
$(NAME):       $(SRSFILES)
	gfortran $(FFLAGS) -o $(NAME) *.f 
#	mv $(NAME) target
#.f.o:
#	gfortran $(FFLAGS) -o $*.f 

clean:
	rm -f $(NAME) *.o *.mod
	
PREFIX ?= /usr/local/bin

# Install the executable to a target directory (default /usr/local/bin)
install:
	install -d $(PREFIX)
	install -m 755 $(NAME) $(PREFIX)
