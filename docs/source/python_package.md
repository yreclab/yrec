Python Package
===============

To make YREC as easy to use and integrate into research and teaching as
possible, a Python wrapper has been developed which encapsulates all the YREC
functionality and makes it available from within the Python programming
environment.

## Installation

The YREC core versioning is formatted YYYYMM, i.e. 202602.

The python wrapper is versioned with a similar, but slightly expanded version
value.  YYYY.MM.#. The 'MM' portion will have only a single-digit value for
single-digit months, and two digits for two-digit months.  The final number
after the second period reflects the revision of this python wrapper itself,
apart from the functionality provided by the YREC core.

`pip install yrec`

## Usage

To use YREC in a python environment, simply import the package `yrec`. This
makes several classes and functions available which are detailed below.

### Support data

NOTE: The first time yrec is imported after installation, it will perform a
single-time download of supporting data.  The default location for this data is
in ${HOME}/.config/yrec, but can be overridden by setting the YREC_DOWNLOAD
environment variable to another directory prior to importing yrec. This data may
take a few minutes to download depending on the speed of the internet connection.

This support data includes the INPUT and STARTMODELS directories from the
release of YREC used to build the core application. If you require newer or
different INPUT or STARTMODELS data, you can point the environment variable to
where you have that stored prior to importing yrec. Note: If you require an
override location for the support data, that location will have to be specified
via environment variable prior to _each_ use of yrec. This can be done from the
shell, before running the script or python interpreter, via `export
YREC_DOWNLOAD=<location>`, or from within a python script by using
`os.environ['YREC_DOWNLOAD'] = <location>`.

Not setting this value will store and use the support data from the default
location and is meant to be transparent to the user.

### Select API members

#### model (class)

Creating a model object from the model class can be done several ways.

```
model(NML[1/2], NML[2/1])
```
Create a model using the values specified by the namelist files NML1 and NML2. They may be specified as arguments to the model() method in any order.

```
model.copy_existing( my_mode )
```
Create a model by copying an existing model which is passed as the only argument. This may be useful for quickly creating several models that are all modifications of each other.


```
mymodel.run()
```
Run the model using the YREC core and deposit outputs in the output directory specified.
Terminal output from the progress of the run is deposited in the `<model_name>.out` file.




### Shell Entrypoint

A shell entrypoint is registered whenever the environment containing the yrec
package is activated.  This provides a `yrec` command which may be invoked
outside of any Python usage to run the YREC executable directly in the same way
as if it were built from source by the user.

The documentation for namelist placeholders and environment variables applies
to this method of running YREC.  Specifically, be sure to set the YREC_INPUT
and YREC_START environment variables if those are referenced in any of the
namelist files you plan to use.


### Examples

Display version

```
import yrec
yrec.__version__
```

Create model from namelist files and run

```
mymodel = yrec.model('control_namelist.nml1', 'physics_namelist.nml2')
mymodel.run()
```




