#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Test script for pr-enhance processor
#
# This script tests the pr-enhance.sh processor with various content types,
# templates, and edge cases to ensure it works correctly with PR enhancement
# scenarios.
###############################################################################

echo "🧪 Testing pr-enhance processor..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSOR_PATH="$SCRIPT_DIR/../../actions/openai-chat/processors/pr-enhance.sh"
TEMPLATE_PATH="$SCRIPT_DIR/../../templates/pr-enhancement.tmpl.md"

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

# Test 1: Complete PR enhancement with all fields
test_complete_pr_enhancement() {
  local test_data='{
    "summary": "This PR introduces a new authentication system with OAuth 2.0 support and enhanced security features.",
    "changes": [
      "Added OAuth 2.0 authentication endpoints",
      "Implemented JWT token validation middleware",
      "Enhanced user session management",
      "Added comprehensive input validation",
      "Improved error handling and logging"
    ],
    "testing": "Added unit tests for all new authentication flows. Integration tests cover OAuth flow end-to-end. Manual testing performed on staging environment.",
    "documentation": "Updated API documentation with new authentication endpoints. Added OAuth setup guide for developers. Updated deployment instructions.",
    "commit_analysis": {
      "total_commits": 15,
      "conventional_commits": 12,
      "suggestions": "Consider using more descriptive commit messages for better traceability"
    }
  }'
  
  run_content_test "Complete PR enhancement" "$test_data" "OAuth 2.0 support"
  run_content_test "Complete PR - changes list" "$test_data" "JWT token validation"
  run_content_test "Complete PR - testing info" "$test_data" "unit tests"
  run_content_test "Complete PR - documentation" "$test_data" "API documentation"
  run_content_test "Complete PR - commit analysis" "$test_data" "Total commits analyzed: 15"
}

# Test 2: Minimal PR enhancement
test_minimal_pr_enhancement() {
  local test_data='{
    "summary": "Bug fix for user login issue",
    "changes": ["Fixed null pointer exception in login validation"],
    "testing": "Tested locally",
    "documentation": "No documentation changes needed",
    "commit_analysis": {
      "total_commits": 1,
      "conventional_commits": 1,
      "suggestions": ""
    }
  }'
  
  run_content_test "Minimal PR enhancement" "$test_data" "Bug fix"
  run_content_test "Minimal PR - single change" "$test_data" "null pointer exception"
}

# Test 3: PR with extensive changes
test_extensive_changes() {
  local test_data='{
    "summary": "Major refactoring of the data processing pipeline",
    "changes": [
      "Refactored data ingestion module for better performance",
      "Implemented new caching layer with Redis",
      "Added data validation pipeline",
      "Optimized database queries for 50% faster response times",
      "Introduced async processing for large datasets",
      "Added comprehensive error handling",
      "Implemented data transformation utilities",
      "Added monitoring and alerting for pipeline health",
      "Updated configuration management",
      "Enhanced logging for better debugging"
    ],
    "testing": "Comprehensive testing suite including unit tests (95% coverage), integration tests for all pipeline stages, performance tests showing 50% improvement, and load testing with production-scale data.",
    "documentation": "Complete rewrite of pipeline documentation, added architecture diagrams, created troubleshooting guide, updated API documentation, and added performance benchmarking results.",
    "commit_analysis": {
      "total_commits": 45,
      "conventional_commits": 38,
      "suggestions": "Epic spanning 6 weeks with key milestones: refactoring, caching, optimization, and documentation"
    }
  }'
  
  run_content_test "Extensive changes - performance" "$test_data" "50% faster response"
  run_content_test "Extensive changes - Redis" "$test_data" "Redis"
  run_content_test "Extensive changes - 45 commits" "$test_data" "Total commits analyzed: 45"
  run_content_test "Extensive changes - coverage" "$test_data" "95% coverage"
}

# Test 4: PR with special characters and formatting
test_special_characters() {
  local test_data='{
    "summary": "Added support for \"special characters\" & formatting: $variables, {objects}, [arrays], and more!",
    "changes": [
      "Support for markdown `code` blocks in comments",
      "Handle URLs like https://example.com/path?param=value",
      "Process symbols: @mentions, #hashtags, and *emphasis*",
      "Fixed regex patterns like /^test.*$/ in validation"
    ],
    "testing": "Tested with various \"quoted strings\", $variables, and edge cases",
    "documentation": "Updated docs with examples of special character handling",
    "commit_analysis": {
      "total_commits": 8,
      "conventional_commits": 6,
      "suggestions": "Multiple commits addressing different character encodings"
    }
  }'
  
  run_content_test "Special characters - quotes" "$test_data" "special characters"
  run_content_test "Special characters - markdown" "$test_data" "markdown.*code.*blocks"
  run_content_test "Special characters - URLs" "$test_data" "https://example.com"
  run_content_test "Special characters - symbols" "$test_data" "@mentions"
}

# Test 5: Empty and minimal fields
test_empty_fields() {
  local test_data='{
    "summary": "",
    "changes": [],
    "testing": "",
    "documentation": "",
    "commit_analysis": {
      "total_commits": 0,
      "conventional_commits": 0,
      "suggestions": ""
    }
  }'
  
  run_content_test "Empty fields handling" "$test_data" "Summary"
}

# Test 6: Single change item
test_single_change() {
  local test_data='{
    "summary": "Quick hotfix for critical production issue",
    "changes": ["Fixed memory leak in session cleanup"],
    "testing": "Verified fix in staging environment",
    "documentation": "Updated incident report",
    "commit_analysis": {
      "total_commits": 1,
      "conventional_commits": 1,
      "suggestions": "Emergency hotfix commit"
    }
  }'
  
  run_content_test "Single change" "$test_data" "memory leak"
  run_content_test "Single change - hotfix" "$test_data" "hotfix"
}

# Test 7: Long descriptions and content
test_long_content() {
  local test_data='{
    "summary": "This is an extremely comprehensive pull request that addresses multiple complex issues across various components of the system, implementing new features while maintaining backward compatibility and ensuring optimal performance characteristics throughout the entire application lifecycle.",
    "changes": [
      "Implemented a sophisticated caching mechanism that intelligently manages memory usage while providing sub-millisecond response times for frequently accessed data",
      "Developed a comprehensive error handling system that provides detailed debugging information while maintaining security best practices",
      "Created an advanced monitoring system that tracks performance metrics, user behavior patterns, and system health indicators in real-time"
    ],
    "testing": "Conducted extensive testing including unit tests with 99% code coverage, integration tests covering all major user workflows, performance tests under various load conditions, security penetration testing, accessibility testing for WCAG compliance, and comprehensive end-to-end testing across multiple browsers and device types.",
    "documentation": "Comprehensive documentation overhaul including detailed API reference documentation, step-by-step user guides, architectural decision records, deployment and configuration guides, troubleshooting documentation, and performance optimization recommendations.",
    "commit_analysis": {
      "total_commits": 127,
      "conventional_commits": 98,
      "suggestions": "Large-scale development effort spanning 12 weeks from 8 contributors"
    }
  }'
  
  run_content_test "Long content - comprehensive" "$test_data" "comprehensive"
  run_content_test "Long content - 127 commits" "$test_data" "Total commits analyzed: 127"
  run_content_test "Long content - 99% coverage" "$test_data" "99% code coverage"
}

# Test 8: Unicode and international characters
test_unicode_content() {
  local test_data='{
    "summary": "Added internationalization support for múltiple languages including 中文, العربية, and Русский",
    "changes": [
      "Support for emoji reactions 🎉 👍 ❤️ in comments",
      "Currency formatting for € £ ¥ ₹ symbols",
      "Right-to-left text support for Arabic العربية"
    ],
    "testing": "Tested with múltiple character sets and encoding formats",
    "documentation": "Updated documentation with international examples",
    "commit_analysis": {
      "total_commits": 12,
      "conventional_commits": 10,
      "suggestions": "Internationalization commits across different modules"
    }
  }'
  
  run_content_test "Unicode - multiple languages" "$test_data" "múltiple languages"
  run_content_test "Unicode - Chinese" "$test_data" "中文"
  run_content_test "Unicode - emojis" "$test_data" "🎉"
  run_content_test "Unicode - Arabic" "$test_data" "العربية"
}

# Test 9: Technical and code-focused content
test_technical_content() {
  local test_data='{
    "summary": "Refactored core algorithms and optimized database queries",
    "changes": [
      "Replaced O(n²) algorithm with O(n log n) implementation",
      "Added database indexes for frequently queried columns",
      "Implemented connection pooling with HikariCP",
      "Added Redis caching for session data",
      "Optimized SQL queries using CTEs and window functions"
    ],
    "testing": "Performance benchmarks show 300% improvement in query response times",
    "documentation": "Added technical architecture diagrams and performance analysis",
    "commit_analysis": {
      "total_commits": 25,
      "conventional_commits": 22,
      "suggestions": "Systematic optimization with detailed performance measurements"
    }
  }'
  
  run_content_test "Technical content - O notation" "$test_data" "O(n log n)"
  run_content_test "Technical content - HikariCP" "$test_data" "HikariCP"
  run_content_test "Technical content - 300%" "$test_data" "300% improvement"
}

# Test 10: Variable substitution
test_variable_substitution() {
  local test_data='{
    "summary": "Test variable substitution",
    "changes": ["Updated version handling"],
    "testing": "Basic testing",
    "documentation": "Documentation updated",
    "commit_analysis": {
      "total_commits": 1,
      "conventional_commits": 1,
      "suggestions": "Version bump commit"
    }
  }'
  
  local vars_b64
  vars_b64=$(echo -e "VERSION=1.5.0\nDATE=2024-07-15\nCOMMITS=5" | base64)
  
  run_content_test "Variable substitution - summary" "$test_data" "Test variable substitution"
  run_content_test "Variable substitution - testing" "$test_data" "Basic testing"
  run_content_test "Variable substitution - documentation" "$test_data" "Documentation updated"
}

# Test 11: Error handling - invalid JSON
test_invalid_json() {
  local test_data='{"summary": invalid json syntax}'
  
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

# Test 12: Error handling - missing template
test_missing_template() {
  local test_data='{"summary":"test"}'
  
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

# Test 13: Missing required fields
test_missing_fields() {
  local test_data='{
    "summary": "Test with missing fields"
  }'
  
  run_content_test "Missing fields handling" "$test_data" "Test with missing fields"
}

# Test 14: Nested theme structure for changes
test_nested_changes() {
  local test_data='{
    "summary": "Testing nested theme structure for changes",
    "changes": [
      {
        "theme": "CI Improvements",
        "changes": [
          "Refactored OpenAI chat action with modular processors",
          "Added test mode support with mock fixtures",
          "Enhanced error handling and logging"
        ]
      },
      {
        "theme": "Documentation",
        "changes": [
          "Updated template file naming convention",
          "Added comprehensive test suite documentation"
        ]
      }
    ],
    "testing": "Added tests for both flat and nested change structures",
    "documentation": "Updated schema to support both formats",
    "commit_analysis": {
      "total_commits": 10,
      "conventional_commits": 8,
      "suggestions": "Good commit hygiene with clear themes"
    }
  }'
  
  run_content_test "Nested changes - CI theme" "$test_data" "CI Improvements"
  run_content_test "Nested changes - Documentation theme" "$test_data" "Documentation"
  run_content_test "Nested changes - modular processors" "$test_data" "modular processors"
  run_content_test "Nested changes - schema format" "$test_data" "support both formats"
}

# Test 15: Plain text variable substitution
test_plain_variables() {
  local test_data='{
    "summary": "Plain text variables test",
    "changes": ["Simple change"],
    "testing": "Basic test",
    "documentation": "Updated",
    "commit_analysis": {
      "total_commits": 1,
      "conventional_commits": 1,
      "suggestions": "Simple commit"
    }
  }'
  
  local vars="VERSION=2.0.0"$'\n'"DATE=2024-11-01"
  
  run_content_test "Plain variables - summary" "$test_data" "Plain text variables test"
  run_content_test "Plain variables - testing" "$test_data" "Basic test"
}

# Main test execution
main() {
  echo "Using processor: $PROCESSOR_PATH"
  echo "Using template: $TEMPLATE_PATH"
  echo ""
  
  test_complete_pr_enhancement
  test_minimal_pr_enhancement
  test_extensive_changes
  test_special_characters
  test_empty_fields
  test_single_change
  test_long_content
  test_unicode_content
  test_technical_content
  test_variable_substitution
  test_invalid_json
  test_missing_template
  test_missing_fields
  test_nested_changes
  test_plain_variables
  
  echo "🏁 PR enhance processor tests completed!"
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