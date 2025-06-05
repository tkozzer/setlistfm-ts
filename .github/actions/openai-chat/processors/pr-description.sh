#!/usr/bin/env bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared.sh"

###############################################################################
# PR Description processor for release PR generation
#
# Usage: pr-description.sh <content> <template_file> [vars]
#
# Arguments:
#   content       - JSON response from OpenAI (pr-description schema)
#   template_file - Path to pr-description output template
#   vars         - Optional base64-encoded variables (VERSION, DATE, etc.)
#
# This processor handles:
# - Complex nested JSON structure (changes object with sub-arrays)
# - Conditional sections ({{#if}}, {{#unless}})
# - Array processing ({{#each}})
# - Breaking changes object arrays
# - Template variable substitution
###############################################################################

main() {
  local content="$1"
  local template_file="$2"
  local vars="${3:-}"
  
  # Handle stdin input
  if [[ $content == "-" ]]; then
    content=$(cat)
  fi
  
  # Validate inputs
  validate_inputs "$content" "$template_file" "$vars"
  
  # Load template
  local template_content
  template_content=$(cat "$template_file")
  
  # Process template variables first (VERSION, DATE, etc.)
  local processed_template
  processed_template=$(process_template_vars "$template_content" "$vars")
  
  # Process the JSON content with the template
  process_pr_description "$processed_template" "$content" "$vars"
}

# Process PR description with complex nested structure
process_pr_description() {
  local template="$1"
  local content="$2"
  local vars="${3:-}"
  local result="$template"
  
  # Process simple string fields first
  local string_fields
  string_fields=$(get_string_fields "$content")
  while IFS= read -r field; do
    [[ -z $field ]] && continue
    local key value
    key=$(echo "$field" | cut -d':' -f1)
    value=$(echo "$field" | cut -d':' -f2-)
    
    local pattern="{{${key}}}"
    result="${result//$pattern/$value}"
  done <<< "$string_fields"
  
  # Process whats_new array
  result=$(process_whats_new "$result" "$content")
  
  # Process all changes categories
  result=$(process_changes_features "$result" "$content")
  result=$(process_changes_bug_fixes "$result" "$content")
  result=$(process_changes_improvements "$result" "$content")
  result=$(process_changes_internal "$result" "$content")
  result=$(process_changes_documentation "$result" "$content")
  
  # Process breaking_changes array
  result=$(process_breaking_changes "$result" "$content")
  
  # Clean up any remaining handlebars
  result=$(cleanup_handlebars "$result" "$vars")
  
  printf '%s' "$result"
}

# Process whats_new section
process_whats_new() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "whats_new"; then
    local whats_new_count
    whats_new_count=$(get_array_length "$content" "whats_new")
    
    if [[ $whats_new_count -gt 0 ]]; then
      # Build the what's new list
      local whats_new_section="## 📝 What's New"$'\n\n'
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -r '.whats_new[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r item; do
        [[ -z $item ]] && continue
        whats_new_section="${whats_new_section}- ${item}"$'\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the whats_new section
      template=$(replace_conditional_section "$template" "whats_new" "$whats_new_section")
    else
      # Remove the entire {{#if whats_new}} block
      template=$(remove_conditional_section "$template" "whats_new")
    fi
  else
    template=$(remove_conditional_section "$template" "whats_new")
  fi
  
  echo "$template"
}

# Process changes.features section
process_changes_features() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "changes.features"; then
    local features_count
    features_count=$(echo "$content" | jq -r '.changes.features // [] | length' 2>/dev/null || echo "0")
    
    if [[ $features_count -gt 0 ]]; then
      local features_section="### ✨ Features"$'\n\n'
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -r '.changes.features[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r item; do
        [[ -z $item ]] && continue
        features_section="${features_section}- ${item}"$'\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the features section
      template=$(replace_conditional_section "$template" "changes.features" "$features_section")
    else
      template=$(remove_conditional_section "$template" "changes.features")
    fi
  else
    template=$(remove_conditional_section "$template" "changes.features")
  fi
  
  echo "$template"
}

# Process changes.bug_fixes section
process_changes_bug_fixes() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "changes.bug_fixes"; then
    local bug_fixes_count
    bug_fixes_count=$(echo "$content" | jq -r '.changes.bug_fixes // [] | length' 2>/dev/null || echo "0")
    
    if [[ $bug_fixes_count -gt 0 ]]; then
      local bug_fixes_section="### 🐛 Bug Fixes"$'\n\n'
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -r '.changes.bug_fixes[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r item; do
        [[ -z $item ]] && continue
        bug_fixes_section="${bug_fixes_section}- ${item}"$'\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the bug_fixes section
      template=$(replace_conditional_section "$template" "changes.bug_fixes" "$bug_fixes_section")
    else
      template=$(remove_conditional_section "$template" "changes.bug_fixes")
    fi
  else
    template=$(remove_conditional_section "$template" "changes.bug_fixes")
  fi
  
  echo "$template"
}

# Process changes.improvements section
process_changes_improvements() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "changes.improvements"; then
    local improvements_count
    improvements_count=$(echo "$content" | jq -r '.changes.improvements // [] | length' 2>/dev/null || echo "0")
    
    if [[ $improvements_count -gt 0 ]]; then
      local improvements_section="### 🔧 Improvements"$'\n\n'
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -r '.changes.improvements[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r item; do
        [[ -z $item ]] && continue
        improvements_section="${improvements_section}- ${item}"$'\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the improvements section
      template=$(replace_conditional_section "$template" "changes.improvements" "$improvements_section")
    else
      template=$(remove_conditional_section "$template" "changes.improvements")
    fi
  else
    template=$(remove_conditional_section "$template" "changes.improvements")
  fi
  
  echo "$template"
}

# Process changes.internal section
process_changes_internal() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "changes.internal"; then
    local internal_count
    internal_count=$(echo "$content" | jq -r '.changes.internal // [] | length' 2>/dev/null || echo "0")
    
    if [[ $internal_count -gt 0 ]]; then
      local internal_section="### 🏗️ Internal"$'\n\n'
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -r '.changes.internal[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r item; do
        [[ -z $item ]] && continue
        internal_section="${internal_section}- ${item}"$'\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the internal section
      template=$(replace_conditional_section "$template" "changes.internal" "$internal_section")
    else
      template=$(remove_conditional_section "$template" "changes.internal")
    fi
  else
    template=$(remove_conditional_section "$template" "changes.internal")
  fi
  
  echo "$template"
}

# Process changes.documentation section
process_changes_documentation() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "changes.documentation"; then
    local documentation_count
    documentation_count=$(echo "$content" | jq -r '.changes.documentation // [] | length' 2>/dev/null || echo "0")
    
    if [[ $documentation_count -gt 0 ]]; then
      local documentation_section="### 📚 Documentation"$'\n\n'
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -r '.changes.documentation[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r item; do
        [[ -z $item ]] && continue
        documentation_section="${documentation_section}- ${item}"$'\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the documentation section
      template=$(replace_conditional_section "$template" "changes.documentation" "$documentation_section")
    else
      template=$(remove_conditional_section "$template" "changes.documentation")
    fi
  else
    template=$(remove_conditional_section "$template" "changes.documentation")
  fi
  
  echo "$template"
}

# Process breaking_changes section
process_breaking_changes() {
  local template="$1"
  local content="$2"
  
  if json_field_exists "$content" "breaking_changes"; then
    local breaking_count
    breaking_count=$(get_array_length "$content" "breaking_changes")
    
    if [[ $breaking_count -gt 0 ]]; then
      # Build formatted breaking changes section
      local breaking_section=""
      local temp_file
      temp_file=$(mktemp)
      echo "$content" | jq -c '.breaking_changes[]?' 2>/dev/null > "$temp_file" || true
      
      while IFS= read -r breaking_obj; do
        [[ -z $breaking_obj ]] && continue
        local change migration
        change=$(echo "$breaking_obj" | jq -r '.change // "Unknown change"')
        migration=$(echo "$breaking_obj" | jq -r '.migration // "No migration guidance provided"')
        
        breaking_section="${breaking_section}### ${change}"$'\n\n'
        breaking_section="${breaking_section}**Migration:** ${migration}"$'\n\n'
      done < "$temp_file"
      rm -f "$temp_file"
      
      # Replace the {{#if breaking_changes}} block and remove {{#unless}} block
      template=$(replace_conditional_section "$template" "breaking_changes" "$breaking_section")
      template=$(remove_conditional_section "$template" "unless breaking_changes")
    else
      # Remove {{#if}} block but keep {{#unless}} content
      template=$(remove_conditional_section "$template" "breaking_changes")
      template=$(remove_unless_markers "$template" "breaking_changes")
    fi
  else
    # Remove {{#if}} block but keep {{#unless}} content
    template=$(remove_conditional_section "$template" "breaking_changes")
    template=$(remove_unless_markers "$template" "breaking_changes")
  fi
  
  echo "$template"
}

# Replace a conditional section with new content
replace_conditional_section() {
  local template="$1"
  local section_name="$2"
  local new_content="$3"
  
  local temp_file temp_output temp_content
  temp_file=$(mktemp)
  temp_output=$(mktemp)
  temp_content=$(mktemp)
  
  echo "$template" > "$temp_file"
  echo "$new_content" > "$temp_content"
  
  # Use a combination of sed and file operations to handle multiline content
  local start_line end_line
  start_line=$(grep -n "{{#if $section_name}}" "$temp_file" | head -1 | cut -d: -f1)
  end_line=$(awk -v start="$start_line" 'NR > start && /{{\/if}}/ {print NR; exit}' "$temp_file")
  
  if [[ -n $start_line && -n $end_line ]]; then
    # Replace the range with our new content
    {
      head -n $((start_line - 1)) "$temp_file"
      cat "$temp_content"
      tail -n +$((end_line + 1)) "$temp_file"
    } > "$temp_output"
    
    local result
    result=$(cat "$temp_output")
  else
    local result
    result=$(cat "$temp_file")
  fi
  
  rm -f "$temp_file" "$temp_output" "$temp_content"
  echo "$result"
}

# Remove a conditional section entirely
remove_conditional_section() {
  local template="$1"
  local section_name="$2"
  
  local temp_file temp_output
  temp_file=$(mktemp)
  temp_output=$(mktemp)
  
  echo "$template" > "$temp_file"
  
  # Use sed to remove the conditional block
  if [[ "$section_name" == "unless"* ]]; then
    # Handle {{#unless}} blocks
    local unless_name=${section_name#unless }
    sed "/{{#unless $unless_name}}/,/{{\/unless}}/d" "$temp_file" > "$temp_output"
  else
    # Handle regular {{#if}} blocks
    sed "/{{#if $section_name}}/,/{{\/if}}/d" "$temp_file" > "$temp_output"
  fi
  
  local result
  result=$(cat "$temp_output")
  rm -f "$temp_file" "$temp_output"
  
  echo "$result"
}

# Remove unless markers but keep content
remove_unless_markers() {
  local template="$1"
  local section_name="$2"
  
  template="${template//\{\{#unless $section_name\}\}/}"
  template="${template//\{\{\/unless\}\}/}"
  
  echo "$template"
}

# Check if this script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Validate arguments
  if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "❌ pr-description.sh: Usage: $0 <content> <template_file> [vars]" >&2
    exit 1
  fi
  
  main "$@"
fi 