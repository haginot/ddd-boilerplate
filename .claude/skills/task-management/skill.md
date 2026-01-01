# Spec-Driven Development with spec-workflow-mcp

This skill provides guidance for using spec-workflow-mcp to manage development specifications within a DDD/Clean Architecture project.

## Overview

spec-workflow-mcp is a specification-driven development workflow tool that integrates with Claude Code to provide structured, approval-based task management. This skill helps you use spec-workflow-mcp effectively while maintaining DDD principles.

---

## Quick Start Commands

### Creating Specifications
```
Create a spec for user authentication feature
Create a specification for order management bounded context
```

### Listing and Viewing
```
List all specs
Show spec user-auth
What's the status of the order-management spec?
```

### Task Execution
```
Execute task 1.2 in spec user-auth
Run the next task in order-management spec
```

### Approval Workflow
```
Approve spec user-auth
Request revision for spec order-management
```

---

## DDD-Aligned Spec Workflow

### 1. Specification Creation
Create specifications aligned with bounded contexts:

```
Create a spec for [bounded-context-name] with the following requirements:
- [Domain requirement 1]
- [Domain requirement 2]
- [Application requirement]
- [Infrastructure requirement]
```

### 2. Task Organization by Layer

Specifications should organize tasks by DDD layers:

```
Spec: user-authentication
├── Domain Layer Tasks (Priority: High)
│   ├── 1.1 Create UserId Value Object
│   ├── 1.2 Create Email Value Object
│   ├── 1.3 Create User Aggregate
│   └── 1.4 Define UserCreatedEvent
├── Application Layer Tasks (Priority: Medium)
│   ├── 2.1 Create RegisterUserCommand
│   ├── 2.2 Create RegisterUserUseCase
│   └── 2.3 Create AuthenticateUserUseCase
├── Infrastructure Layer Tasks (Priority: Medium)
│   ├── 3.1 Implement UserRepository
│   └── 3.2 Implement PasswordHasher
└── Interface Layer Tasks (Priority: Low)
    ├── 4.1 Create AuthController
    └── 4.2 Define API DTOs
```

### 3. Implementation Order

Follow DDD layering when implementing tasks:

```
1. Domain Layer Tasks (First)
   └── Value Objects → Entities → Aggregates → Domain Events

2. Application Layer Tasks (Second)
   └── Use Case interfaces → Command Handlers → Query Handlers

3. Infrastructure Layer Tasks (Third)
   └── Repository implementations → External service clients

4. Interface Layer Tasks (Last)
   └── Controllers → DTOs → API endpoints
```

### 4. Task Completion Checklist

Before marking a task as complete:
- [ ] Domain layer tests pass
- [ ] No architecture violations (`npm run validate:layers`)
- [ ] Domain events published for state changes
- [ ] Ubiquitous language used consistently
- [ ] Documentation updated if needed

---

## Task-to-Layer Mapping

### Domain Layer Tasks

Tasks targeting the domain layer should focus on:

| Task Type | Location | Naming |
|-----------|----------|--------|
| Entity | `src/[context]/domain/[Entity].ts` | PascalCase |
| Value Object | `src/[context]/domain/[Name].ts` | PascalCase |
| Aggregate | `src/[context]/domain/[Aggregate].ts` | PascalCase |
| Domain Event | `src/[context]/domain/events/[Name]Event.ts` | `[Entity][Action]Event` |
| Repository Interface | `src/[context]/domain/[Entity]Repository.ts` | `[Entity]Repository` |

**Key Guidelines:**
- NO imports from outer layers
- NO infrastructure concerns (database, HTTP, etc.)
- Focus on business logic and invariants
- Use factory methods over constructors
- Publish domain events for state changes

### Application Layer Tasks

Tasks targeting the application layer should focus on:

| Task Type | Location | Naming |
|-----------|----------|--------|
| Use Case | `src/[context]/application/[Action][Entity]UseCase.ts` | `[Action][Entity]UseCase` |
| Command | `src/[context]/application/commands/[Action][Entity]Command.ts` | `[Action][Entity]Command` |
| Query | `src/[context]/application/queries/[Action][Entity]Query.ts` | `[Get/List][Entity]Query` |
| Handler | `src/[context]/application/handlers/[Name]Handler.ts` | `[Name]Handler` |

**Key Guidelines:**
- Orchestrate domain objects, don't implement business logic
- Depend on domain interfaces, not implementations
- Handle transactions
- Publish domain events
- Return DTOs, not domain entities

### Infrastructure Layer Tasks

Tasks targeting the infrastructure layer should focus on:

| Task Type | Location | Naming |
|-----------|----------|--------|
| Repository Impl | `src/[context]/infrastructure/[Prefix][Entity]Repository.ts` | `Sql[Entity]Repository` |
| Mapper | `src/[context]/infrastructure/mappers/[Entity]Mapper.ts` | `[Entity]Mapper` |
| External Client | `src/[context]/infrastructure/[Service]Client.ts` | `[Service]Client` |

**Key Guidelines:**
- Implement domain interfaces
- Map between domain and persistence models
- Handle technical concerns (connections, retries)
- Never expose infrastructure types to domain

### Interface Layer Tasks

Tasks targeting the interface layer should focus on:

| Task Type | Location | Naming |
|-----------|----------|--------|
| Controller | `src/[context]/interface/[Entity]Controller.ts` | `[Entity]Controller` |
| DTO | `src/[context]/interface/dto/[Name]Dto.ts` | `[Name]Dto` |
| Presenter | `src/[context]/interface/presenters/[Name]Presenter.ts` | `[Name]Presenter` |

**Key Guidelines:**
- Handle HTTP concerns
- Validate input
- Map to/from DTOs
- Use Application layer services

---

## Common Spec Patterns

### Pattern 1: Creating a New Aggregate Spec

When creating a spec for a new aggregate:

```
Create a spec for Order aggregate with:
- OrderId, CustomerId value objects
- Order aggregate root with items collection
- OrderCreatedEvent, OrderConfirmedEvent
- OrderRepository interface
- CreateOrderUseCase, ConfirmOrderUseCase
- SqlOrderRepository implementation
- OrderController with REST endpoints
```

### Pattern 2: Adding a Feature Spec

When creating a spec for a new feature:

```
Create a spec for password reset feature:
- PasswordResetToken value object
- PasswordResetRequestedEvent
- RequestPasswordResetUseCase
- ResetPasswordUseCase
- EmailService integration
- PasswordResetController
```

### Pattern 3: Refactoring Spec

When creating a spec for refactoring:

```
Create a spec for extracting Payment bounded context:
- Move payment-related entities from Order context
- Create PaymentRepository interface
- Update Order aggregate to use PaymentId reference
- Implement anti-corruption layer
```

---

## Dashboard Usage

Start the visual dashboard for progress monitoring:

```bash
npm run spec:dashboard
```

The dashboard provides:
- Real-time progress tracking
- Visual task status
- Approval workflow overview
- Implementation logs

---

## Related Skills

- **DDD Architecture** (`.claude/skills/ddd-architecture/`)
- **Repository Generator** (`.claude/skills/repository-generator/`)
- **Domain Event Publisher** (`.claude/skills/domain-event-publisher/`)
- **Architecture Guardian** (`.claude/skills/architecture-guardian/`)

---

## Resources

- [spec-workflow-mcp Documentation](https://github.com/Pimzino/spec-workflow-mcp)
- [DDD Reference](./docs/ubiquitous-language.md)
- [Context Map](./docs/context-map.md)
