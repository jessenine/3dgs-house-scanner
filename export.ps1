# export.ps1 - Export trained 3DGS model to PLY format
# Usage: .\export.ps1 -ConfigPath <path> -OutputPath <path>

param(
    [Parameter(Mandatory=$true)][string]$ConfigPath,
    [Parameter(Mandatory=$true)][string]$OutputPath
)

# Convert paths to absolute
$ConfigPath = (Get-Item $ConfigPath).FullName
$OutputPath = (Get-Item $OutputPath).FullName

Write-Host "=== Export 3DGS Model to PLY ===" -ForegroundColor Cyan
Write-Host "Config path: $ConfigPath"
Write-Host "Output path: $OutputPath"
Write-Host ""

# Check if config file exists
if (-not (Test-Path $ConfigPath)) {
    Write-Host "ERROR: Config file not found: $ConfigPath" -ForegroundColor Red
    exit 1
}

# Create output directory
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Export the model
Write-Host "Step 1: Exporting PLY..." -ForegroundColor Yellow
python -m nerfstudio.scripts.export_points --load-config $ConfigPath --output-dir $OutputPath
Write-Host ""

Write-Host "✓ Export complete!" -ForegroundColor Green
Write-Host "Output: $OutputPath"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. View results: Open SuperSplat (https://super.splat3d.com)"
Write-Host "  2. Or use SIBR Viewer (https://github.com/inria/sibr)"
Write-Host "  3. Compress for web: Use SuperSplat's .spz export (~90% smaller)"
