# Extract frames from video for 3DGS training
# Usage: .\extract-frames.ps1 -VideoPath "C:\video.mp4" -OutputPath "C:\frames"
#        .\extract-frames.ps1 -VideoPath "..\video.mp4" -OutputPath "..\frames"
#        .\extract-frames.ps1 -VideoPath "video.mp4" -OutputPath "frames"  (uses current dir)

param(
    [Parameter(Mandatory=$true)]
    [string]$VideoPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
)

# Convert paths to standard Windows paths
# This handles:
# 1. PowerShell provider paths: Microsoft.PowerShell.Core\FileSystem::path
# 2. Relative paths: ..\video.mp4
# 3. Absolute paths: C:\path\to\file.mp4
function Convert-ToWindowsPath {
    param([string]$Path)
    
    # First, check if this is a PowerShell provider path (contains ::)
    # Provider paths look like: Microsoft.PowerShell.Core\FileSystem::\\server\path
    if ($Path.Contains("::")) {
        # Split on :: to get just the file system path
        $parts = $Path -split "::", 2
        if ($parts.Count -ge 2) {
            return $parts[1]
        }
    }
    
    # Handle relative paths
    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        return Join-Path -Path (Get-Location).Path -ChildPath $Path
    }
    
    # Already an absolute path, return as-is
    return $Path
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Extracting Frames from Video" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Video path: $VideoPath" -ForegroundColor DarkGray
Write-Host "Output path: $OutputPath" -ForegroundColor DarkGray
Write-Host ""

# Convert paths
$VideoPathAbs = Convert-ToWindowsPath $VideoPath
$OutputPathAbs = Convert-ToWindowsPath $OutputPath

Write-Host "Using video: $VideoPathAbs" -ForegroundColor Green
Write-Host "Output to: $OutputPathAbs" -ForegroundColor Green
Write-Host ""

# Check if video file exists
if (-not (Test-Path $VideoPathAbs)) {
    Write-Host "ERROR: Video file not found: $VideoPathAbs" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage: .\extract-frames.ps1 -VideoPath `"C:\path\to\video.mp4`" -OutputPath `"C:\path\to\frames`""
    Write-Host "Example: .\extract-frames.ps1 -VideoPath `"C:\photos\IMG_0471.MOV`" -OutputPath `"C:\photos\frames`""
    Write-Host ""
    Write-Host "Supports relative paths: .\extract-frames.ps1 -VideoPath `"video.mp4`" -OutputPath `"frames`""
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPathAbs)) {
    New-Item -ItemType Directory -Path $OutputPathAbs | Out-Null
}

# Check if ffmpeg is installed
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "ffmpeg not found. Installing..."
    winget install --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements | Out-Null
    if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Failed to install ffmpeg. Please install manually." -ForegroundColor Red
        exit 1
    }
}

# Extract 1 frame every 0.25 seconds (4 FPS)
Write-Host "Extracting frames..."
ffmpeg -i "$VideoPathAbs" -vf "fps=4" -q:v 2 "$OutputPathAbs\frame_%04d.jpg"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "  ERROR: Frame extraction failed!" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Video file: $VideoPathAbs"
    Write-Host "Output folder: $OutputPathAbs"
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Extraction complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "Frames saved to: $OutputPathAbs"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Process frames with: python -m nerfstudio.scripts.process_data <frames> <output>"
Write-Host "  2. Train with: python -m nerfstudio.scripts.train splatfacto <options>"
Write-Host ""
