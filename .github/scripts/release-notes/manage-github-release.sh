#!/usr/bin/env bash

#
# @file manage-github-release.sh
# @description Manages GitHub release creation and updates for setlistfm-ts releases.
# @author tkozzer
# @module release-notes
#

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
VERBOSE=false
VERIFY_TAG=false

usage() {
    cat << EOF
Usage: $0 [OPTIONS] --version VERSION --notes-file NOTES_FILE

Manages GitHub release creation and updates for setlistfm-ts.

Options:
    --version VERSION       Target version (e.g., 1.2.3)
    --notes-file FILE       Path to release notes markdown file
    --github-token TOKEN    GitHub token (or set GH_TOKEN env var)
    --dry-run              Show what would be done without executing
    --verify-tag           Verify git tag exists before creating release
    --verbose              Enable verbose output
    --help                 Show this help message

Environment Variables:
    GH_TOKEN               GitHub token for authentication

Examples:
    $0 --version 1.2.3 --notes-file release-notes.md
    $0 --version 1.2.3 --notes-file release-notes.md --dry-run
    $0 --version 1.2.3 --notes-file release-notes.md --verify-tag

EOF
}

log() {
    local level="$1"
    shift
    case "$level" in
        "ERROR")
            echo -e "${RED}❌ ERROR: $*${NC}" >&2
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ SUCCESS: $*${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $*${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO: $*${NC}"
            ;;
        "VERBOSE")
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${BLUE}🔍 VERBOSE: $*${NC}"
            fi
            ;;
    esac
}

validate_inputs() {
    local errors=()

    # Check required parameters
    if [[ -z "${VERSION:-}" ]]; then
        errors+=("Version is required")
    fi

    if [[ -z "${NOTES_FILE:-}" ]]; then
        errors+=("Notes file is required")
    fi

    # Validate version format (semver)
    if [[ -n "${VERSION:-}" ]] && ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
        errors+=("Version must be valid semver format (e.g., 1.2.3, 1.2.3-beta.1)")
    fi

    # Check notes file exists and is readable
    if [[ -n "${NOTES_FILE:-}" ]] && [[ ! -f "$NOTES_FILE" ]]; then
        errors+=("Release notes file does not exist: $NOTES_FILE")
    fi

    if [[ -n "${NOTES_FILE:-}" ]] && [[ ! -r "$NOTES_FILE" ]]; then
        errors+=("Release notes file is not readable: $NOTES_FILE")
    fi

    # Check GitHub token
    if [[ -z "${GH_TOKEN:-}" ]]; then
        errors+=("GitHub token is required (set GH_TOKEN environment variable or use --github-token)")
    fi

    # Check gh CLI is available (skip in test mode)
    if [[ "${TESTING_MODE:-}" != "true" ]] && ! command -v gh &> /dev/null; then
        errors+=("GitHub CLI (gh) is not installed or not in PATH")
    fi

    if [[ ${#errors[@]} -gt 0 ]]; then
        log "ERROR" "Validation failed:"
        for error in "${errors[@]}"; do
            echo "  - $error" >&2
        done
        exit 1
    fi

    log "VERBOSE" "Input validation passed"
}

validate_notes_content() {
    local notes_file="$1"
    local version="$2"
    
    log "VERBOSE" "Validating release notes content"
    
    # Check file is not empty
    if [[ ! -s "$notes_file" ]]; then
        log "WARNING" "Release notes file is empty"
        return 1
    fi
    
    # Check for basic markdown structure
    if ! grep -q "^#" "$notes_file"; then
        log "WARNING" "Release notes may not have proper markdown headers"
    fi
    
    # Check if version is mentioned in the notes
    if ! grep -q "$version" "$notes_file"; then
        log "WARNING" "Version $version not found in release notes"
    fi
    
    # Check for setlistfm-ts mention (from original validation)
    if ! grep -q "setlistfm-ts" "$notes_file"; then
        log "ERROR" "Release notes must mention 'setlistfm-ts'"
        return 1
    fi
    
    log "VERBOSE" "Release notes content validation passed"
    return 0
}

check_git_tag() {
    local version="$1"
    local tag="v$version"
    
    log "VERBOSE" "Checking if git tag $tag exists"
    
    if git rev-parse "$tag" >/dev/null 2>&1; then
        log "VERBOSE" "Git tag $tag exists"
        return 0
    else
        log "ERROR" "Git tag $tag does not exist"
        return 1
    fi
}

check_release_exists() {
    local version="$1"
    local tag="v$version"
    
    log "VERBOSE" "Checking if GitHub release $tag already exists"
    
    if gh release view "$tag" >/dev/null 2>&1; then
        log "VERBOSE" "GitHub release $tag already exists"
        return 0
    else
        log "VERBOSE" "GitHub release $tag does not exist"
        return 1
    fi
}

create_github_release() {
    local version="$1"
    local notes_file="$2"
    local tag="v$version"
    
    log "INFO" "Creating GitHub release $tag"
    
    local cmd_args=(
        "gh" "release" "create" "$tag"
        "--title" "$tag"
        "--notes-file" "$notes_file"
    )
    
    # Add verify-tag flag if requested
    if [[ "$VERIFY_TAG" == "false" ]]; then
        cmd_args+=("--verify-tag=false")
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY RUN: Would execute: ${cmd_args[*]}"
        return 0
    fi
    
    log "VERBOSE" "Executing: ${cmd_args[*]}"
    
    if "${cmd_args[@]}"; then
        log "SUCCESS" "Created GitHub release $tag"
        return 0
    else
        log "ERROR" "Failed to create GitHub release $tag"
        return 1
    fi
}

update_github_release() {
    local version="$1"
    local notes_file="$2"
    local tag="v$version"
    
    log "INFO" "Updating GitHub release $tag"
    
    local cmd_args=(
        "gh" "release" "edit" "$tag"
        "--title" "$tag"
        "--notes-file" "$notes_file"
    )
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY RUN: Would execute: ${cmd_args[*]}"
        return 0
    fi
    
    log "VERBOSE" "Executing: ${cmd_args[*]}"
    
    if "${cmd_args[@]}"; then
        log "SUCCESS" "Updated GitHub release $tag"
        return 0
    else
        log "ERROR" "Failed to update GitHub release $tag"
        return 1
    fi
}

manage_release() {
    local version="$1"
    local notes_file="$2"
    
    # Validate notes content
    if ! validate_notes_content "$notes_file" "$version"; then
        exit 1
    fi
    
    # Check git tag if verification is enabled
    if [[ "$VERIFY_TAG" == "true" ]]; then
        if ! check_git_tag "$version"; then
            exit 1
        fi
    fi
    
    # Determine if we need to create or update
    if check_release_exists "$version"; then
        log "INFO" "Release exists, updating..."
        if ! update_github_release "$version" "$notes_file"; then
            exit 1
        fi
    else
        log "INFO" "Release does not exist, creating..."
        if ! create_github_release "$version" "$notes_file"; then
            # If create fails, try update as fallback (matches original workflow logic)
            log "WARNING" "Create failed, attempting update as fallback..."
            if ! update_github_release "$version" "$notes_file"; then
                exit 1
            fi
        fi
    fi
}

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                VERSION="$2"
                shift 2
                ;;
            --notes-file)
                NOTES_FILE="$2"
                shift 2
                ;;
            --github-token)
                GH_TOKEN="$2"
                export GH_TOKEN
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verify-tag)
                VERIFY_TAG=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Validate inputs
    validate_inputs
    
    # Execute main logic
    manage_release "$VERSION" "$NOTES_FILE"
    
    log "SUCCESS" "GitHub release management completed successfully"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 