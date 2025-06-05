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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --system  ) SYSTEM="$2";   shift 2 ;;
    --template) TEMPLATE="$2"; shift 2 ;;
    --vars    ) VARS="$2";     shift 2 ;;
    --model   ) MODEL="$2";    shift 2 ;;
    --temp    ) TEMP="$2";     shift 2 ;;
    --tokens  ) TOKENS="$2";   shift 2 ;;
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
    while IFS='=' read -r KEY VALUE; do
      [[ -z $KEY ]] && continue
      # sed separator is | to avoid escaping /
      text=$(printf '%s' "$text" | sed -e "s|{{${KEY}}}|${VALUE//|/\\|}|g")
    done <<< "$VARS"
  fi
  printf '%s' "$text"
}

PROMPT_SYS=$(substitute "$PROMPT_SYS")
PROMPT_USER=$(substitute "$PROMPT_USER")

###############################################################################
# Call the OpenAI API                                                         #
###############################################################################
[[ -z ${OPENAI_API_KEY:-} ]] && { echo "❌ OPENAI_API_KEY secret not set" >&2; exit 1; }

# jq 1.5‑compatible payload construction
REQUEST=$(
  jq -n \
    --arg model  "$MODEL" \
    --arg sys    "$PROMPT_SYS" \
    --arg user   "$PROMPT_USER" \
    --arg temp   "$TEMP" \
    --arg tokens "$TOKENS" \
    '
    {
      "model": $model,
      "messages":
        ( ($sys | length) == 0
          ? []
          : [ { "role": "system", "content": $sys } ]
        )
        + [ { "role": "user", "content": $user } ],
      "temperature": ($temp   | tonumber),
      "max_tokens":  ($tokens | tonumber)
    }'
)

RESPONSE=$(curl -sS \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$REQUEST" \
  https://api.openai.com/v1/chat/completions)

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

###############################################################################
# Emit outputs                                                                #
###############################################################################
{
  echo "content<<EOF"
  echo "$CONTENT"
  echo "EOF"
} >> "$GITHUB_OUTPUT"
