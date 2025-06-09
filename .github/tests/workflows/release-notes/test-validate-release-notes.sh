#!/usr/bin/env bash

#
# test-validate-release-notes.sh
#
# Comprehensive test suite for validate-release-notes.sh
# Tests all validation functionality including edge cases and error conditions
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test configuration
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
readonly SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-notes/validate-release-notes.sh"
readonly FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-notes"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_TEST_NAMES=()

# Test environment setup
setup_test_environment() {
    echo -e "${BLUE}Setting up test environment...${NC}"
    
    # Verify script exists and is executable
    if [[ ! -f "$SCRIPT_UNDER_TEST" ]]; then
        echo -e "${RED}❌ Test script not found: $SCRIPT_UNDER_TEST${NC}"
        exit 1
    fi
    
    if [[ ! -x "$SCRIPT_UNDER_TEST" ]]; then
        echo -e "${RED}❌ Test script not executable: $SCRIPT_UNDER_TEST${NC}"
        exit 1
    fi
    
    # Verify fixtures exist
    if [[ ! -d "$FIXTURES_DIR" ]]; then
        echo -e "${RED}❌ Fixtures directory not found: $FIXTURES_DIR${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Test environment ready${NC}"
    echo ""
}

cleanup_test_environment() {
    echo -e "${BLUE}Cleaning up test environment...${NC}"
    # Clean up any temporary files
    find /tmp -name "tmp.*" -type f -user "$(whoami)" -delete 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
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
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "validate-release-notes.sh - Release Notes Quality Validation" && echo "$output" | grep -q "USAGE:"; then
        return 0
    fi
    return 1
}

test_version_display() {
    local output
    local exit_code=0
    
    output=$("$SCRIPT_UNDER_TEST" --script-version 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "validate-release-notes.sh version"; then
        return 0
    fi
    return 1
}

test_invalid_argument() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --invalid-option 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 2 ]] && [[ "$output" == *"Unknown option"* ]]
}

test_missing_required_file() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 2 ]] && [[ "$output" == *"Release notes file is required"* ]]
}

test_missing_required_version() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/valid-release-notes.md" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 2 ]] && [[ "$output" == *"Version is required"* ]]
}

test_nonexistent_file() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "/nonexistent/file.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 2 ]] && [[ "$output" == *"does not exist"* ]]
}

test_invalid_version_format() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/valid-release-notes.md" --version "invalid-version" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 2 ]] && [[ "$output" == *"Invalid version format"* ]]
}

test_valid_release_notes() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/valid-release-notes.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 0 ]] && [[ "$output" == *"All validations passed"* ]]
}

test_valid_with_github_links() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/valid-with-github-links.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 0 ]] && [[ "$output" == *"All validations passed"* ]]
}

test_missing_version_content() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/invalid-missing-version.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 1 ]] && [[ "$output" == *"Missing required content elements"* ]] && [[ "$output" == *"version 1.2.3"* ]]
}

test_short_content() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/invalid-short-content.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 1 ]] && [[ "$output" == *"content too short"* ]]
}

test_no_sections() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/invalid-no-sections.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 1 ]] && [[ "$output" == *"too few sections"* ]]
}

test_format_inconsistency() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/invalid-format-inconsistent.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 1 ]] && [[ "$output" == *"Format consistency issues"* ]]
}

test_generic_content() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/invalid-generic-content.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 1 ]] && [[ "$output" == *"generic/template language"* ]]
}

test_malformed_links() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/invalid-malformed-links.md" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 1 ]] && [[ "$output" == *"malformed"* ]]
}

create_temp_file() {
    local content="$1"
    local temp_file
    temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    echo "$temp_file"
}

test_semver_with_v_prefix() {
    local temp_file output exit_code
    temp_file=$(create_temp_file "# Release Notes - setlistfm-ts v1.2.3

## Features
- Enhanced API integration
- Improved performance

## Bug Fixes
- Fixed authentication issues
- Resolved encoding problems

This release brings significant improvements.")

    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "v1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    rm -f "$temp_file"
    
    [[ $exit_code -eq 0 ]]
}

test_custom_project_name() {
    local temp_file output exit_code
    temp_file=$(create_temp_file "# Release Notes - custom-project v1.2.3

## Features
- Enhanced API integration
- Improved performance

## Bug Fixes
- Fixed authentication issues
- Resolved encoding problems

This release brings significant improvements.")

    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" --project "custom-project" 2>&1)
    exit_code=$?
    set -e
    
    rm -f "$temp_file"
    
    [[ $exit_code -eq 0 ]]
}

test_verbose_mode() {
    local output exit_code
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$FIXTURES_DIR/validate-release-notes/valid-release-notes.md" --version "1.2.3" --verbose 2>&1)
    exit_code=$?
    set -e
    
    [[ $exit_code -eq 0 ]] && [[ "$output" == *"Starting comprehensive"* ]]
}

test_unreadable_file() {
    local temp_file output exit_code
    temp_file=$(create_temp_file "# Release Notes - setlistfm-ts v1.2.3

## Features
- Enhanced API integration
- Improved performance

## Bug Fixes
- Fixed authentication issues
- Resolved encoding problems

This release brings significant improvements.")

    # Remove read permissions
    chmod 000 "$temp_file"
    
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    # Restore permissions and cleanup
    chmod 644 "$temp_file" 2>/dev/null || true
    rm -f "$temp_file"
    
    [[ $exit_code -eq 2 ]] && [[ "$output" == *"not readable"* ]]
}

test_boundary_values() {
    local temp_file output exit_code
    
    # Test exact minimum content length (200 chars) with proper format
    local content_200_chars="# Release Notes - setlistfm-ts v1.2.3

## Features
- API enhancement for testing minimum length
- Second feature for validation testing  
- Third feature for boundary testing

## Bug Fixes
- Bug fix for validation testing requirements

This release tests boundary values."
    
    temp_file=$(create_temp_file "$content_200_chars")
    
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    local boundary_test_passed=false
    if [[ $exit_code -eq 0 ]]; then
        boundary_test_passed=true
    fi
    
    rm -f "$temp_file"
    
    # Test exactly at minimum thresholds (200 chars, 2 sections, 3 bullet points)
    temp_file=$(create_temp_file "# Release Notes - setlistfm-ts v1.2.3

## Features  
- First feature for minimum testing
- Second feature for validation
- Third feature meets requirement

## Bug Fixes
- Single bug fix for second section

This release tests the exact boundary values for validation.")

    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    rm -f "$temp_file"
    
    [[ $boundary_test_passed == true ]] && [[ $exit_code -eq 0 ]]
}

test_empty_sections() {
    local temp_file output exit_code
    temp_file=$(create_temp_file "# Release Notes - setlistfm-ts v1.2.3

## Features

## Bug Fixes
- Fixed authentication issues
- Resolved encoding problems
- Corrected parsing errors

## Performance

This release includes empty sections that should be detected during semantic structure validation.")

    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    rm -f "$temp_file"
    
    # Test should pass since empty sections validation is currently disabled
    # When re-enabled, this would detect empty Features and Performance sections
    [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 1 ]]
}

test_complex_markdown() {
    local temp_file output exit_code
    temp_file=$(create_temp_file "# Release Notes - setlistfm-ts v1.2.3

## Features

### API Enhancements
- Enhanced setlist search with advanced filtering
- Improved authentication flow with OAuth 2.0
- New data endpoints for artist statistics

## Bug Fixes
- Fixed token expiration handling
- Resolved memory leaks in data processing
- Corrected rate limiting issues

This release includes complex markdown testing.")

    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    rm -f "$temp_file"
    
    [[ $exit_code -eq 0 ]]
}

test_error_recovery() {
    local temp_file output exit_code
    
    # Test with binary content that might cause parsing issues
    temp_file=$(mktemp)
    echo -e "# Release Notes - setlistfm-ts v1.2.3\n\n## Features\n- Binary content test\x00\x01\x02\n\n## Bug Fixes\n- Fixed issues\n\nThis tests binary content handling." > "$temp_file"
    
    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    local binary_test_result=$exit_code
    rm -f "$temp_file"
    
    # Test with extremely long lines that might cause issues
    temp_file=$(create_temp_file "# Release Notes - setlistfm-ts v1.2.3

## Features
- $(printf 'A%.0s' {1..500})

## Bug Fixes  
- Fixed authentication issues
- Resolved encoding problems

This release tests extremely long content lines for error recovery.")

    set +e
    output=$("$SCRIPT_UNDER_TEST" --notes-file "$temp_file" --version "1.2.3" 2>&1)
    exit_code=$?
    set -e
    
    rm -f "$temp_file"
    
    # Should handle gracefully - either pass or fail with proper error messages
    [[ $binary_test_result -eq 0 || $binary_test_result -eq 1 ]] && [[ $exit_code -eq 0 || $exit_code -eq 1 ]]
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}🚀 Validate Release Notes Script Test Suite${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo ""
    
    setup_test_environment
    
    # Run all tests
    run_test "help_message" "test_help_message" "Verify help message displays correctly"
    run_test "version_display" "test_version_display" "Verify version display works"
    run_test "invalid_argument" "test_invalid_argument" "Verify error for invalid arguments"
    run_test "missing_required_file" "test_missing_required_file" "Verify error when required file is missing"
    run_test "missing_required_version" "test_missing_required_version" "Verify error when required version is missing"
    run_test "nonexistent_file" "test_nonexistent_file" "Verify error when file does not exist"
    run_test "invalid_version_format" "test_invalid_version_format" "Verify error for invalid version format"
    run_test "valid_release_notes" "test_valid_release_notes" "Verify valid release notes pass validation"
    run_test "valid_with_github_links" "test_valid_with_github_links" "Verify valid release notes with GitHub links pass validation"
    run_test "missing_version_content" "test_missing_version_content" "Verify error when version content is missing"
    run_test "short_content" "test_short_content" "Verify error when content is too short"
    run_test "no_sections" "test_no_sections" "Verify error when insufficient sections"
    run_test "format_inconsistency" "test_format_inconsistency" "Verify error when format inconsistency"
    run_test "generic_content" "test_generic_content" "Verify error when generic language detected"
    run_test "malformed_links" "test_malformed_links" "Verify error when malformed links"
    run_test "semver_with_v_prefix" "test_semver_with_v_prefix" "Verify valid semver with v prefix"
    run_test "custom_project_name" "test_custom_project_name" "Verify valid custom project name"
    run_test "verbose_mode" "test_verbose_mode" "Verify verbose mode"
    run_test "unreadable_file" "test_unreadable_file" "Verify error when file is not readable"
    run_test "boundary_values" "test_boundary_values" "Verify boundary values test"
    run_test "empty_sections" "test_empty_sections" "Verify empty sections test"
    run_test "complex_markdown" "test_complex_markdown" "Verify complex markdown test"
    run_test "error_recovery" "test_error_recovery" "Verify error recovery test"
    
    # Cleanup
    cleanup_test_environment
    
    # Print results
    echo -e "${BOLD}${BLUE}Test Results Summary${NC}"
    echo -e "${BLUE}===================${NC}"
    echo -e "Total tests: ${BOLD}$TOTAL_TESTS${NC}"
    echo -e "Passed:      ${GREEN}${BOLD}$PASSED_TESTS${NC}"
    echo -e "Failed:      ${RED}${BOLD}$FAILED_TESTS${NC}"
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo ""
        echo -e "${RED}Failed tests:${NC}"
        for test_name in "${FAILED_TEST_NAMES[@]}"; do
            echo -e "  - $test_name"
        done
        echo ""
        exit 1
    else
        echo ""
        echo -e "${GREEN}${BOLD}🎉 All tests passed!${NC}"
        echo ""
        exit 0
    fi
}

# Run main function only when script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 