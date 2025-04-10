Quick Start
===========

To run YREC you need to first build it, link it with the appropriate input physics tables, and provide a starting model. It is important to note that you must choose a starting model from the library of solutions, as YREC is a relaxation code. Changes to starting models are processed with a “rescaling” option.

## Installation

```{admonition} Code Location
:class: seealso
:name: code-location
The code can be found in `src/` (all files ending in `.f`, e.g. `*.f`.) They are assembled into an executable using the script `Makefile`. This will require a Fortran compiler on your machine. The name of the executable can be adjusted, or the location of it moved to your working directory.
```

To begin with the installation process, you will need the GNU Fortran (`gfortran`) or Intel Fortran (`ifort`) compiler, which you can install using your package manager.

In the `yrec/src` directory, run the `make` command. It will create a `yrec` binary in the current directory.

This binary can then be moved to another directory, renamed, and then called using `./yrec file.nml1 file.nml2`.

To install yrec to ~/bin, run the following command:

```
make && make install PREFIX=~/bin
```

This will then allow you to call yrec from a directory that has been added to your $PATH.

You can also run it without a PREFIX specified, using `make; sudo make install`; doing so will install to `/usr/local/bin/yrec`, so you can call `yrec` from any directory.

## Running the examples

There are existing runs packaged with YREC in the `examples/` directory. These include a variety of different test cases which span a wide range in mass and age. To run, simply open a terminal at the folder and follow the instructions in the README to feed in the appropriate `nml1` and `nml2` files.

```{admonition} Namelist file locations
:class: caution
:name: namelist-paths
The example templates have all their paths set relative to the directory structure, rather than as an absolute path. If you are designing your own namelists in a custom directory structure, make sure to double check that your paths in your `.nml1` file are set correctly. It may be helpful to place the `input/` folder in a known location on the filesystem, and use an absolute path to point to it.
```

### Understanding the output

YREC produces multiple output files, which can be parsed and plotted. The nature of these output files are as follows:

| Filetype     | Description    |
| ------------ | -------------- |
| `.track`      | A stellar model track, recording general model information at each individual timestep in the YREC run. It does not record the full interior structure of the star at each step; rather, it presents observables such as the central temperature and pressure, or the stellar luminosity, at each timestep. |
| `.last`      | The last converged stellar structure model computed, readable by YREC. The file format is the same as that of the starting model. |
| `.short`      | Detailed numerical information about the model as it evolves. Can be set to output frequently, for instance when `LPULSE=.TRUE.` |
| `.store`      | Stored model snapshots over the course of a run. |
| `.pmod`      | Pulsation output for the interior model. |
| `.penv`      | Pulsation output for the envelope model. |
| `.atm`      | Pulsation output for the atmosphere model. |
| `.full`      | Deprecated detailed model structure output, formatted. |
| `.excomp`      | Deprecated composition output over time, moved to .track. |

### Batch scripting and templating
