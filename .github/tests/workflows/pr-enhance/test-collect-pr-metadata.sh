#!/usr/bin/env bash
set -euo pipefail

# Test script for collect-pr-metadata.sh
# This test validates the PR metadata collection logic extracted from pr-enhance workflow

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../../../scripts/pr-enhance"
FIXTURES_DIR="$SCRIPT_DIR/../../fixtures/workflows/pr-enhance/pr-metadata"
COLLECT_SCRIPT="$SCRIPTS_DIR/collect-pr-metadata.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

total_tests=0
passed_tests=0

# Function to run a test
run_test() {
    local name="$1"
    local setup_function="$2"
    local check_function="$3"
    
    total_tests=$((total_tests + 1))
    
    echo -e "${BLUE}Running: $name${NC}"
    
    # Setup test environment
    local test_dir="test_env_$$_$total_tests"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Initialize git repo
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Run setup
    if $setup_function; then
        # Run the script
        "$COLLECT_SCRIPT" > script_output.txt 2>&1 || true
        
        # Run the check
        if $check_function; then
            echo -e "${GREEN}✅ $name${NC}"
            passed_tests=$((passed_tests + 1))
        else
            echo -e "${RED}❌ $name${NC}"
            echo "Debug info:"
            echo "Current directory: $(pwd)"
            echo "Files in directory:"
            ls -la
            echo "Script output:"
            cat script_output.txt 2>/dev/null || echo "No script output"
            echo "Environment variables:"
            env | grep -E "(PR_NUMBER|PR_TITLE|BASE_SHA|HEAD_SHA|OUTPUT_FILE|TEST_MODE)" || echo "No relevant env vars found"
        fi
    else
        echo -e "${RED}❌ $name (setup failed)${NC}"
    fi
    
    # Cleanup
    cd ..
    rm -rf "$test_dir"
}

# Function to run a simple validation test
run_validation_test() {
    local name="$1"
    local expected_exit_code="$2"
    shift 2
    local env_vars=("$@")
    
    total_tests=$((total_tests + 1))
    
    echo -e "${BLUE}Running: $name${NC}"
    
    # Setup test environment
    local test_dir="test_env_$$_$total_tests"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Set environment variables
    for var in "${env_vars[@]}"; do
        export "$var"
    done
    
    # Run script and capture exit code
    local actual_exit_code=0
    "$COLLECT_SCRIPT" > output.txt 2>&1 || actual_exit_code=$?
    
    if [[ $actual_exit_code -eq $expected_exit_code ]]; then
        echo -e "${GREEN}✅ $name${NC}"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}❌ $name${NC}"
        echo "Expected exit code: $expected_exit_code, got: $actual_exit_code"
        echo "Output:"
        cat output.txt
    fi
    
    # Cleanup environment
    for var in "${env_vars[@]}"; do
        unset "${var%%=*}"
    done
    
    cd ..
    rm -rf "$test_dir"
}

# Test setup functions
setup_basic_commits() {
    # Create initial commit
    echo "Initial commit" > README.md
    git add README.md
    git commit -m "initial: setup repository" --quiet
    local base_sha=$(git rev-parse HEAD)
    
    # Create feature commits
    echo "Feature 1" > feature1.txt
    git add feature1.txt
    git commit -m "feat: add new feature" --quiet
    
    echo "Fix issue" > fix.txt
    git add fix.txt
    git commit -m "fix(ui): resolve button alignment" --quiet
    
    echo "Documentation" > docs.md
    git add docs.md
    git commit -m "docs: update installation guide" --quiet
    
    local head_sha=$(git rev-parse HEAD)
    
    export PR_NUMBER="123"
    export PR_TITLE="Test PR with conventional commits"
    export PR_BODY="This is a test PR body with multiple lines"
    export BASE_SHA="$base_sha"
    export HEAD_SHA="$head_sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
}

setup_mixed_commits() {
    # Create initial commit
    echo "Initial" > README.md
    git add README.md
    git commit -m "initial commit" --quiet
    local base_sha=$(git rev-parse HEAD)
    
    # Mix of conventional and non-conventional commits
    echo "Feature" > feature.txt
    git add feature.txt
    git commit -m "feat(api): add user authentication" --quiet
    
    echo "Random change" > random.txt
    git add random.txt
    git commit -m "made some changes" --quiet
    
    echo "Style fix" > style.css
    git add style.css
    git commit -m "style: fix css formatting" --quiet
    
    echo "Another random" > another.txt
    git add another.txt
    git commit -m "update stuff" --quiet
    
    local head_sha=$(git rev-parse HEAD)
    
    export PR_NUMBER="456"
    export PR_TITLE="Mixed commit types"
    export PR_BODY=""
    export BASE_SHA="$base_sha"
    export HEAD_SHA="$head_sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
}

setup_all_commit_types() {
    # Create initial commit
    echo "Initial" > README.md
    git add README.md
    git commit -m "initial setup" --quiet
    local base_sha=$(git rev-parse HEAD)
    
    # Create commits for each conventional type
    echo "feat" > feat.txt && git add feat.txt && git commit -m "feat: new feature" --quiet
    echo "fix" > fix.txt && git add fix.txt && git commit -m "fix: bug fix" --quiet
    echo "docs" > docs.txt && git add docs.txt && git commit -m "docs: documentation" --quiet
    echo "style" > style.txt && git add style.txt && git commit -m "style: formatting" --quiet
    echo "refactor" > refactor.txt && git add refactor.txt && git commit -m "refactor: code cleanup" --quiet
    echo "perf" > perf.txt && git add perf.txt && git commit -m "perf: optimization" --quiet
    echo "test" > test.txt && git add test.txt && git commit -m "test: add tests" --quiet
    echo "chore" > chore.txt && git add chore.txt && git commit -m "chore: maintenance" --quiet
    echo "ci" > ci.txt && git add ci.txt && git commit -m "ci: update pipeline" --quiet
    echo "build" > build.txt && git add build.txt && git commit -m "build: update deps" --quiet
    
    local head_sha=$(git rev-parse HEAD)
    
    export PR_NUMBER="789"
    export PR_TITLE="All commit types"
    export PR_BODY="Testing all conventional commit types"
    export BASE_SHA="$base_sha"
    export HEAD_SHA="$head_sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
}

setup_scoped_commits() {
    # Create initial commit
    echo "Initial" > README.md
    git add README.md
    git commit -m "initial" --quiet
    local base_sha=$(git rev-parse HEAD)
    
    # Create scoped commits
    echo "api" > api.txt && git add api.txt && git commit -m "feat(api): add endpoint" --quiet
    echo "ui" > ui.txt && git add ui.txt && git commit -m "fix(ui): button color" --quiet
    echo "core" > core.txt && git add core.txt && git commit -m "refactor(core): simplify logic" --quiet
    echo "ci-scoped" > ci-scoped.txt && git add ci-scoped.txt && git commit -m "feat(ci): add workflow" --quiet
    echo "build-scoped" > build-scoped.txt && git add build-scoped.txt && git commit -m "chore(build): update deps" --quiet
    
    local head_sha=$(git rev-parse HEAD)
    
    export PR_NUMBER="101"
    export PR_TITLE="Scoped commits"
    export PR_BODY="Testing scoped conventional commits"
    export BASE_SHA="$base_sha"
    export HEAD_SHA="$head_sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
}

setup_breaking_changes() {
    # Create initial commit
    echo "Initial" > README.md
    git add README.md
    git commit -m "initial" --quiet
    local base_sha=$(git rev-parse HEAD)
    
    # Breaking change commits
    echo "breaking1" > breaking1.txt && git add breaking1.txt && git commit -m "feat!: breaking API change" --quiet
    echo "breaking2" > breaking2.txt && git add breaking2.txt && git commit -m "fix: something BREAKING CHANGE: removed method" --quiet
    
    local head_sha=$(git rev-parse HEAD)
    
    export PR_NUMBER="202"
    export PR_TITLE="Breaking changes"
    export PR_BODY="Testing breaking change detection"
    export BASE_SHA="$base_sha"
    export HEAD_SHA="$head_sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
}

setup_empty_range() {
    # Create a commit and use same SHA for base and head
    echo "Same commit" > same.txt
    git add same.txt
    git commit -m "feat: same commit" --quiet
    local sha=$(git rev-parse HEAD)
    
    export PR_NUMBER="303"
    export PR_TITLE="Empty range"
    export PR_BODY="Testing empty commit range"
    export BASE_SHA="$sha"
    export HEAD_SHA="$sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
}

# Test using fixture scenario data
test_fixture_scenario() {
    local scenario_name="$1"
    local pr_number="${2:-123}"
    
    echo -e "${BLUE}Running: Fixture scenario - $scenario_name${NC}"
    
    # Load fixture data
    local fixture_content
    fixture_content=$(cat "$FIXTURES_DIR/pr-metadata-commits.json" 2>/dev/null)
    
    if [[ -z "$fixture_content" ]]; then
        echo -e "${RED}❌ Fixture scenario - $scenario_name (missing fixture file)${NC}"
        total_tests=$((total_tests + 1))
        return
    fi
    
    # Parse fixture data to extract commits and expected values
    local commits expected_total expected_conv expected_feat expected_fix expected_docs
    
    # Parse the specific scenario section
    local scenario_section
    scenario_section=$(echo "$fixture_content" | awk "/\"$scenario_name\":/{flag=1} flag && /^[[:space:]]*}[[:space:]]*,?$/{flag=0} flag")
    
    # Extract commit list and expected values
    commits=$(echo "$scenario_section" | sed -n '/"commits":/,/]/p' | grep '^[[:space:]]*"[a-zA-Z0-9]' | grep -v '"commits"' | sed 's/^[[:space:]]*"//g' | sed 's/",*$//')
    
    # Values are nested under "expected" key
    local expected_section
    expected_section=$(echo "$scenario_section" | awk '/"expected"/{flag=1} flag && /^[[:space:]]*}[[:space:]]*,?$/{flag=0} flag')
    
    expected_total=$(echo "$expected_section" | grep '"total":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
    expected_conv=$(echo "$expected_section" | grep '"conv":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
    expected_feat=$(echo "$expected_section" | grep '"feat":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
    expected_fix=$(echo "$expected_section" | grep '"fix":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
    expected_docs=$(echo "$expected_section" | grep '"docs":' | head -1 | sed 's/.*: *\([0-9]*\).*/\1/')
    
    if [[ -z "$expected_total" ]]; then
        echo -e "${RED}❌ Fixture scenario - $scenario_name (could not parse fixture data)${NC}"
        total_tests=$((total_tests + 1))
        return
    fi
    
    # Setup test environment
    local test_dir="test_env_fixture_$$"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Initialize git repo
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "Initial commit" > README.md
    git add README.md
    git commit -m "initial: setup repository" --quiet
    local base_sha=$(git rev-parse HEAD)
    
    # Create commits from fixture data
    local commit_count=0
    while IFS= read -r commit_line; do
        if [[ -n "$commit_line" ]]; then
            # Extract commit message (everything after the hash)
            local commit_msg=$(echo "$commit_line" | sed 's/^[a-zA-Z0-9]* //')
            echo "Commit content $commit_count" > "file_$commit_count.txt"
            git add .
            git commit -m "$commit_msg" --quiet
            commit_count=$((commit_count + 1))
        fi
    done <<< "$commits"
    
    local head_sha=$(git rev-parse HEAD)
    
    # Set environment variables
    export PR_NUMBER="$pr_number"
    export PR_TITLE="Fixture test: $scenario_name"
    export PR_BODY="Testing scenario from fixture: $scenario_name"
    export BASE_SHA="$base_sha"
    export HEAD_SHA="$head_sha"
    export OUTPUT_FILE="output.txt"
    export TEST_MODE="true"
    
    # Run the script
    "$COLLECT_SCRIPT" > script_output.txt 2>&1 || true
    
    # Check results against expected values
    if [[ -f output.txt ]]; then
        local actual_total actual_conv actual_feat actual_fix actual_docs
        actual_total=$(grep "^total=" output.txt | cut -d= -f2)
        actual_conv=$(grep "^conv=" output.txt | cut -d= -f2)
        actual_feat=$(grep "^feat=" output.txt | cut -d= -f2)
        actual_fix=$(grep "^fix=" output.txt | cut -d= -f2)
        actual_docs=$(grep "^docs=" output.txt | cut -d= -f2)
        
        if [[ "$actual_total" == "$expected_total" && "$actual_conv" == "$expected_conv" && "$actual_feat" == "$expected_feat" && "$actual_fix" == "$expected_fix" && "$actual_docs" == "$expected_docs" ]]; then
            echo -e "${GREEN}✅ Fixture scenario - $scenario_name${NC}"
            passed_tests=$((passed_tests + 1))
        else
            echo -e "${RED}❌ Fixture scenario - $scenario_name${NC}"
            echo "Expected: total=$expected_total, conv=$expected_conv, feat=$expected_feat, fix=$expected_fix, docs=$expected_docs"
            echo "Actual: total=$actual_total, conv=$actual_conv, feat=$actual_feat, fix=$actual_fix, docs=$actual_docs"
        fi
    else
        echo -e "${RED}❌ Fixture scenario - $scenario_name (no output file)${NC}"
    fi
    
    total_tests=$((total_tests + 1))
    
    # Cleanup
    cd ..
    rm -rf "$test_dir"
    unset PR_NUMBER PR_TITLE PR_BODY BASE_SHA HEAD_SHA OUTPUT_FILE TEST_MODE
}

# Test check functions
check_basic_output() {
    if [[ ! -f output.txt ]]; then
        echo "Output file not created"
        return 1
    fi
    
    # Check required fields
    local required_fields=("number=123" "title=Test PR with conventional commits" "total=3" "files_count=3")
    for field in "${required_fields[@]}"; do
        if ! grep -q "^$field$" output.txt; then
            echo "Missing field: $field"
            cat output.txt
            return 1
        fi
    done
    
    # Check conventional commit counts
    if ! grep -q "^feat=1$" output.txt; then
        echo "Wrong feat count"
        return 1
    fi
    
    if ! grep -q "^fix=1$" output.txt; then
        echo "Wrong fix count"
        return 1
    fi
    
    if ! grep -q "^docs=1$" output.txt; then
        echo "Wrong docs count"
        return 1
    fi
    
    if ! grep -q "^conv=3$" output.txt; then
        echo "Wrong conventional total"
        return 1
    fi
    
    return 0
}

check_mixed_commits() {
    if [[ ! -f output.txt ]]; then
        echo "Output file not created"
        return 1
    fi
    
    # Should have 4 total commits but only 2 conventional
    if ! grep -q "^total=4$" output.txt; then
        echo "Wrong total count"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^conv=2$" output.txt; then
        echo "Wrong conventional count"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^feat=1$" output.txt; then
        echo "Wrong feat count"
        return 1
    fi
    
    if ! grep -q "^style=1$" output.txt; then
        echo "Wrong style count"
        return 1
    fi
    
    return 0
}

check_all_commit_types() {
    if [[ ! -f output.txt ]]; then
        echo "Output file not created"
        return 1
    fi
    
    # Check each type appears exactly once
    local types=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore")
    for type in "${types[@]}"; do
        if ! grep -q "^$type=1$" output.txt; then
            echo "Wrong $type count"
            cat output.txt
            return 1
        fi
    done
    
    # Check CI count (should include both ci and build)
    if ! grep -q "^ci=2$" output.txt; then
        echo "Wrong ci count (should include build)"
        cat output.txt
        return 1
    fi
    
    # Total conventional should be 10 (8 regular + 2 ci/build)
    if ! grep -q "^conv=10$" output.txt; then
        echo "Wrong conventional total"
        cat output.txt
        return 1
    fi
    
    return 0
}

check_scoped_commits() {
    if [[ ! -f output.txt ]]; then
        echo "Output file not created"
        return 1
    fi
    
    # Check scoped commits are counted correctly
    # feat(api) + feat(ci) = 2 feat commits
    if ! grep -q "^feat=2$" output.txt; then
        echo "Scoped feat count wrong (expected 2: feat(api) + feat(ci))"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^fix=1$" output.txt; then
        echo "Scoped fix not counted"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^refactor=1$" output.txt; then
        echo "Scoped refactor not counted"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^chore=1$" output.txt; then
        echo "Scoped chore not counted"
        cat output.txt
        return 1
    fi
    
    # CI should count both feat(ci) and chore(build) = 2
    if ! grep -q "^ci=2$" output.txt; then
        echo "Scoped CI not counted correctly (expected 2: feat(ci) + chore(build))"
        cat output.txt
        return 1
    fi
    
    # Total conventional: feat(2) + fix(1) + refactor(1) + chore(1) + ci(2) = 7
    if ! grep -q "^conv=7$" output.txt; then
        echo "Wrong conventional total for scoped commits (expected 7)"
        cat output.txt
        return 1
    fi
    
    return 0
}

check_breaking_changes() {
    if [[ ! -f output.txt ]]; then
        echo "Output file not created"
        return 1
    fi
    
    # Check breaking changes detected
    if ! grep -q "^break=2$" output.txt; then
        echo "Breaking changes not detected correctly"
        cat output.txt
        return 1
    fi
    
    return 0
}

check_empty_range() {
    if [[ ! -f output.txt ]]; then
        echo "Output file not created"
        return 1
    fi
    
    # Should have zero commits and files
    if ! grep -q "^total=0$" output.txt; then
        echo "Should have zero commits"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^files_count=0$" output.txt; then
        echo "Should have zero files"
        cat output.txt
        return 1
    fi
    
    if ! grep -q "^conv=0$" output.txt; then
        echo "Should have zero conventional commits"
        cat output.txt
        return 1
    fi
    
    return 0
}

# Test the help option
test_help_option() {
    total_tests=$((total_tests + 1))
    
    echo -e "${BLUE}Running: Help option test${NC}"
    
    if "$COLLECT_SCRIPT" --help > help_output.txt 2>&1; then
        if grep -q "Usage:" help_output.txt && grep -q "Environment Variables:" help_output.txt; then
            echo -e "${GREEN}✅ Help option test${NC}"
            passed_tests=$((passed_tests + 1))
        else
            echo -e "${RED}❌ Help option test (missing expected content)${NC}"
            cat help_output.txt
        fi
    else
        echo -e "${RED}❌ Help option test (failed to run)${NC}"
    fi
    
    rm -f help_output.txt
}

# Main test execution
main() {
    echo "🧪 Testing collect-pr-metadata.sh script..."
    echo ""
    
    # Check if script exists and is executable
    if [[ ! -f "$COLLECT_SCRIPT" ]]; then
        echo -e "${RED}❌ Script not found: $COLLECT_SCRIPT${NC}"
        exit 1
    fi
    
    if [[ ! -x "$COLLECT_SCRIPT" ]]; then
        echo -e "${YELLOW}⚠️  Making script executable...${NC}"
        chmod +x "$COLLECT_SCRIPT"
    fi
    
    echo -e "${BLUE}📋 Running validation tests...${NC}"
    
    # Test missing required environment variables
    run_validation_test "Missing PR_NUMBER" 1 "PR_TITLE=test" "BASE_SHA=abc123" "HEAD_SHA=def456"
    run_validation_test "Missing PR_TITLE" 1 "PR_NUMBER=123" "BASE_SHA=abc123" "HEAD_SHA=def456"
    run_validation_test "Missing BASE_SHA" 1 "PR_NUMBER=123" "PR_TITLE=test" "HEAD_SHA=def456"
    run_validation_test "Missing HEAD_SHA" 1 "PR_NUMBER=123" "PR_TITLE=test" "BASE_SHA=abc123"
    
    echo ""
    echo -e "${BLUE}📊 Running fixture-based tests...${NC}"
    
    # Test scenarios from fixtures
    test_fixture_scenario "basic_conventional"
    test_fixture_scenario "mixed_conventional"
    test_fixture_scenario "all_types"
    test_fixture_scenario "scoped_commits"
    test_fixture_scenario "breaking_changes"
    
    echo ""
    echo -e "${BLUE}📊 Running functional tests...${NC}"
    
    # Test help option
    test_help_option
    
    # Functional tests with git repositories
    run_test "Basic conventional commits" setup_basic_commits check_basic_output
    run_test "Mixed commit types" setup_mixed_commits check_mixed_commits
    run_test "All commit types" setup_all_commit_types check_all_commit_types
    run_test "Scoped commits" setup_scoped_commits check_scoped_commits
    run_test "Breaking changes" setup_breaking_changes check_breaking_changes
    run_test "Empty commit range" setup_empty_range check_empty_range
    
    echo ""
    echo -e "${BLUE}📈 Test Summary${NC}"
    echo "Total tests: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $((total_tests - passed_tests))"
    
    if [[ $passed_tests -eq $total_tests ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed!${NC}"
        exit 1
    fi
}

main "$@" 