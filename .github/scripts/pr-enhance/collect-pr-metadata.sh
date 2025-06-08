#!/usr/bin/env bash
set -euo pipefail

# Script to collect PR metadata including commit analysis and file changes
# Extracts complex logic from pr-enhance.yml workflow for better testability
# 
# Usage: collect-pr-metadata.sh [options]
# Environment variables or options:
#   PR_NUMBER         - Pull request number
#   PR_TITLE          - Pull request title  
#   PR_BODY           - Pull request body
#   BASE_SHA          - Base commit SHA
#   HEAD_SHA          - Head commit SHA
#   OUTPUT_FILE       - File to write GitHub Actions output format (optional)
#   TEST_MODE         - Set to "true" to disable cleanup (optional)

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [options]

Environment Variables:
  PR_NUMBER         Pull request number (required)
  PR_TITLE          Pull request title (required) 
  PR_BODY           Pull request body (optional)
  BASE_SHA          Base commit SHA (required)
  HEAD_SHA          Head commit SHA (required)
  OUTPUT_FILE       Output file path (default: stdout)
  TEST_MODE         Set to "true" to keep temp files for testing

Options:
  -h, --help        Show this help message
  -v, --verbose     Enable verbose output

Examples:
  # From environment variables
  PR_NUMBER=123 PR_TITLE="My PR" BASE_SHA=abc123 HEAD_SHA=def456 $0
  
  # With output file
  OUTPUT_FILE=/tmp/output.txt $0
EOF
}

# Function for verbose logging
log_verbose() {
    if [[ "${VERBOSE:-}" == "true" ]]; then
        echo "[VERBOSE] $*" >&2
    fi
}

# Function for error logging
log_error() {
    echo "[ERROR] $*" >&2
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required environment variables
if [[ -z "${PR_NUMBER:-}" ]]; then
    log_error "PR_NUMBER environment variable is required"
    exit 1
fi

if [[ -z "${PR_TITLE:-}" ]]; then
    log_error "PR_TITLE environment variable is required"
    exit 1
fi

if [[ -z "${BASE_SHA:-}" ]]; then
    log_error "BASE_SHA environment variable is required"
    exit 1
fi

if [[ -z "${HEAD_SHA:-}" ]]; then
    log_error "HEAD_SHA environment variable is required"
    exit 1
fi

# Set default values
PR_BODY="${PR_BODY:-}"
OUTPUT_FILE="${OUTPUT_FILE:-}"
TEST_MODE="${TEST_MODE:-false}"

log_verbose "Starting PR metadata collection"
log_verbose "PR: #$PR_NUMBER - $PR_TITLE"
log_verbose "SHA range: $BASE_SHA..$HEAD_SHA"

# Create temporary directory for work files
TEMP_DIR=$(mktemp -d)
if [[ "$TEST_MODE" != "true" ]]; then
    trap 'rm -rf "$TEMP_DIR"' EXIT
fi

COMMITS_FILE="$TEMP_DIR/commits.txt"
FILES_FILE="$TEMP_DIR/files.txt"
PR_BODY_FILE="$TEMP_DIR/pr_body.txt"

log_verbose "Working directory: $TEMP_DIR"

# Save the original body
printf "%s" "$PR_BODY" > "$PR_BODY_FILE"

# Get commit list (hash + subject)
log_verbose "Collecting commit history..."
if git log --pretty=format:"%h %s" "$BASE_SHA..$HEAD_SHA" > "$COMMITS_FILE" 2>/dev/null; then
    # Ensure there's a newline at the end for proper wc counting
    if [[ -s "$COMMITS_FILE" ]] && [[ "$(tail -c1 "$COMMITS_FILE")" != "" ]]; then
        echo "" >> "$COMMITS_FILE"
    fi
else
    log_verbose "No commits found or git command failed, creating empty file"
    touch "$COMMITS_FILE"
fi

# Get changed files
log_verbose "Collecting changed files..."
if ! git diff --name-only "$BASE_SHA..$HEAD_SHA" > "$FILES_FILE" 2>/dev/null; then
    log_verbose "No file changes found or git command failed, creating empty file"
    touch "$FILES_FILE"
fi

# Calculate basic counts
total=$(wc -l < "$COMMITS_FILE" | xargs)
files_count=$(wc -l < "$FILES_FILE" | xargs)

log_verbose "Found $total commits and $files_count changed files"

# Count specific commit types with consistent regex patterns
log_verbose "Analyzing conventional commit patterns..."

# Function to count commit type safely
count_commit_type() {
    local pattern="$1"
    local file="$2"
    local count
    count=$(grep -cE "$pattern" "$file" 2>/dev/null || true)
    echo "$count"
}

# Count each conventional commit type
feat=$(count_commit_type '^[a-zA-Z0-9]+ feat(\(.*\))?!?:' "$COMMITS_FILE")
fix=$(count_commit_type '^[a-zA-Z0-9]+ fix(\(.*\))?!?:' "$COMMITS_FILE")
docs=$(count_commit_type '^[a-zA-Z0-9]+ docs(\(.*\))?!?:' "$COMMITS_FILE")
style=$(count_commit_type '^[a-zA-Z0-9]+ style(\(.*\))?!?:' "$COMMITS_FILE")
refactor=$(count_commit_type '^[a-zA-Z0-9]+ refactor(\(.*\))?!?:' "$COMMITS_FILE")
perf=$(count_commit_type '^[a-zA-Z0-9]+ perf(\(.*\))?!?:' "$COMMITS_FILE")
test=$(count_commit_type '^[a-zA-Z0-9]+ test(\(.*\))?!?:' "$COMMITS_FILE")
chore=$(count_commit_type '^[a-zA-Z0-9]+ chore(\(.*\))?!?:' "$COMMITS_FILE")

# CI detection: matches both direct ci/build commits AND scoped ci/build commits
ci=$(count_commit_type '^[a-zA-Z0-9]+ ((ci|build)(\(.*\))?!?:|.*\((ci|build)\):)' "$COMMITS_FILE")

# Breaking change detection
break=$(count_commit_type '^[a-zA-Z0-9]+.*BREAKING CHANGE|!:' "$COMMITS_FILE")

# Calculate total conventional commits by summing individual types
conv=$((feat + fix + docs + style + refactor + perf + test + chore + ci))

log_verbose "Conventional commit breakdown:"
log_verbose "  feat: $feat, fix: $fix, docs: $docs, style: $style"
log_verbose "  refactor: $refactor, perf: $perf, test: $test, chore: $chore"
log_verbose "  ci: $ci, breaking: $break"
log_verbose "  Total conventional: $conv out of $total"

# Prepare output in GitHub Actions format
OUTPUT_CONTENT=$(cat <<EOF
number=$PR_NUMBER
title=$PR_TITLE
total=$total
conv=$conv
files_count=$files_count
feat=$feat
fix=$fix
docs=$docs
style=$style
refactor=$refactor
perf=$perf
test=$test
chore=$chore
ci=$ci
break=$break
EOF
)

# Write output
if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$OUTPUT_CONTENT" > "$OUTPUT_FILE"
    log_verbose "Output written to: $OUTPUT_FILE"
else
    echo "$OUTPUT_CONTENT"
fi

# In test mode, also create individual files for inspection
if [[ "$TEST_MODE" == "true" ]]; then
    log_verbose "Test mode: preserving work files in $TEMP_DIR"
    echo "TEMP_DIR=$TEMP_DIR" >&2
fi

log_verbose "PR metadata collection completed successfully" 