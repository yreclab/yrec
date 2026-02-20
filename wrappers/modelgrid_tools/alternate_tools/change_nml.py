#!/usr/bin/env python
"""
update_yrec_nml.py

This script updates `.nml1` and `.nml2` namelist files for YREC (Yale Rotating 
Evolution Code) models by correcting and resolving internal file paths. It allows
users who have downloaded all YREC dependencies and preserved the directory
structure to automatically fix broken references in their input namelists.

Typical use case:
- Fix paths to input files found under a shared `/input` directory.
- Redirect special output file paths (e.g., `.track`, `.full`) to a defined output directory.

Author: Vincent A. Smedile 
Institution: The Ohio State University
Created: 8 August 2025
"""

import os
import re
from glob import glob
from pathlib import Path
import argparse
from tqdm import tqdm


def change_nml(file_path, root_dir, verbose=False, outpath=None, abs_outpaths=False):
    """
    Update .nml1 and .nml2 files in a directory with correct filepaths.

    Parameters
    ----------
    file_path : str
        Path to directory containing .nml1 and .nml2 files.
    root_dir : str
        Root YREC directory (must contain an /input subfolder).
    verbose : bool, optional
        If False, shows progress bar only. If True, prints detailed output.
    outpath : str, optional
        Directory where output files (special keys) should point to.

    Example
    -------
    change_nml(
        file_path="/Users/you/YREC/models/Run_ZAMSmodels",
        root_dir='/Users/you/YREC',
        outpath='/Users/you/YREC/Output',
        verbose=True
    )
    """

    # Keys representing output files that may be redirected
    SPECIAL_KEYS = {
        "FLAST": ".last", "FMODPT": ".full", "FSTOR": ".store", "FTRACK": ".track",
        "FSHORT": ".short", "FPMOD": ".pmod", "FPENV": ".penv", "FPATM": ".atm",
        "FSNU": ".snu", "FSCOMP": ".excomp"
    }

    def has_excluded_template(val):
        """Ignore template/dummy file entries that should not be replaced."""
        return any(x in val.lower() for x in ['template', 'dummy', 'replace', 'default'])

    def parse_nml_file(nml_path):
        """Read and parse key-value pairs from a .nml file, ignoring comments."""
        with open(nml_path, 'r') as f:
            lines = f.readlines()

        # Remove inline and full-line comments
        clean_lines = [line.split('!')[0].strip() for line in lines if line.strip() and not line.strip().startswith('!')]
        joined = "\n".join(clean_lines)

        # Extract entries like KEY = value
        entries = re.findall(r'([A-Z0-9_]+)\s*=\s*([^,\n]+)', joined, re.IGNORECASE)
        nml = {}
        for key, val in entries:
            key = key.upper()
            val = val.strip().strip('"')
            nml[key] = val
        return nml

    def resolve_file_paths(nml_file, nml_dict):
        """
        Adjust file paths in the nml_dict:
        - General keys: Search in root_dir/input recursively.
        - Special keys: Construct new path in outpath.
        """
        input_root = os.path.join(root_dir, 'input')

        for key, val in nml_dict.items():
            if not isinstance(val, str) or has_excluded_template(val):
                continue

            # General file keys (not in SPECIAL_KEYS)
            if '/' in val and key not in SPECIAL_KEYS:
                filename = os.path.basename(val)
                candidates = glob(os.path.join(input_root, '**', filename), recursive=True)
                if candidates:
                    if abs_outpaths:
                        resolved = os.path.abspath(candidates[0])
                    else:
                        resolved = os.path.relpath(candidates[0], start = file_path)
                    nml_dict[key] = f'"{resolved}"'
                    if verbose:
                        print(f"✅ {key} auto-resolved -> {resolved}")
                continue

            # Output file keys
            if key in SPECIAL_KEYS and outpath:
                nml_base = os.path.basename(nml_file).replace(".nml1", "")
                constructed = os.path.join(outpath, f"{nml_base}{SPECIAL_KEYS[key]}")
                nml_dict[key] = f'"{constructed}"'
                if verbose:
                    print(f"🏗️ {key} redirected -> {constructed}")

        return nml_dict

    def write_updated_nml(nml_path, updated_dict):
        """
        Overwrite original .nml file with updated values.
        Keeps original formatting and unmodified lines.
        """
        with open(nml_path, 'r') as f:
            original = f.readlines()

        updated_lines = []
        for line in original:
            stripped = line.strip()
            if '=' not in stripped or stripped.startswith('!'):
                updated_lines.append(line)
                continue

            key = stripped.split('=')[0].strip().upper()
            if key in updated_dict:
                new_line = f" {key} = {updated_dict[key]}\n"
                updated_lines.append(new_line)
            else:
                updated_lines.append(line)

        with open(nml_path, 'w') as f:
            f.writelines(updated_lines)

    # === Locate and process all relevant .nml1 and .nml2 files ===
    target_dir = Path(file_path)
    nml_files = list(target_dir.glob("**/*.nml[1]"))  # Matches .nml1 only

    for nml_file in tqdm(nml_files, desc="Updating .nml files"):
        if verbose:
            print(f"\n🔧 Updating: {nml_file}")
        try:
            nml_dict = parse_nml_file(nml_file)
            nml_dict = resolve_file_paths(nml_file, nml_dict)
            write_updated_nml(nml_file, nml_dict)
        except Exception as e:
            print(f"❌ Error updating {nml_file.name}: {e}")


# Optional: Allow execution from command line or scripts
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
            description=("Updates `.nml1` and `.nml2` namelist files for YREC (Yale Rotating\n"
            "Evolution Code) models by correcting and resolving internal file paths. It allows\n"
            "users who have downloaded all YREC dependencies and preserved the directory\n"
            "structure to automatically fix broken references in their input namelists.\n"
            "Paths inserted in NML files to locations in the input tree are relative to the\n"
            "'files' directory by default. This may be changed to absolute paths using the\n"
            "--abs flag.\n"
            "Example:\n"
            "$ change_nml.py --files <nml_dir> --root ../yrec --verbose --out ./out\n"),
            formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--files", "-f",
                        help="Directory in which NML1 file(s) may be found",
                        required=True)
    parser.add_argument("--root", "-r",
                        help="YREC root directory. Must contain 'input' dir.",
                        required=True)
    parser.add_argument("--out", "-o",
                        help="Output path where YREC will write files. Relative or absolute.",
                        required=True)
    parser.add_argument("--verbose", "-v",
                        help="Verbose progress output",
                        default=False,
                        action="store_true")
    parser.add_argument("--abs", "-a",
                        help="Make paths written to output files absolute instead of relative.",
                        default=False,
                        action="store_true")
    args = parser.parse_args()

    # Minimal usage example
    change_nml(
        #file_path=".",
        #root_dir="../..",
        #outpath="./output",
        file_path=args.files,
        root_dir=args.root,
        outpath=args.out,
        abs_outpaths=args.abs,
        verbose=args.verbose
    )
