#!/bin/bash
set -euo pipefail

# Expects the following environment variables:
# infile
# varlist
# samplelist
# outprefix

bcftools view -S "${samplelist}" -O v -v snps,indels,mnps "${infile}" | \
  awk -v varfile="${varlist}" -f <(cat - <<-'ENDOFSCRIPT'
    BEGIN {
      FS="\t"
      OFS="\t"
      print "Reading variants" > "/dev/stderr"
      while ((getline varline < varfile) > 0) {
        split(varline, varparts, "\t")
        vars[varparts[1]] = 1
      }
      print "Done" > "/dev/stderr"
    }

    /^#/;

    (vars[$1 ":" $2 ":" $4 ":" $5] == 1);

    (NR % 1000000 == 0) {
      print NR > "/dev/stderr"
    }
ENDOFSCRIPT
) | bcftools view -a -O b > "${outprefix}.bcf"

bcftools index "${outprefix}.bcf"
bcftools view -O z "${outprefix}.bcf" > "${outprefix}.vcf.gz"
bcftools index "${outprefix}.vcf.gz"
tabix "${outprefix}.vcf.gz"

# Split vcf for PLINK
bcftools norm -m- "${outprefix}.bcf" -o "${outprefix}.split.vcf.gz" -O z
bcftools index "${outprefix}.split.vcf.gz"
tabix "${outprefix}.split.vcf.gz"

touch "${outprefix}.done"
