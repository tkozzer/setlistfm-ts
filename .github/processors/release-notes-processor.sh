#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------------------------------- #
#  Release Notes Processor                                                    #
# --------------------------------------------------------------------------- #
# Collects release metadata, invokes the OpenAI chat action, and outputs
# formatted release notes. If GH_TOKEN is available, a GitHub release is
# created or updated with the generated notes.
#
# Usage: release-notes-processor.sh <version>
# --------------------------------------------------------------------------- #

VERSION="${1:-}"
[[ -z $VERSION ]] && { echo "Usage: $0 <version>" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION_PATH="$SCRIPT_DIR/../actions/openai-chat"

encode() { printf '%s' "$1" | tr '\n' '\020' | sed 's/"/\\"/g'; }

# Determine previous tag
PREV_TAG=$(git tag --sort=-v:refname 2>/dev/null | grep -E '^v' | grep -v "^v$VERSION$" | head -n 1 || true)
[[ -z $PREV_TAG ]] && PREV_TAG="v0.0.0"

# Extract changelog entry for this version
ESC_VER=$(printf '%s' "$VERSION" | sed 's/\./\\./g')
CHANGELOG_ENTRY=$(awk -v ver="$ESC_VER" '
  $0 ~ "^## \[" ver "\]" {flag=1; next}
  flag && /^## \[/ {exit}
  flag {print}
' CHANGELOG.md | sed '/^$/d')

# Commits between tags (handle missing previous tag)
if git rev-parse "$PREV_TAG" >/dev/null 2>&1; then
  COMMITS=$(git log --pretty=format:'%h %s' "$PREV_TAG"..HEAD || true)
else
  COMMITS=$(git log --pretty=format:'%h %s' HEAD || true)
fi

# Previous release notes (if any)
if [[ -n ${GH_TOKEN:-} ]]; then
  PREVIOUS_RELEASE=$(gh release view "$PREV_TAG" --json body -q .body 2>/dev/null || echo "")
else
  PREVIOUS_RELEASE=""
fi

# Determine version type
IFS=. read -r MAJ MIN PATCH <<< "${VERSION#v}"
IFS=. read -r PMAJ PMIN PPATCH <<< "${PREV_TAG#v}"
if (( MAJ > PMAJ )); then
  VERSION_TYPE="major"
elif (( MIN > PMIN )); then
  VERSION_TYPE="minor"
else
  VERSION_TYPE="patch"
fi

# Prepare variables for OpenAI prompts
VARS_B64=$(cat <<EOVARS | base64 -w 0
CHANGELOG_ENTRY=$(encode "$CHANGELOG_ENTRY")
GIT_COMMITS=$(encode "$COMMITS")
PREVIOUS_RELEASE=$(encode "$PREVIOUS_RELEASE")
VERSION=$VERSION
VERSION_TYPE=$VERSION_TYPE
EOVARS
)

TMP_OUT=$(mktemp)
GITHUB_OUTPUT="$TMP_OUT" \
  bash "$ACTION_PATH/entrypoint.sh" \
    --system   .github/prompts/release-notes.sys.md \
    --template .github/prompts/release-notes.user.md \
    --schema   .github/schema/release-notes.schema.json \
    --output   .github/templates/release-notes.tmpl.md \
    --vars     "$VARS_B64" \
    --model    "${OPENAI_MODEL:-gpt-4o-mini}" \
    --temp     0.2 \
    --tokens   1200

RELEASE_NOTES=$(awk '/^formatted_content<<EOF/{flag=1;next}/^EOF/{flag=0}flag' "$TMP_OUT")
rm -f "$TMP_OUT"

echo "$RELEASE_NOTES"

# Create or update GitHub release if token available
if [[ -n ${GH_TOKEN:-} ]]; then
  gh release create "v$VERSION" --notes "$RELEASE_NOTES" --title "v$VERSION" --verify-tag=false >/dev/null 2>&1 || \
  gh release edit "v$VERSION" --notes "$RELEASE_NOTES" --title "v$VERSION" >/dev/null 2>&1
fi
