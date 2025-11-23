# PowerShell developer setup script for ZUBID backend
# Usage (PowerShell):
#   .\scripts\setup_dev.ps1

$venvPath = "$PSScriptRoot\..\.venv"
Write-Host "Creating virtual environment at $venvPath"
python -m venv $venvPath

$pythonExe = Join-Path $venvPath 'Scripts\python.exe'
$ruffExe = Join-Path $venvPath 'Scripts\ruff.exe'

Write-Host "Upgrading pip and tools"
& $pythonExe -m pip install --upgrade pip setuptools wheel

Write-Host "Installing backend requirements and ruff"
& $pythonExe -m pip install -r "$PSScriptRoot\..\backend\requirements.txt" ruff

Write-Host "Running ruff to auto-fix style issues"
& $ruffExe check "$PSScriptRoot\..\backend" --fix

Write-Host "Running unit tests"
& $pythonExe "$PSScriptRoot\..\backend\test_production.py"

Write-Host "Setup complete. To activate the venv manually run:`n  .\.venv\Scripts\Activate.ps1`"
