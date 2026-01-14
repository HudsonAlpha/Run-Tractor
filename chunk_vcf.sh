#!/bin/bash

#SBATCH -p normal
#SBATCH -c 24
#SBATCH --mem=80G
#SBATCH --job-name chunk_vcf


if [ ! -f $1 ];
then
    echo "$1 file does not exist"
    exit 1
fi

# make job tmp dir and clean up on exit
export TMPDIR=/cluster/home/jtaylor/scratch/tmp
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

module load bcftools
module load htslib
module load cluster/shapeit/5.1.1


filter_region=$(sed -n ${SLURM_ARRAY_TASK_ID}p $1)

chr=$(echo ${filter_region} | cut -f1 -d ':')

input_vcf=$2
working_dir=$(pwd)

input_vcf_fn=$(basename ${input_vcf})
input_vcf_basename=${input_vcf_fn%.vcf.gz}

mkdir -p chunked_vcfs
mkdir -p phased_bcfs
cd chunked_vcfs


bcftools view \
	-r ${filter_region} \
	--threads ${SLURM_JOB_CPUS_PER_NODE} \
	-Oz \
	-o ${input_vcf_fn%.vcf.gz}_${filter_region}.vcf.gz \
	${input_vcf}

tabix \
	-p vcf \
	${input_vcf_fn%.vcf.gz}_${filter_region}.vcf.gz

# Add AC/AN tags in input file
bcftools +fill-tags ${input_vcf_fn%.vcf.gz}_${filter_region}.vcf.gz \
	-Oz \
	-o ${input_vcf_fn%.vcf.gz}_${filter_region}.unphased.vcf.gz \
	-- -t AN,AC

tabix \
	-p vcf \
	${input_vcf_fn%.vcf.gz}_${filter_region}.unphased.vcf.gz


#### old command with ref
#phase_common \
#	--input ${input_vcf_fn%.vcf.gz}_${filter_region}.unphased.vcf.gz \
#	--reference /cluster/home/jtaylor/reference_files/1000G/ALL.${chr}.phase3_shapeit2_mvncall_integrated_v5b.hg38.20130502.genotypes.sorted.vcf.gz \
#	--region ${chr} \
#	--filter-maf 0.001 \
#	--map /cluster/home/jtaylor/software/shapeit5/resources/maps/b38/${chr}.b38.gmap.gz \
#	--output ${working_dir}/phased_bcfs/${input_vcf_fn%.vcf.gz}_${filter_region}.phased.noref.bcf \
#	--thread ${SLURM_JOB_CPUS_PER_NODE}


phase_common \
	--input ${input_vcf_fn%.vcf.gz}_${filter_region}.unphased.vcf.gz \
	--region ${chr} \
	--filter-maf 0.001 \
	--map /cluster/home/jtaylor/scripts/Run_Tractor/resources/${chr}.b38.gmap.gz \
	--output ${working_dir}/phased_bcfs/${input_vcf_fn%.vcf.gz}_${filter_region}.phased.noref.bcf \
	--thread ${SLURM_JOB_CPUS_PER_NODE}