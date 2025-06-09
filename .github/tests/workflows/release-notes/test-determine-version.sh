#!/usr/bin/env bash

#
# @file test-determine-version.sh
# @description Test suite for determine-version.sh script
# @author tkozzer
# @module release-notes-tests
#

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-notes"
SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-notes/determine-version.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Array to store failed tests
declare -a FAILED_TEST_NAMES=()

# Test environment
TEMP_DIR=""

setup_test_environment() {
    echo -e "${BLUE}🔧 Setting up test environment...${NC}"
    
    # Create temporary directory for test files
    TEMP_DIR=$(mktemp -d)
    
    # Verify script exists and is executable
    if [[ ! -f "$SCRIPT_UNDER_TEST" ]]; then
        echo -e "${RED}❌ Script under test not found: $SCRIPT_UNDER_TEST${NC}"
        exit 1
    fi
    
    if [[ ! -x "$SCRIPT_UNDER_TEST" ]]; then
        echo -e "${RED}❌ Script under test is not executable: $SCRIPT_UNDER_TEST${NC}"
        exit 1
    fi
    
    # Verify fixtures exist
    if [[ ! -d "$FIXTURES_DIR" ]]; then
        echo -e "${RED}❌ Fixtures directory not found: $FIXTURES_DIR${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Test environment setup complete${NC}"
    echo -e "   Temp directory: $TEMP_DIR"
    echo -e "   Script under test: $SCRIPT_UNDER_TEST"
    echo -e "   Fixtures directory: $FIXTURES_DIR"
    echo ""
}

cleanup_test_environment() {
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    local description="$3"
    
    echo -e "${CYAN}🧪 Running test: $test_name${NC}"
    echo -e "   ${BLUE}Description:${NC} $description"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if $test_function; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TEST_NAMES+=("$test_name")
    fi
    
    echo ""
}

# Test functions

test_help_message() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --help 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Usage:" && echo "$output" | grep -q "Options:"; then
        return 0
    fi
    return 1
}

test_missing_trigger_type() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Trigger type is required"; then
        return 0
    fi
    return 1
}

test_invalid_trigger_type() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "invalid_trigger" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Trigger type must be 'workflow_dispatch' or 'workflow_run'"; then
        return 0
    fi
    return 1
}

test_manual_trigger_missing_version() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Manual version is required for workflow_dispatch trigger"; then
        return 0
    fi
    return 1
}

test_manual_trigger_invalid_version() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" --manual-version "invalid.version" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Manual version must be valid semver format"; then
        return 0
    fi
    return 1
}

test_manual_trigger_valid_version() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" --manual-version "1.2.3" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "1.2.3"; then
        return 0
    fi
    return 1
}

test_manual_trigger_prerelease_version() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" --manual-version "2.0.0-beta.1" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "2.0.0-beta.1"; then
        return 0
    fi
    return 1
}

test_auto_trigger_missing_package_json() {
    local output
    local exit_code=0
    
    # Change to temp directory where there's no package.json
    cd "$TEMP_DIR"
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_run" 2>&1) || exit_code=$?
    
    # Change back
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Package.json file not found"; then
        return 0
    fi
    return 1
}

test_auto_trigger_invalid_package_json() {
    local output
    local exit_code=0
    local test_package="$TEMP_DIR/package.json"
    
    # Copy invalid package.json to temp directory
    cp "$FIXTURES_DIR/determine-version/invalid-package.json" "$test_package"
    cd "$TEMP_DIR"
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_run" 2>&1) || exit_code=$?
    
    # Change back
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Invalid JSON in package.json"; then
        return 0
    fi
    return 1
}

test_auto_trigger_no_version_in_package_json() {
    local output
    local exit_code=0
    local test_package="$TEMP_DIR/package.json"
    
    # Copy package.json without version to temp directory
    cp "$FIXTURES_DIR/determine-version/no-version-package.json" "$test_package"
    cd "$TEMP_DIR"
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_run" 2>&1) || exit_code=$?
    
    # Change back
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "No version found in package.json"; then
        return 0
    fi
    return 1
}

test_auto_trigger_valid_package_json() {
    local output
    local exit_code=0
    local test_package="$TEMP_DIR/package.json"
    
    # Copy valid package.json to temp directory
    cp "$FIXTURES_DIR/determine-version/valid-package.json" "$test_package"
    cd "$TEMP_DIR"
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_run" 2>&1) || exit_code=$?
    
    # Change back
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "1.2.3"; then
        return 0
    fi
    return 1
}

test_auto_trigger_prerelease_package_json() {
    local output
    local exit_code=0
    local test_package="$TEMP_DIR/package.json"
    
    # Copy prerelease package.json to temp directory
    cp "$FIXTURES_DIR/determine-version/prerelease-package.json" "$test_package"
    cd "$TEMP_DIR"
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_run" 2>&1) || exit_code=$?
    
    # Change back
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "2.0.0-beta.1"; then
        return 0
    fi
    return 1
}

test_output_to_file() {
    local output
    local exit_code=0
    local output_file="$TEMP_DIR/version.txt"
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" --manual-version "1.2.3" --output-file "$output_file" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && [[ -f "$output_file" ]] && [[ "$(cat "$output_file")" == "1.2.3" ]]; then
        return 0
    fi
    return 1
}

test_environment_variable_trigger() {
    local output
    local exit_code=0
    
    export GITHUB_EVENT_NAME="workflow_dispatch"
    output=$("$SCRIPT_UNDER_TEST" --manual-version "1.2.3" 2>&1) || exit_code=$?
    unset GITHUB_EVENT_NAME
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "1.2.3"; then
        return 0
    fi
    return 1
}

test_verbose_output() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" --manual-version "1.2.3" --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERBOSE:" && echo "$output" | grep -q "Manual version: 1.2.3"; then
        return 0
    fi
    return 1
}

test_semver_formats() {
    local versions=("1.0.0" "1.2.3" "2.0.0-beta.1" "1.0.0+build.1" "1.0.0-alpha.1+build.2")
    
    for version in "${versions[@]}"; do
        local output
        local exit_code=0
        output=$("$SCRIPT_UNDER_TEST" --trigger-type "workflow_dispatch" --manual-version "$version" 2>&1) || exit_code=$?
        if [[ $exit_code -ne 0 ]]; then
            echo "Failed for valid version: $version"
            echo "Output: $output"
            return 1
        fi
    done
    
    return 0
}

print_test_summary() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
    echo -e "${BOLD}${CYAN}║  📊 DETERMINE VERSION SCRIPT TEST RESULTS                 ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BOLD}📈 Test Summary:${NC}"
    echo -e "   Total tests: $TOTAL_TESTS"
    echo -e "   ${GREEN}✅ Passed: $PASSED_TESTS${NC}"
    echo -e "   ${RED}❌ Failed: $FAILED_TESTS${NC}"
    echo ""
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${BOLD}${RED}❌ Failed Tests:${NC}"
        for test_name in "${FAILED_TEST_NAMES[@]}"; do
            echo -e "   - $test_name"
        done
        echo ""
    fi
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}💥 Some tests failed!${NC}"
        return 1
    fi
}

main() {
    echo -e "${BOLD}${BLUE}🧪 Starting determine-version.sh test suite${NC}"
    echo ""
    
    # Setup
    setup_test_environment
    trap cleanup_test_environment EXIT
    
    # Run tests
    run_test "help_message" "test_help_message" "Script shows help message with --help flag"
    run_test "missing_trigger_type" "test_missing_trigger_type" "Script fails when trigger type is missing"
    run_test "invalid_trigger_type" "test_invalid_trigger_type" "Script fails with invalid trigger type"
    run_test "manual_trigger_missing_version" "test_manual_trigger_missing_version" "Manual trigger fails when version is missing"
    run_test "manual_trigger_invalid_version" "test_manual_trigger_invalid_version" "Manual trigger fails with invalid version format"
    run_test "manual_trigger_valid_version" "test_manual_trigger_valid_version" "Manual trigger succeeds with valid version"
    run_test "manual_trigger_prerelease_version" "test_manual_trigger_prerelease_version" "Manual trigger succeeds with prerelease version"
    run_test "auto_trigger_missing_package_json" "test_auto_trigger_missing_package_json" "Auto trigger fails when package.json is missing"
    run_test "auto_trigger_invalid_package_json" "test_auto_trigger_invalid_package_json" "Auto trigger fails with invalid JSON"
    run_test "auto_trigger_no_version_in_package_json" "test_auto_trigger_no_version_in_package_json" "Auto trigger fails when version field is missing"
    run_test "auto_trigger_valid_package_json" "test_auto_trigger_valid_package_json" "Auto trigger succeeds with valid package.json"
    run_test "auto_trigger_prerelease_package_json" "test_auto_trigger_prerelease_package_json" "Auto trigger succeeds with prerelease version"
    run_test "output_to_file" "test_output_to_file" "Version can be written to output file"
    run_test "environment_variable_trigger" "test_environment_variable_trigger" "Trigger type can be set via environment variable"
    run_test "verbose_output" "test_verbose_output" "Verbose mode provides detailed logging"
    run_test "semver_formats" "test_semver_formats" "Accepts various valid semver formats"
    
    # Print summary and exit
    print_test_summary
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 