#!/bin/bash

#SBATCH -p highmem
#SBATCH -c 32
#SBATCH --mem=400G
#SBATCH --job-name local_ancestry


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


chr=$(sed -n ${SLURM_ARRAY_TASK_ID}p $1)

echo ${chr}

input_basename=$2
outputs_dir=$(realpath shapeit5/outputs)


mkdir -p local_ancestry
cd local_ancestry

source /cluster/home/jtaylor/micromamba/etc/profile.d/micromamba.sh
micromamba activate /cluster/home/jtaylor/micromamba/envs/rfmix2


rfmix \
	-f ${outputs_dir}/${input_basename}.phased.vcf.gz \
	-r /cluster/home/jtaylor/reference_files/1000G_hg38/ALL.${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz \
	-m /cluster/home/jtaylor/scripts/Run_Tractor/resources/1000G_superpop_labels_amr_eur_afr.tsv \
	-g /cluster/home/jtaylor/scripts/Run_Tractor/resources/${chr}.hg38.gmap.txt \
	-o ${input_basename}_${chr}.deconvoluted \
	--chromosome=${chr} \
	--n-threads=${SLURM_JOB_CPUS_PER_NODE}