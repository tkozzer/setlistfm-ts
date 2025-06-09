#!/bin/bash

###
# Debug Variables Script for Release PR Workflow
# 
# Safely outputs debug information about version and changelog variables
# without shell parsing errors when content contains special characters.
###

set -euo pipefail

# Default values
VERSION=""
CHANGELOG=""
MAX_CHARS=800
TITLE="VARIABLES"
VERBOSE=false

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]
Debug version and changelog variables safely.

OPTIONS:
    --version VALUE         Version string to display
    --changelog VALUE       Changelog content to display  
    --max-chars NUM         Maximum characters to show (default: 800)
    --title TEXT           Debug section title (default: VARIABLES)
    --verbose              Enable verbose output
    -h, --help             Show this help message

EXAMPLES:
    $0 --version "1.0.0" --changelog "### Fixed\n- Bug fixes"
    $0 --version "1.0.0" --changelog "\$(cat CHANGELOG.md)" --max-chars 500
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --changelog)
            CHANGELOG="$2"
            shift 2
            ;;
        --max-chars)
            MAX_CHARS="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$VERSION" ]]; then
    echo "Error: --version is required" >&2
    exit 1
fi

if [[ -z "$CHANGELOG" ]]; then
    echo "Error: --changelog is required" >&2
    exit 1
fi

# Validate max-chars is a number
if ! [[ "$MAX_CHARS" =~ ^[0-9]+$ ]]; then
    echo "Error: --max-chars must be a positive integer" >&2
    exit 1
fi

# Verbose logging
if [[ "$VERBOSE" == "true" ]]; then
    echo "Debug: VERSION='$VERSION'" >&2
    echo "Debug: CHANGELOG length=$(printf '%s' "$CHANGELOG" | wc -c)" >&2
    echo "Debug: MAX_CHARS=$MAX_CHARS" >&2
    echo "Debug: TITLE='$TITLE'" >&2
fi

# Calculate changelog length safely
CHANGELOG_LENGTH=$(printf '%s' "$CHANGELOG" | wc -c)

# Output debug information
echo "=== $TITLE ==="
echo "VERSION=$VERSION"
echo ""
printf "CHANGELOG (length: %s chars):\n" "$CHANGELOG_LENGTH"
echo "--- First $MAX_CHARS chars ---"

# Safely output changelog content with character limit
printf '%s' "$CHANGELOG" | head -c "$MAX_CHARS"

echo ""
echo "--- End of preview ---"
echo "==================" 