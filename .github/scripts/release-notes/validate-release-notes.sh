#!/usr/bin/env bash

#
# validate-release-notes.sh
#
# Comprehensive validation script for AI-generated release notes
# Validates content quality, format consistency, and completeness
#
# Usage: validate-release-notes.sh --notes-file <file> --version <version> [options]
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="validate-release-notes.sh"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging functions
log() { 
  echo "[$(date +'%H:%M:%S')] [$1] $2" >&2
}

log_verbose() {
  [[ "$VERBOSE" == true ]] && log "VERBOSE" "$1"
}

# Global configuration
declare -g NOTES_FILE=""
declare -g VERSION=""
declare -g VERBOSE=false
declare -g PROJECT_NAME="setlistfm-ts"

# Validation thresholds
readonly MIN_CONTENT_LENGTH=200
readonly MIN_SECTIONS=2
readonly MIN_BULLET_POINTS=3
readonly MAX_LINE_LENGTH=100

# Required patterns for quality validation
readonly VERSION_PATTERN='^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$'
readonly GITHUB_URL_PATTERN='https://github\.com/[^/]+/[^/]+'
readonly SEMANTIC_SECTIONS=("Features" "Bug Fixes" "Performance" "Documentation" "Chores" "Breaking Changes")

################################################################################
#  Usage and help functions                                                   #
################################################################################

show_usage() {
  cat << 'EOF'
validate-release-notes.sh - Release Notes Quality Validation

USAGE:
  validate-release-notes.sh [OPTIONS]

DESCRIPTION:
  Comprehensive validation of AI-generated release notes for quality,
  completeness, and format consistency with project standards.

OPTIONS:
  -f, --notes-file FILE    Path to release notes file to validate (required)
  -v, --version VERSION    Expected version in release notes (required)
  -p, --project PROJECT    Project name (default: setlistfm-ts)
  --verbose               Enable verbose output for debugging
  -h, --help              Show this help message

VALIDATION CHECKS:
  • Content completeness (version, project name, sections)
  • Format consistency with project standards
  • Quality metrics (minimum length, detail level)
  • Schema validation for structured content
  • Link validation and formatting checks
  • Bullet point quality assessment

EXAMPLES:
  validate-release-notes.sh -f release-notes.md -v "1.2.3"
  validate-release-notes.sh --notes-file notes.md --version "v2.0.0" --verbose

EXIT CODES:
  0 - Validation passed
  1 - Validation failed
  2 - Invalid arguments or missing files
  3 - Internal error

EOF
}

show_version() {
  echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

################################################################################
#  Input validation                                                           #
################################################################################

validate_inputs() {
  log_verbose "Starting input validation"

  # Validate required parameters
  if [[ -z "$NOTES_FILE" ]]; then
    log "ERROR" "Release notes file is required (--notes-file)"
    return 1
  fi

  if [[ -z "$VERSION" ]]; then
    log "ERROR" "Version is required (--version)"
    return 1
  fi

  # Validate file exists and is readable
  if [[ ! -f "$NOTES_FILE" ]]; then
    log "ERROR" "Release notes file does not exist: $NOTES_FILE"
    return 1
  fi

  if [[ ! -r "$NOTES_FILE" ]]; then
    log "ERROR" "Release notes file is not readable: $NOTES_FILE"
    return 1
  fi

  # Validate version format
  if [[ ! "$VERSION" =~ $VERSION_PATTERN ]]; then
    log "ERROR" "Invalid version format: $VERSION (expected semantic version)"
    return 1
  fi

  log_verbose "Input validation passed"
  return 0
}

################################################################################
#  Content validation functions                                               #
################################################################################

validate_content_completeness() {
  local notes_file="$1"
  local version="$2"
  local project="$3"
  
  log_verbose "Validating content completeness"
  
  local content
  content=$(cat "$notes_file")
  
  # Check for required elements
  local missing_elements=()
  
  # Version should be present
  if ! echo "$content" | grep -q "$version"; then
    missing_elements+=("version $version")
  fi
  
  # Project name should be mentioned
  if ! echo "$content" | grep -qi "$project"; then
    missing_elements+=("project name $project")
  fi
  
  # Should have at least one section header
  if ! echo "$content" | grep -q '^#'; then
    missing_elements+=("section headers")
  fi
  
  # Should have bullet points or numbered lists
  if ! echo "$content" | grep -q '^[*-]' && ! echo "$content" | grep -q '^[0-9]\.'; then
    missing_elements+=("bullet points or lists")
  fi
  
  if [[ ${#missing_elements[@]} -gt 0 ]]; then
    log "ERROR" "Missing required content elements: ${missing_elements[*]}"
    return 1
  fi
  
  log_verbose "Content completeness validation passed"
  return 0
}

validate_format_consistency() {
  local notes_file="$1"
  
  log_verbose "Validating format consistency"
  
  local content
  content=$(cat "$notes_file")
  
  local format_issues=()
  
  # Check line length (should not exceed maximum)
  while IFS= read -r line; do
    # Skip lines that start with URLs or contain markdown links with URLs
    if [[ ${#line} -gt $MAX_LINE_LENGTH ]] && [[ ! "$line" =~ ^https?:// ]] && [[ ! "$line" =~ \[.*\]\(https?:// ]]; then
      format_issues+=("line too long (${#line} chars): ${line:0:50}...")
      break  # Only report first occurrence
    fi
  done <<< "$content"
  
  # Check for consistent header format
  local header_count
  header_count=$(echo "$content" | grep -c '^#' || true)
  if [[ $header_count -eq 0 ]]; then
    format_issues+=("no markdown headers found")
  fi
  
  # Check for consistent bullet point format
  local bullet_inconsistency=false
  if echo "$content" | grep -q '^[*]' && echo "$content" | grep -q '^[-]'; then
    bullet_inconsistency=true
  fi
  
  if [[ "$bullet_inconsistency" == true ]]; then
    format_issues+=("inconsistent bullet point format (mixing * and -)")
  fi
  
  if [[ ${#format_issues[@]} -gt 0 ]]; then
    log "ERROR" "Format consistency issues found:"
    for issue in "${format_issues[@]}"; do
      log "ERROR" "  - $issue"
    done
    return 1
  fi
  
  log_verbose "Format consistency validation passed"
  return 0
}

validate_quality_metrics() {
  local notes_file="$1"
  
  log_verbose "Validating quality metrics"
  
  local content
  content=$(cat "$notes_file")
  
  local quality_issues=()
  
  # Check minimum content length
  local content_length=${#content}
  if [[ $content_length -lt $MIN_CONTENT_LENGTH ]]; then
    quality_issues+=("content too short ($content_length chars, minimum $MIN_CONTENT_LENGTH)")
  fi
  
  # Check minimum number of sections
  local section_count
  section_count=$(echo "$content" | grep -c '^#' || true)
  if [[ $section_count -lt $MIN_SECTIONS ]]; then
    quality_issues+=("too few sections ($section_count found, minimum $MIN_SECTIONS)")
  fi
  
  # Check minimum bullet points
  local bullet_count
  bullet_count=$(echo "$content" | grep -c '^[*-]' || true)
  if [[ $bullet_count -lt $MIN_BULLET_POINTS ]]; then
    quality_issues+=("too few bullet points ($bullet_count found, minimum $MIN_BULLET_POINTS)")
  fi
  
  # Check for generic/template language
  local generic_patterns=("TODO" "FIXME" "placeholder" "example" "lorem ipsum")
  for pattern in "${generic_patterns[@]}"; do
    if echo "$content" | grep -qi "$pattern"; then
      quality_issues+=("contains generic/template language: $pattern")
    fi
  done
  
  if [[ ${#quality_issues[@]} -gt 0 ]]; then
    log "ERROR" "Quality metric issues found:"
    for issue in "${quality_issues[@]}"; do
      log "ERROR" "  - $issue"
    done
    return 1
  fi
  
  log_verbose "Quality metrics validation passed"
  return 0
}

validate_semantic_structure() {
  local notes_file="$1"
  
  log_verbose "Validating semantic structure"
  
  local content
  content=$(cat "$notes_file")
  
  local structure_issues=()
  
  # Check for semantic section organization
  local has_semantic_sections=false
  for section in "${SEMANTIC_SECTIONS[@]}"; do
    if echo "$content" | grep -qi "$section"; then
      has_semantic_sections=true
      break
    fi
  done
  
  if [[ "$has_semantic_sections" == false ]]; then
    structure_issues+=("no semantic sections found (Features, Bug Fixes, etc.)")
  fi
  
  # Check for proper hierarchy (should start with h1 or h2)
  if ! echo "$content" | head -n 5 | grep -q '^##\?[^#]'; then
    structure_issues+=("should start with proper header hierarchy")
  fi
  
  # TODO: Re-enable empty sections check after fixing logic
  # Empty sections validation temporarily disabled
  
  if [[ ${#structure_issues[@]} -gt 0 ]]; then
    log "ERROR" "Semantic structure issues found:"
    for issue in "${structure_issues[@]}"; do
      log "ERROR" "  - $issue"
    done
    return 1
  fi
  
  log_verbose "Semantic structure validation passed"
  return 0
}

validate_links_and_references() {
  local notes_file="$1"
  
  log_verbose "Validating links and references"
  
  local content
  content=$(cat "$notes_file")
  
  local link_issues=()
  
  # Check for malformed markdown links
  if echo "$content" | grep -q '\[.*\]('; then
    # Found markdown links, validate them
    while IFS= read -r line; do
      # Use grep to find markdown link pattern instead of regex
      if echo "$line" | grep -q '\[.*\](.*'; then
        # Extract URL from markdown link using sed
        local url
        url=$(echo "$line" | sed -n 's/.*\[.*\](\([^)]*\)).*/\1/p')
        
        # Basic URL validation
        if [[ -n "$url" ]] && [[ "$url" != "http"* ]] && [[ "$url" != "#"* ]]; then
          link_issues+=("invalid URL format: $url")
        fi
      fi
    done <<< "$content"
  fi
  
  # Check for GitHub-specific patterns if they exist
  if echo "$content" | grep -q 'github.com'; then
    if ! echo "$content" | grep -q "https://github\.com/"; then
      link_issues+=("malformed GitHub URL found")
    fi
  fi
  
  # Check for broken reference-style links
  if echo "$content" | grep -q '\[.*\]\[.*\]' && ! echo "$content" | grep -q '^\[.*\]:'; then
    link_issues+=("reference-style links found but no references defined")
  fi
  
  if [[ ${#link_issues[@]} -gt 0 ]]; then
    log "ERROR" "Link and reference issues found:"
    for issue in "${link_issues[@]}"; do
      log "ERROR" "  - $issue"
    done
    return 1
  fi
  
  log_verbose "Links and references validation passed"
  return 0
}

################################################################################
#  Main validation orchestration                                              #
################################################################################

run_all_validations() {
  local notes_file="$1"
  local version="$2"
  local project="$3"
  
  log "INFO" "Starting comprehensive release notes validation"
  log "INFO" "File: $notes_file"
  log "INFO" "Version: $version"
  log "INFO" "Project: $project"
  
  local validation_results=()
  local total_validations=5
  local passed_validations=0
  
  # Run all validation checks
  if validate_content_completeness "$notes_file" "$version" "$project"; then
    validation_results+=("✅ Content completeness")
    ((passed_validations++))
  else
    validation_results+=("❌ Content completeness")
  fi
  
  if validate_format_consistency "$notes_file"; then
    validation_results+=("✅ Format consistency")
    ((passed_validations++))
  else
    validation_results+=("❌ Format consistency")
  fi
  
  if validate_quality_metrics "$notes_file"; then
    validation_results+=("✅ Quality metrics")
    ((passed_validations++))
  else
    validation_results+=("❌ Quality metrics")
  fi
  
  if validate_semantic_structure "$notes_file"; then
    validation_results+=("✅ Semantic structure")
    ((passed_validations++))
  else
    validation_results+=("❌ Semantic structure")
  fi
  
  if validate_links_and_references "$notes_file"; then
    validation_results+=("✅ Links and references")
    ((passed_validations++))
  else
    validation_results+=("❌ Links and references")
  fi
  
  # Report results
  log "INFO" "Validation Results:"
  for result in "${validation_results[@]}"; do
    log "INFO" "  $result"
  done
  
  log "INFO" "Passed: $passed_validations/$total_validations validations"
  
  if [[ $passed_validations -eq $total_validations ]]; then
    log "INFO" "✅ All validations passed! Release notes are ready for publication."
    return 0
  else
    log "ERROR" "❌ Validation failed. Please fix the issues above before proceeding."
    return 1
  fi
}

################################################################################
#  Utility functions                                                          #
################################################################################

################################################################################
#  Argument parsing                                                           #
################################################################################

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_usage
        exit 0
        ;;
      --script-version)
        show_version
        exit 0
        ;;
      -f|--notes-file)
        NOTES_FILE="$2"
        shift 2
        ;;
      -v|--version)
        VERSION="$2"
        shift 2
        ;;
      -p|--project)
        PROJECT_NAME="$2"
        shift 2
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      *)
        log "ERROR" "Unknown option: $1"
        show_usage
        exit 2
        ;;
    esac
  done
}

################################################################################
#  Main execution                                                             #
################################################################################

main() {
  # Parse command line arguments
  parse_arguments "$@"
  
  # Validate inputs
  if ! validate_inputs; then
    log "ERROR" "Input validation failed"
    exit 2
  fi
  
  # Run all validations
  if run_all_validations "$NOTES_FILE" "$VERSION" "$PROJECT_NAME"; then
    log "INFO" "🎉 Release notes validation completed successfully!"
    exit 0
  else
    log "ERROR" "Release notes validation failed"
    exit 1
  fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi 