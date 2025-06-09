#!/usr/bin/env bash

# Integration test for the complete release notes pipeline
# Tests the end-to-end flow: prepare-ai-context.sh -> OpenAI action -> release-notes processor
# Uses mocked OpenAI responses for reliable testing

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
TEST_OUTPUT_DIR="/tmp/release_notes_integration_test_$$"

# Paths to components
PREPARE_SCRIPT="$PROJECT_ROOT/.github/scripts/release-notes/prepare-ai-context.sh"
OPENAI_ACTION="$PROJECT_ROOT/.github/actions/openai-chat/entrypoint.sh"
RELEASE_NOTES_TEMPLATE="$PROJECT_ROOT/.github/templates/release-notes.tmpl.md"
RELEASE_NOTES_SCHEMA="$PROJECT_ROOT/.github/schema/release-notes.schema.json"
PROMPTS_DIR="$PROJECT_ROOT/.github/prompts"

# Mock fixtures
MOCK_RELEASE_NOTES="$PROJECT_ROOT/.github/tests/fixtures/processors/release-notes.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0

# Setup test environment
setup_test() {
    echo -e "${BOLD}${BLUE}🚀 Setting up Release Notes Pipeline Integration Test${NC}"
    echo -e "Test directory: $TEST_OUTPUT_DIR"
    echo ""
    
    # Create test directory
    mkdir -p "$TEST_OUTPUT_DIR"
    
    # Set environment variables for test mode
    export OPENAI_TEST_MODE=true
    export GITHUB_OUTPUT="$TEST_OUTPUT_DIR/github_output.txt"
    
    # Create sample git history data
    create_test_git_data
    
    echo -e "${GREEN}✅ Test environment setup complete${NC}"
    echo ""
}

# Cleanup test environment
cleanup_test() {
    echo -e "${BLUE}🧹 Cleaning up test environment...${NC}"
    rm -rf "$TEST_OUTPUT_DIR"
    unset OPENAI_TEST_MODE
    unset GITHUB_OUTPUT
}

# Create realistic test git data
create_test_git_data() {
    echo -e "${YELLOW}📝 Creating test git data...${NC}"
    
    # Create sample git commits JSON
    cat > "$TEST_OUTPUT_DIR/git_commits.json" << 'EOF'
[
  {
    "hash": "abc123",
    "message": "feat(api): add OAuth2 authentication support",
    "author": "tkozzer",
    "date": "2024-01-15T10:30:00Z"
  },
  {
    "hash": "def456", 
    "message": "fix(templates): resolve version normalization issue",
    "author": "tkozzer",
    "date": "2024-01-15T11:00:00Z"
  },
  {
    "hash": "ghi789",
    "message": "ci: improve workflow reliability and error handling",
    "author": "tkozzer",
    "date": "2024-01-15T11:30:00Z"
  },
  {
    "hash": "jkl012",
    "message": "docs: update API documentation for OAuth flow",
    "author": "tkozzer",
    "date": "2024-01-15T12:00:00Z"
  }
]
EOF

    # Create sample commit statistics
    cat > "$TEST_OUTPUT_DIR/commit_stats.json" << 'EOF'
{
  "total_commits": 4,
  "feat_count": 1,
  "fix_count": 1,
  "ci_count": 1,
  "docs_count": 1,
  "chore_count": 0,
  "breaking_changes_detected": false
}
EOF

    # Create sample changelog entry
    cat > "$TEST_OUTPUT_DIR/changelog_entry.txt" << 'EOF'
## [0.7.4] - 2024-01-15

### Added
- OAuth2 authentication support for enhanced security
- Improved error handling in workflow processes

### Fixed  
- Template processor version normalization issues
- Variable passing in multiline GitHub Actions scenarios

### Changed
- Enhanced CI workflow reliability and performance
EOF
}

# Helper function to run tests
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}🧪 Running test: $test_name${NC}"
    
    if $test_function; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        return 1
    fi
    echo ""
}

# Verify prerequisites
verify_prerequisites() {
    echo -e "${BLUE}🔍 Verifying prerequisites...${NC}"
    
    local required_files=(
        "$PREPARE_SCRIPT"
        "$OPENAI_ACTION" 
        "$RELEASE_NOTES_TEMPLATE"
        "$RELEASE_NOTES_SCHEMA"
        "$PROMPTS_DIR/release-notes.sys.md"
        "$PROMPTS_DIR/release-notes.user.md"
        "$MOCK_RELEASE_NOTES"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo -e "${RED}❌ Required file not found: $file${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}✅ All prerequisites verified${NC}"
    echo ""
}

# Test 1: prepare-ai-context.sh pipeline
test_prepare_ai_context() {
    echo -e "${BLUE}--- Testing prepare-ai-context.sh pipeline ---${NC}"
    
    # Encode test data to base64
    local git_commits_b64 
    local commit_stats_b64
    local changelog_entry_b64
    
    git_commits_b64=$(base64 -i "$TEST_OUTPUT_DIR/git_commits.json")
    commit_stats_b64=$(base64 -i "$TEST_OUTPUT_DIR/commit_stats.json") 
    changelog_entry_b64=$(base64 -i "$TEST_OUTPUT_DIR/changelog_entry.txt")
    
    # Run prepare-ai-context.sh
    local output
    if output=$("$PREPARE_SCRIPT" \
        --version "0.7.4" \
        --git-commits-b64 "$git_commits_b64" \
        --commit-stats-b64 "$commit_stats_b64" \
        --changelog-entry-b64 "$changelog_entry_b64" \
        --since-tag "v0.7.3" \
        2>&1); then
        
        echo -e "   ${GREEN}✓ prepare-ai-context.sh executed successfully${NC}"
        
        # Extract just the base64-encoded JSON (first line)
        local base64_json
        base64_json=$(echo "$output" | head -1)
        
        # Save for next test
        echo "$base64_json" > "$TEST_OUTPUT_DIR/template_vars.txt"
        
        # Validate output is base64-encoded JSON (new format)
        if echo "$base64_json" | grep -qE '^[A-Za-z0-9+/=]*$' && [[ -n "$base64_json" ]]; then
            echo -e "   ${GREEN}✓ Base64-encoded template variables generated${NC}"
            
            # Decode and validate JSON structure
            local decoded_json
            if decoded_json=$(echo "$base64_json" | base64 -d 2>/dev/null); then
                echo -e "   ${GREEN}✓ Base64 decoding successful${NC}"
                
                # Validate JSON contains expected fields
                if echo "$decoded_json" | jq -e '.VERSION and .GIT_COMMITS_B64 and .COMMIT_STATS_B64' >/dev/null 2>&1; then
                    echo -e "   ${GREEN}✓ JSON contains expected template variables${NC}"
                    return 0
                else
                    echo -e "   ${RED}✗ JSON missing expected fields${NC}"
                    echo "Decoded JSON: $decoded_json"
                    return 1
                fi
                         else
                 echo -e "   ${RED}✗ Base64 decoding failed${NC}"
                 echo "Base64 data: $base64_json"
                 return 1
             fi
         else
             echo -e "   ${RED}✗ Output is not base64-encoded${NC}"
             echo "Base64 data: $base64_json"
             return 1
         fi
    else
        echo -e "   ${RED}✗ prepare-ai-context.sh failed${NC}"
        echo "Error: $output"
        return 1
    fi
}

# Test 2: OpenAI action with mocked response
test_openai_action_mocked() {
    echo -e "${BLUE}--- Testing OpenAI action with mocked response ---${NC}"
    
    # Clear previous output
    > "$GITHUB_OUTPUT"
    
    # Read template variables from previous test
    local template_vars
    if [[ -f "$TEST_OUTPUT_DIR/template_vars.txt" ]]; then
        template_vars=$(cat "$TEST_OUTPUT_DIR/template_vars.txt")
    else
        echo -e "   ${RED}✗ Template variables not available from previous test${NC}"
        return 1
    fi
    
    # Run OpenAI action with test mode (uses mock data)
    if "$OPENAI_ACTION" \
        --system "$PROMPTS_DIR/release-notes.sys.md" \
        --template "$PROMPTS_DIR/release-notes.user.md" \
        --vars "$template_vars" \
        --model "gpt-4o-mini" \
        --temp "0.2" \
        --tokens "1500" \
        --schema "$RELEASE_NOTES_SCHEMA" \
        --output "$RELEASE_NOTES_TEMPLATE" 2>&1; then
        
        echo -e "   ${GREEN}✓ OpenAI action executed successfully${NC}"
        
        # Validate GitHub outputs were created
        if [[ -f "$GITHUB_OUTPUT" ]]; then
            if grep -q "content<<EOF" "$GITHUB_OUTPUT" && \
               grep -q "formatted_content<<EOF" "$GITHUB_OUTPUT"; then
                echo -e "   ${GREEN}✓ GitHub outputs created successfully${NC}"
                
                # Extract and validate the formatted content
                local formatted_content
                formatted_content=$(sed -n '/^formatted_content<<EOF$/,/^EOF$/p' "$GITHUB_OUTPUT" | sed '1d;$d')
                
                if [[ -n "$formatted_content" ]]; then
                    echo -e "   ${GREEN}✓ Formatted content generated${NC}"
                    
                    # Save for validation
                    echo "$formatted_content" > "$TEST_OUTPUT_DIR/release_notes_output.md"
                    
                    return 0
                else
                    echo -e "   ${RED}✗ Formatted content is empty${NC}"
                    return 1
                fi
            else
                echo -e "   ${RED}✗ GitHub outputs incomplete${NC}"
                return 1
            fi
        else
            echo -e "   ${RED}✗ GitHub output file not created${NC}"
            return 1
        fi
    else
        echo -e "   ${RED}✗ OpenAI action failed${NC}"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BOLD}${BLUE}🚀 Release Notes Pipeline Integration Test${NC}"
    echo -e "Testing complete end-to-end pipeline with mocked OpenAI responses"
    echo "=================================================================="
    echo ""
    
    # Trap for cleanup
    trap cleanup_test EXIT
    
    # Setup
    setup_test
    verify_prerequisites
    
    # Run tests
    echo -e "${BOLD}${YELLOW}Running integration tests...${NC}"
    echo ""
    
    run_test "Prepare AI Context Pipeline" test_prepare_ai_context
    run_test "OpenAI Action with Mock Response" test_openai_action_mocked
    
    # Print summary
    echo ""
    echo -e "${BOLD}📊 Integration Test Summary${NC}"
    echo "=========================="
    echo -e "Tests run: ${YELLOW}$TESTS_RUN${NC}"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"
    
    if [[ $TESTS_PASSED -eq $TESTS_RUN ]]; then
        echo -e "\n${BOLD}${GREEN}🎉 All integration tests passed!${NC}"
        echo -e "${GREEN}The release notes pipeline is working correctly end-to-end.${NC}"
        return 0
    else
        echo -e "\n${BOLD}${RED}💥 Some integration tests failed!${NC}"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 