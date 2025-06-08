#!/usr/bin/env bash
set -euo pipefail

# Script to update CHANGELOG.md with new release entry
# This script handles the logic for inserting a new changelog entry

# Validate required environment variables
if [[ -z "${VERSION:-}" ]]; then
    echo "ERROR: VERSION environment variable is required"
    exit 1
fi

if [[ -z "${DATE:-}" ]]; then
    echo "ERROR: DATE environment variable is required"
    exit 1
fi

# Validate required files
if [[ ! -f CHANGELOG.md ]]; then
    echo "ERROR: CHANGELOG.md file not found"
    exit 1
fi

# Get content from environment variables or parameters
FORMATTED_CONTENT="${FORMATTED_CONTENT:-}"
RAW_CONTENT="${RAW_CONTENT:-}"

echo "=== Changelog Update Debug ==="
echo "Version: $VERSION"
echo "Date: $DATE"
echo "Formatted content available: $([ -n "$FORMATTED_CONTENT" ] && echo "yes" || echo "no")"
echo "Raw content available: $([ -n "$RAW_CONTENT" ] && echo "yes" || echo "no")"
echo "=============================="

# Use environment variables to safely handle multi-line content
if [ -n "${FORMATTED_CONTENT}" ] && [ "${FORMATTED_CONTENT}" != "null" ]; then
    echo "Using formatted content for changelog entry"
    echo "${FORMATTED_CONTENT}" > changelog_entry.txt
elif [ -n "${RAW_CONTENT}" ] && [ "${RAW_CONTENT}" != "null" ]; then
    echo "Using raw content for changelog entry"
    echo "${RAW_CONTENT}" > changelog_entry.txt
else
    echo "Using fallback content for changelog entry"
    # Fallback if OpenAI fails completely
    echo "## [${VERSION}] - ${DATE}" > changelog_entry.txt
    echo "" >> changelog_entry.txt
    echo "### Changed" >> changelog_entry.txt
    echo "" >> changelog_entry.txt
    echo "- Release notes generation failed. Please refer to commit history for details." >> changelog_entry.txt
fi

# Add separator after the entry
echo "" >> changelog_entry.txt
echo "---" >> changelog_entry.txt
echo "" >> changelog_entry.txt

echo "Generated changelog entry (first 5 lines):"
head -5 changelog_entry.txt

# Insert the new entry after the --- separator (line 5) and before the first version entry
{ head -n 5 CHANGELOG.md; echo ""; cat changelog_entry.txt; tail -n +6 CHANGELOG.md; } > CHANGELOG.tmp
mv CHANGELOG.tmp CHANGELOG.md

# Verify the update was successful
if grep -q "## \[${VERSION}\] - ${DATE}" CHANGELOG.md; then
    echo "✅ Successfully updated CHANGELOG.md with version ${VERSION}"
else
    echo "❌ Failed to update CHANGELOG.md"
    exit 1
fi

# Clean up
rm changelog_entry.txt 