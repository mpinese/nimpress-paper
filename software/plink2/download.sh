#!/bin/bash

wget -c http://s3.amazonaws.com/plink2-assets/alpha2/plink2_linux_avx2.zip
wget -c http://s3.amazonaws.com/plink2-assets/alpha2/plink2_linux_x86_64.zip

unzip -o plink2_linux_avx2.zip && mv plink2 plink2_linux_avx2_20200124 && rm plink2_linux_avx2.zip
unzip -o plink2_linux_x86_64.zip && mv plink2 plink2_linux_x86_64_20200124 && rm plink2_linux_x86_64.zip

ln -s plink2_linux_avx2_20200124 plink2_avx2
