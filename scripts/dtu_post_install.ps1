#!/usr/bin/env pwsh

# Prepare the installation procedure
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Load conda's PowerShell hook from the newly installed prefix and
# activate the base environment at that same prefix.
& Join-Path "$Env:CONDA_PREFIX" "\shell\condabin\conda-hook.ps1"
conda activate "$Env:CONDA_PREFIX"

# Initialize conda for all supported shells on this machine.
conda init --all

# Create PEP 668 EXTERNALLY-MANAGED marker to block pip/uv/poetry in base.
# On Windows the base environment keeps the standard library directly in
# <PREFIX>\Lib, so the marker is not placed in a version-specific subfolder.
$MarkerFile = Join-Path "$Env:CONDA_PREFIX" "Lib\EXTERNALLY-MANAGED"

$MarkerContent = @'
[externally-managed]
Error=This base environment is frozen and cannot be modified.

To control packages please create a new environment:

  conda create -n myproject python=3.14 <your-packages>
  conda activate myproject

For more information, have a look here:
https://pythonsupport.dtu.dk/learn-more/packages-and-environments/environments.html
'@

Set-Content -Path $MarkerFile -Value $MarkerContent -Encoding utf8
