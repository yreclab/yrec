Yale Rotating Evolution Code
============================

**YREC** is a stellar evolution code optimized for the study of hydrostatic stars from the pre-main sequence through to the helium burning phase of evolution.
It is fast, precise, and accurate in the domains where it functions.

YREC has been extensively used for both stellar population and stellar physics studies, including precision solar models. YREC can also be used to study giant planets and white dwarfs. It includes important physical processes not traditionally included in classical stellar models. 


```{admonition} Physical processes
:class: note
YREC uses modern input microphysics (equation of state, energy transport, energy generation, surface boundary conditions) with a variety of user-configurable options. YREC is a pseudo-2D code that includes gravitational settling, mass loss, rotation, angular momentum loss from magnetized winds, and the structural effects of magnetic fields. 
```

```{toctree}
:maxdepth: 1
quickstart.md
userguide.md
testsuite.md
```

```{toctree}
:maxdepth: 1
:caption: YREC Internals
namelists.md
microphysics.md
```
