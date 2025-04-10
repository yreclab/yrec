NAME = opacities

FFILES = \
main.f tprdid.f combine.f wrtgrid.f interp.f spline.f splint.f \
wrttab.f ffeta.f wrtvand.f locate.f

# FFLAGS = -align commons -c -C -g

FFLAGS = -align commons -c -O

SRSFILES = $(FFILES)

OBJFILES = $(FFILES:.f=.o)

$(NAME):	$(OBJFILES)
	f77 -g -o $(NAME) *.o

.f.o:
	f77 $(FFLAGS) $*.f

