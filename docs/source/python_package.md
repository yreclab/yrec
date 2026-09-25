Python Package
===============

To make YREC as easy to use and integrate into research and teaching as
possible, a Python wrapper has been developed which encapsulates all the YREC
functionality and makes it available from within the Python programming
environment.

# Installation

`python -m pip install yrec`


# Usage

To use YREC in a python environment, import the package `yrec`.

## Support data

The first time yrec is imported after installation, it will perform a
single-time download of supporting data into the default location
`${HOME}/.config/yrec` which may take a few minutes to download depending on
the speed of the internet connection.

The support data include the INPUT and STARTMODELS directories from the
release of YREC used to build the core application bundled within the python
package.

```{admonition} Note
:class: hint
The support data download location can be overridden by setting the
`YREC_DATA` environment variable to the new location prior to each time
yrec is imported.  This can be done before running python code, via `export
YREC_DATA=<location>` (bash-like shells) , or from within a python script
by using `os.environ['YREC_DATA']=<location>`.
```

### yrec module

Variables:
   * __ __version__ __ - Version of package
   * __ __commit__ __- Git commit hash of source tree used to build wrapped YREC executable

#### `yrec.run_parallel(models, workers=0, verbose=False)`

Run multiple models simultaneously. Argument is a list containing one or more model objects.

Parameters:
   * models - List of `Model`(s) to run
   * workers - Number of requested worker processes (default 0 means number of available CPUs)
   * verbose - Print extra information about process dispatch and status (default False)

### yrec.model module

#### `class yrec.model.Model(nml1=None, nml2=None)`

A YREC model

Parameters:
   * nml1 – PHYSICS or CONTROL namelist filename
   * nml2 – CONTROL or PHYSICS namelist filename

   PHYSICS and CONTROL arguments may be in any order.

Variables:
   * name - Name given to model
   * control - CONTROL vars (dict)
   * physics - PHYSICS vars (dict)
   * control_filename - CONTROL namelist output filename
   * physics_filename - PHYSICS namelist output filename

##### `copy(yrec_model)`

Make a new model by copying an existing model.


##### `.run()`

Run the model using the YREC core and deposit outputs in the output directory
specified.  Terminal output from the progress of the run is deposited in the
`<model_name>.out` file.


## Shell Entrypoint

A shell entrypoint is registered whenever the environment containing the yrec
package is activated.  This provides a `yrec` command which may be invoked at
the shell prompt outside of any Python usage to run the YREC executable
directly in the same way as if it were built from source by the user.

The documentation for namelist placeholders and environment variables applies
to this method of running YREC. See [File Location Specifiers](namelist_control.md#file-location-specifiers)


## Examples

Display version

```
import yrec
yrec.__version__
```

### Creating models

Creating a model object from the can be done in a couple ways.

Create a model using the values specified by the namelist files NML1 and NML2.
They are provided as arguments to the Model() constructor in any order.
```
import yrec
mymodel = yrec.Model(NML1_or_2, NML2_or_1)
i.e.
mymodel = yrec.Model('control_namelist.nml1', 'physics_namelist.nml2')
```

Create a model by copying an existing model which is passed as the only
argument. This may be useful for quickly creating several models that are all
derived from a given model.
```
mymodel2 = yrec.model.copy_existing( my_mode )
```

### Running models

Run a single model
```
mymodel = yrec.Model('control_A.nml1', 'physics_A.nml2')
mymodel.run()
```

Run multiple models simultaneously, using three concurrent workers.
```
mA = yrec.Model('control_A.nml1', 'physics_A.nml2')
mB = yrec.Model('physics_B.nml2', 'control_B.nml1')
mC = yrec.Model('control_C.nml1', 'physics_C.nml2')
models = [mA, mB, mC]
yrec.run_parallel(models, workers=3)
{'mA_name': True, 'mB_name': True, 'mC_name': True}
```

The output files produced by the YREC executable are deposited into the
locations specified in the associated CONTROL namelist variables.  The terminal
output from the run is captured and placed alongside the other output files.

## Versioning convention

The version of the core YREC (Fortran) application is specified as `YYYYMM`, i.e.
`202602`.

The python wrapper version is expressed as `YYYY.MM.#`. The `MM` portion is
not zero-padded as the YREC core version value is.  The final number after the
second period reflects the revision of the python wrapper itself, apart from
the functionality provided by the YREC core which it wraps.


