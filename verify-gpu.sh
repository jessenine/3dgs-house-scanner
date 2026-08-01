#!/bin/bash
# verify-gpu.sh - Verify Blackwell GPU (RTX 5060) compatibility for 3DGS
# Usage: ./verify-gpu.sh [--quiet]

set -e

# Default values
QUIET=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --quiet    Suppress output, only return exit code"
            echo "  -h, --help Show this help message"
            echo ""
            echo "Verifies:"
            echo "  - PyTorch GPU detection"
            echo "  - CUDA version (must be 12.6)"
            echo "  - GPU name (must contain RTX 5060)"
            echo "  - VRAM (must be >= 12GB for 300-500 photo models)"
            echo "  - Compute capability (must be 12.0 for Blackwell)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper function to display output
display() {
    if [ "$QUIET" = false ]; then
        echo "$1"
    fi
}

# Track overall status
OVERALL_STATUS=0

# Start verification
display "=== Blackwell GPU Verification ==="
display ""

# Step 1: Check PyTorch installation
display "Step 1: Checking PyTorch installation..."
if command -v python3 &> /dev/null; then
    PYTHON_AVAILABLE=true
else
    display "ERROR: python3 not found"
    OVERALL_STATUS=1
    exit 1
fi

# Try importing torch
if ! python3 -c "import torch" 2>/dev/null; then
    display "ERROR: PyTorch not installed. Install with:"
    display "  python3 -m venv gs-env && source gs-env/bin/activate"
    display "  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"
    OVERALL_STATUS=1
    exit 1
fi

PYTORCH_VERSION=$(python3 -c "import torch; print(torch.__version__)")
display "PyTorch version: $PYTORCH_VERSION"

# Step 2: Check CUDA availability
display ""
display "Step 2: Checking CUDA availability..."
CUDA_AVAILABLE=$(python3 -c "import torch; print(torch.cuda.is_available())")

if [ "$CUDA_AVAILABLE" = "True" ]; then
    display "GPU available: YES"
    
    # CUDA version
    CUDA_VERSION=$(python3 -c "import torch; print(torch.version.cuda)")
    display "CUDA version: $CUDA_VERSION"
    
    # GPU name
    GPU_NAME=$(python3 -c "import torch; print(torch.cuda.get_device_name(0))")
    display "GPU name: $GPU_NAME"
    
    # Compute capability
    COMPUTE_CAP=$(python3 -c "import torch; print(torch.cuda.get_device_capability(0))")
    display "Compute capability: $COMPUTE_CAP"
    
    # VRAM
    VRAM=$(python3 -c "import torch; print(f'{torch.cuda.get_device_properties(0).total_memory / 1e9:.1f}')")
    display "VRAM: ${VRAM}GB"
else
    display "GPU available: NO"
    display ""
    display "Note: PyTorch installed but no CUDA GPU detected."
    display ""
    display "For Blackwell (RTX 5060), ensure:"
    display "  1. NVIDIA drivers installed (551+ for Blackwell)"
    display "  2. CUDA toolkit installed"
    display "  3. GPU is properly connected"
    display ""
    display "Check GPU with: nvidia-smi"
    display "Check CUDA with: nvcc --version"
    OVERALL_STATUS=1
fi

# Step 3: Verify CUDA version
display ""
display "Step 3: Verifying CUDA version..."
if [ "$CUDA_AVAILABLE" = "True" ]; then
    if [ "$CUDA_VERSION" = "12.6" ]; then
        display "CUDA version CHECK: PASS (12.6)"
    else
        display "CUDA version CHECK: FAIL (expected 12.6, found $CUDA_VERSION)"
        display ""
        display "Solution: Install PyTorch with cu126:"
        display "  pip uninstall torch torchvision torchaudio"
        display "  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"
        OVERALL_STATUS=1
    fi
else
    display "CUDA version CHECK: SKIP (no GPU)"
fi

# Step 4: Verify GPU name
display ""
display "Step 4: Verifying GPU name..."
if [ "$CUDA_AVAILABLE" = "True" ]; then
    if echo "$GPU_NAME" | grep -qi "RTX 5060"; then
        display "GPU name CHECK: PASS (RTX 5060 detected)"
    else
        display "GPU name CHECK: FAIL (expected RTX 5060, found $GPU_NAME)"
        OVERALL_STATUS=1
    fi
else
    display "GPU name CHECK: SKIP (no GPU)"
fi

# Step 5: Verify VRAM
display ""
display "Step 5: Verifying VRAM..."
if [ "$CUDA_AVAILABLE" = "True" ]; then
    VRAM_INT=$(echo "$VRAM" | cut -d'.' -f1)
    if [ "$VRAM_INT" -ge 12 ]; then
        display "VRAM CHECK: PASS (${VRAM}GB >= 12GB required)"
    else
        display "VRAM CHECK: FAIL (${VRAM}GB < 12GB required)"
        display ""
        display "Warning: Less than 12GB VRAM. May struggle with 300-500 photo models."
        display "Recommendations:"
        display "  - Use fewer photos (100-200)"
        display "  - Use splatfacto-small model"
        display "  - Check for reserved VRAM (close other GPU applications)"
    fi
else
    display "VRAM CHECK: SKIP (no GPU)"
fi

# Step 6: Verify compute capability
display ""
display "Step 6: Verifying compute capability..."
if [ "$CUDA_AVAILABLE" = "True" ]; then
    if [ "$COMPUTE_CAP" = "(12, 0)" ]; then
        display "Compute capability CHECK: PASS (12.0 for Blackwell)"
    else
        display "Compute capability CHECK: FAIL (expected (12, 0), found $COMPUTE_CAP)"
        display ""
        display "Note: Your GPU has compute capability $COMPUTE_CAP."
        display "      3DGS may need patched code for Blackwell (-DCMAKE_CUDA_ARCHITECTURES=\"120\")"
    fi
else
    display "Compute capability CHECK: SKIP (no GPU)"
fi

# Summary
display ""
display "=== Verification Summary ==="

if [ "$OVERALL_STATUS" -eq 0 ]; then
    display ""
    display -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
    display ""
    display "Your system is ready for 3DGS training with Blackwell GPU."
    display ""
    display "Next steps:"
    display "  1. Prepare 300-500 photos (60-70% overlap)"
    display "  2. Run: python3 -m nerfstudio.scripts.process_data <photos> <output> --data-type images"
    display "  3. Train: python3 -m nerfstudio.scripts.train splatfacto --data <output>/data --output-dir <output>/results"
    display "  4. Export: python3 -m nerfstudio.scripts.export --load-config <output>/results/config.yml --output-path <output>/point_cloud"
    display ""
else
    display ""
    display -e "${RED}✗ SOME CHECKS FAILED${NC}"
    display ""
    display "Review the failures above and fix before proceeding."
    display ""
fi

exit $OVERALL_STATUS
