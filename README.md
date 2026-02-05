A pipeline used to prepare files for Tractor-Mix. Performs phasing with shapeit5 and local ancestry with rfmix2.

1.	Use /cluster/home/jtaylor/scripts/Run_Tractor/run_tractor.sh to generate full phasing and local ancestry outputs. Takes a gzipped vcf and an output directory as arguments. 

2.	Use /cluster/home/jtaylor/scripts/Run_Tractor/plink_processing.sh to filter down to the analysis subtype you are working on, prune related individuals, and generate a standardized kinship matrix. Takes a plink bfile, phenotype string, and a subset file (if filtering down to a specific phenotype). All work is performed in the working directory.

3.	Create a sample list with the resulting unrelated fam file generated from the plink processing (will be used to filter phasing and local ancestry results).

4.	Using /cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/latam5k_ftd_unrelated_null_model_fit_v2_1-25-26.` as an example, make a new script with the correct paths to the new unrelated plink dataset, the kinship matrix, and covariate files, as well as the path for the output null model. *** Be sure to update the formula for the null model to include the covariates you want. *** Be sure to load this micromamba env before running or make sure you have the “GMMAT” and “data.table” R libraries installed: /cluster/home/jtaylor/micromamba/envs/r-env

5.	Filter phasing results to the new unrelated/phenotype individuals. You can use this script as an example: /cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/filter_vcf_for_ftd_and_chr_batch_job.sh I would suggest making a copy of the script in the phasing dir and updating the paths and naming convention. The script is set up to run as a batch, you can submitted using a command like this: sbatch --array [1-22]%6 -o logs/filter_phased-%A_%a.out filter_vcf_for_ftd_and_chr_batch_job.sh /cluster/home/jtaylor/scripts/Run_Tractor/resources/chrs.txt

6.	Filter local ancestry results the new unrelated/phenotype individuals. You can use this script as an example: /cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/filter_map_files_ftd_unrelated.sh Again, I would recommend making a copy of the script and updating paths and naming convention. 

7.	Use Tractor-Mix extract tracts to generate final files for Tractor-Mix GWAS. There are two scripts to do this: 
  a.	/cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/extract_tracts/extract_tracts_ftd_unrelated.sh
  b.	/cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/extract_tracts/run_extract_tracts_ftd_unrelated.sh
Make copies of the files in the directory you want the results in, the update the paths and naming conventions in both. The run_extract_tracts_ftd_unrelated.sh script with run the other, but batch the jobs for chromosome. You may also need to update num-ancs in extract_tracts_ftd_unrelated.sh if you are using anything besides 3 ancestries. This will generate chromosome/ancestry split dosage files for the main Tractor-Mix script.

8.	Run the main Tractor-Mix pipeline using these two scripts:
  a.	/cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/run_tractor_mix.R
  b.	/cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/run_tractor_mix_by_chr.sh
Make copies of the scripts and update paths and naming conventions in both. You will need to update the path to the R script in the shell script too. *** There are some env variables in the shell script that need to be adjusted if you change the memory or cores of the script, there is a comment in the script for this *** You can run this workflow with a command like this: sbatch -o /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/tractor_mix_ftd_unrelated_AC5_site_PC1-10/logs/tractor_mix_run-%A_%a.out /cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/tractor_mix_ftd_unrelated_AC5_site_PC1-10/run_tractor_mix_by_chr.sh /cluster/home/jtaylor/scripts/Run_Tractor/resources/chrs.txt

9.	Combine the chromosome results from Tractor-Mix and filter variants for blacklist and snps only. You can use /cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/combine_and_filter_tractor_mix_results.sh as an example. Make a copy and update paths and naming conventions. This will be final GWAS results.

10.	To generate the ADMIXTURE plot, use the two plots:
  a.	/cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/combine_Q.R
  b.	/cluster/home/jtaylor/scripts/Run_Tractor/example_workflow_scripts/plot_ancestry_proportions.R
Just like the other scripts, make a copy and update paths/naming convention. Run combine Q first to create overall ancestry proportions (chromosome size aware). Then you can plot those results with the other script. You can use the r-env micromamba env for these two scripts as well.
