Analyze the following commits for version {{VERSION}} released on {{DATE}} and generate structured changelog entries.

## Recent Commits:

```
{{COMMITS}}
```

## Instructions:

- Transform the raw commit messages above into user-friendly changelog entries
- Focus on developer impact and user-visible changes for the setlistfm-ts TypeScript SDK
- Group changes into appropriate categories (Added, Changed, Fixed, etc.)
- Filter out commits that don't affect end users (unless they're meaningful CI/tooling improvements)
- Consolidate related commits into single, clear entries
- Return structured JSON data following the provided schema

Return your response as structured JSON containing arrays for each changelog section.
