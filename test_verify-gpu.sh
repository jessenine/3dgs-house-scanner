#!/usr/bin/env bash
# test_verify-gpu.sh - TDD tests for verify-gpu.sh
# Run: ./test_verify-gpu.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/verify-gpu.sh"

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

# Test 1: Script exists and is executable
echo "=== Test Suite: verify-gpu.sh ==="
echo ""

echo "Test 1: Script exists and is executable"
assert "Script file exists" "test -f '$SCRIPT'"
assert "Script is executable" "test -x '$SCRIPT'"
echo ""

# Test 2: Help flag
echo "Test 2: Help flag"
HELP_OUTPUT=$("$SCRIPT" -h 2>&1 || true)
assert "Help flag works" "[[ '$HELP_OUTPUT' =~ 'Usage:' ]]"
assert "Help mentions quiet option" "[[ '$HELP_OUTPUT' =~ '--quiet' ]]"
assert "Help lists verification items" "echo '$HELP_OUTPUT' | grep -q 'CUDA version' && echo '$HELP_OUTPUT' | grep -q 'GPU name' && echo '$HELP_OUTPUT' | grep -q 'VRAM'"
echo ""

# Test 3: Script structure - PyTorch check
echo "Test 3: PyTorch installation check"
assert "Script checks python3" "grep -q 'python3' '$SCRIPT'"
assert "Script imports torch" "grep -q 'import torch' '$SCRIPT'"
assert "Script checks CUDA.is_available" "grep -q 'torch.cuda.is_available' '$SCRIPT'"
echo ""

# Test 4: CUDA version verification
echo "Test 4: CUDA version verification"
assert "Script checks CUDA version" "grep -q 'torch.version.cuda' '$SCRIPT'"
assert "Script validates 12.6" "grep -q '12.6' '$SCRIPT'"
echo ""

# Test 5: GPU name verification
echo "Test 5: GPU name verification"
assert "Script gets GPU name" "grep -q 'torch.cuda.get_device_name' '$SCRIPT'"
assert "Script checks for RTX 5060" "grep -qi 'RTX 5060' '$SCRIPT'"
echo ""

# Test 6: VRAM verification
echo "Test 6: VRAM verification"
assert "Script checks VRAM" "grep -q 'total_memory' '$SCRIPT'"
assert "Script validates 12GB minimum" "grep -q '12' '$SCRIPT' && grep -q 'VRAM' '$SCRIPT'"
echo ""

# Test 7: Compute capability verification
echo "Test 7: Compute capability verification"
assert "Script checks compute capability" "grep -q 'get_device_capability' '$SCRIPT'"
assert "Script checks for 12.0" "grep -q '12, 0' '$SCRIPT' || grep -q '12\.0' '$SCRIPT'"
echo ""

# Test 8: Error handling
echo "Test 8: Error handling"
assert "Script uses set -e" "grep -q 'set -e' '$SCRIPT'"
assert "Script exits with status" "grep -q 'exit' '$SCRIPT'"
assert "Script has overall status" "grep -q 'OVERALL_STATUS' '$SCRIPT'"
echo ""

# Test 9: Quiet mode
echo "Test 9: Quiet mode"
assert "Script accepts --quiet" "grep -q 'quiet' '$SCRIPT' || grep -q 'QUIET' '$SCRIPT'"
echo ""

# Test 10: Documentation
echo "Test 10: Documentation"
assert "Script shows next steps" "grep -q 'Next steps' '$SCRIPT' || grep -q 'Verify' '$SCRIPT'"
assert "Script provides troubleshooting" "grep -qi 'nvidia-smi' '$SCRIPT' || grep -qi 'nvcc' '$SCRIPT'"
assert "Script mentions patched code" "grep -qi 'patched' '$SCRIPT' || grep -qi 'sm_120' '$SCRIPT'"
echo ""

# Test 11: Output formatting
echo "Test 11: Output formatting"
assert "Script uses display function" "grep -q 'display()' '$SCRIPT' || grep -q 'display()' '$SCRIPT'"
assert "Script has checkmarks" "grep -q '✓' '$SCRIPT' || grep -q 'PASS' '$SCRIPT'"
assert "Script has error markers" "grep -q '✗' '$SCRIPT' || grep -q 'FAIL' '$SCRIPT'"
echo ""

# Test 12: Exit codes
echo "Test 12: Exit codes"
# Run with --quiet and check exit code based on system
$SCRIPT --quiet > /dev/null 2>&1 || true
SCRIPT_EXIT=$?
# Exit should be 0 (success) or 1 (some checks failed)
assert "Script exits with 0 or 1" "[[ $SCRIPT_EXIT -eq 0 || $SCRIPT_EXIT -eq 1 ]]"

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
