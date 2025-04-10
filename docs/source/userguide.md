User Guide
==========

Welcome to YREC! In this guide, we present some common use cases for the YREC code, as well as overall troubleshooting advice. YREC can be applied to a wide range of astrophysical problems. No single set of controls will be adequate for all physically interesting cases. The different sample cases below involve using the code to solve problems that require significant differences in the numerical controls, tied to the nature of the problems themselves.

```{admonition} Errors
:class: hint
Users should always check on how their results depend on the assumptions in the underlying models, such as the temporal and spatial resolution. The error in a calculation is as important as the answer.
```

The YREC documentation covers how to compile and run the code; the input files that are needed for runs; and a description of the user parameters that govern the runs. What we are covering here are input instructions, in the form of namelists, for common physical scenarios.

## Initializing YREC

To run YREC you need the source code, a starting model, and input physics tables for the code. It is important to note that you must choose a starting model from the library of solutions, as YREC is a relaxation code. Changes to starting models are processed with a “rescaling” option. YREC was written as a `F77` program but is `F90` compliant.

```{admonition} Code Location
:class: seealso
:name: code-location
The code can be found in `../source/` (all files ending in `.f`, e.g. `*.f`.) They are assembled into an executable using the script `Makefile`; on Linux, `make -f Makefile` should generate the required executable. This will require a Fortran compiler on your machine. The name of the executable can be adjusted, or the location of it moved to your working directory.
```

You also need to include two namelists (with default names `yrec8.nml1` and `yrec8.nml2`). The first file includes I/O data and global run information. The second file includes microphysics and numerical parameters. Both namelist files should be in the same directory as the executable; paths to other I/O files are specified in `yrec8.nml1`.

```{admonition} Input Files
:class: note
The input files for YREC are not large, and in practical terms it may be useful to copy them to your local directory using the same directory structure.  All are found in daughter directories in the `input/` file directory. 
```

### Tables

**Surface Boundary Condition Tables.** YREC requires an atmospheric boundary condition for the pressure at $T = T_{\mathrm{eff}}$; by default this is evaluated at $\tau =2/3$. (It would be possible to code alternatives if desired). It is also possible to do a table look-up for the pressure – there are two sets tabulated (under /atmos/allard and /atmos/kurucz.  Allard is only available for solar metallicity. Kurucz 1991 tables are available here, and one must choose the correct metallicity (`*m13.tab` => $\mathrm{[Fe/H]} = -1.3$; `*p03.tan` => $\mathrm{[Fe/H]}=0.3$). These options are chosen in `yrec8.nml2`, and the file paths specified in `yrec8.nml1` if used. 

**Atomic Opacity Tables.** High temperature opacity tables are packaged for a range of metallicities but require the user to specify the mixture of heavy elements. We recommend using the Grevesse & Sauval (1998) mixture.  There are two choices (OPAL or OP), found in the `input/opacity/opal95` : `GS98.OP17` and `GS98.OPAL17`. This requires the user to specify `LOPAL95 = .TRUE.` in `yrec8.nml1` and specify a path for the file. 

**Molecular Opacity Tables.** Molecular opacities are used below 10,000 K. The recommended input is `input/opacity/alex06/alexmol06gs98.tab.` As for the atomic opacity tables, this includes all metallicities, and it requires the user to set `LALEX06 = .TRUE.` in `yrec8.nml1` and specify a path. 

**Helium Burning Tables.** Helium burning uses a different type of atomic opacity table, found at `input/opacity/lanl/PURECO.DBGLAOL.`

**Conductive Opacity Tables.** Conductive opacities are important in some domains, and we recommend using the Potekhin tables at `input/opacity/potekhin/condall06.d` (flag `LCondOpacP=.TRUE.` in `yrec8.nml2`) 

**Fermi Tables.** Degeneracy pressure requires a numerical solution of the Fermi integrals, which is found at `input/eos/yale/FERMI.TAB.`

**Equation of State Tables.** As for opacities, there are low and high temperature equation of state options. There is also a simplified older EoS (basically boltzman/saha at low T, and fully ionized at high T); this is computed analytically as a backup option and does not require a table. We strongly recommend using the 2006 OPAL EOS (`LOPALE06=.TRUE.` in `yrec8.nml2`) at high temperatures. The SCV equation of state at low temperatures is an interesting option (`LSCV=.TRUE.` in `yrec8.nml2`), with tables at `input/eos/scv/`[^1].

### Starting Models

YREC comes bundled with multiple families of starting models, which are under `input/models/`.

- `seed` models are the legacy starting models from prior generations of the YREC code. These are all pre-MS models, well up the Hayashi track. These models use the Grevesse & Sauval (1998) mixture; note that you will need to manually adjust the CNO abundance vectors for consistency with Z in the event that you adopt a different mixture. Files that end with `.pms` are far above the true birthline, but a good choice to initialize if you want to perturb a starting model to a different set of physical conditions. Ones ending in `.ahbl` are at the deuterium burning birthline, and these can be good choices to initialize models with rotation.
- `start` models are generated from the seed models. These are all generated using the Grevesse & Sauval (1998) heavy element mixture, the OPAL 2006 EoS, the Eddington gray atmosphere, and a mix of OP atomic opacities and Alexander+2006 molecular opacities. There is a dense grid of models for solar metallicity (0.03 – 25 solar masses), and a sparse grid (0.05, 0.1, 0.3, 1, 3, 10 solar masses) run for metallicities from 0.001 – 0.06. These models are a good initial starting set if you plan on modifying the masses, mixtures or metallicities of the models. You can generate a denser grid at different metallicities by copying the templates used in the Run_start_zgrid for a wider range of starting masses.
- `dbl` models are the starting models run to the beginning of the deuterium burning birthline, defined as a 1% drop from the initial deuterium abundance. These are a good starting point for normal stellar evolution calculations. If you need a mass / abundance combination not present in the library, you should generate it from the starting model libraries and run it to this initial state.

[^1]:(`h_tab_i.dat`; `he_tab_i.dat`; `z_tab_i.dat`)

# Running YREC

YREC has two mandatory namelists. The second namelist, yrec8.nml2, discussed in detail below, contains almost all of the physical options (e.g. does the model include rotation? What are the assumed nuclear reaction cross-sections?) and the numerical ones (what are the adopted spatial and temporal resolutions? How accurate does the solution need to be?) The first namelist contains global run instructions, pointers to the input and output files, and specifies the frequency of output and it’s degree of detail. There are a small number of miscellaneous controls as well, described below. 

## Global Instructions

**DESCRIP**(1) – (2): A two line plain text header describing the run. This appears as a header in the output track file. 

YREC is a relaxation code that requires a valid solution of the structure equations as an input. There are therefore three classes of operations that it can perform:  

1. It can rescale a starting model (as described below) with a zero timestep. This is appropriate for the zero-age main sequence (core H burning) or the zero-age horizontal branch (core He burning). 

2. It can rescale and evolve a starting model with a non-zero timestep. This is required for pre-MS models, as there is no time-independent solution for a star supported by gravitational potential energy release. 

3. It can evolve a starting model, or the result of a prior rescaling step, without changing the global model properties. 

A typical run will involve 2 steps: a rescaling of the starting model to the correct mixing length, composition, mass, and input physics (which are in general different than the ones assumed in the library), followed by a run to a specified end point or number of models.  If the parameters of the rescaled model are very different from the input, multiple rescalings may be needed (example: using a solar metallicity model as a template for a very metal poor model may need a series of metallicity rescalings). 

Each YREC run has a fixed mass and composition (set in namelist 1), and a starting rotation rate (set in `yrec8.nml2`). Suites of models with varying mass, composition, or rotation rate are generated by multiple runs of YREC using scripts. 

### Mandatory Global Variables
**NUMRUN** (n/a) - The number of separate runs the code will execute. For each of these runs, the following vectors must be specified: 

**KINDRN**(I) – The type of operation being performed. 1 = evolve (all rescaling options are ignored in this case); 2 = rescale (rescaling options used, timestep set to zero); 3 = evolve and rescale (rescaling options used, timestep calculated as normal). Option 3 should only be used for the pre-MS. 

**LFIRST**(I) – This T/F flag specifies whether the starting model will be used, or if the result of the prior run will be used. This is hard-coded true on the first run. In general, this will be TRUE for the first run and false for subsequent ones. (One can do clever exceptions, but it is almost always better practice to use multiple code runs instead.) 

**NMODLS**(I) – The code will run to this number of models, until it crashes, or if it reaches an optional independent stop condition. 

**CMIXLA**(I) – The mixing length, in pressure scale heights. If fixed for a calculation, specify the same value in all runs. 

**ZENV0A**(I) - The surface metallicity; this is used as an output label, not an input variable. I recommend depreciating this; set to the same value as either the input Z or the rescaled one. 

**XENV0A**(I) - The surface hydrogen mass fraction; this is used as an output label, not an input variable. I recommend depreciating this; set to the same value as either the input X or the rescaled one. 

#### Rescaling variables

A negative value means that this component is not being rescaled (except for `SENV0A`, which is by definition a negative number). Note: care should be taken for CHeB stars, and arguably it is better to use scripts to create modified starting models for them. 

**RSCLM**(I) - If positive, rescale to this total mass (Msun). All mass variables are stretched in a pre-MS or MS model. For a CHeB star the envelope mass is stretched and the He core mass is held fixed (see below). 

**RSCLCM**(I) - If positive, rescale to this He core mass (CHeB only).  

**RSCLX**(I) - If positive, rescale to this hydrogen mass fraction (envelope in CHeB, full star otherwise.) 

**RSCLZ**(I) - If positive, rescale to this metallicity (whole star). 

**LSENV0A**(I) - If true, adjust the outer fitting point mass location. 

**SENV0A**(I) = -1.0D-7 ! Log of fractional envelope fitting point mass, defined as the difference between the outer fitting point and the total mass. Values greater than -1e-11 are set to -1e-11, e.g. this must be a negative number. -1e-4 is standard, -1e-7 is a thin outer envelope fitting point; -1e-11 sets the fitting point at the atmospheric boundary condition, equivalent to MESA. 

### Stopping Conditions

**ENDAGE**(I) - Stop runs if the model age exceeds this value (in yr).



Annotated code example:

```{literalinclude} ../../src/alfilein.f
:lines: 1-20
```
