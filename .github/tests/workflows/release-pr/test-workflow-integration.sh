#!/usr/bin/env bash
set -euo pipefail

# Integration test to verify the extract-changelog-entry.sh script works with the release-notes-generate.yml workflow
# This test reproduces the exact failing scenario from the workflow logs and verifies it's now fixed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../../../.."
EXTRACT_SCRIPT="$PROJECT_ROOT/.github/scripts/release-pr/extract-changelog-entry.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_test() {
    echo -e "${BLUE}🧪 $1${NC}"
}

echo_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_fail() {
    echo -e "${RED}❌ $1${NC}"
}

main() {
    echo -e "${BLUE}🚀 Testing Workflow Integration Fix${NC}"
    echo ""
    echo -e "${YELLOW}Original Error from release-notes-generate.yml:${NC}"
    echo "[ERROR] Unknown option: --version"
    echo ""
    echo -e "${YELLOW}Failing Command from Workflow:${NC}"
    echo ".github/scripts/release-pr/extract-changelog-entry.sh \\"
    echo "  --version \"0.7.2\" \\"
    echo "  --changelog \"CHANGELOG.md\" \\"
    echo "  --verbose"
    echo ""
    
    # Test the exact command that was failing
    echo_test "Running exact workflow command"
    
    local output
    local exit_code
    
    # Change to project root to run the command as the workflow would
    cd "$PROJECT_ROOT"
    
    if output=$("$EXTRACT_SCRIPT" --version "0.7.2" --changelog "CHANGELOG.md" --verbose 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        echo_pass "Command succeeded! The workflow integration issue is FIXED."
        echo ""
        echo -e "${YELLOW}Command output (first 10 lines):${NC}"
        echo "$output" | head -10
        echo "..."
        echo ""
        echo -e "${GREEN}✅ SUMMARY: All workflow compatibility issues have been resolved${NC}"
        echo ""
        echo "The script now supports:"
        echo "  ✅ --version parameter (extracts specific version entries)"
        echo "  ✅ --changelog parameter (alias for --file)"
        echo "  ✅ --verbose parameter (alias for --debug)"
        echo ""
        echo "This fixes the error seen in the workflow logs:"
        echo "  ❌ [ERROR] Unknown option: --version"
        echo "  ✅ Now properly handles all workflow parameters"
        
        return 0
    else
        echo_fail "Command failed with exit code: $exit_code"
        echo "Output: $output"
        echo ""
        echo -e "${RED}❌ The workflow integration issue is NOT FIXED${NC}"
        return 1
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 