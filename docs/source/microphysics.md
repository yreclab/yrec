Microphysics in YREC
====================

Standard stellar models are important tools for understanding stellar populations, and their approximations are reasonable ones for a range of interesting physical conditions. We therefore begin with ingredients in common with all models: the equation of state; opacities for conductive and radiative energy transport; convection; and the treatment of the boundary conditions. YREC is equipped to explore a number of distinct assumptions; note that some options are tied to the code being backwards-compatible with obsolete scenarios that are not currently recommended for use. 
% Variables with a blue prefix (`YREC8.NML1`) are set in the first namelist; generally speaking, these are input physics file locations used by the code, I/O controls, or run instructions. 

## Equation of State

The equation of state (EoS) relates composition, temperature and density to pressure. YREC employs a mixture of semi-analytic and tabulated equations of state. The EoS is also used to compute thermodynamic quantities, such as specific heats, and partial derivatives used for the solution of the structure equations (e.g. $d \ln P / d \ln T$). The latter impact the convergence of the structure equations, but do not dictate the solution; as a result, it can be important to have smoothly varying derivatives, which can be a challenge. Furthermore, different equation of state tables are generally valid only in specific domains. YREC therefore has a layered equation of state, defined as follows. 

### The Base YREC EoS

The default equation of state that includes electron degeneracy pressure, radiation pressure, and a Boltzmann-Saha solver for H and He that assumes full ionization higher than a critical threshold. This EoS can also include collective effects, such as the Debye-Huckel correction for the pressure reduction due to mutual electron repulsion. It is used by default where other EoS values are not present; because it is semi-analytic, the derivatives from this EoS are used for the solution of the structure equations even when other tabulated EoS calculations are used for the pressure itself. Radiation pressure is included analytically; electron degeneracy involves a table lookup.

`YREC8.NML1` **FFERMI** (n/a) – Path for the table of Fermi integral solutions, used for computing electron degeneracy pressure. This includes partial degeneracy and relativistic corrections. This must be specified for the code to run. 

**LDH** (TRUE), **ETADH0** (-2), **ETADH1** (1) – LDH toggles the usage of the Debye-Huckel correction to the standard EoS (T/F); ETADH0 and ETADH1 are the domains where it is used. Default settings are recommended. 

**TSCUT** (6.0) – A fully ionized EoS is assumed for `log T > TSCUT`. Do not alter without good reason, as the Saha equation for H and He breaks down at high density! 

### The OPAL EoS

```{admonition} Physical processes
:class: important
The tabulated OPAL EoS (Rogers& Nayfonov 2002) is the main recommended one for stellar evolution calculations.
```
It is available for 3.3 < log T < 8.3; there is a complex edge to the tables at higher densities, which is a function of T (see Figure 2, {cite:p}`2002ApJ...576.1064R`). The biggest practical restriction on the tables is the density range; there are regimes for low mass stars that are outside of the tables. If this condition is triggered, the code uses the default EoS. OPAL assumes a fixed heavy element abundance and mixture and does not allow the heavy element fraction to vary during a run (e.g. from gravitational settling). in general different OPAL tables should be used for different mixtures. Note: this is a minor effect, as P is insensitive to the metal content. I am having trouble finding the literature reference for the 2006 EoS, which I remember being a correction for an error in the treatment of relativistic electron degeneracy. 

`YREC8.NML1` **FOPALE** (n/a) – path to the OPAL EoS Tables. 

**LOPALE** (`FALSE`), **LOPALE01**(`FALSE`), **LOPALE06**(`FALSE`) – These are T/F flags for the usage of the 1996, 2002 and 2006 versions of the OPAL EoS. We should alter the defaults to make LOPALE06 = TRUE and depreciate the others. LOPALE06 = TRUE is strongly recommended. If all are set, LOPAL06 takes precedence over LOPAL01, which in turn takes precedence over LOPALE. 

**LNUMDeriv** (`FALSE`) – replaces the semi-analytic YREC EoS derivatives with numerical derivatives directly from the OPAL tables.  This choice imposes a large (factor of 3) performance penalty, with little impact on the solution. Choose wisely. 

### The SCV EoS

The tabulated SCV EoS is a viable supplement to the OPAL EOS for lower temperatures. The code logic is OPAL > SCV > YREC for cases where the EoS is outside of the table domain; a ramp is employed close to the OPAL table edge boundary. SCV uses three different pure abundance tables (X, Y, and Z; the latter was actually generated using the YREC EoS assuming Boltzmann-Saha and is a minor correction), with the EoS inferred by combining the solutions in a thermodynamically consistent fashion. 

`YREC8.NML1` **FSCVH** (n/a), **FSCVHE** (n/a), **FSCVZ** (n/a)   – paths to the SCV EoS tables for H, He and "metals". 

**LSCV** (FALSE) – A T/F flags for the usage of the SCV EoS. Note that if the OPAL EoS is used, SCV only is adopted if outside of the OPAL tables. To get a full SCV calculation, set OPAL off and SCV on! 

### The MHD EoS


```{admonition} Physical processes
:class: important
The tabulated MHD EoS is not currently recommended for usage, as it has not been maintained and modernized with code improvements. It is only available for low densities in any case. 
```

**FMHD1**, **FMHD2**, **FMHD3**, **FMHD4**, **FMHD5**, **FMHD6**, **FMHD7** – locations of the MHD EoS tables. 

  
