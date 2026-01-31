#!/bin/bash

#SBATCH -p highmem
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH --job-name extract_tracts_ftd

###
### Example script extract tracts by chromosome
###
### Make a copy of this script in the directory you want to run it in and update paths.
### be sure to update paths and make sur num-ancs is set to what you want
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

python3 /cluster/home/jtaylor/software/Tractor/scripts/extract_tracts.py \
	--vcf /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/shapeit5/outputs_ftd_unrelated/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_${chr}_ftd_unrelated.phased.vcf.gz \
	--msp /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/local_ancestry/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_${chr}_ftd_unrelated.deconvoluted.msp.tsv \
	--num-ancs 3 \
	--output-dir /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated