#!/usr/bin/env bash
set -euo pipefail

# Test script to verify version-specific changelog extraction functionality
# This test verifies that the --version parameter correctly extracts specific version entries

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

run_version_test() {
    local test_name="$1"
    local version="$2"
    local expected_content="$3"
    local changelog_file="$4"
    
    echo_test "$test_name"
    
    total_tests=$((total_tests + 1))
    
    # Capture output and exit code
    local actual_output
    local actual_exit_code
    
    local args
    if [[ -n "$version" ]]; then
        args="--version $version --changelog $changelog_file --output-format plain"
    else
        args="--changelog $changelog_file --output-format plain"
    fi
    
    if actual_output=$("$EXTRACT_SCRIPT" $args 2>/dev/null); then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    # Check exit code
    if [[ "$actual_exit_code" != "0" ]]; then
        echo_fail "Command failed with exit code: $actual_exit_code"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
    
    # Check if output contains expected content
    if [[ "$actual_output" == *"$expected_content"* ]]; then
        echo_pass "Test passed - extracted correct content"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        echo_fail "Content mismatch"
        echo "   Expected to contain: $expected_content"
        echo "   Actual output: $actual_output"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

main() {
    echo -e "${BLUE}🚀 Testing Version-Specific Changelog Extraction${NC}"
    echo ""
    
    # Create a test changelog with multiple versions
    local temp_changelog
    temp_changelog=$(mktemp)
    cat > "$temp_changelog" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [0.8.0] - 2024-06-15

### Added
- Version 0.8.0 feature A
- Version 0.8.0 feature B

### Changed
- Version 0.8.0 change A

## [0.7.2] - 2024-06-09

### Added
- Version 0.7.2 feature A
- Version 0.7.2 feature B

### Fixed
- Version 0.7.2 bug fix A

## [0.7.1] - 2024-06-01

### Fixed
- Version 0.7.1 bug fix A
- Version 0.7.1 bug fix B

## [0.7.0] - 2024-05-20

### Added
- Version 0.7.0 initial release
- Version 0.7.0 basic functionality

### Changed
- Version 0.7.0 improved performance
EOF
    
    echo -e "${YELLOW}Testing version-specific extraction:${NC}"
    echo ""
    
    # Test extraction of specific versions
    run_version_test \
        "Extract version 0.8.0" \
        "0.8.0" \
        "Version 0.8.0 feature A" \
        "$temp_changelog"
    
    run_version_test \
        "Extract version 0.7.2" \
        "0.7.2" \
        "Version 0.7.2 bug fix A" \
        "$temp_changelog"
    
    run_version_test \
        "Extract version 0.7.1" \
        "0.7.1" \
        "Version 0.7.1 bug fix B" \
        "$temp_changelog"
    
    run_version_test \
        "Extract version 0.7.0" \
        "0.7.0" \
        "Version 0.7.0 initial release" \
        "$temp_changelog"
    
    # Test extraction without version (should get latest)
    run_version_test \
        "Extract latest version (no --version param)" \
        "" \
        "Version 0.8.0 feature A" \
        "$temp_changelog"
    
    echo ""
    echo -e "${YELLOW}Testing edge cases:${NC}"
    echo ""
    
    # Test non-existent version
    echo_test "Test non-existent version 0.9.0"
    total_tests=$((total_tests + 1))
    
    local output
    if output=$("$EXTRACT_SCRIPT" --version "0.9.0" --changelog "$temp_changelog" --output-format plain 2>/dev/null); then
        if [[ "$output" == *"No changelog entries found for version 0.9.0"* ]]; then
            echo_pass "Test passed - correctly handled non-existent version"
            passed_tests=$((passed_tests + 1))
        else
            echo_fail "Unexpected output for non-existent version: $output"
            failed_tests=$((failed_tests + 1))
        fi
    else
        echo_fail "Command failed unexpectedly"
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test version with 'v' prefix
    local temp_changelog_v_prefix
    temp_changelog_v_prefix=$(mktemp)
    cat > "$temp_changelog_v_prefix" << 'EOF'
# Changelog

## [v1.0.0] - 2024-06-20

### Added
- Version with v prefix

## [0.9.0] - 2024-06-15

### Added
- Version without v prefix
EOF
    
    run_version_test \
        "Extract version with 'v' prefix" \
        "v1.0.0" \
        "Version with v prefix" \
        "$temp_changelog_v_prefix"
    
    # Cleanup
    rm -f "$temp_changelog" "$temp_changelog_v_prefix"
    
    # Test summary
    echo ""
    echo -e "${BLUE}📊 Test Summary:${NC}"
    echo "   Total tests: $total_tests"
    echo "   Passed: $passed_tests"
    echo "   Failed: $failed_tests"
    
    if [[ $failed_tests -gt 0 ]]; then
        echo ""
        echo -e "${RED}❌ Some version extraction tests failed!${NC}"
        return 1
    else
        echo ""
        echo -e "${GREEN}✅ All version extraction tests passed!${NC}"
        echo "   Version-specific extraction is working correctly"
        return 0
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 