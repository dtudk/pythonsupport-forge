#!/usr/bin/env pwsh

# Prepare the installation procedure
$ErrorActionPreference = 'Stop'

conda env list
conda init

conda info
conda list

# Now create the yaml files and install details
conda install pyyaml --channel conda-forge --yes --quiet

# List information on commands
Get-Command python

# Now we have the required python packages
$OUT = "miniforge\Miniforge3\construct.yaml"
if (-not (Test-Path $OUT)) {
    Write-Output "Output file not found! Quitting..."
    exit 1
}

# Update the constructor yaml file.
python update_yaml.py $OUT

Write-Output "<<< BOF >>>"
Get-Content $OUT
Write-Output "<<< EOF >>>"

# Ensure --override-frozen in test.sh
$TESTSH = "miniforge\scripts\test.sh"
if (Test-Path $TESTSH) {
    (Get-Content $TESTSH).Replace('install r-base',
        'install r-base --override-frozen') | Set-Content $TESTSH
}

# copy over post_install script
Copy-Item scripts\dtu_post_install.ps1 miniforge\Miniforge3\dtu_post_install.ps1
