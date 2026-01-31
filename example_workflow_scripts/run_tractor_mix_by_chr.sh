#!/bin/bash

#SBATCH -p highmem
#SBATCH -c 16
#SBATCH --mem=32G
#SBATCH --job-name run_tractor-mix_ftd
#SBATCH --array [1-22]%22

###
### Script to handle sbatching chromsome Tractor-Mix runs
###
### be sure to update path to specific run_tractor_mix rscript
###

if [ ! -f $1 ];
then
    echo "$1 file does not exist"
    exit 1
fi

# make job tmp dir and clean up on exit
export TMPDIR=/cluster/home/jtaylor/scratch/tmp
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

chr=$(sed -n ${SLURM_ARRAY_TASK_ID}p $1)

echo ${chr}

## R env variables that prevent jobs from using too much resoruces. I found the best value to use for these is 25% of the cores submitted with the job
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4
export OPENBLAS_NUM_THREADS=4
export NUMEXPR_NUM_THREADS=4

source /cluster/home/jtaylor/micromamba/etc/profile.d/micromamba.sh
micromamba activate /cluster/home/jtaylor/micromamba/envs/r-env

Rscript /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/tractor_mix_ftd_unrelated_AC5_country_project_PC1-10/run_tractor_mix.R ${chr} $SLURM_CPUS_PER_TASK

micromamba deactivate