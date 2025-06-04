# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.4.0] - 2025-06-04

## [0.4.0] - 2025-06-04

### Fixed
- Completely rewrote the release preparation GitHub Actions workflow to improve robustness, maintainability, and security:
  - Resolved multiple shell interpretation issues that caused failures when commit messages or changelog entries contained backticks, markdown code blocks, or special characters.
  - Replaced unsafe variable expansions with file-based templates and heredoc syntax to prevent command injection and shell execution of commit message content.
  - Switched from -based JSON templating to  for safer, more reliable changelog JSON generation, eliminating errors caused by special characters in commit messages.
  - Added comprehensive error handling and graceful fallbacks for OpenAI API calls used in changelog generation, ensuring the release process continues smoothly even if the API fails or returns empty responses.
  - Fixed SIGPIPE errors in commit collection by using commit 6d773049d67a2ec0125e2df47e2407d6b18f861b
Merge: b359652 c137a93
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 08:08:43 2025 -0500

    Merge pull request #41 from tkozzer/fix/create-release-error
    
    Fix/create release error

commit b35965231bb39085d658ab30904568f314a023a1
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 08:05:00 2025 -0500

    Update release-preparation.yml

commit c137a93b5ea35a3dea133c7dfe1f90e071f70587
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 08:03:48 2025 -0500

    fix(ci): resolve shell interpretation errors in release preparation workflow
    
    * Replaces direct GitHub Actions interpolation with environment variables to prevent shell command execution of commit message content
    * Fixes critical bug where words like 'feature' and 'bugfix' in commit messages were interpreted as shell commands
    * Simplifies variable naming throughout (CUR, NEW, VER, RES, CODE, BODY) for better readability
    * Streamlines system message creation using command substitution instead of read -r -d ''
    * Optimizes file operations with direct piping for commit content truncation
    * Enhances visual clarity with Unicode arrows (⇒, ➡️) in output messages
    * Maintains consistent environment variable approach across version bump and changelog steps
    * Preserves all error handling and fallback mechanisms while improving robustness
    
    The previous approach caused workflow failures when commit messages contained words that resembled shell commands. This refactoring ensures commit content is treated as data rather than executable code, making the release process much more reliable.

commit 1293a6209b1623b66c187f9397e122dc02680532
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 07:53:09 2025 -0500

    fix(ci): resolve SIGPIPE error in release preparation workflow
    
    * Replace git log piped to head with --max-count flag to avoid SIGPIPE
    * Eliminates exit code 141 error when fewer than 50 commits exist
    * Improves reliability of commit collection step in release workflow
    * Add spacing and comments for better readability
    
    The previous approach using 'git log | head -50' caused SIGPIPE when head
    closed the pipe early, causing git log to exit with code 141. Using
    --max-count=50 tells git to only generate the needed commits without
    requiring a pipe, making the workflow more robust.

commit d02a22b9cf33f82196a7cb29fbff65af5326c745
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 07:52:00 2025 -0500

    Update release-preparation.yml

commit 5df8c71fb5eb0eb9f2f27074b98d260c025629b4
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 07:44:48 2025 -0500

    refactor(ci): completely rewrite release-preparation workflow for robustness and maintainability
    
    * Fixed critical printf format string vulnerability that could cause failures with % characters in commit messages
    * Added 12KB input size limiting to prevent OpenAI API payload overflow issues
    * Replaced problematic ANSI-C quoted long strings with safer here-doc approach
    * Added comprehensive error handling with graceful fallbacks for API failures
    * Implemented explicit shell declarations for consistency across environments
    * Organized code into clear sections with descriptive comment headers
    * Replaced Unicode characters (em-dashes, ellipsis) to resolve linter errors
    * Enhanced commit processing with safer printf '%s\n' instead of echo
    * Improved JSON generation using jq --arg to eliminate escaping vulnerabilities
    * Added 'Nothing to commit' fallback to prevent git commit failures
    * Standardized error messages and logging for better debugging
    
    The workflow is now much more resilient to edge cases, easier to maintain,
    and follows shell scripting best practices. All critical security and
    reliability issues have been addressed.

commit 7e40325f2d7652efdca1b298d4e3b367feb14109
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 07:43:06 2025 -0500

    Update release-preparation.yml

commit dfcd6c73f9b211366641d4ee6ded5ac28118b55e
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 07:24:19 2025 -0500

    fix(ci): replace sed with jq for JSON construction in changelog generation
    
    * Replaced sed-based template substitution with direct jq JSON construction
    * Fixed 'unknown option to s' error caused by special characters in commit messages
    * Eliminated intermediate template files and multiple sed replacement steps
    * Used jq --arg flags for safe variable passing and automatic JSON escaping
    * Simplified cleanup process by reducing temporary file creation
    
    The previous approach used sed to replace placeholders in JSON templates, which failed
    when commit messages contained forward slashes, quotes, or other characters that sed
    interpreted as command delimiters. The new jq-based approach constructs the complete
    JSON payload directly with proper escaping, eliminating character interpretation issues
    while maintaining the same functionality for OpenAI API calls.
    
    Resolves workflow failures where changelog generation would fail with sed syntax errors
    when processing commit messages containing special characters.

commit 71bd9b9b1e15e1a46b4bc0596ae2fdc31fb70238
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 07:23:22 2025 -0500

    Update release-preparation.yml

commit e52fd21a48e52e7fdd6a0fb68e0156209995a79a
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 07:14:50 2025 -0500

    fix(ci): enhance changelog generation robustness in release preparation workflow
    
    * Added comprehensive error handling for OpenAI API calls with HTTP status code checking
    * Implemented fallback changelog content when OpenAI API fails or returns empty responses
    * Fixed JSON escaping issues that caused malformed requests when commit messages contain special characters
    * Added debug output for JSON payload validation and API response troubleshooting
    * Enhanced logging to provide clear feedback on OpenAI API success/failure states
    * Added graceful handling for missing OPENAI_API_KEY configuration
    
    The previous implementation failed silently when OpenAI API calls encountered errors,
    resulting in 'Failed to generate changelog entry' without diagnostic information.
    This enhancement ensures the release workflow continues successfully even when
    AI services are unavailable, while providing detailed debugging information
    for troubleshooting API issues.
    
    Resolves workflow failures where changelog generation would fail due to JSON
    syntax errors from unescaped commit message content or OpenAI API service issues.

commit d3d5b6a857d4ec103e766db78959779c7d220196
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 07:14:14 2025 -0500

    Update release-preparation.yml

commit 0777358ebd480ed3844a421d5a8ee92a309f2529
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 07:03:03 2025 -0500

    fix(ci): resolve shell interpretation issues in release preparation workflow
    
    * Replaced echo command with heredoc syntax in version bump detection step
    * Updated OpenAI changelog generation to use cat << 'COMMITS_EOF' pattern
    * Prevents bash from interpreting backticks as command substitution in commit messages
    * Resolves 'command not found' errors when commit messages contain markdown code blocks
    * Fixes OpenAI API failures caused by malformed JSON due to shell interpretation
    
    The previous approach used echo with GitHub Actions variable expansion, which caused
    bash to interpret backticks in commit messages as command substitution (e.g.
    and  were executed as shell commands). The new heredoc approach with quoted
    delimiter treats all content as literal text, preventing shell interpretation while
    maintaining the same functionality for version detection and changelog generation.
    
    Resolves workflow failures in release preparation when commit messages contain backticks.

commit 74c8772941a53a2bd97a65c1d950f47be4cf1c3c
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 07:00:50 2025 -0500

    Update release-preparation.yml

commit a2b5e51ae688a907e655a5f792c30a2a29ed6d1b
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 06:40:16 2025 -0500

    fix(ci): repair changelog extraction in release PR workflow
    
    * Fixed broken awk command that failed to extract changelog entries between version headers
    * Improved logic to properly capture content from latest version section in CHANGELOG.md
    * Added fallback handling for empty changelog results with descriptive error messages
    * Enhanced debugging output to show extracted version and changelog preview
    * Resolved issue where release PRs showed 'changelog could not be generated automatically'
    
    The previous awk pattern had incorrect logic flow that prevented proper content extraction
    between the first two ## headers in the changelog format. The new implementation correctly
    identifies version boundaries and captures all content for the latest release entry.

commit 63dc45067ddfe379014fb845e2ea620ed7e002a9
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 06:37:25 2025 -0500

    Update create-release-pr.yml

commit d8a11de9e57c04d378ad796777b51bfdbc8a4642
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 06:11:48 2025 -0500

    Update create-release-pr.yml

commit 83a7ff10b0062ea78e5effa08fd36cdd0c5fac39
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 06:10:01 2025 -0500

    fix(ci): use PAT token for GitHub CLI operations in release PR workflow
    
    * Updated checkout step to use PAT_TOKEN with fallback to GITHUB_TOKEN
    * Modified all GH_TOKEN environment variables to prefer PAT_TOKEN over default token
    * Applied changes to check PR, label creation, PR creation, and PR update steps
    * Maintains backward compatibility with fallback to GITHUB_TOKEN if PAT not configured
    * Prevents 'GitHub Actions is not permitted to create pull requests' permission errors
    
    The default GITHUB_TOKEN has restrictions on creating pull requests in certain
    scenarios due to GitHub security policies. Using a Personal Access Token with
    full repository permissions resolves these limitations while maintaining fallback
    support for repositories that haven't configured the PAT_TOKEN secret.
    
    Resolves GraphQL createPullRequest permission errors in automated release workflow.

commit ac0ffed56378c7f6a505c46ddce0ecc739d304ce
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 05:59:18 2025 -0500

    fix(ci): resolve shell interpretation issues in OpenAI changelog generation
    
    * Replaced direct variable expansion with temporary file approach in changelog generation step
    * Store commit messages in commits_temp.txt to prevent backtick command execution
    * Created JSON template system with placeholders (OPENAI_MODEL_PLACEHOLDER, VERSION_PLACEHOLDER, etc.)
    * Used sed-based replacement to safely substitute values without shell interpretation
    * Added proper cleanup of temporary files (commits_temp.txt, changelog_prompt_*.json)
    * Prevents 'command not found' errors when commit messages contain markdown backticks
    
    The previous approach failed when commit messages contained backticks around code
    identifiers (e.g. `feature`, `bugfix`) because bash interpreted them as command
    substitution within the JSON payload creation. The new file-based template approach
    treats all content as literal text, making the workflow robust against special characters.
    
    Resolves workflow failures during automated changelog entry generation with OpenAI.

commit 471833ab2722717763e8b70508b8f99f12ff4449
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 05:58:38 2025 -0500

    Update release-preparation.yml

commit 38c2126f6378d87390ac0e58b54606303e528bcc
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 05:48:57 2025 -0500

    fix(ci): resolve shell interpretation issues in release preparation workflow
    
    * Replaced direct variable expansion with temporary file approach in version bump detection
    * Store commit messages in commits_temp.txt to prevent backtick command execution
    * Updated grep commands to read from file instead of shell variable expansion
    * Added proper cleanup of temporary file after processing
    * Prevents 'command not found' errors when commit messages contain markdown backticks
    
    The previous approach failed when commit messages contained backticks around code
    identifiers (e.g. `feature`, `bugfix`) because bash interpreted them as command
    substitution within double quotes. The new file-based approach treats all content
    as literal text, making the workflow robust against any special characters.
    
    Resolves workflow failures during automated version bump type determination.

commit f74329ae84a1c33816be0bf134aafa1cf025d650
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 05:47:46 2025 -0500

    Update release-preparation.yml

commit 55c3a33ab6d0ab2088bbf0762677250af2811fce
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 05:41:48 2025 -0500

    fix(ci): resolve shell interpretation issues in release PR workflow
    
    * Replaced direct variable expansion with temporary file approach to prevent backtick command execution
    * Added safe template system using placeholders (VERSION_PLACEHOLDER, CHANGELOG_PLACEHOLDER)
    * Implemented sed-based replacement to avoid shell interpretation of special characters
    * Added proper cleanup of temporary files (changelog_temp.txt, user_prompt_*.txt)
    * Prevents 'command not found' errors when changelog contains markdown backticks
    
    The previous approach failed when changelog entries contained backticks around code
    identifiers (e.g. `feature`, `bugfix`) because bash interpreted them as command
    substitution within double quotes. The new file-based approach treats all content
    as literal text, making the workflow robust against any special characters.
    
    Resolves workflow failures during automated release PR creation.

commit d58633871a4242b92d5134239d6418ca34de57e2
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 05:40:57 2025 -0500

    Update create-release-pr.yml

commit 9b41897fea71de6e589b591cba3500418137c5c5
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 05:22:47 2025 -0500

    fix: added write to contents

commit a026a129314b5cb2b4829b05f6f31e518eee13b9
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 05:21:42 2025 -0500

    Update create-release-pr.yml

commit 9baa4cdc289918d007e89305342aa7f3aeec136b
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 05:16:24 2025 -0500

    Update create-release-pr.yml

commit bb2f2888673169d4f4d7e08c7dea442e10be96e8
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 05:09:36 2025 -0500

    fix(ci): add label creation step to release PR workflow
    
    * Added 'Ensure labels exist' step to check and create missing labels
    * Creates 'release' label (blue, #0052cc) for release-related items
    * Creates 'automated' label (gray, #ededed) for GitHub Actions items
    * Prevents 'label not found' errors when applying labels to PRs
    * Step only runs when creating new PRs, not when updating existing ones
    
    Resolves issue where workflow failed due to missing repository labels.

commit c1baf05a132b8c7976863ff0a670baf209972e2b
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 04:44:50 2025 -0500

    Update create-release-pr.yml

commit 625c2fe931017ed099f6727d7640acd558af75df
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 04:33:34 2025 -0500

    fix(ci): resolve variable expansion in PR description here-document
    
    * Remove quotes from ENHANCED_EOF delimiter to enable variable expansion
    * Fixes literal '' text appearing in PR descriptions
    * Allows proper substitution of enhanced description content into file
    
    This resolves the issue where PR descriptions were showing the literal variable name
    instead of the actual enhanced description content due to quoted here-document delimiter
    preventing bash variable expansion.

commit 89f19caa66f15b177f2b312ef246f58ab359ccc9
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 04:25:45 2025 -0500

    fix(ci): resolve label creation failure in PR template automation
    
    * Replace bulk label addition with individual label processing loop
    * Add automatic label creation with predefined colors and descriptions
    * Implement error handling for label operations to prevent workflow failures
    * Define 8 standard labels: feature, bugfix, documentation, maintenance, breaking-change, needs-review, release, automated
    
    This fixes the 'label not found' error where GitHub CLI failed when trying to add
    non-existent labels to PRs. Now labels are created automatically if missing and
    added individually with proper error handling.

commit 15ac65b56b3f8c1af8031a8425b44f39d614d1df
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 04:13:29 2025 -0500

    fix(ci): resolve shell interpretation error in create-release-pr workflow
    
    * Replace direct variable usage in --body parameter with --body-file approach
    * Write PR description to temporary file using here-document with quoted delimiter
    * Prevents shell from interpreting special characters in multi-line PR descriptions
    * Eliminates 'command not found' errors when description contains words like 'preview' and 'main'
    
    This fixes the workflow failure where GitHub CLI was interpreting markdown content
    as shell commands instead of treating it as PR body text.

commit 3d78351d68f04f5cbc064e3cf5d63cd23263b225
Merge: 9f27d31 ebe0ff6
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 03:59:48 2025 -0500

    Merge pull request #16 from tkozzer/fix/pr-automation
    
    fix(ci): resolve ESLint parsing errors in GitHub workflows

commit ebe0ff64da8982249ddce9d6402c61a0005a6999
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 03:53:51 2025 -0500

    fix(ci): resolve ESLint parsing errors in GitHub workflows
    
    * Fixes regex pattern in unicorn/filename-case rule to properly exclude YAML files using /.*\.ya?ml$/
    * Removes .github/** from global ignores to allow linting of workflow files while excluding them from filename-case rule
    * Resolves YAML syntax formatting issues in create-release-pr.yml including:
      - Fixes workflow reference syntax from quoted to array format
      - Corrects multiline string indentation in USER_PROMPT assignment
      - Standardizes whitespace and removes trailing spaces
    * Updates pr-template-automation.yml with consistent indentation
    
    These changes resolve the ESLint parsing errors that were preventing successful linting runs and ensure GitHub Actions workflows follow proper YAML syntax while maintaining appropriate linting coverage.

commit 9f27d31744fa279a165a91d0496f1203f8e9a11b
Merge: 1c2f8ce d27f996
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 03:14:41 2025 -0500

    Merge pull request #15 from tkozzer/preview
    
    Added 3 branch dev process

commit d27f996766b989f8449c3824c9502d66b94f7ace
Author: GitHub Action <action@github.com>
Date:   Wed Jun 4 08:10:01 2025 +0000

    chore(release): bump version to 0.3.0 and update changelog

commit 025ed1a0fca203c9850d2289ec7e379f1fc32de6
Merge: 4ea3fad 4fea02e
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 03:09:38 2025 -0500

    Merge pull request #14 from tkozzer/feat/automate-pr-creation
    
    feat(ci,docs): implement AI-powered PR automation and enhance develop…

commit 1c2f8cee71954047b4bb98e94631c95a0516a825
Merge: e143096 4fea02e
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 03:02:21 2025 -0500

    Merge pull request #13 from tkozzer/feat/automate-pr-creation
    
    feat(ci,docs): implement AI-powered PR automation and enhance develop…

commit e143096e958a348ae69a3a8232f3217b0077f9cb
Merge: 3f46ed7 4ea3fad
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 02:59:21 2025 -0500

    Merge pull request #12 from tkozzer/preview
    
    Added a release workflow

commit 4fea02e80b9872a2642689a4d4450b6d5a2e92cb
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 02:55:31 2025 -0500

    feat(ci,docs): implement AI-powered PR automation and enhance development workflow
    
    * Added comprehensive three-branch workflow automation with AI integration
    * Created pr-template-automation.yml for AI-enhanced PR descriptions targeting preview branch
    * Created create-release-pr.yml for automated release PR generation from preview to main
    * Enhanced CONTRIBUTING.md with detailed three-branch workflow documentation
    * Added visual branch structure diagram and automation process explanation
    * Updated README.md with accurate project structure and contributing workflow overview
    * Fixed README.md build badge URL to point to correct ci.yml workflow
    * Improved documentation formatting and clarity throughout
    
    Key automation features:
    - AI-powered PR description enhancement using OpenAI
    - Automatic conventional commit analysis and labeling
    - Smart rate limiting and error handling with graceful fallbacks
    - Repository owner auto-assignment for all PRs
    - Comprehensive changelog generation and version bumping
    - Professional release PR creation with AI-generated descriptions
    
    Provides complete development workflow from feature branch to production release
    with human oversight at critical decision points while automating repetitive tasks.
    
    Refs: #automation-workflow

commit 4ea3fad7e38c4df25ab41940df75dbc5b4494de0
Author: GitHub Action <action@github.com>
Date:   Wed Jun 4 06:54:22 2025 +0000

    chore(release): bump version to 0.2.0 and update changelog

commit ecf377154a42302245cd7d856693d0ad879a77eb
Merge: 3f46ed7 9b7fc46
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Wed Jun 4 01:53:51 2025 -0500

    Merge pull request #11 from tkozzer/fix/release-preparation
    
    fix(ci): resolve release workflow permissions and shell escaping issues

commit 9b7fc468d41944472af5ea5247e479522ffd7234
Merge: 0a02922 86b74f0
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 01:51:49 2025 -0500

    feat(ci): update CI workflow triggers and enhance local testing setup
    
    * Updates CI workflow to trigger on pull requests to preview/main branches instead of main/develop
    * Removes push triggers from CI workflow to align with new three-branch workflow strategy
    * Creates .env.act.example template with OpenAI configuration for local workflow testing
    * Removes .env.act from tracking to prevent accidental exposure of API keys
    * Enhances .gitignore patterns for better environment file handling
    * Adds specific OpenAI API key and model configuration examples for local testing
    
    This change supports the new release workflow where:
    - Feature branches → PR to preview (triggers CI + release prep)
    - Preview branch → PR to main (triggers CI + GitHub release)
    - CI now focuses on validation rather than triggering on every push
    
    The .env.act.example provides a template for developers who want to test
    GitHub workflows locally using nektos/act, with proper OpenAI integration
    for changelog generation testing.

commit 0a0292227b0c2103ddf57488d6b272293f0013b2
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 01:42:14 2025 -0500

    fix(ci): resolve release workflow permissions and shell escaping issues
    
    * Adds contents:write permission to enable GitHub Actions bot to push version updates
    * Adds persist-credentials:true to checkout step for proper authentication
    * Fixes shell escaping in changelog update using heredoc to prevent command interpretation
    * Improves version bump detection precision to avoid false positive breaking change detection
    * Updates breaking change regex to match only at line start (^|[\n])BREAKING CHANGE:
    * Restricts feature detection to commit subject lines using hash prefix pattern
    
    Resolves three critical issues from initial workflow run:
    1. 403 permission denied when pushing version bump commits
    2. Shell interpretation errors when changelog contained backticks or special chars
    3. Incorrect major version bump (1.0.0) due to 'BREAKING CHANGE' text in commit descriptions
    
    The workflow now properly detects minor bumps for feat: commits and safely handles
    changelog content without shell command execution. Authentication is configured
    to allow the release preparation workflow to commit and push changes back to preview branch.

commit 86b74f084935a339adf670808f3144238e3d4305
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Wed Jun 4 01:27:55 2025 -0500

    feat(ci): implement comprehensive GitHub release workflow system
    
    * Adds release-preparation.yml workflow for automated version bumping and changelog generation
    * Updates CI workflow triggers to target preview/main branches instead of main/develop
    * Integrates OpenAI GPT for intelligent changelog generation following Keep a Changelog standards
    * Implements semantic version detection from conventional commit messages (feat/fix/BREAKING CHANGE)
    * Adds automated package.json version bumping and CHANGELOG.md updates
    * Creates .env.act.example template for local workflow testing with nektos/act
    * Removes .env.act from tracking to prevent API key exposure
    * Updates .gitignore patterns to properly handle environment files
    
    The workflow triggers on push to preview branch, analyzes commit history since last release,
    determines appropriate version bump type, generates human-readable changelog entries via OpenAI,
    and commits the updates back to the preview branch. This enables the three-branch workflow:
    feature → preview (auto-release) → main (GitHub release + npm publish).
    
    Local testing capability preserved through Act integration with proper environment isolation.

commit 3f46ed78869b528342771d52b6fec3a8673eefad
Merge: 096793b 9799de6
Author: Tyler Kozlowski <51497123+tkozzer@users.noreply.github.com>
Date:   Tue Jun 3 23:20:47 2025 -0500

    Merge pull request #9 from tkozzer/build/optimized-build
    
    feat(ci): add comprehensive local CI testing with Act integration

commit 9799de6a238ee1cac4a0bd7c4045eaab6fe90fbd
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Tue Jun 3 23:17:22 2025 -0500

    fix(build): replace jiti with tsx for cross-platform TypeScript execution
    
    * Updated all build scripts to use tsx for executing rollup with TypeScript config
    * Replaced jiti dependency with tsx (^4.19.4) for more reliable TS execution
    * Modified build, build:minified, build:umd, and build:umd:minified scripts
    * Updated pnpm-lock.yaml to reflect tsx dependency changes and jiti removal
    
    This resolves Node.js TypeScript extension loading issues across different
    CI environments while maintaining full TypeScript support for build configs.
    The tsx runner provides better cross-platform compatibility compared to jiti.

commit b672ff618b300ff3efb1908c49050c3c9d933215
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Tue Jun 3 23:07:50 2025 -0500

    fix(logger): improve cross-platform stack trace parsing and test flexibility
    
    * Enhanced regex patterns to handle Windows backslash paths and various stack trace formats
    * Added support for .js/.ts file detection in stack traces across different environments
    * Made logger tests more flexible to gracefully handle platform-specific location detection
    * Updated tests to conditionally validate location format only when detection succeeds
    * Fixed path separator handling to work with both Unix forward slashes and Windows backslashes
    
    This resolves logger test failures on Windows GitHub Actions runners where stack trace
    formats differ from Unix systems. The logger now gracefully degrades to no location
    information when stack trace parsing fails, ensuring consistent behavior across platforms
    while maintaining full functionality when location detection works properly.

commit 6537e94573eb5075fdfe1768af13b4fb79785eba
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Tue Jun 3 23:02:39 2025 -0500

    fix(ci): resolve Windows PowerShell glob pattern issues in test commands
    
    * Changed from shell glob patterns to vitest directory paths for cross-platform compatibility
    * Updated test commands: 'src/**/*.test.ts' → 'src/' and 'tests/**/*.test.ts' → 'tests/'
    * Removed deprecated --reporter=basic flag from vitest commands
    * Applied fixes to both production CI (ci.yml) and local CI (ci-local.yml) workflows
    
    This resolves the 'No test files found' error on Windows GitHub Actions runners
    where PowerShell doesn't expand glob patterns the same way as Unix shells.
    Now vitest handles file matching natively using its include configuration,
    ensuring reliable cross-platform test execution while maintaining the smart
    test separation strategy (source tests vs build verification tests).

commit 23f06edd39ecb6ef2b693c0cb7d4dead1d8a2143
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Tue Jun 3 22:57:21 2025 -0500

    ci(workflows): prevent GitHub auto-execution of ci-local.yml
    
    * Changed triggers from push/PR/schedule to manual workflow_dispatch only
    * Added prominent warnings in workflow header about local-only usage
    * Updated concurrency configuration for manual-only execution
    * Enhanced README documentation with local-only execution feature note
    * Removed duplicate ciLocal.yml file to clean up workflow directory
    
    This ensures the local CI workflow (designed for Act testing) only runs
    manually via workflow_dispatch, preventing accidental GitHub Actions
    consumption while maintaining full Act compatibility for local development.
    
    The workflow now serves its intended purpose as a local development tool
    without interfering with production CI/CD pipeline automation.

commit de3513880e370d20ac2089909fa05c615f881061
Author: Tyler Kozlowski <Tyler.J.Kozlowski@gmail.com>
Date:   Tue Jun 3 22:53:12 2025 -0500

    feat(ci): add comprehensive local CI testing with Act integration
    
    * Adds ci-local.yml workflow optimized for nektos/act with production mirroring
    * Implements cross-platform simulation for Windows, macOS, and multiple Ubuntu versions
    * Enhances production CI pipeline with smart test execution strategy
    * Separates source tests from build verification tests for better developer experience
    * Updates documentation with local CI testing guidance and Act installation instructions
    * Fixes ESLint configuration regex pattern validation error
    * Bumps version to 0.1.9 for enhanced CI/CD infrastructure
    
    Infrastructure improvements:
    - Added .actrc configuration for optimal container settings
    - Added .env.act environment template for secure local testing
    - Updated .gitignore with Act-specific file patterns
    - Enhanced cross-platform matrix testing across Node.js 18.x, 20.x, 22.x
    - Improved CI reporting with detailed execution breakdown and platform coverage
    
    The local CI workflow provides 95%+ identical validation to production while
    enabling comprehensive local testing without consuming GitHub Actions minutes.
    Maintains all existing CI quality with significantly improved developer experience. instead of piping to .
  - Improved logging and debugging output throughout the release workflow for clearer diagnostics.
- Fixed changelog extraction logic in the release PR workflow to correctly capture the latest version section, preventing empty or incomplete changelog entries in release pull requests.
- Updated release PR workflow to use a Personal Access Token (PAT) with fallback to the default GitHub token, resolving permission errors when creating pull requests and labels.
- Added steps to ensure required labels (, ) exist before applying them in release PRs, preventing label-not-found errors.
- Corrected variable expansion in PR description templates to enable proper substitution and avoid literal placeholder text appearing in pull request descriptions.

### Changed
- Streamlined environment variable usage and naming conventions in CI workflows for better readability and consistency.
- Enhanced visual clarity in workflow logs using Unicode arrows and standardized error messages.
- Optimized file operations and cleanup in release workflows to reduce temporary file clutter and improve maintainability.

---

## [0.3.0] - 2025-06-04

### Added
- Introduced a comprehensive three-branch development workflow automating pull request creation and release management.
- Added AI-powered PR description enhancement using OpenAI to generate clearer, more informative pull requests.
- Implemented automatic conventional commit analysis and labeling to streamline changelog generation and version bumping.
- Created `pr-template-automation.yml` to automate PR descriptions targeting the `preview` branch.
- Created `create-release-pr.yml` for automated release PR generation from `preview` to `main`.
- Added repository owner auto-assignment for all pull requests to improve review efficiency.
- Provided `.env.act.example` template for local testing of GitHub workflows with OpenAI integration.
- Enhanced documentation with a visual branch structure diagram and detailed explanation of the new three-branch workflow in `CONTRIBUTING.md`.
- Updated `README.md` to reflect the new project structure and contributing workflow.

### Changed
- Updated CI workflow triggers to run on pull requests targeting `preview` and `main` branches instead of `main` and `develop`.
- Removed push triggers from CI workflows to focus on validation during PRs, aligning with the new branching strategy.
- Improved environment file handling by adding `.env.act` to `.gitignore` and providing configuration examples for OpenAI API keys.
- Fixed README build badge URL to correctly point to the CI workflow.
- Improved documentation formatting and clarity throughout the project.

### Fixed
- Resolved GitHub Actions permissions issues by adding `contents:write` permission and enabling `persist-credentials` for proper authentication during release workflows.
- Fixed shell escaping issues in changelog update commands to prevent command interpretation errors during CI runs.

---

## [0.2.0] - 2025-06-04

### Added
- Introduced a comprehensive GitHub release workflow system that automates version bumping and changelog generation using OpenAI GPT.
- Added a new release-preparation workflow triggered on pushes to the `preview` branch, enabling automated semantic version detection and changelog updates based on conventional commit messages.
- Created a `.env.act.example` template to facilitate local testing of GitHub workflows with proper OpenAI API integration.
  
### Changed
- Updated CI workflow triggers to run on pull requests targeting `preview` and `main` branches instead of `main` and `develop`, aligning with the new three-branch workflow strategy.
- Removed CI triggers on push events to focus validation on pull requests, improving workflow efficiency.
- Enhanced `.gitignore` patterns and removed `.env.act` from version control to prevent accidental exposure of sensitive API keys.
- Improved version bump detection logic to avoid false positives, ensuring accurate semantic versioning based on commit messages.
- Refined changelog update process to safely handle special characters and prevent shell command interpretation errors.
- Configured workflow permissions and authentication to allow automated commits and pushes of version and changelog updates by GitHub Actions.

### Fixed
- Resolved permission issues causing 403 errors when the GitHub Actions bot attempted to push version bump commits.
- Fixed shell escaping problems in changelog updates that previously caused errors with special characters like backticks.
- Corrected version bump detection to prevent incorrect major version increments triggered by "BREAKING CHANGE" text in commit bodies rather than commit headers.

---

## [0.1.9] - 2025-06-03

### Added

- **Local CI testing infrastructure**: Complete Act-based local CI testing system for GitHub Actions:
  - `ci-local.yml` workflow optimized for nektos/act with production CI mirroring
  - Cross-platform simulation supporting Windows, macOS, and multiple Ubuntu versions
  - Enhanced platform-specific validation steps for comprehensive local testing
  - `.actrc` configuration file with optimized container settings for local development
  - `.env.act` environment template for secure local testing setup
- **Act integration documentation**: Comprehensive local CI testing guidance:
  - Installation and usage instructions for Act GitHub Actions runner
  - Local workflow testing commands with dry-run options
  - Platform simulation features and cross-platform testing capabilities
  - Act-specific optimizations and GitHub Actions compatibility notes

### Enhanced

- **Production CI pipeline**: Major improvements to GitHub Actions workflow architecture:
  - **Smart test execution strategy**: Separated source tests from build verification tests
  - **Enhanced matrix testing**: Cross-platform testing across Node.js 18.x, 20.x, 22.x on Ubuntu, Windows, macOS
  - **Improved reporting**: Detailed CI summaries with test execution breakdown and platform coverage
  - **Better error handling**: Clear separation prevents confusing failures when build artifacts don't exist
  - **Performance optimization**: Faster feedback with logical test separation and parallel execution
- **Development workflow**: Significantly improved local development experience:
  - **Local CI mirroring**: 95%+ identical local and production CI validation
  - **Platform simulation**: Windows and macOS testing simulation on local Docker containers
  - **Enhanced debugging**: Comprehensive local testing without consuming GitHub Actions minutes
  - **Container optimization**: Multiple Ubuntu versions and container images for thorough testing
- **Project infrastructure**: Enhanced development tooling and configuration:
  - Updated `.gitignore` with Act-specific file patterns and artifact handling
  - Enhanced ESLint configuration with proper regex escaping for filename validation
  - Improved documentation highlighting CI/CD capabilities and local testing features

### Changed

- **CI architecture**: Moved from basic single-job CI to comprehensive multi-job pipeline with:
  - `quick-checks` job for fast developer feedback (source tests only)
  - `test-matrix` job for cross-platform validation (Node versions + OS combinations)
  - `coverage` job for quality metrics and reporting
  - `build-verification` job for package validation (build tests only)
  - `ci-success` job for final validation gate with enhanced reporting
- **Test execution strategy**: Intelligent test separation for optimal developer experience:
  - Source tests (`src/**/*.test.ts`) run in quick-checks and matrix jobs
  - Build verification tests (`tests/**/*.test.ts`) only run after successful build
  - Total test coverage maintained (534 tests) with better execution timing
- **Version**: Bumped to 0.1.9 for enhanced CI/CD infrastructure and local testing capabilities

### Fixed

- **ESLint configuration**: Resolved regex pattern validation error in filename-case rule
- **Dependency installation**: Enhanced lockfile handling for both strict production and flexible local development
- **Test reliability**: Eliminated confusing test failures by running build tests only when artifacts exist
- **Documentation accuracy**: Updated all CI-related documentation to reflect enhanced capabilities

### Infrastructure

- **Local development**: Act integration provides comprehensive local CI testing equivalent to production
- **Cross-platform coverage**: Enhanced testing across 7 environment combinations locally and in production
- **Developer experience**: Significantly reduced feedback cycle for CI changes with local validation
- **Production reliability**: Maintained all existing CI quality while adding comprehensive local testing capabilities

---

## [0.1.8] - 2025-06-03

### Added

- **Enhanced client architecture**: Major improvements to the SetlistFM client implementation:
  - Type-safe interface definition with comprehensive method signatures and JSDoc documentation
  - Factory pattern implementation for creating configured client instances
  - Endpoint delegation system connecting client methods to individual endpoint functions
  - Integration layer between high-level client interface and low-level endpoint implementations
- **Examples automation system**: Complete automation infrastructure for running all examples:
  - `examples/run-all-examples.sh` script for executing all endpoint examples with proper environment setup
  - `examples/README.md` with comprehensive documentation for the examples system and automation
  - Unified examples execution with rate limiting awareness and error handling
- **Enhanced client testing**: Expanded test coverage for client functionality:
  - Factory pattern validation and configuration testing
  - Client interface method delegation verification
  - Integration testing between client methods and endpoint functions

### Enhanced

- **Documentation improvements**: Major updates to project documentation:
  - Updated main `README.md` with Quick Start section, enhanced usage examples, and comprehensive features list
  - Enhanced examples README files across all endpoints with consistent formatting and better code examples
  - Improved client usage documentation with factory pattern examples and configuration options
- **Code organization**: Improved separation of concerns and maintainability:
  - Clear distinction between client interface, implementation, and endpoint delegation
  - Enhanced type safety across all client methods with proper TypeScript interface definitions
  - Standardized error handling and response patterns across all endpoint integrations
- **Examples consistency**: Standardized example code across all endpoints:
  - Consistent client instantiation patterns using factory methods
  - Unified error handling and logging approaches
  - Improved code readability and documentation across all example files

### Changed

- **Version**: Bumped to 0.1.8 for enhanced client architecture and examples automation
- **Client initialization**: Updated from direct constructor usage to factory pattern for better configuration management
- **Examples structure**: Enhanced organization with centralized automation and documentation
- **Development workflow**: Improved development experience with comprehensive examples system and better client interface

### Fixed

- **Client interface consistency**: Resolved inconsistencies in client method signatures and return types
- **Examples execution**: Fixed path resolution and environment setup issues in example scripts
- **Documentation accuracy**: Updated all documentation to reflect current implementation patterns and best practices

---

## [0.1.7] - 2025-06-03

### Added

- **Setlists endpoints**: Complete implementation of both setlists endpoints with comprehensive functionality:
  - `getSetlist()` - Retrieve setlist details by setlist ID with full artist, venue, and song information
  - `searchSetlists()` - Search setlists by artist, venue, city, date, year, and other criteria with pagination
- **Setlists examples directory**: Four comprehensive example files demonstrating real-world usage:
  - `basicSetlistLookup.ts` - Basic setlist retrieval and search with Beatles example data
  - `searchSetlists.ts` - Advanced search functionality with filtering, pagination, and Beatles historical data
  - `completeExample.ts` - Comprehensive setlist analysis with Radiohead tour data and statistical insights
  - `advancedAnalysis.ts` - Complex multi-year setlist analytics with rate limiting and detailed performance metrics
- **Enhanced data validation**: Robust setlist and version ID validation with flexible format support for real API data
- **Comprehensive testing**: 69 unit tests covering all setlists functionality, validation, error handling, and edge cases
- **Real-world API integration**: Examples handle actual setlist.fm API responses including sets structure and song metadata
- **100% test coverage**: Achieved complete test coverage across all implemented endpoints with 515+ tests

### Enhanced

- **API structure compatibility**: Updated validation to match actual setlist.fm API response format with `sets: { set: [...] }` structure
- **Documentation**: Updated main README.md with setlists examples, usage patterns, and complete endpoint coverage tracking
- **API coverage**: Completed setlists endpoints implementation (2/2) bringing total coverage to 11/12 implemented endpoints
- **Type safety**: Complete TypeScript types for setlists data, songs, sets, tours, and validation schemas
- **Error handling**: Comprehensive error handling patterns for setlists endpoints with proper validation feedback
- **Index exports**: Enhanced main endpoints export with conflict resolution for shared types across modules

### Changed

- **Version**: Bumped to 0.1.7 for setlists endpoints implementation
- **Project status**: Updated to reflect setlists endpoints as fully implemented alongside artists, cities, countries, and venues
- **Examples structure**: Added setlists examples following established patterns with comprehensive real-world scenarios
- **Validation schemas**: Updated setlist ID validation to support 7-8 character format and version ID validation for deprecated fields

### Removed

- **Deprecated endpoint**: Removed `getSetlistVersion` endpoint as it is deprecated by setlist.fm API
- **Unused validation**: Cleaned up obsolete validation schemas and test data for deprecated functionality

### Fixed

- **API response structure**: Fixed setlists data structure to match actual API format with proper sets nesting
- **Validation edge cases**: Resolved test failures for setlist ID and version ID validation with realistic data constraints
- **Test coverage gaps**: Added comprehensive endpoint exports testing to achieve 100% coverage milestone
- **Documentation consistency**: Updated all endpoint README files to remove eslint-disable directives and maintain consistent examples

---

## [0.1.6] - 2025-06-03

### Enhanced

- **Development configuration**: Comprehensive enhancement of TypeScript and ESLint configurations to support examples directory:
  - Updated `tsconfig.json` to include examples directory with proper path mappings for full IDE support
  - Created separate `tsconfig.build.json` for production builds that excludes examples from distribution
  - Enhanced `eslint.config.ts` with examples-specific rules allowing console.log and process.env usage
  - Updated package.json scripts to lint and type-check both src and examples directories
- **Examples directory support**: Full TypeScript and ESLint integration for all example files:
  - Fixed TypeScript parameter type errors in venue examples
  - Automatic lint fixing to remove unused eslint-disable directives
  - Complete IDE support with proper import resolution and type checking
- **Documentation improvements**: Major README.md updates highlighting enhanced development experience:
  - Added comprehensive Rate Limiting section with STANDARD/PREMIUM profile documentation
  - Enhanced examples section emphasizing TypeScript support and rate limiting monitoring
  - Restructured Development Tools section with separate guidance for type-checking, linting, and building
  - Updated usage examples to highlight automatic rate limiting features

### Changed

- **Build process**: Separated development and production configurations for optimal developer experience
- **Linting rules**: Examples directory now has relaxed rules appropriate for demonstration code
- **Version**: Bumped to 0.1.6 for development configuration enhancements

### Fixed

- **TypeScript compilation**: Resolved parameter type issues in examples/venues/getVenueSetlists.ts
- **Configuration consistency**: Unified approach to handling both library code and examples with appropriate tooling

---

## [0.1.5] - 2025-06-03

### Added

- **Venues endpoints**: Complete implementation of all three venues endpoints with comprehensive functionality:
  - `getVenue()` - Retrieve venue details by venue ID with full geographic and contact information
  - `getVenueSetlists()` - Get paginated setlists for a specific venue with artist and date metadata
  - `searchVenues()` - Search venues by name, city, country, state, and state code with advanced filtering
- **Venues examples directory**: Four comprehensive example files demonstrating real-world usage:
  - `basicVenueLookup.ts` - Basic venue search and lookup workflow with famous venues (MSG, Wembley, Red Rocks)
  - `searchVenues.ts` - Advanced search functionality with 8 different scenarios and geographic filtering
  - `getVenueSetlists.ts` - Venue setlist analysis with multi-page data collection and artist statistics
  - `completeExample.ts` - Comprehensive 4-phase workflow with city discovery and statistical insights
- **Enhanced data validation**: Robust venue ID validation using 8-character hexadecimal format with regex filtering
- **Comprehensive testing**: 52 unit tests covering all venues functionality, validation, error handling, and edge cases
- **Real-world data handling**: Examples handle API data quality issues including invalid venue IDs and empty venue names
- **Rate limiting integration**: Removed manual delays in favor of built-in SDK rate limiting capabilities

### Enhanced

- **Documentation**: Updated main README.md with venues examples, usage patterns, and complete API coverage tracking
- **API coverage**: Increased completion from 6/18 to 9/18 endpoints (50% API coverage)
- **Type safety**: Complete TypeScript types for venues data, responses, and validation schemas with proper geographic data types
- **Error handling**: Comprehensive error handling patterns for venues endpoint edge cases and data quality issues
- **Performance optimization**: Efficient venue data processing with filtering for valid records and rate limiting respect

### Changed

- **Version**: Bumped to 0.1.5 for venues endpoints implementation
- **Project status**: Updated to reflect venues endpoints as fully implemented and tested alongside artists, cities, and countries
- **Examples structure**: Added venues examples following established patterns with enhanced real-world data handling
- **Main exports**: Enhanced src/endpoints/index.ts to include all venues endpoints for easy importing

### Fixed

- **Rate limiting**: Replaced manual delay() functions with proper SDK rate limiting configuration support
- **Data validation**: Added venue ID format validation to handle real setlist.fm API data inconsistencies
- **Example reliability**: Enhanced examples to gracefully handle invalid venue data and API rate limits

---

## [0.1.4] - 2025-06-03

### Added

- **Countries endpoint**: Complete implementation of the countries endpoint with comprehensive functionality:
  - `searchCountries()` - Retrieve complete list of all supported countries from setlist.fm API
- **Countries examples directory**: Three comprehensive example files demonstrating real-world usage:
  - `basicCountriesLookup.ts` - Countries retrieval and data exploration with regional groupings
  - `countriesAnalysis.ts` - Advanced analysis with cities integration and statistical insights
  - `completeExample.ts` - Production-ready workflow with data validation and performance testing
- **Enhanced validation**: ISO 3166-1 alpha-2 country code validation with strict schema enforcement
- **Comprehensive testing**: 40 unit tests covering all countries functionality, validation, error handling, and edge cases
- **Cross-endpoint integration**: Examples demonstrate integration with cities endpoint for geographic analysis
- **Performance optimization**: Caching strategies and efficiency recommendations for country data usage

### Enhanced

- **Documentation**: Updated main README.md with countries examples, usage patterns, and progress tracking
- **API coverage**: Increased completion from 5/18 to 6/18 endpoints (33% API coverage)
- **Type safety**: Complete TypeScript types for countries data, responses, and validation schemas
- **Error handling**: Comprehensive error handling patterns for countries endpoint edge cases

### Changed

- **Version**: Bumped to 0.1.4 for countries endpoint implementation
- **Project status**: Updated to reflect countries endpoint as fully implemented and tested
- **Examples structure**: Added countries examples following established patterns from artists and cities

---

## [0.1.3] - 2025-06-03

### Added

- **Cities endpoints**: Complete implementation of both cities endpoints with comprehensive functionality:
  - `getCityByGeoId()` - Retrieve city details by GeoNames geographical ID
  - `searchCities()` - Search cities by name, country, state, and state code with pagination support
- **Cities examples directory**: Three comprehensive example files demonstrating real-world usage:
  - `basicCityLookup.ts` - City search and lookup workflow with fallback strategies
  - `searchCities.ts` - Geographic search using ISO country codes and pagination navigation
  - `completeExample.ts` - Advanced geographic data analysis with statistics and coordinate processing
- **Enhanced validation**: ISO 3166-1 alpha-2 country code validation for improved API compatibility
- **Comprehensive testing**: 52 unit tests covering all cities endpoints, validation, error handling, and edge cases
- **Geographic data analysis**: Examples demonstrate working with real setlist.fm database containing:
  - 184 Paris cities worldwide
  - 5064+ cities in Germany
  - 3329+ cities in UK
  - 10000+ cities in US across 200+ pages

### Enhanced

- **Validation schemas**: Improved `CountryCodeSchema` with strict 2-letter uppercase format validation
- **Error handling**: Comprehensive error handling for geographic data edge cases and API limitations
- **Documentation**: Updated README.md with cities examples, usage patterns, and progress tracking
- **Type safety**: Enhanced TypeScript types for geographic coordinates, country codes, and pagination

### Changed

- **Project status**: Updated API coverage from 3/18 to 5/18 completed endpoints
- **README examples**: Added cities usage examples with proper ISO country code format
- **Feature list**: Added ISO standard validation and comprehensive examples documentation

---

## [0.1.2] - 2025-06-02

### Fixed

- **API Base URL**: Corrected setlist.fm API base URL from `https://api.setlist.fm/1.0` to `https://api.setlist.fm/rest/1.0` to match the actual API endpoint structure
- **Parameter passing bug**: Fixed artist endpoints incorrectly wrapping parameters in `{ params: }` object when calling HTTP client
- **Test assertions**: Updated HTTP client test to expect the corrected base URL

### Added

- **Working artist endpoints**: All three artist endpoints are now fully functional with real API integration:
  - `getArtist()` - Retrieve artist details by MusicBrainz ID
  - `searchArtists()` - Search for artists with various criteria  
  - `getArtistSetlists()` - Get setlists for a specific artist
- **Enhanced examples**: Updated `basicArtistLookup.ts` example to demonstrate both search and direct lookup functionality
- **Comprehensive validation**: Zod schema validation for all artist endpoint parameters and responses

### Changed

- Updated documentation to reflect correct API URL structure in setlist.fm API docs
- Enhanced README.md usage examples with working code snippets
- Updated project status to show artist endpoints as completed (3/18 endpoints done)

---

## [0.1.1] - 2025-06-02

### Added

- **Core client implementation**: Complete SetlistFM client with configuration options for API key, user agent, timeout, language, and rate limiting
- **HTTP client utilities**: Robust HTTP client with authentication, error handling, response interceptors, and rate limiting support
- **Comprehensive error handling**: Custom error classes for different API scenarios (authentication, not found, rate limiting, validation, server errors)
- **Type definitions**: Core TypeScript types for pagination, responses, and client configuration
- **Pagination utilities**: Helper functions for extracting pagination info, navigating pages, and validating parameters
- **Metadata utilities**: Functions for creating response metadata and library information
- **Rate limiting system**: Configurable rate limiter with different profiles (conservative, balanced, aggressive) and status tracking
- **Logging utilities**: Comprehensive logging system with configurable levels, timestamps, and location tracking
- **Test coverage reporting**: Added Vitest coverage configuration with V8 provider and comprehensive reporting

### Changed

- Updated project status in README to reflect completed core infrastructure
- Enhanced feature list to show implemented functionality
- Updated TypeScript configuration to include all test files
- Added test coverage script and configuration

---

## [0.1.0] - 2025-06-02

### Added

- Initial project scaffold for `setlistfm-ts`, a fully typed SDK for the [setlist.fm](https://www.setlist.fm/) API
- Structured directory layout by API domain:
  - `artists/`, `venues/`, `setlists/`, `users/`, `cities/`, `countries/`
- Endpoint-specific modules:
  - Stub functions and type definitions co-located with endpoint logic
  - Per-folder `README.md` documentation for clarity and onboarding
- Testing infrastructure:
  - Configured `vitest` with support for coverage reporting, module aliasing, and watch mode
- Linting and formatting:
  - ESLint with `@antfu/eslint-config` for modern TypeScript style rules and import sorting
  - Preconfigured `pnpm` scripts for `lint`, `lint:fix`, and `type-check`
- TypeScript configuration:
  - Strict mode, declaration outputs, ESM module resolution, and path aliasing
- Contribution support:
  - `CONTRIBUTING.md` including standards for commits, documentation, testing, and PR flow
  - `.cursor/rules` for enforced documentation and commit conventions
- GitHub Actions workflow for linting, type-checking, and test runs
- Project metadata and licensing:
  - MIT license, keywords, `README.md`, and repository metadata for npm visibility


---

