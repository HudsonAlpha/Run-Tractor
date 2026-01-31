library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(grid)
library(ggh4x)

###
### Creates admixture plot
###

glob_wide <- fread("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/local_ancestry/LATAM5k_merged_ancestry_proportions_wide.Q")   # sample AFR AMR EUR
meta      <- fread("/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/LATAM5k_11-14-25_country.tsv")         # sample country

# join,order within each country
df <- glob_wide %>%
  inner_join(meta, by = "sample") %>%
  group_by(country) %>%
  arrange(desc(EUR), desc(AMR), desc(AFR), .by_group = TRUE) %>%
  mutate(x = row_number()) %>%
  ungroup()

# long format for ggplot
df_long <- df %>%
  pivot_longer(cols = c(EUR, AMR, AFR),
               names_to = "ancestry", values_to = "prop") %>%
  mutate(ancestry = factor(ancestry, levels = c("EUR","AMR","AFR")))

cols <- c(
  EUR = "#33A02C",
  AMR = "#1F78B4",
  AFR = "#6A3D9A"
)

p_2 <- ggplot(df_long, aes(x = x, y = prop, fill = ancestry)) +
  geom_col(width = 1) +
  facet_grid(. ~ country, scales = "free_x", space = "free_x", switch = "x") +
  scale_fill_manual(values = cols) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  theme_void(base_size = 12) +
  theme(
    plot.background  = element_rect(fill = "black", color = NA),
    panel.background = element_rect(fill = "black", color = NA),

    panel.spacing.x  = unit(3, "pt"), 
    plot.margin      = margin(t = 8, r = 8, b = 18, l = 8), 

    strip.placement  = "outside",
    strip.text.x     = element_text(color = "white", size = 12), #, margin = margin(t = 4, b = 4)),

    legend.position  = "bottom",
    legend.text      = element_text(color = "white"),
    legend.title     = element_blank()
  )
	
	# minimum panel width in sample-units
	min_n <- 40

	# compute samples per country in the SAME order as your facet levels
	country_counts <- df_long %>%
	  distinct(country, sample) %>%
	  count(country, name = "n")

	# ensure country is a factor with the same levels used in the plot
	country_counts <- country_counts %>%
	  mutate(country = factor(country, levels = levels(df_long$country))) %>%
	  arrange(country)

	col_widths <- pmax(country_counts$n, min_n)

	# build plot
	p_3 <- ggplot(df_long, aes(x = x, y = prop, fill = ancestry)) +
	  geom_col(width = 1) +
	  facet_grid(. ~ country, scales = "free_x", space = "free_x", switch = "x") + 
		scale_fill_manual(values = cols) + 
	  scale_y_continuous(expand = c(0, 0)) +
	  scale_x_continuous(expand = c(0, 0)) +
		labs(
			title = "LATAM5k RFMIX2 Ancestry Proportions"
		) + 
	  theme_void(base_size = 12) +
	  theme(
	    plot.background  = element_rect(fill = "black", color = NA),
	    panel.background = element_rect(fill = "black", color = NA),
	    panel.spacing.x  = unit(3, "pt"),
	    plot.margin      = margin(t = 8, r = 8, b = 18, l = 8),
	    strip.text.x     = element_text(color = "white", size = 12, margin = margin(t = 6, b = 0)),
			plot.title       = element_text(color = "white", size = 14, face = "bold", hjust = 0.5),
	    legend.position  = "bottom",
	    legend.text      = element_text(color = "white"),
	    legend.title     = element_blank()
	  )

	# apply minimum widths
	p_3 <- p_3 + ggh4x::force_panelsizes(cols = unit(col_widths, "null"))


ggsave(
  "/cluster/projects/ADFTD/redlat_paper_2/LATAM5k_12-3-25/tractor/local_ancestry/LATAM5k_global_ancestry_1-12-26.pdf",
  p_3,
  device = cairo_pdf,
  width  = 18,
  height = 3.6, 
  units  = "in"
)