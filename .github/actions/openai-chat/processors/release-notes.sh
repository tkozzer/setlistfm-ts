#!/bin/bash

# --------------------------------------------------------------------------- #
#  Release Notes Processor                                                    #
# --------------------------------------------------------------------------- #
# Processes structured JSON responses for release notes generation and formats
# them using the release-notes.tmpl.md template with handlebars-style syntax.

set -euo pipefail

# Get the directory of this script to source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared.sh"

# --------------------------------------------------------------------------- #
#  Helper function for conditional section replacement                        #
# --------------------------------------------------------------------------- #
replace_conditional_section() {
  local template="$1"
  local section_name="$2"
  local new_content="$3"

  # Use shared utilities instead of complex manual parsing
  # This function should follow the same pattern as other processors
  echo "$template" | sed "s/{{#if $section_name}}.*{{\/if}}/$new_content/g"
}

# --------------------------------------------------------------------------- #
#  Input parameters (passed from entrypoint.sh)                               #
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
validate_inputs "$CONTENT" "$OUTPUT_TEMPLATE" "release-notes.sh"

# --------------------------------------------------------------------------- #
#  Load template and process variables using shared utilities                 #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cat "$OUTPUT_TEMPLATE")
FORMATTED_CONTENT=$(process_template_vars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Process simple JSON fields (version, summary, footer_links)                #
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
#  Process primary_section.features                                           #
# --------------------------------------------------------------------------- #
feat_count=$(echo "$CONTENT" | jq -r '.commit_analysis.feat_count // 0')
if [[ $feat_count -gt 0 ]]; then
  feature_list=$(format_as_bullet_list "$CONTENT" "primary_section.features")
  if [[ -n $feature_list ]]; then
    FORMATTED_CONTENT=$(replace_each_block "$FORMATTED_CONTENT" "primary_section.features" "$feature_list")
  fi
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if (gt commit_analysis.feat_count 0)\}\}/}"
  FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "0,/{{\\/if}}/s// /")
else
  FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "(gt commit_analysis.feat_count 0)")
fi

# --------------------------------------------------------------------------- #
#  Process bug_fixes array                                                    #
# --------------------------------------------------------------------------- #
fix_count=$(echo "$CONTENT" | jq -r '.commit_analysis.fix_count // 0')
if [[ $fix_count -gt 0 ]]; then
  fixes_list=$(format_as_bullet_list "$CONTENT" "bug_fixes")
  if [[ -n $fixes_list ]]; then
    FORMATTED_CONTENT=$(replace_each_block "$FORMATTED_CONTENT" "bug_fixes" "$fixes_list")
  fi
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if (gt commit_analysis.fix_count 0)\}\}/}"
  FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "0,/{{\\/if}}/s// /")
else
  FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "(gt commit_analysis.fix_count 0)")
fi

# --------------------------------------------------------------------------- #
#  Process ci_improvements array                                             #
# --------------------------------------------------------------------------- #
ci_count=$(echo "$CONTENT" | jq -r '.commit_analysis.ci_count // 0')
if [[ $ci_count -gt 0 ]]; then
  ci_list=$(format_as_bullet_list "$CONTENT" "ci_improvements")
  if [[ -n $ci_list ]]; then
    FORMATTED_CONTENT=$(replace_each_block "$FORMATTED_CONTENT" "ci_improvements" "$ci_list")
  fi
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if (gt commit_analysis.ci_count 0)\}\}/}"
  FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "0,/{{\\/if}}/s// /")
else
  FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "(gt commit_analysis.ci_count 0)")
fi

# --------------------------------------------------------------------------- #
#  Process secondary_sections array                                           #
# --------------------------------------------------------------------------- #
if json_field_exists "$CONTENT" "secondary_sections"; then
  sections_list=$(format_as_bullet_list "$CONTENT" "secondary_sections")
  if [[ -n $sections_list ]]; then
    FORMATTED_CONTENT=$(replace_each_block "$FORMATTED_CONTENT" "secondary_sections" "$sections_list")
  fi
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if secondary_sections\}\}/}"
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{\/if\}\}/}"
else
  FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "secondary_sections")
fi

# --------------------------------------------------------------------------- #
#  Process breaking changes section                                           #
# --------------------------------------------------------------------------- #
breaking_changes=$(echo "$CONTENT" | jq -r '.breaking_changes // ""')
breaking_detected=$(echo "$CONTENT" | jq -r '.commit_analysis.breaking_changes_detected // false')
if [[ -n $breaking_changes && $breaking_changes != "null" ]] || [[ $breaking_detected == "true" ]]; then
  # Has breaking changes - keep the breaking changes block
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{breaking_changes\}\}/$breaking_changes}"
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{#if (or breaking_changes commit_analysis.breaking_changes_detected)\}\}/}"
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{\/if\}\}/}"
else
  # No breaking changes - replace with "No Breaking Changes" section
  FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "(or breaking_changes commit_analysis.breaking_changes_detected)")
fi

# --------------------------------------------------------------------------- #
#  Clean up handlebars artifacts using shared utilities                       #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cleanup_handlebars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Output the formatted content                                               #
# --------------------------------------------------------------------------- #
printf '%s' "$FORMATTED_CONTENT"


