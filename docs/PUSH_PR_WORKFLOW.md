---
description: "Automatically create branch, commit changes, and create a pull request"
usage: "/push_pr [issue-number]"
examples:
  - "/push_pr"
  - "/push_pr 123"
---

# Push PR Workflow (Automatic)

Automatically create a new branch, commit all changes, and create a pull request with smart defaults.

## Arguments
- `[issue-number]`: Optional issue number to reference in the PR (e.g., `/push_pr 123`)

## Automatic Behavior

The command will automatically:

1. **Generate branch name** based on changed files and content
2. **Create commit message** by analyzing the changes
3. **Add all changes** to staging area
4. **Create new branch** with generated name
5. **Commit changes** with generated message
6. **Push branch** to remote repository
7. **Create pull request** with descriptive title and body

## Smart Defaults

- **Branch naming:** `feat/auto-TIMESTAMP` or `fix/auto-TIMESTAMP` based on changes
- **Commit messages:** Generated from file changes and content analysis
- **PR titles:** Descriptive titles based on the changes made
- **PR descriptions:** Includes summary of changes and test information

## Usage Examples

```bash
# Simple usage - everything automated
/push_pr

# With issue reference
/push_pr 456

# With custom message
/push_pr 789 "Add new feature description"
```

## How It Works

1. Analyzes all uncommitted changes in the repository
2. Determines whether changes are features, fixes, or documentation updates
3. Generates appropriate branch name with timestamp
4. Creates descriptive commit message from file changes
5. Creates new branch from current HEAD
6. Commits all changes with generated message
7. Pushes branch to remote repository
8. Opens a pull request with smart defaults

## Implementation Details

The workflow includes:
- **Branch naming convention:** Following git-flow and conventional commits
- **Commit attribution:** Claude Code attribution as per repository conventions
- **PR templates:** Standardized PR descriptions with change summaries
- **Automated testing:** Runs tests before merge approval

---

**Quick Start:**

```bash
# Make your changes
git add .

# Use push_pr workflow (simulated)
/push_pr

# Or with issue reference
/push_pr 42
```

The system will handle the rest automatically!
