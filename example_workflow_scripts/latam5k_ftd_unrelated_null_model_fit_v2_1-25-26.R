###
### Rscript to generate a null model for Tractor-Mix
###
### be sure to update paths and naming conventions, may have to adjust covariates
###

library(GMMAT)
library(data.table)


fam <- fread("/cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/ftd/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_ftd_unrelated.fam", header = FALSE)
colnames(fam) <- c("FID","IID","PID","MID","SEX_FAM","PHENO_FAM")

fam[, pheno := ifelse(PHENO_FAM == 2, 1, 0)]
fam[, sex := ifelse(SEX_FAM == 2, 1, 0)]

cov <- fread("/cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/ftd/latam5k_ftd_unrelated_site_pc1-10.cov")
country_cov <- fread("/cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/ftd/latam5k_ftd_unrelated_country.cov")
project_cov <- fread("/cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/ftd/latam5k_ftd_unrelated_project.cov")

dat_temp <- merge(fam[, .(FID, IID, pheno, sex)], cov, by = "IID")
dat_temp2 <- merge(dat_temp, country_cov, by = "IID")
dat <- merge(dat_temp2, project_cov, by = "IID")
dat$country <- factor(dat$country)
dat$project <- factor(dat$project)

K <- as.matrix(fread("/cluster/projects/ADFTD/batch_calls/LATAM5k_11-10-25/kinship_unrelated/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_ftd_unrelated.sXX.txt", header = FALSE))

rownames(K) <- fam$IID
colnames(K) <- fam$IID


nullmod <- glmmkin(
  fixed  = pheno ~ sex + country + project + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10,
  data   = dat,
  id     = "IID",
  kins   = K,
  family = binomial()
)

saveRDS(nullmod, "/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/models/LATAM5k_joint_call_11-14-25_dp10_gq20_genotools_ftd_unrelated_null_model_sex_country_project_PC1-10.rds")