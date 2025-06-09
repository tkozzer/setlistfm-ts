#!/usr/bin/env bash
set -euo pipefail

# Test script to verify the interface compatibility issues with the release-notes-generate workflow
# This test demonstrates the actual interface expected by the workflow vs. current implementation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRACT_SCRIPT="$SCRIPT_DIR/../../../scripts/release-pr/extract-changelog-entry.sh"

total_tests=0
passed_tests=0
failed_tests=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_test() {
    echo -e "${BLUE}🧪 $1${NC}"
}

echo_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_fail() {
    echo -e "${RED}❌ $1${NC}"
}

run_interface_test() {
    local test_name="$1"
    local args="$2"
    local expected_exit_code="$3"
    local should_contain="$4"
    
    echo_test "$test_name"
    
    total_tests=$((total_tests + 1))
    
    # Capture output and exit code
    local actual_output
    local actual_exit_code
    
    if actual_output=$("$EXTRACT_SCRIPT" $args 2>&1); then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    # Strip ANSI color codes from output for comparison
    actual_output=$(echo "$actual_output" | sed 's/\x1b\[[0-9;]*m//g')
    
    # Check exit code
    if [[ "$actual_exit_code" != "$expected_exit_code" ]]; then
        echo_fail "Exit code mismatch. Expected: $expected_exit_code, Got: $actual_exit_code"
        echo "   Output: $actual_output"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
    
    # Check if output contains expected content (for error messages)
    if [[ -n "$should_contain" ]]; then
        if [[ "$actual_output" == *"$should_contain"* ]]; then
            echo_pass "Test passed - output contains expected text"
            passed_tests=$((passed_tests + 1))
            return 0
        else
            echo_fail "Output does not contain expected text: '$should_contain'"
            echo "   Actual output: $actual_output"
            failed_tests=$((failed_tests + 1))
            return 1
        fi
    else
        echo_pass "Test passed"
        passed_tests=$((passed_tests + 1))
        return 0
    fi
}

main() {
    echo -e "${BLUE}🚀 Testing Interface Compatibility Issues${NC}"
    echo ""
    
    # Create a temporary changelog for testing
    local temp_changelog
    temp_changelog=$(mktemp)
    cat > "$temp_changelog" << 'EOF'
# Changelog

## [0.7.2] - 2024-06-09

### Added
- New feature A
- New feature B

### Fixed
- Bug fix X

## [0.7.1] - 2024-06-01

### Fixed
- Previous bug fix
EOF
    
    # Test the interface that should now work from the workflow
    echo -e "${YELLOW}Testing interface as called from release-notes-generate.yml workflow:${NC}"
    echo ""
    
    # This should now work - the exact call from the workflow
    run_interface_test \
        "Workflow call: --version 0.7.2 --changelog CHANGELOG.md --verbose (SHOULD WORK)" \
        "--version 0.7.2 --changelog $temp_changelog --verbose" \
        0 \
        ""
    
    # Test individual parameters that should now work
    run_interface_test \
        "Test --version parameter with specific version (SHOULD WORK)" \
        "--version 0.7.2 --file $temp_changelog" \
        0 \
        ""
    
    run_interface_test \
        "Test --changelog parameter alias (SHOULD WORK)" \
        "--changelog $temp_changelog" \
        0 \
        ""
    
    run_interface_test \
        "Test --verbose parameter alias (SHOULD WORK)" \
        "--file $temp_changelog --verbose" \
        0 \
        ""
    
    # Test what currently works
    echo ""
    echo -e "${YELLOW}Testing current working interface:${NC}"
    echo ""
    
    run_interface_test \
        "Current working call: --file --debug" \
        "--file $temp_changelog --debug" \
        0 \
        ""
    
    # Cleanup
    rm -f "$temp_changelog"
    
    # Test summary
    echo ""
    echo -e "${BLUE}📊 Test Summary:${NC}"
    echo "   Total tests: $total_tests"
    echo "   Passed: $passed_tests"
    echo "   Failed: $failed_tests"
    
    if [[ $failed_tests -gt 0 ]]; then
        echo ""
        echo -e "${RED}❌ Some tests failed!${NC}"
        return 1
    else
        echo ""
        echo -e "${GREEN}✅ All interface compatibility tests passed!${NC}"
        echo "   The script now properly supports:"
        echo "   - --version parameter (to filter by specific version)"
        echo "   - --changelog parameter (alias for --file)"
        echo "   - --verbose parameter (alias for --debug)"
        return 0
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 