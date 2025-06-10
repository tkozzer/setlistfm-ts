Generate structured release notes for version {{VERSION}} ({{VERSION_TYPE}} release) of the setlistfm-ts SDK.

**🚨 CRITICAL: Use EXACTLY version "{{VERSION}}" in ALL outputs. Do NOT infer or use any other version number from the context below. The version MUST be exactly "{{VERSION}}" without any modifications.**

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

1. **🎯 VERSION REQUIREMENT**: Use EXACTLY "{{VERSION}}" as the version number (remove any "v" prefix for the JSON field only). DO NOT use any version numbers you see in git commits, changelog entries, or other context.

2. **Extract the version number** from "{{VERSION}}" (remove any "v" prefix for the JSON field)

3. **Generate bug_fixes array** by finding commits with "fix:" prefix in the GIT_COMMITS data:

   - Look for commit messages starting with "fix:" or "fix(scope):"
   - Transform each into a user-focused description: "**Fixed [issue]** [benefit/impact]"
   - If no fix commits found, return empty array []

4. **Generate ci_improvements array** by finding commits with "ci:" prefix in the GIT_COMMITS data:

   - Look for commit messages starting with "ci:" or "ci(scope):"
   - Transform each into a benefit-focused description: "**Enhanced [aspect]** [improvement/impact]"
   - If no ci commits found, return empty array []

5. **Use the COMMIT_STATS data** to populate the commit_analysis field exactly as provided

6. **Determine primary_section** based on the highest count in COMMIT_STATS:

   - feat_count highest → "New Features" with ✨ emoji
   - fix_count highest → "Bug Fixes" with 🐛 emoji
   - ci_count highest → "CI/DevOps Improvements" with 🤖 emoji
   - chore_count highest → "Infrastructure Improvements" with 🛠️ emoji

7. **Create secondary_sections** for other significant commit types (count > 0) that aren't the primary section

8. **Handle breaking_changes**:

   - If HAS_BREAKING_CHANGES is true, extract breaking change details from commits
   - Otherwise, set to empty string ""

9. **Always include standard footer_links**:
   - npm: "https://www.npmjs.com/package/setlistfm-ts"
   - changelog: "https://github.com/tkozzer/setlistfm-ts/blob/main/CHANGELOG.md"
   - issues: "https://github.com/tkozzer/setlistfm-ts/issues"

Return JSON following the exact structure and field requirements from the system prompt.

**🚨 FINAL REMINDER: The "version" field in your JSON response MUST be exactly "{{VERSION}}" (without "v" prefix). Do not use any other version number from git history or changelog data.**
