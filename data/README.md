# nimpress_perf/data: Data to support profiling of nimpress

This directory holds genomic data derived from 1000 genomes, for use in profiling `nimpress` relative to other tools.

As the files in this directory are large they are not stored on the repository. Instead the repository holds scripts which can be used to download and process the 1000 genomes data to generate the required files.

# Regenerating the profiling input data

## Prerequisites

The code requires the following to be installed and in the system path:

* bcftools 1.9
* htslib 1.9
* R 4.0.0

It also requires approximately 65 GB of scratch space.

## Running

Execute in order:
```
01_download_1000G.sh
02_gen_testfiles.sh
```
