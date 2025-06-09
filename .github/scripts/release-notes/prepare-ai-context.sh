#!/usr/bin/env bash

# --------------------------------------------------------------------------- #
#  AI Context Preparation Script                                              #
# --------------------------------------------------------------------------- #
# Orchestrates data collection and prepares comprehensive AI context
# Part of the Release Notes Generation Enhancement Framework
#
# Usage: prepare-ai-context.sh --version <version> [--verbose]

set -euo pipefail

# --------------------------------------------------------------------------- #
#  Configuration and defaults                                                  #
# --------------------------------------------------------------------------- #
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERBOSE=0
VERSION=""
OUTPUT_FORMAT="template_vars"

# Workflow parameters (when provided, use these instead of collecting data)
PROVIDED_GIT_COMMITS_B64=""
PROVIDED_COMMIT_STATS_B64=""
PROVIDED_CHANGELOG_ENTRY_B64=""
PROVIDED_SINCE_TAG=""

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
  
  if [[ -z "$VERSION" ]]; then
    log_error "Missing required parameter: --version"
    exit 1
  fi
  
  # Validate git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
  fi
  
  # Check if required scripts exist
  local required_scripts=(
    "$SCRIPT_DIR/collect-git-history.sh"
    "$SCRIPT_DIR/extract-commit-stats.sh"
  )
  
  for script in "${required_scripts[@]}"; do
    if [[ ! -f "$script" ]]; then
      log_error "Required script not found: $script"
      exit 1
    fi
    
    if [[ ! -x "$script" ]]; then
      log_verbose "Making script executable: $script"
      chmod +x "$script"
    fi
  done
  
  log_verbose "Input validation passed"
}

# --------------------------------------------------------------------------- #
#  Version and tag management                                                  #
# --------------------------------------------------------------------------- #
get_previous_tag() {
  local current_version="$1"
  local previous_tag
  
  log_verbose "Determining previous tag for version: $current_version"
  
  # Remove 'v' prefix if present for comparison
  local version_number="${current_version#v}"
  
  # Get the most recent tag that's not the current version
  previous_tag=$(git tag --sort=-version:refname | \
    grep -v "^v\?${version_number}$" | \
    head -n1 2>/dev/null || echo "")
  
  if [[ -z "$previous_tag" ]]; then
    log_warning "No previous tag found, using first commit"
    # Get first commit if no tags exist
    previous_tag=$(git rev-list --max-parents=0 HEAD 2>/dev/null || echo "HEAD~10")
  fi
  
  log_verbose "Previous tag: $previous_tag"
  echo "$previous_tag"
}

determine_version_type() {
  local current_version="$1"
  local previous_tag="$2"
  
  log_verbose "Determining version type"
  
  # Simple version type detection based on semantic versioning
  if [[ "$current_version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[3]}"
    
    if [[ "$previous_tag" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
      local prev_major="${BASH_REMATCH[1]}"
      local prev_minor="${BASH_REMATCH[2]}"
      local prev_patch="${BASH_REMATCH[3]}"
      
      if [[ $major -gt $prev_major ]]; then
        echo "major"
      elif [[ $minor -gt $prev_minor ]]; then
        echo "minor"
      else
        echo "patch"
      fi
    else
      echo "initial"
    fi
  else
    echo "unknown"
  fi
}

# --------------------------------------------------------------------------- #
#  Data collection functions                                                   #
# --------------------------------------------------------------------------- #
collect_git_commits() {
  local since_tag="$1"
  local git_commits
  
  log_verbose "Collecting git commit history"
  
  git_commits=$("$SCRIPT_DIR/collect-git-history.sh" \
    --since-tag "$since_tag" \
    --output-format text \
    2>/dev/null || echo "No commits found")
  
  echo "$git_commits"
}

collect_commit_stats() {
  local since_tag="$1"
  local commit_stats
  
  log_verbose "Collecting commit statistics"
  
  commit_stats=$("$SCRIPT_DIR/extract-commit-stats.sh" \
    --since-tag "$since_tag" \
    --output-format json \
    2>/dev/null || echo "{}")
  
  echo "$commit_stats"
}

extract_changelog_entry() {
  local version="$1"
  local changelog_entry=""
  
  log_verbose "Extracting changelog entry for version $version"
  
  # Try to find CHANGELOG.md entry
  if [[ -f "CHANGELOG.md" ]]; then
    # Extract section for current version using simpler AWK pattern
    local version_clean="${version#v}"  # Remove 'v' prefix if present
    changelog_entry=$(awk "/^## \[${version_clean}\]/{flag=1; next} /^## / && flag{exit} flag" CHANGELOG.md 2>/dev/null || echo "")
    
    if [[ -n "$changelog_entry" ]]; then
      log_verbose "Found changelog entry"
    else
      log_verbose "No changelog entry found for version $version"
      changelog_entry="No changelog entry found for this version."
    fi
  else
    log_verbose "CHANGELOG.md not found"
    changelog_entry="CHANGELOG.md not found in repository."
  fi
  
  echo "$changelog_entry"
}

get_previous_release_notes() {
  local version="$1"
  
  log_verbose "Looking for previous release notes"
  
  # This is a placeholder - in a real implementation, you might:
  # - Fetch from GitHub releases API
  # - Look in a releases directory
  # - Extract from previous changelog entries
  echo "Previous release notes not available."
}

# --------------------------------------------------------------------------- #
#  Base64 encoding/decoding for multi-line content                            #
# --------------------------------------------------------------------------- #
encode_base64() {
  local content="$1"
  printf '%s' "$content" | base64 -w 0
}

decode_base64() {
  local base64_content="$1"
  if [[ -n "$base64_content" ]]; then
    printf '%s' "$base64_content" | base64 -d 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# --------------------------------------------------------------------------- #
#  Template variable preparation                                               #
# --------------------------------------------------------------------------- #
prepare_template_variables() {
  local version="$1"
  local previous_tag git_commits commit_stats changelog_entry version_type
  local has_breaking_changes previous_release
  
  log_verbose "Preparing template variables"
  
  # Determine previous tag (use provided tag if available)
  if [[ -n "$PROVIDED_SINCE_TAG" ]]; then
    previous_tag="$PROVIDED_SINCE_TAG"
    log_verbose "Using provided since tag: $previous_tag"
  else
    previous_tag=$(get_previous_tag "$version")
    log_verbose "Auto-detected previous tag: $previous_tag"
  fi
  
  # Determine version type
  version_type=$(determine_version_type "$version" "$previous_tag")
  
  # Use provided data or collect it
  if [[ -n "$PROVIDED_GIT_COMMITS_B64" ]]; then
    log_verbose "Using provided git commits data"
    git_commits=$(decode_base64 "$PROVIDED_GIT_COMMITS_B64")
  else
    log_verbose "Collecting git commits internally"
    git_commits=$(collect_git_commits "$previous_tag")
  fi
  
  if [[ -n "$PROVIDED_COMMIT_STATS_B64" ]]; then
    log_verbose "Using provided commit stats data"
    commit_stats=$(decode_base64 "$PROVIDED_COMMIT_STATS_B64")
  else
    log_verbose "Collecting commit stats internally"
    commit_stats=$(collect_commit_stats "$previous_tag")
  fi
  
  if [[ -n "$PROVIDED_CHANGELOG_ENTRY_B64" ]]; then
    log_verbose "Using provided changelog entry data"
    changelog_entry=$(decode_base64 "$PROVIDED_CHANGELOG_ENTRY_B64")
  else
    log_verbose "Extracting changelog entry internally"
    changelog_entry=$(extract_changelog_entry "$version")
  fi
  
  # Always collect previous release notes (no workflow parameter for this yet)
  previous_release=$(get_previous_release_notes "$version")
  
  # Extract breaking changes flag from commit stats
  has_breaking_changes=$(echo "$commit_stats" | jq -r '.breaking_changes_detected // false' 2>/dev/null || echo "false")
  
  # Prepare template variables in GitHub Actions format
  cat <<EOF
VERSION=$version
VERSION_TYPE=$version_type
CHANGELOG_ENTRY_B64=$(encode_base64 "$changelog_entry")
GIT_COMMITS_B64=$(encode_base64 "$git_commits")
COMMIT_STATS_B64=$(encode_base64 "$commit_stats")
HAS_BREAKING_CHANGES=$has_breaking_changes
PREVIOUS_RELEASE_B64=$(encode_base64 "$previous_release")
EOF
}

# --------------------------------------------------------------------------- #
#  Main execution                                                              #
# --------------------------------------------------------------------------- #
main() {
  log_verbose "Starting AI context preparation"
  
  # Validate inputs
  validate_inputs
  
  # Prepare and output template variables
  prepare_template_variables "$VERSION"
  
  log_success "AI context preparation completed successfully"
}

# --------------------------------------------------------------------------- #
#  Command line argument parsing                                               #
# --------------------------------------------------------------------------- #
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --git-commits-b64)
      PROVIDED_GIT_COMMITS_B64="$2"
      shift 2
      ;;
    --commit-stats-b64)
      PROVIDED_COMMIT_STATS_B64="$2"
      shift 2
      ;;
    --changelog-entry-b64)
      PROVIDED_CHANGELOG_ENTRY_B64="$2"
      shift 2
      ;;
    --since-tag)
      PROVIDED_SINCE_TAG="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --help)
      cat <<EOF
AI Context Preparation Script

Usage: prepare-ai-context.sh --version <version> [options]

Options:
  --version <version>              Version to prepare context for (required)
  --git-commits-b64 <base64>       Pre-collected git commits (base64 encoded)
  --commit-stats-b64 <base64>      Pre-collected commit statistics (base64 encoded)
  --changelog-entry-b64 <base64>   Pre-collected changelog entry (base64 encoded)
  --since-tag <tag>                Tag to use for commit range (overrides auto-detection)
  --verbose                        Enable verbose logging
  --help                           Show this help message

Examples:
  prepare-ai-context.sh --version v0.7.1
  prepare-ai-context.sh --version 0.7.1 --verbose
  prepare-ai-context.sh --version 0.7.3 --git-commits-b64 "$(echo 'data' | base64)"

Workflow Integration:
  When workflow parameters are provided, the script uses them instead of 
  collecting data internally. This allows GitHub Actions workflows to 
  pre-collect data and pass it to avoid redundant processing.

Output:
  Template variables in GitHub Actions format (KEY=value)
  Multi-line content is base64-encoded with _B64 suffix

Dependencies:
  - collect-git-history.sh (if not using --git-commits-b64)
  - extract-commit-stats.sh (if not using --commit-stats-b64)
  - git repository with tags
  - jq (for JSON processing)
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