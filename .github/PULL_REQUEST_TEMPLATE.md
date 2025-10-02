## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🎨 Style/UI change (formatting, styling, design)
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] ⚡ Performance improvement
- [ ] ✅ Test addition or update
- [ ] 🔧 Configuration change
- [ ] 🚀 Deployment/infrastructure change

## Related Issue

<!-- Link to the issue this PR addresses (if applicable) -->

Fixes #(issue number)
Relates to #(issue number)

## Changes Made

<!-- List the main changes made in this PR -->

-
-
-

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## Testing Checklist

<!-- Mark completed items with an "x" -->

- [ ] Code follows the project's coding conventions (PEP 8 for Python, ESLint for TypeScript)
- [ ] Code has been formatted with Black (Python) and Prettier/ESLint (TypeScript)
- [ ] Self-review of code completed
- [ ] Comments added to complex or hard-to-understand code
- [ ] Documentation updated (README.md, DEPLOYMENT.md, claude.md, etc.)
- [ ] No new warnings or errors introduced
- [ ] Tested locally with Docker Compose
- [ ] Tested locally with development setup
- [ ] Added/updated unit tests (if applicable)
- [ ] All tests pass locally
- [ ] Database migrations created (if applicable)
- [ ] Environment variables documented in .env.example

## Backend Testing

<!-- If backend changes were made -->

- [ ] API endpoints tested manually (via Swagger UI or curl)
- [ ] Database schema changes tested
- [ ] Scraper functionality tested (if modified)
- [ ] No breaking changes to existing API endpoints
- [ ] Backend linting passes (`flake8`, `black`, `isort`)

## Frontend Testing

<!-- If frontend changes were made -->

- [ ] UI tested in Chrome/Firefox/Safari
- [ ] Responsive design tested (mobile/tablet/desktop)
- [ ] Map functionality tested (if modified)
- [ ] No console errors
- [ ] Frontend linting passes (`npm run lint`)
- [ ] Production build successful (`npm run build`)

## Deployment Notes

<!-- Any special instructions for deployment? -->

- [ ] Requires database migration
- [ ] Requires new environment variables
- [ ] Requires manual data migration
- [ ] Requires server restart
- [ ] Safe to deploy to production
- [ ] Requires coordination with other PRs

### New Environment Variables

<!-- List any new environment variables that need to be configured -->

```bash
# Example:
# NEW_API_KEY=your_api_key_here
```

## Rollback Plan

<!-- How can this change be rolled back if issues occur? -->

## Additional Context

<!-- Add any other context about the PR here -->

## Checklist Before Requesting Review

- [ ] PR title follows Conventional Commits format (e.g., `feat: add news filtering`, `fix: map marker bug`)
- [ ] Branch is up to date with target branch (develop or main)
- [ ] No merge conflicts
- [ ] CI/CD checks are passing (or explain why they're not)
- [ ] Reviewers assigned
- [ ] Labels added (bug, enhancement, documentation, etc.)

---

## For Reviewers

### Review Checklist

- [ ] Code quality and readability
- [ ] Follows project conventions
- [ ] No security vulnerabilities introduced
- [ ] Performance implications considered
- [ ] Error handling appropriate
- [ ] Tests are adequate
- [ ] Documentation is sufficient
