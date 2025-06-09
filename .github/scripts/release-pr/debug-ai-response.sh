#!/usr/bin/env bash

###############################################################################
# Debug AI Response Script
#
# This script safely displays AI response content for debugging purposes,
# handling special characters, quotes, and multiline content that could
# break shell parsing in GitHub Actions workflows.
#
# Author: tkozzer
# Module: release-pr
###############################################################################

set -euo pipefail

# Default values
CONTENT=""
TITLE="AI RESPONSE"
MAX_CHARS=500
VERBOSE=false

# Help function
show_help() {
    cat << EOF
Debug AI Response Script

USAGE:
    $0 [OPTIONS]

DESCRIPTION:
    Safely displays AI response content for debugging, handling special
    characters and multiline content that could break shell parsing.

OPTIONS:
    --content TEXT        AI response content to debug (required)
    --title TEXT          Section title for debug output (default: "AI RESPONSE")
    --max-chars NUM       Maximum characters to show in preview (default: 500)
    --verbose             Show additional debug information
    --help               Show this help message

EXAMPLES:
    # Basic usage
    $0 --content "## Release v1.0.0\\nWhat's new in this release..."
    
    # With custom title and length
    $0 --content "\$content" --title "PR DESCRIPTION" --max-chars 800
    
    # Verbose mode
    $0 --content "\$content" --verbose

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --content)
                CONTENT="$2"
                shift 2
                ;;
            --title)
                TITLE="$2"
                shift 2
                ;;
            --max-chars)
                MAX_CHARS="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "❌ Unknown option: $1" >&2
                echo "Use --help for usage information." >&2
                exit 1
                ;;
        esac
    done
}

# Validate inputs
validate_inputs() {
    if [[ -z "$CONTENT" ]]; then
        echo "❌ Error: --content is required" >&2
        echo "Use --help for usage information." >&2
        exit 1
    fi
    
    if ! [[ "$MAX_CHARS" =~ ^[0-9]+$ ]] || [[ "$MAX_CHARS" -lt 1 ]]; then
        echo "❌ Error: --max-chars must be a positive integer" >&2
        exit 1
    fi
}

# Safe character count function
safe_char_count() {
    local text="$1"
    # Use printf to safely handle special characters
    printf '%s' "$text" | wc -c
}

# Safe substring function that handles special characters
safe_substring() {
    local text="$1"
    local max_chars="$2"
    
    # Use printf and head to safely extract substring
    printf '%s' "$text" | head -c "$max_chars"
}

# Safe line count function
safe_line_count() {
    local text="$1"
    # Count lines safely
    printf '%s' "$text" | wc -l
}

# Main debug function
debug_ai_response() {
    local char_count
    local line_count
    local preview_content
    
    # Calculate metrics safely
    char_count=$(safe_char_count "$CONTENT")
    line_count=$(safe_line_count "$CONTENT")
    preview_content=$(safe_substring "$CONTENT" "$MAX_CHARS")
    
    # Display debug information
    echo "=== $TITLE ==="
    echo "Content length: $char_count chars"
    echo "Content lines: $line_count lines"
    
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Preview length: $MAX_CHARS chars"
        echo "Content type: $(detect_content_type "$CONTENT")"
        echo "Special characters detected: $(detect_special_chars "$CONTENT")"
    fi
    
    echo "First $MAX_CHARS chars:"
    echo "--- Content Preview ---"
    
    # Use printf for safe output that handles special characters
    printf '%s' "$preview_content"
    
    # Add ellipsis if content was truncated
    if [[ "$char_count" -gt "$MAX_CHARS" ]]; then
        echo ""
        echo "..."
        echo "(truncated - showing $MAX_CHARS of $char_count chars)"
    else
        echo ""
    fi
    
    echo "--- End Preview ---"
    echo "================="
}

# Detect content type (JSON, Markdown, etc.)
detect_content_type() {
    local content="$1"
    
    # Check if it's JSON
    if printf '%s' "$content" | jq . >/dev/null 2>&1; then
        echo "JSON"
        return
    fi
    
    # Check if it starts with markdown headers
    if printf '%s' "$content" | head -n 1 | grep -q '^#'; then
        echo "Markdown"
        return
    fi
    
    echo "Text"
}

# Detect potentially problematic special characters
detect_special_chars() {
    local content="$1"
    local detected=()
    
    # Check for single quotes/apostrophes
    if printf '%s' "$content" | grep -q "'"; then
        detected+=("single-quotes")
    fi
    
    # Check for double quotes
    if printf '%s' "$content" | grep -q '"'; then
        detected+=("double-quotes")
    fi
    
    # Check for backticks
    if printf '%s' "$content" | grep -q '`'; then
        detected+=("backticks")
    fi
    
    # Check for backslashes
    if printf '%s' "$content" | grep -q '\\'; then
        detected+=("backslashes")
    fi
    
    # Check for newlines
    if printf '%s' "$content" | grep -q $'\n'; then
        detected+=("newlines")
    fi
    
    # Return comma-separated list or "none"
    if [[ ${#detected[@]} -eq 0 ]]; then
        echo "none"
    else
        IFS=, eval 'echo "${detected[*]}"'
    fi
}

# Main execution
main() {
    parse_args "$@"
    validate_inputs
    debug_ai_response
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 