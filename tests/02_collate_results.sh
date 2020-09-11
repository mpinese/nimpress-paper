#!/bin/bash
set -euo pipefail

head -n1 $(find run1/ -type f -name '*.txt' | head -n1) > run1_results.txt
for f in run1/*.txt; do tail -n+2 $f; done >> run1_results.txt
