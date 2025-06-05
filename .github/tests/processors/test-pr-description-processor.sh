#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Test script for pr-description processor
#
# This script tests the pr-description.sh processor with various content types,
# templates, and edge cases to ensure it works correctly with the complex
# PR description template structure.
###############################################################################

echo "🧪 Testing pr-description processor..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSOR_PATH="$SCRIPT_DIR/../../actions/openai-chat/processors/pr-description.sh"
TEMPLATE_PATH="$SCRIPT_DIR/../../templates/pr-description.tmpl.md"
TEST_DIR="$SCRIPT_DIR/../../actions/openai-chat/processors"

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
    if [[ "$actual" =~ $expected_pattern ]]; then
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

# Test 1: Complete happy path with all sections
test_complete_pr() {
  local test_data='{
    "title": "Major feature release with new APIs",
    "overview": "This release introduces several new API endpoints and improves existing functionality. Users will benefit from enhanced performance and new capabilities.",
    "whats_new": [
      "New authentication API",
      "Enhanced error handling",
      "Improved documentation"
    ],
    "changes": {
      "features": [
        "Added OAuth 2.0 support",
        "New user management endpoints"
      ],
      "bug_fixes": [
        "Fixed memory leak in API client",
        "Resolved timeout issues"
      ],
      "improvements": [
        "Better error messages",
        "Faster response times"
      ],
      "internal": [
        "Updated CI/CD pipeline",
        "Refactored core modules"
      ],
      "documentation": [
        "Updated API reference",
        "Added code examples"
      ]
    },
    "testing_notes": "All automated tests pass. Manual testing completed for new authentication flows.",
    "documentation_notes": "Please review the updated API documentation at docs/api.md",
    "breaking_changes": [
      {
        "change": "Authentication endpoints now require API version header",
        "migration": "Add X-API-Version: v2 header to all authentication requests"
      }
    ],
    "merge_instructions": "Ensure all checks pass, review breaking changes carefully, then squash and merge."
  }'
  
  local vars_b64
  vars_b64=$(echo -e "VERSION=2.0.0\nDATE=2024-06-05" | base64)
  
  run_content_test "Complete PR with all sections" "$test_data" "Major feature release with new APIs" "$vars_b64"
  run_content_test "Complete PR - OAuth feature" "$test_data" "Added OAuth 2.0 support" "$vars_b64"
  run_content_test "Complete PR - breaking changes" "$test_data" "Authentication endpoints now require" "$vars_b64"
  run_content_test "Complete PR - version substitution" "$test_data" "Release v2.0.0" "$vars_b64"
}

# Test 2: Minimal PR with only required fields
test_minimal_pr() {
  local test_data='{
    "title": "Minor bug fixes",
    "overview": "This release contains small bug fixes and stability improvements.",
    "whats_new": [],
    "changes": {
      "features": [],
      "bug_fixes": ["Fixed null pointer exception"],
      "improvements": [],
      "internal": [],
      "documentation": []
    },
    "testing_notes": "Standard test suite passed",
    "documentation_notes": "No documentation changes",
    "breaking_changes": [],
    "merge_instructions": "Standard merge process"
  }'
  
  run_content_test "Minimal PR with empty arrays" "$test_data" "Minor bug fixes"
  run_content_test "Minimal PR - no breaking changes" "$test_data" "None in this release"
}

# Test 3: PR with only features
test_features_only() {
  local test_data='{
    "title": "New feature release",
    "overview": "Added exciting new functionality.",
    "whats_new": ["Amazing new feature", "Better user experience"],
    "changes": {
      "features": ["Feature A", "Feature B"],
      "bug_fixes": [],
      "improvements": [],
      "internal": [],
      "documentation": []
    },
    "testing_notes": "Feature testing completed",
    "documentation_notes": "Updated feature docs",
    "breaking_changes": [],
    "merge_instructions": "Review features carefully"
  }'
  
  run_content_test "Features-only PR" "$test_data" "Amazing new feature"
  run_content_test "Features-only PR - Features section" "$test_data" "### ✨ Features"
}

# Test 4: Multiple breaking changes
test_multiple_breaking_changes() {
  local test_data='{
    "title": "Major version update",
    "overview": "Breaking changes for v3.0.0",
    "whats_new": ["New API structure"],
    "changes": {
      "features": ["Redesigned API"],
      "bug_fixes": [],
      "improvements": [],
      "internal": [],
      "documentation": []
    },
    "testing_notes": "Migration testing completed",
    "documentation_notes": "Migration guide available",
    "breaking_changes": [
      {
        "change": "Removed deprecated v1 endpoints",
        "migration": "Use v2 endpoints instead. See migration guide."
      },
      {
        "change": "Changed response format for user data",
        "migration": "Update client code to handle new user object structure"
      }
    ],
    "merge_instructions": "Coordinate with documentation team before merge"
  }'
  
  run_content_test "Multiple breaking changes" "$test_data" "Removed deprecated v1 endpoints"
  run_content_test "Multiple breaking changes - second item" "$test_data" "Changed response format"
  run_content_test "Multiple breaking changes - migration" "$test_data" "Migration:"
}

# Test 5: Special characters and edge cases
test_special_characters() {
  local test_data='{
    "title": "Release with \"quotes\" & special chars",
    "overview": "Testing special characters: $PATH, {braces}, [brackets], and\nmulti-line content.",
    "whats_new": ["Feature with $special chars", "Multi\nline\nfeature"],
    "changes": {
      "features": [],
      "bug_fixes": ["Fixed issue with \"quoted strings\"", "Resolved {bracket} problems"],
      "improvements": [],
      "internal": [],
      "documentation": []
    },
    "testing_notes": "Special character testing: passed",
    "documentation_notes": "Updated docs with examples",
    "breaking_changes": [],
    "merge_instructions": "Standard process"
  }'
  
  run_content_test "Special characters in content" "$test_data" "quotes.*special chars"
  run_content_test "Special characters - multiline" "$test_data" "Multi"
}

# Test 6: Empty strings
test_empty_strings() {
  local test_data='{
    "title": "",
    "overview": "",
    "whats_new": [""],
    "changes": {
      "features": [""],
      "bug_fixes": [],
      "improvements": [],
      "internal": [],
      "documentation": []
    },
    "testing_notes": "",
    "documentation_notes": "",
    "breaking_changes": [],
    "merge_instructions": ""
  }'
  
  run_content_test "Empty strings handling" "$test_data" "Release v"
}

# Test 7: Large content
test_large_content() {
  local test_data='{
    "title": "Large release with many changes",
    "overview": "This is a comprehensive release with numerous improvements across all areas of the system. We have been working hard to deliver significant value to our users.",
    "whats_new": [
      "Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5",
      "Feature 6", "Feature 7", "Feature 8", "Feature 9", "Feature 10"
    ],
    "changes": {
      "features": [
        "New API endpoint 1", "New API endpoint 2", "New API endpoint 3",
        "Enhanced user interface", "Improved data processing"
      ],
      "bug_fixes": [
        "Fixed bug 1", "Fixed bug 2", "Fixed bug 3", "Fixed bug 4", "Fixed bug 5"
      ],
      "improvements": [
        "Performance improvement 1", "Performance improvement 2", "Better caching"
      ],
      "internal": [
        "Refactored module A", "Refactored module B", "Updated dependencies"
      ],
      "documentation": [
        "Updated README", "Added examples", "Improved API docs"
      ]
    },
    "testing_notes": "Comprehensive testing completed including unit tests, integration tests, and end-to-end testing.",
    "documentation_notes": "All documentation has been updated to reflect the new changes.",
    "breaking_changes": [],
    "merge_instructions": "This is a large release, please review carefully before merging."
  }'
  
  run_content_test "Large content handling" "$test_data" "Feature 10"
  run_content_test "Large content - all categories" "$test_data" "### 🏗️ Internal"
}

# Test 8: Missing optional fields
test_missing_fields() {
  local test_data='{
    "title": "Minimal valid PR",
    "overview": "Basic release",
    "whats_new": [],
    "changes": {
      "bug_fixes": ["One fix"]
    },
    "testing_notes": "Basic testing",
    "documentation_notes": "No docs",
    "breaking_changes": [],
    "merge_instructions": "Merge it"
  }'
  
  run_content_test "Missing optional fields" "$test_data" "Basic release"
}

# Test 9: Error handling - invalid JSON
test_invalid_json() {
  local test_data='{"invalid": json syntax}'
  
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

# Test 10: Error handling - missing template
test_missing_template() {
  local test_data='{"title":"test"}'
  
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

# Test 11: Variable substitution
test_variable_substitution() {
  local test_data='{
    "title": "Variable test",
    "overview": "Testing variables",
    "whats_new": [],
    "changes": {"bug_fixes": []},
    "testing_notes": "Test",
    "documentation_notes": "Test", 
    "breaking_changes": [],
    "merge_instructions": "Test"
  }'
  
  local vars_b64
  vars_b64=$(echo -e "VERSION=1.2.3\nDATE=2024-12-25" | base64)
  
  run_content_test "Variable substitution - VERSION" "$test_data" "Release v1.2.3" "$vars_b64"
  run_content_test "Variable substitution - DATE" "$test_data" "2024-12-25" "$vars_b64"
}

# Cleanup function
cleanup() {
  cd "$TEST_DIR"
  rm -f test_pr_data.json
}

# Main test execution
main() {
  echo "Using processor: $PROCESSOR_PATH"
  echo "Using template: $TEMPLATE_PATH"
  echo ""
  
  test_complete_pr
  test_minimal_pr
  test_features_only
  test_multiple_breaking_changes
  test_special_characters
  test_empty_strings
  test_large_content
  test_missing_fields
  test_invalid_json
  test_missing_template
  test_variable_substitution
  
  cleanup
  
  echo "🏁 PR description processor tests completed!"
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