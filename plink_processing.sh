#!/bin/bash

#SBATCH -p normal
#SBATCH -c 8
#SBATCH --mem=32G

###
### Kinship matrix processing
###
### filter to analysis subset, prunes related individuals, makes kinship matrix
### finally unrelated subste can be used to make filter files for phasing and local ancestry
###
### inputs: plink dataset basename, analysis phenotype (ad, ftd, cc), id list for analysis subtype (only needed for ad and ftd)
###

plink_set=$1
pheno=$2 
subset_file=$3

mkdir kinship_unrelated

## if case/control, no need to filter to subset first
if [ ${pheno} == "cc" ]; then

	# prune related individuals 
	plink2 \
		--bfile ${plink_set} \
		--king-cutoff 0.125 \
		--make-bed \
		--out ${plink_set}_${pheno}_unrelated \
		--memory ${SLURM}

	# kinship matrix
	/cluster/home/ncochran/bin/gemma-0.98.5-linux-static-AMD64 \
		-bfile ${plink_set}_${pheno}_unrelated \
		-gk 2 \
		-maf 0.005 \
		-o ${plink_set}_${pheno}_unrelated \
		-outdir kinship_unrelated

else
	
	# make pheno filter file for plink dataset
	awk 'NR==FNR { ids[$1]; next } $2 in ids { print $1, $2 }' \
	    $subset_file \
	    ${plink_set}.fam \
	    > ${plink_set}_${pheno}.filter

	# filter to analysis subset
	plink2 \
		--bfile ${plink_set} \
		--make-bed \
		--keep ${plink_set}_${pheno}.filter \
		--memory ${SLURM} \
		--out ${plink_set}_${pheno}

	# prune related individuals
	plink2 \
		--bfile ${plink_set}_${pheno} \
		--king-cutoff 0.125 \
		--make-bed \
		--out ${plink_set}_${pheno}_unrelated \
		--memory ${SLURM}

	# kinship matrix
	/cluster/home/ncochran/bin/gemma-0.98.5-linux-static-AMD64 \
		-bfile ${plink_set}_${pheno}_unrelated \
		-gk 2 \
		-maf 0.005 \
		-o ${plink_set}_${pheno}_unrelated \
		-outdir kinship_unrelated
fi