#!/bin/bash
set -euo pipefail

# Expects environment variables:
#   gts_nsamps
#   gts_nloci
#   score_nvars
#   method
#   replicate
#   prefix
#   niters
#   outfile

function onexit
{
  if [[ ! -e "${outfile}.done" ]]; then
    touch "${outfile}.term"
  fi
  rm -f "${outfile}.lock"
}
# function is executed when scripts exits
trap onexit EXIT

touch "${outfile}.lock" && rm -f "${outfile}.queued"

function profile
{
  header="$1"
  label="$2"
  comand="$3"
  niters="$4"

  echo -e "$header\titer\telapsed\tuser\tsys\tmem"

  # Memory run
  mem_result=$({ /usr/bin/time -f %M $comand; } 2>&1 )
  echo -e "$label\t0\tNA\tNA\tNA\t${mem_result}"

  # Performance runs
  perf_command="perf stat $comand 2>&1 | tail -n17 | grep -E 'elapsed|user|sys' | sed -E 's/ seconds.*//; s/^ +//' | tr '\n' '\t'"
  for iter in $(seq 1 "$niters"); do
    perf_result=$(eval "$perf_command")
    echo -e "$label\t$iter\t${perf_result}NA"
  done
}

profile \
  "prefix\tmethod\tgts_nsamps\tgts_nloci\tscore_nvars\treplicate\tniters" \
  "${prefix}\t${method}\t${gts_nsamps}\t${gts_nloci}\t${score_nvars}\t${replicate}\t${niters}" \
  "sh run-${method}.sh $gts_nsamps $gts_nloci $score_nvars" \
  "$niters" \
> "$outfile"

touch "${outfile}.done" && rm -f "${outfile}.lock"
