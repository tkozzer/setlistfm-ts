#!/usr/bin/env bash
set -euo pipefail

# Script to determine semver bump type based on commit messages
# This script analyzes commit messages and determines whether a major, minor, or patch version bump is needed

# Validate required environment variables or command line arguments
COMMITS_INPUT=""
if [[ $# -gt 0 ]]; then
    COMMITS_INPUT="$1"
elif [[ -n "${RAW:-}" ]]; then
    COMMITS_INPUT="$RAW"
fi

if [[ -z "$COMMITS_INPUT" ]]; then
    echo "ERROR: Commit messages input is required" >&2
    echo "Usage: $0 <commits_text>" >&2
    echo "   OR: Set RAW environment variable with commit messages" >&2
    exit 1
fi

# Create temporary file for commit analysis
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

echo "=== Semver Bump Analysis Debug ===" >&2
echo "Input commits length: ${#COMMITS_INPUT}" >&2
echo "Analyzing commit messages for semver bump type..." >&2
echo "==================================" >&2

# Write commits to temporary file for pattern matching
echo "$COMMITS_INPUT" > "$TEMP_FILE"

# Check for breaking changes (major version bump)
# Patterns: "BREAKING CHANGE:" or "!:" anywhere in commits
if grep -Eq '(^|[\n])BREAKING CHANGE:|!:' "$TEMP_FILE"; then
    echo "🔴 MAJOR bump detected: Breaking change found" >&2
    echo "type=major"
    exit 0
fi

# Check for new features (minor version bump)  
# Pattern: commit hash followed by "feat(" or "feat:"
if grep -Eq '^[a-f0-9]+ feat(\(|:)' "$TEMP_FILE"; then
    echo "🟡 MINOR bump detected: New feature found" >&2
    echo "type=minor"
    exit 0
fi

# Default to patch version bump
# For bug fixes, docs, refactor, etc.
echo "🟢 PATCH bump detected: No breaking changes or features found" >&2
echo "type=patch" 