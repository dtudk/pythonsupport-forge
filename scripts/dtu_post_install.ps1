#!/usr/bin/env pwsh

# Prepare the installation procedure
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# DEBUG!
$DEBUG_FILE = & Get-Location
Get-ChildItem Env: | Out-File -FilePath $DEBUG_FILE\pis.debug
Get-Variable | Out-File -FilePath $DEBUG_FILE\pis.debug -Append
# DEBUG END!

# Load conda's PowerShell hook from the newly installed prefix and
# activate the base environment at that same prefix.
& Join-Path "$PREFIX" "\shell\condabin\conda-hook.ps1"
conda activate "$PREFIX"

# Initialize conda for all supported shells on this machine.
conda init --all

# Create PEP 668 EXTERNALLY-MANAGED marker to block pip/uv/poetry in base.
# See PEP 668 for details.
$Python_EXE = Join-Path "$PREFIX" "\bin\python"
$Python_STDLIB = & "$Python_EXE" -c "import sysconfig; print(sysconfig.get_path('stdlib', sysconfig.get_default_scheme()))"
$MarkerFile = Join-Path "$Python_STDLIB" "EXTERNALLY-MANAGED"

$MarkerContent = @'
[externally-managed]
Error=This base environment is frozen and cannot be modified.

  To control packages please create a new environment:

    conda create -n myproject python=3.14 <your-packages>
    conda activate myproject

  For more information, have a look here:
  https://pythonsupport.dtu.dk/learn-more/packages-and-environments/environments.html
'@

Set-Content -Path $MarkerFile -Value "$MarkerContent" -Encoding utf8
