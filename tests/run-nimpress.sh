#!/bin/sh
set -euo pipefail

gts_nsamps="$1"
gts_nloci="$2"
score_nvars="$3"

gts_infile="../data/1000g_v20130502.${gts_nloci}_loci.${gts_nsamps}_samples.bcf"
score_infile="../data/score_${score_nvars}.score"

../software/nimpress/nimpress "$score_infile" "$gts_infile" >/dev/null 2>/dev/null
