#!/usr/bin/env python

# This script converts the input and output directories.
# It removes the commented out FFIRST line and
# changes the input and output paths to relative paths.
# Usage: ./convert_directories.py <nml1>
# KC 2025-04-18

import sys
if len(sys.argv) != 2:
    print("Usage: python convert_directories.py <nml1>")
    sys.exit(1)
nml1 = sys.argv[1]

with open(nml1, "r") as f:
    lines = f.readlines()

with open(nml1, "w") as f:
    for line in lines:
        if line.strip().startswith("! FFIRST ="):
            continue
        elif not line.strip().startswith("F"):
            f.write(line)
            continue

        if line.strip().startswith("FFIRST ="):
            if ".pms" in line or ".ahbl" in line or ".nmo" in line:
                line = line.replace("/home/ast-pinsonneault-group/EVOLUTION/input/models/pms/gs98",
                                    "../../input/models/seed")
            elif "prems." in line or "tams." in line:
                line = line.replace("/home/pinsonneault.1/model/startmodels", "../../input/models/start")
            elif "Dbl." in line:
                line = line.replace("/home/pinsonneault.1/model/startmodels", "../../input/models/dbl")

        line = line.replace("/home/ast-pinsonneault-group/EVOLUTION/input", "../../input")
        line = line.replace("/home/pinsonneault.1/model/output", "output")
        line = line.replace("/home/pinsonneault.1/model/testsuite", "output")
        f.write(line)
