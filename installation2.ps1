# Installation2.ps1
# Run from: PowerShell (Admin is fine, not required after step 1)

function Get-UbuntuDistroName {
    # Prefer the newest Ubuntu if multiple are listed
    $list = wsl -l -q 2>$null
    if (-not $list) { return $null }
    # Typical names: "Ubuntu", "Ubuntu-24.04", "Ubuntu-22.04", "Ubuntu 22.04 LTS"
    $ubuntu = $list | Where-Object { $_ -match '^Ubuntu' } | Sort-Object -Descending | Select-Object -First 1
    if ($ubuntu) { return $ubuntu.Trim() } else { return $null }
}

Write-Host "==> Checking for an existing Ubuntu WSL distribution..." -ForegroundColor Cyan
$distro = Get-UbuntuDistroName

if (-not $distro) {
    Write-Host "==> Installing Ubuntu (latest available)..." -ForegroundColor Cyan
    # This installs the canonical "Ubuntu" package, which is typically the latest LTS
    wsl --install -d Ubuntu

    Write-Host @"
------------------------------------------------------------------------------
A new Ubuntu terminal will launch to complete first-time setup.
Please create your Linux username and password, then close that Ubuntu window.
When finished, return here and press ENTER to continue.
------------------------------------------------------------------------------
"@ -ForegroundColor Yellow
    Pause

    # Re-detect distro after first launch/registration
    $distro = Get-UbuntuDistroName
    if (-not $distro) {
        Write-Error "Ubuntu does not appear to be registered. Run 'wsl -l -v' to diagnose, then rerun this script."
        exit 1
    }
} else {
    Write-Host "==> Found Ubuntu distro: $distro" -ForegroundColor Green
}

Write-Host "==> Updating Ubuntu packages (apt)..." -ForegroundColor Cyan
wsl -d "$distro" -- bash -lc "sudo apt update && sudo apt upgrade -y && sudo apt install -y curl ca-certificates"

Write-Host "==> Installing Miniforge (Conda) the clean, conda-forge-native way..." -ForegroundColor Cyan
$installCmd = @'
set -euo pipefail

# Choose Miniforge (small, clean, conda-forge first)
cd ~
if [ ! -f Miniforge3.sh ]; then
  curl -L -o Miniforge3.sh \
    https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
fi

bash Miniforge3.sh -b -p "$HOME/miniforge3"

# Initialize for bash shells
"$HOME/miniforge3/bin/conda" init bash

# Configure conda defaults
"$HOME/miniforge3/bin/conda" config --set channel_priority strict
"$HOME/miniforge3/bin/conda" config --add channels conda-forge

# Prepend to PATH for this session
export PATH="$HOME/miniforge3/bin:$PATH"

# Install mamba in base
conda install -n base -c conda-forge -y mamba

# Verify
conda --version
mamba --version
'@

wsl -d "$distro" -- bash -lc "$installCmd"

Write-Host "==> Sanity test: create a tiny env and import numpy..." -ForegroundColor Cyan
$testCmd = @'
set -euo pipefail
source ~/.bashrc
export PATH="$HOME/miniforge3/bin:$PATH"
mamba create -n testpy -y python=3.11 numpy
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate testpy
python - << 'PY'
import numpy, sys
print("OK:", "NumPy", numpy.__version__, "| Python", sys.version.split()[0])
PY
'@

wsl -d "$distro" -- bash -lc "$testCmd"

Write-Host "`nAll set! WSL2 + Ubuntu + Conda (Miniforge) + Mamba are ready." -ForegroundColor Green
Write-Host "Tip: open Ubuntu from Start Menu, then 'conda activate base' (auto-activated in new shells)." -ForegroundColor Gray
