#!/usr/bin/env bash
# Test script for entrypoint.sh integration testing with mock data

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTRYPOINT="$SCRIPT_DIR/../../actions/openai-chat/entrypoint.sh"
TEMPLATES_DIR="$SCRIPT_DIR/../../templates"
FIXTURES_DIR="$SCRIPT_DIR/../fixtures/integration"
TEST_OUTPUT_DIR="$SCRIPT_DIR/test-outputs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Setup
setup_test() {
    echo -e "${BLUE}🧪 Setting up integration tests...${NC}"
    mkdir -p "$TEST_OUTPUT_DIR"
    export OPENAI_TEST_MODE=true
    export GITHUB_OUTPUT="$TEST_OUTPUT_DIR/github_output.txt"
}

# Cleanup
cleanup_test() {
    echo -e "${BLUE}🧹 Cleaning up test outputs...${NC}"
    rm -rf "$TEST_OUTPUT_DIR"
}

# Test helper functions
run_test() {
    local test_name="$1"
    local expected_to_pass="$2"
    shift 2
    local cmd=("$@")
    
    echo -e "${YELLOW}Testing: $test_name${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Clear previous output
    > "$GITHUB_OUTPUT"
    
    # Run the command and capture output
    if output=$("${cmd[@]}" 2>&1); then
        if [[ $expected_to_pass == "true" ]]; then
            echo -e "${GREEN}✅ PASS: $test_name${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            
            # Validate GitHub outputs were created
            if [[ -f $GITHUB_OUTPUT ]]; then
                if grep -q "content<<EOF" "$GITHUB_OUTPUT" && grep -q "formatted_content<<EOF" "$GITHUB_OUTPUT"; then
                    echo -e "   ${GREEN}✓ GitHub outputs created successfully${NC}"
                else
                    echo -e "   ${YELLOW}⚠ GitHub outputs incomplete${NC}"
                fi
            fi
        else
            echo -e "${RED}❌ UNEXPECTED PASS: $test_name${NC}"
            echo -e "   Expected failure but command succeeded"
            echo -e "   Output: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        if [[ $expected_to_pass == "false" ]]; then
            echo -e "${GREEN}✅ EXPECTED FAIL: $test_name${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ FAIL: $test_name${NC}"
            echo -e "   Output: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
    echo ""
}

# Verify prerequisites
verify_prerequisites() {
    echo -e "${BLUE}🔍 Verifying prerequisites...${NC}"
    
    if [[ ! -f $ENTRYPOINT ]]; then
        echo -e "${RED}❌ Entrypoint not found: $ENTRYPOINT${NC}"
        exit 1
    fi
    
    if [[ ! -d $TEMPLATES_DIR ]]; then
        echo -e "${RED}❌ Templates directory not found: $TEMPLATES_DIR${NC}"
        exit 1
    fi
    
    if [[ ! -d $FIXTURES_DIR ]]; then
        echo -e "${RED}❌ Fixtures directory not found: $FIXTURES_DIR${NC}"
        exit 1
    fi
    
    # Check for required fixture files
    local required_fixtures=(
        "changelog.json"
        "pr-enhancement.json" 
        "pr-description.json"
        "generic.json"
        "error-scenarios.json"
    )
    
    for fixture in "${required_fixtures[@]}"; do
        if [[ ! -f "$FIXTURES_DIR/$fixture" ]]; then
            echo -e "${RED}❌ Required fixture file not found: $FIXTURES_DIR/$fixture${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}✅ All prerequisites verified${NC}"
    echo ""
}

# Test cases
test_changelog_processing() {
    echo -e "${BLUE}=== Testing Changelog Processing ===${NC}"
    
    # Test with changelog template
    if [[ -f "$TEMPLATES_DIR/changelog.tmpl.md" ]]; then
        run_test "Changelog with output template" true \
            "$ENTRYPOINT" \
            --template "$TEMPLATES_DIR/changelog.tmpl.md" \
            --output "$TEMPLATES_DIR/changelog.tmpl.md" \
            --model "gpt-4" \
            --vars "VERSION=2.1.0,DATE=2024-01-15"
    else
        echo -e "${YELLOW}⚠ Skipping changelog test - template not found${NC}"
    fi
}

test_pr_enhancement_processing() {
    echo -e "${BLUE}=== Testing PR Enhancement Processing ===${NC}"
    
    if [[ -f "$TEMPLATES_DIR/pr-enhancement.tmpl.md" ]]; then
        run_test "PR Enhancement with output template" true \
            "$ENTRYPOINT" \
            --template "$TEMPLATES_DIR/pr-enhancement.tmpl.md" \
            --output "$TEMPLATES_DIR/pr-enhancement.tmpl.md" \
            --model "gpt-4" \
            --vars "COMMIT_COUNT=47,PR_TITLE=OAuth Implementation"
    else
        echo -e "${YELLOW}⚠ Skipping PR enhancement test - template not found${NC}"
    fi
}

test_pr_description_processing() {
    echo -e "${BLUE}=== Testing PR Description Processing ===${NC}"
    
    if [[ -f "$TEMPLATES_DIR/pr-description.tmpl.md" ]]; then
        run_test "PR Description with output template" true \
            "$ENTRYPOINT" \
            --template "$TEMPLATES_DIR/pr-description.tmpl.md" \
            --output "$TEMPLATES_DIR/pr-description.tmpl.md" \
            --model "gpt-4" \
            --vars "PR_TITLE=Complete Auth System,BRANCH=feature/oauth"
    else
        echo -e "${YELLOW}⚠ Skipping PR description test - template not found${NC}"
    fi
}

test_generic_processing() {
    echo -e "${BLUE}=== Testing Generic Processing ===${NC}"
    
    # Test with minimal template for generic processing
    local generic_template="$TEST_OUTPUT_DIR/generic.tmpl.md"
    cat > "$generic_template" << 'EOF'
# {{project_name}}

Version: {{version}}
Author: {{author}}

## Description
{{description}}

## Content
{{content}}
EOF
    
    run_test "Generic processing with custom template" true \
        "$ENTRYPOINT" \
        --template "$generic_template" \
        --output "$generic_template" \
        --model "gpt-4" \
        --vars "EXTRA_VAR=test_value"
}

test_error_scenarios() {
    echo -e "${BLUE}=== Testing Error Scenarios ===${NC}"
    
    # Test missing template
    run_test "Missing template file" false \
        "$ENTRYPOINT" \
        --template "/nonexistent/template.md" \
        --model "gpt-4"
    
    # Test missing output template
    local test_template="$TEST_OUTPUT_DIR/test.tmpl.md"
    echo "Test {{content}}" > "$test_template"
    
    run_test "Missing output template file" false \
        "$ENTRYPOINT" \
        --template "$test_template" \
        --output "/nonexistent/output.md" \
        --model "gpt-4"
    
    # Test no template provided
    run_test "No template provided" false \
        "$ENTRYPOINT" \
        --model "gpt-4"
}

test_template_variable_substitution() {
    echo -e "${BLUE}=== Testing Template Variable Substitution ===${NC}"
    
    # Create test template with variables
    local var_template="$TEST_OUTPUT_DIR/variables.tmpl.md"
    cat > "$var_template" << 'EOF'
# Project: {{PROJECT_NAME}}
Version: {{VERSION}}
Date: {{DATE}}
Content: {{content}}
Special: {{SPECIAL_CHARS}}
EOF
    
    # Test with various variable types
    local test_vars="PROJECT_NAME=Test Project,VERSION=1.0.0,DATE=2024-01-15,SPECIAL_CHARS=Special!@#$%"
    
    run_test "Variable substitution in templates" true \
        "$ENTRYPOINT" \
        --template "$var_template" \
        --output "$var_template" \
        --model "gpt-4" \
        --vars "$test_vars"
}

test_base64_variable_handling() {
    echo -e "${BLUE}=== Testing Base64 Variable Handling ===${NC}"
    
    local b64_template="$TEST_OUTPUT_DIR/base64.tmpl.md"
    cat > "$b64_template" << 'EOF'
# {{TITLE}}
{{content}}
Multi-line: {{MULTILINE}}
EOF
    
    # Create base64 encoded variables
    local vars_content="TITLE=Base64 Test,MULTILINE=Line 1\nLine 2\nLine 3"
    local b64_vars=$(echo "$vars_content" | base64)
    
    run_test "Base64 encoded variables" true \
        "$ENTRYPOINT" \
        --template "$b64_template" \
        --output "$b64_template" \
        --model "gpt-4" \
        --vars "$b64_vars"
}

test_mock_file_selection() {
    echo -e "${BLUE}=== Testing Mock File Selection ===${NC}"
    
    # Create test templates that should trigger different mock files
    local changelog_template="$TEST_OUTPUT_DIR/changelog-test.tmpl.md"
    local pr_enhancement_template="$TEST_OUTPUT_DIR/pr-enhancement-test.tmpl.md"
    local pr_description_template="$TEST_OUTPUT_DIR/pr-description-test.tmpl.md"
    local generic_template="$TEST_OUTPUT_DIR/other-test.tmpl.md"
    
    echo "# Changelog Test {{content}}" > "$changelog_template"
    echo "# PR Enhancement Test {{content}}" > "$pr_enhancement_template"
    echo "# PR Description Test {{content}}" > "$pr_description_template"
    echo "# Generic Test {{content}}" > "$generic_template"
    
    run_test "Changelog mock selection" true \
        "$ENTRYPOINT" \
        --template "$changelog_template" \
        --output "$changelog_template" \
        --model "gpt-4"
    
    run_test "PR Enhancement mock selection" true \
        "$ENTRYPOINT" \
        --template "$pr_enhancement_template" \
        --output "$pr_enhancement_template" \
        --model "gpt-4"
    
    run_test "PR Description mock selection" true \
        "$ENTRYPOINT" \
        --template "$pr_description_template" \
        --output "$pr_description_template" \
        --model "gpt-4"
    
    run_test "Generic mock selection" true \
        "$ENTRYPOINT" \
        --template "$generic_template" \
        --output "$generic_template" \
        --model "gpt-4"
}

# Main test execution
main() {
    echo -e "${BLUE}🚀 Starting entrypoint.sh integration tests${NC}"
    echo ""
    
    verify_prerequisites
    setup_test
    
    # Run all test suites
    test_changelog_processing
    test_pr_enhancement_processing  
    test_pr_description_processing
    test_generic_processing
    test_error_scenarios
    test_template_variable_substitution
    test_base64_variable_handling
    test_mock_file_selection
    
    cleanup_test
    
    # Report results
    echo -e "${BLUE}=== Test Results ===${NC}"
    echo -e "Total tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo ""
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All integration tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}💥 Some integration tests failed!${NC}"
        exit 1
    fi
}

# Allow running specific test functions
if [[ $# -gt 0 ]]; then
    case "$1" in
        setup) setup_test ;;
        cleanup) cleanup_test ;;
        changelog) setup_test; test_changelog_processing; cleanup_test ;;
        pr-enhancement) setup_test; test_pr_enhancement_processing; cleanup_test ;;
        pr-description) setup_test; test_pr_description_processing; cleanup_test ;;
        generic) setup_test; test_generic_processing; cleanup_test ;;
        errors) setup_test; test_error_scenarios; cleanup_test ;;
        variables) setup_test; test_template_variable_substitution; cleanup_test ;;
        base64) setup_test; test_base64_variable_handling; cleanup_test ;;
        mock-selection) setup_test; test_mock_file_selection; cleanup_test ;;
        *) echo "Unknown test: $1"; exit 1 ;;
    esac
else
    main
fi 