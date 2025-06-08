#!/usr/bin/env bash

# 🧪 Test Suite: post-commit-feedback.sh
# 
# Tests the PR commit quality feedback logic extracted from pr-enhance.yml
# Validates percentage calculations, feedback generation, and GitHub CLI operations.

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/pr-enhance"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/pr-enhance/commit-feedback"
POST_FEEDBACK_SCRIPT="$SCRIPTS_DIR/post-commit-feedback.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test output tracking
TOTAL_TESTS=0
PASSED_TESTS=0

# Load fixture data
load_fixtures() {
  if [[ ! -f "$FIXTURES_DIR/commit-feedback-scenarios.json" ]]; then
    echo "❌ Missing fixture file: commit-feedback-scenarios.json"
    exit 1
  fi
}

# Parse JSON fixture (basic jq-like parsing for simple values)
get_fixture_value() {
  local fixture_file="$1"
  local path="$2"
  
  # Simple JSON parsing for our specific structure
  # This is a basic implementation - in production you'd use jq
  grep -o "\"$path\":[[:space:]]*[^,}]*" "$FIXTURES_DIR/$fixture_file" | sed 's/.*:[[:space:]]*//' | tr -d '"'
}

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
# Also capture the body file content if it exists
for arg in "$@"; do
  if [[ "$arg" == --body-file=* ]]; then
    file="${arg#--body-file=}"
    if [[ -f "$file" ]]; then
      echo "MOCK_GH_BODY_CONTENT:" >> "$MOCK_LOG_FILE"
      cat "$file" | sed 's/^/  /' >> "$MOCK_LOG_FILE"
    fi
  elif [[ "$prev_arg" == "--body-file" && -f "$arg" ]]; then
    echo "MOCK_GH_BODY_CONTENT:" >> "$MOCK_LOG_FILE"
    cat "$arg" | sed 's/^/  /' >> "$MOCK_LOG_FILE"
  fi
  prev_arg="$arg"
done
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
  unset GH_TOKEN GITHUB_REPOSITORY MOCK_LOG_FILE
}

# Run post-commit-feedback script with given arguments
run_post_feedback() {
  bash "$POST_FEEDBACK_SCRIPT" "$@"
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
  if run_post_feedback "${args[@]}" >/dev/null 2>&1; then
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
  
  if run_post_feedback "${args[@]}" >/dev/null 2>&1; then
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
  
  if run_post_feedback "${args[@]}" >/dev/null 2>&1; then
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

# Test that script contains expected content patterns
test_content() {
  local test_name="$1"
  shift
  local expected_pattern="$1"
  shift
  local args=("$@")
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "$test_name..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  # Add --dry-run to args to capture content without posting
  args+=(--dry-run)
  
  if result=$(run_post_feedback "${args[@]}" 2>&1); then
    if echo "$result" | grep -q "$expected_pattern"; then
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      printf "❌ FAIL\n"
      printf "    Expected pattern not found: '%s'\n" "$expected_pattern"
      printf "    Actual output:\n"
      echo "$result" | sed 's/^/      /'
    fi
  else
    printf "❌ FAIL (script error)\n"
    printf "    Script failed to execute\n"
  fi
  
  cleanup_test_env "$test_dir"
}

# Test using fixture scenario data
test_fixture_scenario() {
  local scenario_name="$1"
  local pr_number="${2:-123}"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Fixture: $scenario_name..."
  
  # Check if fixture file exists
  if [[ ! -f "$FIXTURES_DIR/commit-feedback-scenarios.json" ]]; then
    printf "❌ FAIL\n"
    printf "    Fixture file not found: commit-feedback-scenarios.json\n"
    return
  fi
  
  # Extract scenario data from fixture
  local conventional total expected_percentage expected_feedback_type
  
  # Parse fixture data (basic parsing - in production use jq)
  local fixture_content
  fixture_content=$(cat "$FIXTURES_DIR/commit-feedback-scenarios.json" 2>/dev/null)
  
  if [[ -z "$fixture_content" ]]; then
    printf "❌ FAIL\n"
    printf "    Could not read fixture file\n"
    return
  fi
  
  # Extract values using grep and sed (simplified JSON parsing)
  # Look for the scenario and extract values within that section
  local scenario_section
  scenario_section=$(echo "$fixture_content" | awk "/\"$scenario_name\":/{flag=1} flag && /^[[:space:]]*}[[:space:]]*,?$/{flag=0} flag")
  
  conventional=$(echo "$scenario_section" | grep '"conventional":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  total=$(echo "$scenario_section" | grep '"total":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  expected_feedback_type=$(echo "$scenario_section" | grep '"expected_feedback_type":' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
  
  if [[ -z "$conventional" || -z "$total" ]]; then
    printf "❌ FAIL\n"
    printf "    Could not parse fixture data for scenario: %s\n" "$scenario_name"
    printf "    conventional: '%s', total: '%s'\n" "$conventional" "$total"
    return
  fi
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  # Run the script with fixture data
  if run_post_feedback --conventional "$conventional" --total "$total" --pr-number "$pr_number" >/dev/null 2>&1; then
    printf "✅ PASS\n"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    printf "❌ FAIL (script error)\n"
    printf "    Script failed with conventional=%s total=%s pr-number=%s\n" "$conventional" "$total" "$pr_number"
  fi
  
  cleanup_test_env "$test_dir"
}

#######################################
# Main Test Suite
#######################################

test_post_commit_feedback() {
  print_test_header "post-commit-feedback.sh"
  
  # Load fixture data
  load_fixtures
  
  # Test fixture scenarios
  print_test_section "Fixture-Based Scenarios"
  
  test_fixture_scenario "perfect_score"
  test_fixture_scenario "good_score" 
  test_fixture_scenario "poor_score"
  test_fixture_scenario "zero_conventional"
  test_fixture_scenario "single_commit_perfect"
  test_fixture_scenario "fractional_percentage"
  test_fixture_scenario "large_numbers"
  
  # Test basic functionality
  print_test_section "Basic Feedback Posting"
  
  test_success "Good commits (100% conventional)" \
    "pr comment" \
    --conventional 5 --total 5 --pr-number 123
    
  test_success "Mixed commits (80% conventional)" \
    "pr comment" \
    --conventional 4 --total 5 --pr-number 456
    
  test_success "Poor commits (40% conventional)" \
    "pr comment" \
    --conventional 2 --total 5 --pr-number 789

  # Test percentage calculation edge cases
  print_test_section "Percentage Calculations"
  
  test_success "Perfect score (100%)" \
    "pr comment" \
    --conventional 10 --total 10 --pr-number 123
    
  test_success "Zero conventional commits" \
    "pr comment" \
    --conventional 0 --total 5 --pr-number 123
    
  test_success "Single commit (100%)" \
    "pr comment" \
    --conventional 1 --total 1 --pr-number 123
    
  test_success "Fractional percentage (33%)" \
    "pr comment" \
    --conventional 1 --total 3 --pr-number 123
    
  test_success "Large numbers" \
    "pr comment" \
    --conventional 85 --total 100 --pr-number 123

  # Test custom thresholds
  print_test_section "Custom Thresholds"
  
  test_success "90% threshold with 89% conventional" \
    "pr comment" \
    --conventional 8 --total 9 --pr-number 123 --threshold 90
    
  test_success "50% threshold with 60% conventional" \
    "pr comment" \
    --conventional 3 --total 5 --pr-number 123 --threshold 50
    
  test_success "0% threshold (always good)" \
    "pr comment" \
    --conventional 0 --total 5 --pr-number 123 --threshold 0

  # Test feedback content generation
  print_test_section "Feedback Content"
  
  test_content "Good feedback contains celebration" \
    "Great work" \
    --conventional 8 --total 10 --pr-number 123
    
  test_content "Poor feedback contains improvement suggestion" \
    "Needs improvement" \
    --conventional 2 --total 10 --pr-number 123
    
  test_content "Feedback contains conventional examples" \
    "feat(api):" \
    --conventional 5 --total 10 --pr-number 123
    
  test_content "Feedback contains percentage" \
    "50%" \
    --conventional 5 --total 10 --pr-number 123

  # Test repository handling
  print_test_section "Repository Handling"
  
  test_success "Default repo from environment" \
    "testowner/testrepo" \
    --conventional 5 --total 10 --pr-number 123
    
  test_success "Custom repository" \
    "custom/repo" \
    --conventional 5 --total 10 --pr-number 123 --repo "custom/repo"

  # Test dry run mode
  print_test_section "Dry Run Mode"
  
  test_dry_run "Dry run with good commits" \
    --conventional 8 --total 10 --pr-number 123
    
  test_dry_run "Dry run with poor commits" \
    --conventional 2 --total 10 --pr-number 123

  # Test zero commits edge case
  print_test_section "Zero Commits Edge Case"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Zero total commits..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  
  if run_post_feedback --conventional 0 --total 0 --pr-number 123 >/dev/null 2>&1; then
    # Should succeed but not post anything
    if [[ -s "$MOCK_LOG_FILE" ]]; then
      printf "❌ FAIL\n"
      printf "    Should not post comment for zero commits\n"
    else
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
  else
    printf "❌ FAIL (script error)\n"
    printf "    Script should handle zero commits gracefully\n"
  fi
  
  cleanup_test_env "$test_dir"

  # Test input validation
  print_test_section "Input Validation"
  
  test_error "Missing conventional count" \
    --total 5 --pr-number 123
    
  test_error "Missing total count" \
    --conventional 3 --pr-number 123
    
  test_error "Missing PR number" \
    --conventional 3 --total 5
    
  test_error "Invalid conventional count (non-numeric)" \
    --conventional "abc" --total 5 --pr-number 123
    
  test_error "Invalid total count (negative)" \
    --conventional 3 --total -1 --pr-number 123
    
  test_error "Invalid PR number (non-numeric)" \
    --conventional 3 --total 5 --pr-number "abc"
    
  test_error "Threshold over 100" \
    --conventional 3 --total 5 --pr-number 123 --threshold 101
    
  test_error "Threshold under 0" \
    --conventional 3 --total 5 --pr-number 123 --threshold -1
    
  test_error "Conventional count exceeds total" \
    --conventional 6 --total 5 --pr-number 123
    
  test_error "Unknown argument" \
    --conventional 3 --total 5 --pr-number 123 --unknown value

  # Test environment validation
  print_test_section "Environment Validation"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Missing GH_TOKEN..."
  
  local test_dir="test_env_$$_$TOTAL_TESTS"
  setup_test_env "$test_dir"
  unset GH_TOKEN
  
  if run_post_feedback --conventional 3 --total 5 --pr-number 123 >/dev/null 2>&1; then
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
  
  if result=$(run_post_feedback --help 2>/dev/null); then
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
  
  if result=$(run_post_feedback --conventional 3 --total 5 --pr-number 123 --verbose --dry-run 2>&1); then
    if echo "$result" | grep -q "Repository:" && echo "$result" | grep -q "Conventional Commits:"; then
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

  # Test realistic scenarios
  print_test_section "Realistic Scenarios"
  
  test_success "Excellent PR (95% conventional)" \
    "pr comment" \
    --conventional 19 --total 20 --pr-number 123
    
  test_success "Good PR (85% conventional)" \
    "pr comment" \
    --conventional 17 --total 20 --pr-number 456
    
  test_success "Needs work (60% conventional)" \
    "pr comment" \
    --conventional 12 --total 20 --pr-number 789
    
  test_success "Poor quality (25% conventional)" \
    "pr comment" \
    --conventional 5 --total 20 --pr-number 999

  # Print results
  print_test_results "$PASSED_TESTS" "$TOTAL_TESTS" "post-commit-feedback.sh"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_post_commit_feedback
  
  # Exit with error code if tests failed
  if [ "$PASSED_TESTS" -ne "$TOTAL_TESTS" ]; then
    exit 1
  fi
fi 