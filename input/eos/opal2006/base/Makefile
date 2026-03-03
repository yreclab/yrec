# EOS table generator Makefile
#
# Usage:
# Several build targets are supported.
#   release : The default target, maximum performance, warning and optimization flags only
#   debug   : Default flags + debug flags, address sanitizer enabled
#
# Several compilers are supported.
#   gfortran : GNU Fortran compiler, the default
#   ifort    : legacy Intel Fortran compiler
#   ifx      : newer Intel compiler may also be used by defining FC=<compiler> on
# the command line when invoking make.
#
#  make [FC=<compiler>] <target>
#
# Examples:
# gfortran, optimized release build:
#    make
# gfortran, debug build
#    make debug
# ifort, debug build:
#    make FC=ifort debug
# ifx, release build:
#    make FC=ifx
#
# To remove executable and all intermediate object files:
#    make clean

# The name for the executable
NAME = ZFS_interp_EOS5_2025

# The default path into which the 'install' target will try to copy the executable.
PREFIX ?= /usr/local/bin

# Compose list of all object files to produce.
OBJS := $(NAME).o

# Flags for GNU Fortran (gfortran)
GNU_BASE_FFLAGS = -ffixed-line-length-132 -Wall
GNU_DBG_FFLAGS = -g -fsanitize=undefined -fsanitize=address -fstack-protector-strong -O0
GNU_REL_FFLAGS = -O3

# Flags for Intel Fortran (ifort)
IFORT_BASE_FFLAGS = -132 -traceback -warn all -nogen-interfaces
IFORT_DBG_FFLAGS = -g
IFORT_REL_FFLAGS = -O3

# Flags for newer Intel Fortran compiler (ifx)
IFX_BASE_FFLAGS = -132 -traceback -warn all -nogen-interfaces
IFX_DBG_FFLAGS = -g
IFX_REL_FFLAGS = -O3

# Assign flags for the requested compiler
ifeq ("$(FC)", "ifort")
	FFLAGS = $(IFORT_BASE_FFLAGS)
	DBG_FFLAGS = $(IFORT_DBG_FFLAGS)
	REL_FFLAGS = $(IFORT_REL_FFLAGS)
else ifeq ("$(FC)", "ifx")
	FFLAGS = $(IFX_BASE_FFLAGS)
	DBG_FFLAGS = $(IFX_DBG_FFLAGS)
	REL_FFLAGS = $(IFX_REL_FFLAGS)
else
	FC = gfortran
	FFLAGS = $(GNU_BASE_FFLAGS)

	DBG_FFLAGS = $(GNU_DBG_FFLAGS)
	DBG_LDFLAGS = $(GNU_DBG_FFLAGS)

	REL_FFLAGS = $(GNU_REL_FFLAGS)
endif

# Targets
all: FFLAGS += $(REL_FFLAGS)
all: $(NAME)

debug: FFLAGS += $(DEV_FFLAGS) $(DBG_FFLAGS)
debug: LDFLAGS += $(DBG_LDFLAGS)
debug: $(NAME)

release: FFLAGS += $(REL_FFLAGS)
release: $(NAME)

$(NAME): $(OBJS)
	$(FC) $(LDFLAGS) -o $(NAME) $(OBJS)

# Remove all object files and executable
clean:
	@rm -f $(NAME)
	@rm -f $(OBJS)

install:
	install -d $(PREFIX)
	install -m 755 $(NAME) $(PREFIX)

## The name for the executable can be changed after the NAME =
#
#NAME = ZFS_interp_EOS5
#
#FFILES = \
#ZFS_interp_EOS5.f
#
## This part specifies the compiler options, and can be used to move 
## the executable to a target location by uncommenting the mv and 
## specifying a target for the move.
#
#FFLAGS =  -c -O3 -w -132 
#
#SRSFILES = $(FFILES)
#
#OBJFILES = $(FFILES:.f=.o)
#
#$(NAME):	$(OBJFILES)
#	ifort -g -o $(NAME) *.o
##	mv $(NAME) target
#.f.o:
#	ifort $(FFLAGS)  -g $*.f
