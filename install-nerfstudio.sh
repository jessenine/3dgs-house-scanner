#!/bin/bash
# install-nerfstudio.sh - Install Nerfstudio with cu126 for Blackwell GPU support
# Usage: ./install-nerfstudio.sh [-v <venv_path>] [-n <nerfstudio_source>]

set -e

VENV_PATH="gs-env"
NERFSTUDIO_SOURCE="nerfstudio"

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

echo "Step 1: Checking Python version..."
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not found. Please install Python 3.10+"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo "Python version: $PYTHON_VERSION"
echo ""

echo "Step 2: Creating virtual environment..."
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    echo "Created virtual environment: $VENV_PATH"
else
    echo "Virtual environment already exists: $VENV_PATH"
fi
echo ""

echo "Step 3: Activating virtual environment..."
source "$VENV_PATH/bin/activate"
echo "Virtual environment activated"
echo ""

echo "Step 4: Upgrading pip, setuptools, wheel..."
pip install --upgrade pip setuptools wheel
echo ""

echo "Step 5: Installing PyTorch cu126..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
echo ""

echo "Step 6: Installing Nerfstudio..."
if [ -d "$NERFSTUDIO_SOURCE" ]; then
    cd "$NERFSTUDIO_SOURCE"
    pip install -e .
    cd -
else
    git clone https://github.com/nerfstudio-project/nerfstudio.git "$NERFSTUDIO_SOURCE"
    cd "$NERFSTUDIO_SOURCE"
    pip install -e .
    cd -
fi
echo ""

echo "Step 7: Installing COLMAP..."
pip install colmap
echo ""

echo "✓ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Navigate to your photo directory with 300-500 images"
echo "2. Run: ./process-data.sh -p <photo_path> -o <output_path>"
echo "3. Run: ./train.sh -d <data_path> -o <output_path>"
echo "4. Run: ./export.sh -c <config_path> -o <output_ply>"
