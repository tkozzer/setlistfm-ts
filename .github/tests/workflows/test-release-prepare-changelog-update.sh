#!/usr/bin/env bash
set -euo pipefail

# Test script for release-prepare workflow changelog update step
#
# This test suite validates the changelog update logic used in the release-prepare.yml workflow.
# It tests the conditional logic for handling OpenAI-generated content, fallback scenarios,
# and proper insertion of new changelog entries into the existing CHANGELOG.md structure.
#
# Tests cover:
# - Preference for formatted content over raw content
# - Fallback to raw content when formatted is empty/null
# - Complete fallback when both OpenAI outputs fail
# - Handling of special characters and multi-line content
# - Proper insertion order (new entries before old ones)
# - Integration with fixture data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/../fixtures"

total_tests=0
passed_tests=0

# Create a mock CHANGELOG.md structure
create_test_changelog() {
  cat > CHANGELOG.md <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.7.0] - 2025-06-07

### Added

- Existing feature from previous release

### Fixed

- Previous bug fix

---

## [0.6.0] - 2025-06-05

### Changed

- Some older change

EOF
}

# Simulate the workflow's changelog update logic
update_changelog() {
  local VER="$1"
  local TODAY="$2"

  # Use environment variables to safely handle multi-line content
  if [ -n "${FORMATTED_CONTENT:-}" ] && [ "${FORMATTED_CONTENT}" != "null" ]; then
    echo "${FORMATTED_CONTENT}" > changelog_entry.txt
  elif [ -n "${RAW_CONTENT:-}" ] && [ "${RAW_CONTENT}" != "null" ]; then
    echo "${RAW_CONTENT}" > changelog_entry.txt
  else
    # Fallback if OpenAI fails completely
    echo "## [${VER}] - ${TODAY}" > changelog_entry.txt
    echo "" >> changelog_entry.txt
    echo "### Changed" >> changelog_entry.txt
    echo "" >> changelog_entry.txt
    echo "- Release notes generation failed. Please refer to commit history for details." >> changelog_entry.txt
  fi

  # Add separator after the entry
  echo "" >> changelog_entry.txt
  echo "---" >> changelog_entry.txt
  echo "" >> changelog_entry.txt

  # Insert the new entry after the --- separator (line 5) and before the first version entry
  { head -n 5 CHANGELOG.md; echo ""; cat changelog_entry.txt; tail -n +6 CHANGELOG.md; } > CHANGELOG.tmp
  mv CHANGELOG.tmp CHANGELOG.md
  rm changelog_entry.txt
}

run_test() {
  local name="$1"
  local version="$2"
  local date="$3"
  local formatted_content="$4"
  local raw_content="$5"
  local expected_pattern="$6"

  total_tests=$((total_tests + 1))
  
  # Setup test environment
  create_test_changelog
  export FORMATTED_CONTENT="$formatted_content"
  export RAW_CONTENT="$raw_content"
  
  # Run the update logic
  update_changelog "$version" "$date"
  
  # Check if the result matches expected pattern
  if grep -q "$expected_pattern" CHANGELOG.md; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "Expected pattern: $expected_pattern"
    echo "Actual changelog:"
    head -20 CHANGELOG.md
    echo "..."
  fi
  
  # Cleanup
  rm -f CHANGELOG.md changelog_entry.txt CHANGELOG.tmp
  unset FORMATTED_CONTENT RAW_CONTENT
}

# Test with fixture data
test_with_fixture() {
  local name="$1"
  local fixture_file="$2"
  local version="$3"
  local date="$4"
  local expected_pattern="$5"

  total_tests=$((total_tests + 1))
  
  create_test_changelog
  
  # Load formatted content from fixture and prepend with correct version header
  local formatted_content=""
  if [[ -f "$FIXTURES_DIR/$fixture_file" ]]; then
    local fixture_content=$(cat "$FIXTURES_DIR/$fixture_file")
    # Replace the fixture version header with our test version
    formatted_content=$(echo "$fixture_content" | sed "s/^## \[.*\] - .*/## [$version] - $date/")
  fi
  
  export FORMATTED_CONTENT="$formatted_content"
  export RAW_CONTENT=""
  
  update_changelog "$version" "$date"
  
  if grep -q "$expected_pattern" CHANGELOG.md && grep -q "## \[$version\] - $date" CHANGELOG.md; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "Expected pattern: $expected_pattern"
    echo "Expected version header: ## [$version] - $date"
    echo "Actual changelog:"
    head -20 CHANGELOG.md
  fi
  
  rm -f CHANGELOG.md changelog_entry.txt CHANGELOG.tmp
  unset FORMATTED_CONTENT RAW_CONTENT
}

# Test structure validation
test_structure() {
  local name="$1"
  local version="$2"
  local date="$3"
  local formatted_content="$4"

  total_tests=$((total_tests + 1))
  
  create_test_changelog
  export FORMATTED_CONTENT="$formatted_content"
  export RAW_CONTENT=""
  
  update_changelog "$version" "$date"
  
  # Check structure: new entry should be before old entries
  local new_line=$(grep -n "## \[$version\]" CHANGELOG.md | cut -d: -f1)
  local old_line=$(grep -n "## \[0.7.0\]" CHANGELOG.md | cut -d: -f1)
  
  if [[ $new_line -lt $old_line ]]; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "New entry line: $new_line, Old entry line: $old_line"
    echo "New entry should appear before old entries"
  fi
  
  rm -f CHANGELOG.md changelog_entry.txt CHANGELOG.tmp
  unset FORMATTED_CONTENT RAW_CONTENT
}

main() {
  echo "Running release-prepare changelog update tests..."

  # Test 1: Formatted content is used when available
  run_test "Formatted content preference" \
    "0.8.0" \
    "2025-06-09" \
    "## [0.8.0] - 2025-06-09

### Added

- New formatted feature
- Another formatted addition" \
    "## [0.8.0] - 2025-06-09

### Added

- Raw content feature" \
    "New formatted feature"

  # Test 2: Fallback to raw content when formatted is empty
  run_test "Raw content fallback" \
    "0.8.1" \
    "2025-06-09" \
    "" \
    "## [0.8.1] - 2025-06-09

### Fixed

- Bug fix from raw content" \
    "Bug fix from raw content"

  # Test 3: Complete fallback when both are empty
  run_test "Complete fallback" \
    "0.8.2" \
    "2025-06-09" \
    "" \
    "" \
    "Release notes generation failed"

  # Test 4: Handle content with special characters
  run_test "Special characters handling" \
    "0.8.3" \
    "2025-06-09" \
    "## [0.8.3] - 2025-06-09

### Added

- Feature with 'single quotes'
- Feature with \"double quotes\"
- Feature with \$dollar signs
- Feature with backticks \`code\`" \
    "" \
    "Feature with 'single quotes'"

  # Test 5: Multi-line content handling
  run_test "Multi-line content" \
    "0.8.4" \
    "2025-06-09" \
    "## [0.8.4] - 2025-06-09

### Added

- Multi-line feature description
  that spans multiple lines
- Another feature

### Changed

- Updated something important" \
    "" \
    "Multi-line feature description"

  # Test 6: Using changelog fixture
  test_with_fixture "Changelog fixture test" \
    "release-notes-examples/changelog-minor-release.md" \
    "0.8.5" \
    "2025-06-09" \
    "Minor improvements"

  # Test 7: Verify correct insertion order
  test_structure "Insertion order verification" \
    "0.8.6" \
    "2025-06-09" \
    "## [0.8.6] - 2025-06-09

### Added

- Newest feature should appear first"

  # Test 8: Handle empty formatted content (null from OpenAI)
  run_test "Null formatted content" \
    "0.8.7" \
    "2025-06-09" \
    "null" \
    "## [0.8.7] - 2025-06-09

### Added

- Feature from raw content backup" \
    "Feature from raw content backup"

  echo "🏁 Completed: $passed_tests/$total_tests passed"

  if [[ $passed_tests -eq $total_tests ]]; then
    echo "🎉 All tests passed!"
    exit 0
  else
    echo "❌ Some tests failed!"
    exit 1
  fi
}

main "$@" 