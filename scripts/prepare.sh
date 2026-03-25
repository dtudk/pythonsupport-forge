#!/usr/bin/env bash

# Prepare the installation procedure
set -xe

conda env list
conda init

conda info
conda list

# Now create the yaml files and install details
conda install --yes pyyaml --channel conda-forge --override-channels

which python3
which python

# Now we have the required python packages
if [[ ! -e miniforge/Miniforge3/construct.yaml ]]; then
  echo "Output file not found! Quitting..."
  exit 1
fi

OUT=miniforge/Miniforge3/construct.yaml
python3 update_yaml.py $OUT

echo "<<< BOF >>>"
cat $OUT
echo "<<< EOF >>>"

