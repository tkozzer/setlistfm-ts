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
    
    # Parse variables using a more robust approach that handles multiline values
    local current_key=""
    local current_value=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Check if this line starts a new KEY=VALUE pair
      if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
        # Process previous key-value pair if we have one
        if [[ -n "$current_key" ]]; then
          # Decode escaped newlines from GitHub Actions variable passing
          local decoded_value
          decoded_value=$(printf '%s' "$current_value" | tr '\020' '\n')
          
          # Use bash parameter substitution for multi-line content
          local pattern="{{${current_key}}}"
          text="${text//$pattern/$decoded_value}"
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
    done <<< "$DECODED_VARS"
    
    # Process the final key-value pair
    if [[ -n "$current_key" ]]; then
      # Decode escaped newlines from GitHub Actions variable passing
      local decoded_value
      decoded_value=$(printf '%s' "$current_value" | tr '\020' '\n')
      
      # Use bash parameter substitution for multi-line content
      local pattern="{{${current_key}}}"
      text="${text//$pattern/$decoded_value}"
    fi
  fi
  printf '%s' "$text"
}

PROMPT_SYS=$(substitute "$PROMPT_SYS")
PROMPT_USER=$(substitute "$PROMPT_USER")

###############################################################################
# Call the OpenAI API (or use test mode)                                      #
###############################################################################

# Check if we're in test mode
if [[ ${OPENAI_TEST_MODE:-false} == "true" ]]; then
  echo "🧪 Test mode enabled - using mock data instead of OpenAI API" >&2
  
  # Determine which mock file to use based on template/output filename
  MOCK_FILE=""
  # Try different possible mock directory paths
  POSSIBLE_MOCK_DIRS=(
    ".github/tests/fixtures/integration"
    "../../tests/fixtures/integration"
    "../tests/fixtures/integration"
    "tests/fixtures/integration"
  )
  
  MOCK_DIR=""
  for dir in "${POSSIBLE_MOCK_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      MOCK_DIR="$dir"
      break
    fi
  done
  
  if [[ -z $MOCK_DIR ]]; then
    echo "❌ No mock directory found. Tried:" >&2
    for dir in "${POSSIBLE_MOCK_DIRS[@]}"; do
      echo "  - $dir" >&2
    done
    exit 1
  fi
  
  echo "📁 Using mock directory: $MOCK_DIR" >&2
  
  # Check output template first (more specific)
  if [[ -n $OUTPUT ]]; then
    if [[ $OUTPUT =~ changelog ]]; then
      MOCK_FILE="$MOCK_DIR/changelog.json"
    elif [[ $OUTPUT =~ pr-enhancement ]]; then
      MOCK_FILE="$MOCK_DIR/pr-enhancement.json"
    elif [[ $OUTPUT =~ pr-description ]]; then
      MOCK_FILE="$MOCK_DIR/pr-description.json"
    elif [[ $OUTPUT =~ release-notes ]]; then
      # Release notes fixtures are in the processors directory
      PROCESSORS_MOCK_DIR="${MOCK_DIR%/integration}/processors"
      MOCK_FILE="$PROCESSORS_MOCK_DIR/release-notes.json"
    else
      MOCK_FILE="$MOCK_DIR/generic.json"
    fi
  # Fall back to checking template filename
  elif [[ -n $TEMPLATE ]]; then
    if [[ $TEMPLATE =~ changelog ]]; then
      MOCK_FILE="$MOCK_DIR/changelog.json"
    elif [[ $TEMPLATE =~ pr-enhancement ]]; then
      MOCK_FILE="$MOCK_DIR/pr-enhancement.json"
    elif [[ $TEMPLATE =~ pr-description ]]; then
      MOCK_FILE="$MOCK_DIR/pr-description.json"
    elif [[ $TEMPLATE =~ release-notes ]]; then
      # Release notes fixtures are in the processors directory
      PROCESSORS_MOCK_DIR="${MOCK_DIR%/integration}/processors"
      MOCK_FILE="$PROCESSORS_MOCK_DIR/release-notes.json"
    else
      MOCK_FILE="$MOCK_DIR/generic.json"
    fi
  else
    # Default to generic mock
    MOCK_FILE="$MOCK_DIR/generic.json"
  fi
  
  # Check if mock file exists
  if [[ ! -f $MOCK_FILE ]]; then
    echo "❌ Mock file not found: $MOCK_FILE" >&2
    echo "Available fixtures:" >&2
    ls -la "$MOCK_DIR"/ >&2 || echo "Mock directory not found: $MOCK_DIR" >&2
    exit 1
  fi
  
  echo "📁 Using mock file: $MOCK_FILE" >&2
  
  # Load mock content as the AI response
  CONTENT=$(cat "$MOCK_FILE")
  
  # Validate it's valid JSON
  if ! echo "$CONTENT" | jq empty >/dev/null 2>&1; then
    echo "❌ Invalid JSON in mock file: $MOCK_FILE" >&2
    exit 1
  fi
  
  echo "✅ Successfully loaded mock data" >&2
  
else
  # Production mode - call OpenAI API
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
fi

###############################################################################
# Process output template with appropriate processor                          #
###############################################################################
FORMATTED_CONTENT=""
if [[ -n $OUTPUT ]]; then
  [[ ! -f $OUTPUT ]] && { echo "❌ output template '$OUTPUT' not found" >&2; exit 1; }
  
  # Determine which processor to use based on output template filename
  PROCESSOR="generic"
  
  if [[ $OUTPUT =~ changelog ]]; then
    PROCESSOR="changelog"
  elif [[ $OUTPUT =~ pr-enhancement ]]; then
    PROCESSOR="pr-enhancement" 
  elif [[ $OUTPUT =~ pr-description ]]; then
    PROCESSOR="pr-description"
  elif [[ $OUTPUT =~ release-notes ]]; then
    PROCESSOR="release-notes"
  fi
  
  # Find the processor script path
  PROCESSOR_SCRIPT="generic.sh"
  if [[ $PROCESSOR == "changelog" ]]; then
    PROCESSOR_SCRIPT="changelog.sh"
  elif [[ $PROCESSOR == "pr-enhancement" ]]; then
    PROCESSOR_SCRIPT="pr-enhance.sh"
  elif [[ $PROCESSOR == "pr-description" ]]; then
    PROCESSOR_SCRIPT="pr-description.sh"
  elif [[ $PROCESSOR == "release-notes" ]]; then
    PROCESSOR_SCRIPT="release-notes.sh"
  fi
  
  # Try different possible processor directory paths
  POSSIBLE_PROCESSOR_DIRS=(
    ".github/actions/openai-chat/processors"
    "../../actions/openai-chat/processors"
    "../actions/openai-chat/processors"
    "actions/openai-chat/processors"
  )
  
  PROCESSOR_PATH=""
  for dir in "${POSSIBLE_PROCESSOR_DIRS[@]}"; do
    if [[ -f "$dir/$PROCESSOR_SCRIPT" ]]; then
      PROCESSOR_PATH="$dir/$PROCESSOR_SCRIPT"
      break
    fi
  done
  
  if [[ -z $PROCESSOR_PATH ]]; then
    echo "❌ Processor script not found: $PROCESSOR_SCRIPT" >&2
    echo "Tried directories:" >&2
    for dir in "${POSSIBLE_PROCESSOR_DIRS[@]}"; do
      echo "  - $dir" >&2
    done
    exit 1
  fi
  
  # Log which processor is being used
  echo "🔄 Using processor: $PROCESSOR" >&2
  
  # Use appropriate processor
  if [[ -f $PROCESSOR_PATH ]]; then
    echo "📝 Processing with $PROCESSOR processor..." >&2
    
    # Prepare arguments for processor
    PROCESSOR_ARGS=()
    
    # Content (JSON from AI response)
    PROCESSOR_ARGS+=("$CONTENT")
    
    # Template file
    PROCESSOR_ARGS+=("$OUTPUT")
    
    # Variables (base64 encoded or raw)
    if [[ -n $VARS ]]; then
      PROCESSOR_ARGS+=("$VARS")
    else
      PROCESSOR_ARGS+=("")
    fi
    
    # Call the processor
    if FORMATTED_CONTENT=$("$PROCESSOR_PATH" "${PROCESSOR_ARGS[@]}"); then
      echo "✅ $PROCESSOR processor completed successfully" >&2
    else
      echo "❌ $PROCESSOR processor failed" >&2
      exit 1
    fi
  else
    echo "❌ Processor not found: $PROCESSOR_PATH" >&2
    exit 1
  fi
else
  FORMATTED_CONTENT="$CONTENT"
  echo "📝 No output template provided, using raw content" >&2
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
