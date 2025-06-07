# 🎉 setlistfm-ts v{{version}}

{{summary}}

{{#if (gt commit_analysis.feat_count 0)}}
## ✨ New Features

{{#each primary_section.features}}
- {{this}}
{{/each}}
{{/if}}

{{#if (gt commit_analysis.fix_count 0)}}
## 🐛 Bug Fixes

{{#each bug_fixes}}
- {{this}}
{{/each}}
{{/if}}

{{#if (gt commit_analysis.ci_count 0)}}
## 🤖 CI/DevOps Improvements

{{#each ci_improvements}}
- {{this}}
{{/each}}
{{/if}}

{{#if secondary_sections}}
{{#each secondary_sections}}
## {{emoji}} {{title}}

{{#each features}}
- {{this}}
{{/each}}

{{/each}}
{{/if}}

{{#if (or breaking_changes commit_analysis.breaking_changes_detected)}}
## ⚠️ Breaking Changes
{{#if breaking_changes}}{{breaking_changes}}{{else}}Breaking changes detected in commits - see commit messages for details.{{/if}}
{{else}}
## 🔒 No Breaking Changes
The SDK code, public APIs, and npm package contents remain exactly the same—upgrade with confidence, your existing integration will continue to work.
{{/if}}

---
**Links**
- 📦 npm: {{footer_links.npm}}
- 📖 Full Changelog: {{footer_links.changelog}}
- 🐛 Issues: {{footer_links.issues}}

Thank you for using **setlistfm-ts**! 🙏
