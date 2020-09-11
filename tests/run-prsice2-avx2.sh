#!/bin/sh
set -euo pipefail

gts_nsamps="$1"
gts_nloci="$2"
score_nvars="$3"

gts_infile="../data/1000g_v20130502.${gts_nloci}_loci.${gts_nsamps}_samples.split.vcf.gz"
score_infile="../data/score_${score_nvars}.score.prsice2.base"

mkdir -p tmp
tmpfile=$(mktemp tmp/prsice2.XXXXXX)

bcftools norm -m- -O z -o "${tmpfile}.vcf.gz" "$gts_infile" 2>/dev/null >/dev/null
../software/plink2/plink2_avx2 --vcf "${tmpfile}.vcf.gz" --make-bed --out "$tmpfile" 2>/dev/null >/dev/null
../software/prsice2/PRSice_avx2 -b "${score_infile}" -t "$tmpfile" --no-clump --no-regress 2>/dev/null >/dev/null

rm -f "$tmpfile"* PRSice.all_score PRSice.log PRSice.mismatch PRSice.prsice
