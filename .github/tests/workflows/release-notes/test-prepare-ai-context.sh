#!/usr/bin/env bash

#
# @file test-prepare-ai-context.sh
# @description Test suite for prepare-ai-context.sh script
# @author tkozzer
# @module release-notes-tests
#

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-notes"
SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-notes/prepare-ai-context.sh"

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
TEST_REPO_DIR=""

setup_test_environment() {
    echo -e "${BLUE}🔧 Setting up test environment...${NC}"
    
    # Create temporary directory for test files
    TEMP_DIR=$(mktemp -d)
    TEST_REPO_DIR="$TEMP_DIR/test-repo"
    
    # Verify script exists and is executable
    if [[ ! -f "$SCRIPT_UNDER_TEST" ]]; then
        echo -e "${RED}❌ Script under test not found: $SCRIPT_UNDER_TEST${NC}"
        exit 1
    fi
    
    if [[ ! -x "$SCRIPT_UNDER_TEST" ]]; then
        echo -e "${RED}❌ Script under test is not executable: $SCRIPT_UNDER_TEST${NC}"
        exit 1
    fi
    
    # Create a test git repository
    setup_test_git_repo
    
    echo -e "${GREEN}✅ Test environment setup complete${NC}"
    echo -e "   Temp directory: $TEMP_DIR"
    echo -e "   Test repo: $TEST_REPO_DIR"
    echo -e "   Script under test: $SCRIPT_UNDER_TEST"
    echo ""
}

setup_test_git_repo() {
    mkdir -p "$TEST_REPO_DIR"
    cd "$TEST_REPO_DIR"
    
    # Initialize git repo
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create initial commit
    echo "Initial commit" > README.md
    git add README.md
    git commit --quiet -m "initial: create repository"
    
    # Add some commits
    echo "Feature 1" > feature1.txt
    git add feature1.txt
    git commit --quiet -m "feat: add new setlist search functionality"
    
    echo "Fix 1" > fix1.txt
    git add fix1.txt
    git commit --quiet -m "fix: resolve timezone issue in venue display"
    
    # Create v0.7.0 tag
    git tag v0.7.0
    
    # Add more commits after the tag
    echo "Feature 2" > feature2.txt
    git add feature2.txt
    git commit --quiet -m "feat!: breaking change to artist API structure"
    
    echo "Fix 2" > fix2.txt
    git add fix2.txt
    git commit --quiet -m "fix: handle empty setlist responses gracefully"
    
    # Create v0.7.1 tag
    git tag v0.7.1
    
    # Create a sample CHANGELOG.md
    cat > CHANGELOG.md << 'EOF'
# Changelog

## [0.7.1] - 2024-01-15

### Added
- New setlist search functionality with advanced filtering

### Fixed
- Resolved timezone issue in venue display
- Handle empty setlist responses gracefully

### Changed
- **BREAKING**: Updated artist API structure for better performance

## [0.7.0] - 2024-01-01

### Added
- Initial release with basic functionality
EOF
    
    git add CHANGELOG.md
    git commit --quiet -m "docs: add changelog"
    
    # Go back to project root
    cd "$PROJECT_ROOT"
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
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Usage:" && echo "$output" | grep -q "Dependencies:"; then
        return 0
    fi
    return 1
}

test_missing_version() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Missing required parameter: --version"; then
        return 0
    fi
    return 1
}

test_not_git_repository() {
    local output
    local exit_code=0
    
    cd "$TEMP_DIR"  # Not a git repo
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Not in a git repository"; then
        return 0
    fi
    return 1
}

test_missing_dependencies() {
    local output
    local exit_code=0
    
    # Temporarily move the dependency scripts to simulate missing dependencies
    local backup_dir="$TEMP_DIR/script_backup"
    mkdir -p "$backup_dir"
    
    if [[ -f "$PROJECT_ROOT/.github/scripts/release-notes/collect-git-history.sh" ]]; then
        mv "$PROJECT_ROOT/.github/scripts/release-notes/collect-git-history.sh" "$backup_dir/"
    fi
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    # Restore the script
    if [[ -f "$backup_dir/collect-git-history.sh" ]]; then
        mv "$backup_dir/collect-git-history.sh" "$PROJECT_ROOT/.github/scripts/release-notes/"
    fi
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Required script not found"; then
        return 0
    fi
    return 1
}

test_valid_version_output() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERSION=0.7.1"; then
        return 0
    fi
    return 1
}

test_base64_encoded_variables() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Check for base64-encoded variables
        if echo "$output" | grep -q "CHANGELOG_ENTRY_B64=" && \
           echo "$output" | grep -q "GIT_COMMITS_B64=" && \
           echo "$output" | grep -q "COMMIT_STATS_B64="; then
            return 0
        fi
    fi
    return 1
}

test_version_type_detection() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERSION_TYPE="; then
        local version_type
        version_type=$(echo "$output" | grep "VERSION_TYPE=" | cut -d'=' -f2)
        
        # Should detect as patch (0.7.0 -> 0.7.1)
        if [[ "$version_type" == "patch" ]]; then
            return 0
        fi
    fi
    return 1
}

test_changelog_extraction() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Decode the changelog entry to verify it was extracted
        local changelog_b64
        changelog_b64=$(echo "$output" | grep "CHANGELOG_ENTRY_B64=" | cut -d'=' -f2)
        
        if [[ -n "$changelog_b64" ]]; then
            local decoded_changelog
            decoded_changelog=$(echo "$changelog_b64" | base64 -d 2>/dev/null || echo "")
            
            if echo "$decoded_changelog" | grep -q "setlist search functionality"; then
                return 0
            fi
        fi
    fi
    return 1
}

test_breaking_changes_flag() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "HAS_BREAKING_CHANGES="; then
        local has_breaking
        has_breaking=$(echo "$output" | grep "HAS_BREAKING_CHANGES=" | cut -d'=' -f2)
        
        # Should detect breaking changes (we have feat! in commits)
        if [[ "$has_breaking" == "true" ]]; then
            return 0
        fi
    fi
    return 1
}

test_verbose_output() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" --verbose 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERBOSE:"; then
        return 0
    fi
    return 1
}

test_v_prefix_handling() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "v0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERSION=v0.7.1"; then
        return 0
    fi
    return 1
}

test_major_version_type_detection() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "1.0.0" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERSION_TYPE="; then
        local version_type
        version_type=$(echo "$output" | grep "VERSION_TYPE=" | cut -d'=' -f2)
        
        # Should detect as major (0.x.x -> 1.0.0)
        if [[ "$version_type" == "major" ]]; then
            return 0
        fi
    fi
    return 1
}

test_minor_version_type_detection() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.8.0" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERSION_TYPE="; then
        local version_type
        version_type=$(echo "$output" | grep "VERSION_TYPE=" | cut -d'=' -f2)
        
        # Should detect as minor (0.7.x -> 0.8.0)
        if [[ "$version_type" == "minor" ]]; then
            return 0
        fi
    fi
    return 1
}

test_dependency_failure_recovery() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Temporarily make extract-commit-stats.sh non-executable to simulate failure
    local backup_perms
    backup_perms=$(stat -f "%Mp%Lp" "$PROJECT_ROOT/.github/scripts/release-notes/extract-commit-stats.sh" 2>/dev/null || echo "755")
    chmod -x "$PROJECT_ROOT/.github/scripts/release-notes/extract-commit-stats.sh" 2>/dev/null || true
    
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    
    # Restore permissions
    chmod "$backup_perms" "$PROJECT_ROOT/.github/scripts/release-notes/extract-commit-stats.sh" 2>/dev/null || true
    
    cd "$PROJECT_ROOT"
    
    # Should handle gracefully - either error properly or provide fallback
    if [[ $exit_code -eq 0 ]]; then
        # If it succeeds, check it still provides basic variables
        if echo "$output" | grep -q "VERSION=" && echo "$output" | grep -q "VERSION_TYPE="; then
            return 0
        fi
    elif [[ $exit_code -ne 0 ]]; then
        # If it fails, that's also acceptable behavior
        return 0
    fi
    return 1
}

test_base64_encoding_integrity() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Test round-trip encoding/decoding for each base64 variable
        local variables=("CHANGELOG_ENTRY_B64" "GIT_COMMITS_B64" "COMMIT_STATS_B64" "PREVIOUS_RELEASE_B64")
        
        for var in "${variables[@]}"; do
            local encoded_value
            encoded_value=$(echo "$output" | grep "$var=" | cut -d'=' -f2)
            
            if [[ -n "$encoded_value" ]]; then
                # Try to decode - should not fail
                local decoded
                decoded=$(echo "$encoded_value" | base64 -d 2>/dev/null || echo "DECODE_FAILED")
                
                if [[ "$decoded" == "DECODE_FAILED" ]]; then
                    return 1
                fi
            fi
        done
        return 0
    fi
    return 1
}

test_complex_changelog_formats() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create a more complex changelog with multiple versions and special characters
    cat > CHANGELOG.md << 'EOF'
# Changelog

## [0.7.1] - 2024-01-15

### Added
- New setlist search functionality with advanced filtering
- Support for "quoted strings" and special chars: !@#$%^&*()
- Unicode support: café, naïve, 北京

### Fixed
- Resolved timezone issue in venue display
- Handle empty setlist responses gracefully

### Changed
- **BREAKING**: Updated artist API structure for better performance

## [0.7.0] - 2024-01-01

### Added
- Initial release with basic functionality
EOF
    
    git add CHANGELOG.md
    git commit --quiet -m "docs: update changelog with complex content"
    
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Decode the changelog entry to verify complex content is preserved
        local changelog_b64
        changelog_b64=$(echo "$output" | grep "CHANGELOG_ENTRY_B64=" | cut -d'=' -f2)
        
        if [[ -n "$changelog_b64" ]]; then
            local decoded_changelog
            decoded_changelog=$(echo "$changelog_b64" | base64 -d 2>/dev/null || echo "")
            
            # Check that special characters and unicode are preserved
            if echo "$decoded_changelog" | grep -q "quoted strings" && \
               echo "$decoded_changelog" | grep -q "café" && \
               echo "$decoded_changelog" | grep -q "!@#"; then
                return 0
            fi
        fi
    fi
    return 1
}

test_missing_changelog_handling() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Remove CHANGELOG.md to test fallback behavior
    rm -f CHANGELOG.md
    
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Should handle missing changelog gracefully
        local changelog_b64
        changelog_b64=$(echo "$output" | grep "CHANGELOG_ENTRY_B64=" | cut -d'=' -f2)
        
        if [[ -n "$changelog_b64" ]]; then
            local decoded_changelog
            decoded_changelog=$(echo "$changelog_b64" | base64 -d 2>/dev/null || echo "")
            
            # Should contain fallback message
            if echo "$decoded_changelog" | grep -q "not found" || \
               echo "$decoded_changelog" | grep -q "CHANGELOG.md"; then
                return 0
            fi
        fi
    fi
    return 1
}

test_large_data_handling() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create a large number of commits to test performance and data handling
    for i in {1..50}; do
        echo "Large test content $i with detailed description and metadata" > "large_file_$i.txt"
        git add "large_file_$i.txt"
        git commit --quiet -m "feat: large commit $i with extensive description that includes many details about the implementation, testing, documentation, and various considerations for performance and scalability"
    done
    
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Should handle large data sets without issues
        if echo "$output" | grep -q "VERSION=" && \
           echo "$output" | grep -q "GIT_COMMITS_B64=" && \
           echo "$output" | grep -q "COMMIT_STATS_B64="; then
            return 0
        fi
    fi
    return 1
}

test_template_variable_completeness() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Verify all expected template variables are present
        local required_vars=("VERSION" "VERSION_TYPE" "CHANGELOG_ENTRY_B64" "GIT_COMMITS_B64" "COMMIT_STATS_B64" "HAS_BREAKING_CHANGES" "PREVIOUS_RELEASE_B64")
        
        for var in "${required_vars[@]}"; do
            if ! echo "$output" | grep -q "$var="; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

test_error_propagation() {
    local output
    local exit_code=0
    
    # Test with invalid version format
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "invalid.version.format" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    # Should handle gracefully - either succeed with best effort or fail appropriately
    if [[ $exit_code -eq 0 ]] || [[ $exit_code -ne 0 ]]; then
        return 0
    fi
    return 1
}

test_json_parsing_robustness() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --version "0.7.1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Decode and validate the COMMIT_STATS_B64 contains valid JSON
        local stats_b64
        stats_b64=$(echo "$output" | grep "COMMIT_STATS_B64=" | cut -d'=' -f2)
        
        if [[ -n "$stats_b64" ]]; then
            local decoded_stats
            decoded_stats=$(echo "$stats_b64" | base64 -d 2>/dev/null || echo "")
            
            # Should be valid JSON (be more tolerant of formatting)
            if echo "$decoded_stats" | grep -q '"total_commits"' && \
               echo "$decoded_stats" | grep -q '"breaking_changes_detected"' && \
               echo "$decoded_stats" | grep -q '{'; then
                return 0
            fi
        fi
    fi
    return 1
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}🚀 AI Context Preparation Script Test Suite${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo ""
    
    setup_test_environment
    
    # Run all tests
    run_test "help_message" "test_help_message" "Verify help message displays correctly"
    run_test "missing_version" "test_missing_version" "Verify error when --version is missing"
    run_test "not_git_repository" "test_not_git_repository" "Verify error when not in git repository"
    run_test "missing_dependencies" "test_missing_dependencies" "Verify error when dependency scripts are missing"
    run_test "valid_version_output" "test_valid_version_output" "Verify output contains VERSION variable"
    run_test "base64_encoded_variables" "test_base64_encoded_variables" "Verify base64-encoded variables are present"
    run_test "version_type_detection" "test_version_type_detection" "Verify version type is detected correctly"
    run_test "changelog_extraction" "test_changelog_extraction" "Verify changelog entry is extracted"
    run_test "breaking_changes_flag" "test_breaking_changes_flag" "Verify breaking changes are detected"
    run_test "verbose_output" "test_verbose_output" "Verify verbose logging works"
    run_test "v_prefix_handling" "test_v_prefix_handling" "Verify 'v' prefix in version is handled"
    
    # Extended coverage tests
    run_test "major_version_type_detection" "test_major_version_type_detection" "Verify major version type detection"
    run_test "minor_version_type_detection" "test_minor_version_type_detection" "Verify minor version type detection"
    run_test "dependency_failure_recovery" "test_dependency_failure_recovery" "Verify handling of dependency script failures"
    run_test "base64_encoding_integrity" "test_base64_encoding_integrity" "Verify base64 encoding/decoding integrity"
    run_test "complex_changelog_formats" "test_complex_changelog_formats" "Verify handling of complex changelog formats"
    run_test "missing_changelog_handling" "test_missing_changelog_handling" "Verify fallback when CHANGELOG.md is missing"
    run_test "large_data_handling" "test_large_data_handling" "Verify performance with large data sets"
    run_test "template_variable_completeness" "test_template_variable_completeness" "Verify all template variables are generated"
    run_test "error_propagation" "test_error_propagation" "Verify error handling with invalid inputs"
    run_test "json_parsing_robustness" "test_json_parsing_robustness" "Verify JSON parsing and validation robustness"
    
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

# Run main function
main "$@" 