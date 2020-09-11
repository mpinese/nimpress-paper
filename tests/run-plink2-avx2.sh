#!/bin/sh
set -euo pipefail

gts_nsamps="$1"
gts_nloci="$2"
score_nvars="$3"

gts_infile="../data/1000g_v20130502.${gts_nloci}_loci.${gts_nsamps}_samples.vcf.gz"
score_infile="../data/score_${score_nvars}.score.plink.raw"
frq_infile="../data/score_${score_nvars}.score.plink.frq"

mkdir -p tmp
tmpfile=$(mktemp tmp/plink.XXXXXX)

../software/plink2/plink2_avx2 --vcf "$gts_infile" --read-freq "$frq_infile" --score "$score_infile" --out "$tmpfile" 2>/dev/null >/dev/null

rm -f "$tmpfile"*
