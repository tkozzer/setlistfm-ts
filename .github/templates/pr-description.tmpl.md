## 🚀 Release v{{VERSION}}

{{title}}

## 📋 Overview

{{overview}}

{{#if whats_new}}

## 📝 What's New

{{#each whats_new}}

- {{.}}
  {{/each}}
  {{/if}}

## 🔄 Changes by Category

{{#if changes.features}}

### ✨ Features

{{#each changes.features}}

- {{.}}
  {{/each}}

{{/if}}
{{#if changes.bug_fixes}}

### 🐛 Bug Fixes

{{#each changes.bug_fixes}}

- {{.}}
  {{/each}}

{{/if}}
{{#if changes.improvements}}

### 🔧 Improvements

{{#each changes.improvements}}

- {{.}}
  {{/each}}

{{/if}}
{{#if changes.internal}}

### 🏗️ Internal

{{#each changes.internal}}

- {{.}}
  {{/each}}

{{/if}}
{{#if changes.documentation}}

### 📚 Documentation

{{#each changes.documentation}}

- {{.}}
  {{/each}}

{{/if}}

## 🧪 Testing & Quality

{{testing_notes}}

## 📚 Documentation

{{documentation_notes}}

## ⚠️ Breaking Changes

{{#if breaking_changes}}
{{#each breaking_changes}}

### {{change}}

**Migration:** {{migration}}

{{/each}}
{{/if}}
{{#unless breaking_changes}}
None in this release.
{{/unless}}

## 🔗 Merge Instructions

{{merge_instructions}}

---

**Generated on:** {{DATE}}
**Version:** {{VERSION}}
