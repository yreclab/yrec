## This is an example on how to run YREC using HPC. 
## Current set up requires 4 directories. 
## One for each:
## -- the input (defined here) and output files (defined in nml1).
## -- the slurm output and the slurm error output (defined here).  

#!/usr/bin/bash
#SBATCH --job-name=yrec_grid_run
#SBATCH --qos=jtayar-b
#SBATCH --mail-type=END,FAIL # (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=l.morales@ufl.edu
#SBATCH --mem=4GB
#SBATCH --time=4:00:00
#SBATCH --output=output_slurm/%x-%A-%03a.out
#SBATCH --error=err_output_slurm/%x-%A-%03a.err

#SBATCH --array=[number of nml pairs]

module load gcc

INPUT_DIR="/path/to/input/files/"
## Log path for computation times
LOG_FILE="/path/to/file/direcory/[filename]"

NML_FILES=($(ls ${INPUT_DIR}/*.nml1))
NUM_FILES=${#NML_FILES[@]}

## Pick the current nml1 file for this array task
NML1="${NML_FILES[$SLURM_ARRAY_TASK_ID]}"
NML2="${NML1%.nml1}.nml2"

## tracking time
start=$(date +%s)

/path/to/yrec/src/yrec "$NML1" "$NML2"

end=$(date +%s)
runtime=$((end - start))

JOB_ID=${SLURM_JOB_ID:-"NA"}
TASK_ID=${SLURM_ARRAY_TASK_ID:-"NA"}
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

## append file name, runtime, job info
echo "${TIMESTAMP},${JOB_ID},${TASK_ID},$(basename "$NML1"),${runtime}" >> "$LOG_FILE"
