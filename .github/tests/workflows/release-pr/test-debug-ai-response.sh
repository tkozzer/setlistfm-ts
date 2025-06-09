#!/usr/bin/env bash

###############################################################################
# Test script for debug-ai-response.sh
#
# Tests the debug AI response script with various content types and edge cases,
# specifically covering the shell parsing errors that occurred in the workflow.
# Uses fixture-based test data following project patterns.
#
# Author: tkozzer
# Module: release-pr tests
###############################################################################

set -euo pipefail

echo "🧪 Testing debug-ai-response.sh..."

# Test setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
FIXTURES_DIR="$ROOT_DIR/.github/tests/fixtures/workflows/release-pr/debug-ai-response"
DEBUG_SCRIPT="$ROOT_DIR/.github/scripts/release-pr/debug-ai-response.sh"

# Ensure required files exist
if [[ ! -f "$DEBUG_SCRIPT" ]]; then
    echo "❌ FAIL: Script not found at $DEBUG_SCRIPT" >&2
    exit 1
fi

if [[ ! -f "$FIXTURES_DIR/test-cases.json" ]]; then
    echo "❌ FAIL: Test cases fixture not found at $FIXTURES_DIR/test-cases.json" >&2
    exit 1
fi

# Make script executable
chmod +x "$DEBUG_SCRIPT"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load content from file helper
load_content_file() {
    local file_name="$1"
    local file_path="$FIXTURES_DIR/$file_name"
    
    if [[ ! -f "$file_path" ]]; then
        echo "❌ Fixture file not found: $file_path" >&2
        return 1
    fi
    
    cat "$file_path"
}

# Run test case based on fixture data
run_test_case() {
    local test_name="$1"
    local test_config="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}📋 Test $TOTAL_TESTS: $test_name${NC}"
    
    # Parse test configuration
    local description
    description=$(echo "$test_config" | jq -r '.description')
    
    # Get arguments array
    local args=()
    while IFS= read -r arg; do
        # Handle special CONTENT_FROM_FILE placeholder
        if [[ "$arg" == "CONTENT_FROM_FILE" ]]; then
            local content_file
            content_file=$(echo "$test_config" | jq -r '.content_file // ""')
            if [[ -n "$content_file" ]]; then
                local content
                if content=$(load_content_file "$content_file"); then
                    args+=("$content")
                else
                    echo -e "${RED}❌ FAIL${NC}"
                    echo "Failed to load content file: $content_file"
                    return 1
                fi
            else
                echo -e "${RED}❌ FAIL${NC}"
                echo "CONTENT_FROM_FILE specified but no content_file provided"
                return 1
            fi
        else
            args+=("$arg")
        fi
    done < <(echo "$test_config" | jq -r '.args[]?')
    
    # Get expected results
    local expected_exit_code
    expected_exit_code=$(echo "$test_config" | jq -r '.expected_exit_code // 0')
    
    local expected_output_contains=()
    while IFS= read -r pattern; do
        expected_output_contains+=("$pattern")
    done < <(echo "$test_config" | jq -r '.expected_output_contains[]?' 2>/dev/null || true)
    
    local expected_stderr_contains=()
    while IFS= read -r pattern; do
        expected_stderr_contains+=("$pattern")
    done < <(echo "$test_config" | jq -r '.expected_stderr_contains[]?' 2>/dev/null || true)
    
    # Execute the script
    local actual_exit_code=0
    local actual_output
    
    if actual_output=$("$DEBUG_SCRIPT" "${args[@]}" 2>&1); then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    # Check exit code
    if [[ $actual_exit_code -ne $expected_exit_code ]]; then
        echo -e "${RED}❌ FAIL${NC}"
        echo "Expected exit code: $expected_exit_code"
        echo "Actual exit code: $actual_exit_code"
        echo "Output (first 500 chars):"
        echo "$actual_output" | head -c 500
        echo ""
        return 1
    fi
    
    # Check output patterns
    local pattern_check_failed=false
    
    # Check stdout patterns
    for pattern in "${expected_output_contains[@]}"; do
        if ! echo "$actual_output" | grep -q -F "$pattern"; then
            echo -e "${RED}❌ FAIL${NC}"
            echo "Expected output pattern not found: $pattern"
            echo "Actual output (first 500 chars):"
            echo "$actual_output" | head -c 500
            echo ""
            pattern_check_failed=true
            break
        fi
    done
    
    # Check stderr patterns
    if [[ $pattern_check_failed == false ]]; then
        for pattern in "${expected_stderr_contains[@]}"; do
            if ! echo "$actual_output" | grep -q -F "$pattern"; then
                echo -e "${RED}❌ FAIL${NC}"
                echo "Expected stderr pattern not found: $pattern"
                echo "Actual output (first 500 chars):"
                echo "$actual_output" | head -c 500
                echo ""
                pattern_check_failed=true
                break
            fi
        done
    fi
    
    if [[ $pattern_check_failed == false ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        return 1
    fi
}

# Load and execute all test cases
main() {
    echo ""
    echo "=== Running Fixture-Based Tests ==="
    echo ""
    
    # Load test cases from fixture file
    local test_cases
    test_cases=$(cat "$FIXTURES_DIR/test-cases.json")
    
    # Get test case names
    local test_names=()
    while IFS= read -r name; do
        test_names+=("$name")
    done < <(echo "$test_cases" | jq -r '.test_cases[].name')
    
    # Run each test case
    for test_name in "${test_names[@]}"; do
        local test_config
        test_config=$(echo "$test_cases" | jq --arg name "$test_name" '.test_cases[] | select(.name == $name)')
        
        if [[ -n "$test_config" ]]; then
            run_test_case "$test_name" "$test_config"
        else
            echo -e "${RED}❌ FAIL: Test case not found: $test_name${NC}"
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
        fi
        
        echo ""
    done
    
    # Results summary
    echo "=== Results ==="
    echo -e "${BLUE}📊 Test Results:${NC}"
    echo "Total tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"
    
    if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed.${NC}"
        exit 1
    fi
}

# Run main function
main 