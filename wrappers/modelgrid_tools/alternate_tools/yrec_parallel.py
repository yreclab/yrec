#!/usr/bin/env python3
"""
yrec_parallel.py

Run multiple YREC model5.1c namelists in parallel with optional verbose output
and progress bar. Designed for batch execution of stellar evolution model runs.

Author: Vincent A. Smedile
Institution: The Ohio State University
Date: 2025-08-08
"""

# Import standard libraries for filesystem and subprocess handling
import os
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess as sub
from tqdm import tqdm  # For progress bars


def yrec_parallel(
    yrec_dir='/Users/vincentsmedile/YREC5.1/models',
    run_dirs='/Users/vincentsmedile/YREC5.1/models/Run_ZAMSmodels',
    verbose=False, 
    ncore_override = None
):
    """
    Run multiple YREC model5.1c namelists in parallel.

    Parameters
    ----------
    yrec_dir : str
        Path to directory containing the YREC executable.
    run_dirs : str or list of str
        Single run directory (str) or list of directories containing one or more .nml1/.nml2 pairs.
    verbose : bool
        If True, print full output from the model run. If False, only show completion and errors.
    ncore_override: None or int
        If none/default, instructs the function to use all cpus except for 3 and run the YREC program for every namelist
        in the directory in parallel until done. If given an int, it will use that many cores. 
        !!!ONLY CHANGE IF YOU DO NOT WANT TO RUN PARALLEL AND YOU KNOW THE NUMBER OF CPUS YOU HAVE!!!
    """

    # If run_dirs is a single directory string, convert to a list for uniform processing
    if isinstance(run_dirs, str):
        run_dirs = [run_dirs]

    runs = []  # List to store paired .nml1/.nml2 runs

    # Loop over each directory to find model input namelists
    for run_dir in run_dirs:
        run_path = Path(run_dir)

        # Find all .nml1 and .nml2 files in the directory, sorted alphabetically
        nml1_files = sorted(run_path.glob("*.nml1"))
        nml2_files = sorted(run_path.glob("*.nml2"))

        # Create a lookup dictionary from .nml2 filenames (stem => Path object)
        nml2_lookup = {f.stem: f for f in nml2_files}

        # Pair each .nml1 file with a matching .nml2 file by stem (filename without extension)
        for nml1 in nml1_files:
            stem = nml1.stem  # e.g. "model_run_01"
            if stem in nml2_lookup:
                # Append dict with absolute resolved paths for this run pair
                runs.append({
                    "nml1": str(nml1.resolve()),
                    "nml2": str(nml2_lookup[stem].resolve())
                })
            else:
                # Warn if no matching .nml2 found for a .nml1 file
                print(f"⚠ No matching .nml2 for {nml1}")

    # Raise error if no valid .nml1/.nml2 pairs found
    if not runs:
        raise FileNotFoundError("No .nml1/.nml2 pairs found in the given run_dirs.")

    # Define the function to run a single model using subprocess
    def run_model(run):
        # Build shell command to change to YREC directory and run executable with input files
        cmd = f"cd {yrec_dir} && ./model5.1c {run['nml1']} {run['nml2']}"
        # Execute the command, capture stdout and stderr as text
        result = sub.run(cmd, shell=True, capture_output=True, text=True)
        # Return the model's .nml1 path, command, stdout and stderr
        return (run['nml1'], cmd, result.stdout, result.stderr)

    # Determine how many parallel jobs to run, leaving some CPUs free
    if ncore_override is None: 
        num_cpus = os.cpu_count()
        max_workers = min(len(runs), max(1, num_cpus - 3))
    else: 
        if ncore_override < 1: 
            ncore_override = 1
            print(f"❌Number of cores used cannot be 0, defaulting to 1")
            max_workers = ncore_override
        else: 
            max_workers = ncore_override
    print(f"Running up to {max_workers} jobs in parallel (CPUs: {num_cpus})")

    # Use ThreadPoolExecutor to run all models in parallel with a progress bar
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Submit all model runs as futures
        futures = [executor.submit(run_model, run) for run in runs]
        # Initialize tqdm progress bar with total runs count and label
        with tqdm(total=len(futures), desc="YREC runs") as pbar:
            # As each future completes...
            for future in as_completed(futures):
                # Unpack returned values from run_model
                nml1_path, cmd, out, err = future.result()
                # Extract a friendly model name from the .nml1 filename stem
                model_name = Path(nml1_path).stem

                if verbose:
                    # If verbose, print full command, any errors, and output
                    print(f"\nFinished: {cmd}")
                    if err.strip():
                        print(f"Error:\n{err}")
                    else:
                        print(f"Output:\n{out}")
                    print(f"✅ Finished {model_name}")
                else:
                    # If not verbose, only print error or success summary
                    if err.strip():
                        print(f"❌ Error while running {model_name} — see logs.")
                    else:
                        print(f"✅ Finished {model_name}")

                # Update the progress bar after each run completes
                pbar.update(1)


# Allow script to be run directly with example paths
if __name__ == "__main__":
    yrec_parallel(
        yrec_dir='/Users/vincentsmedile/YREC5.1/models',
        run_dirs='/Users/vincentsmedile/YREC5.1/models/Run_ZAMSmodels',
        verbose=True
    )
