#!/usr/bin/env bash

#
# @file test-manage-github-release.sh
# @description Test suite for manage-github-release.sh script
# @author tkozzer
# @module release-notes-tests
#

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
FIXTURES_DIR="$PROJECT_ROOT/.github/tests/fixtures/workflows/release-notes"
SCRIPT_UNDER_TEST="$PROJECT_ROOT/.github/scripts/release-notes/manage-github-release.sh"

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

# Mock environment setup
TEST_VERSION="1.2.3"
TEST_GH_TOKEN="gh_test_token_123456789"
TEMP_DIR=""

setup_test_environment() {
    echo -e "${BLUE}🔧 Setting up test environment...${NC}"
    
    # Create temporary directory for test files
    TEMP_DIR=$(mktemp -d)
    
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
    
    echo -e "${GREEN}✅ Test environment setup complete${NC}"
    echo -e "   Temp directory: $TEMP_DIR"
    echo -e "   Script under test: $SCRIPT_UNDER_TEST"
    echo -e "   Fixtures directory: $FIXTURES_DIR"
    echo ""
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

# Setup mock gh command for testing
setup_mock_gh() {
    local behavior="$1"
    local mock_dir="$TEMP_DIR/mock_bin"
    mkdir -p "$mock_dir"
    
    cat > "$mock_dir/gh" << EOF
#!/usr/bin/env bash
# Mock gh CLI for testing

case "\$1 \$2 \$3" in
    "release view v1.2.3")
        case "$behavior" in
            "exists") exit 0 ;;
            "not_exists") exit 1 ;;
            *) exit 1 ;;
        esac
        ;;
    "release create v1.2.3")
        case "$behavior" in
            "create_success") 
                echo "Created release v1.2.3"
                exit 0
                ;;
            "create_fail")
                echo "Failed to create release" >&2
                exit 1
                ;;
            *) exit 1 ;;
        esac
        ;;
    "release edit v1.2.3")
        case "$behavior" in
            "update_success"|"create_fail"|"exists") 
                echo "Updated release v1.2.3"
                exit 0
                ;;
            "update_fail")
                echo "Failed to update release" >&2
                exit 1
                ;;
            *) exit 1 ;;
        esac
        ;;
    *)
        echo "Mock gh: unknown command \$*" >&2
        exit 1
        ;;
esac
EOF
    
    chmod +x "$mock_dir/gh"
    export PATH="$mock_dir:$PATH"
}

# Test functions

test_help_message() {
    local output
    if output=$("$SCRIPT_UNDER_TEST" --help 2>&1); then
        if echo "$output" | grep -q "Usage:" && echo "$output" | grep -q "Options:"; then
            return 0
        fi
    fi
    return 1
}

test_missing_required_args() {
    local output
    local exit_code=0
    
    # No environment setup needed for this test
    output=$("$SCRIPT_UNDER_TEST" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Version is required"; then
        return 0
    fi
    return 1
}

test_invalid_version_format() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "invalid.version" --notes-file "$notes_file" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Version must be valid semver format"; then
        return 0
    fi
    return 1
}

test_missing_notes_file() {
    local nonexistent_file="$TEMP_DIR/nonexistent.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$nonexistent_file" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Release notes file does not exist"; then
        return 0
    fi
    return 1
}

test_missing_github_token() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    unset GH_TOKEN
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "GitHub token is required"; then
        return 0
    fi
    return 1
}

test_invalid_release_notes_content() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/invalid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --dry-run 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Release notes must mention 'setlistfm-ts'"; then
        return 0
    fi
    return 1
}

test_empty_release_notes() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/empty-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --dry-run 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Release notes file is empty"; then
        return 0
    fi
    return 1
}

test_dry_run_create_new_release() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --dry-run --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "DRY RUN: Would execute.*gh release create"; then
        return 0
    fi
    return 1
}

test_dry_run_update_existing_release() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --dry-run --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "DRY RUN: Would execute.*gh release edit"; then
        return 0
    fi
    return 1
}

test_successful_create_new_release() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "create_success"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Created GitHub release v1.2.3"; then
        return 0
    fi
    return 1
}

test_successful_update_existing_release() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Updated GitHub release v1.2.3"; then
        return 0
    fi
    return 1
}

test_create_fail_fallback_to_update() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "create_fail"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Create failed, attempting update as fallback"; then
        return 0
    fi
    return 1
}

test_version_formats() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    # Test valid semver formats
    local versions=("1.0.0" "1.2.3" "2.0.0-beta.1" "1.0.0+build.1" "1.0.0-alpha.1+build.2")
    
    for version in "${versions[@]}"; do
        local output
        local exit_code=0
        output=$("$SCRIPT_UNDER_TEST" --version "$version" --notes-file "$notes_file" --dry-run 2>&1) || exit_code=$?
        if [[ $exit_code -ne 0 ]]; then
            echo "Failed for valid version: $version"
            echo "Output: $output"
            return 1
        fi
    done
    
    return 0
}

test_unreadable_notes_file() {
    local temp_notes="$TEMP_DIR/unreadable.md"
    local output
    local exit_code=0
    
    # Create a file and make it unreadable
    echo "# Test notes" > "$temp_notes"
    chmod 000 "$temp_notes"
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$temp_notes" --dry-run 2>&1) || exit_code=$?
    
    # Restore permissions for cleanup
    chmod 644 "$temp_notes" 2>/dev/null || true
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Release notes file is not readable"; then
        return 0
    fi
    return 1
}

test_verify_tag_success() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    local test_repo="$TEMP_DIR/verify-tag-success-test"
    
    # Create isolated git repo with the tag
    mkdir -p "$test_repo"
    cd "$test_repo"
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add test.txt
    git commit --quiet -m "initial commit"
    git tag "v$TEST_VERSION"
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --verify-tag --dry-run --verbose 2>&1) || exit_code=$?
    
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Git tag v$TEST_VERSION exists"; then
        return 0
    fi
    return 1
}

test_verify_tag_failure() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    local test_repo="$TEMP_DIR/verify-tag-test"
    
    # Create isolated git repo without the tag
    mkdir -p "$test_repo"
    cd "$test_repo"
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add test.txt
    git commit --quiet -m "initial commit"
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --verify-tag --dry-run 2>&1) || exit_code=$?
    
    cd "$PROJECT_ROOT"
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Git tag v$TEST_VERSION does not exist"; then
        return 0
    fi
    return 1
}

test_missing_markdown_headers() {
    local temp_notes="$TEMP_DIR/no-headers.md"
    local output
    local exit_code=0
    
    # Create notes without markdown headers
    echo "Release notes without headers for setlistfm-ts $TEST_VERSION" > "$temp_notes"
    echo "Just plain text content" >> "$temp_notes"
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$temp_notes" --dry-run --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Release notes may not have proper markdown headers"; then
        return 0
    fi
    return 1
}

test_version_not_in_notes() {
    local temp_notes="$TEMP_DIR/no-version.md"
    local output
    local exit_code=0
    
    # Create notes without version mention
    echo "# Release Notes for setlistfm-ts" > "$temp_notes"
    echo "Some changes were made" >> "$temp_notes"
    
    setup_mock_gh "not_exists"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$temp_notes" --dry-run --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "Version $TEST_VERSION not found in release notes"; then
        return 0
    fi
    return 1
}

test_github_token_via_argument() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "not_exists"
    unset GH_TOKEN  # Remove environment variable
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --github-token "$TEST_GH_TOKEN" --dry-run --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "DRY RUN: Would execute"; then
        return 0
    fi
    return 1
}

test_update_operation_failure() {
    local notes_file="$FIXTURES_DIR/validate-release-notes/valid-release-notes.md"
    local output
    local exit_code=0
    
    setup_mock_gh "update_fail"
    export GH_TOKEN="$TEST_GH_TOKEN"
    
    output=$("$SCRIPT_UNDER_TEST" --version "$TEST_VERSION" --notes-file "$notes_file" --verbose 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Failed to update GitHub release"; then
        return 0
    fi
    return 1
}

print_test_summary() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
    echo -e "${BOLD}${CYAN}║  📊 MANAGE GITHUB RELEASE SCRIPT TEST RESULTS             ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BOLD}📈 Test Summary:${NC}"
    echo -e "   Total tests: $TOTAL_TESTS"
    echo -e "   ${GREEN}✅ Passed: $PASSED_TESTS${NC}"
    echo -e "   ${RED}❌ Failed: $FAILED_TESTS${NC}"
    echo ""
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${BOLD}${RED}❌ Failed Tests:${NC}"
        for test_name in "${FAILED_TEST_NAMES[@]}"; do
            echo -e "   - $test_name"
        done
        echo ""
    fi
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}💥 Some tests failed!${NC}"
        return 1
    fi
}

main() {
    echo -e "${BOLD}${BLUE}🧪 Starting manage-github-release.sh test suite${NC}"
    echo ""
    
    # Setup
    setup_test_environment
    trap cleanup_test_environment EXIT
    
    # Run tests
    run_test "help_message" "test_help_message" "Script shows help message with --help flag"
    run_test "missing_required_args" "test_missing_required_args" "Script fails with appropriate error when required args missing"
    run_test "invalid_version_format" "test_invalid_version_format" "Script validates semver format"
    run_test "missing_notes_file" "test_missing_notes_file" "Script fails when notes file doesn't exist"
    run_test "missing_github_token" "test_missing_github_token" "Script fails when GitHub token is missing"
    run_test "invalid_release_notes_content" "test_invalid_release_notes_content" "Script validates release notes contain setlistfm-ts"
    run_test "empty_release_notes" "test_empty_release_notes" "Script fails when release notes file is empty"
    run_test "dry_run_create_new_release" "test_dry_run_create_new_release" "Dry run shows create command for new release"
    run_test "dry_run_update_existing_release" "test_dry_run_update_existing_release" "Dry run shows update command for existing release"
    run_test "successful_create_new_release" "test_successful_create_new_release" "Successfully creates new GitHub release"
    run_test "successful_update_existing_release" "test_successful_update_existing_release" "Successfully updates existing GitHub release"
    run_test "create_fail_fallback_to_update" "test_create_fail_fallback_to_update" "Falls back to update when create fails"
    run_test "version_formats" "test_version_formats" "Accepts various valid semver formats"
    run_test "unreadable_notes_file" "test_unreadable_notes_file" "Script fails when notes file is not readable"
    run_test "verify_tag_success" "test_verify_tag_success" "Script succeeds with --verify-tag when tag exists"
    run_test "verify_tag_failure" "test_verify_tag_failure" "Script fails with --verify-tag when tag doesn't exist"
    run_test "missing_markdown_headers" "test_missing_markdown_headers" "Script warns about missing markdown headers"
    run_test "version_not_in_notes" "test_version_not_in_notes" "Script warns when version not found in notes"
    run_test "github_token_via_argument" "test_github_token_via_argument" "Script accepts GitHub token via --github-token argument"
    run_test "update_operation_failure" "test_update_operation_failure" "Script handles update operation failures"
    
    # Print summary and exit
    print_test_summary
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 