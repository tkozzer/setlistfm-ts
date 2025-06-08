#!/usr/bin/env bash
set -euo pipefail

# Test script for update-pr-description.sh script
# This test validates the logic used in the pr-enhance workflow for updating PR descriptions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/pr-enhance"

total_tests=0
passed_tests=0

# Mock gh command for testing
mock_gh() {
    local cmd="$1"
    local pr_number="$2"
    local arg="$3"
    local body_file="$4"
    
    echo "Mock gh called: $cmd $pr_number $arg $body_file"
    if [[ -f "$body_file" ]]; then
        echo "PR content would be:"
        cat "$body_file"
        echo "---"
    fi
}

run_test() {
    local name="$1"
    local raw_content="$2"
    local formatted_content="$3"
    local expected_content="$4"
    local setup_pr_body="${5:-}"

    total_tests=$((total_tests + 1))
    
    # Setup test environment
    local test_dir="test_env_$$"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Create pr_body.txt if specified
    if [[ -n "$setup_pr_body" ]]; then
        echo "$setup_pr_body" > pr_body.txt
    fi
    
    # Mock gh command by overriding PATH
    mkdir -p mock_bin
    cat > mock_bin/gh <<'EOF'
#!/bin/bash
echo "$@" >> gh_calls.log
if [[ "$3" == "--body-file" && -f "$4" ]]; then
    echo "PR updated with content:"
    cat "$4"
fi
EOF
    chmod +x mock_bin/gh
    export PATH="$PWD/mock_bin:$PATH"
    
    # Set environment variables
    export RAW_CONTENT="$raw_content"
    export FORMATTED_CONTENT="$formatted_content"
    export PR_NUMBER="123"
    export GH_TOKEN="mock_token"
    export TEST_MODE="true"
    
    # Run the actual script
    if "$SCRIPTS_DIR/update-pr-description.sh" > output.log 2>&1; then
        # Check if the expected content was used
        if [[ -f final.md ]] && grep -q "$expected_content" final.md; then
            echo "✅ $name"
            passed_tests=$((passed_tests + 1))
        elif grep -q "$expected_content" output.log; then
            echo "✅ $name"
            passed_tests=$((passed_tests + 1))
        else
            echo "❌ $name"
            echo "Expected content: $expected_content"
            echo "Output log:"
            cat output.log 2>/dev/null || echo "No output log"
            echo "Final.md content:"
            cat final.md 2>/dev/null || echo "No final.md"
        fi
    else
        echo "❌ $name (script failed)"
        echo "Error output:"
        cat output.log 2>/dev/null || echo "No output log"
    fi
    
    # Cleanup
    cd ..
    rm -rf "$test_dir"
    unset RAW_CONTENT FORMATTED_CONTENT PR_NUMBER GH_TOKEN TEST_MODE
}



main() {
    echo "Running update-pr-description.sh tests..."

    # Test 1: Formatted content chosen over raw
    run_test "Formatted content preference" \
        "raw with 'single' quotes" \
        "formatted with 'quotes' and \$dollar" \
        "formatted with 'quotes' and \$dollar"

    # Test 2: Raw content fallback when formatted is null
    run_test "Raw content fallback" \
        "raw value" \
        "null" \
        "raw value"

    # Test 3: Original PR body fallback
    run_test "Original PR body fallback" \
        "" \
        "" \
        "default PR body" \
        "default PR body"

    # Test 4: Handle empty content gracefully
    run_test "Empty content handling" \
        "" \
        "" \
        "PR description not available"

    # Test 5: Formatted content with special characters
    run_test "Special characters in formatted content" \
        "raw content" \
        "formatted with \"quotes\" and \$symbols and newlines" \
        "formatted with \"quotes\" and \$symbols and newlines"

    # Note: Error tests for missing environment variables would require
    # unsetting variables in subshells, which is complex for this test setup
    echo "⚠️  Skipping error tests for missing environment variables (require unset variables)"

    echo "🏁 Completed: $passed_tests/$total_tests passed"

    if [[ $passed_tests -eq $total_tests ]]; then
        echo "🎉 All tests passed!"
        exit 0
    else
        echo "❌ Some tests failed!"
        exit 1
    fi
}

main "$@"
