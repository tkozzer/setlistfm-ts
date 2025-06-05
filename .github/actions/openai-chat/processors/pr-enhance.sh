#!/bin/bash

# --------------------------------------------------------------------------- #
#  PR Enhancement Processor                                                   #
# --------------------------------------------------------------------------- #
# Processes structured JSON responses for PR enhancement and formats them
# using the pr-enhancement.tmpl.md template with handlebars-style syntax.

set -euo pipefail

# Get the directory of this script to source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared.sh"

# --------------------------------------------------------------------------- #
#  Input parameters (passed from entrypoint.sh)                              #
# --------------------------------------------------------------------------- #
CONTENT="$1"           # Raw JSON response from OpenAI
OUTPUT_TEMPLATE="$2"   # Path to output template file
VARS="${3:-}"          # Optional template variables (base64 encoded)

# Handle stdin input
if [[ $CONTENT == "-" ]]; then
  CONTENT=$(cat)
fi

# --------------------------------------------------------------------------- #
#  Validate inputs using shared utilities                                     #
# --------------------------------------------------------------------------- #
validate_inputs "$CONTENT" "$OUTPUT_TEMPLATE" "pr-enhance.sh"

# --------------------------------------------------------------------------- #
#  Load template and process variables using shared utilities                 #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cat "$OUTPUT_TEMPLATE")
FORMATTED_CONTENT=$(process_template_vars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Process simple JSON fields using shared utilities                         #
# --------------------------------------------------------------------------- #
string_fields=$(get_string_fields "$CONTENT")

if [[ -n $string_fields ]]; then
  while IFS= read -r field; do
    [[ -z $field ]] && continue
    key=$(echo "$field" | cut -d':' -f1 | tr -d '"')
    value=$(echo "$CONTENT" | jq -r ".$key // empty" 2>/dev/null || echo "")
    
    if [[ -n $value && $value != "null" ]]; then
      pattern="{{${key}}}"
      FORMATTED_CONTENT="${FORMATTED_CONTENT//$pattern/$value}"
    fi
  done <<< "$string_fields"
fi

# --------------------------------------------------------------------------- #
#  Process commit_analysis nested object                                     #
# --------------------------------------------------------------------------- #
if json_field_exists "$CONTENT" "commit_analysis"; then
  total_commits=$(echo "$CONTENT" | jq -r '.commit_analysis.total_commits // 0')
  conventional_commits=$(echo "$CONTENT" | jq -r '.commit_analysis.conventional_commits // 0')
  suggestions=$(echo "$CONTENT" | jq -r '.commit_analysis.suggestions // ""')
  
  # Replace commit analysis variables
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{commit_analysis.total_commits\}\}/$total_commits}"
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{commit_analysis.conventional_commits\}\}/$conventional_commits}"
  
  # Handle conditional suggestions block
  if [[ -n $suggestions && $suggestions != "null" ]]; then
    # Keep the suggestions block and replace the variable
    FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{commit_analysis.suggestions\}\}/$suggestions}"
    # Remove the conditional markers
    FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if commit_analysis.suggestions\}\}/}"
    FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{\/if\}\}/}"
  else
    # Remove the entire conditional block
    FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "commit_analysis.suggestions")
  fi
fi

# --------------------------------------------------------------------------- #
#  Process changes array using shared utilities                              #
# --------------------------------------------------------------------------- #
if json_field_exists "$CONTENT" "changes"; then
  formatted_changes=$(format_as_bullet_list "$CONTENT" "changes")
  
  if [[ -n $formatted_changes ]]; then
    # Replace the {{#each changes}}...{{/each}} block using shared utility
    FORMATTED_CONTENT=$(replace_each_block "$FORMATTED_CONTENT" "changes" "$formatted_changes")
  fi
fi

# --------------------------------------------------------------------------- #
#  Clean up handlebars artifacts using shared utilities                       #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cleanup_handlebars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Output the formatted content                                               #
# --------------------------------------------------------------------------- #
printf '%s' "$FORMATTED_CONTENT" 