# manhattan and qq-plots
library(qqman)
library(data.table)
library(R.utils)
library(tidyverse)

font_family <- "Arial"
my_theme <- theme(
  text = element_text(family = font_family),
  plot.title = element_text(face = "bold", size = 25, hjust = 0.5),  # Centered title, bold
  plot.subtitle = element_text(size = 20, hjust = 0.5), # Centered subtitle
  axis.title.x = element_text(size = 20),  # X-axis label
  axis.title.y = element_text(size =20),  # Y-axis label
  axis.text.x = element_text(size = 20),
  axis.text.y = element_text(size = 20),
  legend.text = element_text(size = 20),
  legend.title = element_text(size = 20)
)

in_file=snakemake@input[["merged_assoc"]]
method=snakemake@params[["method"]]
phenotype=snakemake@params[["phenotype"]]
output_prefix=snakemake@params[["output_prefix"]]

# test
# method <- "regenie"
# in_file<-"data/regenie_results/pop12sub2_covid1.regenie.gz"
# phenotype <- "covid1"
# output_prefix<-"pop12sub2_covid1"

df <- data.table::fread(in_file, header = TRUE)

print(paste("input file: ", in_file))
print(paste("phenotype: ", phenotype))
print(paste("method: ", method))
print(paste("dimensions before: ", dim(df)[1], dim(df)[2]))

if (method == "regenie") {
  df <- df %>% mutate(LOG10P = 10^(-LOG10P)) %>% rename(POS = GENPOS, P = LOG10P, AF1 = A1FREQ) %>% filter(!is.na(P))# %>% arrange(P)
}

print(paste("dimensions after: ", dim(df)[1], dim(df)[2]))

######### manhattan ########


png(paste0(output_prefix, "_LOG10P_manhattan.png"), width = 12, height = 6, units = "in", res = 300)
qqman::manhattan(df, main = paste(method, phenotype), chr = "CHROM", bp = "POS", snp = "ID", logp = T, col = c("#ced4da", "#4393C3"))
dev.off()

######## qq ################

# Bin allele frequencies into meaningful categories
df <- df %>%
  mutate(AF_bin = cut(AF1, 
                      breaks = c(0, 0.001, 0.01, 0.05, 1), 
                      labels = c("0-0.001", "0.001-0.01", "0.01-0.05", "0.05-1"), 
                      include.lowest = TRUE))

df <- df %>%
  arrange(P) %>% group_by(AF_bin) %>% 
  mutate(
    observed = -log10(P),
    expected = -log10(ppoints(n())),  # Expected -log10(P) under uniform distribution
    AF_bin = paste0(AF_bin, " (", as.character(n()), " SNPs)")
    )

png(paste0(output_prefix, "_LOG10P_qq.png"), width = 12, height = 6, units = "in", res = 300)
ggplot(df, aes(x = expected, y = observed, color = AF_bin)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
  guides(color = guide_legend(override.aes = list(size = 4))) +
  labs(title = paste(method, phenotype), x = "Expected -log10(P)", y = "Observed -log10(P)", color = "Allele Frequency") +
  theme_minimal() +
  my_theme +
  theme(legend.position = "right")
dev.off()
