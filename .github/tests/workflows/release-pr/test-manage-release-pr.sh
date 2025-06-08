#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
#  🧪  Test Release PR Management Script                                     #
# --------------------------------------------------------------------------- #
#
# Tests the manage-release-pr.sh script functionality including:
# - Parameter validation
# - PR creation logic
# - PR update logic  
# - Output formats (GitHub Actions and JSON)
# - Error handling
# - GitHub CLI mocking for reliable testing
#
# Author: tkozzer
# --------------------------------------------------------------------------- #

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
FIXTURES_DIR="$ROOT_DIR/.github/tests/fixtures/workflows/release-pr"
SCRIPT_UNDER_TEST="$ROOT_DIR/.github/scripts/release-pr/manage-release-pr.sh"

# Test state
PASSED=0
FAILED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() {
    echo -e "${CYAN}[INFO] $*${NC}" >&2
}

pass() {
    echo -e "${GREEN}[PASS] $*${NC}" >&2
    ((PASSED++))
}

fail() {
    echo -e "${RED}[FAIL] $*${NC}" >&2
    ((FAILED++))
}

debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG] $*${NC}" >&2
    fi
}

# Create a temporary directory for test execution
setup_test_env() {
    export TEST_DIR=$(mktemp -d)
    export MOCK_DIR="$TEST_DIR/mock"
    mkdir -p "$MOCK_DIR"
    cd "$TEST_DIR"
    
    # Create isolated PATH that only includes our mock directory
    # This ensures no real external commands are accessible
    export ORIGINAL_PATH="$PATH"
    export PATH="$MOCK_DIR:/usr/bin:/bin"  # Keep basic system commands but prioritize mocks
    
    debug "Test environment setup in: $TEST_DIR"
    debug "Isolated PATH: $PATH"
}

cleanup_test_env() {
    # Restore original PATH
    if [[ -n "${ORIGINAL_PATH:-}" ]]; then
        export PATH="$ORIGINAL_PATH"
    fi
    
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        debug "Cleaned up test directory: $TEST_DIR"
    fi
}

create_gh_mock() {
    local mock_config="$1"
    
    # Check if gh should be unavailable (don't create any mock script)
    if echo "$mock_config" | jq -e '.mock_gh_unavailable' >/dev/null 2>&1; then
        if [[ "$(echo "$mock_config" | jq -r '.mock_gh_unavailable')" == "true" ]]; then
            debug "GitHub CLI marked as unavailable - not creating any gh mock"
            return
        fi
    fi
    
    # Create mock gh script
     cat > "$MOCK_DIR/gh" << EOF
#!/usr/bin/env bash
set -euo pipefail

# Load mock configuration
MOCK_CONFIG_FILE="$MOCK_DIR/gh_config.json"

debug() {
    if [[ "\${DEBUG:-}" == "true" ]]; then
        echo "[DEBUG] Mock gh called with: \$*" >&2
    fi
}

debug "\$@"

# Mock auth status check
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
    exit 0
fi

# Mock PR list command
if [[ "\$1" == "pr" && "\$2" == "list" ]]; then
    if [[ -f "\$MOCK_CONFIG_FILE" ]]; then
        local response=""
        response=\$(jq -r '.mock_gh_responses.pr_list // ""' "\$MOCK_CONFIG_FILE" 2>/dev/null || echo "")
        echo "\$response"
    fi
    exit 0
fi

# Mock PR create command
if [[ "\$1" == "pr" && "\$2" == "create" ]]; then
    if [[ -f "\$MOCK_CONFIG_FILE" ]]; then
        if [[ "\$(jq -r '.mock_gh_responses.pr_create_fail // false' "\$MOCK_CONFIG_FILE")" == "true" ]]; then
            echo "Error: PR creation failed" >&2
            exit 1
        fi
    fi
    echo "https://github.com/test-owner/test-repo/pull/123"
    exit 0
fi

# Mock PR edit command  
if [[ "\$1" == "pr" && "\$2" == "edit" ]]; then
    if [[ -f "\$MOCK_CONFIG_FILE" ]]; then
        if [[ "\$(jq -r '.mock_gh_responses.pr_edit_fail // false' "\$MOCK_CONFIG_FILE")" == "true" ]]; then
            echo "Error: PR update failed" >&2
            exit 1
        fi
    fi
    exit 0
fi

# Default mock response
exit 0
EOF

    chmod +x "$MOCK_DIR/gh"
    
    # Create mock configuration file
    echo "$mock_config" > "$MOCK_DIR/gh_config.json"
    
    debug "Created gh mock with config: $mock_config"
}

run_test_case() {
    local test_name="$1"
    local test_config="$2"
    
    info "Running test: $test_name"
    ((TOTAL++))
    
    # Parse test configuration
    local description
    description=$(echo "$test_config" | jq -r '.description')
    debug "Description: $description"
    
    # Get arguments array
    local args=()
    while IFS= read -r arg; do
        args+=("$arg")
    done < <(echo "$test_config" | jq -r '.args[]?')
    
    # Get expected results
    local expected_exit_code
    expected_exit_code=$(echo "$test_config" | jq -r '.expected_exit_code // 0')
    
    local expected_stdout_contains=()
    while IFS= read -r pattern; do
        expected_stdout_contains+=("$pattern")
    done < <(echo "$test_config" | jq -r '.expected_stdout_contains[]?' 2>/dev/null || true)
    
    local expected_stderr_contains=()
    while IFS= read -r pattern; do
        expected_stderr_contains+=("$pattern")
    done < <(echo "$test_config" | jq -r '.expected_stderr_contains[]?' 2>/dev/null || true)
    
    # Setup mocking
    create_gh_mock "$test_config"
    
    # Execute the script
    local actual_exit_code=0
    local stdout_file="$TEST_DIR/stdout"
    local stderr_file="$TEST_DIR/stderr"
    
    # Add mock directory to PATH for this test
    export PATH="$MOCK_DIR:$PATH"
    
    debug "Executing: $SCRIPT_UNDER_TEST ${args[*]}"
    "$SCRIPT_UNDER_TEST" "${args[@]}" >"$stdout_file" 2>"$stderr_file" || actual_exit_code=$?
    
    local actual_stdout
    actual_stdout=$(<"$stdout_file")
    local actual_stderr  
    actual_stderr=$(<"$stderr_file")
    
    debug "Exit code: $actual_exit_code"
    debug "STDOUT: $actual_stdout"
    debug "STDERR: $actual_stderr"
    
    # Check exit code
    if [[ "$actual_exit_code" != "$expected_exit_code" ]]; then
        fail "$test_name - Expected exit code $expected_exit_code, got $actual_exit_code"
        debug "Full STDERR: $actual_stderr"
        return 1
    fi
    
    # Check stdout patterns
    for pattern in "${expected_stdout_contains[@]}"; do
        if ! echo "$actual_stdout" | grep -F -- "$pattern" >/dev/null; then
            fail "$test_name - STDOUT missing expected pattern: '$pattern'"
            debug "Actual STDOUT: $actual_stdout"
            return 1
        fi
    done
    
    # Check stderr patterns  
    for pattern in "${expected_stderr_contains[@]}"; do
        if ! echo "$actual_stderr" | grep -F -- "$pattern" >/dev/null; then
            fail "$test_name - STDERR missing expected pattern: '$pattern'"
            debug "Actual STDERR: $actual_stderr"
            return 1
        fi
    done
    
    # Check JSON output if expected
    if echo "$test_config" | jq -e '.expected_stdout_json' >/dev/null 2>&1; then
        local expected_json
        expected_json=$(echo "$test_config" | jq -c '.expected_stdout_json')
        
        if ! echo "$actual_stdout" | jq -e . >/dev/null 2>&1; then
            fail "$test_name - Expected JSON output but got invalid JSON"
            debug "Actual output: $actual_stdout"
            return 1
        fi
        
        local actual_json
        actual_json=$(echo "$actual_stdout" | jq -c .)
        
        if [[ "$actual_json" != "$expected_json" ]]; then
            fail "$test_name - JSON output mismatch"
            debug "Expected: $expected_json"
            debug "Actual: $actual_json"
            return 1
        fi
    fi
    
    pass "$test_name"
    return 0
}

run_all_tests() {
    info "Starting release PR management tests..."
    
    # Load test cases
    local test_cases_file="$FIXTURES_DIR/test-cases.json"
    if [[ ! -f "$test_cases_file" ]]; then
        fail "Test cases file not found: $test_cases_file"
        return 1
    fi
    
    # Verify script exists
    if [[ ! -f "$SCRIPT_UNDER_TEST" ]]; then
        fail "Script under test not found: $SCRIPT_UNDER_TEST"
        return 1
    fi
    
    if [[ ! -x "$SCRIPT_UNDER_TEST" ]]; then
        fail "Script under test not executable: $SCRIPT_UNDER_TEST"
        return 1
    fi
    
    # Run each test case
    while IFS= read -r test_name; do
        local test_config
        test_config=$(jq --arg name "$test_name" '.test_cases[] | select(.name == $name)' "$test_cases_file")
        
        setup_test_env
        run_test_case "$test_name" "$test_config" || true
        cleanup_test_env
        
    done < <(jq -r '.test_cases[].name' "$test_cases_file")
    
    # Summary
    echo
    echo "=========================================="
    echo "Release PR Management Test Results"
    echo "=========================================="
    echo "Total Tests: $TOTAL"
    echo "Passed: $PASSED"
    echo "Failed: $FAILED"
    echo "=========================================="
    
    if [[ $FAILED -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests "$@"
fi 