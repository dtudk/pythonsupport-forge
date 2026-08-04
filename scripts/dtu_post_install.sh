#!/usr/bin/env bash

set -euo pipefail

# Load conda shell functions from the newly installed prefix and
# activate the base environment at that same prefix.
source "${PREFIX}/etc/profile.d/conda.sh" && conda activate "${PREFIX}"

# Initialize conda for all supported shells on this machine.
conda init --all

# Create PEP 668 EXTERNALLY-MANAGED marker to block pip/uv/poetry in base
# See PEP 668 for details.
STDLIB_PATH=$("${PREFIX}/bin/python" -c "import sysconfig; print(sysconfig.get_path('stdlib', sysconfig.get_default_scheme()))")
MARKER_FILE="${STDLIB_PATH}/EXTERNALLY-MANAGED"

cat > "${MARKER_FILE}" << 'EOF'
[externally-managed]
Error=This base environment is frozen and cannot be modified.

  To control packages please create a new environment:

    conda create -n myproject python=3.14 <your-packages>
    conda activate myproject

  For more information, have a look here:
  https://pythonsupport.dtu.dk/learn-more/packages-and-environments/environments.html
EOF

chmod 644 "${MARKER_FILE}"
