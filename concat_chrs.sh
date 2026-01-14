#!/bin/bash

#SBATCH -p highmem
#SBATCH -c 64
#SBATCH --mem=250G
#SBATCH --job-name concat_chrs

# make job tmp dir and clean up on exit
export TMPDIR=/cluster/home/jtaylor/scratch/tmp
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

module load bcftools
module load htslib

input_basename=$1

ligation_dir=$(realpath ligation)

mkdir -p outputs
cd outputs

ls -1v ${ligation_dir}/*chr*.bcf > chr_files.txt

bcftools concat \
	--file-list chr_files.txt \
	-Oz \
	-o ${input_basename}.phased.vcf.gz \
	--threads ${SLURM_JOB_CPUS_PER_NODE}

tabix -p vcf ${input_basename}.phased.vcf.gz

rm chr_files.txt