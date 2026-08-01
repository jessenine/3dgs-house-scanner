#!/bin/bash
# train.sh - Train 3D Gaussian Splatting model with Nerfstudio
# Usage: ./train.sh -d <data_path> -o <output_path> [--max-iterations N] [--model splatfacto|splatfacto-small]

set -e

# Default values
DATA_PATH=""
OUTPUT_PATH=""
MAX_ITERATIONS=30000
MODEL="splatfacto"
NUM_WORKERS=4

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--data-path)
            DATA_PATH="$2"
            shift 2
            ;;
        -o|--output-path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        --num-workers)
            NUM_WORKERS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -d <data_path> -o <output_path> [options]"
            echo ""
            echo "Options:"
            echo "  -d, --data-path         Path to COLMAP data directory (required)"
            echo "  -o, --output-path       Path to output directory (required)"
            echo "  --max-iterations        Number of training iterations (default: 30000)"
            echo "  --model                 Model: splatfacto or splatfacto-small (default: splatfacto)"
            echo "  --num-workers           Number of data loader workers (default: 4)"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$DATA_PATH" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "ERROR: Both -d (data-path) and -o (output-path) are required"
    echo ""
    echo "Usage: $0 -d <data_path> -o <output_path>"
    exit 1
fi

# Check if data directory exists
if [ ! -d "$DATA_PATH" ]; then
    echo "ERROR: Data directory not found: $DATA_PATH"
    exit 1
fi

# Check if COLMAP data exists
if [ ! -f "$DATA_PATH/sparse/0/images.bin" ] && [ ! -d "$DATA_PATH/sparse/0" ]; then
    echo "ERROR: COLMAP data not found in $DATA_PATH/sparse/0/"
    echo "       Run process-data.sh first to create COLMAP output."
    exit 1
fi

echo "=== Train 3D Gaussian Splatting Model ==="
echo "Data path: $DATA_PATH"
echo "Output path: $OUTPUT_PATH"
echo "Model: $MODEL"
echo "Iterations: $MAX_ITERATIONS"
echo "Workers: $NUM_WORKERS"
echo ""

# Create output directory
echo "Step 1: Creating output directory..."
mkdir -p "$OUTPUT_PATH"
echo "Output directory: $OUTPUT_PATH"
echo ""

# Estimate VRAM requirements
echo "Step 2: Checking VRAM requirements..."
PHOTO_COUNT=$(find "$DATA_PATH" -maxdepth 3 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | wc -l)
VRAM_NEEDED=$(echo "scale=2; $PHOTO_COUNT * 0.0075" | bc)
echo "Photos: $PHOTO_COUNT"
echo "Estimated VRAM needed: ${VRAM_NEEDED}GB (0.75GB per 100 photos)"
echo ""

# Check available VRAM
if command -v nvidia-smi &> /dev/null; then
    AVAIL_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
    echo "Available VRAM: ${AVAIL_VRAM}MB"
    if [ "$AVAIL_VRAM" -lt 6000 ]; then
        echo "WARNING: Less than 6GB VRAM available. Training may fail."
        echo "         Consider using fewer photos or splatfacto-small model."
    fi
else
    echo "Note: nvidia-smi not found. VRAM check skipped."
    echo "      Ensure your GPU has at least 6GB VRAM."
fi
echo ""

# Start training
echo "Step 3: Starting $MODEL training..."
echo "Training web UI will be available at: http://localhost:7562"
echo "Training time estimate: 45-90 minutes for 30000 iterations"
echo ""
echo "Training command:"
echo "  python -m nerfstudio.scripts.train $MODEL \\"
echo "    --data $DATA_PATH \\"
echo "    --output-dir $OUTPUT_PATH \\"
echo "    --max-num-iterations $MAX_ITERATIONS \\"
echo "    --num-workers $NUM_WORKERS"
echo ""

python -m nerfstudio.scripts.train "$MODEL" \
    --data "$DATA_PATH" \
    --output-dir "$OUTPUT_PATH" \
    --max-num-iterations "$MAX_ITERATIONS" \
    --num-workers "$NUM_WORKERS"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Training Complete ==="
    echo ""
    echo "Output structure:"
    ls -la "$OUTPUT_PATH"
    echo ""
    echo "Model files:"
    ls -la "$OUTPUT_PATH/$MODEL" 2>/dev/null || echo "  (model directory not found)"
    echo ""
    echo "Next steps:"
    echo "1. Check model config: $OUTPUT_PATH/$MODEL/config.yml"
    echo "2. Export PLY: python -m nerfstudio.scripts.export --load-config $OUTPUT_PATH/$MODEL/config.yml --output-path $OUTPUT_PATH/point_cloud"
    echo ""
else
    echo ""
    echo "ERROR: Training failed. Possible causes:"
    echo "  - Insufficient VRAM (need at least 6GB for 300-500 photos)"
    echo "  - Data path incorrect or COLMAP data missing"
    echo "  - Out of disk space"
    echo "  - Try reduced iterations: --max-iterations 1000 (for testing)"
    echo "  - Try smaller model: --model splatfacto-small"
    echo ""
    exit 1
fi
