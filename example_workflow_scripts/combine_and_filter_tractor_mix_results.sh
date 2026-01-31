#!/bin/bash

#SBATCH -p normal
#SBATCH -c 2
#SBATCH --mem=32G
#SBATCH --job-name combine_and_filter_tractor-mix
#SBATCH -o logs/combine_and_filter_tractor-mix.out

###
### Combines chromosome Tractor-Mix outputs and filter for mappability, blacklist regions, and snps only
###
### update naming conventions and filenames
###

## combine sumstats
for chr in {1..22}; do
	if [ $chr -eq 1 ]; then 
		cat LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_chr${chr}_ftd_unrelated_tractor-mix_results_ac5_sex_country_project_pc1-10.tsv
	else 
		tail -n +2 LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_chr${chr}_ftd_unrelated_tractor-mix_results_ac5_sex_country_project_pc1-10.tsv
	fi
done > LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_all_chr_ftd_unrelated_tractor-mix_results_ac5_sex_country_project_pc1-10.tsv

### filter for blacklist
sum_stats="LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_all_chr_ftd_unrelated_tractor-mix_results_ac5_sex_country_project_pc1-10.tsv"
sum_stats_basename=$(basename "${sum_stats%.tsv}")

module load cluster/bedtools

awk 'BEGIN{OFS="\t"} NR>1 {print $1, $2-1, $2, $3}' $sum_stats | sort -k1,1 -k2,2n > sorted_sum_stats.bed

bedtools intersect -a sorted_sum_stats.bed -b /cluster/projects/ADFTD/redlat_paper_2/filtering_bed_files/k50_mappabilty.umap.sorted.bed -u | sort -k1,1 -k2,2n > sorted_sum_stats_mappability.bed

bedtools intersect -a sorted_sum_stats_mappability.bed -b /cluster/projects/ADFTD/redlat_paper_2/filtering_bed_files/all_blacklist_3col_sorted.bed -v | sort -k1,1 -k2,2n > sorted_sum_stats_mappability_all_blacklist.bed

awk '{ print $4 }' sorted_sum_stats_mappability_all_blacklist.bed > passing_variants_mappability_all_blacklist.txt

(head -n 1 $sum_stats && awk 'NR==FNR{a[$1]; next} $3 in a' passing_variants_mappability_all_blacklist.txt $sum_stats) > ${sum_stats_basename}_mappability_all_blacklist.tsv

awk 'BEGIN{FS=OFS="\t"} NR==1 || (length($4)==1 && length($5)==1)' ${sum_stats_basename}_mappability_all_blacklist.tsv > ${sum_stats_basename}_mappability_all_blacklist_snps.tsv