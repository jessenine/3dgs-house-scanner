#!/bin/bash
# process-data.sh - Process photos with COLMAP SfM for 3D Gaussian Splatting
# Usage: ./process-data.sh -p <photo_path> -o <output_path> [--data-type images|video]

set -e

# Default values
PHOTO_PATH=""
OUTPUT_PATH=""
DATA_TYPE="images"
NUM_THREADS=8

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--photo-path)
            PHOTO_PATH="$2"
            shift 2
            ;;
        -o|--output-path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        --data-type)
            DATA_TYPE="$2"
            shift 2
            ;;
        --num-threads)
            NUM_THREADS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -p <photo_path> -o <output_path> [options]"
            echo ""
            echo "Options:"
            echo "  -p, --photo-path    Path to photos directory (required)"
            echo "  -o, --output-path   Path to output directory (required)"
            echo "  --data-type         Data type: images or video (default: images)"
            echo "  --num-threads       Number of threads for COLMAP (default: 8)"
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
if [ -z "$PHOTO_PATH" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "ERROR: Both -p (photo-path) and -o (output-path) are required"
    echo ""
    echo "Usage: $0 -p <photo_path> -o <output_path>"
    exit 1
fi

# Check if photo directory exists
if [ ! -d "$PHOTO_PATH" ]; then
    echo "ERROR: Photo directory not found: $PHOTO_PATH"
    exit 1
fi

# Count photos
PHOTO_COUNT=$(find "$PHOTO_PATH" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" \) | wc -l)

echo "=== Process Data with COLMAP SfM ==="
echo "Photo path: $PHOTO_PATH"
echo "Output path: $OUTPUT_PATH"
echo "Data type: $DATA_TYPE"
echo "Photo count: $PHOTO_COUNT"
echo "Threads: $NUM_THREADS"
echo ""

# Validate photo count
if [ $PHOTO_COUNT -lt 10 ]; then
    echo "WARNING: Very few photos ($PHOTO_COUNT). Recommended: 300-500"
    echo "         Minimal: 10, Optimal: 300-500 for full house"
fi

if [ $PHOTO_COUNT -gt 1000 ]; then
    echo "WARNING: Large number of photos ($PHOTO_COUNT). May take longer."
fi
echo ""

# Create output directory
echo "Step 1: Creating output directory..."
mkdir -p "$OUTPUT_PATH"
echo "Output directory: $OUTPUT_PATH"
echo ""

# Run COLMAP SfM via Nerfstudio
echo "Step 2: Running COLMAP SfM via Nerfstudio..."
echo "Command: python -m nerfstudio.scripts.process_data"
python -m nerfstudio.scripts.process_data "$PHOTO_PATH" "$OUTPUT_PATH" --data-type "$DATA_TYPE" --num-workers "$NUM_THREADS"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== COLMAP SfM Complete ==="
    echo ""
    echo "Output structure:"
    ls -la "$OUTPUT_PATH"
    echo ""
    echo "COLMAP data:"
    ls -la "$OUTPUT_PATH/data" 2>/dev/null || echo "  (data directory not found)"
    echo ""
    echo "Next steps:"
    echo "1. Check COLMAP output: $OUTPUT_PATH/data/sparse/0/"
    echo "2. Train model: python -m nerfstudio.scripts.train splatfacto --data $OUTPUT_PATH/data --output-dir $OUTPUT_PATH/results"
    echo ""
else
    echo ""
    echo "ERROR: COLMAP SfM failed. Possible causes:"
    echo "  - Insufficient photo overlap (need 60-70%)"
    echo "  - Poor image quality or inconsistent lighting"
    echo "  - Incorrect photo format (need JPG, JPEG, PNG, BMP)"
    echo ""
    exit 1
fi
