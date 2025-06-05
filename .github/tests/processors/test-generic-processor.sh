#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Test script for generic processor
#
# This script tests the generic.sh processor with various content types,
# templates, and edge cases to ensure it works correctly as a fallback
# processor for unknown template types.
###############################################################################

echo "🧪 Testing generic processor..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSOR_PATH="$SCRIPT_DIR/../../actions/openai-chat/processors/generic.sh"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Test helper function
run_test() {
  local test_name="$1"
  local test_data="$2"
  local template_content="$3"
  local expected_pattern="$4"
  local vars="${5:-}"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  # Create temporary template file
  local temp_template
  temp_template=$(mktemp)
  echo "$template_content" > "$temp_template"
  
  if actual=$(echo "$test_data" | "$PROCESSOR_PATH" - "$temp_template" "$vars" 2>&1); then
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
  
  rm -f "$temp_template"
  echo ""
}

# Test for specific content patterns
run_content_test() {
  local test_name="$1"
  local test_data="$2"
  local template_content="$3"
  local expected_content="$4"
  local vars="${5:-}"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  # Create temporary template file
  local temp_template
  temp_template=$(mktemp)
  echo "$template_content" > "$temp_template"
  
  if actual=$(echo "$test_data" | "$PROCESSOR_PATH" - "$temp_template" "$vars" 2>&1); then
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
  
  rm -f "$temp_template"
  echo ""
}

# Test 1: Plain text content with simple template
test_plain_text() {
  local content="This is plain text content without any JSON structure."
  local template="Content: {{content}}"
  
  run_content_test "Plain text processing" "$content" "$template" "This is plain text content"
}

# Test 2: JSON content with field substitution
test_json_content() {
  local content='{
    "title": "Sample Title",
    "description": "This is a sample description",
    "author": "John Doe"
  }'
  local template="# {{title}}

Written by: {{author}}

{{description}}"
  
  run_content_test "JSON field substitution" "$content" "$template" "Sample Title"
  run_content_test "JSON author field" "$content" "$template" "John Doe"
  run_content_test "JSON description field" "$content" "$template" "sample description"
}

# Test 3: Variable substitution with template variables
test_variable_substitution() {
  local content="Simple content for variable testing"
  local template="Version: {{VERSION}}
Date: {{DATE}}
Content: {{content}}"
  
  local vars_b64
  vars_b64=$(echo -e "VERSION=1.0.0\nDATE=2024-06-01" | base64)
  
  run_content_test "Variable substitution - VERSION" "$content" "$template" "1.0.0" "$vars_b64"
  run_content_test "Variable substitution - DATE" "$content" "$template" "2024-06-01" "$vars_b64"
  run_content_test "Variable substitution - CONTENT" "$content" "$template" "Simple content" "$vars_b64"
}

# Test 4: Mixed JSON and variable substitution
test_mixed_substitution() {
  local content='{
    "feature": "Authentication System",
    "status": "completed"
  }'
  local template="# Release {{VERSION}}

## Feature: {{feature}}
Status: {{status}}
Released on: {{DATE}}"
  
  local vars_b64
  vars_b64=$(echo -e "VERSION=2.1.0\nDATE=2024-07-15" | base64)
  
  run_content_test "Mixed substitution - feature" "$content" "$template" "Authentication System" "$vars_b64"
  run_content_test "Mixed substitution - version" "$content" "$template" "2.1.0" "$vars_b64"
  run_content_test "Mixed substitution - status" "$content" "$template" "completed" "$vars_b64"
}

# Test 5: Special characters and escaping
test_special_characters() {
  local content='{
    "message": "Fixed issue with \"quoted strings\" and $variables",
    "regex": "Pattern: /^test.*$/",
    "symbols": "Special chars: @#$%^&*()"
  }'
  local template="Message: {{message}}
Regex: {{regex}}
Symbols: {{symbols}}"
  
  run_content_test "Special characters - quotes" "$content" "$template" "quoted strings"
  run_content_test "Special characters - regex" "$content" "$template" "/^test.*$/"
  run_content_test "Special characters - symbols" "$content" "$template" "Special chars"
}

# Test 6: Multi-line content
test_multiline_content() {
  local content="Line 1: First line of content
Line 2: Second line with more information
Line 3: Final line"
  local template="Multi-line Content:
{{content}}

End of content."
  
  run_content_test "Multi-line content" "$content" "$template" "Line 1: First line"
  run_content_test "Multi-line content - line 2" "$content" "$template" "Line 2: Second line"
  run_content_test "Multi-line content - line 3" "$content" "$template" "Line 3: Final line"
}

# Test 7: Large JSON object
test_large_json() {
  local content='{
    "project": "SetlistFM TypeScript SDK",
    "version": "3.0.0",
    "features": ["OAuth support", "Enhanced error handling", "Better TypeScript types"],
    "maintainer": "tkozzer",
    "repository": "https://github.com/tkozzer/setlistfm-ts",
    "license": "MIT"
  }'
  local template="# {{project}} v{{version}}

Maintained by: {{maintainer}}
Repository: {{repository}}
License: {{license}}"
  
  run_content_test "Large JSON - project" "$content" "$template" "SetlistFM TypeScript SDK"
  run_content_test "Large JSON - maintainer" "$content" "$template" "tkozzer"
  run_content_test "Large JSON - repository" "$content" "$template" "github.com/tkozzer"
}

# Test 8: Unicode and international characters
test_unicode_content() {
  local content='{
    "title": "Internationalization Support",
    "languages": "中文, العربية, Español, Français",
    "emoji": "🎉 🚀 ✨",
    "currency": "€ £ ¥ ₹"
  }'
  local template="# {{title}}

Supported languages: {{languages}}
Emojis: {{emoji}}
Currencies: {{currency}}"
  
  run_content_test "Unicode - Chinese" "$content" "$template" "中文"
  run_content_test "Unicode - Arabic" "$content" "$template" "العربية"
  run_content_test "Unicode - emojis" "$content" "$template" "🎉 🚀"
  run_content_test "Unicode - currencies" "$content" "$template" "€ £ ¥"
}

# Test 9: Empty content and fields
test_empty_content() {
  local content='{
    "title": "",
    "description": "Non-empty description",
    "empty_field": ""
  }'
  local template="Title: {{title}}
Description: {{description}}
Empty: {{empty_field}}"
  
  run_content_test "Empty fields - description" "$content" "$template" "Non-empty description"
}

# Test 10: Plain text variables (non-base64)
test_plain_variables() {
  local content="Testing plain text variables"
  local template="Version: {{VERSION}}
Environment: {{ENV}}
Content: {{content}}"
  
  local vars="VERSION=1.5.0"$'\n'"ENV=production"
  
  run_content_test "Plain variables - VERSION" "$content" "$template" "1.5.0" "$vars"
  run_content_test "Plain variables - ENV" "$content" "$template" "production" "$vars"
}

# Test 11: No template variables
test_no_variables() {
  local content='{
    "name": "Test Project",
    "type": "library"
  }'
  local template="Project: {{name}}
Type: {{type}}"
  
  run_content_test "No variables" "$content" "$template" "Test Project"
  run_content_test "No variables - type" "$content" "$template" "library"
}

# Test 12: Complex nested JSON (should only process top-level)
test_nested_json() {
  local content='{
    "name": "Parent Object",
    "nested": {
      "child": "Child Value",
      "grandchild": {
        "value": "Deep Value"
      }
    },
    "simple": "Simple Value"
  }'
  local template="Name: {{name}}
Simple: {{simple}}
Nested: {{nested}}"
  
  run_content_test "Nested JSON - name" "$content" "$template" "Parent Object"
  run_content_test "Nested JSON - simple" "$content" "$template" "Simple Value"
}

# Test 13: Error handling - invalid JSON
test_invalid_json() {
  local content='{"invalid": json syntax}'
  local template="Content: {{content}}"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: Invalid JSON error handling"
  
  local temp_template
  temp_template=$(mktemp)
  echo "$template" > "$temp_template"
  
  if output=$(echo "$content" | "$PROCESSOR_PATH" - "$temp_template" "" 2>&1); then
    # Should treat as plain text when JSON is invalid
    if echo "$output" | grep -q "invalid"; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Should treat invalid JSON as plain text"
      echo "Output: $output"
    fi
  else
    echo "❌ FAIL - Command should not fail on invalid JSON"
    echo "Output: $output"
  fi
  
  rm -f "$temp_template"
  echo ""
}

# Test 14: Error handling - missing template
test_missing_template() {
  local content="Test content"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: Missing template error handling"
  
  if output=$(echo "$content" | "$PROCESSOR_PATH" - "nonexistent.md" "" 2>&1); then
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

# Test 15: Very large content
test_large_content() {
  local content=""
  for i in {1..100}; do
    content="${content}Line $i: This is a long line of content with various details. "
  done
  
  local template="Large Content Processing:
{{content}}
End of large content."
  
  run_content_test "Large content - line 1" "$content" "$template" "Line 1:"
  run_content_test "Large content - line 100" "$content" "$template" "Line 100:"
}

# Main test execution
main() {
  echo "Using processor: $PROCESSOR_PATH"
  echo ""
  
  test_plain_text
  test_json_content
  test_variable_substitution
  test_mixed_substitution
  test_special_characters
  test_multiline_content
  test_large_json
  test_unicode_content
  test_empty_content
  test_plain_variables
  test_no_variables
  test_nested_json
  test_invalid_json
  test_missing_template
  test_large_content
  
  echo "🏁 Generic processor tests completed!"
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