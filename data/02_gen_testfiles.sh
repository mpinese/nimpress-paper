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

# Test for the presence of R
if ! command -v R &> /dev/null; then
  echo "R could not be found. Please install R, ensure it is available on the path, and try again."
  exit 1
fi
if ! R --version | grep -q 'R version 4.0.0'; then
  echo "R version not 4.0.0. Note that this code has only been tested on R v4.0.0"
fi

n_samples=(1e0 2e0 5e0 1e1 2e1 5e1 1e2 2e2 5e2 1e3 2e3)
n_loci=(1e1 1e2 1e3 1e4 1e5 1e6 1e7)

infile="ALL.autosomes.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf"

# 1. Generate sample subsets
bcftools query -l "$infile" > samplelist_all.txt
for n_samples_i in ${n_samples[@]}; do
  head -n $(printf "%.f" "$n_samples_i") samplelist_all.txt > "samplelist_${n_samples_i}.txt"
done

# 2. Generate variant subsets and score files
if [ ! -e variantlist_all.shuf.spdi ]; then
  if [ ! -e variantlist_all.spdi ]; then
    bcftools view -G --min-af 0.01 --max-af 0.99 -v snps,indels,mnps --known "$infile" | \
      bcftools norm -m- | \
      bcftools query -f '%CHROM:%POS:%REF:%ALT\t%ID\n' | \
      awk 'BEGIN {FS="\t";OFS="\t"} { if (seen_rsids[$2] == 0) { print $1, $2; seen_rsids[$2] = 1 }}' \
      > variantlist_all.spdi
  fi
  shuf variantlist_all.spdi > variantlist_all.shuf.spdi
fi
for n_loci_i in ${n_loci[@]}; do
  head -n $(printf "%.f" "$n_loci_i") variantlist_all.shuf.spdi | \
    sort -t':' -k1,1 -k2,2n > "variantlist_${n_loci_i}.spdi"
  echo ${n_loci_i}
  R --vanilla --silent <<- ENDOFSCRIPT
    options(echo = FALSE)
    spdi = read.table(pipe("sed 's/:/\t/g' variantlist_${n_loci_i}.spdi"),
      sep = "\t", header = FALSE, stringsAsFactors = FALSE)
    colnames(spdi) = c("chrom", "pos", "ref", "alts", "id")

    spdi\$eff_allele = sapply(strsplit(spdi\$alts, ","), sample, size = 1)
    spdi\$eff_allele_af = runif(nrow(spdi))
    spdi\$beta = rnorm(nrow(spdi))

    cat(sprintf("Test score %d\nTest score %d\nNo citation\nhs37d5\n0.0\n", nrow(spdi), nrow(spdi)),
      file="score_${n_loci_i}.score")
    cat(paste(sprintf("%s\t%d\t%s\t%s\t%.4f\t%.4f",
        spdi\$chrom, spdi\$pos, spdi\$ref, spdi\$eff_allele, spdi\$beta, spdi\$eff_allele_af), collapse = "\n"),
      file="score_${n_loci_i}.score", append=TRUE)
    cat("\n", file="score_${n_loci_i}.score", append=TRUE)
    cat(paste(sprintf("%s\t%s\t%.4f", spdi\$id, spdi\$eff_allele, spdi\$beta), collapse = "\n"),
      file="score_${n_loci_i}.score.plink.raw")
    cat("\n", file="score_${n_loci_i}.score.plink.raw", append=TRUE)
    cat("CHR\tSNP\tA1\tA2\tMAF\tNCHROBS\n", file="score_${n_loci_i}.score.plink.frq")
    cat(paste(sprintf("%s\t%s\t%s\t%s\t%.4f\t10000", spdi\$chrom, spdi\$id, spdi\$eff_allele, spdi\$ref, spdi\$eff_allele_af), collapse = "\n"),
      file="score_${n_loci_i}.score.plink.frq", append=TRUE)
    cat("\n", file="score_${n_loci_i}.score.plink.frq", append=TRUE)
    cat("#CHROM\tID\tREF\tALT\tALT_FREQS\tOBS_CT\n", file="score_${n_loci_i}.score.plink.afreq")
    cat(paste(sprintf("%s\t%s\t%s\t%s\t%.4f\t10000", spdi\$chrom, spdi\$id, spdi\$ref, spdi\$eff_allele, spdi\$eff_allele_af), collapse = "\n"),
      file="score_${n_loci_i}.score.plink.afreq", append=TRUE)
    cat("\n", file="score_${n_loci_i}.score.plink.afreq", append=TRUE)
    cat("SNP\tA1\tBETA\tP\n", file="score_${n_loci_i}.score.prsice2.base")
    cat(paste(sprintf("%s\t%s\t%.4f\t0", spdi\$id, spdi\$eff_allele, spdi\$beta), collapse = "\n"),
      file="score_${n_loci_i}.score.prsice2.base", append=TRUE)
    cat("\n", file="score_${n_loci_i}.score.prsice2.base", append=TRUE)
ENDOFSCRIPT
done

# 3. Subset infile to each combination of loci and samples
for n_samples_i in ${n_samples[@]}; do
  for n_loci_i in ${n_loci[@]}; do
    if [ ! -e "1000g_v20130502.${n_loci_i}_loci.${n_samples_i}_samples.done" ]; then
      echo "Running ${n_loci_i} loci x ${n_samples_i} samples"
      infile="$infile" varlist="variantlist_${n_loci_i}.spdi" samplelist="samplelist_${n_samples_i}.txt" outprefix="1000g_v20130502.${n_loci_i}_loci.${n_samples_i}_samples" 02_gen_testfiles.subsetgenotypes.sh
    fi
  done
done
