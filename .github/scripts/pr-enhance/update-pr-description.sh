#!/usr/bin/env bash
set -euo pipefail

# Script to update PR description with AI-generated content
# This script determines which content to use (formatted vs raw) and updates the PR description

# Validate required environment variables
if [[ ! -v RAW_CONTENT ]]; then
    echo "ERROR: RAW_CONTENT environment variable is required"
    exit 1
fi

if [[ ! -v FORMATTED_CONTENT ]]; then
    echo "ERROR: FORMATTED_CONTENT environment variable is required"
    exit 1
fi

if [[ -z "${PR_NUMBER:-}" ]]; then
    echo "ERROR: PR_NUMBER environment variable is required"
    exit 1
fi

if [[ -z "${GH_TOKEN:-}" ]]; then
    echo "ERROR: GH_TOKEN environment variable is required"
    exit 1
fi

# Debug output to understand what we received
echo "=== AI Output Debug ==="
echo "Raw content length: $(printf '%s' "$RAW_CONTENT" | wc -c)"
echo "Formatted content length: $(printf '%s' "$FORMATTED_CONTENT" | wc -c)"
echo "======================="

# Write AI outputs to temporary files first
printf '%s' "$FORMATTED_CONTENT" > formatted_temp.md
printf '%s' "$RAW_CONTENT" > raw_temp.md

# Determine which content to use based on file size and content
if [ -s formatted_temp.md ] && [ "$(head -c 4 formatted_temp.md)" != "null" ]; then
    echo "Using formatted content"
    cp formatted_temp.md final.md
elif [ -s raw_temp.md ] && [ "$(head -c 4 raw_temp.md)" != "null" ]; then
    echo "Using raw content"
    cp raw_temp.md final.md
else
    echo "No AI content available, using original PR body"
    if [[ -f pr_body.txt ]]; then
        cp pr_body.txt final.md
    else
        echo "WARNING: No pr_body.txt found, creating minimal content"
        echo "PR description not available" > final.md
    fi
fi

# Clean up temporary files
rm -f formatted_temp.md raw_temp.md

# Verify we have content before updating
if [ -s final.md ]; then
    echo "Updating PR description with $(wc -l < final.md) lines"
    gh pr edit "$PR_NUMBER" --body-file final.md
    
    # Only clean up if not in test mode
    if [[ "${TEST_MODE:-}" != "true" ]]; then
        rm -f final.md
    fi
else
    echo "ERROR: No content to write, keeping original description"
    exit 1
fi 