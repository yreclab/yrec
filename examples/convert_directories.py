#!/usr/bin/env python
import sys

if len(sys.argv) != 2:
    print("Usage: python rename_directories.py <nml1>")
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

        line = line.replace("/home/ast-pinsonneault-group/EVOLUTION/input", "../../input")
        line = line.replace("/home/pinsonneault.1/model/startmodels", "../../input/models/start")
        line = line.replace("/home/pinsonneault.1/model/output", "output")
        line = line.replace("/home/pinsonneault.1/model/testsuite", "output")
        f.write(line)
