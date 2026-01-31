###
### Rscript to run the main tractor mix pipeline by chromosome
###
### be sure to update paths and naming convention for all input files, output file, and the null model
###

args <- commandArgs(trailingOnly = TRUE)
print(args)


chr <- args[1]
slurm_cores <- as.integer(args[2])

input_anc0 <- paste0("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_", chr, "_ftd_unrelated.phased.anc0.dosage.txt")
input_anc1 <- paste0("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_", chr, "_ftd_unrelated.phased.anc1.dosage.txt")
input_anc2 <- paste0("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/extract_tracts_ftd_unrelated/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_", chr, "_ftd_unrelated.phased.anc2.dosage.txt")
output_file <- paste0("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/tractor_mix_ftd_unrelated_AC5_country_project_PC1-10/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_", chr, "_ftd_unrelated_tractor-mix_results_ac5_sex_country_project_pc1-10.tsv")

null_model <- readRDS("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/models/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_ftd_unrelated_null_model_sex_country_project_PC1-10.rds")

source("/cluster/home/jtaylor/software/Tractor-Mix/TractorMix.score.R")

TractorMix.score(obj = null_model, 
                 infiles = c(input_anc0, input_anc1, input_anc2),
                 outfiles = output_file, 
                 AC_threshold = 5)
								 #n_core = slurm_cores)