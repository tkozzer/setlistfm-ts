#!/usr/bin/env bash
set -euo pipefail

# Comprehensive test runner for extract-changelog-entry.sh script
# Runs all tests to verify the workflow integration fix

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

total_test_suites=0
passed_test_suites=0
failed_test_suites=0

run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    
    echo -e "${BLUE}🧪 Running $suite_name${NC}"
    echo ""
    
    total_test_suites=$((total_test_suites + 1))
    
    if "$SCRIPT_DIR/$test_script"; then
        echo ""
        echo -e "${GREEN}✅ $suite_name PASSED${NC}"
        passed_test_suites=$((passed_test_suites + 1))
        return 0
    else
        echo ""
        echo -e "${RED}❌ $suite_name FAILED${NC}"
        failed_test_suites=$((failed_test_suites + 1))
        return 1
    fi
}

main() {
    echo -e "${BLUE}🚀 Running All Extract Changelog Entry Tests${NC}"
    echo ""
    echo -e "${YELLOW}This test suite verifies the fix for the workflow integration issue:${NC}"
    echo "  Original Error: [ERROR] Unknown option: --version"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Run all test suites
    run_test_suite "Original Test Suite (Backward Compatibility)" "test-extract-changelog-entry.sh"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    run_test_suite "Interface Compatibility Tests" "test-extract-changelog-entry-interface.sh"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    run_test_suite "Version-Specific Extraction Tests" "test-extract-changelog-entry-versioning.sh"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    run_test_suite "Workflow Integration Test" "test-workflow-integration.sh"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Final summary
    echo -e "${BLUE}📊 COMPREHENSIVE TEST SUMMARY${NC}"
    echo "────────────────────────────────────────────────────────────────────"
    echo "   Total test suites: $total_test_suites"
    echo "   Passed: $passed_test_suites"
    echo "   Failed: $failed_test_suites"
    echo ""
    
    if [[ $failed_test_suites -gt 0 ]]; then
        echo -e "${RED}❌ SOME TEST SUITES FAILED${NC}"
        echo "   The workflow integration fix may not be complete."
        return 1
    else
        echo -e "${GREEN}✅ ALL TEST SUITES PASSED!${NC}"
        echo ""
        echo -e "${GREEN}🎉 WORKFLOW INTEGRATION FIX COMPLETE${NC}"
        echo ""
        echo "The extract-changelog-entry.sh script now fully supports:"
        echo "  ✅ --version parameter (extracts specific version entries)"
        echo "  ✅ --changelog parameter (alias for --file)"  
        echo "  ✅ --verbose parameter (alias for --debug)"
        echo "  ✅ Backward compatibility with existing interface"
        echo "  ✅ Version-specific extraction functionality"
        echo ""
        echo "This resolves the error from release-notes-generate.yml:"
        echo "  ❌ [ERROR] Unknown option: --version"
        echo "  ✅ Workflow will now execute successfully"
        return 0
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 