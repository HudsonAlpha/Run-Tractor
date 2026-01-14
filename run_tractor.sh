#!/bin/bash

#SBATCH -p normal
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --job-name run_tractor
#SBATCH -o /cluster/home/jtaylor/logs/Tractor/tractor_driver.out

input_vcf=$1
output_dir=$2

input_vcf_fn=$(basename ${input_vcf})
input_vcf_basename=${input_vcf_fn%.vcf.gz}

date=$(date +%Y-%m-%d)

mkdir /cluster/home/jtaylor/logs/Tractor/tractor_run_${input_vcf_basename}_${date}
log_dir=/cluster/home/jtaylor/logs/Tractor/tractor_run_${input_vcf_basename}_${date}
export log_dir

mkdir -p $output_dir
cd $output_dir

###
### Phasing
###

mkdir shapeit5
cd shapeit5

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

# concat phased chr vcfs
concat_job=$(sbatch --parsable --dependency=afterok:${ligate_jobs} -o ${log_dir}/concat_chrs-%A_%a.out \
	/cluster/home/jtaylor/scripts/Run_Tractor/concat_chrs.sh ${input_vcf_basename})

cd ../

###
### Local Ancestry
###

local_anc_job=$(sbatch --parsable --array [1-22]%6 --dependency=afterok:${concat_job} -o ${log_dir}/local_ancestry-%A_%a.out \
	/cluster/home/jtaylor/scripts/Run_Tractor/local_ancestry.sh /cluster/home/jtaylor/scripts/Run_Tractor/chrs.txt ${input_vcf_basename})

cd ../

###
### Tractor
###

mkdir tractor
#cd tractor