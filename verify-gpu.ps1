# verify-gpu.ps1 - Verify Blackwell GPU compatibility for 3DGS
# Usage: .\verify-gpu.ps1 [-Quiet]

param(
    [switch]$Quiet
)

function Write-Status {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host $Message
    }
}

Write-Host "=== Blackwell GPU Verification ===" -ForegroundColor Cyan
Write-Host ""

# Overall status
$overallStatus = 0

# Step 1: Check PyTorch installation
Write-Host "Step 1: Checking PyTorch installation..." -ForegroundColor Yellow
try {
    $pytorchVersion = python -c "import torch; print(torch.__version__)"
    $cudaAvailable = python -c "import torch; print(torch.cuda.is_available())"
    Write-Status "✓ PyTorch installed"
    Write-Status "  PyTorch version: $pytorchVersion"
    Write-Status "  CUDA available: $cudaAvailable"
} catch {
    Write-Status "ERROR: PyTorch not installed. Install with:"
    Write-Status "  python -m venv gs-env && .\gs-env\Scripts\activate"
    Write-Status "  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"
    $overallStatus = 1
}
Write-Host ""

# Step 2: Verify CUDA version
Write-Host "Step 2: Verifying CUDA version..." -ForegroundColor Yellow
try {
    $cudaVersion = python -c "import torch; print(torch.version.cuda)"
    if ($cudaVersion -eq "12.6") {
        Write-Status "✓ CUDA 12.6 confirmed"
    } else {
        Write-Status "✗ CUDA version: $cudaVersion (expected 12.6)"
        $overallStatus = 1
    }
} catch {
    Write-Status "⚠ CUDA check failed"
}
Write-Host ""

# Step 3: Verify GPU model
Write-Host "Step 3: Verifying GPU model..." -ForegroundColor Yellow
try {
    if ($cudaAvailable -eq "True") {
        $gpuName = python -c "import torch; print(torch.cuda.get_device_name(0))"
        Write-Status "  GPU: $gpuName"
        if ($gpuName -match "RTX 5060") {
            Write-Status "✓ RTX 5060 confirmed"
        } else {
            Write-Status "✗ GPU is not RTX 5060"
            $overallStatus = 1
        }
    } else {
        Write-Status "⚠ No GPU detected (CPU mode)"
        $overallStatus = 1
    }
} catch {
    Write-Status "⚠ GPU check failed"
}
Write-Host ""

# Step 4: Verify VRAM
Write-Host "Step 4: Verifying VRAM..." -ForegroundColor Yellow
try {
    if ($cudaAvailable -eq "True") {
        $totalVRAM = python -c "import torch; print(torch.cuda.get_device_properties(0).total_memory / 1024**3)"
        $totalVRAMInt = [int]$totalVRAM
        Write-Status "  Total VRAM: ${totalVRAM} GB"
        if ($totalVRAMInt -ge 12) {
            Write-Status "✓ VRAM >= 12GB confirmed"
        } else {
            Write-Status "✗ VRAM ${totalVRAM}GB < 12GB minimum"
            $overallStatus = 1
        }
    } else {
        Write-Status "⚠ Cannot determine VRAM (no GPU)"
        $overallStatus = 1
    }
} catch {
    Write-Status "⚠ VRAM check failed"
}
Write-Host ""

# Step 5: Verify compute capability
Write-Host "Step 5: Verifying compute capability..." -ForegroundColor Yellow
try {
    if ($cudaAvailable -eq "True") {
        $capability = python -c "import torch; print(torch.cuda.get_device_capability(0))"
        $major = $capability[1]
        $minor = $capability[3]
        Write-Status "  Compute capability: $major.$minor"
        if ($major -eq "1" -and $minor -eq "2") {
            Write-Status "✓ Compute capability 12.0 confirmed (Blackwell)"
        } else {
            Write-Status "✗ Compute capability $major.$minor != 12.0 (expected for Blackwell)"
            $overallStatus = 1
        }
    } else {
        Write-Status "⚠ Cannot determine compute capability (no GPU)"
        $overallStatus = 1
    }
} catch {
    Write-Status "⚠ Compute capability check failed"
}
Write-Host ""

# Summary
Write-Host "=== Verification Summary ===" -ForegroundColor Cyan
if ($overallStatus -eq 0) {
    Write-Status "✓ All checks passed! Ready for 3DGS training."
    Write-Status ""
    Write-Status "Next steps:"
    Write-Status "  1. Train: .\train.ps1 -DataPath <path> -OutputPath <output_dir>"
    Write-Status "  2. Export: .\export.ps1 -ConfigPath <config_path> -OutputPath <output_ply>"
    Write-Status "  3. View: https://super.splat3d.com"
} else {
    Write-Status "✗ Some checks failed. Please fix before training."
    Write-Status ""
    Write-Status "Troubleshooting:"
    Write-Status "  - Install PyTorch: python -m venv gs-env && .\gs-env\Scripts\activate && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"
    Write-Status "  - Check GPU: nvidia-smi"
    Write-Status "  - Check CUDA: nvcc --version"
    Write-Status "  - For Blackwell (RTX 5060), use patched 3DGS with -DCMAKE_CUDA_ARCHITECTURES=""120"""
}

exit $overallStatus
