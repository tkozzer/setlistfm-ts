## 📋 Summary

{{summary}}

## 🔄 Changes

{{#each changes}}
{{this}}
{{/each}}

## 📝 Commit Analysis

- Total commits analyzed: {{commit_analysis.total_commits}}
- Conventional commits: {{commit_analysis.conventional_commits}} (feat, fix, chore, refactor)
  {{#if commit_analysis.suggestions}}

  Note: {{commit_analysis.suggestions}}
  {{/if}}

## 🧪 Testing

{{testing}}

## 📚 Documentation

{{documentation}}
