#!/usr/bin/env bash
# --------------------------------------------------------------------------- #
#  📝  Extract Latest Changelog Entry                                         #
# --------------------------------------------------------------------------- #
# 
# Extracts the latest changelog entry from CHANGELOG.md for use in release
# PR descriptions. This script replaces the inline AWK logic from the 
# release-pr.yml workflow to improve testability and maintainability.
#
# Usage:
#   ./extract-changelog-entry.sh [OPTIONS]
#
# Options:
#   --file <path>     Path to changelog file (default: CHANGELOG.md)
#   --output-format   Format: 'github-actions' (default) or 'plain'
#   --debug          Enable debug output
#   --help           Show this help message
#
# GitHub Actions Output:
#   When --output-format=github-actions (default), outputs in the format:
#   entry<<EOF
#   <changelog content>
#   EOF
#
# Plain Output:
#   When --output-format=plain, outputs just the changelog content
#
# Exit Codes:
#   0 - Success
#   1 - Changelog file not found
#   2 - No changelog entries found
#   3 - Invalid changelog format
#
# Author: tkozzer
# --------------------------------------------------------------------------- #

set -euo pipefail

# Default configuration
CHANGELOG_FILE="CHANGELOG.md"
OUTPUT_FORMAT="github-actions"
DEBUG=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

debug() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${BLUE}[DEBUG] $*${NC}" >&2
    fi
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARN] $*${NC}" >&2
}

show_help() {
    sed -n '2,/^# Author:/p' "$0" | sed 's/^# //; s/^#//'
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --file)
                CHANGELOG_FILE="$2"
                shift 2
                ;;
            --output-format)
                OUTPUT_FORMAT="$2"
                if [[ "$OUTPUT_FORMAT" != "github-actions" && "$OUTPUT_FORMAT" != "plain" ]]; then
                    error "Invalid output format: $OUTPUT_FORMAT. Must be 'github-actions' or 'plain'"
                    exit 1
                fi
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
}

validate_changelog_file() {
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        error "Changelog file not found: $CHANGELOG_FILE"
        return 1
    fi
    
    debug "Found changelog file: $CHANGELOG_FILE"
    return 0
}

show_debug_headers() {
    if [[ "$DEBUG" == "true" ]]; then
        debug "First 3 changelog headers:"
        grep "^## \[" "$CHANGELOG_FILE" | head -3 | while read -r line; do
            debug "  $line"
        done
    fi
}

extract_changelog_entry() {
    local temp_file
    temp_file=$(mktemp)
    
    debug "Extracting changelog entry from: $CHANGELOG_FILE"
    
    # Check if file has any version headers
    if ! grep -q "^## \[" "$CHANGELOG_FILE"; then
        debug "No version headers found in changelog"
        echo "No changelog entries found for the latest version" > "$temp_file"
    else
        debug "Using AWK to extract content between first and second version headers"
        
        # Extract content between first and second ## [ headers, remove empty lines
        awk '
            /^## \[/ { 
                if (++count == 2) exit
                next 
            }
            count == 1 { print }
        ' "$CHANGELOG_FILE" | sed '/^$/d' > "$temp_file"
        
        # If no content was extracted, provide default message
        if [[ ! -s "$temp_file" ]]; then
            debug "No content found between version headers"
            echo "No changelog entries found for the latest version" > "$temp_file"
        fi
    fi
    
    # Show debug output of extracted content
    if [[ "$DEBUG" == "true" ]]; then
        debug "Extracted changelog entry (first 5 lines):"
        head -5 "$temp_file" | while read -r line; do
            debug "  $line"
        done
    fi
    
    # Output in requested format
    if [[ "$OUTPUT_FORMAT" == "github-actions" ]]; then
        debug "Outputting in GitHub Actions format"
        echo 'entry<<EOF'
        cat "$temp_file"
        echo 'EOF'
    else
        debug "Outputting in plain format"
        cat "$temp_file"
    fi
    
    # Cleanup
    rm -f "$temp_file"
    
    return 0
}

main() {
    parse_args "$@"
    
    debug "Starting changelog entry extraction"
    debug "Changelog file: $CHANGELOG_FILE"
    debug "Output format: $OUTPUT_FORMAT"
    
    # Validate inputs
    validate_changelog_file || exit 1
    
    # Show debug information
    show_debug_headers
    
    # Extract and output the changelog entry
    extract_changelog_entry || exit 2
    
    debug "Changelog entry extraction completed successfully"
    
    return 0
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 