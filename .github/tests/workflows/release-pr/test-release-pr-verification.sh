#!/usr/bin/env bash
set -euo pipefail

# Test script for release-pr workflow verification step
# Tests the new commit verification and version validation logic

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Function to test the actual verification script with mocked git/package data
test_verify_release_commit() {
    local commit_message="$1"
    local package_version="$2"
    
    # Create a temporary git directory for testing
    local temp_dir=$(mktemp -d)
    local original_dir=$(pwd)
    
    cd "$temp_dir"
    
    # Initialize git repo and create mock commit
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create mock package.json
    echo "{\"version\": \"$package_version\"}" > package.json
    
    # Ensure node is available
    if ! command -v node >/dev/null 2>&1; then
        echo "NODE_NOT_FOUND"
        cd "$original_dir"
        rm -rf "$temp_dir"
        return 127
    fi
    
    # Create an initial commit and then the test commit
    echo "initial" > README.md
    git add README.md package.json
    git commit -q -m "initial commit"
    git commit -q --allow-empty -m "$commit_message"
    
    # Run the actual verification script (adjust path based on where test runner executes from)
    local script_path
    if [[ -f "$original_dir/.github/scripts/release-pr/verify-release-commit.sh" ]]; then
    script_path="$original_dir/.github/scripts/release-pr/verify-release-commit.sh"
    elif [[ -f "$original_dir/../scripts/release-pr/verify-release-commit.sh" ]]; then
script_path="$original_dir/../scripts/release-pr/verify-release-commit.sh"
    else
        echo "SCRIPT_NOT_FOUND:Cannot locate verify-release-commit.sh"
        cd "$original_dir"
        rm -rf "$temp_dir"
        return 127
    fi
    

    local output
    local exit_code
    
    if output=$("$script_path" 2>&1); then
        exit_code=0
        echo "SUCCESS:$(echo "$output" | grep "Version from commit:" | sed 's/Version from commit: //')"
    else
        exit_code=$?
        if echo "$output" | grep -q "Version mismatch"; then
            local commit_ver=$(echo "$output" | grep "Commit version:" | sed 's/Commit version: //')
            local package_ver=$(echo "$output" | grep "Package.json version:" | sed 's/Package.json version: //')
            echo "VERSION_MISMATCH:$commit_ver:$package_ver"
        else
            echo "FORMAT_ERROR:$commit_message"
        fi
    fi
    
    # Cleanup
    cd "$original_dir"
    rm -rf "$temp_dir"
    
    return $exit_code
}

run_test() {
    local test_name="$1"
    local commit_msg="$2"
    local package_ver="$3"
    local expected_result="$4"
    local expected_exit_code="$5"
    
    echo_test "$test_name"
    
    total_tests=$((total_tests + 1))
    
    # Capture output and exit code
    local actual_output
    local actual_exit_code
    
    if actual_output=$(test_verify_release_commit "$commit_msg" "$package_ver" 2>&1); then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    # Check exit code
    if [[ "$actual_exit_code" != "$expected_exit_code" ]]; then
        echo_fail "Exit code mismatch. Expected: $expected_exit_code, Got: $actual_exit_code"
        echo "   Output: $actual_output"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
    
    # Check output content
    if [[ "$actual_output" == "$expected_result" ]]; then
        echo_pass "Test passed"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        echo_fail "Output mismatch"
        echo "   Expected: $expected_result"
        echo "   Got:      $actual_output"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

main() {
    echo -e "${BLUE}🚀 Testing Release PR Verification Logic${NC}"
    echo ""
    
    # Test 1: Valid release commit with matching version
    run_test "Valid release commit with matching version" \
        "chore(release): v1.2.3 – update changelog" \
        "1.2.3" \
        "SUCCESS:1.2.3" \
        0
    
    # Test 2: Valid release commit with different dash style
    run_test "Valid release commit with em dash" \
        "chore(release): v0.7.1 — update changelog" \
        "0.7.1" \
        "SUCCESS:0.7.1" \
        0
    
    # Test 3: Valid release commit with additional text
    run_test "Valid release commit with extra text" \
        "chore(release): v2.0.0 – update changelog and docs" \
        "2.0.0" \
        "SUCCESS:2.0.0" \
        0
    
    # Test 4: Version mismatch between commit and package.json
    run_test "Version mismatch" \
        "chore(release): v1.2.3 – update changelog" \
        "1.2.4" \
        "VERSION_MISMATCH:1.2.3:1.2.4" \
        1
    
    # Test 5: Invalid commit format - wrong type
    run_test "Invalid commit type" \
        "feat(release): v1.2.3 – update changelog" \
        "1.2.3" \
        "FORMAT_ERROR:feat(release): v1.2.3 – update changelog" \
        1
    
    # Test 6: Invalid commit format - missing version
    run_test "Missing version in commit" \
        "chore(release): update changelog" \
        "1.2.3" \
        "FORMAT_ERROR:chore(release): update changelog" \
        1
    
    # Test 7: Invalid commit format - wrong scope
    run_test "Invalid scope" \
        "chore(build): v1.2.3 – update changelog" \
        "1.2.3" \
        "FORMAT_ERROR:chore(build): v1.2.3 – update changelog" \
        1
    
    # Test 8: Invalid commit format - missing 'update changelog'
    run_test "Missing 'update changelog'" \
        "chore(release): v1.2.3 – build complete" \
        "1.2.3" \
        "FORMAT_ERROR:chore(release): v1.2.3 – build complete" \
        1
    
    # Test 9: Invalid version format
    run_test "Invalid version format" \
        "chore(release): v1.2 – update changelog" \
        "1.2" \
        "FORMAT_ERROR:chore(release): v1.2 – update changelog" \
        1
    
    # Test 10: Valid pre-release version
    run_test "Pre-release version with extra text" \
        "chore(release): v1.0.0-beta.1 – update changelog" \
        "1.0.0" \
        "SUCCESS:1.0.0" \
        0
    
    # Test 11: Complex version with build metadata
    run_test "Complex version extraction" \
        "chore(release): v2.1.5-alpha.3+build.456 – update changelog and bump version" \
        "2.1.5" \
        "SUCCESS:2.1.5" \
        0
    
    # Test 12: Edge case - extra spaces
    run_test "Extra spaces in commit" \
        "chore(release):  v1.0.0  –  update changelog" \
        "1.0.0" \
        "FORMAT_ERROR:chore(release):  v1.0.0  –  update changelog" \
        1
    
    # Test 13: Case sensitivity
    run_test "Case sensitivity test" \
        "Chore(release): v1.0.0 – update changelog" \
        "1.0.0" \
        "FORMAT_ERROR:Chore(release): v1.0.0 – update changelog" \
        1
    
    # Test 14: Valid commit with zero patch version
    run_test "Zero patch version" \
        "chore(release): v1.0.0 – update changelog" \
        "1.0.0" \
        "SUCCESS:1.0.0" \
        0
    
    # Test 15: Valid commit with high version numbers
    run_test "High version numbers" \
        "chore(release): v10.25.100 – update changelog" \
        "10.25.100" \
        "SUCCESS:10.25.100" \
        0
    
    echo ""
    echo -e "${BLUE}📊 Test Results Summary:${NC}"
    echo "   Total tests: $total_tests"
    echo -e "   ${GREEN}Passed: $passed_tests${NC}"
    echo -e "   ${RED}Failed: $failed_tests${NC}"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some tests failed!${NC}"
        exit 1
    fi
}

main "$@" 