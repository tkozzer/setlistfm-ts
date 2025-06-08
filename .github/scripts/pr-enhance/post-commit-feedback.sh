#!/usr/bin/env bash

# 📊 PR Commit Quality Feedback Script
# 
# Posts a detailed comment about commit message quality on a PR.
# Extracted from .github/workflows/pr-enhance.yml for better testability.
#
# Usage: post-commit-feedback.sh --conventional N --total N --pr-number N [options]
#
# Arguments:
#   --conventional N    Number of conventional commits
#   --total N          Total number of commits
#   --pr-number N      Pull request number
#   --threshold N      Percentage threshold for good practices (default: 80)
#   --repo OWNER/REPO  Repository in format owner/repo (default: from git remote)
#   --dry-run          Show what would be done without making changes
#   --verbose          Enable verbose output
#   --help             Show this help message
#
# Environment Variables:
#   GH_TOKEN           GitHub token for authentication (required)
#   GITHUB_REPOSITORY  Repository context (owner/repo format)
#
# Output: Posts a comment with commit quality feedback and statistics
#
# Examples:
#   post-commit-feedback.sh --conventional 8 --total 10 --pr-number 123
#   post-commit-feedback.sh --conventional 3 --total 5 --pr-number 456 --threshold 60
#   post-commit-feedback.sh --conventional 0 --total 2 --pr-number 789 --dry-run
#

set -euo pipefail

# Default values
CONVENTIONAL_COUNT=""
TOTAL_COUNT=""
PR_NUMBER=""
THRESHOLD=80
REPOSITORY=""
DRY_RUN=false
VERBOSE=false
HELP=false

# Logging functions
log_info() {
    echo "ℹ️  $*" >&2
}

log_verbose() {
    if [[ $VERBOSE == "true" ]]; then
        echo "🔍 $*" >&2
    fi
}

log_error() {
    echo "❌ Error: $*" >&2
}

log_success() {
    echo "✅ $*" >&2
}

log_dry_run() {
    echo "🔍 [DRY RUN] $*" >&2
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --conventional)
            CONVENTIONAL_COUNT="$2"
            shift 2
            ;;
        --total)
            TOTAL_COUNT="$2"
            shift 2
            ;;
        --pr-number)
            PR_NUMBER="$2"
            shift 2
            ;;
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --repo)
            REPOSITORY="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            HELP=true
            shift
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Show help if requested
if [[ $HELP == "true" ]]; then
    grep "^#" "$0" | grep -v "^#!/" | sed 's/^# //' | sed 's/^#//'
    exit 0
fi

# Validate required arguments
if [[ -z "$CONVENTIONAL_COUNT" ]]; then
    log_error "Conventional commit count is required. Use --conventional N"
    exit 1
fi

if [[ -z "$TOTAL_COUNT" ]]; then
    log_error "Total commit count is required. Use --total N"
    exit 1
fi

if [[ -z "$PR_NUMBER" ]]; then
    log_error "PR number is required. Use --pr-number N"
    exit 1
fi

# Validate numeric inputs
if ! [[ "$CONVENTIONAL_COUNT" =~ ^[0-9]+$ ]]; then
    log_error "Conventional count must be a non-negative integer"
    exit 1
fi

if ! [[ "$TOTAL_COUNT" =~ ^[0-9]+$ ]]; then
    log_error "Total count must be a non-negative integer"
    exit 1
fi

if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    log_error "PR number must be a positive integer"
    exit 1
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    log_error "Threshold must be a non-negative integer"
    exit 1
fi

# Validate logical constraints
if [[ $THRESHOLD -lt 0 || $THRESHOLD -gt 100 ]]; then
    log_error "Threshold must be between 0 and 100"
    exit 1
fi

if [[ $CONVENTIONAL_COUNT -gt $TOTAL_COUNT ]]; then
    log_error "Conventional commit count cannot exceed total commit count"
    exit 1
fi

# Validate GitHub token
if [[ -z "${GH_TOKEN:-}" ]]; then
    log_error "GH_TOKEN environment variable is required"
    exit 1
fi

# Determine repository
if [[ -z "$REPOSITORY" ]]; then
    if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
        REPOSITORY="$GITHUB_REPOSITORY"
    else
        # Try to get from git remote
        if git remote get-url origin >/dev/null 2>&1; then
            REPOSITORY=$(git remote get-url origin | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?$|\1|')
        else
            log_error "Could not determine repository. Use --repo owner/repo or set GITHUB_REPOSITORY"
            exit 1
        fi
    fi
fi

log_verbose "Repository: $REPOSITORY"
log_verbose "PR Number: $PR_NUMBER"
log_verbose "Conventional Commits: $CONVENTIONAL_COUNT"
log_verbose "Total Commits: $TOTAL_COUNT"
log_verbose "Threshold: $THRESHOLD%"

# Function to calculate percentage
calculate_percentage() {
    local conventional="$1"
    local total="$2"
    
    if [[ $total -eq 0 ]]; then
        echo "0"
        return
    fi
    
    # Use awk for percentage calculation (same logic as workflow)
    awk "BEGIN {printf \"%.0f\", ($conventional / $total) * 100}"
}

# Function to determine feedback message and emoji
determine_feedback() {
    local percentage="$1"
    local threshold="$2"
    
    if [[ $percentage -ge $threshold ]]; then
        echo "GOOD"
    else
        echo "NEEDS_IMPROVEMENT"
    fi
}

# Function to generate commit feedback content
generate_feedback_content() {
    local conventional_count="$1"
    local total_count="$2"
    local percentage="$3"
    local feedback_type="$4"
    
    # Determine message and emoji based on feedback type
    local feedback_message emoji
    if [[ $feedback_type == "GOOD" ]]; then
        feedback_message="🎉 **Great work!** Your commit messages follow our conventional format consistently."
        emoji="🎸"
    else
        feedback_message="💡 **Needs improvement** - Consider following our [Conventional Commits](https://www.conventionalcommits.org/) format more consistently."
        emoji="📝"
    fi
    
    # Generate the complete feedback content
    cat <<EOF
## $emoji Commit Message Quality Report

**Conventional Commit Adherence:** **$conventional_count** out of **$total_count** commits (**$percentage%**)

$feedback_message

### Conventional Commit Examples:
- \`feat(api): add new endpoint for user profiles\`
- \`fix(ui): resolve button alignment issue\`
- \`docs(readme): update installation instructions\`
- \`refactor(utils): simplify error handling logic\`
- \`chore(deps): update dependencies to latest versions\`

**Why this helps:**
- 🤖 Automated changelog generation
- 📋 Clear understanding of changes at a glance
- 🔄 Better semantic versioning decisions
- 🚀 Improved project maintainability

**Reference:** Check out our [Contributing Guide](CONTRIBUTING.md#commit-messages) for more details.
EOF
}

# Function to post comment to GitHub
post_comment() {
    local pr_number="$1"
    local content="$2"
    local repository="$3"
    
    if [[ $DRY_RUN == "true" ]]; then
        log_dry_run "Would post comment to PR #$pr_number"
        log_dry_run "Comment content preview:"
        echo "$content" | sed 's/^/    /' >&2
        return 0
    fi
    
    # Create temporary file for comment content
    local temp_file
    temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    
    # Post comment using GitHub CLI
    if gh pr comment "$pr_number" \
        --body-file "$temp_file" \
        --repo "$repository" >/dev/null 2>&1; then
        log_success "Posted commit quality feedback to PR #$pr_number"
        rm -f "$temp_file"
        return 0
    else
        log_error "Failed to post comment to PR #$pr_number"
        rm -f "$temp_file"
        return 1
    fi
}

# Main execution
main() {
    if [[ $DRY_RUN == "true" ]]; then
        log_info "DRY RUN MODE - No changes will be made"
    fi
    
    log_verbose "Processing commit quality feedback for PR #$PR_NUMBER"
    
    # Only proceed if we have commits to analyze
    if [[ $TOTAL_COUNT -eq 0 ]]; then
        log_info "No commits to analyze (total count is 0)"
        if [[ $DRY_RUN == "true" ]]; then
            log_dry_run "Would skip posting feedback due to zero commits"
        fi
        exit 0
    fi
    
    # Calculate percentage
    local percentage
    percentage=$(calculate_percentage "$CONVENTIONAL_COUNT" "$TOTAL_COUNT")
    log_verbose "Calculated percentage: $percentage%"
    
    # Determine feedback type
    local feedback_type
    feedback_type=$(determine_feedback "$percentage" "$THRESHOLD")
    log_verbose "Feedback type: $feedback_type"
    
    # Generate feedback content
    local feedback_content
    feedback_content=$(generate_feedback_content "$CONVENTIONAL_COUNT" "$TOTAL_COUNT" "$percentage" "$feedback_type")
    
    # Post comment
    if post_comment "$PR_NUMBER" "$feedback_content" "$REPOSITORY"; then
        log_verbose "Posted commit quality feedback (${percentage}% conventional)"
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@" 