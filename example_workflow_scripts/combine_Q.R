library(data.table)
library(dplyr)
library(tidyr)

###
### Rscript to combine ancestry proportion chromosome files and create a total ancestry proportion file for each individual.
###
### script is chromosome size aware
### be sure to update path and naming convention for the q files

# read chromosome lengths
clen <- fread("/cluster/home/jtaylor/scripts/Run_Tractor/chr_lengths.tsv")        # columns: chr, length

# make sure chr matches your Q filenames (1..22, "1".. "22", etc.)
clen[, chr := as.integer(chr)]

# list Q files
q_files <- sprintf("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/local_ancestry/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_chr%d.deconvoluted.rfmix.Q", 1:22)

# read all Q files and attach chromosome index
q_list <- lapply(seq_along(q_files), function(i) {
  f <- q_files[i]
  dt <- fread(f, skip = 2)          # skips the two header lines
  setnames(dt, c("sample", "AFR", "AMR", "EUR"))
  dt[, chr := i]                         # 1..22 in same order as clen
  dt
})

q_all <- rbindlist(q_list)

# merge in chromosome lengths
q_all <- merge(q_all, clen, by.x = "chr", by.y = "chr")

# long format: one row per sample × chr × ancestry
q_long <- melt(
  q_all,
  id.vars = c("sample", "chr", "length"),
  measure.vars = c("AFR", "AMR", "EUR"),
  variable.name = "ancestry",
  value.name   = "prop_chr"
)

# compute length-weighted global ancestry:
# global proportion = sum( prop_chr * chr_length ) / sum( chr_length )
glob_long <- q_long %>%
  group_by(sample, ancestry) %>%
  summarise(
    weighted_sum = sum(prop_chr * length),
    total_len    = sum(length),
    .groups = "drop_last"
  ) %>%
  mutate(prop = weighted_sum / total_len) %>%
  ungroup() %>%
  select(sample, ancestry, prop)
	
fwrite(glob_long, file = "/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/local_ancestry/LATAM5k_merged_ancestry_proportions_long_three_anc.Q", sep = "\t")

# wide format: one row per sample × AFR x AMR x EUR
glob_wide <- glob_long %>% 
	tidyr::pivot_wider(names_from = ancestry, values_from = prop) %>% 
	arrange(sample)
	
fwrite(glob_wide, file = "/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/local_ancestry/LATAM5k_merged_ancestry_proportions_wide_three_anc.Q", sep = "\t")

qc <- glob_wide %>% 
	mutate(sum_props = AFR + AMR + EUR) %>% 
	summarise(min_sum = min(sum_props), max_sum = max(sum_props))

print(qc)