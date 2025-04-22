#!/bin/bash
rm yrec
./make.py
cd ../examples/
./run_tests.sh
cd ../src
