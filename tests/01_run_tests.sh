#!/bin/bash
set -euo pipefail

run_id="run1"

if [[ "$run_id" == "run1" ]]; then
  n_samples=(1e0 1e1 1e2 1e3)
  n_loci_gts=(1e7)
  n_loci_scores=(1e1 1e2 1e3 1e4)
  methods=(nimpress plink2-avx2 prsice2-avx2)
  replicates=$(seq 1 5)
  niters=6
else
  echo "Unknown run ID $run_id" > /dev/stderr
  exit 1
fi

mkdir -p "$run_id"

for gts_nloci in ${n_loci_gts[@]}; do
  for score_nvars in ${n_loci_scores[@]}; do
    gts_nloci_int=$(printf "%.f" "$gts_nloci")
    score_nvars_int=$(printf "%.f" "$score_nvars")
    if [[ $score_nvars_int -le $gts_nloci_int ]]; then
      for gts_nsamps in ${n_samples[@]}; do
        for method in ${methods[@]}; do
          for replicate in ${replicates[@]}; do
            run_name="np.${run_id}.${method}.${gts_nsamps}.${gts_nloci}.${score_nvars}.${replicate}.${niters}"
            outfile="${run_id}/${method}-${gts_nsamps}-${gts_nloci}-${score_nvars}-${replicate}-${niters}.txt"

            if [[ -e "${outfile}.done" ]]; then
              echo "${run_name} already done."
            elif [[ -e "${outfile}.queued" ]]; then
              echo "${run_name} already in queue."
            elif [[ -e "${outfile}.lock" ]]; then
              echo "${run_name} running."
            elif [[ -e "${outfile}.term" ]]; then
              echo "${run_name} terminated."
            else
              prefix="${run_id}/" gts_nsamps="$gts_nsamps" gts_nloci="$gts_nloci" score_nvars="$score_nvars" method="$method" replicate="$replicate" niters="$niters" outfile="$outfile" bash run_test.sh
            fi
          done
        done
      done
    fi
  done
done

