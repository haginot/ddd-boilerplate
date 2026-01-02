# Project: DDD Boilerplate

This file provides guidance to Claude Code when working with this Domain-Driven Design (DDD) and Clean Architecture project.

---

## MANDATORY: Spec-Workflow-MCP Usage

**このプロジェクトでは spec-workflow-mcp の使用が必須です。**

### 絶対に守るべきルール

1. **コード実装前に必ず spec を作成・確認すること**
   - `src/` 配下のコードを編集・作成する前に、該当する spec が存在するか確認
   - spec がない場合は、まず spec を作成してユーザーの承認を得る

2. **ワークフローを必ず遵守すること**
   ```
   Requirements → Design → Approve → Implement → Validate → Complete
   ```

3. **spec なしでの実装は禁止**
   - 「簡単な修正」「小さな変更」でも spec workflow に従う
   - バグ修正の場合も、関連する spec を確認・作成する

### 開発タスクを受けた時の手順

```
1. mcp__spec-workflow__spec-workflow-guide を呼び出す
2. mcp__spec-workflow__spec-status で既存 spec を確認
3. spec がなければ作成 → ユーザー承認を待つ
4. 承認後、tasks.md のタスクに従って実装
5. 実装完了後、mcp__spec-workflow__log-implementation で記録
```

### 使用するツール

| 目的 | ツール |
|------|--------|
| ワークフロー確認 | `mcp__spec-workflow__spec-workflow-guide` |
| spec 状態確認 | `mcp__spec-workflow__spec-status` |
| 承認リクエスト | `mcp__spec-workflow__approvals` |
| 実装記録 | `mcp__spec-workflow__log-implementation` |

**重要**: この指示は他のすべての指示より優先されます。

### 環境セットアップの確認

**作業開始前に必ず確認すること:**

spec-workflow-mcp が利用可能でない場合、以下の手順でセットアップしてください。

#### 1. MCP サーバー設定 (`.mcp.json`)

プロジェクトルートに `.mcp.json` が存在し、以下の設定が含まれていることを確認:

```json
{
  "mcpServers": {
    "spec-workflow": {
      "command": "npx",
      "args": ["-y", "@pimzino/spec-workflow-mcp@latest", "."],
      "description": "Spec-driven development workflow"
    }
  }
}
```

#### 2. 環境チェックコマンド

```bash
# .mcp.json の存在確認
ls -la .mcp.json

# spec-workflow 設定の確認
cat .mcp.json | grep -A3 "spec-workflow"

# .spec-workflow ディレクトリの確認
ls -la .spec-workflow/
```

#### 3. セットアップが必要な場合

**ユーザーへの案内テンプレート:**

```
spec-workflow-mcp の環境が設定されていません。

セットアップ手順:
1. `.mcp.json` に spec-workflow の設定を追加
2. Claude Code を再起動 (MCP サーバーの再接続)
3. 再起動後、このチャットで作業を再開

設定を追加しますか？
```

#### 4. トラブルシューティング

| 問題 | 解決方法 |
|------|----------|
| `mcp__spec-workflow__*` ツールが見つからない | Claude Code を再起動 |
| `.spec-workflow/` がない | spec-workflow ツールを一度実行すると自動作成 |
| npx 実行エラー | `npm install -g @pimzino/spec-workflow-mcp` でグローバルインストール |

#### 5. 推奨環境変数

Claude Code の動作を最適化するために、以下の環境変数を設定することを推奨します。

**`~/.zshrc` または `~/.bashrc` に追加:**

```bash
# Claude Code 出力トークン制限の引き上げ
# デフォルト: 4096 → 長い応答でエラーが発生する場合に増加
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=16384
```

**設定後の反映:**
```bash
source ~/.zshrc  # または source ~/.bashrc
```

| 環境変数 | デフォルト値 | 推奨値 | 説明 |
|----------|-------------|--------|------|
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 4096 | 16384 | 出力トークンの最大数。長い応答が必要な場合に増加 |

**注意**: トークン数を増やすと、API コストが増加する可能性があります。

---

## Project Overview

**Architecture**: Domain-Driven Design (DDD) + Clean Architecture
**Language**: TypeScript
**Runtime**: Node.js (>=18.0.0)

This project follows strict DDD and Clean Architecture principles to ensure maintainability, testability, and alignment with business requirements.

---

## Architecture Overview

### Layered Architecture

```
┌─────────────────────────────────────┐
│      Interface Layer (API/UI)       │  ← Adapters (Controllers, CLI, etc.)
├─────────────────────────────────────┤
│      Application Layer              │  ← Use Cases, Commands, Queries
├─────────────────────────────────────┤
│      Domain Layer                   │  ← Business Logic (Entities, Aggregates, Value Objects)
├─────────────────────────────────────┤
│      Infrastructure Layer           │  ← Adapters (Database, External APIs)
└─────────────────────────────────────┘
```

### Dependency Rule

**CRITICAL**: Dependencies MUST point inward only:

```
Interface → Application → Domain
     ↓           ↓          ↑
Infrastructure → (implements Domain interfaces)
```

- ✅ Domain layer has ZERO dependencies on outer layers
- ✅ Application layer depends on Domain interfaces
- ✅ Infrastructure implements Domain interfaces
- ❌ Domain NEVER imports from Application/Infrastructure/Interface

---

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
    │   ├── [Aggregate].ts     # Aggregate Root
    │   ├── [Entity].ts        # Entity
    │   ├── [ValueObject].ts   # Value Object
    │   ├── [Repository].ts    # Repository Interface
    │   └── events/
    │       └── [Event].ts     # Domain Events
    ├── application/            # Application Layer
    │   ├── commands/
    │   │   └── [Command].ts
    │   ├── queries/
    │   │   └── [Query].ts
    │   └── handlers/
    │       └── [Handler].ts
    ├── infrastructure/         # Infrastructure Layer
    │   ├── [Repository]Impl.ts
    │   ├── mappers/
    │   └── models/
    └── interface/              # Interface Layer
        └── [Controller].ts
```

---

## Code Style Guidelines

### Entity Rules

```typescript
// ✅ GOOD: Rich domain model with behavior
export class Order extends AggregateRoot<OrderId> {
  private constructor(
    id: OrderId,
    private items: OrderItem[],
    private status: OrderStatus
  ) {
    super(id);
  }

  static create(customerId: CustomerId, items: OrderItem[]): Order {
    if (items.length === 0) {
      throw new InvalidOrderError("Order must have at least one item");
    }
    const order = new Order(OrderId.generate(), items, OrderStatus.Pending);
    order.addDomainEvent(new OrderCreatedEvent(order.id));
    return order;
  }

  addItem(item: OrderItem): void {
    if (this.status !== OrderStatus.Pending) {
      throw new InvalidOrderError("Cannot modify confirmed order");
    }
    this.items.push(item);
  }

  confirm(): void {
    this.validateOrderCanBeConfirmed();
    this.status = OrderStatus.Confirmed;
    this.addDomainEvent(new OrderConfirmedEvent(this.id));
  }
}

// ❌ BAD: Anemic domain model (just data)
export class Order {
  id: string;
  items: OrderItem[];
  status: string;
}
```

**Entity Best Practices**:
- ✅ Entities MUST have unique identity
- ✅ Use private constructors + factory methods
- ✅ Implement business logic as methods
- ✅ Validate invariants in methods
- ✅ Publish domain events for state changes
- ❌ NEVER create anemic entities (data-only)

### Value Object Rules

```typescript
// ✅ GOOD: Immutable value object with validation
export class Email extends ValueObject<{ value: string }> {
  private constructor(props: { value: string }) {
    super(props);
  }

  static create(email: string): Email {
    if (!Email.isValid(email)) {
      throw new InvalidEmailError(`Invalid email: ${email}`);
    }
    return new Email({ value: email });
  }

  private static isValid(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  get value(): string {
    return this.props.value;
  }

  get domain(): string {
    return this.props.value.split('@')[1];
  }
}

// ❌ BAD: Mutable value object without validation
export class Email {
  value: string; // Can be changed!
}
```

**Value Object Best Practices**:
- ✅ Value objects MUST be immutable
- ✅ Equality based on ALL attributes
- ✅ Include validation in factory method
- ✅ Small and focused
- ✅ Implement meaningful methods

### Repository Pattern

```typescript
// ✅ GOOD: Repository interface in domain layer
// File: src/[context]/domain/OrderRepository.ts
export interface OrderRepository {
  save(order: Order): Promise<void>;
  findById(id: OrderId): Promise<Order | null>;
  findByCustomerId(customerId: CustomerId): Promise<Order[]>;
  findPendingOrders(): Promise<Order[]>;
}

// ✅ GOOD: Implementation in infrastructure layer
// File: src/[context]/infrastructure/SqlOrderRepository.ts
export class SqlOrderRepository implements OrderRepository {
  constructor(private readonly db: Database) {}

  async save(order: Order): Promise<void> {
    const model = OrderMapper.toModel(order);
    await this.db.save(model);
  }

  async findById(id: OrderId): Promise<Order | null> {
    const model = await this.db.findOne({ id: id.value });
    return model ? OrderMapper.toDomain(model) : null;
  }
}

// ❌ BAD: Repository returning DTOs or database models
export interface OrderRepository {
  findById(id: string): Promise<OrderDto>; // ❌ Should return Order entity
}
```

**Repository Best Practices**:
- ✅ Repository interfaces in domain layer
- ✅ Implementations in infrastructure layer
- ✅ Return domain objects, NEVER DTOs or database models
- ✅ Use domain-specific query methods
- ✅ Repository works with Aggregate Roots only

### Domain Events

```typescript
// ✅ GOOD: Immutable domain event with past tense
export class OrderConfirmedEvent implements DomainEvent {
  readonly occurredAt: Date;
  
  constructor(
    readonly orderId: OrderId,
    readonly customerId: CustomerId,
    readonly totalAmount: Money
  ) {
    this.occurredAt = new Date();
  }
}

// ❌ BAD: Mutable event with present tense
export class ConfirmOrder { // Should be OrderConfirmed
  orderId: string; // Can be changed!
}
```

**Domain Event Best Practices**:
- ✅ Events MUST be immutable
- ✅ Use past tense naming (OrderCreated, not CreateOrder)
- ✅ Include all necessary data
- ✅ Publish through application layer
- ✅ Include timestamp

### Use Cases (Application Layer)

```typescript
// ✅ GOOD: Use case orchestrates domain objects
export class CreateOrderUseCase {
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(command: CreateOrderCommand): Promise<CreateOrderResponse> {
    // 1. Create domain objects
    const customerId = CustomerId.create(command.customerId);
    const items = command.items.map(item => 
      OrderItem.create(
        ProductId.create(item.productId),
        Quantity.create(item.quantity),
        Money.create(item.price, Currency.USD)
      )
    );

    // 2. Use domain logic
    const order = Order.create(customerId, items);

    // 3. Persist through repository
    await this.orderRepository.save(order);

    // 4. Publish events
    for (const event of order.domainEvents) {
      await this.eventPublisher.publish(event);
    }

    return new CreateOrderResponse(order.id.value);
  }
}

// ❌ BAD: Use case contains business logic
export class CreateOrderUseCase {
  async execute(command: CreateOrderCommand): Promise<void> {
    // ❌ Business logic should be in domain
    if (command.items.length === 0) {
      throw new Error("Order must have items");
    }
    const total = command.items.reduce((sum, item) => sum + item.price, 0);
    // ...
  }
}
```

**Use Case Best Practices**:
- ✅ Orchestrate domain objects, don't implement business logic
- ✅ Handle transactions
- ✅ Publish domain events
- ✅ Return DTOs, not domain objects
- ✅ One use case = one business workflow

---

## Development Commands

```bash
# Install dependencies
npm install

# Development
npm run dev

# Build
npm run build

# Run tests
npm test
npm run test:unit
npm run test:integration
npm run test:e2e
npm run test:coverage

# Lint
npm run lint
npm run lint:fix

# Type check
npm run typecheck
```

---

## Critical Rules

### NEVER

- ❌ **NEVER implement code without an approved spec** (spec-workflow-mcp 必須)
- ❌ **NEVER skip the spec workflow** even for "small" changes
- ❌ NEVER expose database concerns to domain layer
- ❌ NEVER create anemic domain models (data without behavior)
- ❌ NEVER have cross-aggregate transactions in single operation
- ❌ NEVER let technical concerns drive domain design
- ❌ NEVER skip ubiquitous language development
- ❌ NEVER create large, monolithic aggregates
- ❌ NEVER use domain entities in API responses (use DTOs)
- ❌ NEVER import from outer layers in domain code

### ALWAYS

- ✅ **ALWAYS use spec-workflow-mcp before implementing any feature**
- ✅ **ALWAYS call spec-workflow-guide when receiving implementation requests**
- ✅ **ALWAYS get user approval before starting implementation**
- ✅ **ALWAYS log implementation details after completing tasks**
- ✅ ALWAYS use ubiquitous language consistently
- ✅ ALWAYS respect bounded context boundaries
- ✅ ALWAYS validate invariants in domain objects
- ✅ ALWAYS publish domain events for state changes
- ✅ ALWAYS use dependency injection at composition root
- ✅ ALWAYS write tests for domain logic first
- ✅ ALWAYS make value objects immutable
- ✅ ALWAYS use repository pattern for persistence

---

## Agent Selection Protocol

### Mandatory Orchestrator Usage

**IMPORTANT:** For ALL development tasks in this DDD/Clean Architecture project,
you MUST follow this protocol:

#### Automatic Invocation (Preferred)
The `ddd-orchestrator` should automatically activate when you receive requests containing:
- Feature implementation keywords
- Code modifications in `src/` directory
- Architecture discussions
- Domain modeling requests

#### Verification Check
Before implementing ANY code changes, verify:
```
Is this a development task?
  -> YES: Has ddd-orchestrator been invoked?
    -> NO: Invoke it now before proceeding
    -> YES: Proceed with implementation
  -> NO: Handle directly
```

#### Explicit Invocation (Fallback)
If automatic invocation doesn't occur for development tasks:
```
@ddd-orchestrator [describe the task]
```

#### Examples

**Correct workflow:**
```
User: "Implement User registration feature"
Claude: [Automatically invokes ddd-orchestrator]
Orchestrator: [Analyzes -> Delegates to specialists]
Result: Coordinated multi-agent implementation
```

**Incorrect workflow (avoid):**
```
User: "Implement User registration feature"
Claude: [Directly starts implementing without orchestrator]
```

#### Emergency Override
Only skip orchestrator for:
- Reading existing files (no modifications)
- Answering questions about architecture (no implementation)
- Simple documentation updates (README, comments)

### Subagent Delegation Rules

When you ARE the orchestrator:
1. **Always decompose** complex tasks by DDD layer
2. **Delegate, don't implement** - use specialist agents
3. **Validate compliance** - check layer dependencies
4. **Integrate results** - coordinate multiple agents
5. **Report comprehensively** - summarize all work done

### Available Specialist Agents

| Agent | Role | Use For |
|-------|------|---------|
| `ddd-orchestrator` | Primary coordinator | All development tasks |
| `ddd-architect-reviewer` | Architecture guardian | Design reviews, compliance checks |
| `domain-engineer` | Domain specialist | Aggregates, Entities, Value Objects |
| `application-engineer` | Application specialist | Use Cases, Commands, Queries |
| `infrastructure-engineer` | Infrastructure specialist | Repositories, External services |
| `test-specialist` | Testing specialist | Unit, Integration, E2E tests |

---

## Code Review Checklist

Before committing code, verify:

### Domain Layer
- [ ] Entities contain business logic, not just data
- [ ] Value objects are immutable
- [ ] Aggregates maintain their invariants
- [ ] Domain events are published for state changes
- [ ] No dependencies on outer layers
- [ ] Ubiquitous language is used consistently

### Application Layer
- [ ] Use cases orchestrate, don't implement business logic
- [ ] DTOs are used for input/output
- [ ] Domain events are published
- [ ] Dependencies are injected

### Infrastructure Layer
- [ ] Repositories return domain objects, not DTOs
- [ ] Database models are separate from domain entities
- [ ] Mapping between domain and persistence is clear

### Testing
- [ ] Domain logic has unit tests without mocks
- [ ] Use cases have integration tests with mocked repositories
- [ ] All tests pass

---

## Naming Conventions

### Files
- Entities: `[Name].ts` (e.g., `Order.ts`)
- Value Objects: `[Name].ts` (e.g., `Money.ts`, `OrderId.ts`)
- Domain Events: `[Name]Event.ts` (e.g., `OrderCreatedEvent.ts`)
- Repository Interfaces: `[Name]Repository.ts` (e.g., `OrderRepository.ts`)
- Repository Implementations: `[Name]RepositoryImpl.ts` or `Sql[Name]Repository.ts`
- Use Cases: `[Action][Entity]UseCase.ts` (e.g., `CreateOrderUseCase.ts`)
- Commands: `[Action][Entity]Command.ts` (e.g., `CreateOrderCommand.ts`)
- Queries: `[Action][Entity]Query.ts` (e.g., `GetOrderQuery.ts`)

### Classes
- Domain Events: Past tense (`OrderCreated`, `PaymentProcessed`)
- Commands: Imperative (`CreateOrder`, `ConfirmPayment`)
- Errors: `[Context]Error` (e.g., `InvalidOrderError`)

---

## Additional Resources

- [docs/ubiquitous-language.md](./docs/ubiquitous-language.md) - Domain vocabulary
- [docs/context-map.md](./docs/context-map.md) - Bounded context relationships
- [docs/claude-code-github-actions.md](./docs/claude-code-github-actions.md) - GitHub Actions integration

---

## Claude Code GitHub Actions Integration

This project includes GitHub Actions workflows for automated development with Claude Code.

### Available Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `claude-code-issue.yml` | Issue with `claude-dev` label | Auto-implement issues |
| `claude-code-test.yml` | PR/push | Cloud testing |
| `claude-code-review.yml` | PR | Automated code review |
| `claude-code-auto-fix.yml` | CI failure (workflow_run) | Auto-fix CI failures |

### Quick Start

1. **Add secret:** Repository Settings → Secrets → `ANTHROPIC_API_KEY`

2. **Auto-implement an issue:**
   - Create an issue with requirements
   - Add `claude-dev` label
   - Claude creates a PR automatically

3. **Request changes via comment:**
   ```
   @claude Please add validation for email format
   ```

### Features

- **Issue-to-PR Automation:** Label issues with `claude-dev` for automatic implementation
- **Cloud Testing:** Tests run on Node.js 20/22 with Docker
- **Code Review:** DDD/Clean Architecture compliance checks
- **Architecture Validation:** Layer dependency verification
- **Auto-Fix CI Failures:** Automatic repair of CI failures using Claude Code

### Auto-Fix Workflow

The `claude-code-auto-fix.yml` workflow automatically fixes CI failures:

1. **Trigger:** When any of the following workflows fail:
   - Claude Code - Cloud Testing
   - Docker CI
   - AI-Generated Code Quality
   - Task Validation

2. **Process:**
   - Detects failed jobs and retrieves error logs
   - Analyzes the failure using Claude Code
   - Attempts automatic fixes (lint, type errors, tests)
   - Commits and pushes fixes to the PR branch
   - Comments on the PR with results

3. **Safety:**
   - Only runs on PRs (not direct pushes)
   - Prevents infinite loops by skipping `claude-auto-fix-*` branches
   - Respects DDD/Clean Architecture rules

### Local CI Monitoring (gh CLI + Claude Code)

For immediate CI monitoring without waiting for workflow_run triggers:

```bash
# Interactive watch mode - prompts before fixing
npm run ci:watch

# Auto-fix mode - automatically fixes failures
npm run ci:watch:auto

# Background monitoring
npm run ci:monitor

# Manual fix for specific run
npm run ci:fix -- --run-id <RUN_ID>
```

**Features:**
- Real-time CI status dashboard
- Automatic failure detection
- Claude Code integration for intelligent fixes
- Git commit/push automation
- Works on any branch (no main branch restriction)

**Requirements:**
- `gh` CLI installed and authenticated
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- `ANTHROPIC_API_KEY` environment variable

See [docs/claude-code-github-actions.md](./docs/claude-code-github-actions.md) for full documentation.

---

## Spec-Driven Development with spec-workflow-mcp

This project integrates [spec-workflow-mcp](https://github.com/Pimzino/spec-workflow-mcp) for structured, approval-based specification workflow aligned with DDD principles.

### Overview

spec-workflow-mcp provides a specification-driven development workflow:
- **Structured Workflow**: Requirements → Design → Tasks
- **Approval Process**: Built-in approval and revision tracking
- **Real-time Dashboard**: Visual progress monitoring
- **Task Progress Tracking**: Visual progress bars and detailed status

### Quick Start

```bash
# Start the dashboard (optional, for visual monitoring)
npm run spec:dashboard

# In Claude Code, use natural language:
# - "Create a spec for user authentication feature"
# - "List all specs"
# - "Execute task 1.2 in spec user-auth"
```

### Spec Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  1. Create      │────▶│  2. Design      │────▶│  3. Approve     │
│  Requirements   │     │  Specification  │     │  Spec           │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  6. Complete    │◀────│  5. Validate    │◀────│  4. Implement   │
│  Spec           │     │  Architecture   │     │  Tasks          │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

#### 1. Create Requirements
Define requirements using natural language with Claude Code. The spec-workflow-mcp will generate structured specifications.

#### 2. Design Specification
The system creates detailed design documents with tasks organized by DDD layers.

#### 3. Approve Specification
Review and approve the specification before implementation. Revisions are tracked.

#### 4. Implementation
Follow DDD layer order:
1. **Domain Layer First** - Entities, Value Objects, Aggregates, Events
2. **Application Layer** - Use Cases, Commands, Queries
3. **Infrastructure Layer** - Repository implementations, External services
4. **Interface Layer** - Controllers, API endpoints

#### 5. Validation
Run architecture validation before completing: `npm run validate:layers`

#### 6. Complete Specification
Mark spec as complete after all tasks are done.

### Task-to-Layer Mapping

| Layer | Task Focus | Key Guidelines |
|-------|------------|----------------|
| Domain | Entities, Value Objects, Aggregates, Events | NO outer layer imports, pure business logic |
| Application | Use Cases, Commands, Queries | Orchestrate domain, handle transactions |
| Infrastructure | Repositories, External services | Implement domain interfaces |
| Interface | Controllers, DTOs, API endpoints | Handle HTTP, validate input |

### Natural Language Commands

| Command | Description |
|---------|-------------|
| "Create a spec for [feature]" | Create new specification |
| "List all specs" | Show all specifications and their status |
| "Show spec [name]" | Display specific specification details |
| "Execute task [id] in spec [name]" | Execute a specific task |
| "Approve spec [name]" | Approve a specification for implementation |

### Directory Structure

```
.spec-workflow/
├── approvals/      # Approval tracking files
├── archive/        # Archived specifications
├── specs/          # Active specifications
├── steering/       # Workflow management files
├── templates/      # Spec templates
└── user-templates/ # Custom user templates
```

### Dashboard

Access the real-time dashboard for visual progress monitoring:

```bash
npm run spec:dashboard
# Opens at http://localhost:5000
```

---

**Last Updated**: 2026-01-01
**Version**: 3.0.0

---

## Docker Integration (Testing & Validation)

- テスト用イメージ: `Dockerfile.test`
- Compose: `docker-compose.test.yml`（`test-runner`, `integration-test`, `test-db`）
- 主なコマンド:
  - `npm run docker:build` — テストイメージをビルド
  - `npm run docker:test` — ユニット+統合テストを Docker で実行
  - `npm run docker:check` — lint / typecheck / dockerテスト / audit / outdated を一括実行しレポート生成
- レポート: `reports/*.json`（`scripts/docker-problem-detector.sh` が生成）
- 速い検証: `npm run docker:test:unit`（ドメイン・アプリ層の高速チェック用）
- フック: `.claude/hooks/docker_test.sh`（pre_commit）、`.claude/hooks/docker_lint_and_test.sh`（PostToolUse）
