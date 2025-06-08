#!/usr/bin/env bash

#
# @file determine-version.sh
# @description Determines the target version for setlistfm-ts releases based on trigger type.
# @author tkozzer
# @module release-notes
#

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERBOSE=false
OUTPUT_FILE=""
PACKAGE_JSON_PATH="package.json"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Determines the target version for setlistfm-ts releases.

Options:
    --trigger-type TYPE     Trigger type: 'workflow_dispatch' or 'workflow_run'
    --manual-version VER    Manual version (required if trigger-type is workflow_dispatch)
    --package-json PATH     Path to package.json file (default: package.json)
    --output-file FILE      Write version to file instead of stdout
    --verbose               Enable verbose output
    --help                  Show this help message

Environment Variables:
    GITHUB_EVENT_NAME       GitHub event name (alternative to --trigger-type)
    GITHUB_EVENT_INPUTS     GitHub event inputs JSON (alternative to --manual-version)

Examples:
    # Manual trigger with specific version
    $0 --trigger-type workflow_dispatch --manual-version 1.2.3

    # Automatic trigger reading from package.json
    $0 --trigger-type workflow_run

    # Using environment variables (GitHub Actions context)
    GITHUB_EVENT_NAME=workflow_dispatch $0 --manual-version 1.2.3

    # Output to file
    $0 --trigger-type workflow_run --output-file version.txt

EOF
}

log() {
    local level="$1"
    shift
    case "$level" in
        "ERROR")
            echo -e "${RED}❌ ERROR: $*${NC}" >&2
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ SUCCESS: $*${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $*${NC}" >&2
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO: $*${NC}" >&2
            ;;
        "VERBOSE")
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${BLUE}🔍 VERBOSE: $*${NC}" >&2
            fi
            ;;
    esac
}

validate_semver() {
    local version="$1"
    
    # Basic semver pattern: MAJOR.MINOR.PATCH with optional pre-release and build metadata
    local semver_pattern='^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$'
    
    if [[ "$version" =~ $semver_pattern ]]; then
        return 0
    else
        return 1
    fi
}

validate_inputs() {
    local errors=()
    
    # Determine trigger type from environment if not provided
    if [[ -z "${TRIGGER_TYPE:-}" ]] && [[ -n "${GITHUB_EVENT_NAME:-}" ]]; then
        TRIGGER_TYPE="$GITHUB_EVENT_NAME"
        log "VERBOSE" "Using trigger type from environment: $TRIGGER_TYPE"
    fi
    
    # Check required parameters
    if [[ -z "${TRIGGER_TYPE:-}" ]]; then
        errors+=("Trigger type is required (use --trigger-type or set GITHUB_EVENT_NAME)")
    fi
    
    # Validate trigger type
    if [[ -n "${TRIGGER_TYPE:-}" ]] && [[ "$TRIGGER_TYPE" != "workflow_dispatch" ]] && [[ "$TRIGGER_TYPE" != "workflow_run" ]]; then
        errors+=("Trigger type must be 'workflow_dispatch' or 'workflow_run', got: $TRIGGER_TYPE")
    fi
    
    # For manual triggers, validate manual version
    if [[ "${TRIGGER_TYPE:-}" == "workflow_dispatch" ]]; then
        if [[ -z "${MANUAL_VERSION:-}" ]]; then
            errors+=("Manual version is required for workflow_dispatch trigger")
        elif ! validate_semver "$MANUAL_VERSION"; then
            errors+=("Manual version must be valid semver format (e.g., 1.2.3, 1.2.3-beta.1): $MANUAL_VERSION")
        fi
    fi
    
    # For automatic triggers, validate package.json exists
    if [[ "${TRIGGER_TYPE:-}" == "workflow_run" ]]; then
        if [[ ! -f "$PACKAGE_JSON_PATH" ]]; then
            errors+=("Package.json file not found: $PACKAGE_JSON_PATH")
        elif [[ ! -r "$PACKAGE_JSON_PATH" ]]; then
            errors+=("Package.json file is not readable: $PACKAGE_JSON_PATH")
        fi
    fi
    
    # Check if node is available for package.json parsing
    if [[ "${TRIGGER_TYPE:-}" == "workflow_run" ]] && ! command -v node &> /dev/null; then
        errors+=("Node.js is required to parse package.json but is not available in PATH")
    fi
    
    if [[ ${#errors[@]} -gt 0 ]]; then
        log "ERROR" "Validation failed:"
        for error in "${errors[@]}"; do
            echo "  - $error" >&2
        done
        exit 1
    fi
    
    log "VERBOSE" "Input validation passed"
}

extract_version_from_package_json() {
    local package_json="$1"
    
    log "VERBOSE" "Extracting version from package.json: $package_json"
    
    # Check if file contains valid JSON
    if ! node -e "JSON.parse(require('fs').readFileSync('$package_json', 'utf8'))" &>/dev/null; then
        log "ERROR" "Invalid JSON in package.json file: $package_json"
        exit 1
    fi
    
    # Extract version
    local version
    if ! version=$(node -p "require('./$package_json').version" 2>/dev/null); then
        log "ERROR" "Failed to extract version from package.json"
        exit 1
    fi
    
    # Validate extracted version
    if [[ -z "$version" ]] || [[ "$version" == "undefined" ]]; then
        log "ERROR" "No version found in package.json"
        exit 1
    fi
    
    if ! validate_semver "$version"; then
        log "ERROR" "Invalid version format in package.json: $version"
        exit 1
    fi
    
    log "VERBOSE" "Successfully extracted version from package.json: $version"
    echo "$version"
}

determine_version() {
    local version=""
    
    case "$TRIGGER_TYPE" in
        "workflow_dispatch")
            log "INFO" "Manual trigger detected, using provided version"
            version="$MANUAL_VERSION"
            log "VERBOSE" "Manual version: $version"
            ;;
        "workflow_run")
            log "INFO" "Automatic trigger detected, reading version from package.json"
            version=$(extract_version_from_package_json "$PACKAGE_JSON_PATH")
            ;;
        *)
            log "ERROR" "Unsupported trigger type: $TRIGGER_TYPE"
            exit 1
            ;;
    esac
    
    # Final validation
    if ! validate_semver "$version"; then
        log "ERROR" "Final version validation failed: $version"
        exit 1
    fi
    
    log "SUCCESS" "Determined version: $version"
    
    # Output version
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo "$version" > "$OUTPUT_FILE"
        log "INFO" "Version written to file: $OUTPUT_FILE"
    else
        echo "$version"
    fi
}

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --trigger-type)
                TRIGGER_TYPE="$2"
                shift 2
                ;;
            --manual-version)
                MANUAL_VERSION="$2"
                shift 2
                ;;
            --package-json)
                PACKAGE_JSON_PATH="$2"
                shift 2
                ;;
            --output-file)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Validate inputs
    validate_inputs
    
    # Execute main logic
    determine_version
    
    log "VERBOSE" "Version determination completed successfully"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 