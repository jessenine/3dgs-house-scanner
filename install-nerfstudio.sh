#!/bin/bash
# install-nerfstudio.sh - Install Nerfstudio with cu126 for Blackwell GPU support
# Usage: ./install-nerfstudio.sh [-v <venv_path>] [-n <nerfstudio_source>]

set -e

# Default values
VENV_PATH="gs-env"
NERFSTUDIO_SOURCE="nerfstudio"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--venv-path)
            VENV_PATH="$2"
            shift 2
            ;;
        -n|--nerfstudio-source)
            NERFSTUDIO_SOURCE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-v <venv_path>] [-n <nerfstudio_source>]"
            echo "  -v, --venv-path     Virtual environment path (default: gs-env)"
            echo "  -n, --nerfstudio-source  Nerfstudio source directory (default: nerfstudio)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Nerfstudio Installation Script ==="
echo "Virtual environment: $VENV_PATH"
echo "Nerfstudio source: $NERFSTUDIO_SOURCE"
echo ""

# Step 1: Check Python version
echo "Step 1: Checking Python version..."
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not found. Please install Python 3.10+"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo "Python version: $PYTHON_VERSION"
if [[ ! "$PYTHON_VERSION" =~ ^3\.(1[0-9]|[2-9])\. ]]; then
    echo "WARNING: Python 3.10+ recommended, found $PYTHON_VERSION"
fi
echo ""

# Step 2: Create virtual environment
echo "Step 2: Creating virtual environment..."
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    echo "Created virtual environment: $VENV_PATH"
else
    echo "Virtual environment already exists: $VENV_PATH"
fi
echo ""

# Step 3: Activate virtual environment
echo "Step 3: Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Virtual environment activated"
echo ""

# Step 4: Upgrade pip, setuptools, wheel
echo "Step 4: Upgrading pip, setuptools, wheel..."
pip install --upgrade pip setuptools wheel
echo "Upgraded: pip $(pip --version | awk '{print $2}'), setuptools $(pip show setuptools | grep Version | awk '{print $2}'), wheel $(pip show wheel | grep Version | awk '{print $2}')"
echo ""

# Step 5: Install PyTorch with cu126
echo "Step 5: Installing PyTorch with cu126..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
echo "PyTorch installed"
echo "CUDA version: $(python3 -c 'import torch; print(torch.version.cuda)')"
echo ""

# Step 6: Install Nerfstudio
echo "Step 6: Installing Nerfstudio..."
if [ -d "$NERFSTUDIO_SOURCE" ]; then
    pip install -e "$NERFSTUDIO_SOURCE"
else
    echo "WARNING: Nerfstudio source directory not found ($NERFSTUDIO_SOURCE)"
    echo "Install Nerfstudio manually with: pip install -e $NERFSTUDIO_SOURCE"
fi
echo ""

# Step 7: Verify Blackwell GPU compatibility
echo "Step 7: Verifying GPU compatibility..."
python3 -c "
import torch
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU name: {torch.cuda.get_device_name(0)}')
    print(f'Compute capability: {torch.cuda.get_device_capability(0)}')
    print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')
else:
    print('Note: No CUDA GPU detected. For Blackwell (RTX 5060), ensure NVIDIA drivers are installed.')
"
echo ""

echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Activate venv: source $VENV_PATH/bin/activate"
echo "2. Process photos: python3 -m nerfstudio.scripts.process_data <photos> <output> --data-type images"
echo "3. Train model: python3 -m nerfstudio.scripts.train splatfacto --data <output>/data --output-dir <output>/results"
echo "4. Export PLY: python3 -m nerfstudio.scripts.export --load-config <output>/results/config.yml --output-path <output>/point_cloud"
echo ""
echo "For Windows deployment, use install-nerfstudio.ps1 instead."
