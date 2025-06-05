## [{{VERSION}}] - {{DATE}}

{{#if added}}

### Added

{{#each added}}

- {{this}}
  {{/each}}

{{/if}}
{{#if changed}}

### Changed

{{#each changed}}

- {{this}}
  {{/each}}

{{/if}}
{{#if deprecated}}

### Deprecated

{{#each deprecated}}

- {{this}}
  {{/each}}

{{/if}}
{{#if removed}}

### Removed

{{#each removed}}

- {{this}}
  {{/each}}

{{/if}}
{{#if fixed}}

### Fixed

{{#each fixed}}

- {{this}}
  {{/each}}

{{/if}}
{{#if security}}

### Security

{{#each security}}

- {{this}}
  {{/each}}

{{/if}}
