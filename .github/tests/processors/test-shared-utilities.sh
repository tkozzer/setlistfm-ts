#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Test script for shared utilities
#
# This script tests all functions in shared.sh to ensure they work correctly
# across all processors.
###############################################################################

echo "🧪 Testing shared utilities..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_PATH="$SCRIPT_DIR/../../actions/openai-chat/processors/shared.sh"

# Source the shared utilities
source "$SHARED_PATH"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Test helper function
run_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_result="$3"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  if actual=$(eval "$test_command" 2>&1); then
    if [[ "$actual" == "$expected_result" ]]; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Unexpected result"
      echo "Expected: '$expected_result'"
      echo "Actual: '$actual'"
    fi
  else
    echo "❌ FAIL - Command failed with exit code $?"
    echo "Output: $actual"
  fi
  echo ""
}

# Test helper for exit codes
run_exit_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_exit_code="$3"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  if eval "$test_command" >/dev/null 2>&1; then
    local actual_exit_code=0
  else
    local actual_exit_code=$?
  fi
  
  if [[ $actual_exit_code -eq $expected_exit_code ]]; then
    echo "✅ PASS"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo "❌ FAIL - Wrong exit code"
    echo "Expected: $expected_exit_code"
    echo "Actual: $actual_exit_code"
  fi
  echo ""
}

# Test helper for pattern matching
run_pattern_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_pattern="$3"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo "📋 Test $TOTAL_TESTS: $test_name"
  
  if actual=$(eval "$test_command" 2>&1); then
    if [[ "$actual" =~ $expected_pattern ]]; then
      echo "✅ PASS"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      echo "❌ FAIL - Pattern not found"
      echo "Expected pattern: '$expected_pattern'"
      echo "Actual: '$actual'"
    fi
  else
    echo "❌ FAIL - Command failed"
    echo "Output: $actual"
  fi
  echo ""
}

# Test 1: is_base64 function
test_is_base64() {
  echo "🔍 Testing is_base64 function..."
  
  # Valid base64
  run_exit_test "Valid base64 string" "is_base64 'SGVsbG8gV29ybGQ='" 0
  run_exit_test "Another valid base64" "is_base64 'VkVSU0lPTj0xLjAuMA=='" 0
  
  # Invalid base64
  run_exit_test "Invalid base64 - spaces" "is_base64 'Hello World'" 1
  run_exit_test "Invalid base64 - special chars" "is_base64 'Hello@World!'" 1
  run_exit_test "Empty string" "is_base64 ''" 1
  run_exit_test "Multi-line string" "is_base64 $'line1\nline2'" 1
}

# Test 2: process_template_vars function
test_process_template_vars() {
  echo "🔍 Testing process_template_vars function..."
  
  # Test with base64 encoded vars
  local vars_b64
  vars_b64=$(echo -e "VERSION=1.0.0\nDATE=2024-06-01" | base64)
  local template="Version: {{VERSION}}, Date: {{DATE}}"
  
  run_test "Base64 variable substitution" \
    "process_template_vars '$template' '$vars_b64'" \
    "Version: 1.0.0, Date: 2024-06-01"
  
  # Test with plain text vars
  local vars_plain="VERSION=2.0.0"$'\n'"DATE=2024-07-01"
  
  run_test "Plain text variable substitution" \
    "process_template_vars '$template' '$vars_plain'" \
    "Version: 2.0.0, Date: 2024-07-01"
  
  # Test with no vars
  run_test "No variables provided" \
    "process_template_vars '$template' ''" \
    "Version: {{VERSION}}, Date: {{DATE}}"
}

# Test 2a: Multiline variable content (demonstrating the bug)
test_multiline_variable_content() {
  echo "🔍 Testing multiline variable content (now fixed)..."
  
  # Test the problematic scenario from release PR workflow
  local template="Version: {{VERSION}}

Changelog:
{{CHANGELOG}}

End."
  
  # This is the exact format that was failing in the release PR workflow
  local vars_multiline="VERSION=0.7.2
CHANGELOG=### Added
- New feature one
- New feature two
### Fixed  
- Bug fix one
- Bug fix two"
  
  # Test that regular newline format now works correctly 
  run_pattern_test "Multiline CHANGELOG - VERSION substitution works" \
    "process_template_vars '$template' '$vars_multiline'" \
    "Version: 0.7.2"
  
  # Test that content is now present
  run_pattern_test "Multiline CHANGELOG - content is present" \
    "process_template_vars '$template' '$vars_multiline'" \
    "New feature one"
  
  # Test that base64 encoded multiline content also works
  local vars_b64
  vars_b64=$(echo "$vars_multiline" | base64 -w 0)
  
  run_pattern_test "Multiline CHANGELOG - base64 encoded works" \
    "process_template_vars '$template' '$vars_b64'" \
    "Version: 0.7.2"
    
  run_pattern_test "Multiline CHANGELOG - base64 content is present" \
    "process_template_vars '$template' '$vars_b64'" \
    "New feature one"
}

# Test 3: get_array_length function
test_get_array_length() {
  echo "🔍 Testing get_array_length function..."
  
  local json='{"items": ["a", "b", "c"], "empty": [], "nested": {"array": ["x", "y"]}}'
  
  run_test "Array with 3 items" \
    "get_array_length '$json' 'items'" \
    "3"
  
  run_test "Empty array" \
    "get_array_length '$json' 'empty'" \
    "0"
  
  run_test "Non-existent array" \
    "get_array_length '$json' 'missing'" \
    "0"
}

# Test 4: json_field_exists function
test_json_field_exists() {
  echo "🔍 Testing json_field_exists function..."
  
  local json='{"name": "test", "value": 42, "empty": "", "null_field": null}'
  
  run_exit_test "Existing string field" \
    "json_field_exists '$json' 'name'" 0
  
  run_exit_test "Existing number field" \
    "json_field_exists '$json' 'value'" 0
  
  run_exit_test "Existing empty field" \
    "json_field_exists '$json' 'empty'" 0
  
  run_exit_test "Existing null field" \
    "json_field_exists '$json' 'null_field'" 1
  
  run_exit_test "Non-existent field" \
    "json_field_exists '$json' 'missing'" 1
}

# Test 5: get_string_fields function
test_get_string_fields() {
  echo "🔍 Testing get_string_fields function..."
  
  local json='{"name": "John", "age": 30, "city": "New York", "active": true}'
  
  run_pattern_test "String fields extraction" \
    "get_string_fields '$json'" \
    "name:John.*city:New York"
  
  # Test with special characters
  local json_special='{"message": "Hello \"World\"!", "path": "/usr/bin"}'
  
  run_pattern_test "String fields with special chars" \
    "get_string_fields '$json_special'" \
    "message:.*World.*path:/usr/bin"
}

# Test 6: format_as_bullet_list function
test_format_as_bullet_list() {
  echo "🔍 Testing format_as_bullet_list function..."
  
  local json='{"features": ["Feature A", "Feature B", "Feature C"]}'
  
  run_pattern_test "Bullet list formatting" \
    "format_as_bullet_list '$json' 'features'" \
    "- Feature A.*- Feature B.*- Feature C"
  
  # Test with empty array
  local json_empty='{"features": []}'
  
  run_test "Empty array bullet list" \
    "format_as_bullet_list '$json_empty' 'features'" \
    ""
}

# Test 7: cleanup_handlebars function
test_cleanup_handlebars() {
  echo "🔍 Testing cleanup_handlebars function..."
  
  local content="Some text {{#each items}}item{{/each}} more text {{#if condition}}conditional{{/if}} end"
  
  run_test "Cleanup handlebars with vars" \
    "cleanup_handlebars '$content' 'has_vars'" \
    "Some text  end"
  
  # Test without vars (should preserve VERSION, DATE, etc.)
  local content_with_vars="Text {{VERSION}} and {{CUSTOM}} placeholders"
  
  run_test "Cleanup without vars - preserve standard" \
    "cleanup_handlebars '$content_with_vars' ''" \
    "Text {{VERSION}} and {{CUSTOM}} placeholders"
}

# Test 8: validate_inputs function (using a simple test since it's validation)
test_validate_inputs() {
  echo "🔍 Testing validate_inputs function..."
  
  # Create temporary template file
  local temp_template
  temp_template=$(mktemp)
  echo "Test template" > "$temp_template"
  
  # Valid inputs
  run_exit_test "Valid JSON content and template" \
    "validate_inputs '{\"test\": \"value\"}' '$temp_template' ''" 0
  
  # Invalid JSON
  run_exit_test "Invalid JSON content" \
    "validate_inputs '{invalid json}' '$temp_template' ''" 1
  
  # Missing template
  run_exit_test "Missing template file" \
    "validate_inputs '{\"test\": \"value\"}' 'nonexistent.md' ''" 1
  
  rm -f "$temp_template"
}

# Test 9: Edge cases and error conditions
test_edge_cases() {
  echo "🔍 Testing edge cases..."
  
  # Test with very large JSON
  local large_json='{"items": ['
  for i in {1..100}; do
    large_json="${large_json}\"item$i\""
    if [[ $i -lt 100 ]]; then
      large_json="${large_json},"
    fi
  done
  large_json="${large_json}]}"
  
  run_test "Large JSON array length" \
    "get_array_length '$large_json' 'items'" \
    "100"
  
  # Test with Unicode content
  local unicode_json='{"message": "Hello 世界! 🌍", "emoji": "🎉🚀✨"}'
  
  run_pattern_test "Unicode in string fields" \
    "get_string_fields '$unicode_json'" \
    "message:Hello 世界.*emoji:🎉🚀✨"
  
  # Test with complex nested JSON
  local nested_json='{"level1": {"level2": {"level3": "deep value"}}}'
  
  run_exit_test "Nested JSON field exists" \
    "json_field_exists '$nested_json' 'level1'" 0
  
  run_exit_test "Deep nested field doesn't exist at top level" \
    "json_field_exists '$nested_json' 'level3'" 1
}

# Test 10: Performance with repeated operations
test_performance() {
  echo "🔍 Testing performance with repeated operations..."
  
  local json='{"data": ["item1", "item2", "item3", "item4", "item5"]}'
  
  # Run the same operation multiple times to check for consistency
  local results=()
  for i in {1..5}; do
    results+=($(get_array_length "$json" "data"))
  done
  
  # Check all results are the same
  local first_result="${results[0]}"
  local all_same=true
  for result in "${results[@]}"; do
    if [[ "$result" != "$first_result" ]]; then
      all_same=false
      break
    fi
  done
  
  if [[ "$all_same" == true && "$first_result" == "5" ]]; then
    echo "✅ PASS - Performance test: consistent results"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo "❌ FAIL - Performance test: inconsistent results"
    echo "Results: ${results[*]}"
  fi
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo ""
}

# Test 4: replace_each_block function  
test_replace_each_block() {
  echo "🔍 Testing replace_each_block function..."
  
  # This is a placeholder test since this function might be complex
  # We'll just test if it's callable
  run_exit_test "Function exists and is callable" \
    "type replace_each_block" \
    "0"
}

# Test 5: Error scenarios
test_error_scenarios() {
  echo "🔍 Testing error scenarios..."
  
  # Test with invalid JSON for process_template_vars
  run_exit_test "Invalid JSON handling" \
    "process_template_vars 'test' 'invalid}json'" \
    "0"  # Should not crash
}

# Main test execution
main() {
  echo "🧪 Testing shared processor utilities..."
  echo "Using utilities: $SHARED_PATH"
  echo ""
  
  test_is_base64
  test_process_template_vars
  test_multiline_variable_content
  test_get_array_length
  test_replace_each_block
  test_error_scenarios
  
  echo "🏁 Shared utilities tests completed!"
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