#!/bin/sh

#SBATCH -p normal
#SBATCH --job-name filter_ftd_map_files
#SBATCH -c 2
#SBATCH --mem=8G
#SBATCH -o filter_ftd_unrelated_map_files.out

###
### Filters map files for analysis subtype
###
### generates the pheno specific map files for extract tracts input
### be sure to update path to samples file and naming convention
###

samples_to_keep="/cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_ftd_unrelated.ids"
basecols=6

for chr in {1..22}; do
	infile="LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_chr${chr}.deconvoluted.msp.tsv"
	outfile="LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_chr${chr}_ftd_unrelated.deconvoluted.msp.tsv"
		
	awk -v base="$basecols" '
	BEGIN{FS=OFS="\t"}
	NR==FNR{keep[$1]=1; next}
	
	FNR==1 { print; next}
	
	FNR==2{
  	for (i=1; i<=NF; i++){
    	name=$i
    	gsub(/\.0$|\.1$/,"",name)
    	if (i<=base || keep[name]) use[i]=1
  		}
		}
		{
  		out=""
  		for (i=1; i<=NF; i++) if (use[i]) out = (out=="" ? $i : out OFS $i)
  		print out
		}
		' "$samples_to_keep" "$infile" > "$outfile"
done