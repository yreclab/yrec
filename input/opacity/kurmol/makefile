NAME = kaprossinterp

FFILES = \
kaprossinterp.f

# FFLAGS = -align commons -c -C -g

FFLAGS = -align commons -c -O

SRSFILES = $(FFILES)

OBJFILES = $(FFILES:.f=.o)

$(NAME):	$(OBJFILES)
	f77 -g -o $(NAME) *.o

.f.o:
	f77 $(FFLAGS) $*.f

