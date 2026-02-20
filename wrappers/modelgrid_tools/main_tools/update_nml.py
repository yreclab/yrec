'''
Intended use:
    - Read a master set of YREC namelist files, where both .nml1 and .nml2 are required. 
    - Replace parameter assignments given in command-line interface (CLI) or via function call. 
    - Write out a new set of YREC namelist files with user-specified naming convention. 
How to use CLI: 
    - python update_nml.py [filename].nml1 [filename].nml2 [output_prefix] "[PARAM]=[newvalue]"
How to use function call: 
    from update_nml import update_namelists
    params = {"[PARAM1]":"[VALUE]", "[PARAM2]":"[VALUE]", [...]} 
    result = update_namelists("file.nml1", "file.nml2", "updated_file", params, verbose=True) 
    
    Note:
    - Multiple parameters can be passed. 

    - if verbose = False, no warnings or print statements will be displayed. 
    '''
import sys
import re

def read_nml(filename):
    with open(filename, "r") as f:
        return f.readlines()

def write_nml(filename, lines):
    with open(filename, "w") as f:
        f.writelines(lines)

def parse_updates(args, verbose=True):
    ''' Parses CLI args or list of "PARAM=VALUE" strings into a dict.'''
    updates = {}
    for arg in args:
        if "=" not in arg:
            if verbose: 
                print(f"Skipping invalid update argument: {arg}")
            continue
        param, val = arg.split("=", 1)
        updates[param.strip().upper()] = val.strip()
    return updates

def update_lines(lines, updates, output_prefix):
    """Update lines with new parameter values and replace outfile names with user specified output_prefix."""
    found_params = set()
    new_lines = []
    
    output_file_names = ['FLAST','FSTOR','FTRACK','FSHORT','FPMOD','FPENV','FPATM','FMODPT','FSNU','FSCOMP']
    
    for line in lines:
        stripped = line.lstrip()
        if not stripped or stripped.startswith("!"):
            new_lines.append(line)
            continue

        updated = False
        for param, val in updates.items():
            # Match param, equal sign, spaces, value, keep all comments
            pattern = rf"^(\s*{re.escape(param)}\s*=\s*)([^\s!]+)"
            match = re.match(pattern, line, re.IGNORECASE)
            if match:
                leading = match.group(1)
                rest_of_line = line[match.end():]
                new_line = f"{leading}{val}{rest_of_line}"
                new_lines.append(new_line)
                found_params.add(param)
                updated = True
                break
        
        # Replaces output file names 
        if not updated: 
            for fname in output_file_names: 
                match = re.match(rf"^\s*{fname}\s*=\s*['\"]?.*?\.([a-zA-Z0-9_]+)['\"]?(.*)$", line, re.IGNORECASE)
                if match:
                    ext = match.group(1)
                    new_file_name = f'"{output_prefix}.{ext}"'
                    new_lines.append(f" {fname} = {new_file_name}\n")
                    updated = True
                    break
        
        # Keeps remaining parameters as is
        if not updated:
            new_lines.append(line)

    return new_lines, found_params

def update_namelists(nml1_file, nml2_file, output_prefix, updates_dict, verbose=True):
    '''
    Update YREC nml1 and nml2 files with given parameter updates.
    
    Args: 
        nml1_file (str) : Path to nml1 file.
        nml2_file (str) : Path to nml2 file. 
        output_prefix (str) : Prefix for updated .nml files.
        updates_dict (dict) : Dictionary of parameters to be changed and the values specfied.
        verbose (bool) : Print status messages if True. 
    Returns: 
        dict: { 
            "output_files": (updated_file.nml1, updated_file.nml2), 
            "missing_params": [list of parameters not found] 
        }
    '''
    nml1_lines = read_nml(nml1_file)
    nml2_lines = read_nml(nml2_file)
    
    # Update parameters 
    nml1_updated, nml1_found = update_lines(nml1_lines, updates_dict, output_prefix)
    nml2_updated, nml2_found = update_lines(nml2_lines, updates_dict, output_prefix)

    # Check for missing params
    all_found = nml1_found.union(nml2_found)
    missing = [param for param in updates_dict if param not in all_found]

    # Create file name using output_prefix
    new_nml1_file = f"{output_prefix}.nml1"
    new_nml2_file = f"{output_prefix}.nml2"
    write_nml(new_nml1_file, nml1_updated)
    write_nml(new_nml2_file, nml2_updated)
    
    if verbose:
        print(f"Output files:\n  {new_nml1_file}\n  {new_nml2_file}")
        if missing:
            print("Warning: parameters not found:", ", ".join(missing))
        else:
            print("All parameters updated successfully.")

    return {
        "output_files": (new_nml1_file, new_nml2_file),
        "missing_params": missing 
        }

def main():
    if len(sys.argv) < 5:
        print("Usage: python update_nml.py nml1_file nml2_file output_prefix 'PARAM=VALUE [...]'")
        sys.exit(1)

    nml1_file = sys.argv[1] 
    nml2_file = sys.argv[2]
    output_prefix = sys.argv[3]
    updates = parse_updates(sys.argv[4:])
    
    update_namelists(nml1_file, nml2_file, output_prefix, updates, verbose=True)

if __name__ == "__main__":
    main()
