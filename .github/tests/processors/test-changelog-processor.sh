#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Test script for changelog processor
#
# This script tests the changelog.sh processor with various content types,
# templates, and edge cases to ensure it works correctly with Keep a Changelog
# format.
###############################################################################

echo "🧪 Testing changelog processor..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSOR_PATH="$SCRIPT_DIR/../../actions/openai-chat/processors/changelog.sh"
TEMPLATE_PATH="$SCRIPT_DIR/../../templates/changelog.tmpl.md"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Test helper function
run_test() {
  local test_name="$1"
  local test_data="$2"
  local expected_pattern="$3"
  local vars="${4:-}"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  if actual=$(echo "$test_data" | "$PROCESSOR_PATH" - "$TEMPLATE_PATH" "$vars" 2>&1); then
    if echo "$actual" | grep -q "$expected_pattern"; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Pattern not found"
      echo "Expected pattern: $expected_pattern"
      echo "Actual output (first 300 chars):"
      echo "$actual" | head -c 300
      echo "..."
    fi
  else
    echo "❌ FAIL - Command failed with exit code $?"
    echo "Output: $actual"
  fi
  echo ""
}

# Test for specific content patterns
run_content_test() {
  local test_name="$1"
  local test_data="$2"
  local expected_content="$3"
  local vars="${4:-}"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  if actual=$(echo "$test_data" | "$PROCESSOR_PATH" - "$TEMPLATE_PATH" "$vars" 2>&1); then
    if echo "$actual" | grep -q "$expected_content"; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Expected content not found"
      echo "Expected: $expected_content"
      echo "Actual output (first 500 chars):"
      echo "$actual" | head -c 500
      echo "..."
    fi
  else
    echo "❌ FAIL - Command failed with exit code $?"
    echo "Output: $actual"
  fi
  echo ""
}

# Test 1: Complete changelog with all sections
test_complete_changelog() {
  local test_data='{
    "added": [
      "New authentication API endpoints",
      "Support for OAuth 2.0 flows",
      "Enhanced error handling middleware"
    ],
    "changed": [
      "Updated API response format for user data",
      "Improved database query performance",
      "Refactored user authentication logic"
    ],
    "deprecated": [
      "Legacy v1 authentication endpoints",
      "Old configuration format"
    ],
    "removed": [
      "Support for TLS 1.0 and 1.1",
      "Deprecated helper functions"
    ],
    "fixed": [
      "Memory leak in session management",
      "Race condition in user registration",
      "Incorrect timezone handling"
    ],
    "security": [
      "Updated dependencies with security patches",
      "Improved input validation"
    ]
  }'
  
  local vars_b64
  vars_b64=$(echo -e "VERSION=2.1.0\nDATE=2024-06-05" | base64)
  
  run_content_test "Complete changelog with all sections" "$test_data" "New authentication API endpoints" "$vars_b64"
  run_content_test "Complete changelog - Changed section" "$test_data" "Updated API response format" "$vars_b64"
  run_content_test "Complete changelog - Security section" "$test_data" "Updated dependencies" "$vars_b64"
  run_content_test "Complete changelog - version substitution" "$test_data" "2.1.0" "$vars_b64"
  run_content_test "Complete changelog - date substitution" "$test_data" "2024-06-05" "$vars_b64"
}

# Test 2: Minimal changelog with only one section
test_minimal_changelog() {
  local test_data='{
    "added": [],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": ["Critical bug fix for user authentication"],
    "security": []
  }'
  
  run_content_test "Minimal changelog with one section" "$test_data" "Critical bug fix"
  run_content_test "Minimal changelog - empty sections handled" "$test_data" "Fixed"
}

# Test 3: Changelog with only Added items
test_added_only() {
  local test_data='{
    "added": [
      "Revolutionary new feature",
      "Amazing user interface improvements",
      "Advanced analytics dashboard"
    ],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [],
    "security": []
  }'
  
  run_content_test "Added-only changelog" "$test_data" "Revolutionary new feature"
  run_content_test "Added-only changelog - multiple items" "$test_data" "Amazing user interface"
  run_content_test "Added-only changelog - Added section" "$test_data" "Added"
}

# Test 4: Empty changelog
test_empty_changelog() {
  local test_data='{
    "added": [],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [],
    "security": []
  }'
  
  run_content_test "Empty changelog" "$test_data" "## \[{{VERSION}}\] - {{DATE}}"
}

# Test 5: Special characters and markdown
test_special_characters() {
  local test_data='{
    "added": [
      "Support for `markdown` formatting in comments",
      "New **bold** text rendering",
      "URLs like https://example.com now work"
    ],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [
      "Fixed issue with \"quoted strings\" in config",
      "Resolved problem with $variables in templates",
      "Fixed regex patterns like /^test.*$/ in search"
    ],
    "security": []
  }'
  
  run_content_test "Special characters - markdown" "$test_data" "markdown.*formatting"
  run_content_test "Special characters - quotes" "$test_data" "quoted strings"
  run_content_test "Special characters - variables" "$test_data" "variables in templates"
}

# Test 6: Large changelog
test_large_changelog() {
  local test_data='{
    "added": [
      "Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5",
      "Feature 6", "Feature 7", "Feature 8", "Feature 9", "Feature 10"
    ],
    "changed": [
      "Change 1", "Change 2", "Change 3", "Change 4", "Change 5"
    ],
    "deprecated": [
      "Deprecated 1", "Deprecated 2", "Deprecated 3"
    ],
    "removed": [
      "Removed 1", "Removed 2"
    ],
    "fixed": [
      "Fix 1", "Fix 2", "Fix 3", "Fix 4", "Fix 5", "Fix 6"
    ],
    "security": [
      "Security 1", "Security 2", "Security 3"
    ]
  }'
  
  run_content_test "Large changelog - all sections" "$test_data" "Feature 10"
  run_content_test "Large changelog - Security section" "$test_data" "Security 3"
  run_content_test "Large changelog - many fixes" "$test_data" "Fix 6"
}

# Test 7: Mixed case and formatting
test_mixed_case() {
  local test_data='{
    "added": ["lowercase field test"],
    "CHANGED": ["UPPERCASE field test"],
    "fixed": ["Mixed Case field test"],
    "security": ["another lowercase test"]
  }'
  
  run_content_test "Mixed case fields" "$test_data" "lowercase field test"
}

# Test 8: Long descriptions
test_long_descriptions() {
  local test_data='{
    "added": [
      "This is a very long description of a feature that spans multiple lines and contains detailed information about what was implemented, why it was needed, and how it benefits users in their daily workflow"
    ],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [
      "Fixed a complex bug that was causing intermittent failures in the authentication system when users had special characters in their usernames and were logging in from certain geographic regions during peak hours"
    ],
    "security": []
  }'
  
  run_content_test "Long descriptions" "$test_data" "very long description"
  run_content_test "Long descriptions - complex bug" "$test_data" "complex bug"
}

# Test 9: Unicode and international characters
test_unicode_characters() {
  local test_data='{
    "added": [
      "Support for émojis 🎉 and unicode characters",
      "Internationalization for 中文, Español, and Français",
      "Currency symbols like € £ ¥ ₹"
    ],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [],
    "security": []
  }'
  
  run_content_test "Unicode characters" "$test_data" "émojis"
  run_content_test "Unicode characters - international" "$test_data" "中文"
  run_content_test "Unicode characters - currency" "$test_data" "€ £ ¥"
}

# Test 10: Error handling - invalid JSON
test_invalid_json() {
  local test_data='{"added": invalid json}'
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: Invalid JSON error handling"
  
  if output=$(echo "$test_data" | "$PROCESSOR_PATH" - "$TEMPLATE_PATH" "" 2>&1); then
    echo "❌ FAIL - Expected error but command succeeded"
  else
    if [[ "$output" =~ "Invalid JSON content" ]]; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Wrong error message: $output"
    fi
  fi
  echo ""
}

# Test 11: Error handling - missing template
test_missing_template() {
  local test_data='{"added":["test"]}'
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: Missing template error handling"
  
  if output=$(echo "$test_data" | "$PROCESSOR_PATH" - "nonexistent.md" "" 2>&1); then
    echo "❌ FAIL - Expected error but command succeeded"
  else
    if [[ "$output" =~ "Template file" && "$output" =~ "not found" ]]; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Wrong error message: $output"
    fi
  fi
  echo ""
}

# Test 12: Variable substitution without base64
test_variable_substitution_plain() {
  local test_data='{
    "added": ["New feature"],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [],
    "security": []
  }'
  
  local vars="VERSION=3.0.0"$'\n'"DATE=2024-12-25"
  
  run_content_test "Variable substitution - plain text" "$test_data" "3.0.0" "$vars"
  run_content_test "Variable substitution - date plain" "$test_data" "2024-12-25" "$vars"
}

# Test 13: Empty strings in arrays
test_empty_strings() {
  local test_data='{
    "added": ["", "Valid item", ""],
    "changed": [],
    "deprecated": [],
    "removed": [],
    "fixed": [""],
    "security": []
  }'
  
  run_content_test "Empty strings in arrays" "$test_data" "Valid item"
}

# Main test execution
main() {
  echo "Using processor: $PROCESSOR_PATH"
  echo "Using template: $TEMPLATE_PATH"
  echo ""
  
  test_complete_changelog
  test_minimal_changelog
  test_added_only
  test_empty_changelog
  test_special_characters
  test_large_changelog
  test_mixed_case
  test_long_descriptions
  test_unicode_characters
  test_invalid_json
  test_missing_template
  test_variable_substitution_plain
  test_empty_strings
  
  echo "🏁 Changelog processor tests completed!"
  echo "📊 Results: $PASSED_TESTS/$TOTAL_TESTS tests passed"
  
  if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
    echo "✅ All tests passed!"
    exit 0
  else
    echo "❌ Some tests failed"
    exit 1
  fi
}

main "$@" 