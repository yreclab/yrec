# YREC Makefile
#
# Usage:
# gfortran default compiler, standard development flags:
#    make
# gfortran default compiler, debug flags:
#    make debug
# gfortran default compiler, release flags (optimization):
#    make release
#
# To specify the other supported compiler, ifort, set FC on command line.
# ifort, standard development flags:
#    make FC=ifort
# ifort, debug flags:
#    make FC=ifort debug
# ifort, release flags (optimization):
#    make FC=ifort release
#
# To remove executable and all intermediate object files:
#    make clean


# The name for the executable
NAME = yrec

# The default path into which the install target will try to copy the executable.
PREFIX ?= /usr/local/bin

# Compose list of all object files to produce.
OBJS := $(patsubst %.f,%.o,$(wildcard *.f))

# Set flags for GNU Fortran (gfortran)
# The default compiler if FC is not specified on the command line.
GNU_BASE_FFLAGS = -ffixed-line-length-132 -Wall
GNU_DEV_FFLAGS = -fcheck=all -ffpe-trap=invalid,zero,overflow
GNU_DBG_FFLAGS = -g
GNU_REL_FFLAGS = -O3

# Set flags for Intel Fortran (ifort)
# Enable compile-time warnings and floating point exception reporting at runtime.
INTEL_BASE_FFLAGS = -132 -traceback -warn all -nogen-interfaces
INTEL_DEV_FFLAGS = -check all -fpe:0
INTEL_DBG_FFLAGS = -g
INTEL_REL_FFLAGS = -O3

ifeq ("$(FC)", "ifort")
	FFLAGS = $(INTEL_BASE_FFLAGS)
	DEV_FFLAGS = $(INTEL_DEV_FFLAGS)
	DBG_FFLAGS = $(INTEL_DBG_FFLAGS)
	REL_FFLAGS = $(INTEL_REL_FFLAGS)
else
	FC = gfortran
	FFLAGS = $(GNU_BASE_FFLAGS)
	DEV_FFLAGS = $(GNU_DEV_FFLAGS)
	DBG_FFLAGS = $(GNU_DBG_FFLAGS)
	REL_FFLAGS = $(GNU_REL_FFLAGS)
endif

# Targets
all: FFLAGS += $(DEV_FFLAGS)
all: $(NAME)

debug: FFLAGS += $(DEV_FFLAGS) $(DBG_FFLAGS)
debug: $(NAME)

release: FFLAGS += $(REL_FFLAGS)
release: $(NAME)

$(NAME): $(OBJS)
	@$(FC) -o $(NAME) $(OBJS)

# Remove all object files and executable
clean:
	@rm -f $(NAME)
	@rm -f $(OBJS)

install:
	install -d $(PREFIX)
	install -m 755 $(NAME) $(PREFIX)
