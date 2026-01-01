# Claude Code GitHub Actions Integration

This document describes the GitHub Actions workflows that integrate Claude Code for automated development, testing, and code review.

## Overview

Three workflows automate different aspects of the development lifecycle:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `claude-code-issue.yml` | Issue labeled `claude-dev` or `@claude` comment | Auto-implement issues |
| `claude-code-test.yml` | PR opened/updated, push to main | Run tests in cloud |
| `claude-code-review.yml` | PR opened/updated | Automated code review |

## Prerequisites

### Required Secrets

Add the following secret to your repository:

```
ANTHROPIC_API_KEY=your-api-key
```

Go to: Repository Settings → Secrets and variables → Actions → New repository secret

### Required Permissions

The workflows require these permissions:
- `contents: write` - Create branches and commits
- `pull-requests: write` - Create PRs and comments
- `issues: write` - Comment on issues

## Workflows

### 1. Issue-Triggered Development

**File:** `.github/workflows/claude-code-issue.yml`

**Trigger:**
- Issue labeled with `claude-dev`
- Comment starting with `@claude`

**What it does:**
1. Reads issue title and body
2. Runs Claude Code to implement the feature
3. Follows spec-workflow-mcp process
4. Creates a branch and commits changes
5. Opens a PR linked to the issue

**Usage:**

```markdown
# Option 1: Label an issue
1. Create an issue with clear requirements
2. Add the `claude-dev` label
3. Wait for Claude to create a PR

# Option 2: Comment on an issue
@claude Please implement this with unit tests
```

**Example Issue:**
```markdown
Title: Implement User Registration Feature

## Requirements
- Create User aggregate with email validation
- Create RegisterUser use case
- Add unit tests

## Acceptance Criteria
- [ ] Email must be validated
- [ ] Duplicate emails rejected
- [ ] Tests pass
```

### 2. Cloud Testing

**File:** `.github/workflows/claude-code-test.yml`

**Trigger:**
- Pull request opened/updated
- Push to main branch

**What it does:**
1. Runs tests on Node.js 18 and 20
2. Runs linting and type checking
3. Runs architecture validation
4. Runs Docker-based tests
5. Analyzes coverage with Claude
6. Posts test summary as PR comment

**Test Matrix:**

| Test Type | Command | Node Versions |
|-----------|---------|---------------|
| Lint | `npm run lint` | 18, 20 |
| Type Check | `npm run typecheck` | 18, 20 |
| Unit Tests | `npm run test:unit` | 18, 20 |
| Integration | `npm run test:integration` | 18, 20 |
| Architecture | `npm run validate:layers` | 18, 20 |
| Docker | `npm run docker:test:unit` | Latest |

### 3. Automated Code Review

**File:** `.github/workflows/claude-code-review.yml`

**Trigger:**
- Pull request opened/updated/ready for review

**What it does:**
1. Identifies changed TypeScript files
2. Reviews code against DDD/Clean Architecture principles
3. Checks for security vulnerabilities
4. Validates architecture layer dependencies
5. Posts detailed review as PR comment

**Review Checklist:**

#### DDD/Clean Architecture
- [ ] Domain layer has no outer layer imports
- [ ] Entities contain business logic (not anemic)
- [ ] Value Objects are immutable
- [ ] Domain Events use past-tense naming
- [ ] Repository interfaces in domain layer
- [ ] Use Cases orchestrate, don't contain business logic

#### Code Quality
- [ ] TypeScript strict mode compliant
- [ ] Proper error handling
- [ ] No code duplication
- [ ] Consistent naming conventions

#### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities

## Configuration

### Customizing Claude's Behavior

Edit the `prompt` field in each workflow to customize instructions:

```yaml
- name: Run Claude Code
  uses: anthropics/claude-code-action@beta
  with:
    prompt: |
      # Your custom instructions here
    max_turns: 50
    timeout_minutes: 30
```

### Adjusting Test Matrix

Edit `claude-code-test.yml` to change Node versions:

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]  # Add more versions
```

### Limiting Review Scope

Edit `claude-code-review.yml` to change which files trigger review:

```yaml
- name: Get changed files
  uses: tj-actions/changed-files@v44
  with:
    files: |
      src/**/*.ts
      tests/**/*.ts
      # Add more patterns
```

## Best Practices

### Writing Good Issues for Claude

1. **Be specific** - Include clear requirements
2. **Provide context** - Reference existing code if relevant
3. **Define acceptance criteria** - What does "done" look like?
4. **Use DDD terminology** - Aggregate, Entity, Value Object, etc.

**Good Example:**
```markdown
## Feature: Order Confirmation

### Context
We have an Order aggregate in src/order/domain/Order.ts

### Requirements
1. Add `confirm()` method to Order aggregate
2. Publish OrderConfirmed domain event
3. Prevent confirmation of already confirmed orders

### Files to modify
- src/order/domain/Order.ts
- src/order/domain/events/OrderConfirmed.ts (new)
- tests/unit/order/Order.test.ts
```

### Reviewing Claude's PRs

1. **Always review** - Claude can make mistakes
2. **Check tests** - Ensure coverage is adequate
3. **Verify architecture** - Run `npm run validate:layers`
4. **Test manually** - For complex features

### Handling Failures

If a workflow fails:
1. Check the workflow run logs
2. Look for specific error messages
3. Comment on the issue with more context
4. Try again with `@claude` comment

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "API key not found" | Add `ANTHROPIC_API_KEY` secret |
| "Permission denied" | Check workflow permissions in settings |
| "Tests failing" | Review test output, fix issues manually |
| "Claude timeout" | Increase `timeout_minutes` or simplify task |

### Debugging

Enable debug logging:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

### Rate Limits

- Claude API has rate limits
- Large PRs may hit token limits
- Split large tasks into smaller issues

## Security Considerations

1. **API Key Protection** - Never commit API keys
2. **Review All Code** - Claude can make security mistakes
3. **Least Privilege** - Only grant necessary permissions
4. **Audit Logs** - Check Actions logs regularly

## Cost Optimization

1. **Limit Triggers** - Use labels to control when Claude runs
2. **Set Timeouts** - Prevent runaway jobs
3. **Cache Dependencies** - Use npm cache in workflows
4. **Skip Unchanged Files** - Only review changed code

## Integration with Spec Workflow

Claude Code respects the spec-workflow-mcp process:

```
Issue Created
    |
    v
[claude-code-issue.yml]
    |
    v
Claude checks for existing spec
    |
    +-- No spec: Creates requirements -> design -> tasks
    |
    +-- Has spec: Implements tasks
    |
    v
Creates PR
    |
    v
[claude-code-test.yml] - Runs tests
[claude-code-review.yml] - Reviews code
    |
    v
Human Review & Merge
```

## Examples

### Example: Full Development Cycle

1. Create issue:
```markdown
Title: Add Email Value Object

Implement Email value object with validation.

Requirements:
- Validate email format
- Immutable
- Unit tests
```

2. Add `claude-dev` label

3. Claude creates PR with:
   - `src/shared/domain/Email.ts`
   - `tests/unit/shared/domain/Email.test.ts`

4. Tests run automatically

5. Code review posted

6. Human reviews and merges

---

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - Project guidelines
- [Agent Orchestration](./agent-orchestration-test-scenarios.md) - Subagent system
- [spec-workflow-mcp](../README.md#spec-driven-development) - Specification workflow
