#!/bin/bash

#SBATCH -p normal
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --job-name run_extract_tracts_ftd
#SBATCH -o /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated/logs/run_extract_tracts.out

###
### Example script for running the extract tracts part of Tractor-Mix workflow.
###
### Make a copy of this script in the directory you want to run it in and update paths.
### script takes care of sbatching extract tracts jobs by chromosome
###

sbatch \
	--array [1-22]%6 \
	-o /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated/logs/extract_tracts-%A_%a.out \
	/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated/extract_tracts_ftd_unrelated.sh \
	/cluster/home/jtaylor/scripts/Run_Tractor/resources/chrs.txt