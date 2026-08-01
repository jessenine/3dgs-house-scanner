#!/usr/bin/env bash
# test_pipeline.sh - TDD tests for pipeline scripts (process-data.sh, train.sh, export.sh)
# Run: ./test_pipeline.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Assert function
assert() {
    local description="$1"
    local condition="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$condition"; then
        echo -e "${GREEN}✓ PASS${NC}: $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $description"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: All scripts exist and are executable
echo "=== Test Suite: Pipeline Scripts ==="
echo ""

echo "Test 1: Script files exist and are executable"
assert "process-data.sh exists" "test -f '$SCRIPT_DIR/process-data.sh'"
assert "process-data.sh is executable" "test -x '$SCRIPT_DIR/process-data.sh'"
assert "train.sh exists" "test -f '$SCRIPT_DIR/train.sh'"
assert "train.sh is executable" "test -x '$SCRIPT_DIR/train.sh'"
assert "export.sh exists" "test -f '$SCRIPT_DIR/export.sh'"
assert "export.sh is executable" "test -x '$SCRIPT_DIR/export.sh'"
echo ""

# Test 2: process-data.sh
echo "Test 2: process-data.sh structure"
assert "process-data.sh has help" "$SCRIPT_DIR/process-data.sh -h 2>&1 | grep -q 'Usage:'"
assert "process-data.sh requires photo-path" "$SCRIPT_DIR/process-data.sh 2>&1 | grep -qi 'required'"
assert "process-data.sh requires output-path" "$SCRIPT_DIR/process-data.sh -p test 2>&1 | grep -qi 'required'"
assert "process-data.sh uses nerfstudio" "grep -q 'nerfstudio.scripts.process_data' '$SCRIPT_DIR/process-data.sh'"
assert "process-data.sh validates photo count" "grep -q 'PHOTO_COUNT' '$SCRIPT_DIR/process-data.sh'"
assert "process-data.sh creates output dir" "grep -q 'mkdir -p' '$SCRIPT_DIR/process-data.sh'"
echo ""

# Test 3: train.sh
echo "Test 3: train.sh structure"
assert "train.sh has help" "$SCRIPT_DIR/train.sh -h 2>&1 | grep -q 'Usage:'"
assert "train.sh requires data-path" "$SCRIPT_DIR/train.sh 2>&1 | grep -qi 'required'"
assert "train.sh requires output-path" "$SCRIPT_DIR/train.sh -d test 2>&1 | grep -qi 'required'"
assert "train.sh uses splatfacto" "grep -q 'nerfstudio.scripts.train' '$SCRIPT_DIR/train.sh'"
assert "train.sh validates COLMAP data" "grep -q 'sparse/0/images.bin' '$SCRIPT_DIR/train.sh'"
assert "train.sh estimates VRAM" "grep -q 'VRAM' '$SCRIPT_DIR/train.sh'"
assert "train.sh shows web UI" "grep -q 'localhost:7562' '$SCRIPT_DIR/train.sh'"
echo ""

# Test 4: export.sh
echo "Test 4: export.sh structure"
assert "export.sh has help" "$SCRIPT_DIR/export.sh -h 2>&1 | grep -q 'Usage:'"
assert "export.sh requires config-path" "$SCRIPT_DIR/export.sh 2>&1 | grep -qi 'required'"
assert "export.sh requires output-path" "$SCRIPT_DIR/export.sh -c test 2>&1 | grep -qi 'required'"
assert "export.sh uses export script" "grep -q 'nerfstudio.scripts.export' '$SCRIPT_DIR/export.sh'"
assert "export.sh validates config" "grep -q 'config.yml' '$SCRIPT_DIR/export.sh'"
assert "export.sh creates output dir" "grep -q 'mkdir -p' '$SCRIPT_DIR/export.sh'"
echo ""

# Test 5: Error handling
echo "Test 5: Error handling"
assert "process-data.sh uses set -e" "grep -q 'set -e' '$SCRIPT_DIR/process-data.sh'"
assert "train.sh uses set -e" "grep -q 'set -e' '$SCRIPT_DIR/train.sh'"
assert "export.sh uses set -e" "grep -q 'set -e' '$SCRIPT_DIR/export.sh'"
assert "process-data.sh has error exits" "grep -q 'exit 1' '$SCRIPT_DIR/process-data.sh'"
assert "train.sh has error exits" "grep -q 'exit 1' '$SCRIPT_DIR/train.sh'"
assert "export.sh has error exits" "grep -q 'exit 1' '$SCRIPT_DIR/export.sh'"
echo ""

# Test 6: Documentation
echo "Test 6: Documentation"
assert "process-data.sh shows next steps" "grep -q 'Next steps' '$SCRIPT_DIR/process-data.sh'"
assert "train.sh shows web URL" "grep -q 'localhost:7562' '$SCRIPT_DIR/train.sh'"
assert "export.sh shows next steps" "grep -q 'Next steps' '$SCRIPT_DIR/export.sh'"
assert "process-data.sh mentions COLMAP" "grep -qi 'COLMAP' '$SCRIPT_DIR/process-data.sh'"
assert "train.sh mentions VRAM" "grep -qi 'VRAM' '$SCRIPT_DIR/train.sh'"
echo ""

# Test 7: Validation
echo "Test 7: Input validation"
assert "process-data.sh checks photo dir" "grep -q ' Photo directory not found' '$SCRIPT_DIR/process-data.sh'"
assert "train.sh checks data dir" "grep -q ' Data directory not found' '$SCRIPT_DIR/train.sh'"
assert "export.sh checks config file" "grep -q ' Config file not found' '$SCRIPT_DIR/export.sh'"
echo ""

# Test 8: Command-line arguments
echo "Test 8: Command-line arguments"
assert "process-data.sh accepts -p" "grep -q '\-p' '$SCRIPT_DIR/process-data.sh'"
assert "process-data.sh accepts -o" "grep -q '\-o' '$SCRIPT_DIR/process-data.sh'"
assert "train.sh accepts -d" "grep -q '\-d' '$SCRIPT_DIR/train.sh'"
assert "train.sh accepts -o" "grep -q '\-o' '$SCRIPT_DIR/train.sh'"
assert "export.sh accepts -c" "grep -q '\-c' '$SCRIPT_DIR/export.sh'"
assert "export.sh accepts -o" "grep -q '\-o' '$SCRIPT_DIR/export.sh'"
echo ""

# Summary
echo "=== Test Summary ==="
echo "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo ""

# Exit with error if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

echo -e "${GREEN}All tests passed!${NC}"
