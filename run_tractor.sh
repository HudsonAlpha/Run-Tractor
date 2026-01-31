#!/bin/bash

#SBATCH -p normal
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --job-name run_tractor
#SBATCH -o /cluster/home/jtaylor/logs/Tractor/tractor_driver.out

###
### Main script driver for phasing and local ancestry. 
###
### inputs: joint called vcf, output directory name (will create if not a dir)
###


input_vcf=$1
output_dir=$2

input_vcf_fn=$(basename ${input_vcf})
input_vcf_basename=${input_vcf_fn%.vcf.gz}

input_plink_fn=$(basename ${input_plink}.fam)
input_plink_basename=${input_plink_fn%.fam}

date=$(date +%Y-%m-%d)

mkdir /cluster/home/jtaylor/logs/Tractor/tractor_run_${input_vcf_basename}_${date}
log_dir=/cluster/home/jtaylor/logs/Tractor/tractor_run_${input_vcf_basename}_${date}
export log_dir

mkdir -p $output_dir
cd $output_dir

###
### Phasing
###

mkdir phasing
cd phasing

# chunk and phase input vcf
chunk_vcf_jobs=$(sbatch --parsable --array [1-139]%15 -o ${log_dir}/chunk_and_phase-%A_%a.out /cluster/home/jtaylor/scripts/Run_Tractor/chunk_vcf.sh \
	/cluster/home/jtaylor/reference_files/shapeit5/all_chrs_chunk_filter_regions.txt ${input_vcf})

export chunk_vcf_jobs

# check and rerun failed chunk jobs
rerun_chunk_jobs=$(sbatch --parsable --dependency=afterany:${chunk_vcf_jobs} -o ${log_dir}/rerun_chunk_jobs.out \
	/cluster/home/jtaylor/scripts/Run_Tractor/check_chunk_jobs.sh ${input_vcf_basename})

# ligate chunks into chr files
ligate_jobs=$(sbatch --parsable --array [1-22]%6 --dependency=afterok:${rerun_chunk_jobs} -o ${log_dir}/ligate-%A_%a.out \
	/cluster/home/jtaylor/scripts/Run_Tractor/ligate_phased_chunks.sh /cluster/home/jtaylor/scripts/Run_Tractor/chrs.txt ${input_vcf_basename})

###
### Local Ancestry
###

local_anc_job=$(sbatch --parsable --array [1-22]%6 --dependency=afterok:${ligate_jobs} -o ${log_dir}/local_ancestry-%A_%a.out \
	/cluster/home/jtaylor/scripts/Run_Tractor/local_ancestry.sh /cluster/home/jtaylor/scripts/Run_Tractor/chrs.txt ${input_vcf_basename})