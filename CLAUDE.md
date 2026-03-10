# CLAUDE.md

This file provides guidance to AI assistants (including Claude) working in this repository.

## Repository Overview

**Project:** claude
**Status:** Early-stage project — conventions defined here should be followed as the codebase grows.

## Project Structure

```
/
├── README.md        # Project overview
├── CLAUDE.md        # AI assistant guidance (this file)
└── .git/            # Git repository
```

Update this section as directories and files are added.

## Development Workflow

### Branching

- **Main branch:** `main`
- Feature branches: `feature/<description>` or `claude/<description>`
- Bug fix branches: `fix/<description>`
- Always branch from `main` and open a PR to merge back

### Commits

- Write clear, concise commit messages in imperative mood (e.g., "Add user auth endpoint")
- Keep commits focused — one logical change per commit
- Do not amend published commits; create new commits instead

### Pull Requests

- Keep PRs small and focused on a single concern
- Include a summary of what changed and why
- Ensure all checks pass before requesting review

## Code Conventions

### General

- Prefer clarity over cleverness
- Keep functions short and single-purpose
- Avoid unnecessary abstractions — don't over-engineer
- Only add comments where the logic isn't self-evident
- No hardcoded secrets or credentials in source code

### File Organization

- Group related files together in directories
- Use consistent naming conventions (choose one and stick with it):
  - Files: `kebab-case` or `snake_case` depending on language norms
  - Directories: `kebab-case`

## Testing

- Write tests for new functionality
- Run the full test suite before pushing
- Tests live alongside source code or in a dedicated `tests/` directory

## CI/CD

No CI/CD pipelines configured yet. When added:
- All PRs should pass lint, format, and test checks
- Document pipeline steps in this section

## Security

- Never commit secrets, API keys, or credentials
- Use environment variables or secret managers for sensitive values
- Add `.env` and credential files to `.gitignore`
- Validate all external inputs at system boundaries

## Getting Started

```bash
git clone <repo-url>
cd claude
```

Additional setup instructions should be added here as dependencies and tooling are introduced.
