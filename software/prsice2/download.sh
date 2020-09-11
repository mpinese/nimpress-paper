set -euo pipefail

wget -c https://github.com/choishingwan/PRSice/releases/download/2.3.3/PRSice_linux.zip

unzip PRSice_linux.zip PRSice_linux
mv PRSice_linux "PRSice_linux_2.3.3_20200805"
ln -s "PRSice_linux_2.3.3_20200805" PRSice_avx2

rm PRSice_linux.zip
