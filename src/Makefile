# The name for the executable
NAME = model_052025

PREFIX ?= /usr/local/bin

# Compose list of all object files to produce.
OBJS := $(patsubst %.f,%.o,$(wildcard *.f))

# Set flags for GNU Fortran (gfortran)
# The default compiler if FC is not specified on the command line.
GNU_BASE_FFLAGS = -c -w -ffixed-line-length-132 -Wall
GNU_DEV_FFLAGS = -fcheck=all, -ffpe-trap=invalid,zero,overflow
GNU_DBG_FFLAGS = -g
GNU_REL_FFLAGS = -O3

# Set flags for Intel Fortran (ifort)
# Enable compile-time warnings and floating point exception reporting at runtime.
INTEL_BASE_FFLAGS = -c -w -132 -traceback -warn all -nogen-interfaces
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
# all: default target with flags useful for development enabled
# debug: development flags plus debug flag(s)
# release: optimization enabled, no development of debug flags
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
