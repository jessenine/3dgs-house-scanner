# train.ps1 - Train 3DGS model with Splatfacto
# Usage: .\train.ps1 -DataPath <path> -OutputPath <path> [-MaxIterations <int>] [-Model <splatfacto|splatfacto-small>] [-NumWorkers <int>]

param(
    [Parameter(Mandatory=$true)][string]$DataPath,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [int]$MaxIterations = 30000,
    [string]$Model = "splatfacto",
    [int]$NumWorkers = 4
)

# Convert paths to absolute
$DataPath = (Get-Item $DataPath).FullName
$OutputPath = (Get-Item $OutputPath).FullName

Write-Host "=== Training 3DGS Model with Splatfacto ===" -ForegroundColor Cyan
Write-Host "Data path: $DataPath"
Write-Host "Output path: $OutputPath"
Write-Host "Model: $Model"
Write-Host "Iterations: $MaxIterations"
Write-Host "Workers: $NumWorkers"
Write-Host ""

# Check if data directory exists
if (-not (Test-Path $DataPath)) {
    Write-Host "ERROR: Data directory not found: $DataPath" -ForegroundColor Red
    exit 1
}

# Estimate VRAM (0.5-1 GB per 100 photos)
$photoCount = (Get-ChildItem -Path $DataPath -File -Include *.jpg,*.jpeg,*.png | Measure-Object).Count
$estimatedVRAM = [math]::Ceiling($photoCount / 100 * 1.5)
Write-Host "Estimated VRAM requirement: ~$estimatedVRAM GB"
Write-Host ""

# Create output directory
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Train the model
Write-Host "Step 1: Starting training..." -ForegroundColor Yellow
Write-Host "Web UI will be available at: http://localhost:7562"
Write-Host ""

nerfstudio train $Model --data $DataPath --output-dir $OutputPath --max-iterations $MaxIterations --num-workers $NumWorkers

Write-Host ""
Write-Host "✓ Training complete!" -ForegroundColor Green
Write-Host "Output: $OutputPath"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Export PLY: .\export.ps1 -ConfigPath $OutputPath\config.yml -OutputPath <output_ply>"
Write-Host "  2. View results: Open SuperSplat or SIBR Viewer"
