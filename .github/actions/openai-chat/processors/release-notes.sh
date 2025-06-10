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
#  Helper functions for content generation and conditional replacement         #
# --------------------------------------------------------------------------- #
replace_conditional_section() {
  local template="$1"
  local section_name="$2"
  local new_content="$3"

  # Use shared utilities instead of complex manual parsing
  # This function should follow the same pattern as other processors
  echo "$template" | sed "s/{{#if $section_name}}.*{{\/if}}/$new_content/g"
}

# Generate bug fixes list from git commit data when AI doesn't provide it
generate_bug_fixes_from_commits() {
  local vars="$1"
  local expected_count="$2"
  
  if [[ -z $vars ]]; then
    echo "**Bug fixes** based on $expected_count fix commits"
    return
  fi
  
  # Extract git commits from template variables
  local git_commits
  git_commits=$(extract_template_variable "$vars" "GIT_COMMITS" 2>/dev/null || echo "")
  
  if [[ -n $git_commits ]]; then
    # Extract fix commits and create bullet points
    echo "$git_commits" | grep -E "^\s*fix(\([^)]+\))?:" | head -5 | while read -r commit; do
      # Extract the commit message after the type
      local msg=$(echo "$commit" | sed 's/^\s*fix[^:]*:\s*//')
      echo "**Fixed**: $msg"
    done
  else
    echo "**Bug fixes** based on $expected_count fix commits"
  fi
}

# Generate CI improvements list from git commit data when AI doesn't provide it
generate_ci_improvements_from_commits() {
  local vars="$1"
  local expected_count="$2"
  
  if [[ -z $vars ]]; then
    echo "**CI/DevOps improvements** based on $expected_count ci commits"
    return
  fi
  
  # Extract git commits from template variables
  local git_commits
  git_commits=$(extract_template_variable "$vars" "GIT_COMMITS" 2>/dev/null || echo "")
  
  if [[ -n $git_commits ]]; then
    # Extract ci commits and create bullet points
    echo "$git_commits" | grep -E "^\s*ci(\([^)]+\))?:" | head -5 | while read -r commit; do
      # Extract the commit message after the type
      local msg=$(echo "$commit" | sed 's/^\s*ci[^:]*:\s*//')
      echo "**CI Enhancement**: $msg"
    done
  else
    echo "**CI/DevOps improvements** based on $expected_count ci commits"
  fi
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
#  Process version from template variables (not from AI response)             #
# --------------------------------------------------------------------------- #
# Extract version from template variables rather than AI response
version_from_template=$(extract_template_variable "$VARS" "VERSION" 2>/dev/null || echo "")

if [[ -n $version_from_template && $version_from_template != "null" ]]; then
  # Remove existing "v" prefix if present, as template already has "v{{version}}"
  version_without_v="${version_from_template#v}"
  FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{version\}\}/$version_without_v}"
fi

# --------------------------------------------------------------------------- #
#  Process other JSON fields (summary, footer_links, etc.)                   #
# --------------------------------------------------------------------------- #
# Process other string fields (excluding version since we handle it above)
string_fields=$(get_string_fields "$CONTENT")
if [[ -n $string_fields ]]; then
  while IFS= read -r field; do
    [[ -z $field ]] && continue
    key=$(echo "$field" | cut -d':' -f1 | tr -d '"')
    # Skip version as we handled it above from template variables
    [[ $key == "version" ]] && continue
    
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
  # Try to get bug_fixes from AI response first
  fixes_list=$(format_as_bullet_list "$CONTENT" "bug_fixes")
  
  # If not provided by AI, generate from git commit data
  if [[ -z $fixes_list ]]; then
    fixes_list=$(generate_bug_fixes_from_commits "$VARS" "$fix_count")
  fi
  
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
  # Try to get ci_improvements from AI response first
  ci_list=$(format_as_bullet_list "$CONTENT" "ci_improvements")
  
  # If not provided by AI, generate from git commit data
  if [[ -z $ci_list ]]; then
    ci_list=$(generate_ci_improvements_from_commits "$VARS" "$ci_count")
  fi
  
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
secondary_count=$(get_array_length "$CONTENT" "secondary_sections")
if [[ $secondary_count -gt 0 ]]; then
  # Format secondary sections manually since they have a complex structure
  sections_content=""
  for ((i=0; i<secondary_count; i++)); do
    section_title=$(echo "$CONTENT" | jq -r ".secondary_sections[$i].title // \"\"")
    section_emoji=$(echo "$CONTENT" | jq -r ".secondary_sections[$i].emoji // \"\"")
    
    if [[ -n $section_title && $section_title != "null" ]]; then
      sections_content+=$'\n\n'"## $section_emoji $section_title"$'\n\n'
      
      # Get features for this section
      features=$(echo "$CONTENT" | jq -r ".secondary_sections[$i].features[]? // empty" 2>/dev/null || true)
      while IFS= read -r feature; do
        [[ -z $feature ]] && continue
        sections_content+="- $feature"$'\n'
      done <<< "$features"
    fi
  done
  
  if [[ -n $sections_content ]]; then
    # Use remove_conditional_block to remove the entire {{#if secondary_sections}}...{{/if}} block
    # and then add our content where the block was
    FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "secondary_sections")
    # Insert our sections content where the block was removed
    # Find the breaking changes section and insert before it
    breaking_marker="{{#if (or breaking_changes commit_analysis.breaking_changes_detected)}}"
    FORMATTED_CONTENT="${FORMATTED_CONTENT//$breaking_marker/$sections_content$'\n\n'$breaking_marker}"
  else
    FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "secondary_sections")
  fi
else
  FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "secondary_sections")
fi

# --------------------------------------------------------------------------- #
#  Process breaking changes section                                           #
# --------------------------------------------------------------------------- #
breaking_changes=$(echo "$CONTENT" | jq -r '.breaking_changes // ""')
breaking_detected=$(echo "$CONTENT" | jq -r '.commit_analysis.breaking_changes_detected // false')

# Create the appropriate breaking changes content
if [[ -n $breaking_changes && $breaking_changes != "null" ]] || [[ $breaking_detected == "true" ]]; then
  # Has breaking changes - use the breaking changes section
  breaking_content="## ⚠️ Breaking Changes"$'\n\n'
  if [[ -n $breaking_changes && $breaking_changes != "null" ]]; then
    breaking_content+="$breaking_changes"
  else
    breaking_content+="Breaking changes detected in commits - see commit messages for details."
  fi
else
  # No breaking changes - use the "No Breaking Changes" section
  breaking_content="## 🔒 No Breaking Changes"$'\n\n'"The SDK code, public APIs, and npm package contents remain exactly the same—upgrade with confidence, your existing integration will continue to work."
fi

# Replace the entire conditional block with our content - use the existing function
FORMATTED_CONTENT=$(remove_conditional_block "$FORMATTED_CONTENT" "(or breaking_changes commit_analysis.breaking_changes_detected)")
# Clean up any leftover breaking changes content (this handles the {{else}} case)
FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed '/## 🔒 No Breaking Changes/,/upgrade with confidence/d')
# Insert our breaking changes content before the footer
FORMATTED_CONTENT="${FORMATTED_CONTENT//---/$breaking_content$'\n\n'---}"

# --------------------------------------------------------------------------- #
#  Process footer_links if present                                           #
# --------------------------------------------------------------------------- #
if json_field_exists "$CONTENT" "footer_links"; then
  # Extract individual footer links
  npm_link=$(echo "$CONTENT" | jq -r '.footer_links.npm // ""')
  changelog_link=$(echo "$CONTENT" | jq -r '.footer_links.changelog // ""')
  issues_link=$(echo "$CONTENT" | jq -r '.footer_links.issues // ""')
  
  # Replace individual footer link placeholders
  [[ -n $npm_link && $npm_link != "null" ]] && FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{footer_links.npm\}\}/$npm_link}"
  [[ -n $changelog_link && $changelog_link != "null" ]] && FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{footer_links.changelog\}\}/$changelog_link}"
  [[ -n $issues_link && $issues_link != "null" ]] && FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{footer_links.issues\}\}/$issues_link}"
fi

# --------------------------------------------------------------------------- #
#  Clean up handlebars artifacts using shared utilities                       #
# --------------------------------------------------------------------------- #
FORMATTED_CONTENT=$(cleanup_handlebars "$FORMATTED_CONTENT" "$VARS")

# --------------------------------------------------------------------------- #
#  Output the formatted content                                               #
# --------------------------------------------------------------------------- #
printf '%s' "$FORMATTED_CONTENT"


