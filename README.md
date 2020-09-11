# Analyses in support of the nimpress paper

## Requirements

This has been tested with:

* bcftools 1.9
* htslib 1.9
* R 4.0.0, with packages:
  * ggplot2 3.3.2
  * plyr 1.8.6
  * reshape2 1.4.4
  * svglite 1.2.3.2

All software should be accessible on the system path. Approximately 65 GB of scratch disk space is also required.


## Running

Comparison software (PLINK2, PRSice-2) and input data (1000 genomes project genotypes) are not included in this repo, and must be downloaded and preprocessed first using scripts in this repository. This process is described in the following steps, to be run from the repository root directory (`nimpress-paper`).

1. Download software:
```
cd software/plink2/
bash download.sh
cd ../prsice2
bash download.sh
cd ../..
```
2. Download and process input data:
```
cd data
bash 01_download_1000G.sh
bash 02_gen_testfiles.sh
cd ..
```
3. Perform profiling:
```
cd tests
bash 01_run_tests.sh
bash 02_collate_results.sh
Rscript 03_summarise_results.R
cd..
```

## Contact

Mark Pinese (mpinese@ccia.org.au)

