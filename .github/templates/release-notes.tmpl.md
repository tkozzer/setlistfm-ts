# 🎉 setlistfm-ts v{{version}}

{{summary}}

## {{primary_section.emoji}} {{primary_section.title}}

{{#each primary_section.features}}
- {{this}}
{{/each}}

{{#if secondary_sections}}
{{#each secondary_sections}}
## {{emoji}} {{title}}

{{#each features}}
- {{this}}
{{/each}}

{{/each}}
{{/if}}

{{#if (and (eq version_type "major") (not breaking_changes))}}
## ⚠️ Breaking Changes
Major version released but no breaking changes were detected.
{{/if}}

{{#if breaking_changes}}
## ⚠️ Breaking Changes
{{breaking_changes}}
{{/if}}
{{#unless breaking_changes}}
## 🔒 No Breaking Changes
The SDK code, public APIs, and npm package contents remain exactly the same—upgrade with confidence, your existing integration will continue to work.
{{/unless}}

---
**Links**
- 📦 npm: {{footer_links.npm}}
- 📖 Full Changelog: {{footer_links.changelog}}
- 🐛 Issues: {{footer_links.issues}}

Thank you for using **setlistfm-ts**! 🙏
