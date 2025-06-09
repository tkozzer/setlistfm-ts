#!/usr/bin/env bash

# --------------------------------------------------------------------------- #
#  Git History Collection Script                                              #
# --------------------------------------------------------------------------- #
# Collects git commit history since the last release for AI context
# Part of the Release Notes Generation Enhancement Framework
#
# Usage: collect-git-history.sh --since-tag <tag> --output-format <json|text> [--verbose]

set -euo pipefail

# --------------------------------------------------------------------------- #
#  Configuration and defaults                                                  #
# --------------------------------------------------------------------------- #
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERBOSE=0
OUTPUT_FORMAT="text"
SINCE_TAG=""
COMMIT_LIMIT=50

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# --------------------------------------------------------------------------- #
#  Logging functions                                                           #
# --------------------------------------------------------------------------- #
log_info() {
  echo -e "${BLUE}ℹ️  INFO: $*${NC}" >&2
}

log_success() {
  echo -e "${GREEN}✅ SUCCESS: $*${NC}" >&2
}

log_warning() {
  echo -e "${YELLOW}⚠️  WARNING: $*${NC}" >&2
}

log_error() {
  echo -e "${RED}❌ ERROR: $*${NC}" >&2
}

log_verbose() {
  if [[ $VERBOSE -eq 1 ]]; then
    echo -e "${BLUE}🔍 VERBOSE: $*${NC}" >&2
  fi
}

# --------------------------------------------------------------------------- #
#  Input validation                                                            #
# --------------------------------------------------------------------------- #
validate_inputs() {
  log_verbose "Starting input validation"
  
  if [[ -z "$SINCE_TAG" ]]; then
    log_error "Missing required parameter: --since-tag"
    exit 1
  fi
  
  if [[ "$OUTPUT_FORMAT" != "json" && "$OUTPUT_FORMAT" != "text" ]]; then
    log_error "Invalid output format: $OUTPUT_FORMAT. Must be 'json' or 'text'"
    exit 1
  fi
  
  # Validate git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
  fi
  
  log_verbose "Input validation passed"
}

# --------------------------------------------------------------------------- #
#  Git operations                                                              #
# --------------------------------------------------------------------------- #
get_commit_range() {
  local since_tag="$1"
  local commit_range
  
  log_verbose "Determining commit range since tag: $since_tag"
  
  # Check if tag exists
  if git rev-parse --verify "refs/tags/$since_tag" >/dev/null 2>&1; then
    commit_range="${since_tag}..HEAD"
    log_verbose "Using commit range: $commit_range"
  else
    log_warning "Tag $since_tag not found, using all commits"
    commit_range="HEAD"
  fi
  
  echo "$commit_range"
}

collect_commits_text() {
  local commit_range="$1"
  local commits
  
  log_verbose "Collecting commits in text format"
  
  commits=$(git log "$commit_range" \
    --pretty=format:"%h - %s (%an, %ar)" \
    --no-merges \
    --max-count="$COMMIT_LIMIT" 2>/dev/null || echo "")
  
  if [[ -z "$commits" ]]; then
    log_warning "No commits found in range $commit_range"
    echo "No commits found since $SINCE_TAG"
  else
    echo "$commits"
  fi
}

collect_commits_json() {
  local commit_range="$1"
  local commits=()
  
  log_verbose "Collecting commits in JSON format"
  
  # Build array of commit objects
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      local hash=$(echo "$line" | cut -d' ' -f1)
      local message=$(git log -1 --pretty=format:"%s" "$hash" 2>/dev/null || echo "")
      local author=$(git log -1 --pretty=format:"%an" "$hash" 2>/dev/null || echo "")
      local date=$(git log -1 --pretty=format:"%ar" "$hash" 2>/dev/null || echo "")
      
      # Escape JSON strings (backslashes first, then quotes)
      message=$(echo "$message" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
      author=$(echo "$author" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
      
      # Build commit object as single line
      local commit_obj="{\"hash\": \"$hash\", \"message\": \"$message\", \"author\": \"$author\", \"date\": \"$date\"}"
      commits+=("$commit_obj")
    fi
  done < <(git log "$commit_range" --pretty=format:"%h" --no-merges --max-count="$COMMIT_LIMIT" 2>/dev/null && echo)
  
  # Build final JSON array
  if [[ ${#commits[@]} -eq 0 ]]; then
    echo "[]"
  else
    local IFS=','
    echo "[${commits[*]}]"
  fi
}

# --------------------------------------------------------------------------- #
#  Main execution                                                              #
# --------------------------------------------------------------------------- #
main() {
  local commit_range
  local output
  
  log_verbose "Starting git history collection"
  
  # Validate inputs
  validate_inputs
  
  # Get commit range
  commit_range=$(get_commit_range "$SINCE_TAG")
  
  # Collect commits based on output format
  if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    output=$(collect_commits_json "$commit_range")
  else
    output=$(collect_commits_text "$commit_range")
  fi
  
  # Output results
  printf '%s' "$output"
  
  log_success "Git history collection completed successfully"
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
    --commit-limit)
      COMMIT_LIMIT="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --help)
      cat <<EOF
Git History Collection Script

Usage: collect-git-history.sh --since-tag <tag> --output-format <json|text> [options]

Options:
  --since-tag <tag>        Tag to collect commits since (required)
  --output-format <format> Output format: json or text (default: text)
  --commit-limit <number>  Maximum number of commits to collect (default: 50)
  --verbose               Enable verbose logging
  --help                  Show this help message

Examples:
  collect-git-history.sh --since-tag v0.7.0 --output-format text
  collect-git-history.sh --since-tag v0.7.0 --output-format json --verbose
EOF
      exit 0
      ;;
    *)
      log_error "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Run main function
main "$@" 