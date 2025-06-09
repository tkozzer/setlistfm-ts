#!/bin/bash

# --------------------------------------------------------------------------- #
#  Shared Utilities for OpenAI Action Processors                             #
# --------------------------------------------------------------------------- #
# Common functions used by pr-enhance.sh, changelog.sh, and other processors
# to reduce code duplication and ensure consistent behavior.

# Note: This file is sourced by processors, so we don't set -euo pipefail here
# as the parent processor should handle that

# --------------------------------------------------------------------------- #
#  Validation Functions                                                       #
# --------------------------------------------------------------------------- #

# Validate processor inputs
# Usage: validate_inputs "$CONTENT" "$OUTPUT_TEMPLATE" "$PROCESSOR_NAME"
validate_inputs() {
  local content="$1"
  local template_file="$2"
  local processor_name="$3"
  
  if [[ -z $content ]]; then
    echo "❌ $processor_name: No content provided" >&2
    return 1
  fi

  if [[ ! -f $template_file ]]; then
    echo "❌ $processor_name: Template file '$template_file' not found" >&2
    return 1
  fi

  # Validate JSON structure
  if ! echo "$content" | jq . >/dev/null 2>&1; then
    echo "❌ $processor_name: Invalid JSON content" >&2
    return 1
  fi
  
  return 0
}

# --------------------------------------------------------------------------- #
#  Variable Processing Functions                                              #
# --------------------------------------------------------------------------- #

# Detect if a string is base64 encoded
# Usage: is_base64 "$VARS"
is_base64() {
  local vars="$1"
  [[ -n $vars ]] && echo "$vars" | grep -qE '^[A-Za-z0-9+/=]*$' && [[ $(echo "$vars" | wc -l) -eq 1 ]]
}

# Process template variables (VERSION, DATE, COMMITS, etc.)
# Usage: process_template_vars "$FORMATTED_CONTENT" "$VARS"
# Returns: Updated content via stdout
process_template_vars() {
  local content="$1"
  local vars="$2"
  
  if [[ -z $vars ]]; then
    echo "$content"
    return 0
  fi
  
  # Decode base64 vars if it looks like base64
  local decoded_vars
  if is_base64 "$vars"; then
    decoded_vars=$(echo "$vars" | base64 -d)
    
    # Check if decoded content is JSON (new format from prepare-ai-context.sh)
    if echo "$decoded_vars" | jq empty >/dev/null 2>&1; then
      # New JSON format - extract variables from JSON structure
      local json_vars="$decoded_vars"
      
      # Process each JSON field as a template variable
      local keys
      keys=$(echo "$json_vars" | jq -r 'keys[]' 2>/dev/null || echo "")
      
      while IFS= read -r key; do
        [[ -z $key ]] && continue
        
        local value
        value=$(echo "$json_vars" | jq -r ".$key // empty" 2>/dev/null || echo "")
        
        if [[ -n $value && $value != "null" ]]; then
          # Handle base64-encoded fields (those ending with _B64)
          if [[ $key == *_B64 ]]; then
            # Decode base64 content and remove _B64 suffix from variable name
            if decoded_b64_value=$(echo "$value" | base64 -d 2>/dev/null); then
              template_key="${key%_B64}"
              local pattern="{{${template_key}}}"
              content="${content//$pattern/$decoded_b64_value}"
            fi
          else
            # Regular variable processing
            local pattern="{{${key}}}"
            content="${content//$pattern/$value}"
          fi
        fi
      done <<< "$keys"
      
      echo "$content"
      return
    fi
  else
    decoded_vars="$vars"
  fi
  
  # Legacy format: Parse variables using a more robust approach that handles multiline values
  local current_key=""
  local current_value=""
  
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Check if this line starts a new KEY=VALUE pair
    if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      # Process previous key-value pair if we have one
      if [[ -n "$current_key" ]]; then
        # Handle base64-encoded variables (those ending with _B64)
        if [[ $current_key == *_B64 ]]; then
          # Decode base64 content and remove _B64 suffix from variable name
          if decoded_b64_value=$(echo "$current_value" | base64 -d 2>/dev/null); then
            template_key="${current_key%_B64}"
            local pattern="{{${template_key}}}"
            content="${content//$pattern/$decoded_b64_value}"
          fi
        else
          # Regular variable processing
          # Decode escaped newlines from GitHub Actions variable passing
          local decoded_value
          decoded_value=$(printf '%s' "$current_value" | tr '\020' '\n')
          
          # Use bash parameter substitution for multi-line content
          local pattern="{{${current_key}}}"
          content="${content//$pattern/$decoded_value}"
        fi
      fi
      
      # Start processing new key-value pair
      current_key="${line%%=*}"
      current_value="${line#*=}"
    else
      # This line is part of the current value (multiline content)
      if [[ -n "$current_key" ]]; then
        current_value="$current_value"$'\n'"$line"
      fi
    fi
  done <<< "$decoded_vars"
  
  # Process the final key-value pair
  if [[ -n "$current_key" ]]; then
    # Handle base64-encoded variables (those ending with _B64)
    if [[ $current_key == *_B64 ]]; then
      # Decode base64 content and remove _B64 suffix from variable name
      if decoded_b64_value=$(echo "$current_value" | base64 -d 2>/dev/null); then
        template_key="${current_key%_B64}"
        local pattern="{{${template_key}}}"
        content="${content//$pattern/$decoded_b64_value}"
      fi
    else
      # Regular variable processing
      # Decode escaped newlines from GitHub Actions variable passing
      local decoded_value
      decoded_value=$(printf '%s' "$current_value" | tr '\020' '\n')
      
      # Use bash parameter substitution for multi-line content
      local pattern="{{${current_key}}}"
      content="${content//$pattern/$decoded_value}"
    fi
  fi
  
  echo "$content"
}

# --------------------------------------------------------------------------- #
#  Template Processing Functions                                              #
# --------------------------------------------------------------------------- #

# Replace {{#each array}}...{{/each}} block with formatted list
# Usage: replace_each_block "$CONTENT" "$SECTION_NAME" "$FORMATTED_LIST"
# Returns: Updated content via stdout
replace_each_block() {
  local content="$1"
  local section_name="$2"
  local formatted_list="$3"
  
  local temp_file
  temp_file=$(mktemp)
  printf '%s' "$content" > "$temp_file"
  
  if grep -q "{{#each $section_name}}" "$temp_file"; then
    # Find line numbers for the section block
    local start_line end_line
    start_line=$(grep -n "{{#each $section_name}}" "$temp_file" | head -1 | cut -d: -f1)
    
    if [[ $section_name == "changes" ]]; then
      # For PR enhancement, find the last {{/each}}
      end_line=$(grep -n "{{/each}}" "$temp_file" | tail -1 | cut -d: -f1)
    else
      # For changelog, find the next {{/each}} after this {{#each}}
      end_line=$(awk -v start="$start_line" 'NR > start && /{{\/each}}/ {print NR; exit}' "$temp_file")
    fi
    
    if [[ -n $start_line && -n $end_line ]]; then
      # Replace the range with our formatted list
      {
        head -n $((start_line - 1)) "$temp_file"
        printf '%s' "$formatted_list"
        tail -n +$((end_line + 1)) "$temp_file"
      } > "${temp_file}.new"
      content=$(cat "${temp_file}.new")
      rm -f "${temp_file}.new"
    fi
  fi
  
  rm -f "$temp_file"
  echo "$content"
}

# Remove {{#if section}}...{{/if}} conditional block
# Usage: remove_conditional_block "$CONTENT" "$SECTION_NAME"
# Returns: Updated content via stdout
remove_conditional_block() {
  local content="$1"
  local section_name="$2"
  
  local temp_file
  temp_file=$(mktemp)
  printf '%s' "$content" > "$temp_file"
  
  # Use sed to remove the entire conditional block
  content=$(sed "/{{#if $section_name}}/,/{{\/if}}/d" "$temp_file")
  rm -f "$temp_file"
  
  echo "$content"
}

# Format array items as bullet list
# Usage: format_as_bullet_list "$JSON_CONTENT" "$ARRAY_KEY"
# Returns: Formatted bullet list via stdout
format_as_bullet_list() {
  local json_content="$1"
  local array_key="$2"
  
  local array_items
  array_items=$(echo "$json_content" | jq -r ".$array_key[]? // empty" 2>/dev/null || true)
  
  if [[ -n $array_items ]]; then
    local formatted_list=""
    while IFS= read -r item; do
      [[ -z $item ]] && continue
      formatted_list="${formatted_list}- ${item}"$'\n'
    done <<< "$array_items"
    echo "$formatted_list"
  fi
}

# --------------------------------------------------------------------------- #
#  Cleanup Functions                                                          #
# --------------------------------------------------------------------------- #

# Clean up handlebars artifacts
# Usage: cleanup_handlebars "$CONTENT" "$HAS_VARS"
# Returns: Cleaned content via stdout
cleanup_handlebars() {
  local content="$1"
  local has_vars="$2"
  
  # Remove leftover {{#each}} or {{/each}} markers
  content="${content//\{\{#each *\}\}/}"
  content="${content//\{\{\/each\}\}/}"
  
  # Remove leftover {{#if}} or {{/if}} markers
  content="${content//\{\{#if *\}\}/}"
  content="${content//\{\{\/if\}\}/}"
  
  # Remove leftover {{else}} markers
  content="${content//\{\{else\}\}/}"
  
  # Remove unprocessed placeholders, but preserve standard template variables
  # if no VARS were provided (keep VERSION, DATE, etc. for debugging)
  if [[ -n $has_vars ]]; then
    # Variables were provided, remove any remaining unprocessed placeholders
    content=$(printf '%s' "$content" | sed 's/{{[^}]*}}//g')
  fi
  # Note: When no VARS provided, we intentionally keep {{VERSION}}, {{DATE}}, etc. 
  # for debugging and to show what template variables are expected
  
  # Clean up excessive newlines (more than 2 consecutive)
  content=$(printf '%s' "$content" | sed '/^$/N;/^\n$/d')
  
  echo "$content"
}

# --------------------------------------------------------------------------- #
#  JSON Processing Functions                                                  #
# --------------------------------------------------------------------------- #

# Get array length from JSON
# Usage: get_array_length "$JSON_CONTENT" "$ARRAY_KEY"
# Returns: Array length via stdout
get_array_length() {
  local json_content="$1"
  local array_key="$2"
  echo "$json_content" | jq -r ".$array_key // [] | length" 2>/dev/null || echo "0"
}

# Check if JSON field exists
# Usage: json_field_exists "$JSON_CONTENT" "$FIELD_KEY"
# Returns: 0 if exists, 1 if not
json_field_exists() {
  local json_content="$1"
  local field_key="$2"
  echo "$json_content" | jq -e ".$field_key" >/dev/null 2>&1
}

# Get string fields from JSON for template substitution
# Usage: get_string_fields "$JSON_CONTENT"
# Returns: Field list in "key:value" format via stdout
get_string_fields() {
  local json_content="$1"
  echo "$json_content" | jq -r 'to_entries[] | select(.value | type == "string") | "\(.key):\(.value)"' 2>/dev/null || true
} 