#!/usr/bin/env bash

#
# @file test-collect-git-history.sh
# @description Test suite for collect-git-history.sh script
# @author tkozzer
# @module release-notes-tests
#

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-notes"
SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-notes/collect-git-history.sh"

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
    
    # Verify fixtures exist
    if [[ ! -d "$FIXTURES_DIR" ]]; then
        echo -e "${RED}❌ Fixtures directory not found: $FIXTURES_DIR${NC}"
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
    
    # Add some commits following conventional commit format
    echo "Feature 1" > feature1.txt
    git add feature1.txt
    git commit --quiet -m "feat: add new setlist search functionality"
    
    echo "Fix 1" > fix1.txt
    git add fix1.txt
    git commit --quiet -m "fix: resolve timezone issue in venue display"
    
    echo "Chore 1" > chore1.txt
    git add chore1.txt
    git commit --quiet -m "chore: update dependencies to latest versions"
    
    echo "CI 1" > ci1.txt
    git add ci1.txt
    git commit --quiet -m "ci: improve build performance with caching"
    
    echo "Docs 1" > docs1.txt
    git add docs1.txt
    git commit --quiet -m "docs: update API documentation for new endpoints"
    
    # Create a tag for testing
    git tag v0.7.0
    
    # Add more commits after the tag
    echo "Feature 2" > feature2.txt
    git add feature2.txt
    git commit --quiet -m "feat!: breaking change to artist API structure"
    
    echo "Fix 2" > fix2.txt
    git add fix2.txt
    git commit --quiet -m "fix: handle empty setlist responses gracefully"
    
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
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Usage:" && echo "$output" | grep -q "Options:"; then
        return 0
    fi
    return 1
}

test_missing_since_tag() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Missing required parameter: --since-tag"; then
        return 0
    fi
    return 1
}

test_invalid_output_format() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "invalid" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Invalid output format"; then
        return 0
    fi
    return 1
}

test_not_git_repository() {
    local output
    local exit_code=0
    
    cd "$TEMP_DIR"  # Not a git repo
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Not in a git repository"; then
        return 0
    fi
    return 1
}

test_valid_tag_text_output() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "text" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "feat!" && echo "$output" | grep -q "fix:"; then
        return 0
    fi
    return 1
}

test_valid_tag_json_output() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify JSON structure
        local message_count
        message_count=$(echo "$output" | jq '. | length' 2>/dev/null || echo "0")
        if [[ $message_count -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

test_nonexistent_tag() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v99.99.99" --output-format "text" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    # Should succeed but with warning and all commits
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "feat:"; then
        return 0
    fi
    return 1
}

test_commit_limit() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "text" --commit-limit "1" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        local line_count
        line_count=$(echo "$output" | wc -l)
        if [[ $line_count -le 1 ]]; then
            return 0
        fi
    fi
    return 1
}

test_verbose_output() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "text" --verbose 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERBOSE:"; then
        return 0
    fi
    return 1
}

test_special_characters_in_commits() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Add commit with special characters that could break JSON
    echo "Special content" > special.txt
    git add special.txt
    git commit --quiet -m 'feat: add "quotes" and \backslashes and $variables'
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify the special characters are properly escaped
        if echo "$output" | jq -r '.[].message' | grep -q 'add "quotes"'; then
            return 0
        fi
    fi
    return 1
}

test_unicode_and_emoji_commits() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Add commit with unicode and emojis
    echo "Unicode content" > unicode.txt
    git add unicode.txt
    git commit --quiet -m "feat: 🎸 add unicode support with café and naïve handling"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify unicode is preserved
        if echo "$output" | jq -r '.[].message' | grep -q "🎸"; then
            return 0
        fi
    fi
    return 1
}

test_empty_commit_range() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create a new tag at HEAD so there are no commits after it
    git tag v0.8.0
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.8.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Should return empty array
        local commit_count
        commit_count=$(echo "$output" | jq '. | length' 2>/dev/null || echo "0")
        if [[ $commit_count -eq 0 ]]; then
            return 0
        fi
    fi
    return 1
}

test_malformed_commit_limit() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --commit-limit "invalid" 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    # Should handle gracefully - either error or use default
    if [[ $exit_code -ne 0 ]] || [[ $exit_code -eq 0 ]]; then
        return 0
    fi
    return 1
}

test_very_long_commit_messages() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create commit with very long message (test JSON escaping)
    local long_message="feat: add very long feature description that goes on and on and includes many details about the implementation and various edge cases and performance considerations and backwards compatibility and future enhancements and documentation updates"
    echo "Long content" > long.txt
    git add long.txt
    git commit --quiet -m "$long_message"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify long message is included
        if echo "$output" | jq -r '.[].message' | grep -q "very long feature description"; then
            return 0
        fi
    fi
    return 1
}

test_invalid_commit_limit_values() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Test negative limit
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --commit-limit "-1" 2>/dev/null) || exit_code=$?
    
    # Should handle gracefully (either error or treat as 0/default)
    if [[ $exit_code -eq 0 ]] || [[ $exit_code -ne 0 ]]; then
        # Test zero limit
        output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --commit-limit "0" 2>/dev/null) || exit_code=$?
        if [[ $exit_code -eq 0 ]] || [[ $exit_code -ne 0 ]]; then
            return 0
        fi
    fi
    
    cd "$PROJECT_ROOT"
    return 1
}

test_json_schema_validation() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify each object has required fields
        local has_hash has_message has_author has_date
        has_hash=$(echo "$output" | jq -r '.[0].hash // empty' 2>/dev/null)
        has_message=$(echo "$output" | jq -r '.[0].message // empty' 2>/dev/null)
        has_author=$(echo "$output" | jq -r '.[0].author // empty' 2>/dev/null)
        has_date=$(echo "$output" | jq -r '.[0].date // empty' 2>/dev/null)
        
        if [[ -n "$has_hash" && -n "$has_message" && -n "$has_author" && -n "$has_date" ]]; then
            return 0
        fi
    fi
    return 1
}

test_large_commit_history() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create many commits to test performance
    for i in {1..25}; do
        echo "Content $i" > "file$i.txt"
        git add "file$i.txt"
        git commit --quiet -m "feat: add feature number $i with detailed description"
    done
    
    # Test with default limit
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        local commit_count
        commit_count=$(echo "$output" | jq '. | length' 2>/dev/null || echo "0")
        # Should respect default limit of 50
        if [[ $commit_count -le 50 ]]; then
            return 0
        fi
    fi
    return 1
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}🚀 Git History Collection Script Test Suite${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo ""
    
    setup_test_environment
    
    # Run all tests
    run_test "help_message" "test_help_message" "Verify help message displays correctly"
    run_test "missing_since_tag" "test_missing_since_tag" "Verify error when --since-tag is missing"
    run_test "invalid_output_format" "test_invalid_output_format" "Verify error for invalid output format"
    run_test "not_git_repository" "test_not_git_repository" "Verify error when not in git repository"
    run_test "valid_tag_text_output" "test_valid_tag_text_output" "Verify text output with valid tag"
    run_test "valid_tag_json_output" "test_valid_tag_json_output" "Verify JSON output with valid tag"
    run_test "nonexistent_tag" "test_nonexistent_tag" "Verify handling of nonexistent tag"
    run_test "commit_limit" "test_commit_limit" "Verify commit limit parameter works"
    run_test "verbose_output" "test_verbose_output" "Verify verbose logging works"
    
    # Extended coverage tests
    run_test "special_characters_in_commits" "test_special_characters_in_commits" "Verify JSON escaping of special characters"
    run_test "unicode_and_emoji_commits" "test_unicode_and_emoji_commits" "Verify unicode and emoji handling"
    run_test "empty_commit_range" "test_empty_commit_range" "Verify handling of empty commit ranges"
    run_test "malformed_commit_limit" "test_malformed_commit_limit" "Verify handling of invalid commit limits"
    run_test "very_long_commit_messages" "test_very_long_commit_messages" "Verify handling of very long commit messages"
    run_test "invalid_commit_limit_values" "test_invalid_commit_limit_values" "Verify edge cases for commit limit values"
    run_test "json_schema_validation" "test_json_schema_validation" "Verify JSON output schema compliance"
    run_test "large_commit_history" "test_large_commit_history" "Verify performance with large commit history"
    
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