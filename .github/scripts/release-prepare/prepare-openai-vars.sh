#!/usr/bin/env bash
set -euo pipefail

# Script to prepare variables for OpenAI changelog generation
# This script handles complex multi-line string processing, escaping, and base64 encoding

# Validate required environment variables or command line arguments
VERSION="${VERSION:-}"
COMMITS_INPUT="${COMMITS_INPUT:-}"

if [[ -z "$VERSION" ]]; then
    echo "ERROR: VERSION environment variable is required"
    echo "Usage: Set VERSION environment variable with the release version"
    exit 1
fi

if [[ -z "$COMMITS_INPUT" ]]; then
    echo "ERROR: COMMITS_INPUT environment variable is required"
    echo "Usage: Set COMMITS_INPUT environment variable with commit messages"
    exit 1
fi

# Create temporary file for safe multi-line content handling
COMMITS_TEMP_FILE=$(mktemp)
trap 'rm -f "$COMMITS_TEMP_FILE"' EXIT

echo "=== OpenAI Variables Preparation Debug ==="
echo "Version: $VERSION"
echo "Commits input length: ${#COMMITS_INPUT}"
echo "Date: $(date +%Y-%m-%d)"
echo "============================================"

# Save commits to temporary file to handle multi-line content safely
cat > "$COMMITS_TEMP_FILE" <<EOF
$COMMITS_INPUT
EOF

echo "Commits saved to temporary file ($(wc -l < "$COMMITS_TEMP_FILE") lines)"

# Read commits and escape for simple KEY=VALUE format
# Replace newlines with ASCII control character \020 and escape quotes
COMMITS_ESCAPED=$(cat "$COMMITS_TEMP_FILE" | tr '\n' '\020' | sed 's/"/\\"/g')

echo "Commits escaped successfully (length: ${#COMMITS_ESCAPED})"

# Create variables in a single line format for safe GitHub Actions passing
TEMPLATE_VARS="VERSION=$VERSION
COMMITS=${COMMITS_ESCAPED}
DATE=$(date +%Y-%m-%d)"

echo "Template variables created:"
echo "  VERSION=$VERSION"
echo "  COMMITS=[${#COMMITS_ESCAPED} chars]"
echo "  DATE=$(date +%Y-%m-%d)"

# Encode the entire vars block as base64 to avoid shell parsing issues
VARS_ENCODED=$(echo "$TEMPLATE_VARS" | base64 -w 0)

echo "Variables encoded to base64 successfully (length: ${#VARS_ENCODED})"

# Output the base64 encoded variables
echo "template_vars=${VARS_ENCODED}"

echo "✅ OpenAI variables preparation completed successfully" 