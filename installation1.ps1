# Installation1.ps1
# Run from: PowerShell (Admin)

# 0) Ensure Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please re-run this script in an elevated PowerShell (Run as administrator)."
    exit 1
}

Write-Host "==> Enabling Windows features required by WSL2..." -ForegroundColor Cyan
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null

# Optional: ensure hypervisor autostarts (harmless if already set)
try {
    bcdedit /set hypervisorlaunchtype auto | Out-Null
} catch {
    Write-Host "bcdedit not applied (this is OK on many systems)." -ForegroundColor Yellow
}

Write-Host "==> Updating WSL to the latest package..." -ForegroundColor Cyan
wsl --update

Write-Host "==> Setting WSL2 as the default..." -ForegroundColor Cyan
wsl --set-default-version 2

Write-Host "`n==> A reboot is recommended before continuing." -ForegroundColor Yellow
$answer = Read-Host "Reboot now? (Y/N)"
if ($answer -match '^[Yy]') {
    Restart-Computer
} else {
    Write-Host "Please reboot manually before running Installation2.ps1" -ForegroundColor Yellow
}
