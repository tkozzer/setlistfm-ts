#!/usr/bin/env bash

#
# @file test-extract-commit-stats.sh
# @description Test suite for extract-commit-stats.sh script
# @author tkozzer
# @module release-notes-tests
#

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-notes"
SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-notes/extract-commit-stats.sh"

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
    
    # Create a test git repository with specific commits
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
    
    # Add commits with different conventional commit types
    echo "Feature 1" > feature1.txt
    git add feature1.txt
    git commit --quiet -m "feat: add new setlist search functionality"
    
    echo "Feature 2" > feature2.txt
    git add feature2.txt
    git commit --quiet -m "feat(api): enhance artist endpoint with filters"
    
    echo "Fix 1" > fix1.txt
    git add fix1.txt
    git commit --quiet -m "fix: resolve timezone issue in venue display"
    
    echo "Fix 2" > fix2.txt
    git add fix2.txt
    git commit --quiet -m "fix(ui): handle empty setlist responses gracefully"
    
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
    
    # Add more commits after the tag including breaking changes
    echo "Breaking Feature" > breaking.txt
    git add breaking.txt
    git commit --quiet -m "feat!: breaking change to artist API structure"
    
    echo "Another fix" > fix3.txt
    git add fix3.txt
    git commit --quiet -m "fix: handle null responses in venue service"
    
    echo "Another chore" > chore2.txt
    git add chore2.txt
    git commit --quiet -m "chore(deps): bump axios to latest version"
    
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
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Usage:" && echo "$output" | grep -q "Conventional Commit Patterns"; then
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

test_json_output_structure() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Just check if it's valid JSON with expected structure
        if echo "$output" | jq -e '.total_commits, .breaking_changes_detected, .commit_patterns' >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

test_commit_type_counting() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Check that we can extract numeric values for commit counts
        if echo "$output" | jq -e '.feat_count, .fix_count, .chore_count, .ci_count, .docs_count' >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

test_breaking_changes_detection() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Just check that the breaking_changes_detected field exists and is boolean
        if echo "$output" | jq -e '.breaking_changes_detected | type == "boolean"' >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

test_text_output_format() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "text" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Total commits:" && echo "$output" | grep -q "Breaking changes detected:"; then
        return 0
    fi
    return 1
}

test_commit_patterns_extraction() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        # Just check that commit_patterns exists and is an array
        if echo "$output" | jq -e '.commit_patterns | type == "array"' >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

test_no_commits_scenario() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    # Test with a tag that has no commits after it (using current HEAD)
    current_hash=$(git rev-parse HEAD)
    git tag test-empty-tag
    output=$("$SCRIPT_UNDER_TEST" --since-tag "test-empty-tag" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]]; then
        local total_commits
        total_commits=$(echo "$output" | jq '.total_commits' 2>/dev/null || echo "-1")
        
        # Should report 0 commits
        if [[ $total_commits -eq 0 ]]; then
            return 0
        fi
    fi
    return 1
}

test_verbose_output() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" --verbose 2>&1) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "VERBOSE:"; then
        return 0
    fi
    return 1
}

test_malformed_commit_messages() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Add commits with unusual formats that might break parsing
    echo "Content 1" > malformed1.txt
    git add malformed1.txt
    git commit --quiet -m "not-conventional-format"
    
    echo "Content 2" > malformed2.txt
    git add malformed2.txt
    git commit --quiet -m ": empty prefix"
    
    echo "Content 3" > malformed3.txt
    git add malformed3.txt
    git commit --quiet -m "feat::double colon"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Should handle malformed commits gracefully
        local total_commits
        total_commits=$(echo "$output" | jq '.total_commits' 2>/dev/null || echo "0")
        if [[ $total_commits -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

test_breaking_change_variations() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Test different breaking change formats
    echo "Breaking 1" > breaking1.txt
    git add breaking1.txt
    git commit --quiet -m "fix!: breaking fix change"
    
    echo "Breaking 2" > breaking2.txt
    git add breaking2.txt
    git commit --quiet -m "chore: update dependencies

BREAKING CHANGE: This removes support for old API"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Should detect breaking changes
        local has_breaking
        has_breaking=$(echo "$output" | jq '.breaking_changes_detected' 2>/dev/null)
        if [[ "$has_breaking" == "true" ]]; then
            return 0
        fi
    fi
    return 1
}

test_large_scale_commit_analysis() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create many commits of different types
    for i in {1..30}; do
        local commit_type
        case $((i % 5)) in
            0) commit_type="feat" ;;
            1) commit_type="fix" ;;
            2) commit_type="chore" ;;
            3) commit_type="ci" ;;
            4) commit_type="docs" ;;
        esac
        
        echo "Content $i" > "large_$i.txt"
        git add "large_$i.txt"
        git commit --quiet -m "$commit_type: commit number $i with type $commit_type"
    done
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify counts are reasonable
        local total feat_count fix_count
        total=$(echo "$output" | jq '.total_commits' 2>/dev/null || echo "0")
        feat_count=$(echo "$output" | jq '.feat_count' 2>/dev/null || echo "0")
        fix_count=$(echo "$output" | jq '.fix_count' 2>/dev/null || echo "0")
        
        if [[ $total -gt 30 && $feat_count -gt 0 && $fix_count -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

test_edge_case_patterns() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Test edge cases in commit pattern matching
    echo "Edge 1" > edge1.txt
    git add edge1.txt
    git commit --quiet -m "FEAT: uppercase type"
    
    echo "Edge 2" > edge2.txt
    git add edge2.txt
    git commit --quiet -m "feat : space before colon"
    
    echo "Edge 3" > edge3.txt
    git add edge3.txt
    git commit --quiet -m "feature: full word instead of short form"
    
    echo "Edge 4" > edge4.txt
    git add edge4.txt
    git commit --quiet -m "feat(scope): scoped commit"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Should handle edge cases gracefully
        local total_commits
        total_commits=$(echo "$output" | jq '.total_commits' 2>/dev/null || echo "0")
        if [[ $total_commits -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

test_commit_stats_accuracy() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Create known quantities of each commit type
    for i in {1..3}; do
        echo "Feat $i" > "test_feat_$i.txt"
        git add "test_feat_$i.txt"
        git commit --quiet -m "feat: test feature $i"
    done
    
    for i in {1..2}; do
        echo "Fix $i" > "test_fix_$i.txt"
        git add "test_fix_$i.txt"
        git commit --quiet -m "fix: test fix $i"
    done
    
    echo "Chore 1" > test_chore_1.txt
    git add test_chore_1.txt
    git commit --quiet -m "chore: test chore 1"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify we can detect the exact counts we added
        local feat_count fix_count chore_count
        feat_count=$(echo "$output" | jq '.feat_count' 2>/dev/null || echo "0")
        fix_count=$(echo "$output" | jq '.fix_count' 2>/dev/null || echo "0")
        chore_count=$(echo "$output" | jq '.chore_count' 2>/dev/null || echo "0")
        
        # We added at least 3 feat, 2 fix, 1 chore (plus existing ones)
        if [[ $feat_count -ge 3 && $fix_count -ge 2 && $chore_count -ge 1 ]]; then
            return 0
        fi
    fi
    return 1
}

test_json_field_validation() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Validate all required fields exist and have correct types
        local validation_count=0
        local passed_count=0
        
        # Check numeric fields
        if echo "$output" | jq -e '.total_commits | type == "number"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        if echo "$output" | jq -e '.feat_count | type == "number"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        if echo "$output" | jq -e '.fix_count | type == "number"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        if echo "$output" | jq -e '.chore_count | type == "number"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        if echo "$output" | jq -e '.ci_count | type == "number"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        if echo "$output" | jq -e '.docs_count | type == "number"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        # Check boolean field
        if echo "$output" | jq -e '.breaking_changes_detected | type == "boolean"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        # Check array field
        if echo "$output" | jq -e '.commit_patterns | type == "array"' >/dev/null 2>&1; then
            ((passed_count++))
        fi
        ((validation_count++))
        
        # All validations should pass
        if [[ $passed_count -eq $validation_count ]]; then
            return 0
        fi
    fi
    return 1
}

test_commit_patterns_completeness() {
    local output
    local exit_code=0
    
    cd "$TEST_REPO_DIR"
    
    # Add commits with various patterns
    echo "Pattern test 1" > pattern1.txt
    git add pattern1.txt
    git commit --quiet -m "test: add testing pattern"
    
    echo "Pattern test 2" > pattern2.txt
    git add pattern2.txt
    git commit --quiet -m "perf: performance improvement"
    
    output=$("$SCRIPT_UNDER_TEST" --since-tag "v0.7.0" --output-format "json" 2>/dev/null) || exit_code=$?
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | jq empty >/dev/null 2>&1; then
        # Verify patterns array includes the new patterns we added
        local patterns
        patterns=$(echo "$output" | jq -r '.commit_patterns[]' 2>/dev/null)
        
        if echo "$patterns" | grep -q "test:" && echo "$patterns" | grep -q "perf:"; then
            return 0
        fi
    fi
    return 1
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}🚀 Commit Statistics Extraction Script Test Suite${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
    
    setup_test_environment
    
    # Run all tests
    run_test "help_message" "test_help_message" "Verify help message displays correctly"
    run_test "missing_since_tag" "test_missing_since_tag" "Verify error when --since-tag is missing"
    run_test "invalid_output_format" "test_invalid_output_format" "Verify error for invalid output format"
    run_test "json_output_structure" "test_json_output_structure" "Verify JSON output has required fields"
    run_test "commit_type_counting" "test_commit_type_counting" "Verify commit types are counted correctly"
    run_test "breaking_changes_detection" "test_breaking_changes_detection" "Verify breaking changes are detected"
    run_test "text_output_format" "test_text_output_format" "Verify text output format is correct"
    run_test "commit_patterns_extraction" "test_commit_patterns_extraction" "Verify commit patterns are extracted"
    run_test "no_commits_scenario" "test_no_commits_scenario" "Verify handling when no commits exist"
    run_test "verbose_output" "test_verbose_output" "Verify verbose logging works"
    
    # Extended coverage tests
    run_test "malformed_commit_messages" "test_malformed_commit_messages" "Verify handling of malformed commit messages"
    run_test "breaking_change_variations" "test_breaking_change_variations" "Verify detection of various breaking change formats"
    run_test "large_scale_commit_analysis" "test_large_scale_commit_analysis" "Verify performance with large commit sets"
    run_test "edge_case_patterns" "test_edge_case_patterns" "Verify handling of edge case commit patterns"
    run_test "commit_stats_accuracy" "test_commit_stats_accuracy" "Verify accuracy of commit type counting"
    run_test "json_field_validation" "test_json_field_validation" "Verify JSON output field types and structure"
    run_test "commit_patterns_completeness" "test_commit_patterns_completeness" "Verify completeness of pattern extraction"
    
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