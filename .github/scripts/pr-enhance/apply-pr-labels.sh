#!/usr/bin/env bash

# 🏷️ PR Label Application & Auto-Assignment Script
# 
# Applies labels to a PR and assigns it to the repository owner.
# Extracted from .github/workflows/pr-enhance.yml for better testability.
#
# Usage: apply-pr-labels.sh --labels "label1 label2 label3" --pr-number N [options]
#
# Arguments:
#   --labels "list"     Space-separated list of labels to apply
#   --pr-number N       Pull request number
#   --assignee USER     User to assign PR to (default: repository owner from context)
#   --repo OWNER/REPO   Repository in format owner/repo (default: from git remote)
#   --dry-run           Show what would be done without making changes
#   --verbose           Enable verbose output
#   --help              Show this help message
#
# Environment Variables:
#   GH_TOKEN           GitHub token for authentication (required)
#   GITHUB_REPOSITORY  Repository context (owner/repo format)
#   GITHUB_REPOSITORY_OWNER  Repository owner for assignment
#
# Output: Success/failure status and applied labels information
#
# Examples:
#   apply-pr-labels.sh --labels "feature bugfix" --pr-number 123
#   apply-pr-labels.sh --labels "documentation" --pr-number 456 --assignee user
#   apply-pr-labels.sh --labels "feature testing" --pr-number 789 --dry-run
#

set -euo pipefail

# Default values
LABELS=""
PR_NUMBER=""
ASSIGNEE=""
REPOSITORY=""
DRY_RUN=false
VERBOSE=false
HELP=false

# Label definitions with colors and descriptions
# These match the original workflow logic exactly
declare -A LABEL_COLORS=(
    ["feature"]="0e8a16"
    ["bugfix"]="d73a4a"
    ["documentation"]="0075ca"
    ["maintenance"]="fbca04"
    ["refactor"]="1d76db"
    ["performance"]="ff6b6b"
    ["testing"]="ff9500"
    ["style"]="f9c74f"
    ["ci-cd"]="6f42c1"
    ["breaking-change"]="b60205"
    ["needs-review"]="fbca04"
)

declare -A LABEL_DESCRIPTIONS=(
    ["feature"]="New feature or enhancement"
    ["bugfix"]="Bug fix"
    ["documentation"]="Docs improvement"
    ["maintenance"]="Maintenance / chores"
    ["refactor"]="Code refactoring"
    ["performance"]="Performance improvement"
    ["testing"]="Testing related changes"
    ["style"]="Code style changes"
    ["ci-cd"]="CI/CD pipeline changes"
    ["breaking-change"]="Breaking change"
    ["needs-review"]="Needs commit-message review"
)

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
        --labels)
            LABELS="$2"
            shift 2
            ;;
        --pr-number)
            PR_NUMBER="$2"
            shift 2
            ;;
        --assignee)
            ASSIGNEE="$2"
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
if [[ -z "$LABELS" ]]; then
    log_error "Labels are required. Use --labels 'label1 label2 ...'"
    exit 1
fi

if [[ -z "$PR_NUMBER" ]]; then
    log_error "PR number is required. Use --pr-number N"
    exit 1
fi

if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    log_error "PR number must be a positive integer"
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

# Determine assignee
if [[ -z "$ASSIGNEE" ]]; then
    if [[ -n "${GITHUB_REPOSITORY_OWNER:-}" ]]; then
        ASSIGNEE="$GITHUB_REPOSITORY_OWNER"
    else
        # Extract owner from repository
        ASSIGNEE="${REPOSITORY%%/*}"
    fi
fi

log_verbose "Repository: $REPOSITORY"
log_verbose "PR Number: $PR_NUMBER"
log_verbose "Assignee: $ASSIGNEE"
log_verbose "Labels: $LABELS"

# Validate labels
for label in $LABELS; do
    if [[ -z "${LABEL_COLORS[$label]:-}" ]]; then
        log_error "Unknown label: $label"
        log_error "Supported labels: ${!LABEL_COLORS[*]}"
        exit 1
    fi
done

# Function to create a label (idempotent)
create_label() {
    local label="$1"
    local color="${LABEL_COLORS[$label]}"
    local description="${LABEL_DESCRIPTIONS[$label]}"
    
    log_verbose "Creating label '$label' with color '$color'"
    
    if [[ $DRY_RUN == "true" ]]; then
        log_dry_run "Would create label: $label (color: $color, desc: $description)"
        return 0
    fi
    
    # Create label (idempotent - won't fail if it exists)
    if gh label create "$label" \
        --color "$color" \
        --description "$description" \
        --repo "$REPOSITORY" \
        --force >/dev/null 2>&1; then
        log_verbose "Label '$label' created/updated"
    else
        log_verbose "Label '$label' creation failed (may already exist)"
    fi
}

# Function to apply labels and assign PR
apply_labels_and_assign() {
    local pr_number="$1"
    local labels="$2"
    local assignee="$3"
    
    # Build label arguments
    local label_args=""
    for label in $labels; do
        label_args="$label_args --add-label $label"
    done
    
    log_verbose "Applying labels and assigning PR $pr_number to $assignee"
    
    if [[ $DRY_RUN == "true" ]]; then
        log_dry_run "Would apply labels: $labels"
        log_dry_run "Would assign PR to: $assignee"
        return 0
    fi
    
    # Apply labels and assign PR
    if gh pr edit "$pr_number" \
        $label_args \
        --add-assignee "$assignee" \
        --repo "$REPOSITORY" >/dev/null 2>&1; then
        log_success "Applied labels and assigned PR $pr_number"
        return 0
    else
        log_error "Failed to apply labels or assign PR $pr_number"
        return 1
    fi
}

# Main execution
main() {
    if [[ $DRY_RUN == "true" ]]; then
        log_info "DRY RUN MODE - No changes will be made"
    fi
    
    log_info "Processing labels for PR #$PR_NUMBER"
    
    # Create all labels first
    for label in $LABELS; do
        create_label "$label"
    done
    
    # Apply labels and assign PR
    if apply_labels_and_assign "$PR_NUMBER" "$LABELS" "$ASSIGNEE"; then
        if [[ $DRY_RUN == "false" ]]; then
            log_success "Successfully applied labels: $LABELS"
            log_success "Successfully assigned PR to: $ASSIGNEE"
        fi
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@" 