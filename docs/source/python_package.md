Python Package
===============

To make YREC as easy to use and integrate into research and teaching as
possible, a Python wrapper has been developed which encapsulates all the YREC
functionality and makes it available from within the Python programming
environment.

# Installation

`python -m pip install yrec`


# Usage

To use YREC in a python environment, simply import the package `yrec`. This
makes several classes and functions available which are detailed below.

## Support data

NOTE: The first time yrec is imported after installation, it will perform a
single-time download of supporting data.  The default location for this data is
in `${HOME}/.config/yrec`, but can be overridden by setting the `YREC_DOWNLOAD`
environment variable to another directory prior to importing yrec. This data may
take a few minutes to download depending on the speed of the internet connection.

This support data includes the INPUT and STARTMODELS directories from the
release of YREC used to build the core application bundled with the python
package. If you require newer or different INPUT or STARTMODELS data, you can
point the environment variable to where you have that stored prior to importing
yrec. Note: If you require an override location for the support data, that
location will have to be specified via environment variable prior to _each_ use
of yrec. This can be done from the shell, before running the script or python
interpreter, via `export YREC_DOWNLOAD=<location>`, or from within a python
script by using `os.environ['YREC_DOWNLOAD'] = <location>`.

Leaving `YREC_DOWNLOAD` unset will cause the support data to be stored and
accessed from the default location. This will be appropriate for nearly all use
cases.

## API


### yrec module

#### module members

```
yrec.run_parallel( [models] )
```
Run multiple models simultaneously. Argument is a list containing one or more model objects.


### Model Class Members

#### Method members

```
.run()
```
Run the model using the YREC core and deposit outputs in the output directory
specified.  Terminal output from the progress of the run is deposited in the
`<model_name>.out` file.


#### Data members

```
.name
```
Name for this model. Automatically derived from namelist input files, if the model
was created using those. Can be overridden by assigning a new string to this member.

```
.control
```
A dictionary representing the current state of the set of the model's CONTROL variables.

```
.physics
```
A dictionary representing the current state of the set of the model's PHYSICS variables.


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
They are provided as arguments to the model() method in any order.
```
import yrec
mymodel = yrec.Model(NML1_or_2, NML2_or_1)
i.e.
mymodel = yrec.Model('control_namelist.nml1', 'physics_namelist.nml2')
mymodel.run()
```

Create a model by copying an existing model which is passed as the only
argument. This may be useful for quickly creating several models that are all
derived from a given model.
```
mymodel2 = yrec.model.copy_existing( my_mode )
```


Run multiple models simultaneously, using three CPUs.
```
mA = yrec.Model('control_A.nml1', 'physics_A.nml2')
mB = yrec.Model('physics_B.nml2', 'control_B.nml1')
mC = yrec.Model('control_C.nml1', 'physics_C.nml2')
models = [mA, mB, mC]
yrec.run_parallel(models)
{'mA_name': True, 'mB_name': True, 'mC_name': True}
```


## Versioning convention

The version of the core YREC (Fortran) application is specified as `YYYYMM`, i.e.
`202602`.

The python wrapper version is expressed as `YYYY.MM.#`. The `MM` portion is
not zero-padded as the YREC core version value is.  The final number after the
second period reflects the revision of the python wrapper itself, apart from
the functionality provided by the YREC core which it wraps.


