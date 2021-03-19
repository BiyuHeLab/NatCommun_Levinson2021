#!/bin/bash
#SBATCH --partition=cpu_short
#SBATCH --nodes=1
#SBATCH --ntasks=35
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=2G

module load matlab/R2017a

export SCRATCH= # SCRATCH DIRECTORY FOR CLUSTER
mkdir -p $SCRATCH/$SLURM_JOB_ID

matlab -nojvm -nodisplay -nodesktop -singleCompThread -r "HLTP_callMVPA_betas_HPC_parallel('$1'); quit;"

rm -rf $SCRATCH/$SLURM_JOB_ID
