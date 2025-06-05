#!/bin/bash

# --------------------------------------------------------------------------- #
#  Changelog Processor                                                        #
# --------------------------------------------------------------------------- #
# Processes structured JSON responses for changelog generation and formats them
# using the changelog.tmpl.md template with handlebars-style syntax.
# Follows Keep a Changelog standards with sections: Added, Changed, Deprecated,
# Removed, Fixed, Security.

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
validate_inputs "$CONTENT" "$OUTPUT_TEMPLATE" "changelog.sh"

# --------------------------------------------------------------------------- #
#  Load template and process variables using shared utilities                 #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cat "$OUTPUT_TEMPLATE")
FORMATTED_CONTENT=$(process_template_vars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Process changelog sections (added, changed, deprecated, removed, fixed, security)
# --------------------------------------------------------------------------- #
changelog_sections=("added" "changed" "deprecated" "removed" "fixed" "security")

for section in "${changelog_sections[@]}"; do
  # Check if section exists and has items using shared utilities
  if json_field_exists "$CONTENT" "$section"; then
    section_count=$(get_array_length "$CONTENT" "$section")
    
    if [[ $section_count -gt 0 ]]; then
      # Section has items - format as bullet list and replace in template
      formatted_list=$(format_as_bullet_list "$CONTENT" "$section")
      
      if [[ -n $formatted_list ]]; then
        # Replace the {{#each section}}...{{/each}} block using shared utility
        FORMATTED_CONTENT=$(replace_each_block "$FORMATTED_CONTENT" "$section" "$formatted_list")
      fi
      
      # Remove the {{#if section}} and {{/if}} markers for this section
      FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if $section\}\}/}"
      
      # Remove {{/if}} that corresponds to this section
      # We need to be careful to only remove the first {{/if}} after removing {{#if section}}
      FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "0,/{{\/if}}/s///" )
      
    else
      # Section is empty - remove the entire {{#if section}}...{{/if}} block
      FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "$section")
    fi
  else
    # Section doesn't exist - remove the entire {{#if section}}...{{/if}} block
    FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "$section")
  fi
done

# --------------------------------------------------------------------------- #
#  Clean up handlebars artifacts using shared utilities                       #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cleanup_handlebars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Output the formatted content                                               #
# --------------------------------------------------------------------------- #
printf '%s' "$FORMATTED_CONTENT" 