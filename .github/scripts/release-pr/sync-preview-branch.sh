#!/usr/bin/env bash
set -euo pipefail

# Script to ensure the latest preview branch state is synchronized
# This script waits for any final pushes and force fetches the latest state

# Wait longer for any final pushes to complete (increased from 5 to 10 seconds)
echo "⏱️ Waiting 10 seconds for release-prepare pushes to complete..."
sleep 10

# Force fetch the latest state
echo "🔄 Fetching latest preview branch state..."
git fetch origin preview --force
git reset --hard origin/preview

# Debug output
echo "=== Current Repository State ==="
echo "Current commit: $(git rev-parse HEAD)"
echo "Latest origin/preview: $(git rev-parse origin/preview)"
echo "Last commit message: $(git log -1 --pretty=format:'%s')"
echo "Current version: $(node -p "require('./package.json').version")"
echo "First changelog header: $(head -15 CHANGELOG.md | grep "^## \\[" | head -1)"
echo "Total changelog entries: $(grep "^## \\[" CHANGELOG.md | wc -l)" 