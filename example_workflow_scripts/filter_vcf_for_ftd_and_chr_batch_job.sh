#!/bin/sh

#SBATCH -p normal
#SBATCH --job-name filter_vcf_ftd
#SBATCH --mem=32G
#SBATCH -c 8

###
### filter's phased vcfs for analysis subtype (input for extract tracts)
###
### be sure to update paths and naming convention in the command
###
### example command to run as batch jobs per chromosome: sbatch --array [1-22]%6 -o logs/filter_phased-%A_%a.out filter_vcf_for_ftd_and_chr_batch_job.sh /cluster/home/jtaylor/scripts/Run_Tractor/resources/chrs.txt
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

module load bcftools
module load htslib
	
bcftools view \
	-t ${chr} \
	--samples-file /cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_ftd_unrelated.ids \
	-Oz \
	-o LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_${chr}_ftd_unrelated.phased.vcf.gz \
	--threads $SLURM_CPUS_PER_TASK \
	/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/shapeit5/outputs/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools.phased.vcf.gz
tabix -p vcf LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_${chr}_ftd_unrelated.phased.vcf.gz
