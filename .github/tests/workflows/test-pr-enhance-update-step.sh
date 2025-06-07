#!/usr/bin/env bash
set -euo pipefail

# Test script for pr-enhance workflow update step quoting

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

total_tests=0
passed_tests=0

run_step() {
  # same logic as in workflow
  echo "=== AI Output Debug ==="
  echo "Raw content length: $(printf '%s' "$RAW_CONTENT" | wc -c)"
  echo "Formatted content length: $(printf '%s' "$FORMATTED_CONTENT" | wc -c)"
  echo "======================="

  printf '%s' "$FORMATTED_CONTENT" > formatted_temp.md
  printf '%s' "$RAW_CONTENT" > raw_temp.md

  if [ -s formatted_temp.md ] && [ "$(head -c 4 formatted_temp.md)" != "null" ]; then
    cp formatted_temp.md final.md
  elif [ -s raw_temp.md ] && [ "$(head -c 4 raw_temp.md)" != "null" ]; then
    cp raw_temp.md final.md
  else
    cp pr_body.txt final.md
  fi

  rm -f formatted_temp.md raw_temp.md
}

run_test() {
  local name="$1"
  RAW_CONTENT="$2" FORMATTED_CONTENT="$3" run_step

  total_tests=$((total_tests + 1))
  if diff -u <(printf '%s' "$4") final.md >/dev/null; then
    echo "✅ $name"
    passed_tests=$((passed_tests + 1))
  else
    echo "❌ $name"
    echo "Expected:"; printf '%s\n' "$4"
    echo "Actual:"; cat final.md
  fi
  rm -f final.md pr_body.txt
}

main() {
  echo "Running workflow quoting tests..."

  echo "default PR body" > pr_body.txt

  run_test "Formatted content chosen" \
    "raw with 'single' quotes" \
    "formatted with 'quotes' and \$dollar" \
    "formatted with 'quotes' and \$dollar"

  run_test "Raw content fallback" \
    "raw value" \
    "null" \
    "raw value"

  echo "🏁 Completed: $passed_tests/$total_tests passed"

  if [[ $passed_tests -eq $total_tests ]]; then
    exit 0
  else
    exit 1
  fi
}

main "$@"
