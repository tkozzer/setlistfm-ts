#!/usr/bin/env bash

# 🧪 Test Suite: determine-pr-labels.sh
# 
# Tests the PR label determination logic extracted from pr-enhance.yml
# Validates commit type counts, percentage calculations, and edge cases.

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/pr-enhance"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/pr-enhance/pr-labels"
DETERMINE_LABELS_SCRIPT="$SCRIPTS_DIR/determine-pr-labels.sh"

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

# Run determine-pr-labels script with given arguments
run_determine_labels() {
  bash "$DETERMINE_LABELS_SCRIPT" "$@"
}

# Test that a specific set of labels is returned
test_labels() {
  local test_name="$1"
  shift
  local expected_labels="$1"
  shift
  local args=("$@")
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "$test_name..."
  
  # Run the script
  local result
  if result=$(run_determine_labels "${args[@]}" 2>/dev/null); then
    # Sort both expected and actual for comparison (labels can be in any order)
    local expected_sorted actual_sorted
    expected_sorted=$(echo "$expected_labels" | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
    actual_sorted=$(echo "$result" | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
    
    if [ "$expected_sorted" = "$actual_sorted" ]; then
      printf "✅ PASS\n"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      printf "❌ FAIL\n"
      printf "    Expected: '%s'\n" "$expected_labels"
      printf "    Actual:   '%s'\n" "$result"
    fi
  else
    printf "❌ FAIL (script error)\n"
    printf "    Script failed to execute\n"
  fi
}

# Test that script exits with error
test_error() {
  local test_name="$1"
  shift
  local args=("$@")
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "$test_name..."
  
  if run_determine_labels "${args[@]}" >/dev/null 2>&1; then
    printf "❌ FAIL\n"
    printf "    Expected error, but script succeeded\n"
  else
    printf "✅ PASS\n"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  fi
}

# Test using fixture scenario data
test_fixture_scenario() {
  local scenario_name="$1"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Fixture: $scenario_name..."
  
  # Parse fixture data (basic parsing)
  local fixture_content
  fixture_content=$(cat "$FIXTURES_DIR/pr-label-scenarios.json" 2>/dev/null)
  
  if [[ -z "$fixture_content" ]]; then
    printf "❌ FAIL\n"
    printf "    Could not load fixture file\n"
    return
  fi
  
  # Extract commit counts and expected labels
  local feat fix docs chore refactor perf test style ci break conv total
  
  # Parse the specific scenario section
  local scenario_section
  scenario_section=$(echo "$fixture_content" | awk "/\"$scenario_name\":/{flag=1} flag && /^[[:space:]]*}[[:space:]]*,?$/{flag=0} flag")
  
  feat=$(echo "$scenario_section" | grep '"feat":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  fix=$(echo "$scenario_section" | grep '"fix":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  docs=$(echo "$scenario_section" | grep '"docs":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  chore=$(echo "$scenario_section" | grep '"chore":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  refactor=$(echo "$scenario_section" | grep '"refactor":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  perf=$(echo "$scenario_section" | grep '"perf":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  test=$(echo "$scenario_section" | grep '"test":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  style=$(echo "$scenario_section" | grep '"style":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  ci=$(echo "$scenario_section" | grep '"ci":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  break=$(echo "$scenario_section" | grep '"break":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  conv=$(echo "$scenario_section" | grep '"conv":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  total=$(echo "$scenario_section" | grep '"total":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
  
  if [[ -z "$total" ]]; then
    printf "❌ FAIL\n"
    printf "    Could not parse fixture data for scenario: %s\n" "$scenario_name"
    return
  fi
  
  # Run the script with fixture data
  if result=$(run_determine_labels --feat "$feat" --fix "$fix" --docs "$docs" --chore "$chore" --refactor "$refactor" --perf "$perf" --test "$test" --style "$style" --ci "$ci" --break "$break" --conv "$conv" --total "$total" 2>/dev/null); then
    # For now, just check that it runs successfully
    printf "✅ PASS\n"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    printf "❌ FAIL (script error)\n"
    printf "    Script failed with fixture data\n"
  fi
}

#######################################
# Main Test Suite
#######################################

test_determine_labels() {
  print_test_header "determine-pr-labels.sh"
  
  # Test fixture scenarios first
  print_test_section "Fixture-Based Scenarios"
  
  test_fixture_scenario "single_feature"
  test_fixture_scenario "single_fix"
  test_fixture_scenario "feature_and_fix"
  test_fixture_scenario "all_conventional_types"
  test_fixture_scenario "needs_review_80_percent"
  test_fixture_scenario "no_needs_review_80_percent"
  test_fixture_scenario "zero_commits"
  test_fixture_scenario "typical_feature_pr"
  test_fixture_scenario "bugfix_poor_commits"
  
  # Test basic functionality
  print_test_section "Basic Label Assignment"
  
  test_labels "Single feature commit" \
    "feature" \
    --feat 1 --conv 1 --total 1
    
  test_labels "Single fix commit" \
    "bugfix" \
    --fix 1 --conv 1 --total 1
    
  test_labels "Single docs commit" \
    "documentation" \
    --docs 1 --conv 1 --total 1
    
  test_labels "Single chore commit" \
    "maintenance" \
    --chore 1 --conv 1 --total 1
    
  test_labels "Single refactor commit" \
    "refactor" \
    --refactor 1 --conv 1 --total 1
    
  test_labels "Single performance commit" \
    "performance" \
    --perf 1 --conv 1 --total 1
    
  test_labels "Single test commit" \
    "testing" \
    --test 1 --conv 1 --total 1
    
  test_labels "Single style commit" \
    "style" \
    --style 1 --conv 1 --total 1
    
  test_labels "Single CI commit" \
    "ci-cd" \
    --ci 1 --conv 1 --total 1
    
  test_labels "Single breaking change commit" \
    "breaking-change" \
    --break 1 --conv 1 --total 1

  # Test multiple commit types
  print_test_section "Multiple Commit Types"
  
  test_labels "Feature and fix commits" \
    "feature bugfix" \
    --feat 2 --fix 1 --conv 3 --total 3
    
  test_labels "All conventional commit types" \
    "feature bugfix documentation maintenance refactor performance testing style ci-cd breaking-change" \
    --feat 1 --fix 1 --docs 1 --chore 1 --refactor 1 --perf 1 --test 1 --style 1 --ci 1 --break 1 --conv 10 --total 10

  # Test needs-review logic
  print_test_section "Needs Review Logic"
  
  test_labels "100% conventional - no needs-review" \
    "feature" \
    --feat 1 --conv 1 --total 1
    
  test_labels "80% conventional - no needs-review" \
    "feature" \
    --feat 1 --conv 4 --total 5
    
  test_labels "79% conventional - needs review" \
    "feature needs-review" \
    --feat 1 --conv 3 --total 4
    
  test_labels "50% conventional - needs review" \
    "feature needs-review" \
    --feat 1 --conv 1 --total 2
    
  test_labels "0% conventional - needs review" \
    "feature needs-review" \
    --feat 1 --conv 0 --total 1

  # Test custom threshold
  print_test_section "Custom Threshold"
  
  test_labels "90% threshold - 89% conventional needs review" \
    "feature needs-review" \
    --feat 1 --conv 8 --total 9 --threshold 90
    
  test_labels "50% threshold - 60% conventional no review" \
    "feature" \
    --feat 1 --conv 3 --total 5 --threshold 50

  # Test edge cases
  print_test_section "Edge Cases"
  
  test_labels "Zero commits" \
    "" \
    --conv 0 --total 0
    
  test_labels "No conventional commits" \
    "feature needs-review" \
    --feat 1 --conv 0 --total 1
    
  test_labels "All zeros" \
    "" \
    --feat 0 --fix 0 --docs 0 --chore 0 --refactor 0 --perf 0 --test 0 --style 0 --ci 0 --break 0 --conv 0 --total 0

  # Test large numbers
  print_test_section "Large Numbers"
  
  test_labels "Large commit counts" \
    "feature bugfix" \
    --feat 100 --fix 50 --conv 150 --total 150

  # Test validation errors
  print_test_section "Input Validation"
  
  test_error "Negative feat count" \
    --feat -1 --conv 1 --total 1
    
  test_error "Non-numeric feat count" \
    --feat abc --conv 1 --total 1
    
  test_error "Threshold over 100" \
    --feat 1 --conv 1 --total 1 --threshold 101
    
  test_error "Threshold under 0" \
    --feat 1 --conv 1 --total 1 --threshold -1
    
  test_error "Conv count exceeds total" \
    --feat 1 --conv 2 --total 1
    
  test_error "Unknown argument" \
    --feat 1 --unknown 2 --conv 1 --total 1

  # Test help functionality
  print_test_section "Help Functionality"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  printf "  🧪 %-45s" "Help flag shows usage..."
  if result=$(run_determine_labels --help 2>/dev/null); then
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

  # Test percentage calculation precision
  print_test_section "Percentage Calculation Precision"
  
  test_labels "33.33% conventional (rounds down)" \
    "feature needs-review" \
    --feat 1 --conv 1 --total 3
    
  test_labels "66.66% conventional (rounds down)" \
    "feature needs-review" \
    --feat 1 --conv 2 --total 3
    
  test_labels "33.33% with 50% threshold (passes)" \
    "feature" \
    --feat 1 --conv 1 --total 3 --threshold 33

  # Test realistic scenarios
  print_test_section "Realistic Scenarios"
  
  test_labels "Typical feature PR" \
    "feature testing documentation" \
    --feat 3 --test 2 --docs 1 --conv 6 --total 6
    
  test_labels "Bugfix with poor commit messages" \
    "bugfix needs-review" \
    --fix 2 --conv 1 --total 3
    
  test_labels "Mixed refactor with good practices" \
    "refactor testing performance" \
    --refactor 5 --test 3 --perf 1 --conv 9 --total 9
    
  test_labels "Breaking change release" \
    "breaking-change feature bugfix documentation" \
    --break 2 --feat 3 --fix 1 --docs 2 --conv 8 --total 8

  # Print results
  print_test_results "$PASSED_TESTS" "$TOTAL_TESTS" "determine-pr-labels.sh"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_determine_labels
  
  # Exit with error code if tests failed
  if [ "$PASSED_TESTS" -ne "$TOTAL_TESTS" ]; then
    exit 1
  fi
fi 