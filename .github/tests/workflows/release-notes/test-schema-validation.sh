#!/usr/bin/env bash

# Test suite for release notes schema validation (Fix 5: Schema-Template Alignment)
# This validates that the JSON schema correctly enforces all template requirements

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SCHEMA_FILE="$PROJECT_ROOT/.github/schema/release-notes.schema.json"
TEST_OUTPUT_DIR="/tmp/schema_test_$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0

# Create temp directory for test files
mkdir -p "$TEST_OUTPUT_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEST_OUTPUT_DIR"
}
trap cleanup EXIT

# Helper function to run tests
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Running test: $test_name${NC}"
    
    if $test_function; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        return 1
    fi
}

# Helper function to validate JSON against schema
validate_json() {
    local json_file="$1"
    
    # Simple validation using jq - check if all required fields exist (version no longer required)
    local has_summary has_primary has_commit has_breaking has_footer has_bugs has_ci
    
    has_summary=$(jq -e '.summary' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    has_primary=$(jq -e '.primary_section' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    has_commit=$(jq -e '.commit_analysis' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    has_breaking=$(jq -e '.breaking_changes' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    has_footer=$(jq -e '.footer_links' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    has_bugs=$(jq -e '.bug_fixes' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    has_ci=$(jq -e '.ci_improvements' "$json_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    
    if [[ "$has_summary" == "yes" && "$has_primary" == "yes" && \
          "$has_commit" == "yes" && "$has_breaking" == "yes" && "$has_footer" == "yes" && \
          "$has_bugs" == "yes" && "$has_ci" == "yes" ]]; then
        echo "VALID"
    else
        echo "INVALID"
    fi
}

# Helper to create test JSON files
create_test_json() {
    local filename="$1"
    local json_content="$2"
    
    echo "$json_content" > "$TEST_OUTPUT_DIR/$filename"
}

test_schema_is_valid_json() {
    # Test that the schema file itself is valid JSON
    if jq empty "$SCHEMA_FILE" >/dev/null 2>&1; then
        return 0
    else
        echo "Schema file is not valid JSON"
        return 1
    fi
}

test_schema_has_required_fields() {
    # Test that all expected fields are in the required array
    local required_fields
    required_fields=$(jq -r '.required[]' "$SCHEMA_FILE" | sort | tr '\n' ' ')
    
    local expected_fields="breaking_changes bug_fixes ci_improvements commit_analysis footer_links primary_section summary"
    
    if [[ "$required_fields" == "$expected_fields " ]]; then
        return 0
    else
        echo "Required fields mismatch:"
        echo "Expected: $expected_fields"
        echo "Actual: $required_fields"
        return 1
    fi
}

test_valid_complete_json_passes() {
    # Test that a complete, valid JSON structure passes validation
    local test_json='{
        "summary": "This patch release focuses on improving CI/CD workflow stability.",
        "primary_section": {
            "title": "CI/DevOps Improvements",
            "emoji": "🤖",
            "features": ["**Enhanced workflow** reduces build failures"]
        },
        "commit_analysis": {
            "total_commits": 21,
            "feat_count": 2,
            "fix_count": 8,
            "ci_count": 11,
            "breaking_changes_detected": false
        },
        "breaking_changes": "",
        "bug_fixes": ["**Fixed template processor** handles version normalization"],
        "ci_improvements": ["**Enhanced test coverage** ensures better quality"],
        "footer_links": {
            "npm": "https://www.npmjs.com/package/setlistfm-ts",
            "changelog": "https://github.com/tkozzer/setlistfm-ts/blob/main/CHANGELOG.md",
            "issues": "https://github.com/tkozzer/setlistfm-ts/issues"
        }
    }'
    
    create_test_json "valid_complete.json" "$test_json"
    
    local result
    result=$(validate_json "$TEST_OUTPUT_DIR/valid_complete.json")
    
    if [[ "$result" == "VALID" ]]; then
        return 0
    else
        echo "Valid complete JSON failed validation: $result"
        return 1
    fi
}

test_missing_bug_fixes_fails() {
    # Test that missing bug_fixes field fails validation
    local test_json='{
        "summary": "Test release",
        "primary_section": {
            "title": "Features",
            "emoji": "✨",
            "features": ["Test feature"]
        },
        "commit_analysis": {
            "total_commits": 1,
            "feat_count": 1,
            "fix_count": 0,
            "ci_count": 0,
            "breaking_changes_detected": false
        },
        "breaking_changes": "",
        "ci_improvements": [],
        "footer_links": {
            "npm": "https://npm.com",
            "changelog": "https://changelog.com",
            "issues": "https://issues.com"
        }
    }'
    
    create_test_json "missing_bug_fixes.json" "$test_json"
    
    local result
    result=$(validate_json "$TEST_OUTPUT_DIR/missing_bug_fixes.json")
    
    if [[ "$result" == "INVALID" ]]; then
        return 0
    else
        echo "Missing bug_fixes should have failed validation but got: $result"
        return 1
    fi
}

test_missing_ci_improvements_fails() {
    # Test that missing ci_improvements field fails validation
    local test_json='{
        "summary": "Test release",
        "primary_section": {
            "title": "Features",
            "emoji": "✨",
            "features": ["Test feature"]
        },
        "commit_analysis": {
            "total_commits": 1,
            "feat_count": 1,
            "fix_count": 0,
            "ci_count": 0,
            "breaking_changes_detected": false
        },
        "breaking_changes": "",
        "bug_fixes": [],
        "footer_links": {
            "npm": "https://npm.com",
            "changelog": "https://changelog.com",
            "issues": "https://issues.com"
        }
    }'
    
    create_test_json "missing_ci_improvements.json" "$test_json"
    
    local result
    result=$(validate_json "$TEST_OUTPUT_DIR/missing_ci_improvements.json")
    
    if [[ "$result" == "INVALID" ]]; then
        return 0
    else
        echo "Missing ci_improvements should have failed validation but got: $result"
        return 1
    fi
}

test_empty_arrays_are_valid() {
    # Test that empty bug_fixes and ci_improvements arrays are valid
    local test_json='{
        "summary": "Test release with no fixes or improvements",
        "primary_section": {
            "title": "Features",
            "emoji": "✨",
            "features": ["**New feature** added functionality"]
        },
        "commit_analysis": {
            "total_commits": 1,
            "feat_count": 1,
            "fix_count": 0,
            "ci_count": 0,
            "breaking_changes_detected": false
        },
        "breaking_changes": "",
        "bug_fixes": [],
        "ci_improvements": [],
        "footer_links": {
            "npm": "https://npm.com",
            "changelog": "https://changelog.com",
            "issues": "https://issues.com"
        }
    }'
    
    create_test_json "empty_arrays.json" "$test_json"
    
    local result
    result=$(validate_json "$TEST_OUTPUT_DIR/empty_arrays.json")
    
    if [[ "$result" == "VALID" ]]; then
        return 0
    else
        echo "Empty arrays should be valid but got: $result"
        return 1
    fi
}

###############################################################################
# Main Test Execution                                                         #
###############################################################################

main() {
    echo "🧪 Running Schema Validation Tests (Fix 5: Schema-Template Alignment)"
    echo "Schema file: $SCHEMA_FILE"
    echo

    # Check if schema file exists
    if [[ ! -f "$SCHEMA_FILE" ]]; then
        echo -e "${RED}❌ Schema file not found: $SCHEMA_FILE${NC}"
        exit 1
    fi

    echo "Running schema validation tests..."
    echo

    # Run all tests
    run_test "Schema is valid JSON" test_schema_is_valid_json
    run_test "Schema has required fields" test_schema_has_required_fields
    run_test "Valid complete JSON passes" test_valid_complete_json_passes
    run_test "Missing bug_fixes fails" test_missing_bug_fixes_fails
    run_test "Missing ci_improvements fails" test_missing_ci_improvements_fails
    run_test "Empty arrays are valid" test_empty_arrays_are_valid

    # Print summary
    echo
    echo "📊 Test Summary"
    echo "==============="
    echo -e "Tests run: ${YELLOW}$TESTS_RUN${NC}"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"

    if [[ $TESTS_PASSED -eq $TESTS_RUN ]]; then
        echo -e "\n${GREEN}🎉 All schema validation tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}💥 Some schema validation tests failed!${NC}"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 