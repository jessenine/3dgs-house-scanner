#!/bin/bash
# export.sh - Export trained 3DGS model to PLY format
# Usage: ./export.sh -c <config_path> -o <output_path>

set -e

# Default values
CONFIG_PATH=""
OUTPUT_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config-path)
            CONFIG_PATH="$2"
            shift 2
            ;;
        -o|--output-path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -c <config_path> -o <output_path>"
            echo ""
            echo "Options:"
            echo "  -c, --config-path   Path to model config.yml (required)"
            echo "  -o, --output-path   Path to output PLY directory (required)"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$CONFIG_PATH" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "ERROR: Both -c (config-path) and -o (output-path) are required"
    echo ""
    echo "Usage: $0 -c <config_path> -o <output_path>"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "ERROR: Config file not found: $CONFIG_PATH"
    exit 1
fi

echo "=== Export 3DGS Model to PLY ==="
echo "Config path: $CONFIG_PATH"
echo "Output path: $OUTPUT_PATH"
echo ""

# Validate config file
echo "Step 1: Validating config file..."
CONFIG_DIR=$(dirname "$CONFIG_PATH")
echo "Config directory: $CONFIG_DIR"

# Extract data path from config
if command -v python3 &> /dev/null; then
    DATA_PATH=$(python3 -c "
import yaml
with open('$CONFIG_PATH', 'r') as f:
    config = yaml.safe_load(f)
print(config.get('pipeline', {}).get('.datamanager', {}).get('data', ''))
" 2>/dev/null || echo "")
    echo "Data path from config: $DATA_PATH"
else
    echo "Note: Python3 not available. Skipping config parsing."
fi
echo ""

# Create output directory
echo "Step 2: Creating output directory..."
mkdir -p "$OUTPUT_PATH"
echo "Output directory: $OUTPUT_PATH"
echo ""

# Estimate PLY size
echo "Step 3: Estimating PLY size..."
if [ -d "$DATA_PATH" ]; then
    PHOTO_COUNT=$(find "$DATA_PATH" -maxdepth 3 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | wc -l)
    ESTIMATED_SIZE=$(echo "scale=2; $PHOTO_COUNT * 0.3" | bc)
    echo "Photos: $PHOTO_COUNT"
    echo "Estimated PLY size: ${ESTIMATED_SIZE}GB (0.3GB per photo)"
else
    echo "Note: Data path not available for size estimation."
    echo "      PLY files are typically 100-500MB for full house."
fi
echo ""

# Run export
echo "Step 4: Running export..."
echo "Command: python -m nerfstudio.scripts.export"
echo ""
echo "This will create a point_cloud.ply file in $OUTPUT_PATH"
echo ""

python -m nerfstudio.scripts.export --load-config "$CONFIG_PATH" --output-path "$OUTPUT_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Export Complete ==="
    echo ""
    echo "Output structure:"
    ls -la "$OUTPUT_PATH"
    echo ""
    
    # Find PLY file
    PLY_FILE=$(find "$OUTPUT_PATH" -name "*.ply" -type f 2>/dev/null | head -1)
    if [ -n "$PLY_FILE" ]; then
        PLY_SIZE=$(du -h "$PLY_FILE" | cut -f1)
        echo "PLY file: $PLY_FILE"
        echo "Size: $PLY_SIZE"
        echo ""
    fi
    
    echo "Next steps:"
    echo "1. Open PLY in SuperSplat: https://superspl.at/editor"
    echo "2. Or use SIBR Viewer: https://inria.github.io/sibr/"
    echo "3. Compress for web: Use SuperSplat's 'Compress' feature"
    echo ""
else
    echo ""
    echo "ERROR: Export failed. Possible causes:"
    echo "  - Config path incorrect"
    echo "  - Model not fully trained (need complete checkpoints)"
    echo "  - Insufficient disk space"
    echo "  - Config may have different export path - check config file"
    echo ""
    exit 1
fi
