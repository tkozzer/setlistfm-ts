#!/usr/bin/env bash
set -euo pipefail

# Script to verify that the last commit is a proper release preparation commit
# This script validates the commit format and cross-checks version consistency

# Get the latest commit message
LAST_COMMIT=$(git log -1 --pretty=format:'%s')
echo "Latest commit: $LAST_COMMIT"

# Check if it matches the expected format: chore(release): v{version} – update changelog
if [[ "$LAST_COMMIT" =~ ^chore\(release\):\ v[0-9]+\.[0-9]+\.[0-9]+.*update\ changelog ]]; then
  echo "✅ Release preparation commit verified!"
  
  # Extract version from commit message
  COMMIT_VERSION=$(echo "$LAST_COMMIT" | sed -E 's/^chore\(release\): v([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')
  echo "Version from commit: $COMMIT_VERSION"
  
  # Cross-validate with package.json version
  PACKAGE_VERSION=$(node -p "require('./package.json').version")
  echo "Version from package.json: $PACKAGE_VERSION"
  
  if [[ "$COMMIT_VERSION" == "$PACKAGE_VERSION" ]]; then
    echo "✅ Version consistency verified!"
    exit 0
  else
    echo "❌ ERROR: Version mismatch detected!"
    echo "Commit version: $COMMIT_VERSION"
    echo "Package.json version: $PACKAGE_VERSION"
    echo "This indicates a synchronization issue in the release-prepare workflow."
    exit 1
  fi
else
  echo "❌ ERROR: Expected release preparation commit not found!"
  echo "Expected format: 'chore(release): v{version} – update changelog'"
  echo "Actual commit: $LAST_COMMIT"
  echo ""
  echo "This indicates that the release-prepare workflow did not complete successfully."
  echo "Please check the release-prepare workflow logs and ensure it completed before this workflow runs."
  exit 1
fi 