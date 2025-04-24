#!/bin/bash

# This script runs the tests in the testsuite.txt file
# and compares the output to the standard output.
# Usage: ./run_tests.sh [S]
# If the first argument is "S", it will make this version the standard.
# If the first argument is not "S", it will compare this version to the standard.
# KC 2025-04-18

yrec="../src/yrec"
if [ ! -f "$yrec" ]; then
  cd ../src
  make
  cd ../examples
fi

while IFS= read -r line; do
  if [[ -z "$line" || "$line" =~ ^# ]]; then
    continue
  fi

  echo -n "$(date '+%Y-%m-%d %H:%M:%S') "
  read dir test <<< "$line"
  echo "Running test $test in directory $dir"

  cd $dir
  for file in output/"$test".*; do
    rm "$file"
  done
  if [ -f "$test".nml2 ]; then
    ../"$yrec" "$test".nml1 "$test".nml2 > output/"$test".out
  else
    ../"$yrec" "$test".nml1 "$dir".nml2 > output/"$test".out
  fi

  echo -n "$(date '+%Y-%m-%d %H:%M:%S') "
  if [ "$1" = "S" ]; then
    echo "Making this version the standard"
    if [ -f output/"$test".diff ]; then
      rm output/"$test".diff
    fi
    mv output/"$test".* standard/

  else
    echo "Comparing this version to the standard"
    cd output/
    if [ -f "$test".diff ]; then
      rm "$test".diff
    fi
    for file in "$test".*; do
      echo "diff ../standard/$file $file" >> "$test".diff
      diff ../standard/"$file" "$file" >> "$test".diff
      echo >> "$test".diff
    done

    if (( $(cat "$test".diff | wc -l) > \
          $(($(ls -1q ../standard/"$test".* | wc -l) * 2)) )); then
      echo "Differences found in $test"
    else
      echo "No differences found in $test"
    fi
    cd ..
  fi

  echo
  rm fort.*
  cd ..
done < "testsuite.sh"

echo -n "$(date '+%Y-%m-%d %H:%M:%S') "
echo "All tests completed"