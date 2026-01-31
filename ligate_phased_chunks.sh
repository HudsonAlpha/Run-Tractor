#!/bin/bash

#SBATCH -p highmem
#SBATCH -c 32
#SBATCH --mem=150G
#SBATCH --job-name ligate_chunks


if [ ! -f $1 ];
then
    echo "$1 file does not exist"
    exit 1
fi

# make job tmp dir and clean up on exit
export TMPDIR=/cluster/home/jtaylor/scratch/tmp
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

module load cluster/shapeit/5.1.1
module load htslib


chr=$(sed -n ${SLURM_ARRAY_TASK_ID}p $1)

echo ${chr}

input_basename=$2
phased_chunks_dir=$(realpath phased_bcfs)


mkdir -p ligation
cd ligation

ls -1v ${phased_chunks_dir}/*_${chr}:*.bcf > ${chr}_files.txt

ligate \
	--input ${chr}_files.txt \
	--output ${input_basename}_${chr}.phased.vcf \
	--thread ${SLURM_JOB_CPUS_PER_NODE} \
	--index

bgzip --threads ${SLURM_JOB_CPUS_PER_NODE} ${input_basename}_${chr}.phased.vcf
tabix -p vcf ${input_basename}_${chr}.phased.vcf.gz
