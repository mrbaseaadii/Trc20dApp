# Contributing to TRON Ecosystem DApp

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Development Workflow

### 1. Fork and Clone
```bash
git clone https://github.com/mrbaseaadii/Trc20dApp.git
cd Trc20dApp
```

### 2. Create a Feature Branch
```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Make Your Changes
- Keep commits atomic and well-described
- Follow the code style of the project
- Add tests for new features
- Update documentation as needed

### 4. Push PR Workflow
Use the automated Push PR workflow:
```bash
/push_pr [issue-number]
```

Or manually:
```bash
git add .
git commit -m "feat: description of changes"
git push origin feat/your-feature-name
```

### 5. Create Pull Request
- Reference related issues
- Provide clear description of changes
- Include test results
- Wait for review and CI checks

## Code Style

### Solidity
- Use Solidity 0.8.23 or higher
- Follow OpenZeppelin standards
- Include natspec documentation
- Use `pragma solidity ^0.8.0;`

### TypeScript/JavaScript
- Use TypeScript for type safety
- Follow ESLint configuration
- Use prettier for formatting
- Write JSDoc comments

### Commit Messages
Follow conventional commits:
```
feat: add new feature
fix: fix a bug
docs: documentation changes
test: add or update tests
refactor: code refactoring
perf: performance improvements
chore: build, dependencies, etc.
```

## Pull Request Guidelines

### PR Title
- Clear and descriptive
- Reference issue number: `Fix: #123`
- Use conventional commit format

### PR Description
```markdown
## Description
Brief description of changes

## Related Issues
Closes #123

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
How to test these changes

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Code follows style guide
```

## Testing Requirements

### Unit Tests
```bash
npm run test
```

### Smart Contract Tests
```bash
npm run test:contracts
```

### Coverage
```bash
npm run test:coverage
```

## Documentation

- Update README.md for user-facing changes
- Add comments for complex logic
- Include examples for new features
- Update docs/ folder for detailed documentation

## Code Review Process

1. Automated checks (linting, tests)
2. Peer review by maintainers
3. Address feedback and requests
4. Approval and merge

## Reporting Issues

### Bug Reports
Include:
- Clear title
- Detailed description
- Steps to reproduce
- Expected vs actual behavior
- Environment details

### Feature Requests
Include:
- Clear title
- Use case and motivation
- Proposed solution
- Alternatives considered

## Development Setup

### Prerequisites
- Node.js 16+
- npm or yarn
- Git

### Installation
```bash
npm install
npm run compile
npm run test
```

### Local Development
```bash
# Start local node
npm run node:start

# Deploy to local node
npm run deploy:local

# Run development server
npm run dev
```

## Questions?

Feel free to:
- Open a discussion
- Comment on related issues
- Reach out to maintainers

Let's build amazing things on TRON together! 🚀
