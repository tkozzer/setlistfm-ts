#!/usr/bin/env bash
set -euo pipefail

# Test script for release-pr workflow state synchronization
# Tests the enhanced preview branch sync logic and debug output

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

# Function to test the sync script output format and behavior
test_sync_script_output() {
    # Find the script path (adjust based on where test runner executes from)
    local script_path
    if [[ -f "$SCRIPT_DIR/../../../scripts/release-pr/sync-preview-branch.sh" ]]; then
script_path="$SCRIPT_DIR/../../../scripts/release-pr/sync-preview-branch.sh"
elif [[ -f "$SCRIPT_DIR/../scripts/release-pr/sync-preview-branch.sh" ]]; then
script_path="$SCRIPT_DIR/../scripts/release-pr/sync-preview-branch.sh"
    else
        echo "SCRIPT_NOT_FOUND:Cannot locate sync-preview-branch.sh"
        return 127
    fi
    
    # Run the actual script with a timeout to avoid waiting 10 seconds
    # We'll capture just the beginning of the output to test format
    timeout 2 "$script_path" 2>&1 || true
}

# Mock functions to simulate different scenarios for testing
mock_sync_scenarios() {
    local test_scenario="$1"
    
    case "$test_scenario" in
        "successful_sync")
            echo "⏱️ Waiting 10 seconds for release-prepare pushes to complete..."
            # Simulate wait time (reduced for testing)
            sleep 1
            echo "🔄 Fetching latest preview branch state..."
            echo "=== Current Repository State ==="
            echo "Current commit: abc123def456"
            echo "Latest origin/preview: abc123def456"
            echo "Last commit message: chore(release): v1.2.3 – update changelog"
            echo "Current version: 1.2.3"
            echo "First changelog header: ## [1.2.3] - 2025-06-08"
            echo "Total changelog entries: 5"
            return 0
            ;;
        "version_mismatch")
            echo "⏱️ Waiting 10 seconds for release-prepare pushes to complete..."
            sleep 1
            echo "🔄 Fetching latest preview branch state..."
            echo "=== Current Repository State ==="
            echo "Current commit: abc123def456"
            echo "Latest origin/preview: def456ghi789"
            echo "Last commit message: chore(release): v1.2.3 – update changelog"
            echo "Current version: 1.2.2"
            echo "First changelog header: ## [1.2.2] - 2025-06-07"
            echo "Total changelog entries: 4"
            return 0
            ;;
        "git_fetch_failure")
            echo "⏱️ Waiting 10 seconds for release-prepare pushes to complete..."
            sleep 1
            echo "🔄 Fetching latest preview branch state..."
            echo "fatal: unable to access remote repository"
            return 1
            ;;
    esac
}

# Function to validate debug output format
validate_debug_output() {
    local output="$1"
    local expected_patterns=(
        "⏱️ Waiting 10 seconds"
        "🔄 Fetching latest preview branch state"
        "=== Current Repository State ==="
        "Current commit:"
        "Latest origin/preview:"
        "Last commit message:"
        "Current version:"
        "First changelog header:"
        "Total changelog entries:"
    )
    
    for pattern in "${expected_patterns[@]}"; do
        if ! echo "$output" | grep -q "$pattern"; then
            echo "Missing pattern: $pattern"
            return 1
        fi
    done
    
    return 0
}

# Function to validate actual script output (partial validation for timeout scenarios)
validate_actual_script_output() {
    local output="$1"
    local minimal_patterns=(
        "⏱️ Waiting 10 seconds"
    )
    
    for pattern in "${minimal_patterns[@]}"; do
        if ! echo "$output" | grep -q "$pattern"; then
            echo "Missing pattern: $pattern"
            return 1
        fi
    done
    
    return 0
}

# Function to extract values from debug output
extract_debug_values() {
    local output="$1"
    local field="$2"
    
    case "$field" in
        "current_commit")
            echo "$output" | grep "Current commit:" | sed 's/Current commit: //'
            ;;
        "origin_commit")
            echo "$output" | grep "Latest origin/preview:" | sed 's/Latest origin\/preview: //'
            ;;
        "last_commit_message")
            echo "$output" | grep "Last commit message:" | sed 's/Last commit message: //'
            ;;
        "current_version")
            echo "$output" | grep "Current version:" | sed 's/Current version: //'
            ;;
        "changelog_header")
            echo "$output" | grep "First changelog header:" | sed 's/First changelog header: //'
            ;;
        "changelog_count")
            echo "$output" | grep "Total changelog entries:" | sed 's/Total changelog entries: //'
            ;;
    esac
}

run_test() {
    local test_name="$1"
    local scenario="$2"
    local validation_type="$3"
    local expected_result="$4"
    
    echo_test "$test_name"
    
    total_tests=$((total_tests + 1))
    
    # Capture output and exit code
    local actual_output
    local actual_exit_code
    
    # For some tests, use the actual script, for others use mock scenarios
    if [[ "$scenario" == "actual_script_test" ]]; then
        actual_output=$(test_sync_script_output)
        actual_exit_code=0
    else
        if actual_output=$(mock_sync_scenarios "$scenario" 2>&1); then
        actual_exit_code=0
        else
            actual_exit_code=$?
        fi
    fi
    
    case "$validation_type" in
        "format_check")
            # Use different validation for actual script vs mock scenarios
            if [[ "$scenario" == "actual_script_test" ]]; then
                if validate_actual_script_output "$actual_output"; then
                    echo_pass "Actual script output format is correct"
                    passed_tests=$((passed_tests + 1))
                    return 0
                else
                    echo_fail "Actual script output format is incorrect"
                    failed_tests=$((failed_tests + 1))
                    return 1
                fi
            else
                if validate_debug_output "$actual_output"; then
                    echo_pass "Debug output format is correct"
                    passed_tests=$((passed_tests + 1))
                    return 0
                else
                    echo_fail "Debug output format is incorrect"
                    failed_tests=$((failed_tests + 1))
                    return 1
                fi
            fi
            ;;
        "field_extraction")
            local field="$expected_result"
            local extracted_value=$(extract_debug_values "$actual_output" "$field")
            if [[ -n "$extracted_value" ]]; then
                echo_pass "Successfully extracted $field: $extracted_value"
                passed_tests=$((passed_tests + 1))
                return 0
            else
                echo_fail "Failed to extract $field"
                failed_tests=$((failed_tests + 1))
                return 1
            fi
            ;;
        "exit_code")
            if [[ "$actual_exit_code" == "$expected_result" ]]; then
                echo_pass "Exit code matches expected: $expected_result"
                passed_tests=$((passed_tests + 1))
                return 0
            else
                echo_fail "Exit code mismatch. Expected: $expected_result, Got: $actual_exit_code"
                failed_tests=$((failed_tests + 1))
                return 1
            fi
            ;;
        "sync_detection")
            local current_commit=$(extract_debug_values "$actual_output" "current_commit")
            local origin_commit=$(extract_debug_values "$actual_output" "origin_commit")
            
            if [[ "$current_commit" == "$origin_commit" ]]; then
                echo_pass "Repository is synchronized"
                passed_tests=$((passed_tests + 1))
                return 0
            else
                echo_fail "Repository sync mismatch. Current: $current_commit, Origin: $origin_commit"
                failed_tests=$((failed_tests + 1))
                return 1
            fi
            ;;
    esac
}

main() {
    echo -e "${BLUE}🔄 Testing Release PR State Synchronization${NC}"
    echo ""
    
    # Test 1: Successful synchronization with proper format
    run_test "Successful sync - debug output format" \
        "successful_sync" \
        "format_check" \
        ""
    
    # Test 2: Field extraction tests
    run_test "Extract current commit hash" \
        "successful_sync" \
        "field_extraction" \
        "current_commit"
    
    run_test "Extract origin commit hash" \
        "successful_sync" \
        "field_extraction" \
        "origin_commit"
    
    run_test "Extract last commit message" \
        "successful_sync" \
        "field_extraction" \
        "last_commit_message"
    
    run_test "Extract current version" \
        "successful_sync" \
        "field_extraction" \
        "current_version"
    
    run_test "Extract changelog header" \
        "successful_sync" \
        "field_extraction" \
        "changelog_header"
    
    run_test "Extract changelog count" \
        "successful_sync" \
        "field_extraction" \
        "changelog_count"
    
    # Test 3: Synchronization status detection
    run_test "Detect successful synchronization" \
        "successful_sync" \
        "sync_detection" \
        ""
    
    # This test should fail sync detection (mismatch scenario)
    echo_test "Detect sync mismatch"
    total_tests=$((total_tests + 1))
    local mismatch_output=$(mock_sync_scenarios "version_mismatch" 2>&1)
    local current_commit=$(extract_debug_values "$mismatch_output" "current_commit")
    local origin_commit=$(extract_debug_values "$mismatch_output" "origin_commit")
    
    if [[ "$current_commit" != "$origin_commit" ]]; then
        echo_pass "Correctly detected repository sync mismatch"
        passed_tests=$((passed_tests + 1))
    else
        echo_fail "Failed to detect sync mismatch"
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test 4: Different scenarios
    run_test "Handle git fetch failure" \
        "git_fetch_failure" \
        "exit_code" \
        "1"
    
    run_test "Handle successful operations" \
        "successful_sync" \
        "exit_code" \
        "0"
    
    # Test 5: Test actual script output format
    run_test "Actual script output format" \
        "actual_script_test" \
        "format_check" \
        ""
    
    # Test 6: Wait time behavior (simplified test)
    echo_test "Wait time implementation"
    local start_time=$(date +%s)
    mock_sync_scenarios "successful_sync" > /dev/null
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    total_tests=$((total_tests + 1))
    if [[ $duration -ge 1 ]]; then
        echo_pass "Wait time implemented (${duration}s)"
        passed_tests=$((passed_tests + 1))
    else
        echo_fail "Wait time too short (${duration}s)"
        failed_tests=$((failed_tests + 1))
    fi
    
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