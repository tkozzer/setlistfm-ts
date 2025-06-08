#!/usr/bin/env bash
set -euo pipefail

# Test script for extract-changelog-entry.sh
# Comprehensive testing of changelog entry extraction logic

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRACT_SCRIPT="$SCRIPT_DIR/../../../scripts/release-pr/extract-changelog-entry.sh"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/release-pr/changelog-extraction"
TEST_CASES_FILE="$FIXTURES_DIR/test-cases.json"

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

# Load test case data from JSON fixture
load_test_case() {
    local case_index="$1"
    local field="$2"
    
    jq -r ".testCases[$case_index].$field" "$TEST_CASES_FILE"
}

load_error_test_case() {
    local case_index="$1"
    local field="$2"
    
    jq -r ".errorTestCases[$case_index].$field" "$TEST_CASES_FILE"
}

load_help_test_case() {
    local field="$1"
    
    jq -r ".helpTestCase.$field" "$TEST_CASES_FILE"
}

# Test function using fixtures
run_fixture_test() {
    local test_name="$1"
    local fixture_file="$2"
    local expected_output="$3"
    local expected_exit_code="$4"
    local additional_args="${5:-}"
    
    echo_test "$test_name"
    
    total_tests=$((total_tests + 1))
    
    # Use fixture file directly or handle special case for non-existent files
    local changelog_file
    if [[ "$fixture_file" == "/nonexistent/changelog.md" ]]; then
        changelog_file="$fixture_file"  # This should not exist
    else
        changelog_file="$FIXTURES_DIR/$fixture_file"
    fi
    
    # Capture output and exit code
    local actual_output
    local actual_exit_code
    
    if actual_output=$("$EXTRACT_SCRIPT" --file "$changelog_file" $additional_args 2>&1); then
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
    
    # Check output content - handle multiline comparison
    local expected_formatted
    expected_formatted=$(echo -e "$expected_output")
    
    if [[ "$actual_output" == "$expected_formatted" ]]; then
        echo_pass "Test passed"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        echo_fail "Output mismatch"
        echo "   Expected:"
        echo "$expected_formatted" | sed 's/^/     /'
        echo "   Got:"
        echo "$actual_output" | sed 's/^/     /'
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

# Test function for help and special cases
run_special_test() {
    local test_name="$1"
    local expected_output="$2"
    local expected_exit_code="$3"
    local additional_args="${4:-}"
    
    echo_test "$test_name"
    
    total_tests=$((total_tests + 1))
    
    # Capture output and exit code
    local actual_output
    local actual_exit_code
    
    if actual_output=$("$EXTRACT_SCRIPT" $additional_args 2>&1); then
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
    
    # Check output content - handle multiline comparison
    local expected_formatted
    expected_formatted=$(echo -e "$expected_output")
    
    if [[ "$actual_output" == "$expected_formatted" ]]; then
        echo_pass "Test passed"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        echo_fail "Output mismatch"
        echo "   Expected:"
        echo "$expected_formatted" | sed 's/^/     /'
        echo "   Got:"
        echo "$actual_output" | sed 's/^/     /'
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

main() {
    echo -e "${BLUE}🚀 Testing Changelog Entry Extraction Logic${NC}"
    echo ""
    
    # Verify that jq is available for JSON parsing
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}❌ jq is required for parsing test case JSON files${NC}"
        echo "Please install jq to run these tests."
        exit 1
    fi
    
    # Verify test cases file exists
    if [[ ! -f "$TEST_CASES_FILE" ]]; then
        echo -e "${RED}❌ Test cases file not found: $TEST_CASES_FILE${NC}"
        exit 1
    fi
    
    # Run main test cases
    local test_count
    test_count=$(jq '.testCases | length' "$TEST_CASES_FILE")
    
    for ((i = 0; i < test_count; i++)); do
        local name fixture output_format exit_code expected_output additional_args
        
        name=$(load_test_case "$i" "name")
        fixture=$(load_test_case "$i" "fixture")
        output_format=$(load_test_case "$i" "outputFormat")
        exit_code=$(load_test_case "$i" "expectedExitCode")
        expected_output=$(load_test_case "$i" "expectedOutput")
        
        additional_args=""
        if [[ "$output_format" != "github-actions" ]]; then
            additional_args="--output-format $output_format"
        fi
        
        run_fixture_test "$name" "$fixture" "$expected_output" "$exit_code" "$additional_args"
    done
    
    # Run error test cases
    local error_test_count
    error_test_count=$(jq '.errorTestCases | length' "$TEST_CASES_FILE")
    
    for ((i = 0; i < error_test_count; i++)); do
        local name fixture output_format exit_code expected_output additional_args
        
        name=$(load_error_test_case "$i" "name")
        fixture=$(load_error_test_case "$i" "fixture")
        output_format=$(load_error_test_case "$i" "outputFormat")
        exit_code=$(load_error_test_case "$i" "expectedExitCode")
        expected_output=$(load_error_test_case "$i" "expectedOutput")
        
        additional_args=""
        if [[ "$output_format" != "github-actions" ]]; then
            additional_args="--output-format $output_format"
        fi
        
        run_fixture_test "$name" "$fixture" "$expected_output" "$exit_code" "$additional_args"
    done
    
    # Run help test case
    local help_name help_exit_code help_expected_output
    help_name=$(load_help_test_case "name")
    help_exit_code=$(load_help_test_case "expectedExitCode")
    help_expected_output=$(load_help_test_case "expectedOutput")
    
    run_special_test "$help_name" "$help_expected_output" "$help_exit_code" "--help"
    
    # Summary
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📊 Test Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "Total tests: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some tests failed!${NC}"
        exit 1
    fi
}

# Verify the script exists before running tests
if [[ ! -f "$EXTRACT_SCRIPT" ]]; then
    echo -e "${RED}❌ Script not found: $EXTRACT_SCRIPT${NC}"
    echo "Please ensure the release-pr/extract-changelog-entry.sh script exists and is executable."
    exit 1
fi

if [[ ! -x "$EXTRACT_SCRIPT" ]]; then
    echo -e "${RED}❌ Script not executable: $EXTRACT_SCRIPT${NC}"
    echo "Please make the script executable with: chmod +x $EXTRACT_SCRIPT"
    exit 1
fi

main "$@" 