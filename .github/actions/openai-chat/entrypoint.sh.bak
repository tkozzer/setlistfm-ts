#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2155
set -euo pipefail

###############################################################################
# Parse CLI args                                                              #
###############################################################################
SYSTEM=""
TEMPLATE=""
VARS=""
MODEL=""
TEMP="0.3"
TOKENS="1500"
SCHEMA=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --system  ) SYSTEM="$2";   shift 2 ;;
    --template) TEMPLATE="$2"; shift 2 ;;
    --vars    ) VARS="$2";     shift 2 ;;
    --model   ) MODEL="$2";    shift 2 ;;
    --temp    ) TEMP="$2";     shift 2 ;;
    --tokens  ) TOKENS="$2";   shift 2 ;;
    --schema  ) SCHEMA="$2";   shift 2 ;;
    --output  ) OUTPUT="$2";   shift 2 ;;
    *) echo "unknown option $1" >&2; exit 1 ;;
  esac
done

[[ -z $TEMPLATE ]] && { echo "❌ --template is required" >&2; exit 1; }

###############################################################################
# Load and prepare prompts                                                    #
###############################################################################
load_file() {
  local file="$1"
  [[ -z $file ]] && { echo ""; return; }
  [[ ! -f $file ]] && { echo "❌ file '$file' not found" >&2; exit 1; }
  cat "$file"
}

PROMPT_SYS=$(load_file "$SYSTEM")
PROMPT_USER=$(load_file "$TEMPLATE")

# Escape special regex characters for sed substitution
escape_for_sed() {
  local text="$1"
  # Escape all regex metacharacters: \ . * + ? ^ $ { } ( ) [ ] |
  # Note: backslash must be escaped first
  text="${text//\\/\\\\}"  # \ -> \\
  text="${text//./\\.}"    # . -> \.
  text="${text//\*/\\*}"   # * -> \*
  text="${text//+/\\+}"    # + -> \+
  text="${text//\?/\\?}"   # ? -> \?
  text="${text//^/\\^}"    # ^ -> \^
  text="${text//$/\\$}"    # $ -> \$
  text="${text//{/\\{}"    # { -> \{
  # Use a different approach for } since bash has issues with the syntax
  text=$(printf '%s' "$text" | sed 's/}/\\}/g')  # } -> \}
  text="${text//(/\\(}"    # ( -> \(
  text="${text//)/\\)}"    # ) -> \)
  text="${text//\[/\\[}"   # [ -> \[
  text="${text//\]/\\]}"   # ] -> \]
  text="${text//|/\\|}"    # | -> \|
  printf '%s' "$text"
}

# Substitute {{KEY}} placeholders in both prompts
substitute() {
  local text="$1"
  if [[ -n $VARS ]]; then
    # Decode base64 vars if it looks like base64 (no newlines, only base64 chars)
    if echo "$VARS" | grep -qE '^[A-Za-z0-9+/=]*$' && [[ $(echo "$VARS" | wc -l) -eq 1 ]]; then
      DECODED_VARS=$(echo "$VARS" | base64 -d)
    else
      DECODED_VARS="$VARS"
    fi
    
    while IFS='=' read -r KEY VALUE; do
      [[ -z $KEY ]] && continue
      # Decode escaped newlines from GitHub Actions variable passing
      decoded_value=$(printf '%s' "$VALUE" | tr '\020' '\n')
      
      # Use bash parameter substitution for multi-line content (safer than sed)
      # Create the pattern to replace
      pattern="{{${KEY}}}"
      # Use bash built-in string replacement (handles newlines safely)
      text="${text//$pattern/$decoded_value}"
    done <<< "$DECODED_VARS"
  fi
  printf '%s' "$text"
}

PROMPT_SYS=$(substitute "$PROMPT_SYS")
PROMPT_USER=$(substitute "$PROMPT_USER")

###############################################################################
# Call the OpenAI API                                                         #
###############################################################################
[[ -z ${OPENAI_API_KEY:-} ]] && { echo "❌ OPENAI_API_KEY secret not set" >&2; exit 1; }

# Load schema if provided
SCHEMA_JSON="{}"
if [[ -n $SCHEMA ]]; then
  [[ ! -f $SCHEMA ]] && { echo "❌ schema file '$SCHEMA' not found" >&2; exit 1; }
  SCHEMA_JSON=$(cat "$SCHEMA")
fi

# jq 1.5‑compatible payload construction with optional structured output
REQUEST=$(
  jq -n \
    --arg model  "$MODEL" \
    --arg sys    "$PROMPT_SYS" \
    --arg user   "$PROMPT_USER" \
    --arg temp   "$TEMP" \
    --arg tokens "$TOKENS" \
    --argjson schema "$SCHEMA_JSON" \
    --arg has_schema "$([[ -n $SCHEMA ]] && echo "true" || echo "false")" \
    '
    {
      "model": $model,
      "messages":
        ( if ($sys | length) == 0
          then [ { "role": "user",   "content": $user } ]
          else [ { "role": "system", "content": $sys  },
                { "role": "user",   "content": $user } ]
          end ),
      "temperature": ($temp   | tonumber),
      "max_tokens":  ($tokens | tonumber)
    } + 
    ( if $has_schema == "true" 
      then { "response_format": { "type": "json_schema", "json_schema": { "name": "response", "schema": $schema } } }
      else {}
      end )'
)

RESPONSE=$(curl -sS \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$REQUEST" \
  https://api.openai.com/v1/chat/completions)

# Check for API errors
if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
  echo "❌ OpenAI API Error:" >&2
  echo "$RESPONSE" | jq -r '.error.message // .error' >&2
  exit 1
fi

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

###############################################################################
# Process output template (if provided)                                       #
###############################################################################
FORMATTED_CONTENT=""
if [[ -n $OUTPUT ]]; then
  [[ ! -f $OUTPUT ]] && { echo "❌ output template '$OUTPUT' not found" >&2; exit 1; }
  
  # Load output template
  OUTPUT_TEMPLATE=$(cat "$OUTPUT")
  
  # If we have structured JSON response, process the template
  if [[ -n $SCHEMA ]] && echo "$CONTENT" | jq . >/dev/null 2>&1; then
    # Parse JSON and create a combined context for template processing
    TEMPLATE_CONTEXT=$(echo "$CONTENT" | jq -c .)
    
    # Simple template processing for {{variable}} substitution
    FORMATTED_CONTENT="$OUTPUT_TEMPLATE"
    
    # Add VARS to context for VERSION, DATE, etc.
    if [[ -n $VARS ]]; then
      # Decode base64 vars if it looks like base64 (no newlines, only base64 chars)
      if echo "$VARS" | grep -qE '^[A-Za-z0-9+/=]*$' && [[ $(echo "$VARS" | wc -l) -eq 1 ]]; then
        DECODED_VARS=$(echo "$VARS" | base64 -d)
      else
        DECODED_VARS="$VARS"
      fi
      
      while IFS='=' read -r KEY VALUE; do
        [[ -z $KEY ]] && continue
        # Decode escaped newlines from GitHub Actions variable passing
        decoded_value=$(printf '%s' "$VALUE" | tr '\020' '\n')
        
        # Use bash parameter substitution for multi-line content (safer than sed)
        pattern="{{${KEY}}}"
        FORMATTED_CONTENT="${FORMATTED_CONTENT//$pattern/$decoded_value}"
      done <<< "$DECODED_VARS"
    fi
    
    # JSON field substitution - handle both simple and nested properties
    # Handle simple fields
    while IFS= read -r field; do
      [[ -z $field ]] && continue
      key=$(echo "$field" | cut -d':' -f1 | tr -d '"')
      value=$(echo "$CONTENT" | jq -r ".$key // empty" 2>/dev/null || echo "")
      if [[ -n $value && $value != "null" ]]; then
        # Use bash parameter substitution (safer for any content)
        pattern="{{${key}}}"
        FORMATTED_CONTENT="${FORMATTED_CONTENT//$pattern/$value}"
      fi
    done <<< "$(echo "$CONTENT" | jq -r 'to_entries[] | select(.value | type == "string" or type == "number") | "\(.key):\(.value)"' 2>/dev/null || true)"
    
    # Handle nested object properties (e.g., commit_analysis.total_commits)
    # Simple approach: just handle the common cases we know about
    if echo "$CONTENT" | jq -e '.commit_analysis' >/dev/null 2>&1; then
      total_commits=$(echo "$CONTENT" | jq -r '.commit_analysis.total_commits // 0')
      conventional_commits=$(echo "$CONTENT" | jq -r '.commit_analysis.conventional_commits // 0')
      suggestions=$(echo "$CONTENT" | jq -r '.commit_analysis.suggestions // "N/A"')
      
      # Use bash parameter substitution for commit analysis fields
      FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{commit_analysis.total_commits\}\}/$total_commits}"
      FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{commit_analysis.conventional_commits\}\}/$conventional_commits}"
      
      # Handle suggestions carefully (could contain special characters)
      if [[ $suggestions != "N/A" && $suggestions != "null" ]]; then
        # Only replace if suggestions block exists
        FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "/{{#if commit_analysis.suggestions}}/,/{{\/if}}/d")
        FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{commit_analysis.suggestions\}\}/$suggestions}"
      else
        # Remove the entire conditional block
        FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "/{{#if commit_analysis.suggestions}}/,/{{\/if}}/d")
      fi
    fi
    
    # Handle arrays for {{#each array}} patterns - special case for complex structures
    # Handle the 'changes' array specially since it has nested structure
    if echo "$CONTENT" | jq -e '.changes' >/dev/null 2>&1; then
      # Build the formatted changes section using temp files to avoid subshell issues
      changes_temp=$(mktemp)
      echo "$CONTENT" | jq -c '.changes[]' 2>/dev/null > "$changes_temp"
      
      changes_section=""
      while IFS= read -r change_obj; do
        [[ -z $change_obj ]] && continue
        theme=$(echo "$change_obj" | jq -r '.theme // "Other"')
        changes_section="$changes_section- **$theme:**"$'\n'
        
        # Get the nested changes array for this theme
        items_temp=$(mktemp)
        echo "$change_obj" | jq -r '.changes[]? // empty' > "$items_temp"
        
        while IFS= read -r change_item; do
          [[ -z $change_item ]] && continue
          changes_section="$changes_section  - $change_item"$'\n'
        done < "$items_temp"
        rm -f "$items_temp"
        
      done < "$changes_temp"
      rm -f "$changes_temp"
      
      # Replace the {{#each changes}}...{{/each}} block
      temp_file=$(mktemp)
      printf '%s' "$FORMATTED_CONTENT" > "$temp_file"
      
      if grep -q "{{#each changes}}" "$temp_file"; then
        # Find line numbers for the outer changes block
        start_line=$(grep -n "{{#each changes}}" "$temp_file" | head -1 | cut -d: -f1)
        end_line=$(grep -n "{{/each}}" "$temp_file" | tail -1 | cut -d: -f1)
        
        if [[ -n $start_line && -n $end_line ]]; then
          # Replace the range with our formatted changes
          {
            head -n $((start_line - 1)) "$temp_file"
            printf '%s' "$changes_section"
            tail -n +$((end_line + 1)) "$temp_file"
          } > "${temp_file}.new"
          FORMATTED_CONTENT=$(cat "${temp_file}.new")
          rm -f "${temp_file}.new"
        fi
      fi
      rm -f "$temp_file"
    fi
    
    # Handle other simple arrays
    for array_key in $(echo "$CONTENT" | jq -r 'to_entries[] | select(.value | type == "array" and .key != "changes") | .key' 2>/dev/null || true); do
      array_items=$(echo "$CONTENT" | jq -r ".$array_key[]? // empty" 2>/dev/null || true)
      if [[ -n $array_items ]]; then
        # Create bullet list
        formatted_list=""
        while IFS= read -r item; do
          [[ -z $item ]] && continue
          formatted_list="${formatted_list}- ${item}"$'\n'
        done <<< "$array_items"
        
        # Use a temp file approach for safe replacement
        temp_file=$(mktemp)
        printf '%s' "$FORMATTED_CONTENT" > "$temp_file"
        
        # Replace the {{#each}}...{{/each}} block
        if grep -q "{{#each $array_key}}" "$temp_file"; then
          # Find line numbers
          start_line=$(grep -n "{{#each $array_key}}" "$temp_file" | head -1 | cut -d: -f1)
          end_line=$(grep -n "{{/each}}" "$temp_file" | head -1 | cut -d: -f1)
          
          if [[ -n $start_line && -n $end_line ]]; then
            # Replace the range with our list
            {
              head -n $((start_line - 1)) "$temp_file"
              printf '%s' "$formatted_list"
              tail -n +$((end_line + 1)) "$temp_file"
            } > "${temp_file}.new"
            FORMATTED_CONTENT=$(cat "${temp_file}.new")
            rm -f "${temp_file}.new"
          fi
        fi
        rm -f "$temp_file"
      fi
    done
    
    # Very simple template processing - just remove empty {{#if}} blocks
    # Process each section individually
    for section in added changed deprecated removed fixed security; do
      count=$(echo "$CONTENT" | jq -r ".$section // [] | length" 2>/dev/null || echo "0")
      if [[ $count -eq 0 ]]; then
        # Remove the entire {{#if section}}...{{/if}} block
        FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "/{{#if $section}}/,/{{\/if}}/d")
             else
         # Keep the block but remove the {{#if}} and {{/if}} markers
         FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "s/{{#if $section}}//g")
         FORMATTED_CONTENT=$(printf '%s' "$FORMATTED_CONTENT" | sed "s/{{\/if}}//g")
       fi
    done
    
  else
    # For non-structured response, just do variable substitution
    FORMATTED_CONTENT=$(substitute "$OUTPUT_TEMPLATE")
    # Replace {{content}} with the raw response using bash parameter substitution
    FORMATTED_CONTENT="${FORMATTED_CONTENT//\{\{content\}\}/$CONTENT}"
  fi
else
  FORMATTED_CONTENT="$CONTENT"
fi

###############################################################################
# Emit outputs                                                                #
###############################################################################
{
  echo "content<<EOF"
  echo "$CONTENT"
  echo "EOF"
} >> "$GITHUB_OUTPUT"

{
  echo "formatted_content<<EOF"
  echo "$FORMATTED_CONTENT"
  echo "EOF"
} >> "$GITHUB_OUTPUT"
