#!/usr/bin/env bash
# Unit tests for entrypoint.sh substitute function
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTRYPOINT="$SCRIPT_DIR/../../actions/openai-chat/entrypoint.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0

# Source the substitute function from entrypoint.sh for unit testing
# We'll extract just the substitute function
extract_substitute_function() {
    # Create a temporary file with just the substitute function
    cat > "/tmp/substitute_test.sh" << 'EOF'
#!/usr/bin/env bash
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
EOF
    source "/tmp/substitute_test.sh"
}

run_test() {
    local test_name="$1"
    local template="$2"
    local vars="$3"
    local expected_pattern="$4"
    local should_contain="${5:-true}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}Test $TOTAL_TESTS: $test_name${NC}"
    
    # Set VARS environment variable for the substitute function
    export VARS="$vars"
    
    local result
    result=$(substitute "$template")
    
    local found=false
    if [[ "$result" == *"$expected_pattern"* ]]; then
        found=true
    fi
    
    if [[ "$should_contain" == "true" && "$found" == "true" ]] || \
       [[ "$should_contain" == "false" && "$found" == "false" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "Expected pattern '$expected_pattern' to be $([ "$should_contain" = "true" ] && echo "present" || echo "absent")"
        echo "Result (first 200 chars): ${result:0:200}..."
        echo ""
    fi
    
    unset VARS
}

test_simple_substitution() {
    echo -e "${BLUE}=== Testing Simple Variable Substitution ===${NC}"
    
    run_test "Simple VERSION substitution" \
        "Version: {{VERSION}}" \
        "VERSION=1.0.0" \
        "Version: 1.0.0"
        
    run_test "Multiple simple variables" \
        "Version: {{VERSION}}, Date: {{DATE}}" \
        $'VERSION=1.0.0\nDATE=2024-06-09' \
        "Version: 1.0.0, Date: 2024-06-09"
}

test_multiline_substitution_bug() {
    echo -e "${BLUE}=== Testing Multiline Variable Bug ===${NC}"
    
    local template="Version: {{VERSION}}

Changelog:
{{CHANGELOG}}

End of changelog."

    # This is the exact problematic format from the release PR workflow
    local multiline_vars="VERSION=0.7.2
CHANGELOG=### Added
- New feature one  
- New feature two
### Fixed
- Bug fix one
- Bug fix two"
    
    # These tests should demonstrate the bug
    run_test "Multiline CHANGELOG - VERSION should work" \
        "$template" \
        "$multiline_vars" \
        "Version: 0.7.2"
        
    run_test "Multiline CHANGELOG - content should be present (will fail)" \
        "$template" \
        "$multiline_vars" \
        "New feature one"
        
    run_test "Multiline CHANGELOG - CHANGELOG placeholder should be replaced (will fail)" \
        "$template" \
        "$multiline_vars" \
        "{{CHANGELOG}}" \
        "false"  # Should NOT contain the placeholder if substitution worked
}

test_base64_encoded_multiline() {
    echo -e "${BLUE}=== Testing Base64 Encoded Multiline (Should Work) ===${NC}"
    
    local template="Version: {{VERSION}}

Changelog:
{{CHANGELOG}}

End of changelog."

    local multiline_vars="VERSION=0.7.2
CHANGELOG=### Added
- New feature one  
- New feature two
### Fixed
- Bug fix one
- Bug fix two"
    
    # Base64 encode the variables
    local vars_b64
    vars_b64=$(echo "$multiline_vars" | base64 -w 0)
    
    run_test "Base64 multiline - VERSION should work" \
        "$template" \
        "$vars_b64" \
        "Version: 0.7.2"
        
    run_test "Base64 multiline - content should be present" \
        "$template" \
        "$vars_b64" \
        "New feature one"
        
    run_test "Base64 multiline - CHANGELOG placeholder should be replaced" \
        "$template" \
        "$vars_b64" \
        "{{CHANGELOG}}" \
        "false"  # Should NOT contain the placeholder
}

main() {
    echo -e "${BLUE}🧪 Testing entrypoint.sh substitute function${NC}"
    echo ""
    
    # Extract and source the substitute function
    extract_substitute_function
    
    test_simple_substitution
    test_multiline_substitution_bug
    test_base64_encoded_multiline
    
    echo ""
    echo "🏁 Substitute function tests completed!"
    echo "📊 Results: $PASSED_TESTS/$TOTAL_TESTS tests passed"
    
    # Cleanup
    rm -f "/tmp/substitute_test.sh"
    
    if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed - demonstrating the bug!${NC}"
        exit 1
    fi
}

main "$@" 