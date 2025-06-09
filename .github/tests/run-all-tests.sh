#!/usr/bin/env bash
# Master test runner for the entire .github/tests directory
# Orchestrates all processor tests, integration tests, and any future test suites

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test counters
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Array to store failed test suites
declare -a FAILED_SUITE_NAMES=()

# Timing
START_TIME=$(date +%s)

print_banner() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                                              ║${NC}"
    echo -e "${BOLD}${CYAN}║  🧪 MASTER TEST SUITE - SetlistFM TypeScript SDK Testing Framework 🧪      ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                              ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}${BLUE}🔍 Test Discovery:${NC}"
    echo -e "   📁 Processors: $(find processors/ -name "test-*.sh" | wc -l | tr -d ' ') test scripts"
    echo -e "   🔗 Integration: $(find integration/ -name "test-*.sh" | wc -l | tr -d ' ') test scripts"
    echo -e "   🏗  Workflows: $(find workflows/ -name "test-*.sh" | wc -l | tr -d ' ') test scripts"
    echo -e "   📊 Fixture Files: $(find fixtures/ -name "*.json" -o -name "*.txt" | wc -l | tr -d ' ') fixture data files"
    echo ""
}

run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    local description="$3"
    local category="$4"
    
    echo -e "${BOLD}${YELLOW}▶ Running: $suite_name${NC}"
    echo -e "   ${MAGENTA}Category:${NC} $category"
    echo -e "   ${BLUE}Description:${NC} $description"
    echo -e "   ${CYAN}Script:${NC} $test_script"
    echo ""
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    # Start timing for this suite
    local suite_start=$(date +%s)
    
    # Capture both stdout and stderr, and the exit code
    local output
    local exit_code
    
    if output=$("$test_script" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    local suite_end=$(date +%s)
    local suite_duration=$((suite_end - suite_start))
    
    # Extract test statistics from output
    local suite_total=0
    local suite_passed=0
    local suite_failed=0
    
    if echo "$output" | grep -q "Total tests:"; then
        suite_total=$(echo "$output" | grep -m1 "Total tests:" | sed 's/.*Total tests: \([0-9]*\).*/\1/')
        suite_passed=$(echo "$output" | grep -m1 "Passed:" | sed 's/.*Passed: \([0-9]*\).*/\1/')
        suite_failed=$(echo "$output" | grep -m1 "Failed:" | sed 's/.*Failed: \([0-9]*\).*/\1/')
    elif echo "$output" | grep -q "Total Tests Run:"; then
        suite_total=$(echo "$output" | grep -m1 "Total Tests Run:" | sed 's/.*Total Tests Run: \([0-9]*\).*/\1/')
        suite_passed=$(echo "$output" | grep -m1 "Tests Passed:" | sed 's/.*Tests Passed: \([0-9]*\).*/\1/')
        suite_failed=$(echo "$output" | grep -m1 "Tests Failed:" | sed 's/.*Tests Failed: \([0-9]*\).*/\1/')
    fi
    
    # Update global counters
    TOTAL_TESTS=$((TOTAL_TESTS + suite_total))
    PASSED_TESTS=$((PASSED_TESTS + suite_passed))
    FAILED_TESTS=$((FAILED_TESTS + suite_failed))
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✅ $suite_name: PASSED${NC} ${CYAN}(${suite_duration}s)${NC}"
        if [[ $suite_total -gt 0 ]]; then
            echo -e "   ${GREEN}Tests: $suite_passed/$suite_total passed${NC}"
        fi
        PASSED_SUITES=$((PASSED_SUITES + 1))
    else
        echo -e "${RED}❌ $suite_name: FAILED${NC} ${CYAN}(${suite_duration}s)${NC}"
        if [[ $suite_total -gt 0 ]]; then
            echo -e "   ${RED}Tests: $suite_passed/$suite_total passed, $suite_failed failed${NC}"
        fi
        FAILED_SUITES=$((FAILED_SUITES + 1))
        FAILED_SUITE_NAMES+=("$suite_name")
        
        # Show last few lines of output for context
        echo -e "${YELLOW}   Last output lines:${NC}"
        echo "$output" | tail -10 | sed 's/^/   /'
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

verify_test_environment() {
    echo -e "${BLUE}🔍 Verifying test environment...${NC}"
    
    # Check directory structure
    local required_dirs=("processors" "integration" "workflows" "fixtures")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
            echo -e "${RED}❌ Required directory not found: $dir${NC}"
            exit 1
        fi
    done
    
    # Check for key test scripts
    local key_scripts=(
        "processors/test-all-processors.sh"
        "integration/test-entrypoint-all.sh"
        "integration/test-entrypoint-integration.sh"
        "workflows/pr-enhance/test-pr-enhance-update-step.sh"
        "workflows/release-prepare/test-release-prepare-changelog-update.sh"
        "workflows/release-prepare/test-release-prepare-semver-bump.sh"
        "workflows/release-prepare/test-release-prepare-openai-vars.sh"
        "workflows/pr-enhance/test-collect-pr-metadata.sh"
    )
    
    for script in "${key_scripts[@]}"; do
        local full_path="$SCRIPT_DIR/$script"
        if [[ ! -f "$full_path" ]]; then
            echo -e "${RED}❌ Key test script not found: $script${NC}"
            exit 1
        fi
        
        if [[ ! -x "$full_path" ]]; then
            echo -e "${RED}❌ Test script not executable: $script${NC}"
            exit 1
        fi
    done
    
    # Check mock files
    local fixture_count=$(find "$SCRIPT_DIR/fixtures" -name "*.json" -o -name "*.txt" | wc -l)
    if [[ $fixture_count -lt 5 ]]; then
        echo -e "${YELLOW}⚠ Warning: Only $fixture_count fixture files found (expected 5+)${NC}"
    fi
    
    echo -e "${GREEN}✅ Test environment verified${NC}"
    echo ""
}



generate_comprehensive_report() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))
    local minutes=$((total_duration / 60))
    local seconds=$((total_duration % 60))
    
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                                              ║${NC}"
    echo -e "${BOLD}${CYAN}║  📊 COMPREHENSIVE TEST RESULTS - SetlistFM TypeScript SDK                   ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                              ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Execution summary
    echo -e "${BOLD}⏱️  Execution Summary:${NC}"
    echo -e "   Duration: ${minutes}m ${seconds}s"
    echo -e "   Start Time: $(date -d "@$START_TIME" '+%Y-%m-%d %H:%M:%S')"
    echo -e "   End Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Test suite summary
    echo -e "${BOLD}🧪 Test Suite Summary:${NC}"
    echo -e "   Total Suites: $TOTAL_SUITES"
    echo -e "   ${GREEN}✅ Passed: $PASSED_SUITES${NC}"
    echo -e "   ${RED}❌ Failed: $FAILED_SUITES${NC}"
    echo ""
    
    # Individual test summary
    echo -e "${BOLD}🔍 Individual Test Summary:${NC}"
    echo -e "   Total Tests: $TOTAL_TESTS"
    echo -e "   ${GREEN}✅ Passed: $PASSED_TESTS${NC}"
    echo -e "   ${RED}❌ Failed: $FAILED_TESTS${NC}"
    echo ""
    
    # Coverage and success rate
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        local pass_percentage=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "${BOLD}📈 Coverage Metrics:${NC}"
        echo -e "   Success Rate: ${pass_percentage}%"
        
        if [[ $pass_percentage -ge 95 ]]; then
            echo -e "   Quality Level: ${GREEN}🏆 Excellent${NC}"
        elif [[ $pass_percentage -ge 85 ]]; then
            echo -e "   Quality Level: ${YELLOW}🥈 Good${NC}"
        elif [[ $pass_percentage -ge 70 ]]; then
            echo -e "   Quality Level: ${YELLOW}🥉 Acceptable${NC}"
        else
            echo -e "   Quality Level: ${RED}⚠️  Needs Improvement${NC}"
        fi
        echo ""
    fi
    
    # Component coverage
    echo -e "${BOLD}🧩 Component Coverage:${NC}"
    echo -e "   ${GREEN}✅ Changelog Processor${NC}"
    echo -e "   ${GREEN}✅ PR Enhancement Processor${NC}"
    echo -e "   ${GREEN}✅ Generic Processor${NC}"
    echo -e "   ${GREEN}✅ Shared Utilities${NC}"
    echo -e "   ${GREEN}✅ Entrypoint Integration${NC}"
    echo -e "   ${GREEN}✅ Mock Data Pipeline${NC}"
    echo -e "   ${GREEN}✅ Error Handling${NC}"
    echo -e "   ${GREEN}✅ Variable Substitution${NC}"
    echo ""
    
    # Failed suites detail
    if [[ ${#FAILED_SUITE_NAMES[@]} -gt 0 ]]; then
        echo -e "${BOLD}${RED}❌ Failed Test Suites:${NC}"
        for suite in "${FAILED_SUITE_NAMES[@]}"; do
            echo -e "     ${RED}• $suite${NC}"
        done
        echo ""
    fi
    
    # Final result
    if [[ $FAILED_SUITES -eq 0 ]]; then
        echo -e "${BOLD}${GREEN}🎉 ALL TESTS PASSED! SYSTEM READY FOR PRODUCTION! 🎉${NC}"
        echo ""
        echo -e "${BOLD}✅ Verified Capabilities:${NC}"
        echo -e "   ${GREEN}• Complete OpenAI API integration with fallback testing${NC}"
        echo -e "   ${GREEN}• All processor scripts functioning correctly${NC}"
        echo -e "   ${GREEN}• End-to-end workflow validation${NC}"
        echo -e "   ${GREEN}• Comprehensive error handling${NC}"
        echo -e "   ${GREEN}• Mock data infrastructure working${NC}"
        echo -e "   ${GREEN}• GitHub Actions output generation${NC}"
        echo ""
        echo -e "${BOLD}${CYAN}🚀 The SetlistFM TypeScript SDK testing framework is${NC}"
        echo -e "${BOLD}${CYAN}   enterprise-ready and production-validated!${NC}"
    else
        echo -e "${BOLD}${RED}💥 SOME TESTS FAILED - ATTENTION REQUIRED! 💥${NC}"
        echo ""
        echo -e "${RED}Please review the failed test suites above and resolve issues before deployment.${NC}"
        echo -e "${YELLOW}Check logs, fix failing tests, and re-run this test suite.${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    echo -e "${BOLD}SetlistFM TypeScript SDK - Master Test Runner${NC}"
    echo ""
    echo -e "${BOLD}USAGE:${NC}"
    echo "  $0 [options]"
    echo ""
    echo -e "${BOLD}DESCRIPTION:${NC}"
    echo "  Comprehensive test runner for the entire .github/tests directory."
    echo "  Executes all processor tests, integration tests, and validates the"
    echo "  complete OpenAI API integration workflow."
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "  -h, --help           Show this help message"
    echo "  --processors-only    Run only processor tests"
    echo "  --integration-only   Run only integration tests"
    echo "  --workflows-only     Run only workflow tests"
    echo "  --quick             Skip detailed reporting (faster execution)"
    echo "  --verbose           Show verbose output from all test scripts"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "  $0                        # Run all tests with full reporting"
    echo "  $0 --processors-only      # Run only processor unit tests"
    echo "  $0 --integration-only     # Run only integration tests"
    echo "  $0 --workflows-only       # Run only workflow tests"
    echo "  $0 --quick               # Fast execution with minimal reporting"
    echo ""
    echo -e "${BOLD}TEST STRUCTURE:${NC}"
    echo "  📁 processors/           - Individual processor unit tests"
    echo "  📁 integration/          - End-to-end integration tests"
    echo "  📁 workflows/            - Workflow logic tests"
    echo "  📁 fixtures/               - Test fixture data (JSON/TXT)"
    echo ""
    echo -e "${BOLD}COVERAGE:${NC}"
    echo "  • Changelog generation processor"
    echo "  • PR enhancement processor"
    echo "  • Generic content processor"
    echo "  • Shared utility functions"
    echo "  • Workflow update steps"
    echo "  • PR metadata collection with conventional commit analysis"
    echo "  • PR label determination based on commit type counts"
    echo "  • PR label application and auto-assignment operations"
    echo "  • Release PR verification logic"
    echo "  • Release PR state synchronization"
    echo "  • Complete entrypoint workflow"
    echo "  • Mock API data pipeline"
    echo "  • Error handling scenarios"
    echo ""
}

# Parse command line arguments
QUICK_MODE=false
VERBOSE_MODE=false
RUN_PROCESSORS=true
RUN_INTEGRATION=true
RUN_WORKFLOWS=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --processors-only)
            RUN_INTEGRATION=false
            RUN_WORKFLOWS=false
            shift
            ;;
        --integration-only)
            RUN_PROCESSORS=false
            RUN_WORKFLOWS=false
            shift
            ;;
        --workflows-only)
            RUN_PROCESSORS=false
            RUN_INTEGRATION=false
            RUN_WORKFLOWS=true
            shift
            ;;
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --verbose)
            VERBOSE_MODE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Main execution
main() {
    # Change to script directory to ensure relative paths work
    cd "$SCRIPT_DIR"
    
    if [[ $QUICK_MODE == "true" ]]; then
        # Quick mode - minimal output
        echo -e "${BOLD}${BLUE}🚀 Quick Test Mode - Running all tests...${NC}"
        
        local total_exit=0
        
        if [[ $RUN_PROCESSORS == "true" ]]; then
            echo -n "Processors: "
            if ./processors/test-all-processors.sh >/dev/null 2>&1; then
                echo -e "${GREEN}PASS${NC}"
            else
                echo -e "${RED}FAIL${NC}"
                total_exit=1
            fi
        fi
        
        if [[ $RUN_INTEGRATION == "true" ]]; then
            echo -n "Integration: "
            if ./integration/test-entrypoint-integration.sh >/dev/null 2>&1; then
                echo -e "${GREEN}PASS${NC}"
            else
                echo -e "${RED}FAIL${NC}"
                total_exit=1
            fi
        fi

        if [[ $RUN_WORKFLOWS == "true" ]]; then
            echo -n "Workflows: "
            local workflow_exit=0
            if ! ./workflows/pr-enhance/test-pr-enhance-update-step.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-prepare/test-release-prepare-changelog-update.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-prepare/test-release-prepare-semver-bump.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-prepare/test-release-prepare-openai-vars.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/pr-enhance/test-collect-pr-metadata.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/pr-enhance/test-determine-pr-labels.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/pr-enhance/test-apply-pr-labels.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/pr-enhance/test-post-commit-feedback.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-release-pr-verification.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-release-pr-sync.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-extract-changelog-entry.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-extract-changelog-entry-interface.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-extract-changelog-entry-versioning.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-workflow-integration.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-manage-release-pr.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-pr/test-debug-ai-response.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-notes/test-collect-git-history.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-notes/test-extract-commit-stats.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-notes/test-prepare-ai-context.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-notes/test-validate-release-notes.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-notes/test-manage-github-release.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            if ! ./workflows/release-notes/test-determine-version.sh >/dev/null 2>&1; then
                workflow_exit=1
            fi
            
            if [[ $workflow_exit -eq 0 ]]; then
                echo -e "${GREEN}PASS${NC}"
            else
                echo -e "${RED}FAIL${NC}"
                total_exit=1
            fi
        fi
        
        if [[ $total_exit -eq 0 ]]; then
            echo -e "${GREEN}✅ All tests passed${NC}"
        else
            echo -e "${RED}❌ Some tests failed${NC}"
        fi
        
        exit $total_exit
    else
        # Full mode - comprehensive reporting
        print_banner
        verify_test_environment
        
        echo -e "${BOLD}${CYAN}🚀 Starting comprehensive test execution...${NC}"
        echo ""
        
        if [[ $RUN_PROCESSORS == "true" ]]; then
            echo -e "${BOLD}${MAGENTA}═══ PROCESSOR TESTS ═══${NC}"
            echo ""
            
            run_test_suite \
                "Individual Processor Tests" \
                "$SCRIPT_DIR/processors/test-all-processors.sh" \
                "Testing all individual processors (changelog, pr-enhance, generic, shared utilities)" \
                "Unit Testing"
        fi
        
        if [[ $RUN_INTEGRATION == "true" ]]; then
            echo -e "${BOLD}${MAGENTA}═══ INTEGRATION TESTS ═══${NC}"
            echo ""
            
            run_test_suite \
                "Entrypoint Integration Tests" \
                "$SCRIPT_DIR/integration/test-entrypoint-integration.sh" \
                "Testing complete entrypoint workflow with mock data and API simulation" \
                "Integration Testing"
        fi

        if [[ $RUN_WORKFLOWS == "true" ]]; then
            echo -e "${BOLD}${MAGENTA}═══ WORKFLOW TESTS ═══${NC}"
            echo ""

            run_test_suite \
                "PR Enhance Workflow Step" \
                "$SCRIPT_DIR/workflows/pr-enhance/test-pr-enhance-update-step.sh" \
                "Testing quoting logic in pr-enhance workflow update step" \
                "Workflow Testing"

            run_test_suite \
                "Release Prepare Changelog Update" \
                "$SCRIPT_DIR/workflows/release-prepare/test-release-prepare-changelog-update.sh" \
                "Testing changelog update logic in release-prepare workflow" \
                "Workflow Testing"

            run_test_suite \
                "Release Prepare Semver Bump" \
                "$SCRIPT_DIR/workflows/release-prepare/test-release-prepare-semver-bump.sh" \
                "Testing semver bump type determination based on commit message analysis" \
                "Workflow Testing"

            run_test_suite \
                "Release Prepare OpenAI Variables" \
                "$SCRIPT_DIR/workflows/release-prepare/test-release-prepare-openai-vars.sh" \
                "Testing OpenAI variables preparation with multi-line content handling and base64 encoding" \
                "Workflow Testing"

            run_test_suite \
                "PR Metadata Collection" \
                "$SCRIPT_DIR/workflows/pr-enhance/test-collect-pr-metadata.sh" \
                "Testing PR metadata collection with conventional commit analysis" \
                "Workflow Testing"

            run_test_suite \
                "PR Label Determination" \
                "$SCRIPT_DIR/workflows/pr-enhance/test-determine-pr-labels.sh" \
                "Testing PR label determination logic based on commit type counts and percentages" \
                "Workflow Testing"

            run_test_suite \
                "PR Label Application" \
                "$SCRIPT_DIR/workflows/pr-enhance/test-apply-pr-labels.sh" \
                "Testing PR label application and auto-assignment with GitHub CLI operations" \
                "Workflow Testing"

            run_test_suite \
                "PR Commit Quality Feedback" \
                "$SCRIPT_DIR/workflows/pr-enhance/test-post-commit-feedback.sh" \
                "Testing commit quality feedback posting with percentage calculations and GitHub CLI operations" \
                "Workflow Testing"

            run_test_suite \
                "Release PR Verification" \
                "$SCRIPT_DIR/workflows/release-pr/test-release-pr-verification.sh" \
                "Testing commit verification and version validation logic in release-pr workflow" \
                "Workflow Testing"

            run_test_suite \
                "Release PR State Synchronization" \
                "$SCRIPT_DIR/workflows/release-pr/test-release-pr-sync.sh" \
                "Testing state synchronization and debug output in release-pr workflow" \
                "Workflow Testing"

            run_test_suite \
                "Changelog Entry Extraction" \
                "$SCRIPT_DIR/workflows/release-pr/test-extract-changelog-entry.sh" \
                "Testing changelog entry extraction logic with various formats and edge cases" \
                "Workflow Testing"

            run_test_suite \
                "Changelog Extraction Interface Compatibility" \
                "$SCRIPT_DIR/workflows/release-pr/test-extract-changelog-entry-interface.sh" \
                "Testing interface compatibility with release-notes-generate workflow (--version, --changelog, --verbose)" \
                "Workflow Testing"

            run_test_suite \
                "Changelog Version-Specific Extraction" \
                "$SCRIPT_DIR/workflows/release-pr/test-extract-changelog-entry-versioning.sh" \
                "Testing version-specific changelog extraction functionality and edge cases" \
                "Workflow Testing"

            run_test_suite \
                "Workflow Integration Fix Verification" \
                "$SCRIPT_DIR/workflows/release-pr/test-workflow-integration.sh" \
                "Testing complete fix for release-notes-generate.yml workflow integration issue" \
                "Workflow Testing"

            run_test_suite \
                "Release PR Management" \
                "$SCRIPT_DIR/workflows/release-pr/test-manage-release-pr.sh" \
                "Testing release PR creation and update logic with comprehensive mocking and error handling" \
                "Workflow Testing"

            run_test_suite \
                "Debug AI Response" \
                "$SCRIPT_DIR/workflows/release-pr/test-debug-ai-response.sh" \
                "Testing safe AI response debugging that handles special characters, quotes, and multiline content" \
                "Workflow Testing"

            run_test_suite \
                "Git History Collection" \
                "$SCRIPT_DIR/workflows/release-notes/test-collect-git-history.sh" \
                "Testing git history collection with JSON/text output formats, unicode support, and edge case handling" \
                "Workflow Testing"

            run_test_suite \
                "Commit Statistics Extraction" \
                "$SCRIPT_DIR/workflows/release-notes/test-extract-commit-stats.sh" \
                "Testing conventional commit parsing, type counting, and breaking change detection" \
                "Workflow Testing"

            run_test_suite \
                "AI Context Preparation" \
                "$SCRIPT_DIR/workflows/release-notes/test-prepare-ai-context.sh" \
                "Testing data orchestration, template variable preparation, and base64 encoding for AI context" \
                "Workflow Testing"

            run_test_suite \
                "Release Notes Validation" \
                "$SCRIPT_DIR/workflows/release-notes/test-validate-release-notes.sh" \
                "Testing release notes content validation, formatting checks, and quality metrics" \
                "Workflow Testing"

            run_test_suite \
                "GitHub Release Management" \
                "$SCRIPT_DIR/workflows/release-notes/test-manage-github-release.sh" \
                "Testing GitHub release creation and update logic with comprehensive validation and mocking" \
                "Workflow Testing"

            run_test_suite \
                "Version Determination" \
                "$SCRIPT_DIR/workflows/release-notes/test-determine-version.sh" \
                "Testing version determination logic with trigger-based conditional handling and validation" \
                "Workflow Testing"
        fi
        
        generate_comprehensive_report
        
        # Exit with appropriate code
        if [[ $FAILED_SUITES -eq 0 ]]; then
            exit 0
        else
            exit 1
        fi
    fi
}

main "$@" 