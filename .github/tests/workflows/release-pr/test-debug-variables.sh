#!/bin/bash

###
# Test suite for .github/scripts/release-pr/debug-variables.sh
# 
# Tests the debug variables script with various inputs and edge cases,
# including special character handling that caused the original shell parsing error.
###

set -euo pipefail

# Get the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# Script under test
SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-pr/debug-variables.sh"

# Test fixtures
FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-pr/debug-variables"
TEST_CASES_FILE="$FIXTURES_DIR/test-cases.json"

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to print colored output
print_status() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
    esac
}

# Function to test basic scenarios without complex pattern matching
run_basic_tests() {
    print_status "INFO" "Running basic functionality tests"
    
    # Test 1: Basic functionality with apostrophes (the original error case)
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Original error reproduction with apostrophes"
    
    local original_changelog="### Fixed\n- Resolved shell parsing errors in GitHub Actions workflows by extracting debug scripts and improving handling of special characters in AI-generated PR descriptions.\n- Fixed command parsing errors in the release PR workflow by replacing eval-based execution with direct GitHub CLI calls, ensuring complex content is handled correctly.\n- Improved the release-prepare workflow's changelog update logic with comprehensive tests covering special character handling, multi-line content, and proper insertion order.\n---"
    
    if "$SCRIPT_UNDER_TEST" --version "0.7.3" --changelog "$original_changelog" >/dev/null 2>&1; then
        print_status "PASS" "Original error reproduction - apostrophes handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Original error reproduction - failed with apostrophes"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 2: Apostrophes in content
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Apostrophes in content"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog $'### Fixed\n- Fixed what\'s broken\n- Here\'s another fix\n- Don\'t break anything' >/dev/null 2>&1; then
        print_status "PASS" "Apostrophes in content handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Apostrophes in content failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 3: Double quotes
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Double quotes in content"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog $'### Fixed\n- Fixed "quoted" issues\n- Resolved "another" problem' >/dev/null 2>&1; then
        print_status "PASS" "Double quotes handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Double quotes failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 4: Backticks
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Backticks in content"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog $'### Fixed\n- Fixed `code` issues\n- Updated `file.txt` handling' >/dev/null 2>&1; then
        print_status "PASS" "Backticks handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Backticks failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 5: Mixed special characters
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Mixed special characters"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog $'### Fixed\n- Fixed what\'s "broken" with `code`\n- Here\'s a $variable reference\n- Don\'t use (parentheses) incorrectly' >/dev/null 2>&1; then
        print_status "PASS" "Mixed special characters handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Mixed special characters failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 6: Empty changelog (should fail)
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Empty changelog error"
    
    if ! "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog "" >/dev/null 2>&1; then
        print_status "PASS" "Empty changelog error handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Empty changelog should have failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 7: Custom max chars
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Custom max chars"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog "This is a very long changelog entry that should be truncated" --max-chars 20 >/dev/null 2>&1; then
        print_status "PASS" "Custom max chars handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Custom max chars failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 8: Custom title
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Custom title"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog "content" --title "CUSTOM" >/dev/null 2>&1; then
        print_status "PASS" "Custom title handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Custom title failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 9: Verbose mode
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Verbose mode"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog "content" --verbose >/dev/null 2>&1; then
        print_status "PASS" "Verbose mode handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Verbose mode failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 10: Unicode content
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Unicode content"
    
    if "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog $'### Fixed 🐛\n- Fixed émojis and accénts\n- Resolved ñoñó issues' >/dev/null 2>&1; then
        print_status "PASS" "Unicode content handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Unicode content failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to test error cases
run_error_tests() {
    print_status "INFO" "Running error handling tests"
    
    # Test 1: Missing version
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Missing version error"
    
    if ! "$SCRIPT_UNDER_TEST" --changelog "content" >/dev/null 2>&1; then
        print_status "PASS" "Missing version error handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Missing version error not handled"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 2: Missing changelog
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Missing changelog error"
    
    if ! "$SCRIPT_UNDER_TEST" --version "1.0.0" >/dev/null 2>&1; then
        print_status "PASS" "Missing changelog error handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Missing changelog error not handled"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 3: Invalid max chars
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Invalid max chars error"
    
    if ! "$SCRIPT_UNDER_TEST" --version "1.0.0" --changelog "content" --max-chars "invalid" >/dev/null 2>&1; then
        print_status "PASS" "Invalid max chars error handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Invalid max chars error not handled"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 4: Unknown option
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Unknown option error"
    
    if ! "$SCRIPT_UNDER_TEST" --unknown-option "value" >/dev/null 2>&1; then
        print_status "PASS" "Unknown option error handled correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Unknown option error not handled"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Test 5: Help message
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "INFO" "Test: Help message"
    
    if "$SCRIPT_UNDER_TEST" --help | grep -q "Usage:" 2>/dev/null; then
        print_status "PASS" "Help message displayed correctly"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_status "FAIL" "Help message not displayed correctly"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Main test function
run_tests() {
    print_status "INFO" "Starting debug-variables.sh test suite"
    print_status "INFO" "Script under test: $SCRIPT_UNDER_TEST"
    echo ""
    
    # Verify script exists and is executable
    if [[ ! -f "$SCRIPT_UNDER_TEST" ]]; then
        print_status "FAIL" "Script not found: $SCRIPT_UNDER_TEST"
        exit 1
    fi
    
    if [[ ! -x "$SCRIPT_UNDER_TEST" ]]; then
        print_status "FAIL" "Script is not executable: $SCRIPT_UNDER_TEST"
        exit 1
    fi
    
    # Run basic functionality tests
    run_basic_tests
    echo ""
    
    # Run error handling tests
    run_error_tests
    echo ""
}

# Run the tests
run_tests

# Print summary
echo "============================================"
print_status "INFO" "Test Summary"
echo "  Tests run: $TESTS_RUN"
echo "  Tests passed: $TESTS_PASSED"
echo "  Tests failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
    print_status "PASS" "All tests passed! ✨"
    exit 0
else
    print_status "FAIL" "$TESTS_FAILED test(s) failed"
    exit 1
fi 