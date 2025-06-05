#!/usr/bin/env bash
# Master test runner for all entrypoint-related tests
# Runs both processor tests and integration tests

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSORS_DIR="$SCRIPT_DIR/../processors"
INTEGRATION_DIR="$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  🚀 Entrypoint Test Suite - Comprehensive Testing                       ${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    local description="$3"
    
    echo -e "${BOLD}${YELLOW}▶ Running: $suite_name${NC}"
    echo -e "   ${description}"
    echo ""
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    # Capture both stdout and stderr, and the exit code
    local output
    local exit_code
    
    if output=$("$test_script" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # Extract test statistics from output
    local suite_total=0
    local suite_passed=0
    local suite_failed=0
    
    if echo "$output" | grep -q "Total tests:"; then
        suite_total=$(echo "$output" | grep "Total tests:" | sed 's/.*Total tests: \([0-9]*\).*/\1/')
        suite_passed=$(echo "$output" | grep "Passed:" | sed 's/.*Passed: \([0-9]*\).*/\1/')
        suite_failed=$(echo "$output" | grep "Failed:" | sed 's/.*Failed: \([0-9]*\).*/\1/')
    fi
    
    # Update global counters
    TOTAL_TESTS=$((TOTAL_TESTS + suite_total))
    PASSED_TESTS=$((PASSED_TESTS + suite_passed))
    FAILED_TESTS=$((FAILED_TESTS + suite_failed))
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✅ $suite_name: PASSED${NC}"
        if [[ $suite_total -gt 0 ]]; then
            echo -e "   ${GREEN}Tests: $suite_passed/$suite_total passed${NC}"
        fi
        PASSED_SUITES=$((PASSED_SUITES + 1))
    else
        echo -e "${RED}❌ $suite_name: FAILED${NC}"
        if [[ $suite_total -gt 0 ]]; then
            echo -e "   ${RED}Tests: $suite_passed/$suite_total passed, $suite_failed failed${NC}"
        fi
        FAILED_SUITES=$((FAILED_SUITES + 1))
        FAILED_SUITE_NAMES+=("$suite_name")
        
        # Show last few lines of output for context
        echo -e "${YELLOW}   Last output lines:${NC}"
        echo "$output" | tail -5 | sed 's/^/   /'
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

verify_prerequisites() {
    echo -e "${BLUE}🔍 Verifying test prerequisites...${NC}"
    
    # Check that all required test scripts exist
    local required_scripts=(
        "$PROCESSORS_DIR/test-all-processors.sh"
        "$INTEGRATION_DIR/test-entrypoint-integration.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            echo -e "${RED}❌ Required test script not found: $script${NC}"
            exit 1
        fi
        
        if [[ ! -x "$script" ]]; then
            echo -e "${RED}❌ Test script not executable: $script${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}✅ All prerequisites verified${NC}"
    echo ""
}

run_all_tests() {
    print_header
    verify_prerequisites
    
    echo -e "${BOLD}${CYAN}Running all entrypoint-related tests...${NC}"
    echo ""
    
    # Run processor tests
    run_test_suite \
        "Processor Tests" \
        "$PROCESSORS_DIR/test-all-processors.sh" \
        "Testing all individual processors (changelog, pr-enhance, generic, shared utilities)"
    
    # Run integration tests
    run_test_suite \
        "Integration Tests" \
        "$INTEGRATION_DIR/test-entrypoint-integration.sh" \
        "Testing complete entrypoint workflow with mock data"
    
    # Generate final report
    generate_final_report
}

generate_final_report() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  📊 FINAL TEST RESULTS                                                   ${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Test suite summary
    echo -e "${BOLD}Test Suites:${NC}"
    echo -e "  Total: $TOTAL_SUITES"
    echo -e "  ${GREEN}Passed: $PASSED_SUITES${NC}"
    echo -e "  ${RED}Failed: $FAILED_SUITES${NC}"
    echo ""
    
    # Individual test summary
    echo -e "${BOLD}Individual Tests:${NC}"
    echo -e "  Total: $TOTAL_TESTS"
    echo -e "  ${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "  ${RED}Failed: $FAILED_TESTS${NC}"
    echo ""
    
    # Coverage summary
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        local pass_percentage=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "${BOLD}Coverage:${NC}"
        echo -e "  Success Rate: ${pass_percentage}%"
        echo ""
    fi
    
    # Failed suites detail
    if [[ ${#FAILED_SUITE_NAMES[@]} -gt 0 ]]; then
        echo -e "${BOLD}${RED}Failed Test Suites:${NC}"
        for suite in "${FAILED_SUITE_NAMES[@]}"; do
            echo -e "  ${RED}• $suite${NC}"
        done
        echo ""
    fi
    
    # Final result
    if [[ $FAILED_SUITES -eq 0 ]]; then
        echo -e "${BOLD}${GREEN}🎉 ALL TESTS PASSED! 🎉${NC}"
        echo -e "${GREEN}The entrypoint system is ready for production use.${NC}"
        echo ""
        
        # Show what was tested
        echo -e "${BOLD}✅ Successfully Tested:${NC}"
        echo -e "  ${GREEN}• All processor scripts (changelog, pr-enhance, generic, shared)${NC}"
        echo -e "  ${GREEN}• Complete integration workflow with mocked API calls${NC}"
        echo -e "  ${GREEN}• Error handling and edge cases${NC}"
        echo -e "  ${GREEN}• Template variable substitution${NC}"
        echo -e "  ${GREEN}• Mock file selection and loading${NC}"
        echo -e "  ${GREEN}• GitHub Actions output generation${NC}"
        echo ""
    else
        echo -e "${BOLD}${RED}💥 SOME TESTS FAILED! 💥${NC}"
        echo -e "${RED}Please review the failed test suites above and fix any issues.${NC}"
        echo ""
    fi
    
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Master test runner for all entrypoint-related tests"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  --processors    Run only processor tests"
    echo "  --integration   Run only integration tests"
    echo "  --quiet         Run in quiet mode (less verbose output)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 --processors       # Run only processor tests"
    echo "  $0 --integration      # Run only integration tests"
}

# Parse command line arguments
QUIET_MODE=false
RUN_PROCESSORS=true
RUN_INTEGRATION=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --processors)
            RUN_INTEGRATION=false
            shift
            ;;
        --integration)
            RUN_PROCESSORS=false
            shift
            ;;
        --quiet)
            QUIET_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    if [[ $QUIET_MODE == "true" ]]; then
        # Redirect output for quiet mode
        exec 3>&1 4>&2
        exec 1>/dev/null 2>&1
    fi
    
    print_header
    verify_prerequisites
    
    echo -e "${BOLD}${CYAN}Running selected test suites...${NC}"
    echo ""
    
    # Run selected test suites
    if [[ $RUN_PROCESSORS == "true" ]]; then
        run_test_suite \
            "Processor Tests" \
            "$PROCESSORS_DIR/test-all-processors.sh" \
            "Testing all individual processors (changelog, pr-enhance, generic, shared utilities)"
    fi
    
    if [[ $RUN_INTEGRATION == "true" ]]; then
        run_test_suite \
            "Integration Tests" \
            "$INTEGRATION_DIR/test-entrypoint-integration.sh" \
            "Testing complete entrypoint workflow with mock data"
    fi
    
    if [[ $QUIET_MODE == "true" ]]; then
        # Restore output for final report
        exec 1>&3 2>&4
    fi
    
    generate_final_report
    
    # Exit with appropriate code
    if [[ $FAILED_SUITES -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

main "$@" 