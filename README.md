# DDD Boilerplate

A Domain-Driven Design (DDD) and Clean Architecture boilerplate for TypeScript/Node.js projects, optimized for use with Claude Code.

## Features

- **Clean Architecture**: Four-layer architecture with clear dependency rules
- **DDD Patterns**: Entity, Value Object, Aggregate Root, Domain Event, Repository
- **Claude Code Integration**: CLAUDE.md, Skills, Hooks for automated guidance
- **Type Safety**: Full TypeScript support with strict mode
- **Testing Ready**: Jest configuration with separate unit/integration/e2e test suites

## Architecture

```
┌─────────────────────────────────────┐
│      Interface Layer (API/UI)       │  ← Controllers, CLI
├─────────────────────────────────────┤
│      Application Layer              │  ← Use Cases, Commands, Queries
├─────────────────────────────────────┤
│      Domain Layer                   │  ← Entities, Value Objects, Domain Events
├─────────────────────────────────────┤
│      Infrastructure Layer           │  ← Repositories, External Services
└─────────────────────────────────────┘
```

### Dependency Rule

Dependencies point **inward only**:
- Interface → Application → Domain
- Infrastructure → Domain (implements interfaces)
- ❌ Domain NEVER imports from outer layers

## Project Structure

```
src/
├── shared/                      # Shared Kernel
│   └── domain/
│       ├── Entity.ts           # Entity base class
│       ├── ValueObject.ts      # Value Object base class
│       ├── AggregateRoot.ts    # Aggregate Root base class
│       ├── DomainEvent.ts      # Domain Event interface
│       └── Repository.ts       # Repository interface
└── [context]/                   # Bounded Context
    ├── domain/                 # Domain Layer
    ├── application/            # Application Layer
    ├── infrastructure/         # Infrastructure Layer
    └── interface/              # Interface Layer

tests/
├── unit/                       # Domain layer tests
├── integration/                # Application layer tests
└── e2e/                        # End-to-end tests

.claude/
├── settings.json               # Hooks configuration
├── skills/
│   └── ddd-architecture/       # DDD skill
└── hooks/                      # Validation scripts
```

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- npm or yarn
- Claude Code (optional, for AI-assisted development)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd ddd-boilerplate

# Install dependencies
npm install

# Build the project
npm run build
```

### Development

```bash
# Run in development mode
npm run dev

# Type check
npm run typecheck

# Lint
npm run lint
npm run lint:fix
```

### Testing

```bash
# Run all tests
npm test

# Run unit tests only
npm run test:unit

# Run integration tests
npm run test:integration

# Run e2e tests
npm run test:e2e

# Run with coverage
npm run test:coverage
```

## Creating a New Bounded Context

1. Create the context directory structure:

```bash
mkdir -p src/[context]/{domain,application,infrastructure,interface}
mkdir -p src/[context]/domain/events
mkdir -p src/[context]/application/{commands,queries,handlers}
mkdir -p src/[context]/infrastructure/mappers
```

2. Define your domain model:
   - Create entities and value objects in `domain/`
   - Define repository interfaces in `domain/`
   - Create domain events in `domain/events/`

3. Implement use cases in `application/`:
   - Create commands and queries
   - Implement handlers

4. Add infrastructure in `infrastructure/`:
   - Implement repositories
   - Add mappers for domain ↔ persistence conversion

5. Create API endpoints in `interface/`

## Claude Code Integration

This boilerplate includes Claude Code integration for AI-assisted development:

### CLAUDE.md

Project context and coding guidelines are defined in `CLAUDE.md`. Claude Code will automatically read this file to understand:
- Architecture principles
- Coding conventions
- Layer boundaries
- Naming conventions

### Hooks

Validation hooks automatically check:
- **Layer Dependencies**: Prevents domain layer from importing outer layers
- **Domain Events**: Validates event naming and structure
- **Naming Conventions**: Ensures consistent naming patterns
- **Task Architecture**: Validates task implementations follow DDD principles

### Skills

The DDD Architecture skill provides guidance for:
- Creating aggregates and entities
- Implementing repositories
- Publishing domain events
- Designing bounded contexts

## Spec-Driven Development with spec-workflow-mcp

This project integrates [spec-workflow-mcp](https://github.com/Pimzino/spec-workflow-mcp) for structured, approval-based specification workflow aligned with DDD principles.

### Quick Start

```bash
# Start the dashboard (optional)
npm run spec:dashboard

# In Claude Code, use natural language:
# - "Create a spec for user authentication feature"
# - "List all specs"
# - "Execute task 1.2 in spec user-auth"
```

### Natural Language Commands

| Command | Description |
|---------|-------------|
| "Create a spec for [feature]" | Create new specification |
| "List all specs" | Show all specifications and status |
| "Show spec [name]" | Display specification details |
| "Execute task [id] in spec [name]" | Execute a specific task |
| "Approve spec [name]" | Approve specification |

### Spec Workflow

1. **Create Requirements** - Define requirements using natural language
2. **Design Specification** - System generates structured specs with tasks by DDD layer
3. **Approve Specification** - Review and approve before implementation
4. **Implement** - Follow DDD layer order (Domain → Application → Infrastructure → Interface)
5. **Validate** - Run `npm run validate:layers` before completing
6. **Complete** - Mark spec as done after all tasks finished

See `CLAUDE.md` for detailed spec-workflow documentation.

## Documentation

- [Ubiquitous Language](./docs/ubiquitous-language.md) - Domain vocabulary
- [Context Map](./docs/context-map.md) - Bounded context relationships

## Best Practices

### Domain Layer

- ✅ Keep domain logic in entities and value objects
- ✅ Use factory methods for object creation
- ✅ Validate invariants in domain objects
- ✅ Publish domain events for state changes
- ❌ Never import from infrastructure or application layers

### Application Layer

- ✅ One use case per class
- ✅ Orchestrate domain objects, don't implement business logic
- ✅ Use DTOs for input/output
- ✅ Publish domain events through event publisher

### Infrastructure Layer

- ✅ Implement repository interfaces from domain layer
- ✅ Use mappers for domain ↔ persistence conversion
- ✅ Return domain objects, never database models

## License

MIT
