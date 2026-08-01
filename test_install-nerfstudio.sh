#!/usr/bin/env bash
# test_install-nerfstudio.sh - TDD tests for install-nerfstudio.sh
# Run: ./test_install-nerfstudio.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/install-nerfstudio.sh"

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
echo "=== Test Suite: install-nerfstudio.sh ==="
echo ""

echo "Test 1: Script exists and is executable"
assert "Script file exists" "test -f '$SCRIPT'"
assert "Script is executable" "test -x '$SCRIPT'"
echo ""

# Test 2: Script responds to help flag
echo "Test 2: Help flag"
HELP_OUTPUT=$("$SCRIPT" -h 2>&1 || true)
assert "Help flag works" "[[ '$HELP_OUTPUT' =~ 'Usage:' ]]"
assert "Help mentions venv option" "[[ '$HELP_OUTPUT' =~ '-v' ]]"
assert "Help mentions nerfstudio option" "[[ '$HELP_OUTPUT' =~ '-n' ]]"
echo ""

# Test 3: Script structure - checks Python version
echo "Test 3: Python version check"
assert "Script checks Python version" "grep -q 'python3 --version' '$SCRIPT'"
assert "Script errors if python3 not found" "grep -q 'ERROR.*python3.*not found' '$SCRIPT'"
echo ""

# Test 4: Script creates virtual environment
echo "Test 4: Virtual environment creation"
assert "Script creates venv" "grep -q 'python3 -m venv' '$SCRIPT'"
assert "Script uses venv directory" "grep -q 'VENV_PATH' '$SCRIPT'"
echo ""

# Test 5: Script activates virtual environment
echo "Test 5: Virtual environment activation"
assert "Script activates venv" "grep -q 'source.*activate' '$SCRIPT' || grep -q \"source .*/activate\" '$SCRIPT'"
echo ""

# Test 6: Script upgrades pip
echo "Test 6: pip upgrade"
assert "Script upgrades pip" "grep -qi 'pip.*upgrade' '$SCRIPT'"
assert "Script upgrades setuptools" "grep -qi 'setuptools' '$SCRIPT'"
assert "Script upgrades wheel" "grep -qi 'wheel' '$SCRIPT'"
echo ""

# Test 7: Script installs PyTorch cu126
echo "Test 7: PyTorch cu126 installation"
assert "Script installs torch" "grep -qi 'torch' '$SCRIPT' && grep -qi 'install' '$SCRIPT'"
assert "Script installs torchvision" "grep -qi 'torchvision' '$SCRIPT' && grep -qi 'install' '$SCRIPT'"
assert "Script installs torchaudio" "grep -qi 'torchaudio' '$SCRIPT' && grep -qi 'install' '$SCRIPT'"
assert "Script uses cu126 index" "grep -qi 'cu126' '$SCRIPT'"
echo ""

# Test 8: Script installs Nerfstudio
echo "Test 8: Nerfstudio installation"
assert "Script installs nerfstudio" "grep -qi 'nerfstudio' '$SCRIPT' && grep -qi 'install' '$SCRIPT'"
assert "Script uses editable install" "grep -qi 'editable' '$SCRIPT' || grep -qi 'pip.*-e' '$SCRIPT'"
assert "Script checks for NERFSTUDIO_SOURCE" "grep -q 'NERFSTUDIO_SOURCE' '$SCRIPT'"
echo ""

# Test 9: Script verifies GPU
echo "Test 9: GPU verification"
assert "Script checks CUDA availability" "grep -q 'torch.cuda.is_available' '$SCRIPT'"
assert "Script prints GPU name" "grep -q 'torch.cuda.get_device_name' '$SCRIPT'"
assert "Script prints VRAM" "grep -q 'total_memory' '$SCRIPT'"
echo ""

# Test 10: Script documentation
echo "Test 10: Script documentation"
assert "Script has usage instructions" "grep -q 'Next steps' '$SCRIPT'"
assert "Script shows commands" "grep -qi 'process_data' '$SCRIPT' && grep -qi 'train' '$SCRIPT' && grep -qi 'export' '$SCRIPT'"
echo ""

# Test 11: Script error handling
echo "Test 11: Error handling"
assert "Script uses set -e" "grep -q 'set -e' '$SCRIPT'"
assert "Script handles missing source" "grep -qi 'WARNING.*NERFSTUDIO_SOURCE' '$SCRIPT'"
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
