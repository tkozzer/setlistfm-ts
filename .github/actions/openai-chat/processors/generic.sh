#!/usr/bin/env bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared.sh"

###############################################################################
# Generic processor for basic template processing
#
# Usage: generic.sh <content> <template_file> [vars]
#
# Arguments:
#   content       - Raw content (could be JSON or plain text)
#   template_file - Path to template file
#   vars         - Optional base64-encoded variables (KEY=VALUE format)
#
# This processor handles:
# - Basic {{variable}} substitution from vars
# - Simple JSON field substitution for string/number fields  
# - {{content}} replacement with raw content
# - Fallback to basic variable substitution for non-JSON content
###############################################################################

main() {
  local content="$1"
  local template_file="$2"
  local vars="${3:-}"
  
  # Handle stdin input
  if [[ $content == "-" ]]; then
    content=$(cat)
  fi
  
  # Validate inputs (generic processor accepts any content)
  if [[ -z $content ]]; then
    echo "❌ generic.sh: Content cannot be empty" >&2
    exit 1
  fi
  
  if [[ ! -f $template_file ]]; then
    echo "❌ generic.sh: Template file '$template_file' not found" >&2
    exit 1
  fi
  
  # Load template
  local template_content
  template_content=$(cat "$template_file")
  
  # Process template variables first
  local processed_template
  processed_template=$(process_template_vars "$template_content" "$vars")
  
  # Check if content is valid JSON
  if echo "$content" | jq . >/dev/null 2>&1; then
    # JSON content - do structured processing
    process_json_content "$processed_template" "$content" "$vars"
  else
    # Non-JSON content - do simple replacement
    process_plain_content "$processed_template" "$content" "$vars"
  fi
}

# Process JSON content with field substitution
process_json_content() {
  local template="$1"
  local content="$2"
  local vars="$3"
  local result="$template"
  
  # First, collect all {{field}} patterns from template and replace with values or empty strings
  local template_vars
  template_vars=$(echo "$result" | grep -oE '\{\{[a-zA-Z_][a-zA-Z0-9_]*\}\}' | sort | uniq || true)
  
  while IFS= read -r var_pattern; do
    [[ -z $var_pattern ]] && continue
    # Extract field name from {{field}}
    local field_name
    field_name=$(echo "$var_pattern" | sed 's/{{//g' | sed 's/}}//g')
    
    # Skip special fields like 'content' which are handled separately
    [[ $field_name == "content" ]] && continue
    
    # Get value from JSON, default to empty if not found
    local value
    value=$(echo "$content" | jq -r ".$field_name // \"\"" 2>/dev/null || echo "")
    
    # Replace all occurrences of this pattern
    result="${result//$var_pattern/$value}"
  done <<< "$template_vars"
  
  # Replace {{content}} with the raw JSON
  result="${result//\{\{content\}\}/$content}"

  # Re-apply variables so they can override JSON fields
  result=$(process_template_vars "$result" "$vars")

  printf '%s' "$result"
}

# Process plain text content
process_plain_content() {
  local template="$1"
  local content="$2"
  local vars="$3"

  # Just replace {{content}} with the raw content
  local result="${template//\{\{content\}\}/$content}"

  # Re-apply variables for consistency with JSON mode
  result=$(process_template_vars "$result" "$vars")

  printf '%s' "$result"
}

# Check if this script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Validate arguments
  if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "❌ generic.sh: Usage: $0 <content> <template_file> [vars]" >&2
    exit 1
  fi
  
  main "$@"
fi 