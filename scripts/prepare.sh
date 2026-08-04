#!/usr/bin/env bash

# Prepare the installation procedure
set -xe

conda env list
conda init

conda info
conda list

# Now create the yaml files and install details
conda install pyyaml --channel conda-forge --yes --quiet

which python3
which python

# Now we have the required python packages
OUT=miniforge/Miniforge3/construct.yaml
if [[ ! -e $OUT ]]; then
  echo "Output file not found! Quitting..."
  exit 1
fi

python3 update_yaml.py $OUT

echo "<<< BOF >>>"
cat $OUT
echo "<<< EOF >>>"

# copy over post_install script 
cp scripts/dtu_post_install.sh miniforge/Miniforge3/dtu_post_install.sh
