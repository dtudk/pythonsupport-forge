
conda env list
conda init

conda info
conda list

# Now create the yaml files and install details
conda install --yes pyyaml --channel conda-forge --override-channels

which python3
which python

# Now we have the required python packages
$OUT=miniforge/Miniforge3/construct.yaml
if (Test-Path $OUT) {
  Write-Warning "Output file not found! Quitting..."
  Exit
}

python3 update_yaml.py $OUT

Write-Host "<<< BOF >>>"
cat $OUT
Write-Host "<<< EOF >>>"

