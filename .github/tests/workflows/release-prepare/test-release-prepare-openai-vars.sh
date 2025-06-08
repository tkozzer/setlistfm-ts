#!/usr/bin/env bash
set -euo pipefail

# Test script for prepare-openai-vars.sh script
# This test validates the logic used in the release-prepare workflow for preparing OpenAI variables

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/release-prepare"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/release-prepare/openai-vars"

total_tests=0
passed_tests=0

# Helper function to decode base64 and validate template variables
validate_template_vars() {
  local base64_content="$1"
  local expected_version="$2"
  local expected_date="$3"
  
  # Basic validation: check if it's valid base64 and contains the key components
  local decoded_content
  if decoded_content=$(echo "$base64_content" | base64 -d 2>/dev/null); then
    # Check for the presence of expected VERSION, any valid DATE, and COMMITS
    if [[ "$decoded_content" == *"VERSION=$expected_version"* ]] && \
       [[ "$decoded_content" == *"DATE="* ]] && \
       [[ "$decoded_content" == *"COMMITS="* ]]; then
      return 0
    fi
  fi
  
  return 1
}

# Helper function to extract and test commits content
validate_commits_content() {
  local base64_content="$1"
  local original_commits="$2"
  
  # For now, just validate that COMMITS= exists
  # Even empty commits should have the COMMITS= line
  local decoded_content
  if decoded_content=$(echo "$base64_content" | base64 -d 2>/dev/null); then
    if [[ "$decoded_content" == *"COMMITS="* ]]; then
      return 0
    fi
  fi
  return 1
}

# Test helper function
run_test() {
  local name="$1"
  local version="$2"
  local commits_input="$3"
  local expected_success="$4"
  
  total_tests=$((total_tests + 1))
  
  # Set environment variables
  export VERSION="$version"
  export COMMITS_INPUT="$commits_input"
  
  # Run the script and capture output
  local output
  local exit_code=0
  if output=$("$SCRIPTS_DIR/prepare-openai-vars.sh" 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  
  if [[ "$expected_success" == "true" && $exit_code -eq 0 ]]; then
    # Extract template_vars from output
    local template_vars
    if template_vars=$(echo "$output" | grep "template_vars=" | tail -1 | cut -d'=' -f2); then
      # Validate the base64 content
      local current_date
      current_date=$(date +%Y-%m-%d)
      
      if validate_template_vars "$template_vars" "$version" "$current_date"; then
        if validate_commits_content "$template_vars" "$commits_input"; then
          echo "✅ $name"
          passed_tests=$((passed_tests + 1))
        else
          echo "❌ $name (commits content validation failed)"
          echo "Script output:"
          echo "$output"
        fi
      else
        echo "❌ $name (template vars validation failed)"
        echo "Script output:"
        echo "$output"
      fi
    else
      echo "❌ $name (no template_vars output found)"
      echo "Script output:"
      echo "$output"
    fi
  elif [[ "$expected_success" == "false" && $exit_code -ne 0 ]]; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "Expected success: $expected_success"
    echo "Exit code: $exit_code"
    echo "Script output:"
    echo "$output"
  fi
  
  # Cleanup environment variables
  unset VERSION COMMITS_INPUT
}

# Test with fixture files
test_with_fixture() {
  local name="$1"
  local fixture_file="$2"
  local version="$3"
  local expected_success="$4"
  
  total_tests=$((total_tests + 1))
  
  if [[ ! -f "$FIXTURES_DIR/$fixture_file" ]]; then
    echo "❌ $name (fixture file not found: $fixture_file)"
    return
  fi
  
  local commits_input
  commits_input=$(cat "$FIXTURES_DIR/$fixture_file")
  
  # Set environment variables
  export VERSION="$version"
  export COMMITS_INPUT="$commits_input"
  
  # Run the script and capture output
  local output
  local exit_code=0
  if output=$("$SCRIPTS_DIR/prepare-openai-vars.sh" 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  
  if [[ "$expected_success" == "true" && $exit_code -eq 0 ]]; then
    # Extract template_vars from output
    local template_vars
    if template_vars=$(echo "$output" | grep "template_vars=" | tail -1 | cut -d'=' -f2); then
      # Validate the base64 content
      local current_date
      current_date=$(date +%Y-%m-%d)
      
      if validate_template_vars "$template_vars" "$version" "$current_date"; then
        if validate_commits_content "$template_vars" "$commits_input"; then
          echo "✅ $name"
          passed_tests=$((passed_tests + 1))
        else
          echo "❌ $name (commits content validation failed)"
          echo "Fixture file: $fixture_file"
          echo "Script output:"
          echo "$output"
        fi
      else
        echo "❌ $name (template vars validation failed)"
        echo "Fixture file: $fixture_file"
        echo "Script output:"
        echo "$output"
      fi
    else
      echo "❌ $name (no template_vars output found)"
      echo "Script output:"
      echo "$output"
    fi
  elif [[ "$expected_success" == "false" && $exit_code -ne 0 ]]; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "Expected success: $expected_success"
    echo "Exit code: $exit_code"
    echo "Fixture file: $fixture_file"
    echo "Script output:"
    echo "$output"
  fi
  
  # Cleanup environment variables
  unset VERSION COMMITS_INPUT
}

# Test base64 round-trip functionality
test_base64_roundtrip() {
  local name="$1"
  local test_content="$2"
  local version="$3"
  
  total_tests=$((total_tests + 1))
  
  # Set environment variables
  export VERSION="$version"
  export COMMITS_INPUT="$test_content"
  
  # Run the script
  local output
  if output=$("$SCRIPTS_DIR/prepare-openai-vars.sh" 2>&1); then
    # Extract template_vars
    local template_vars
    if template_vars=$(echo "$output" | grep "template_vars=" | tail -1 | cut -d'=' -f2); then
      # Test if we can decode it back successfully
      local decoded_content
      if decoded_content=$(echo "$template_vars" | base64 -d 2>/dev/null); then
        # Check if the decoded content contains our escaped commits
        if echo "$decoded_content" | grep -q "COMMITS="; then
          echo "✅ $name"
          passed_tests=$((passed_tests + 1))
        else
          echo "❌ $name (decoded content missing COMMITS)"
          echo "Decoded content:"
          echo "$decoded_content"
        fi
      else
        echo "❌ $name (base64 decode failed)"
        echo "Template vars: $template_vars"
      fi
    else
      echo "❌ $name (no template_vars output found)"
      echo "Script output:"
      echo "$output"
    fi
  else
    echo "❌ $name (script failed)"
    echo "Script output:"
    echo "$output"
  fi
  
  # Cleanup environment variables
  unset VERSION COMMITS_INPUT
}

# Test error conditions
test_error_condition() {
  local name="$1"
  local version="$2"
  local commits_input="$3"
  
  total_tests=$((total_tests + 1))
  
  # Set environment variables (or not, for testing missing vars)
  if [[ -n "$version" ]]; then
    export VERSION="$version"
  fi
  if [[ -n "$commits_input" ]]; then
    export COMMITS_INPUT="$commits_input"
  fi
  
  # Run script and expect failure
  local output
  local exit_code=0
  if output=$("$SCRIPTS_DIR/prepare-openai-vars.sh" 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  
  if [[ $exit_code -ne 0 ]]; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name (expected failure but script succeeded)"
    echo "Script output:"
    echo "$output"
  fi
  
  # Cleanup environment variables
  unset VERSION COMMITS_INPUT 2>/dev/null || true
}

echo "🧪 Testing prepare-openai-vars.sh script"
echo "=========================================="

# Test basic functionality
echo ""
echo "📝 Basic functionality tests:"
run_test "Simple commits" "1.2.3" "a1b2c3d feat: add feature\nb2c3d4e fix: bug fix" "true"
run_test "Single line commit" "2.0.0" "a1b2c3d fix: simple fix" "true"
run_test "Version with patch" "1.0.1" "a1b2c3d docs: update readme" "true"

# Test with fixture files
echo ""
echo "📂 Fixture file tests:"
test_with_fixture "Simple commits fixture" "openai-vars-simple-commits.txt" "1.2.3" "true"
test_with_fixture "Multiline commits fixture" "openai-vars-multiline-commits.txt" "2.0.0" "true"
test_with_fixture "Special characters fixture" "openai-vars-special-chars.txt" "1.1.0" "true"
test_with_fixture "Large content fixture" "openai-vars-large-content.txt" "3.0.0" "true"
test_with_fixture "Existing escapes fixture" "openai-vars-existing-escapes.txt" "1.0.5" "true"
test_with_fixture "Empty commits fixture" "openai-vars-empty.txt" "1.0.0" "true"

# Test special character handling
echo ""
echo "🔤 Special character tests:"
run_test "Quotes and escapes" "1.2.3" 'a1b2c3d feat: add "quoted" feature\nWith escaped content: \\"test\\"' "true"
run_test "Mixed newlines" "1.2.3" $'a1b2c3d feat: feature\n\nMultiple lines\nWith content' "true"
run_test "Unicode content" "1.2.3" "a1b2c3d feat: add émojis 🎉 and spëcial chars" "true"

# Test base64 round-trip functionality
echo ""
echo "🔄 Base64 round-trip tests:"
test_base64_roundtrip "Simple round-trip" "a1b2c3d feat: test" "1.0.0"
test_base64_roundtrip "Complex round-trip" $'a1b2c3d feat: complex\n\nWith "quotes" and \\escapes' "2.0.0"

# Test edge cases
echo ""
echo "🔍 Edge case tests:"
run_test "Very long version" "10.20.30-beta.1+build.123" "a1b2c3d feat: test" "true"
run_test "Version with pre-release" "1.0.0-alpha.1" "a1b2c3d feat: test" "true"
run_test "Large commits input" "$(printf 'a%.0s' {1..1000})" "Large commit message content" "true"

# Test error conditions
echo ""
echo "⚠️  Error condition tests:"
test_error_condition "Missing VERSION" "" "some commits"
test_error_condition "Missing COMMITS_INPUT" "1.0.0" ""
test_error_condition "Both missing" "" ""

# Summary
echo ""
echo "=========================================="
echo "📊 Test Results Summary:"
echo "Total tests: $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $((total_tests - passed_tests))"

if [[ $passed_tests -eq $total_tests ]]; then
  echo "🎉 All tests passed!"
  exit 0
else
  echo "❌ Some tests failed!"
  exit 1
fi 