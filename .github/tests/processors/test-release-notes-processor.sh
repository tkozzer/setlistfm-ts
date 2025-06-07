#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Test script for release-notes processor                                      #
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSOR="$SCRIPT_DIR/../../processors/release-notes-processor.sh"
FIXTURE_DIR="$SCRIPT_DIR/../fixtures/release-notes-examples"

TOTAL_TESTS=0
PASSED_TESTS=0

run_test(){
  local name="$1"; shift
  TOTAL_TESTS=$((TOTAL_TESTS+1))
  echo "📋 Test $TOTAL_TESTS: $name"
  if "$@"; then
    echo "✅ PASS"
    PASSED_TESTS=$((PASSED_TESTS+1))
  else
    echo "❌ FAIL"
  fi
  echo
}

# Ensure processor is executable
run_test "Processor exists" test -x "$PROCESSOR"

# Test changelog parsing
run_changelog_parsing(){
  local ver="0.7.0"
  "$PROCESSOR" "$ver" >/tmp/out.txt && grep -q "v$ver" /tmp/out.txt
}
run_test "Changelog parsing" run_changelog_parsing

# Test fallback logic when OpenAI fails
run_fallback(){
  OPENAI_API_KEY=invalid-key "$PROCESSOR" "0.7.0" >/tmp/out.txt || true
  grep -q "Automated release notes generation failed" /tmp/out.txt
}
run_test "OpenAI failure fallback" run_fallback

# Summary
echo "🏁 Release notes processor tests completed!"
echo "📊 Results: $PASSED_TESTS/$TOTAL_TESTS tests passed"

[[ $PASSED_TESTS -eq $TOTAL_TESTS ]]
