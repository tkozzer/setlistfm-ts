#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Master test script for all processors
#
# This script runs all individual processor test scripts and provides
# a comprehensive summary of test results across the entire processor
# architecture.
###############################################################################

echo "🧪 Running comprehensive processor test suite..."
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test script paths
SHARED_TEST="$SCRIPT_DIR/test-shared-utilities.sh"
CHANGELOG_TEST="$SCRIPT_DIR/test-changelog-processor.sh"
PR_ENHANCE_TEST="$SCRIPT_DIR/test-pr-enhance-processor.sh"
PR_DESCRIPTION_TEST="$SCRIPT_DIR/test-pr-description-processor.sh"
GENERIC_TEST="$SCRIPT_DIR/test-generic-processor.sh"
RELEASE_NOTES_TEST="$SCRIPT_DIR/test-release-notes-processor.sh"

# Results tracking
declare -A test_results
declare -A test_counts
total_tests=0
total_passed=0
failed_components=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a test script and capture results
run_test_script() {
  local test_name="$1"
  local test_script="$2"
  
  echo ""
  echo "🔍 Running $test_name tests..."
  echo "----------------------------------------"
  
  if [[ ! -f "$test_script" ]]; then
    echo -e "${RED}❌ Test script not found: $test_script${NC}"
    test_results["$test_name"]="MISSING"
    return 1
  fi
  
  if ! [[ -x "$test_script" ]]; then
    echo -e "${YELLOW}⚠️  Making $test_script executable...${NC}"
    chmod +x "$test_script"
  fi
  
  local output
  local exit_code
  
  if output=$("$test_script" 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  
  # Extract test counts from output
  local passed_count failed_count total_count
  if [[ "$output" =~ Results:\ ([0-9]+)/([0-9]+)\ tests\ passed ]]; then
    passed_count="${BASH_REMATCH[1]}"
    total_count="${BASH_REMATCH[2]}"
    failed_count=$((total_count - passed_count))
  else
    # Fallback if pattern doesn't match
    passed_count="?"
    failed_count="?"
    total_count="?"
  fi
  
  test_counts["$test_name"]="$passed_count/$total_count"
  
  if [[ $exit_code -eq 0 ]]; then
    test_results["$test_name"]="PASS"
    echo -e "${GREEN}✅ $test_name: All tests passed ($passed_count/$total_count)${NC}"
    total_tests=$((total_tests + total_count))
    total_passed=$((total_passed + passed_count))
  else
    test_results["$test_name"]="FAIL"
    echo -e "${RED}❌ $test_name: Some tests failed ($passed_count/$total_count)${NC}"
    failed_components+=("$test_name")
    total_tests=$((total_tests + total_count))
    total_passed=$((total_passed + passed_count))
    
    # Show last few lines of output for failed tests
    echo ""
    echo "📋 Failure details:"
    echo "$output" | tail -10
  fi
}

# Function to display comprehensive summary
display_summary() {
  echo ""
  echo "=================================================="
  echo "🏁 COMPREHENSIVE TEST RESULTS SUMMARY"
  echo "=================================================="
  echo ""
  
  # Component-wise results
  echo "📊 Component Test Results:"
  echo "-------------------------"
  for component in "Shared Utilities" "Changelog Processor" "PR Enhance Processor" "PR Description Processor" "Release Notes Processor" "Generic Processor"; do
    local status="${test_results[$component]:-SKIPPED}"
    local count="${test_counts[$component]:-0/0}"
    
    case "$status" in
      "PASS")
        echo -e "${GREEN}✅ $component: $count tests passed${NC}"
        ;;
      "FAIL")
        echo -e "${RED}❌ $component: $count tests (some failed)${NC}"
        ;;
      "MISSING")
        echo -e "${YELLOW}⚠️  $component: Test script missing${NC}"
        ;;
      *)
        echo -e "${YELLOW}⚠️  $component: Skipped${NC}"
        ;;
    esac
  done
  
  echo ""
  echo "📈 Overall Statistics:"
  echo "---------------------"
  echo "Total Tests Run: $total_tests"
  echo "Tests Passed: $total_passed"
  echo "Tests Failed: $((total_tests - total_passed))"
  
  local pass_rate
  if [[ $total_tests -gt 0 ]]; then
    pass_rate=$(( (total_passed * 100) / total_tests ))
    echo "Pass Rate: ${pass_rate}%"
  else
    echo "Pass Rate: N/A"
  fi
  
  echo ""
  if [[ ${#failed_components[@]} -eq 0 && $total_tests -gt 0 ]]; then
    echo -e "${GREEN}🎉 ALL PROCESSOR TESTS PASSED! 🎉${NC}"
    echo ""
    echo "✅ All processors are working correctly"
    echo "✅ Shared utilities are functioning properly" 
    echo "✅ Error handling is robust"
    echo "✅ Edge cases are covered"
    echo ""
    echo -e "${GREEN}The processor architecture is ready for production! 🚀${NC}"
  elif [[ ${#failed_components[@]} -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  No tests were run${NC}"
  else
    echo -e "${RED}❌ SOME COMPONENTS HAVE FAILING TESTS${NC}"
    echo ""
    echo "Failed components:"
    for component in "${failed_components[@]}"; do
      echo -e "${RED}  • $component${NC}"
    done
    echo ""
    echo "Please review the test failures above and fix the issues."
  fi
  
  echo ""
  echo "=================================================="
}

# Function to show test coverage summary
display_coverage_summary() {
  echo ""
  echo "🔍 Test Coverage Summary:"
  echo "------------------------"
  
  echo "Shared Utilities (shared.sh):"
  echo "  • Input validation and error handling"
  echo "  • Base64 encoding/decoding detection"
  echo "  • JSON processing and field extraction"
  echo "  • Template variable substitution"
  echo "  • Handlebars cleanup and formatting"
  echo "  • Performance and edge case testing"
  echo ""
  
  echo "Changelog Processor (changelog.sh):"
  echo "  • Keep a Changelog format compliance"
  echo "  • All section types (Added, Changed, Deprecated, etc.)"
  echo "  • Empty arrays and missing sections"
  echo "  • Special characters and Unicode support"
  echo "  • Variable substitution (VERSION, DATE)"
  echo "  • Large content and performance testing"
  echo ""
  
  echo "PR Enhance Processor (pr-enhance.sh):"
  echo "  • PR enhancement JSON schema compliance"
  echo "  • Changes array processing and formatting"
  echo "  • Summary, testing, and documentation fields"
  echo "  • Commit analysis handling"
  echo "  • Technical content and code references"
  echo "  • Unicode and international character support"
  echo ""
  
  echo "PR Description Processor (pr-description.sh):"
  echo "  • Complex nested JSON structure handling"
  echo "  • Conditional sections ({{#if}}, {{#unless}})"
  echo "  • Array processing ({{#each}} blocks)"
  echo "  • Breaking changes object arrays"
  echo "  • What's new and changes categorization"
  echo "  • Professional PR description formatting"
  echo ""

  echo "Release Notes Processor (release-notes-processor.sh):"
  echo "  • Changelog and commit extraction"
  echo "  • Previous release fallback logic"
  echo "  • OpenAI API invocation and error handling"
  echo "  • Template rendering of markdown"
  echo "  • GitHub release creation"
  echo ""
  
  echo "Generic Processor (generic.sh):"
  echo "  • Plain text and JSON content handling"
  echo "  • Basic template variable substitution"
  echo "  • Field replacement for unknown schemas"
  echo "  • Fallback processing for custom templates"
  echo "  • Error graceful handling for invalid JSON"
  echo "  • Multi-line content and large data support"
}

# Main execution
main() {
  echo "Starting comprehensive test suite for processor architecture..."
  echo "This will test all processors and shared utilities."
  echo ""
  
  # Run all test scripts
  run_test_script "Shared Utilities" "$SHARED_TEST"
  run_test_script "Changelog Processor" "$CHANGELOG_TEST"
  run_test_script "PR Enhance Processor" "$PR_ENHANCE_TEST"
  run_test_script "PR Description Processor" "$PR_DESCRIPTION_TEST"
  run_test_script "Release Notes Processor" "$RELEASE_NOTES_TEST"
  run_test_script "Generic Processor" "$GENERIC_TEST"
  
  # Display comprehensive results
  display_summary
  display_coverage_summary
  
  # Exit with appropriate code
  if [[ ${#failed_components[@]} -eq 0 && $total_tests -gt 0 ]]; then
    exit 0
  else
    exit 1
  fi
}

# Handle script arguments
if [[ $# -gt 0 ]]; then
  case "$1" in
    "--help"|"-h")
      echo "Usage: $0 [--help|--summary-only]"
      echo ""
      echo "This script runs comprehensive tests for all processors:"
      echo "  • Shared utilities (validation, JSON processing, etc.)"
      echo "  • Changelog processor (Keep a Changelog format)"
      echo "  • PR enhance processor (PR enhancement schema)"
      echo "  • PR description processor (complex nested structures)"
      echo "  • Generic processor (fallback for unknown templates)"
      echo ""
      echo "Options:"
      echo "  --help, -h          Show this help message"
      echo "  --summary-only      Show only the test coverage summary"
      exit 0
      ;;
    "--summary-only")
      display_coverage_summary
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
fi

main "$@" 