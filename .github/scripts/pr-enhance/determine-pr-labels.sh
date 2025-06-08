#!/bin/bash

# 🏷️ PR Label Determination Script
# 
# Determines which labels to apply to a PR based on commit type counts.
# Extracted from .github/workflows/pr-enhance.yml for better testability.
#
# Usage: determine-pr-labels.sh --feat N --fix N --docs N [other flags] --conv N --total N
#
# Arguments:
#   --feat N        Number of feature commits
#   --fix N         Number of fix commits  
#   --docs N        Number of documentation commits
#   --chore N       Number of chore commits
#   --refactor N    Number of refactor commits
#   --perf N        Number of performance commits
#   --test N        Number of test commits
#   --style N       Number of style commits
#   --ci N          Number of CI commits
#   --break N       Number of breaking change commits
#   --conv N        Number of conventional commits
#   --total N       Total number of commits
#   --threshold N   Conventional commit percentage threshold (default: 80)
#   --help          Show this help message
#
# Output: Space-separated list of labels to stdout
#
# Examples:
#   determine-pr-labels.sh --feat 2 --fix 1 --conv 3 --total 3
#   # Output: feature bugfix
#
#   determine-pr-labels.sh --feat 1 --conv 1 --total 2
#   # Output: feature needs-review
#

set -euo pipefail

# Default values
FEAT_COUNT=0
FIX_COUNT=0
DOCS_COUNT=0
CHORE_COUNT=0
REFACTOR_COUNT=0
PERF_COUNT=0
TEST_COUNT=0
STYLE_COUNT=0
CI_COUNT=0
BREAK_COUNT=0
CONV_COUNT=0
TOTAL_COUNT=0
THRESHOLD=80
HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --feat)
      FEAT_COUNT="$2"
      shift 2
      ;;
    --fix)
      FIX_COUNT="$2"
      shift 2
      ;;
    --docs)
      DOCS_COUNT="$2"
      shift 2
      ;;
    --chore)
      CHORE_COUNT="$2"
      shift 2
      ;;
    --refactor)
      REFACTOR_COUNT="$2"
      shift 2
      ;;
    --perf)
      PERF_COUNT="$2"
      shift 2
      ;;
    --test)
      TEST_COUNT="$2"
      shift 2
      ;;
    --style)
      STYLE_COUNT="$2"
      shift 2
      ;;
    --ci)
      CI_COUNT="$2"
      shift 2
      ;;
    --break)
      BREAK_COUNT="$2"
      shift 2
      ;;
    --conv)
      CONV_COUNT="$2"
      shift 2
      ;;
    --total)
      TOTAL_COUNT="$2"
      shift 2
      ;;
    --threshold)
      THRESHOLD="$2"
      shift 2
      ;;
    --help)
      HELP=true
      shift
      ;;
    *)
      echo "Error: Unknown argument $1" >&2
      exit 1
      ;;
  esac
done

# Show help if requested
if [ "$HELP" = true ]; then
  grep "^#" "$0" | grep -v "^#!/" | sed 's/^# //' | sed 's/^#//'
  exit 0
fi

# Validate inputs
if ! [[ "$FEAT_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$FIX_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$DOCS_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$CHORE_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$REFACTOR_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$PERF_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$TEST_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$STYLE_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$CI_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$BREAK_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$CONV_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$TOTAL_COUNT" =~ ^[0-9]+$ ]] || 
   ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "Error: All counts must be non-negative integers" >&2
  exit 1
fi

if [ "$THRESHOLD" -lt 0 ] || [ "$THRESHOLD" -gt 100 ]; then
  echo "Error: Threshold must be between 0 and 100" >&2
  exit 1
fi

if [ "$CONV_COUNT" -gt "$TOTAL_COUNT" ]; then
  echo "Error: Conventional commit count cannot exceed total commit count" >&2
  exit 1
fi

# Initialize labels array
labels=()

# Add labels based on commit type counts
[ "$FEAT_COUNT" -gt 0 ] && labels+=('feature')
[ "$FIX_COUNT" -gt 0 ] && labels+=('bugfix')
[ "$DOCS_COUNT" -gt 0 ] && labels+=('documentation')
[ "$CHORE_COUNT" -gt 0 ] && labels+=('maintenance')
[ "$REFACTOR_COUNT" -gt 0 ] && labels+=('refactor')
[ "$PERF_COUNT" -gt 0 ] && labels+=('performance')
[ "$TEST_COUNT" -gt 0 ] && labels+=('testing')
[ "$STYLE_COUNT" -gt 0 ] && labels+=('style')
[ "$CI_COUNT" -gt 0 ] && labels+=('ci-cd')
[ "$BREAK_COUNT" -gt 0 ] && labels+=('breaking-change')

# Add needs-review label if conventional commit percentage is below threshold
if [ "$TOTAL_COUNT" -gt 0 ]; then
  # Calculate percentage using awk (same logic as workflow)
  percentage=$(awk "BEGIN{print int(($CONV_COUNT/$TOTAL_COUNT)*100)}")
  [ "$percentage" -lt "$THRESHOLD" ] && labels+=('needs-review')
fi

# Output space-separated labels
echo "${labels[*]}" 