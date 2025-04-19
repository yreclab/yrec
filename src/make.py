#!/usr/bin/env python

# This script compiles the code using make.
# Usage: ./make.py <compiler [default: gfortran]>
# KC 2025-04-18

import sys
import glob
import os

if len(sys.argv) > 2:
    print("Usage: ./Makemake.py <compiler>")
    sys.exit(1)
elif len(sys.argv) == 2:
    compiler = sys.argv[1]
    if compiler not in ["gfortran", "ifort", "ifx"]:
        print("Usage: ./Makemake.py <compiler>")
        sys.exit(1)
else:
    compiler = "gfortran"

MakeBeg =\
r'''
# The name for the executable can be changed after the NAME =

NAME = yrec

FFILES = \
'''

MakeEnd =\
r'''# This part specifies the compiler options, and can be used to move 
# the executable to a target location by uncommenting the mv and 
# specifying a target for the move.

FFLAGS =  -ffixed-line-length-132 -w -O3 

SRSFILES = $(FFILES)

OBJFILES = $(FFILES:.f=.o)

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
'''

if compiler in ["ifort", "ifx"]:
    MakeEnd = MakeEnd.replace("FFLAGS =  -ffixed-line-length-132 -w -O3 ",
                              "FFLAGS =  -c -O3 -w -132 ")
    MakeEnd = MakeEnd.replace("$(NAME):       $(SRSFILES)", "$(NAME):	$(OBJFILES)")
    MakeEnd = MakeEnd.replace("	gfortran $(FFLAGS) -o $(NAME) *.f ",
                              f"	{compiler} -g -o $(NAME) *.o")
    MakeEnd = MakeEnd.replace("#.f.o:", ".f.o:")
    MakeEnd = MakeEnd.replace("#	gfortran $(FFLAGS) -o $*.f ",
                              f"	{compiler} $(FFLAGS)  -g $*.f")

for file in glob.glob("*.f90"):
    os.system(f"{compiler} -c {file}")

with open("Makefile", "w") as f:
    f.write(MakeBeg)
    files = sorted(glob.glob("*.f*"))
    for i, file in enumerate(files):
        if i == len(files) - 1:
            f.write(file + "\n\n")
        elif i % 4 < 3:
            f.write(file.ljust(19) + " ")
        else:
            f.write(file + " \\" + "\n")
    f.write(MakeEnd)

os.system("make")
# if compiler in ["ifort", "ifx"]:
os.system("rm *.o *.mod")
os.system("rm Makefile")
