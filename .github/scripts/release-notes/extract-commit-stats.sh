#!/usr/bin/env bash

# --------------------------------------------------------------------------- #
#  Commit Statistics Extraction Script                                        #
# --------------------------------------------------------------------------- #
# Analyzes commits using conventional commit patterns for intelligent categorization
# Part of the Release Notes Generation Enhancement Framework
#
# Usage: extract-commit-stats.sh --since-tag <tag> [--output-format json] [--verbose]

set -euo pipefail

# --------------------------------------------------------------------------- #
#  Configuration and defaults                                                  #
# --------------------------------------------------------------------------- #
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERBOSE=0
OUTPUT_FORMAT="json"
SINCE_TAG=""

# Conventional commit patterns  
readonly FEAT_PATTERN="^feat"
readonly FIX_PATTERN="^fix"
readonly CHORE_PATTERN="^chore"
readonly CI_PATTERN="^ci"
readonly DOCS_PATTERN="^docs"
readonly BREAKING_PATTERN="BREAKING CHANGE:|!:"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# --------------------------------------------------------------------------- #
#  Logging functions                                                           #
# --------------------------------------------------------------------------- #
log() {
    local level="$1"
    shift
    
    case "$level" in
        "ERROR")
            echo -e "${RED}❌ ERROR: $*${NC}" >&2
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ SUCCESS: $*${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $*${NC}" >&2
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO: $*${NC}" >&2
            ;;
        "VERBOSE")
            if [[ "$VERBOSE" == "1" ]]; then
                echo -e "${BLUE}🔍 VERBOSE: $*${NC}" >&2
            fi
            ;;
    esac
}

# --------------------------------------------------------------------------- #
#  Input validation                                                            #
# --------------------------------------------------------------------------- #
validate_inputs() {
  log "VERBOSE" "Starting input validation"
  
  if [[ -z "$SINCE_TAG" ]]; then
    log "ERROR" "Missing required parameter: --since-tag"
    exit 1
  fi
  
  if [[ "$OUTPUT_FORMAT" != "json" && "$OUTPUT_FORMAT" != "text" ]]; then
    log "ERROR" "Invalid output format: $OUTPUT_FORMAT. Must be 'json' or 'text'"
    exit 1
  fi
  
  # Validate git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log "ERROR" "Not in a git repository"
    exit 1
  fi
  
  log "VERBOSE" "Input validation passed"
}

# --------------------------------------------------------------------------- #
#  Git operations                                                              #
# --------------------------------------------------------------------------- #
get_commit_range() {
  local since_tag="$1"
  local commit_range
  
  log "VERBOSE" "Determining commit range since tag: $since_tag"
  
  # Check if tag exists
  if git rev-parse --verify "refs/tags/$since_tag" >/dev/null 2>&1; then
    commit_range="${since_tag}..HEAD"
    log "VERBOSE" "Using commit range: $commit_range"
  else
    log "WARNING" "Tag $since_tag not found, using all commits"
    commit_range="HEAD"
  fi
  
  echo "$commit_range"
}

# --------------------------------------------------------------------------- #
#  Commit analysis functions                                                   #
# --------------------------------------------------------------------------- #
count_commits_by_pattern() {
  local commit_range="$1"
  local pattern="$2"
  local count
  
  # Count commits matching pattern - use git log directly with grep
  count=$(git log "$commit_range" --pretty=format:"%s" --no-merges 2>/dev/null | grep -cE "$pattern" 2>/dev/null)
  
  # If grep returns empty (no matches), set to 0
  if [[ -z "$count" ]]; then
    count="0"
  fi
  
  echo "$count"
}

detect_breaking_changes() {
  local commit_range="$1"
  local has_breaking="false"
  
  log "VERBOSE" "Checking for breaking changes"
  
  # Check commit messages for breaking change indicators
  if git log "$commit_range" --pretty=format:"%s %b" --no-merges 2>/dev/null | \
     grep -qE "$BREAKING_PATTERN"; then
    has_breaking="true"
    log "VERBOSE" "Breaking changes detected in commit messages"
  fi
  
  echo "$has_breaking"
}

get_commit_patterns() {
  local commit_range="$1"
  local patterns=()
  
  log "VERBOSE" "Extracting unique commit patterns"
  
  # Get unique prefixes from commit messages
  while IFS= read -r commit_msg; do
    if [[ -n "$commit_msg" ]]; then
      # Extract pattern (everything before the first colon)
      local pattern=$(echo "$commit_msg" | sed -n 's/^\([^:]*\):.*/\1:/p')
      if [[ -n "$pattern" && ! " ${patterns[*]} " =~ " ${pattern} " ]]; then
        patterns+=("$pattern")
      fi
    fi
  done < <(git log "$commit_range" --pretty=format:"%s" --no-merges 2>/dev/null || echo "")
  
  # Convert array to JSON format
  local patterns_json="["
  for ((i=0; i<${#patterns[@]}; i++)); do
    patterns_json+="\"${patterns[i]}\""
    if [[ $i -lt $((${#patterns[@]} - 1)) ]]; then
      patterns_json+=","
    fi
  done
  patterns_json+="]"
  
  echo "$patterns_json"
}

# --------------------------------------------------------------------------- #
#  Statistics generation                                                       #
# --------------------------------------------------------------------------- #
generate_stats() {
  local commit_range="$1"
  local total_commits feat_count fix_count chore_count ci_count docs_count
  local breaking_changes_detected commit_patterns
  
  log "VERBOSE" "Generating commit statistics"
  
  # Count total commits
  total_commits=$(git rev-list --count --no-merges "$commit_range" 2>/dev/null || echo "0")
  
  # Count by conventional commit types
  feat_count=$(count_commits_by_pattern "$commit_range" "$FEAT_PATTERN")
  fix_count=$(count_commits_by_pattern "$commit_range" "$FIX_PATTERN")
  chore_count=$(count_commits_by_pattern "$commit_range" "$CHORE_PATTERN")
  ci_count=$(count_commits_by_pattern "$commit_range" "$CI_PATTERN")
  docs_count=$(count_commits_by_pattern "$commit_range" "$DOCS_PATTERN")
  
  # Detect breaking changes
  breaking_changes_detected=$(detect_breaking_changes "$commit_range")
  
  # Get commit patterns
  commit_patterns=$(get_commit_patterns "$commit_range")
  
  log "VERBOSE" "Statistics: total=$total_commits, feat=$feat_count, fix=$fix_count, chore=$chore_count, ci=$ci_count, docs=$docs_count"
  
  if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    # Output JSON format
    cat <<EOF
{
  "total_commits": $total_commits,
  "feat_count": $feat_count,
  "fix_count": $fix_count,
  "chore_count": $chore_count,
  "ci_count": $ci_count,
  "docs_count": $docs_count,
  "breaking_changes_detected": $breaking_changes_detected,
  "commit_patterns": $commit_patterns
}
EOF
  else
    # Output text format
    cat <<EOF
Total commits: $total_commits
Features (feat:): $feat_count
Bug fixes (fix:): $fix_count
Chores (chore:): $chore_count
CI/CD (ci:): $ci_count
Documentation (docs:): $docs_count
Breaking changes detected: $breaking_changes_detected
Commit patterns: $commit_patterns
EOF
  fi
}

# --------------------------------------------------------------------------- #
#  Main execution                                                              #
# --------------------------------------------------------------------------- #
main() {
  local commit_range
  
  log "VERBOSE" "Starting commit statistics extraction"
  
  # Validate inputs
  validate_inputs
  
  # Get commit range
  commit_range=$(get_commit_range "$SINCE_TAG")
  
  # Generate and output statistics
  generate_stats "$commit_range"
  
  log "SUCCESS" "Commit statistics extraction completed successfully"
}

# --------------------------------------------------------------------------- #
#  Command line argument parsing                                               #
# --------------------------------------------------------------------------- #
while [[ $# -gt 0 ]]; do
  case $1 in
    --since-tag)
      SINCE_TAG="$2"
      shift 2
      ;;
    --output-format)
      OUTPUT_FORMAT="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --help)
      cat <<EOF
Commit Statistics Extraction Script

Usage: extract-commit-stats.sh --since-tag <tag> [options]

Options:
  --since-tag <tag>        Tag to analyze commits since (required)
  --output-format <format> Output format: json or text (default: json)
  --verbose               Enable verbose logging
  --help                  Show this help message

Examples:
  extract-commit-stats.sh --since-tag v0.7.0
  extract-commit-stats.sh --since-tag v0.7.0 --output-format text --verbose

Conventional Commit Patterns Analyzed:
  feat:    New features
  fix:     Bug fixes
  chore:   Maintenance tasks
  ci:      CI/CD changes
  docs:    Documentation updates
  
Breaking Change Detection:
  - BREAKING CHANGE: in commit body
  - ! in commit type (e.g., feat!:, fix!:)
EOF
      exit 0
      ;;
    *)
      log "ERROR" "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi 