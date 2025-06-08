#!/usr/bin/env bash
set -euo pipefail

# Test script for determine-semver-bump.sh script
# This test validates the logic used in the release-prepare workflow for determining semver bump type

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/release-prepare"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/release-prepare/semver-bump"

total_tests=0
passed_tests=0

# Test helper function
run_test() {
  local name="$1"
  local input_commits="$2"
  local expected_type="$3"
  
  total_tests=$((total_tests + 1))
  
  # Run the script and capture output
  local output
  if output=$("$SCRIPTS_DIR/determine-semver-bump.sh" "$input_commits" 2>&1); then
    # Extract the bump type from output
    local actual_type
    if echo "$output" | grep -q "type="; then
      actual_type=$(echo "$output" | grep "type=" | tail -1 | cut -d'=' -f2)
      
      if [[ "$actual_type" == "$expected_type" ]]; then
        echo "✅ $name"
        passed_tests=$((passed_tests + 1))
      else
        echo "❌ $name"
        echo "Expected: $expected_type"
        echo "Actual: $actual_type"
        echo "Script output:"
        echo "$output"
      fi
    else
      echo "❌ $name (no type output found)"
      echo "Script output:"
      echo "$output"
    fi
  else
    echo "❌ $name (script failed)"
    echo "Script output:"
    echo "$output"
  fi
}

# Test with fixture files
test_with_fixture() {
  local name="$1"
  local fixture_file="$2"
  local expected_type="$3"
  
  total_tests=$((total_tests + 1))
  
  if [[ ! -f "$FIXTURES_DIR/$fixture_file" ]]; then
    echo "❌ $name (fixture file not found: $fixture_file)"
    return
  fi
  
  local input_commits
  input_commits=$(cat "$FIXTURES_DIR/$fixture_file")
  
  # Run the script and capture output
  local output
  if output=$("$SCRIPTS_DIR/determine-semver-bump.sh" "$input_commits" 2>&1); then
    # Extract the bump type from output
    local actual_type
    if echo "$output" | grep -q "type="; then
      actual_type=$(echo "$output" | grep "type=" | tail -1 | cut -d'=' -f2)
      
      if [[ "$actual_type" == "$expected_type" ]]; then
        echo "✅ $name"
        passed_tests=$((passed_tests + 1))
      else
        echo "❌ $name"
        echo "Expected: $expected_type"
        echo "Actual: $actual_type"
        echo "Fixture file: $fixture_file"
        echo "Script output:"
        echo "$output"
      fi
    else
      echo "❌ $name (no type output found)"
      echo "Script output:"
      echo "$output"
    fi
  else
    echo "❌ $name (script failed)"
    echo "Script output:"
    echo "$output"
  fi
}

# Test environment variable input
test_with_env_var() {
  local name="$1"
  local input_commits="$2"
  local expected_type="$3"
  
  total_tests=$((total_tests + 1))
  
  # Set RAW environment variable and call script without arguments
  local output
  if output=$(RAW="$input_commits" "$SCRIPTS_DIR/determine-semver-bump.sh" 2>&1); then
    # Extract the bump type from output
    local actual_type
    if echo "$output" | grep -q "type="; then
      actual_type=$(echo "$output" | grep "type=" | tail -1 | cut -d'=' -f2)
      
      if [[ "$actual_type" == "$expected_type" ]]; then
        echo "✅ $name"
        passed_tests=$((passed_tests + 1))
      else
        echo "❌ $name"
        echo "Expected: $expected_type"
        echo "Actual: $actual_type"
        echo "Script output:"
        echo "$output"
      fi
    else
      echo "❌ $name (no type output found)"
      echo "Script output:"
      echo "$output"
    fi
  else
    echo "❌ $name (script failed)"
    echo "Script output:"
    echo "$output"
  fi
}

# Test error conditions
test_error_condition() {
  local name="$1"
  local should_fail="$2"
  
  total_tests=$((total_tests + 1))
  
  # Run script without any input (should fail)
  local output
  local exit_code=0
  if output=$("$SCRIPTS_DIR/determine-semver-bump.sh" 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  
  if [[ "$should_fail" == "true" && $exit_code -ne 0 ]]; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  elif [[ "$should_fail" == "false" && $exit_code -eq 0 ]]; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "Expected failure: $should_fail"
    echo "Exit code: $exit_code"
    echo "Script output:"
    echo "$output"
  fi
}

# Test stdout/stderr separation (critical for GitHub Actions workflow)
test_stdout_stderr_separation() {
  local name="$1"
  local input_commits="$2"
  local expected_type="$3"
  
  total_tests=$((total_tests + 1))
  
  # Capture stdout only (like GitHub Actions does with command substitution)
  local stdout_only
  if stdout_only=$(RAW="$input_commits" "$SCRIPTS_DIR/determine-semver-bump.sh" 2>/dev/null); then
    # Check that stdout contains only the type=X line (no debug messages)
    if [[ "$stdout_only" == "type=$expected_type" ]]; then
      echo "✅ $name (stdout separation)"
      passed_tests=$((passed_tests + 1))
    else
      echo "❌ $name (stdout separation)"
      echo "Expected stdout: 'type=$expected_type'"
      echo "Actual stdout: '$stdout_only'"
    fi
  else
    echo "❌ $name (script failed)"
  fi
  
  # Additional test: verify stderr contains debug messages but stdout doesn't
  total_tests=$((total_tests + 1))
  local stderr_content
  local stdout_content
  {
    stdout_content=$(RAW="$input_commits" "$SCRIPTS_DIR/determine-semver-bump.sh" 2>/tmp/stderr_capture)
    stderr_content=$(cat /tmp/stderr_capture)
    rm -f /tmp/stderr_capture
  }
  
  # Check that stderr contains debug messages and stdout doesn't
  if echo "$stderr_content" | grep -q "=== Semver Bump Analysis Debug ===" && 
     ! echo "$stdout_content" | grep -q "=== Semver Bump Analysis Debug ==="; then
    echo "✅ $name (stderr debug messages)"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name (stderr debug messages)"
    echo "Expected debug messages in stderr, clean output in stdout"
    echo "Stderr contains debug: $(echo "$stderr_content" | grep -q "=== Semver Bump Analysis Debug ===" && echo "YES" || echo "NO")"
    echo "Stdout contains debug: $(echo "$stdout_content" | grep -q "=== Semver Bump Analysis Debug ===" && echo "YES" || echo "NO")"
  fi
}

echo "🧪 Testing determine-semver-bump.sh script"
echo "============================================="

# Test basic functionality with direct input
echo ""
echo "📝 Basic functionality tests:"
run_test "Simple patch fix" "a1b2c3d fix: resolve bug in handler" "patch"
run_test "Simple feature addition" "a1b2c3d feat: add new feature" "minor"
run_test "Breaking change with BREAKING CHANGE:" "a1b2c3d feat: new feature\n\nBREAKING CHANGE: API changed" "major"
run_test "Breaking change with !:" "a1b2c3d feat!: breaking feature" "major"

# Test with fixture files
echo ""
echo "📂 Fixture file tests:"
test_with_fixture "Breaking change fixture" "commits-breaking-change.txt" "major"
test_with_fixture "Feature addition fixture" "commits-feature-addition.txt" "minor"
test_with_fixture "Patch only fixture" "commits-patch-only.txt" "patch"
test_with_fixture "Breaking exclamation fixture" "commits-breaking-exclamation.txt" "major"
test_with_fixture "Mixed breaking and features" "commits-mixed-breaking-and-features.txt" "major"
test_with_fixture "Malformed commits" "commits-malformed.txt" "patch"

# Test environment variable input
echo ""
echo "🔧 Environment variable tests:"
test_with_env_var "Env var - feature" "a1b2c3d feat: add feature" "minor"
test_with_env_var "Env var - breaking" "a1b2c3d feat!: breaking change" "major"
test_with_env_var "Env var - patch" "a1b2c3d fix: bug fix" "patch"

# Test edge cases
echo ""
echo "🔍 Edge case tests:"
test_with_fixture "Empty commits" "commits-empty.txt" "patch"
run_test "Multiline breaking change" "a1b2c3d feat: add feature\n\nSome description\n\nBREAKING CHANGE: This breaks things\n\nMore details" "major"
run_test "Multiple features" "a1b2c3d feat: first feature\nb2c3d4e feat: second feature\nc3d4e5f fix: bug fix" "minor"
run_test "Case sensitivity" "a1b2c3d FEAT: uppercase feature" "patch"
run_test "Feat in middle of line" "a1b2c3d some feat: not a feature" "patch"

# Test error conditions
echo ""
echo "⚠️  Error condition tests:"
test_error_condition "No input provided" "true"

# Test stdout/stderr separation
echo ""
echo "🔍 Stdout/stderr separation tests:"
test_stdout_stderr_separation "Stdout/stderr separation" "a1b2c3d feat: add feature" "minor"

# Summary
echo ""
echo "============================================="
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