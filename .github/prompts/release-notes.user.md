Generate structured release notes for version {{VERSION}} ({{VERSION_TYPE}} release) of the setlistfm-ts SDK.

The version number ({{VERSION}}) is handled by the template processing system - you do not need to include it in your JSON response.

## Context Data

**Changelog Entry:**
{{CHANGELOG_ENTRY}}

**Git Commits (JSON):**
{{GIT_COMMITS}}

**Commit Statistics:**
{{COMMIT_STATS}}

**Breaking Changes Detected:** {{HAS_BREAKING_CHANGES}}

**Previous Release Notes (for style reference):**
{{PREVIOUS_RELEASE}}

## Content Generation Instructions

1. **Generate bug_fixes array** by finding commits with "fix:" prefix in the GIT_COMMITS data:

   - Look for commit messages starting with "fix:" or "fix(scope):"
   - Transform each into a user-focused description: "**Fixed [issue]** [benefit/impact]"
   - If no fix commits found, return empty array []

2. **Generate ci_improvements array** by finding commits with "ci:" prefix in the GIT_COMMITS data:

   - Look for commit messages starting with "ci:" or "ci(scope):"
   - Transform each into a benefit-focused description: "**Enhanced [aspect]** [improvement/impact]"
   - If no ci commits found, return empty array []

3. **Use the COMMIT_STATS data** to populate the commit_analysis field exactly as provided

4. **Determine primary_section** based on the highest count in COMMIT_STATS:

   - feat_count highest → "New Features" with ✨ emoji
   - fix_count highest → "Bug Fixes" with 🐛 emoji
   - ci_count highest → "CI/DevOps Improvements" with 🤖 emoji
   - chore_count highest → "Infrastructure Improvements" with 🛠️ emoji

5. **Create secondary_sections** for other significant commit types (count > 0) that aren't the primary section

6. **Handle breaking_changes**:

   - If HAS_BREAKING_CHANGES is true, extract breaking change details from commits
   - Otherwise, set to empty string ""

7. **Always include standard footer_links**:
   - npm: "https://www.npmjs.com/package/setlistfm-ts"
   - changelog: "https://github.com/tkozzer/setlistfm-ts/blob/main/CHANGELOG.md"
   - issues: "https://github.com/tkozzer/setlistfm-ts/issues"

Return JSON following the exact structure from the system prompt. Do not include a "version" field in your response - version handling is done separately by the template system.
