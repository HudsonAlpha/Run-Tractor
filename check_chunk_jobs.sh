#!/bin/bash

#SBATCH -p normal
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --job-name check_chunk_jobs

input_vcf=$1

new_mem="300G"

failed_tasks=$(sacct \
	--job $chunk_vcf_jobs \
	--state=OUT_OF_MEMORY \
	-o JobID,JobName,State \
	--noheader | \
	grep "chunk_vcf" | \
	awk '{ print $1 }')
		
if [ -z "$failed_tasks" ]; then
	echo "No failed tasks found."
	exit 0
fi

echo "Failed tasks: ${failed_tasks}"

for job_id in $failed_tasks; do
    idx=$(echo "$job_id" | awk -F'[_]' '{print $NF}')
		failed_indexes+=("$idx")
done


echo "Failed array indices: ${failed_indexes[*]}"

tmp_index_string=$(IFS=,; echo "${failed_indexes[*]}")
echo "Resubmitting as new array with tasks: $tmp_index_string"

sbatch -W --array=$tmp_index_string -p highmem --mem=$new_mem -o ${log_dir}/rerun_chunk_and_phase-%A_%a.out \
	/cluster/home/jtaylor/scripts/Run_Tractor/chunk_vcf.sh /cluster/home/jtaylor/reference_files/shapeit5/all_chrs_chunk_filter_regions.txt ${input_vcf}


echo "Rerun jobs complete"