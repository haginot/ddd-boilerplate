---
name: auto-orchestrate
version: 1.0.0
description: Ensures ddd-orchestrator is invoked for all DDD development tasks
---

# Auto-Orchestrate Skill

## Skill Purpose
Automatically trigger `ddd-orchestrator` for any DDD/Clean Architecture development task.

## Activation Rules

### MUST invoke orchestrator when user request contains:

**Feature Implementation:**
- "implement [feature]"
- "create [aggregate/entity/value object]"
- "add [functionality]"
- "build [component]"
- "develop [feature]"
- "code [feature]"
- "write [code]"
- "generate [component]"

**Code Modifications:**
- Any file path starting with `src/`
- "modify [file]"
- "update [component]"
- "change [code]"
- "edit [file]"
- "refactor [code]"
- "optimize [component]"
- "improve [feature]"
- "enhance [functionality]"
- "restructure [code]"

**Architecture Work:**
- "design [model]"
- "architect [system]"
- "model [domain]"
- "plan [implementation]"

**Bug Fixes:**
- "fix [bug]" (if touches domain/application/infrastructure)
- "resolve [issue]"
- "debug [problem]"
- "patch [code]"

**Testing:**
- "test [feature]"
- "write tests for"
- "add test coverage"
- "create test suite"
- "spec [component]"

**DDD-Specific Keywords:**
- "aggregate"
- "entity"
- "value object"
- "domain event"
- "repository"
- "use case"
- "command"
- "query"
- "handler"
- "DTO"
- "domain service"
- "application service"

## Invocation Pattern

When activation rule triggers:
```
Before direct implementation:
1. Check: Is ddd-orchestrator already active?
   -> YES: Proceed
   -> NO: Invoke now

2. Explicit invocation:
   "@ddd-orchestrator, please handle: [user request]"

3. Wait for orchestrator's coordination
4. Proceed only after orchestrator delegates
```

## Examples

### Example 1: Feature Request
```
User: "Implement User registration"

Your response:
"@ddd-orchestrator, please coordinate implementation of User registration feature."

[Wait for orchestrator]
[Orchestrator delegates to domain-engineer, etc.]
```

### Example 2: Bug Fix
```
User: "Fix validation bug in User aggregate"

Your response:
"@ddd-orchestrator, please analyze and coordinate fix for validation bug in User aggregate."

[Wait for orchestrator]
```

### Example 3: Already Invoked
```
User: "Implement User registration"
[Orchestrator already active]

Your response:
[Proceed with implementation as orchestrator delegates]
```

### Example 4: Code Modification
```
User: "Update the Order aggregate to include discount calculation"

Your response:
"@ddd-orchestrator, please coordinate the update to Order aggregate for discount calculation."

[Wait for orchestrator]
```

## Exceptions (Don't invoke)

- Reading files: "show me User.ts"
- Answering questions: "what is an aggregate?"
- Documentation: "update README"
- Simple explanations: "explain the architecture"
- Listing files: "list all entities"
- Searching code: "find uses of OrderId"

## File Path Triggers

Automatically invoke for files matching:
- `src/*/domain/**/*.ts`
- `src/*/application/**/*.ts`
- `src/*/infrastructure/**/*.ts`
- `src/*/interface/**/*.ts`
- `tests/**/*.ts`

## Monitoring

Track invocation pattern:
- Log each time skill triggers
- Measure before/after invocation rates
- Report to orchestrator for optimization

Run measurement:
```bash
npm run measure:agents
```

## Integration with spec-workflow-mcp

When combined with spec-workflow-mcp:
1. spec-workflow handles specification creation/approval
2. auto-orchestrate ensures implementation uses orchestrator
3. Both work together for complete workflow control

```
User Request
    |
    v
spec-workflow-mcp (if new feature)
    |
    v
auto-orchestrate skill
    |
    v
ddd-orchestrator
    |
    v
Specialist agents (domain/application/infrastructure/test)
```
