# DDD Boilerplate

A Domain-Driven Design (DDD) and Clean Architecture boilerplate optimized for TypeScript/Node.js projects, with AI-assisted development support through Claude Code integration.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Environment Setup](#environment-setup)
- [Integrated Features](#integrated-features)
- [Development Workflow](#development-workflow)
- [Documentation](#documentation)

## 🎯 Features

This boilerplate includes the following integrated features:

- **Clean Architecture**: Four-layer architecture with clear dependency rules
- **DDD Patterns**: Entity, Value Object, Aggregate Root, Domain Event, Repository
- **Claude Code Integration**: Automated development assistance through Subagents, Skills, and Hooks
- **Spec-Workflow**: Approval-based specification-driven development workflow
- **Pre-commit Hooks**: Automated quality checks with Husky + lint-staged + commitlint
- **Just**: Unified development workflow through command runner
- **Claude Flow**: Swarm, memory, and architecture validation
- **MCP Servers**: Extended functionality through multiple MCP servers
- **Docker**: Test environment and CI/CD integration
- **GitHub Actions**: Automated CI/CD pipeline

## 🏗️ Architecture

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
- ❌ Domain **NEVER** imports from outer layers

## 🚀 Quick Start

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** or **yarn**
- **Git**
- **Claude Code** (Recommended, for AI-assisted development)
- **Docker** (Optional, for test environment)
- **Just** (Optional, for command runner)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd ddd-boilerplate

# Install dependencies
npm install

# Setup development tools (Just, Act, pre-commit)
npm run setup

# Build the project
npm run build
```

## ⚙️ Environment Setup

### 1. Environment Variables Configuration

Environment variables can be configured in two ways:

#### Method 1: Project-level Configuration (.env file)

Create a `.env` file in the project root and configure recommended environment variables:

```bash
# Copy .env.example
cp .env.example .env

# Edit values as needed
# Especially recommended to set CLAUDE_CODE_MAX_OUTPUT_TOKENS to recommended value
```

**For Node.js Applications Using Environment Variables**:

If you want to use environment variables in your application code, install and use the `dotenv` package:

```bash
# Install dotenv
npm install dotenv

# Load in application entry point
# src/index.ts
import 'dotenv/config';
// or
import dotenv from 'dotenv';
dotenv.config();
```

#### Method 2: Shell-level Configuration (Recommended)

For optimal Claude Code performance, it's recommended to add environment variables to your shell configuration file:

**Add to `~/.zshrc` or `~/.bashrc`:**

```bash
# Increase Claude Code output token limit
# Default: 4096 → Increase if errors occur with long responses
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=16384
```

**Apply changes:**

```bash
source ~/.zshrc  # or source ~/.bashrc
```

**Recommended Environment Variables** (see `.env.example`):

| Environment Variable            | Default Value | Recommended Value                          | Description                                          | Configuration Method                    |
| ------------------------------- | ------------- | ------------------------------------------ | ---------------------------------------------------- | --------------------------------------- |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 4096          | 16384                                      | Maximum output tokens. Increase for longer responses | Shell config file (recommended) or .env |
| `NODE_ENV`                      | -             | development                                | Node.js environment                                  | .env                                    |
| `DATABASE_URL`                  | -             | postgres://test:test@localhost:5432/testdb | Test database connection URL                         | .env                                    |
| `PORT`                          | -             | 3000                                       | API server port                                      | .env                                    |
| `API_BASE_URL`                  | -             | http://localhost:3000                      | API base URL                                         | .env                                    |

**Note**:

- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` is used by Claude Code, so it's recommended to set it in the shell configuration file
- Increasing token count may increase API costs
- `.env` file is included in `.gitignore`, so it won't be committed to Git

### 2. Claude Code Configuration

#### MCP Server Verification

Verify that the following MCP servers are configured in `.mcp.json`:

- `memory`: Persistent memory storage
- `filesystem`: File system access
- `sequential-thinking`: Step-by-step reasoning
- `claude-flow`: Claude Flow MCP server
- `spec-workflow`: Specification-driven development workflow

#### Restart Claude Code

After setting environment variables, **restart Claude Code** to reconnect MCP servers.

### 3. Git Hooks Setup

Pre-commit hooks are automatically installed when running `npm install` (via the `prepare` script).

To set up manually:

```bash
npm run pre-commit:install
```

### 4. Development Tools Setup

```bash
# Install Just, Act, pre-commit
npm run setup
```

## 🔧 Integrated Features

### 1. Subagents

Claude Code's Subagents feature automatically invokes specialized agents.

#### Available Agents

| Agent                     | Role                      | Use For                             |
| ------------------------- | ------------------------- | ----------------------------------- |
| `ddd-orchestrator`        | Primary Coordinator       | All development tasks               |
| `ddd-architect-reviewer`  | Architecture Guardian     | Design reviews, compliance checks   |
| `domain-engineer`         | Domain Specialist         | Aggregates, Entities, Value Objects |
| `application-engineer`    | Application Specialist    | Use Cases, Commands, Queries        |
| `infrastructure-engineer` | Infrastructure Specialist | Repositories, External Services     |
| `test-specialist`         | Testing Specialist        | Unit, Integration, E2E Tests        |

#### Automatic Invocation

`ddd-orchestrator` is automatically invoked when:

- Feature implementation requests
- Code changes in `src/` directory
- Architecture discussions
- Domain modeling requests

See the "Agent Selection Protocol" section in `CLAUDE.md` for details.

### 2. Spec-Workflow (Specification-Driven Development)

Structured approval-based specification workflow using [spec-workflow-mcp](https://github.com/Pimzino/spec-workflow-mcp).

#### Workflow

```
Requirements → Design → Approve → Implement → Validate → Complete
```

#### Quick Start

```bash
# Start dashboard (optional)
npm run spec:dashboard

# Use natural language in Claude Code:
# - "Create a spec for user authentication feature"
# - "List all specs"
# - "Execute task 1.2 in spec user-auth"
```

#### Important Rules

**The use of spec-workflow-mcp is mandatory in this project.**

- ✅ Always create and verify specs before code implementation
- ✅ Implementation without specs is prohibited
- ✅ Always follow the workflow

See the "MANDATORY: Spec-Workflow-MCP Usage" section in `CLAUDE.md` for details.

### 3. Pre-commit Hooks

Automated quality checks with **Husky** + **lint-staged** + **commitlint**.

#### Automatic Checks on Commit

When you run `git commit`, the following checks are automatically executed:

1. **lint-staged**: Runs ESLint + Prettier on staged files
2. **TypeScript Type Check**: `npm run typecheck`
3. **Architecture Validation**: `npm run validate:layers`
4. **Commit Message Validation**: Conventional Commits format

#### Commit Message Format

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Examples**:

```bash
git commit -m "feat: add user authentication"
git commit -m "fix(api): handle null response"
git commit -m "docs: update README"
```

### 4. Just - Command Runner

Unified development workflow using [Just](https://github.com/casey/just).

#### Installation

```bash
# macOS
brew install just

# Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Or use setup script
npm run setup
```

#### Main Workflows

| Command           | Description                                                    |
| ----------------- | -------------------------------------------------------------- |
| `just ci`         | Full CI pipeline (format → lint → test → docker → integration) |
| `just check`      | Quick pre-commit check                                         |
| `just pre-commit` | Pre-commit workflow (used by git hook)                         |

#### Step-by-Step Workflow

```bash
just format          # 1. Code formatting (Prettier)
just lint            # 2. ESLint
just typecheck       # 3. TypeScript type check
just test-unit       # 4. Unit tests
just test-docker     # 5. Docker environment tests
just test-integration # 6. Integration tests
just gh-actions      # 7. Local GitHub Actions verification
```

#### All Commands

```bash
just --list          # Show all available recipes
just help            # Show detailed help
```

See `justfile` for details.

### 5. Claude Flow

Swarm, memory, and architecture validation features through Claude Flow.

#### Memory Namespaces

- `domain`: Entities, VOs, Aggregates, Domain Events
- `application`: Use Cases, Commands, Queries
- `infrastructure`: Repository implementations, Mappers, External Services
- `interface`: Controllers, DTOs, APIs
- `architecture`: Layer decisions, Pattern application history
- `specs`: Spec workflow information

#### Configuration File

See `.flowconfig.json` for detailed configuration.

See `FLOW.md` for details.

### 6. MCP Servers

The following MCP servers are configured:

- **memory**: Persistent memory storage (domain context and ubiquitous language)
- **filesystem**: File system access for project management
- **sequential-thinking**: Step-by-step reasoning for complex architectural decisions
- **claude-flow**: Claude Flow MCP server for swarm, memory, and architecture validation
- **spec-workflow**: Approval-process specification-driven development workflow for DDD/Clean Architecture projects

See `.mcp.json` for configuration.

### 7. Hooks

Automatic validation through Claude Code Hooks.

#### PreToolUse Hooks

Executed before writing code:

- **Layer Dependency Validation**: Checks that domain layer doesn't import outer layers
- **Naming Convention Validation**: Ensures consistent naming patterns
- **Orchestrator Check**: Checks if orchestrator is needed for development tasks

#### PostToolUse Hooks

Executed after writing code:

- **Domain Event Validation**: Validates event naming and structure
- **Architecture Validation**: Strict architecture validation through Claude Flow

See `.claude/settings.json` for configuration.

### 8. Docker

Test environment and CI/CD integration.

#### Test Images

- `Dockerfile.test`: Docker image for testing
- `docker-compose.test.yml`: Compose configuration for test environment

#### Main Commands

```bash
# Build test image
npm run docker:build

# Run unit + integration tests in Docker
npm run docker:test

# Detect issues and generate reports
npm run docker:check

# Unit tests only (fast)
npm run docker:test:unit
```

#### Reports

Reports are generated in `reports/*.json` (generated by `scripts/docker-problem-detector.sh`).

### 9. GitHub Actions

Automated CI/CD pipeline.

#### Available Workflows

| Workflow                 | Trigger                       | Purpose             |
| ------------------------ | ----------------------------- | ------------------- |
| `claude-code-issue.yml`  | Issue with `claude-dev` label | Auto-implementation |
| `claude-code-test.yml`   | PR/push                       | Cloud testing       |
| `claude-code-review.yml` | PR                            | Auto code review    |
| `docker-ci.yml`          | PR/push                       | Docker tests        |
| `task-validation.yml`    | PR                            | Task validation     |

#### Local GitHub Actions Testing

```bash
# Run specific workflow
just gh-actions workflow="claude-code-test.yml"

# List available workflows
just gh-actions-list

# Dry run (show what would execute)
just gh-actions-dry
```

See `docs/claude-code-github-actions.md` for details.

## 💻 Development Workflow

### 1. Implementing New Features

```bash
# 1. Create spec (required)
# In Claude Code: "Create a spec for [feature name]"

# 2. Approve spec
# In Claude Code: "Approve spec [name]"

# 3. Start implementation (Orchestrator automatically invoked)
# In Claude Code: "Implement task 1.1 in spec [name]"

# 4. Validate architecture
npm run validate:layers

# 5. Run tests
npm test

# 6. Commit (pre-commit hooks automatically executed)
git commit -m "feat: implement [feature name]"
```

### 2. Code Quality Checks

```bash
# Quick check (pre-commit equivalent)
just check

# Full CI pipeline
just ci

# Individual checks
just format          # Code formatting
just lint            # ESLint
just typecheck       # TypeScript type check
just test-unit       # Unit tests
```

### 3. Creating a New Bounded Context

1. Create context directory structure:

```bash
mkdir -p src/[context]/{domain,application,infrastructure,interface}
mkdir -p src/[context]/domain/events
mkdir -p src/[context]/application/{commands,queries,handlers}
mkdir -p src/[context]/infrastructure/mappers
```

2. Define domain model:
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

See `CLAUDE.md` for details.

## 📚 Documentation

- [CLAUDE.md](./CLAUDE.md) - Project context and coding guidelines
- [FLOW.md](./FLOW.md) - Claude Flow guide
- [docs/ubiquitous-language.md](./docs/ubiquitous-language.md) - Domain vocabulary
- [docs/context-map.md](./docs/context-map.md) - Bounded Context relationships
- [docs/claude-code-github-actions.md](./docs/claude-code-github-actions.md) - GitHub Actions integration
- [docs/claude-flow-setup.md](./docs/claude-flow-setup.md) - Claude Flow setup
- [docs/memory-namespaces.md](./docs/memory-namespaces.md) - Memory namespaces

## 🔍 Troubleshooting

### MCP Server Not Found

1. Verify `.mcp.json` exists
2. Restart Claude Code (reconnect MCP servers)
3. Verify spec-workflow configuration with `npm run spec:verify`

### Pre-commit Hooks Not Working

```bash
# Reinstall Git hooks
npm run pre-commit:install

# Test manually
npm run pre-commit
```

### Docker Tests Failing

```bash
# Detect Docker issues
npm run docker:check

# Clean up Docker environment
npm run docker:clean

# Rebuild
npm run docker:build
```

### Just Command Not Found

```bash
# Install Just
npm run setup

# Or install manually
brew install just  # macOS
```

### Environment Variables Not Loading

1. Verify `.env` file exists in project root
2. Restart Claude Code
3. Check environment variable in shell: `echo $CLAUDE_CODE_MAX_OUTPUT_TOKENS`

## 📝 Best Practices

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

See the "Best Practices" section in `CLAUDE.md` for details.

## 🤖 Initial Environment Setup with Claude

When starting this project with Claude Code, follow these steps:

### Automated Environment Setup

You can automate environment setup by instructing Claude Code as follows:

```
Please execute the initial environment setup for this project.
Follow these steps to complete all configurations:

1. Install dependencies
   - Run npm install
   - Verify that dependencies are installed

2. Configure environment variables
   - Verify .env.example exists
   - If .env file doesn't exist, copy .env.example to create it
   - Verify CLAUDE_CODE_MAX_OUTPUT_TOKENS is set to 16384

3. Setup development tools
   - Run npm run setup to install Just, Act, pre-commit
   - Verify installation is complete

4. Setup Git Hooks
   - Run npm run pre-commit:install
   - Verify .husky/pre-commit and .husky/commit-msg exist

5. Verify MCP Servers
   - Verify .mcp.json exists and the following servers are configured:
     * memory
     * filesystem
     * sequential-thinking
     * claude-flow
     * spec-workflow

6. Build the project
   - Run npm run build
   - Verify build succeeds

7. Validate architecture
   - Run npm run validate:layers
   - Verify validation succeeds

8. Confirm setup completion
   - Report that all steps are complete
   - Guide on next steps (e.g., creating specs)
```

### Manual Environment Setup

If not using automated setup, execute the following commands in order:

```bash
# 1. Install dependencies
npm install

# 2. Configure environment variables
cp .env.example .env
# Edit .env file and change values as needed

# 3. Setup development tools
npm run setup

# 4. Setup Git Hooks (automatically installed, but verify)
npm run pre-commit:install

# 5. Build the project
npm run build

# 6. Validate architecture
npm run validate:layers

# 7. Restart Claude Code (reconnect MCP servers)
# Please restart Claude Code
```

### Post-Setup Verification

After environment setup is complete, verify the following:

- [ ] `.env` file exists with recommended environment variables configured
- [ ] `node_modules` is installed
- [ ] `.husky/pre-commit` and `.husky/commit-msg` exist
- [ ] Verify Just is installed with `just --version`
- [ ] Verify spec-workflow configuration is correct with `npm run spec:verify`
- [ ] Restart Claude Code and verify MCP servers are connected

### Next Steps

After environment setup is complete, proceed with the following steps:

1. **Create Spec**: Instruct Claude Code with "Create a spec for [feature name]" to create the first spec
2. **Create Bounded Context**: Create a new Bounded Context and define domain model
3. **Start Development**: Begin implementation following spec-workflow

See the "Development Workflow" section for details.

## 📄 License

MIT
