#!/usr/bin/env pwsh

# Prepare the installation procedure
$ErrorActionPreference = 'Stop'

conda env list
conda init

conda info
conda list

# Now create the yaml files and install details
conda install --yes pyyaml --channel conda-forge --override-channels

# List information on commands
Get-Command python

# Now we have the required python packages
$OUT = "miniforge/Miniforge3/construct.yaml"
if (-not (Test-Path $OUT)) {
    Write-Output "Output file not found! Quitting..."
    exit 1
}

python update_yaml.py $OUT

Write-Output "<<< BOF >>>"
Get-Content $OUT
Write-Output "<<< EOF >>>"

# copy over post_install script
Copy-Item scripts/dtu_post_install.ps1 miniforge/Miniforge3/dtu_post_install.ps1
