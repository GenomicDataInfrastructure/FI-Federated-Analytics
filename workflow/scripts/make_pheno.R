library(tidyverse)
# Debug
#sample_sheet_file="input_files/samples_phenotypes.tsv"
#pheno_columns=c("example_phenotype")
#pheno_file="results/pheno_cov/pheno.pheno"

sample_sheet_file=snakemake@input[["sample_sheet_file"]]
pheno_columns=snakemake@params[["pheno_columns"]]
pheno_file=snakemake@output[["pheno_file"]]
fam_file=snakemake@input[["fam"]]

fam <- read.table(fam_file, header = F)
fid <- fam$V1
sample_sheet<-read_tsv(sample_sheet_file)

colnames(sample_sheet) <- gsub("_", "", colnames(sample_sheet))

pheno=sample_sheet %>%
  select(sample, all_of(pheno_columns))%>%
  mutate(FID=fid, IID=sample)%>%
  select(FID,IID, all_of(pheno_columns))

write_tsv(x=pheno,
          file=pheno_file)
