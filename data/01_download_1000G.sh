#!/bin/bash
set -euo pipefail

# Test for the presence of bcftools
if ! command -v bcftools &> /dev/null; then
  echo "bcftools could not be found. Please install bcftools, ensure it is available on the path, and try again."
  exit 1
fi
if ! bcftools --version | grep -q 'bcftools 1.9'; then
  echo "bcftools version not 1.9. Note that this code has only been tested on bcftools v1.9"
fi

DATA_MIRROR="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp"
#DATA_MIRROR="ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp"

for chrom in $(seq 1 22); do
  if [[ ! -e "ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.done" ]]; then
    wget -cq "${DATA_MIRROR}/release/20130502/ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz" && \
    touch "ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.done"
  fi
  if [[ ! -e "ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi.done" ]]; then
    wget -cq "${DATA_MIRROR}/release/20130502/ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi" && \
    touch "ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi.done"
  fi
done

bcftools concat -O b -o ALL.autosomes.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf $(for chrom in $(seq 1 22); do echo -n " ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz"; done)
bcftools index ALL.autosomes.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf

rm ALL.chr*.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz*
