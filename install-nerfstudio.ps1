# install-nerfstudio.ps1 - Install Nerfstudio with cu126 for Blackwell GPU support
# Usage: .\install-nerfstudio.ps1 [-VenvPath <path>] [-NerfstudioSource <path>]

param(
    [string]$VenvPath = "gs-env",
    [string]$NerfstudioSource = "nerfstudio"
)

Write-Host "=== Nerfstudio Installation Script ===" -ForegroundColor Cyan
Write-Host "Virtual environment: $VenvPath"
Write-Host "Nerfstudio source: $NerfstudioSource"
Write-Host ""

# Step 1: Check Python version
Write-Host "Step 1: Checking Python version..." -ForegroundColor Yellow
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: python not found. Please install Python 3.10+"
    exit 1
}
$pythonVersion = python --version 2>&1
Write-Host "Python version: $pythonVersion"
Write-Host ""

# Step 2: Create virtual environment
Write-Host "Step 2: Creating virtual environment..." -ForegroundColor Yellow
if (-not (Test-Path $VenvPath)) {
    python -m venv $VenvPath
    Write-Host "Created virtual environment: $VenvPath" -ForegroundColor Green
} else {
    Write-Host "Virtual environment already exists: $VenvPath"
}
Write-Host ""

# Step 3: Activate virtual environment
Write-Host "Step 3: Activating virtual environment..." -ForegroundColor Yellow
$activatePath = Join-Path $VenvPath "Scripts\Activate.ps1"
if (Test-Path $activatePath) {
    & $activatePath
    Write-Host "Virtual environment activated" -ForegroundColor Green
} else {
    Write-Host "ERROR: Activate.ps1 not found at $activatePath"
    exit 1
}
Write-Host ""

# Step 4: Upgrade pip, setuptools, wheel
Write-Host "Step 4: Upgrading pip, setuptools, wheel..." -ForegroundColor Yellow
pip install --upgrade pip setuptools wheel
Write-Host ""

# Step 5: Install PyTorch with cu126 for Blackwell support
Write-Host "Step 5: Installing PyTorch cu126..." -ForegroundColor Yellow
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
Write-Host ""

# Step 6: Install Nerfstudio
Write-Host "Step 6: Installing Nerfstudio..." -ForegroundColor Yellow
if (Test-Path $NerfstudioSource) {
    Push-Location $NerfstudioSource
    pip install -e .
    Pop-Location
} else {
    git clone https://github.com/nerfstudio-project/nerfstudio.git $NerfstudioSource
    Push-Location $NerfstudioSource
    pip install -e .
    Pop-Location
}
Write-Host ""

# Step 7: Install COLMAP
Write-Host "Step 7: Installing COLMAP..." -ForegroundColor Yellow
pip install colmap
Write-Host ""

# Verify installation
Write-Host "=== Verification ===" -ForegroundColor Cyan
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU: {torch.cuda.get_device_name(0)}')" 2>$null
Write-Host ""

Write-Host "✓ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Navigate to your photo directory with 300-500 images"
Write-Host "  2. Run: .\process-data.ps1 -PhotoPath <path> -OutputPath <path>"
Write-Host "  3. Run: .\train.ps1 -DataPath <path> -OutputPath <path>"
Write-Host "  4. Run: .\export.ps1 -ConfigPath <path> -OutputPath <path>"
Write-Host "  5. Open web UI at: http://localhost:7562"
Write-Host ""
