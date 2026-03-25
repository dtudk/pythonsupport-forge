#!/usr/bin/env bash

# Prepare the installation procedure
set -xe

# Now create the yaml files and install details
mamba install --yes pyyaml --channel conda-forge --override-channels

# Now we have the required python packages
if [[ ! -e miniforge/Miniforge3/construct.yaml ]]; then
  echo "Output file not found! Quitting..."
  exit 1
fi
python3 update_yaml.py miniforge/Miniforge3/construct.yaml

