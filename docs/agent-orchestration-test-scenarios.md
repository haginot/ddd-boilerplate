# Agent Orchestration Test Scenarios

This document defines test scenarios for validating the DDD orchestrator invocation rate.

## Test Categories

### Category 1: Feature Implementation (Expected: Orchestrator Invoked)

| # | Request | Expected Agents | Pass Criteria |
|---|---------|-----------------|---------------|
| 1.1 | "Implement User registration feature" | ddd-orchestrator, domain-engineer, application-engineer, test-specialist | Orchestrator auto-invoked |
| 1.2 | "Create Order aggregate with line items" | ddd-orchestrator, ddd-architect-reviewer, domain-engineer | Orchestrator auto-invoked |
| 1.3 | "Add email validation to User" | ddd-orchestrator, domain-engineer | Orchestrator auto-invoked |
| 1.4 | "Build payment processing feature" | ddd-orchestrator, domain-engineer, infrastructure-engineer | Orchestrator auto-invoked |
| 1.5 | "Develop shopping cart functionality" | ddd-orchestrator, all specialists | Orchestrator auto-invoked |

### Category 2: Bug Fixes (Expected: Orchestrator Invoked)

| # | Request | Expected Agents | Pass Criteria |
|---|---------|-----------------|---------------|
| 2.1 | "Fix email validation in User aggregate" | ddd-orchestrator, domain-engineer | Orchestrator auto-invoked |
| 2.2 | "Resolve authentication issue in LoginHandler" | ddd-orchestrator, application-engineer | Orchestrator auto-invoked |
| 2.3 | "Debug repository save failure" | ddd-orchestrator, infrastructure-engineer | Orchestrator auto-invoked |
| 2.4 | "Fix failing unit tests for Order" | ddd-orchestrator, test-specialist | Orchestrator auto-invoked |

### Category 3: Refactoring (Expected: Orchestrator Invoked)

| # | Request | Expected Agents | Pass Criteria |
|---|---------|-----------------|---------------|
| 3.1 | "Extract Email value object from User" | ddd-orchestrator, ddd-architect-reviewer, domain-engineer | Orchestrator auto-invoked |
| 3.2 | "Refactor OrderService to follow CQRS" | ddd-orchestrator, application-engineer | Orchestrator auto-invoked |
| 3.3 | "Optimize UserRepository queries" | ddd-orchestrator, infrastructure-engineer | Orchestrator auto-invoked |

### Category 4: Architecture Review (Expected: Architect Invoked)

| # | Request | Expected Agents | Pass Criteria |
|---|---------|-----------------|---------------|
| 4.1 | "Review User aggregate design" | ddd-architect-reviewer | Architect auto-invoked |
| 4.2 | "Validate layer dependencies in Order context" | ddd-architect-reviewer | Architect auto-invoked |
| 4.3 | "Check DDD compliance for Payment module" | ddd-architect-reviewer | Architect auto-invoked |

### Category 5: Simple Queries (Expected: No Orchestrator)

| # | Request | Expected Agents | Pass Criteria |
|---|---------|-----------------|---------------|
| 5.1 | "Show me the User aggregate code" | None | Direct response |
| 5.2 | "List all entities in the project" | None | Direct response |
| 5.3 | "What is an aggregate root?" | None | Direct response |
| 5.4 | "Find uses of OrderId" | None | Direct response |

### Category 6: Documentation (Expected: No Orchestrator)

| # | Request | Expected Agents | Pass Criteria |
|---|---------|-----------------|---------------|
| 6.1 | "Update README with architecture overview" | None | Direct response |
| 6.2 | "Add JSDoc comments to User entity" | None | Direct response |
| 6.3 | "Fix typo in CLAUDE.md" | None | Direct response |

## Success Metrics

### Target Invocation Rates

| Category | Target Rate | Priority |
|----------|-------------|----------|
| Feature Implementation | 95%+ | Critical |
| Bug Fixes | 90%+ | High |
| Refactoring | 90%+ | High |
| Architecture Review | 95%+ | Critical |
| Simple Queries | 0% (should NOT invoke) | Medium |
| Documentation | 0% (should NOT invoke) | Low |

### Overall Target

- **Development Tasks (Categories 1-4):** 90%+ orchestrator invocation
- **Non-Development Tasks (Categories 5-6):** <10% orchestrator invocation

## Running Tests

### Manual Testing

1. Start a new Claude Code session
2. Execute each test scenario request
3. Record whether orchestrator was invoked
4. Calculate invocation rate per category

### Automated Measurement

```bash
# Run after a session with development tasks
npm run measure:agents

# View report
cat reports/agent-invocation-rate.md
```

## Improving Invocation Rates

If rates are below target:

1. **Check orchestrator description** - Ensure all keywords are included
2. **Verify hookify rules** - Confirm `orchestrator-reminder` is enabled
3. **Review auto-orchestrate skill** - Check activation rules
4. **Update CLAUDE.md** - Strengthen agent selection protocol
5. **Use explicit invocation** - `@ddd-orchestrator [request]`

## Test Log Template

```markdown
## Test Session: [Date]

### Results

| Scenario | Invoked? | Agents Used | Notes |
|----------|----------|-------------|-------|
| 1.1 | Yes/No | [list] | [notes] |
| 1.2 | Yes/No | [list] | [notes] |
...

### Summary

- Total scenarios tested: X
- Orchestrator invoked: Y
- Invocation rate: Z%
- Target met: Yes/No

### Issues Found

- [List any issues]

### Recommendations

- [List improvements]
```
