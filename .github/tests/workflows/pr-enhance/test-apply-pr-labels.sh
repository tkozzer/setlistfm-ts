#!/usr/bin/env bash

# 🧪 Test Suite: apply-pr-labels.sh
# 
# Tests the PR label application and auto-assignment logic extracted from pr-enhance.yml
# Validates label creation, PR assignment, argument parsing, and error handling.

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/pr-enhance"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/pr-enhance/pr-labels"
APPLY_LABELS_SCRIPT="$SCRIPTS_DIR/apply-pr-labels.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test output tracking
TOTAL_TESTS=0
PASSED_TESTS=0

# Test utility functions
print_test_header() {
  local script_name="$1"
  echo -e "\n${BLUE}🧪 Testing: $script_name${NC}"
  echo "=================================================="
}

print_test_section() {
  local section_name="$1"
  echo -e "\n${YELLOW}📋 $section_name${NC}"
  echo "--------------------------------------------------"
}

print_test_results() {
  local passed="$1"
  local total="$2"
  local script_name="$3"
  
  echo -e "\n${BLUE}📊 Test Results for $script_name${NC}"
  echo "=================================================="
  
  if [ "$passed" -eq "$total" ]; then
    echo -e "${GREEN}✅ All tests passed: $passed/$total${NC}"
  else
    echo -e "${RED}❌ Some tests failed: $passed/$total${NC}"
  fi
  
  echo ""
}

#######################################
# Test Helper Functions
#######################################

# Mock GitHub CLI by creating a fake gh command
setup_mock_gh() {
  local mock_dir="$1"
  mkdir -p "$mock_dir"
  
  # Create mock gh script that logs commands and returns success
  cat > "$mock_dir/gh" <<'EOF'
#!/bin/bash
echo "MOCK_GH_CALL: $*" >> "$MOCK_LOG_FILE"
exit 0
EOF
  chmod +x "$mock_dir/gh"
  
  # Add to PATH
  export PATH="$mock_dir:$PATH"
  export MOCK_LOG_FILE="$mock_dir/gh_calls.log"
  > "$MOCK_LOG_FILE"  # Clear log file
}

# Setup test environment with mock GitHub CLI
setup_test_env() {
  local test_dir="$1"
  local full_test_dir="$SCRIPT_DIR/$test_dir"
  
  # Create test directory with absolute path
  mkdir -p "$full_test_dir"
  cd "$full_test_dir"
  
  # Setup mock git repository
  git init --quiet >/dev/null 2>&1 || true
  git remote add origin "https://github.com/testowner/testrepo.git" >/dev/null 2>&1 || true
  
  # Setup mock GitHub CLI with absolute path
  setup_mock_gh "$full_test_dir/mock_bin"
  
  # Set required environment variables
  export GH_TOKEN="mock_token"
  export GITHUB_REPOSITORY="testowner/testrepo"
  export GITHUB_REPOSITORY_OWNER="testowner"
}

# Cleanup test environment
cleanup_test_env() {
  local test_dir="$1"
  local full_test_dir="$SCRIPT_DIR/$test_dir"
  
  # Always return to script directory first
  cd "$SCRIPT_DIR"
  
  # Remove test directory with absolute path
  if [[ -d "$full_test_dir" ]]; then
    rm -rf "$full_test_dir"
  fi
  
  # Reset environment
  unset GH_TOKEN GITHUB_REPOSITORY GITHUB_REPOSITORY_OWNER MOCK_LOG_FILE
}

# Run apply-pr-labels script with given arguments
run_apply_labels() {
  bash "$APPLY_LABELS_SCRIPT" "$@"
}

# Test that script succeeds with expected mock calls
test_success() {
  local test_name="$1"
  shift
  local expected_calls="$1"
  shift
  local args=("$@")
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "$test_name..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  # Run the script
  if run_apply_labels "${args[@]}" >/dev/null 2>&1; then
    # Check if expected calls were made
    if [[ -n "$expected_calls" ]] && ! grep -q "$expected_calls" "$MOCK_LOG_FILE" 2>/dev/null; then
      printf "❌ FAIL\n"
      printf "    Expected GitHub CLI call containing: '%s'\n" "$expected_calls"
      printf "    Actual calls:\n"
      cat "$MOCK_LOG_FILE" 2>/dev/null | sed 's/^/      /' || echo "      (no calls)"
    else
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
  else
    printf "❌ FAIL (script error)\n"
    printf "    Script failed to execute\n"
  fi
  
  cleanup_test_env "$test_dir"
}

# Test that script fails with error
test_error() {
  local test_name="$1"
  shift
  local args=("$@")
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "$test_name..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  if run_apply_labels "${args[@]}" >/dev/null 2>&1; then
    printf "❌ FAIL\n"
    printf "    Expected error, but script succeeded\n"
  else
    printf "✅ PASS\n"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  fi
  
  cleanup_test_env "$test_dir"
}

# Test dry run mode (should not make GitHub calls)
test_dry_run() {
  local test_name="$1"
  shift
  local args=("$@")
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "$test_name..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  # Add --dry-run to args
  args+=(--dry-run)
  
  if run_apply_labels "${args[@]}" >/dev/null 2>&1; then
    # Check that no actual GitHub CLI calls were made
    if [[ -s "$MOCK_LOG_FILE" ]]; then
      printf "❌ FAIL\n"
      printf "    Dry run should not make GitHub CLI calls\n"
      printf "    Actual calls:\n"
      cat "$MOCK_LOG_FILE" | sed 's/^/      /'
    else
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
  else
    printf "❌ FAIL (script error)\n"
    printf "    Dry run script failed to execute\n"
  fi
  
  cleanup_test_env "$test_dir"
}

#######################################
# Main Test Suite
#######################################

test_apply_labels() {
  print_test_header "apply-pr-labels.sh"
  
  # Test basic functionality
  print_test_section "Basic Label Application"
  
  test_success "Single feature label" \
    "label create feature" \
    --labels "feature" --pr-number 123
    
  test_success "Multiple labels" \
    "label create" \
    --labels "feature bugfix documentation" --pr-number 456
    
  test_success "All supported labels" \
    "label create" \
    --labels "feature bugfix documentation maintenance refactor performance testing style ci-cd breaking-change needs-review" --pr-number 789

  # Test PR assignment
  print_test_section "PR Assignment"
  
  test_success "Default assignee from environment" \
    "pr edit.*--add-assignee testowner" \
    --labels "feature" --pr-number 123
    
  test_success "Custom assignee" \
    "pr edit.*--add-assignee customuser" \
    --labels "feature" --pr-number 123 --assignee customuser

  # Test repository handling
  print_test_section "Repository Handling"
  
  test_success "Default repo from environment" \
    "testowner/testrepo" \
    --labels "feature" --pr-number 123
    
  test_success "Custom repository" \
    "custom/repo" \
    --labels "feature" --pr-number 123 --repo "custom/repo"

  # Test dry run mode
  print_test_section "Dry Run Mode"
  
  test_dry_run "Dry run with single label" \
    --labels "feature" --pr-number 123
    
  test_dry_run "Dry run with multiple labels" \
    --labels "feature bugfix testing" --pr-number 456

  # Test input validation
  print_test_section "Input Validation"
  
  test_error "Missing labels" \
    --pr-number 123
    
  test_error "Missing PR number" \
    --labels "feature"
    
  test_error "Invalid PR number (non-numeric)" \
    --labels "feature" --pr-number "abc"
    
  test_error "Invalid PR number (negative)" \
    --labels "feature" --pr-number "-1"
    
  test_error "Unknown label" \
    --labels "unknown-label" --pr-number 123
    
  test_error "Mixed valid and invalid labels" \
    --labels "feature unknown-label" --pr-number 123

  # Test environment validation
  print_test_section "Environment Validation"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Missing GH_TOKEN..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  unset GH_TOKEN
  
  if run_apply_labels --labels "feature" --pr-number 123 >/dev/null 2>&1; then
    printf "❌ FAIL\n"
    printf "    Should fail without GH_TOKEN\n"
  else
    printf "✅ PASS\n"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  fi
  
  cleanup_test_env "$test_dir"

  # Test help functionality
  print_test_section "Help Functionality"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Help flag shows usage..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  if result=$(run_apply_labels --help 2>/dev/null); then
    if echo "$result" | grep -q "Usage:"; then
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      printf "❌ FAIL\n"
      printf "    Help output doesn't contain 'Usage:'\n"
    fi
  else
    printf "❌ FAIL\n"
    printf "    Help flag failed\n"
  fi
  
  cleanup_test_env "$test_dir"

  # Test verbose mode
  print_test_section "Verbose Mode"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Verbose mode shows details..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  if result=$(run_apply_labels --labels "feature" --pr-number 123 --verbose --dry-run 2>&1); then
    if echo "$result" | grep -q "Repository:" && echo "$result" | grep -q "Labels:"; then
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      printf "❌ FAIL\n"
      printf "    Verbose output missing expected details\n"
    fi
  else
    printf "❌ FAIL\n"
    printf "    Verbose mode failed\n"
  fi
  
  cleanup_test_env "$test_dir"

  # Test label validation
  print_test_section "Label Validation"
  
  test_success "Feature label valid" \
    "feature" \
    --labels "feature" --pr-number 123
    
  test_success "Bugfix label valid" \
    "bugfix" \
    --labels "bugfix" --pr-number 123
    
  test_success "Documentation label valid" \
    "documentation" \
    --labels "documentation" --pr-number 123
    
  test_success "Breaking change label valid" \
    "breaking-change" \
    --labels "breaking-change" --pr-number 123

  # Test edge cases
  print_test_section "Edge Cases"
  
  test_success "Very high PR number" \
    "pr edit 999999" \
    --labels "feature" --pr-number 999999
    
  test_success "Single character assignee" \
    "add-assignee x" \
    --labels "feature" --pr-number 123 --assignee "x"

  # Test realistic scenarios
  print_test_section "Realistic Scenarios"
  
  test_success "Typical feature PR" \
    "feature.*testing.*documentation" \
    --labels "feature testing documentation" --pr-number 123
    
  test_success "Bugfix with review needed" \
    "bugfix.*needs-review" \
    --labels "bugfix needs-review" --pr-number 456
    
  test_success "Breaking change release" \
    "breaking-change.*feature" \
    --labels "breaking-change feature" --pr-number 789

  # Print results
  print_test_results "$PASSED_TESTS" "$TOTAL_TESTS" "apply-pr-labels.sh"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_apply_labels
  
  # Exit with error code if tests failed
  if [ "$PASSED_TESTS" -ne "$TOTAL_TESTS" ]; then
    exit 1
  fi
fi 