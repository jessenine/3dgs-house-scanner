# process-data.ps1 - Process photos with COLMAP SfM
# Usage: .\process-data.ps1 -PhotoPath <path> -OutputPath <path> [-DataType <images|video>] [-NumThreads <int>]

param(
    [Parameter(Mandatory=$true)][string]$PhotoPath,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [string]$DataType = "images",
    [int]$NumThreads = 8
)

# Convert paths to absolute
$PhotoPath = (Get-Item $PhotoPath).FullName
$OutputPath = (Get-Item $OutputPath).FullName

Write-Host "=== Process Data with COLMAP ===" -ForegroundColor Cyan
Write-Host "Photo path: $PhotoPath"
Write-Host "Output path: $OutputPath"
Write-Host "Data type: $DataType"
Write-Host "Threads: $NumThreads"
Write-Host ""

# Check if photo directory exists
if (-not (Test-Path $PhotoPath)) {
    Write-Host "ERROR: Photo directory not found: $PhotoPath" -ForegroundColor Red
    exit 1
}

# Count photos
$photoCount = (Get-ChildItem -Path $PhotoPath -File -Include *.jpg,*.jpeg,*.png | Measure-Object).Count
Write-Host "Found $photoCount photos"
Write-Host ""

# Create output directory
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Export COLMAP data
Write-Host "Step 1: Exporting COLMAP data..." -ForegroundColor Yellow
python -m nerfstudio.scripts.process_data --data $PhotoPath --output-dir $OutputPath --num-downscale 4 --num-threads $NumThreads
Write-Host ""

Write-Host "✓ Data processing complete!" -ForegroundColor Green
Write-Host "Output: $OutputPath\sparse\0 and $OutputPath\dense\0"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Train model: .\train.ps1 -DataPath $OutputPath -OutputPath <output_dir>"
Write-Host "  2. Export PLY: .\export.ps1 -ConfigPath <config_path> -OutputPath <output_ply>"
