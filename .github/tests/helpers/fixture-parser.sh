#!/usr/bin/env bash

# 🧰 Fixture Parser Helper
# 
# Provides functions for parsing JSON fixture files in test scripts.
# This is a simplified JSON parser that works without dependencies like `jq`.
#
# Usage:
#   source .github/tests/helpers/fixture-parser.sh
#   parse_fixture_value "file.json" "scenarios.scenario_name.field"
#

# Parse a value from a JSON fixture file
# Args: $1 = fixture file name, $2 = JSON path (dot notation)
parse_fixture_value() {
    local fixture_file="$1"
    local json_path="$2"
    local fixtures_dir="${FIXTURES_DIR:-$(dirname "$0")/../fixtures}"
    
    if [[ ! -f "$fixtures_dir/$fixture_file" ]]; then
        echo ""
        return 1
    fi
    
    local content
    content=$(cat "$fixtures_dir/$fixture_file")
    
    # Convert dot notation to grep patterns
    # This is a simplified approach - in production, use jq
    local path_parts
    IFS='.' read -ra path_parts <<< "$json_path"
    
    local result="$content"
    local current_section=""
    
    for part in "${path_parts[@]}"; do
        if [[ -n "$current_section" ]]; then
            current_section="${current_section}.*\"$part\""
        else
            current_section="\"$part\""
        fi
    done
    
    # Extract the value using grep and sed
    result=$(echo "$content" | grep -A 50 "$current_section" | grep -m1 ': *[0-9"true]' | sed 's/.*: *\([^,}]*\).*/\1/' | tr -d '"')
    
    echo "$result"
}

# Parse an array from a JSON fixture file
# Args: $1 = fixture file name, $2 = JSON path to array
parse_fixture_array() {
    local fixture_file="$1"
    local json_path="$2"
    local fixtures_dir="${FIXTURES_DIR:-$(dirname "$0")/../fixtures}"
    
    if [[ ! -f "$fixtures_dir/$fixture_file" ]]; then
        echo ""
        return 1
    fi
    
    local content
    content=$(cat "$fixtures_dir/$fixture_file")
    
    # Find the array section and extract items
    local array_content
    array_content=$(echo "$content" | grep -A 100 "\"$json_path\":" | grep -o '"[^"]*"' | sed 's/"//g' | grep -v "$json_path")
    
    echo "$array_content"
}

# Get all scenario names from a fixture
# Args: $1 = fixture file name, $2 = section name (e.g., "scenarios")
get_fixture_scenarios() {
    local fixture_file="$1"
    local section="${2:-scenarios}"
    local fixtures_dir="${FIXTURES_DIR:-$(dirname "$0")/../fixtures}"
    
    if [[ ! -f "$fixtures_dir/$fixture_file" ]]; then
        echo ""
        return 1
    fi
    
    local content
    content=$(cat "$fixtures_dir/$fixture_file")
    
    # Extract scenario names
    echo "$content" | grep -A 1000 "\"$section\":" | grep -o '"[^"]*": {' | sed 's/": {//' | tr -d '"'
}

# Parse a complete scenario from fixture
# Args: $1 = fixture file name, $2 = scenario name
parse_fixture_scenario() {
    local fixture_file="$1"
    local scenario_name="$2"
    local fixtures_dir="${FIXTURES_DIR:-$(dirname "$0")/../fixtures}"
    
    if [[ ! -f "$fixtures_dir/$fixture_file" ]]; then
        return 1
    fi
    
    local content
    content=$(cat "$fixtures_dir/$fixture_file")
    
    # Extract the entire scenario block
    echo "$content" | grep -A 50 "\"$scenario_name\":" | sed '/^[[:space:]]*},[[:space:]]*$/q' | head -n -1
}

# Helper function to extract numeric values from scenario
get_scenario_number() {
    local scenario_content="$1"
    local field="$2"
    
    echo "$scenario_content" | grep "\"$field\":" | sed 's/.*: *\([0-9]*\).*/\1/'
}

# Helper function to extract string values from scenario
get_scenario_string() {
    local scenario_content="$1"
    local field="$2"
    
    echo "$scenario_content" | grep "\"$field\":" | sed 's/.*: *"\([^"]*\)".*/\1/'
}

# Helper function to extract boolean values from scenario
get_scenario_boolean() {
    local scenario_content="$1"
    local field="$2"
    
    echo "$scenario_content" | grep "\"$field\":" | sed 's/.*: *\(true\|false\).*/\1/'
}

# Validate that required fixture files exist
validate_fixtures() {
    local fixtures_dir="${FIXTURES_DIR:-$(dirname "$0")/../fixtures}"
    local required_files=("$@")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$fixtures_dir/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo "❌ Missing fixture files:" >&2
        for file in "${missing_files[@]}"; do
            echo "  - $file" >&2
        done
        return 1
    fi
    
    return 0
}

# List available fixtures
list_fixtures() {
    local fixtures_dir="${FIXTURES_DIR:-$(dirname "$0")/../fixtures}"
    
    if [[ ! -d "$fixtures_dir" ]]; then
        echo "Fixtures directory not found: $fixtures_dir" >&2
        return 1
    fi
    
    echo "Available fixtures:"
    find "$fixtures_dir" -name "*.json" -type f | sed "s|$fixtures_dir/||" | sort
} 