# FI-Federated-Analytics

A Snakemake workflow to perform genome-wide association studies. Based on the workflow at https://github.com/Ax-Sch/asso_smk_smpl/tree/main.

## Repository structure
### config 
- config.yaml file to set workflow parameters
### workflow
- Snakefile
- #### envs
    - environments for each rule
- #### scripts
    - R scripts
 
## Input files
- VCF file: one file for each chromosome or one file for the whole genome chr{contig}.merged.annotated.vcf.gz
- Sample sheet: a tsv file containing sample ID, covariates and phenotypes. The sample ID column should be called "sample"
- Pedigree file: pop{popul}_pedigree.fam in PLINK .fam file format

## Running the workflow

### Update config file
- Directory for the input files
- Populations
- Sample sheet filename
- Phenotype and covariate columns in the sample sheet
- Number of PCs to use
- Contigs

### Building the container
Run the command below and save the .sif file in a folder called image

```
singularity build gwas_workflow.sif gwas.def
```

### Run the worfklow
Running the workflow requires Snakemake version 7

```
snakemake --jobs 10 --use-singularity
```

