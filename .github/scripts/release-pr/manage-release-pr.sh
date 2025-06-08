#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
#  🚀  Manage Release Pull Request                                            #
# --------------------------------------------------------------------------- #
# 
# Manages the creation and updating of release pull requests from preview to main.
# This script replaces the complex inline logic from the release-pr.yml workflow
# to improve testability and maintainability.
#
# Usage:
#   ./manage-release-pr.sh [OPTIONS]
#
# Options:
#   --version <version>       Release version (e.g., 1.2.3)
#   --title <title>           PR title (default: "🚀 Release v{version}")
#   --body <body>             PR body/description
#   --labels <labels>         Comma-separated labels (default: "release,automated")
#   --assignee <assignee>     PR assignee (default: repository owner)
#   --base <branch>           Base branch (default: main)
#   --head <branch>           Head branch (default: preview)
#   --repository <repo>       Repository (default: from git remote)
#   --dry-run                 Show what would be done without executing
#   --output-format <format>  Output format: 'github-actions' (default) or 'json'
#   --debug                   Enable debug output
#   --help                    Show this help message
#
# GitHub Actions Output:
#   When --output-format=github-actions (default), outputs:
#   pr_number=123
#   pr_url=https://github.com/owner/repo/pull/123
#   action_taken=created|updated
#   exists=true|false
#
# JSON Output:
#   When --output-format=json, outputs a JSON object with the same fields
#
# Exit Codes:
#   0 - Success
#   1 - Missing required parameters
#   2 - GitHub CLI error
#   3 - PR operation failed
#   4 - Invalid parameters
#
# Author: tkozzer
# --------------------------------------------------------------------------- #

set -euo pipefail

# Default configuration
VERSION=""
TITLE=""
BODY=""
LABELS="release,automated"
ASSIGNEE=""
BASE_BRANCH="main"
HEAD_BRANCH="preview"
REPOSITORY=""
DRY_RUN=false
OUTPUT_FORMAT="github-actions"
DEBUG=false
MOCK_EXISTING_PR=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

debug() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${BLUE}[DEBUG] $*${NC}" >&2
    fi
}

info() {
    echo -e "${CYAN}[INFO] $*${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARN] $*${NC}" >&2
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}" >&2
}

show_help() {
    sed -n '2,/^# Author:/p' "$0" | sed 's/^# //; s/^#//'
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                VERSION="$2"
                shift 2
                ;;
            --title)
                TITLE="$2"
                shift 2
                ;;
            --body)
                BODY="$2"
                shift 2
                ;;
            --labels)
                LABELS="$2"
                shift 2
                ;;
            --assignee)
                ASSIGNEE="$2"
                shift 2
                ;;
            --base)
                BASE_BRANCH="$2"
                shift 2
                ;;
            --head)
                HEAD_BRANCH="$2"
                shift 2
                ;;
            --repository)
                REPOSITORY="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --output-format)
                OUTPUT_FORMAT="$2"
                if [[ "$OUTPUT_FORMAT" != "github-actions" && "$OUTPUT_FORMAT" != "json" ]]; then
                    error "Invalid output format: $OUTPUT_FORMAT. Must be 'github-actions' or 'json'"
                    exit 4
                fi
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --mock-existing-pr)
                MOCK_EXISTING_PR="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 4
                ;;
        esac
    done
}

validate_parameters() {
    debug "Validating input parameters"
    
    # Version is required
    if [[ -z "$VERSION" ]]; then
        error "Version is required. Use --version to specify."
        exit 1
    fi
    
    # Body is required for PR description
    if [[ -z "$BODY" ]]; then
        error "PR body is required. Use --body to specify."
        exit 1
    fi
    
    # Set default title if not provided
    if [[ -z "$TITLE" ]]; then
        TITLE="🚀 Release v$VERSION"
        debug "Using default title: $TITLE"
    fi
    
    # Determine repository if not provided
    if [[ -z "$REPOSITORY" ]]; then
        if command -v git >/dev/null 2>&1; then
            REPOSITORY=$(git remote get-url origin 2>/dev/null | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git.*/\1/' || echo "")
        fi
        if [[ -z "$REPOSITORY" ]]; then
            # Try to get from GitHub environment
            REPOSITORY="${GITHUB_REPOSITORY:-}"
        fi
        if [[ -z "$REPOSITORY" ]]; then
            error "Could not determine repository. Use --repository to specify."
            exit 1
        fi
        debug "Detected repository: $REPOSITORY"
    fi
    
    # Set default assignee to repository owner if not provided
    if [[ -z "$ASSIGNEE" ]]; then
        ASSIGNEE=$(echo "$REPOSITORY" | cut -d'/' -f1)
        debug "Using repository owner as assignee: $ASSIGNEE"
    fi
    
    debug "Parameters validated successfully"
}

check_github_cli() {
    debug "Checking GitHub CLI availability"
    
    if ! command -v gh >/dev/null 2>&1; then
        error "GitHub CLI (gh) is not installed or not in PATH"
        exit 2
    fi
    
    # Check if authenticated
    if ! gh auth status >/dev/null 2>&1; then
        error "GitHub CLI is not authenticated"
        exit 2
    fi
    
    debug "GitHub CLI is available and authenticated"
}

check_existing_pr() {
    debug "Checking for existing PR: $HEAD_BRANCH → $BASE_BRANCH"
    
    # If mock existing PR is provided, use it (for testing)
    if [[ -n "$MOCK_EXISTING_PR" ]]; then
        debug "Using mock existing PR: $MOCK_EXISTING_PR"
        echo "$MOCK_EXISTING_PR"
        return 0
    fi
    
    local pr_number
    local cmd="gh pr list --repo '$REPOSITORY' --base '$BASE_BRANCH' --head '$HEAD_BRANCH' --json number --jq '.[0].number // empty'"
    
    debug "Executing: $cmd"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        debug "[DRY RUN] Would check for existing PR"
        # For dry run with no mock, assume no existing PR
        echo ""
        return 0
    fi
    
    pr_number=$(eval "$cmd" 2>/dev/null || echo "")
    
    debug "PR check result: '$pr_number'"
    echo "$pr_number"
}

create_new_pr() {
    debug "Creating new PR: $HEAD_BRANCH → $BASE_BRANCH"
    
    local cmd="gh pr create"
    cmd+=" --repo '$REPOSITORY'"
    cmd+=" --base '$BASE_BRANCH'"
    cmd+=" --head '$HEAD_BRANCH'"
    cmd+=" --title '$TITLE'"
    cmd+=" --body '$BODY'"
    cmd+=" --label '$LABELS'"
    cmd+=" --assignee '$ASSIGNEE'"
    
    debug "Executing: $cmd"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would create PR with:"
        info "  Title: $TITLE"
        info "  Body: ${BODY:0:100}..."
        info "  Labels: $LABELS"
        info "  Assignee: $ASSIGNEE"
        # Return a fake URL for dry run
        echo "https://github.com/$REPOSITORY/pull/999"
        return 0
    fi
    
    local pr_url
    if pr_url=$(eval "$cmd" 2>&1); then
        debug "PR created successfully: $pr_url"
        echo "$pr_url"
        return 0
    else
        error "Failed to create PR: $pr_url"
        exit 3
    fi
}

update_existing_pr() {
    local pr_number="$1"
    
    debug "Updating existing PR #$pr_number"
    
    local cmd="gh pr edit '$pr_number'"
    cmd+=" --repo '$REPOSITORY'"
    cmd+=" --title '$TITLE'"
    cmd+=" --body '$BODY'"
    cmd+=" --add-label '$LABELS'"
    cmd+=" --add-assignee '$ASSIGNEE'"
    
    debug "Executing: $cmd"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would update PR #$pr_number with:"
        info "  Title: $TITLE"
        info "  Body: ${BODY:0:100}..."
        info "  Labels: $LABELS"
        info "  Assignee: $ASSIGNEE"
        return 0
    fi
    
    local result
    if result=$(eval "$cmd" 2>&1); then
        debug "PR updated successfully"
        return 0
    else
        error "Failed to update PR: $result"
        exit 3
    fi
}

extract_pr_number_from_url() {
    local pr_url="$1"
    
    # Extract number from end of URL (e.g., https://github.com/owner/repo/pull/123)
    local pr_number
    pr_number=$(echo "$pr_url" | grep -o '[0-9]\+$' || echo "")
    
    if [[ -z "$pr_number" ]]; then
        error "Could not extract PR number from URL: $pr_url"
        exit 3
    fi
    
    debug "Extracted PR number: $pr_number"
    echo "$pr_number"
}

generate_pr_url() {
    local pr_number="$1"
    
    echo "https://github.com/$REPOSITORY/pull/$pr_number"
}

output_results() {
    local action_taken="$1"
    local pr_number="$2" 
    local pr_url="$3"
    local exists="$4"
    
    debug "Outputting results in $OUTPUT_FORMAT format"
    
    if [[ "$OUTPUT_FORMAT" == "github-actions" ]]; then
        echo "pr_number=$pr_number"
        echo "pr_url=$pr_url"
        echo "action_taken=$action_taken"
        echo "exists=$exists"
    elif [[ "$OUTPUT_FORMAT" == "json" ]]; then
        cat << EOF
{
  "pr_number": $pr_number,
  "pr_url": "$pr_url",
  "action_taken": "$action_taken",
  "exists": $exists
}
EOF
    fi
}

main() {
    parse_args "$@"
    
    debug "Starting release PR management"
    debug "Version: $VERSION"
    debug "Base: $BASE_BRANCH → Head: $HEAD_BRANCH"
    debug "Repository: $REPOSITORY"
    debug "Dry run: $DRY_RUN"
    
    # Validate inputs
    validate_parameters
    
    # Check GitHub CLI
    check_github_cli
    
    # Check for existing PR
    info "Checking for existing PR..."
    local existing_pr_number
    existing_pr_number=$(check_existing_pr)
    
    local action_taken=""
    local pr_number=""
    local pr_url=""
    local exists="false"
    
    if [[ -n "$existing_pr_number" ]]; then
        # Update existing PR
        exists="true"
        action_taken="updated"
        pr_number="$existing_pr_number"
        pr_url=$(generate_pr_url "$pr_number")
        
        info "Found existing PR #$pr_number, updating..."
        update_existing_pr "$pr_number"
        success "Updated existing PR #$pr_number"
        
    else
        # Create new PR
        exists="false"
        action_taken="created"
        
        info "No existing PR found, creating new PR..."
        local new_pr_url
        new_pr_url=$(create_new_pr)
        pr_url="$new_pr_url"
        pr_number=$(extract_pr_number_from_url "$pr_url")
        
        success "Created new PR #$pr_number"
    fi
    
    # Output results
    output_results "$action_taken" "$pr_number" "$pr_url" "$exists"
    
    debug "Release PR management completed successfully"
    
    return 0
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 