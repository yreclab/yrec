# YREC Makefile
#
# Usage:
# Several build targets are supported.
#   release : The default target, maximum performance, warning and optimization flags only
#   devel   : standard development flags, display all warnings, trap exceptions
#   debug   : Default flags + debug flags, address sanitizer enabled
#   prof    : Allows use of gprof profiling tool + devel flags + optimization
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
# gfortran, profiling build
#    make prof
# ifort, development build:
#    make FC=ifort devel
# ifx, release build:
#    make FC=ifx
#
# To remove executable and all intermediate object files:
#    make clean

# The name for the executable
NAME = yrec

# The default path into which the 'install' target will try to copy the executable.
PREFIX ?= /usr/local/bin

# Compose list of all object files to produce.
#
# Module sources are named *_mod.f by convention and are held in a separate
# list, because a module must be compiled before anything that USEs it. The
# wildcard above yields alphabetical order, which is not that order, and the
# failure is immediate: "Fatal Error: Can't open module file 'x_mod.mod' for
# reading". MODOBJS is empty until the first module lands, which makes this
# a no-op for the current source tree.
MODOBJS := $(patsubst %.f,%.o,$(wildcard *_mod.f))

# Everything else. filter-out keeps the module objects from appearing twice.
OBJS := $(filter-out $(MODOBJS),$(patsubst %.f,%.o,$(wildcard *.f)))

# The module-before-object ordering rule lives further down, with the other
# targets. It must not appear above them: the first target in the file
# becomes make's default goal, so putting it here made a bare 'make' build
# one object file (chkscal.o) instead of the executable.

# Where .mod files are written and searched for. This is the build directory
# in every case, which is already each compiler's default; it is stated
# explicitly so that an out-of-tree build does not scatter them, and so the
# three compilers are visibly doing the same thing. gfortran spells it -J,
# ifort and ifx spell it -module.
GNU_MODFLAGS = -J.
INTEL_MODFLAGS = -module .

# Flags for GNU Fortran (gfortran)
GNU_BASE_FFLAGS = -ffixed-line-length-132 -Wall -cpp $(GNU_MODFLAGS) -DGIT_HASH="'$(REPO_HASH)'"
GNU_DEV_FFLAGS = -fcheck=all -ffpe-trap=invalid,zero,overflow
GNU_DBG_FFLAGS = -g -fsanitize=undefined -fsanitize=address -fstack-protector-strong -O0
GNU_PROF_FFLAGS = -O3 -g -pg
GNU_REL_FFLAGS = -O3

# Flags for Intel Fortran (ifort)
IFORT_BASE_FFLAGS = -132 -traceback -warn all -nogen-interfaces -fpp $(INTEL_MODFLAGS) -DGIT_HASH="'$(REPO_HASH)'"
IFORT_DEV_FFLAGS = -check all -fpe:0
IFORT_DBG_FFLAGS = -g
IFORT_REL_FFLAGS = -O3

# Flags for newer Intel Fortran compiler (ifx)
IFX_BASE_FFLAGS = -132 -traceback -warn all -nogen-interfaces -fpp $(INTEL_MODFLAGS) -DGIT_HASH="'$(REPO_HASH)'"
IFX_DEV_FFLAGS = -check all -fpe:0
IFX_DBG_FFLAGS = -g
IFX_REL_FFLAGS = -O3

# Assign flags for the requested compiler
ifeq ("$(FC)", "ifort")
	FFLAGS = $(IFORT_BASE_FFLAGS)
	DEV_FFLAGS = $(IFORT_DEV_FFLAGS)
	DBG_FFLAGS = $(IFORT_DBG_FFLAGS)
	REL_FFLAGS = $(IFORT_REL_FFLAGS)
else ifeq ("$(FC)", "ifx")
	FFLAGS = $(IFX_BASE_FFLAGS)
	DEV_FFLAGS = $(IFX_DEV_FFLAGS)
	DBG_FFLAGS = $(IFX_DBG_FFLAGS)
	REL_FFLAGS = $(IFX_REL_FFLAGS)
else
	FC = gfortran
	FFLAGS = $(GNU_BASE_FFLAGS)
	DEV_FFLAGS = $(GNU_DEV_FFLAGS)

	DBG_FFLAGS = $(GNU_DBG_FFLAGS)
	DBG_LDFLAGS = $(GNU_DBG_FFLAGS)

	PROF_FFLAGS = $(GNU_PROF_FFLAGS)
	PROF_LDFLAGS = $(GNU_PROF_FFLAGS)

	REL_FFLAGS = $(GNU_REL_FFLAGS)
endif

# Test for presence of git command for version hash collection.
GIT_AVAIL := $(shell command -v git)
ifdef GIT_AVAIL
REPO_DIRTY := $(shell command git diff --name-only --quiet .; echo $$?)
SHORT_HASH := $(shell command git rev-parse --short HEAD)
ifeq ($(REPO_DIRTY),1)
  REPO_HASH=$(SHORT_HASH)-dirty
else
  REPO_HASH=$(SHORT_HASH)
endif
else
  REPO_HASH=unknown
endif

# Platform detection for static linking
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	STATIC_FLAGS = -static -static-libgfortran -static-libgcc
endif
ifeq ($(UNAME), Darwin)
	STATIC_FLAGS = -mmacosx-version-min=11.0 -static-libgfortran -static-libquadmath
endif

# Targets
#
# Pinned explicitly so that adding a rule above this point cannot silently
# change what a bare 'make' does.
.DEFAULT_GOAL := default

default: FFLAGS += $(REL_FFLAGS)
default: $(NAME)

devel: FFLAGS += $(DEV_FFLAGS)
devel: $(NAME)

debug: FFLAGS += $(DEV_FFLAGS) $(DBG_FFLAGS)
debug: LDFLAGS += $(DBG_LDFLAGS)
debug: $(NAME)

release: FFLAGS += $(REL_FFLAGS)
release: $(NAME)

prof: FFLAGS += $(DEV_FFLAGS) $(PROF_FFLAGS)
prof: LDFLAGS += $(PROF_LDFLAGS)
prof: $(NAME)

static: FFLAGS += $(REL_FFLAGS)
static: LDFLAGS += $(STATIC_FLAGS)
static: $(NAME)

# Build every module before any ordinary object. Stated as a dependency
# rather than as recipe order so that parallel builds (make -j) honour it
# too. This rule carries no recipe, so the built-in %.o: %.f rule still
# supplies one.
#
# It does not order the modules among themselves. That is fine while no
# module USEs another; when one does, generate the dependencies instead
# (makedepf90, or a short script) rather than hand-maintaining an order.
$(OBJS): $(MODOBJS)

$(NAME): $(MODOBJS) $(OBJS)
	$(FC) $(LDFLAGS) -o $(NAME) $(MODOBJS) $(OBJS)

# Remove all object files, module files and the executable.
#
# Deliberately *.o rather than $(OBJS) and $(MODOBJS). Those lists are
# derived from the sources that exist now, so they can never name the
# object of a source that has been deleted -- such an object survives
# every clean and lingers indefinitely. Two were found that way on
# 2026-10-14: rtab.o from the RTAB removal and quad.o from the removal of
# the dead OPAL interpolation helper. Neither was linked, since the link
# line is built from $(OBJS) too, but neither could be cleaned either.
#
# The *.mod removal matters for a different reason: a stale .mod survives
# an edit that should have invalidated it, and a .mod left by a different
# compiler is worse still, since ifort reports it only as "error #7013"
# (module file was generated by an incompatible compiler), which does not
# point at the real cause.
clean:
	@rm -f $(NAME)
	@rm -f *.o
	@rm -f *.mod

install:
	install -d $(PREFIX)
	install -m 755 $(NAME) $(PREFIX)
