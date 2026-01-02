# DDD Boilerplate

Domain-Driven Design (DDD) と Clean Architecture のボイラープレート。TypeScript/Node.js プロジェクト向けに最適化され、Claude Code との統合により AI 支援開発をサポートします。

## 📋 目次

- [機能概要](#機能概要)
- [アーキテクチャ](#アーキテクチャ)
- [クイックスタート](#クイックスタート)
- [環境構築](#環境構築)
- [組み込み機能](#組み込み機能)
- [開発ワークフロー](#開発ワークフロー)
- [ドキュメント](#ドキュメント)

## 🎯 機能概要

このボイラープレートには以下の機能が組み込まれています：

- **Clean Architecture**: 4層アーキテクチャと明確な依存関係ルール
- **DDD パターン**: Entity, Value Object, Aggregate Root, Domain Event, Repository
- **Claude Code 統合**: Subagents, Skills, Hooks による自動化された開発支援
- **Spec-Workflow**: 承認ベースの仕様駆動開発ワークフロー
- **Pre-commit Hooks**: Husky + lint-staged + commitlint による自動品質チェック
- **Just**: コマンドランナーによる統一された開発ワークフロー
- **Claude Flow**: Swarm、メモリ、アーキテクチャ検証
- **MCP Servers**: 複数の MCP サーバーによる拡張機能
- **Docker**: テスト環境と CI/CD 統合
- **GitHub Actions**: 自動化された CI/CD パイプライン

## 🏗️ アーキテクチャ

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

### 依存関係ルール

依存関係は**内側のみ**を指します：

- Interface → Application → Domain
- Infrastructure → Domain (implements interfaces)
- ❌ Domain は外側のレイヤーから**決して**インポートしない

## 🚀 クイックスタート

### 前提条件

- **Node.js** >= 18.0.0
- **npm** または **yarn**
- **Git**
- **Claude Code** (推奨、AI 支援開発用)
- **Docker** (オプション、テスト環境用)
- **Just** (オプション、コマンドランナー用)

### インストール

```bash
# リポジトリをクローン
git clone <repository-url>
cd ddd-boilerplate

# 依存関係をインストール
npm install

# 開発ツールをセットアップ（Just, Act, pre-commit）
npm run setup

# プロジェクトをビルド
npm run build
```

## ⚙️ 環境構築

### 1. 環境変数の設定

環境変数は2つの方法で設定できます：

#### 方法1: プロジェクトレベルの設定（.env ファイル）

プロジェクトルートに `.env` ファイルを作成し、推奨環境変数を設定します：

```bash
# .env.example をコピー
cp .env.example .env

# 必要に応じて値を編集
# 特に CLAUDE_CODE_MAX_OUTPUT_TOKENS は推奨値に設定することを推奨
```

**Node.js アプリケーションで環境変数を使用する場合**:

アプリケーションコードで環境変数を使用する場合は、`dotenv` パッケージをインストールして使用してください：

```bash
# dotenv をインストール
npm install dotenv

# アプリケーションのエントリーポイントで読み込み
# src/index.ts
import 'dotenv/config';
// または
import dotenv from 'dotenv';
dotenv.config();
```

#### 方法2: シェルレベルの設定（推奨）

Claude Code の動作を最適化するために、シェル設定ファイルに環境変数を追加することを推奨します：

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

**推奨環境変数** (`.env.example` を参照):

| 環境変数                        | デフォルト値 | 推奨値                                     | 説明                                             | 設定方法                              |
| ------------------------------- | ------------ | ------------------------------------------ | ------------------------------------------------ | ------------------------------------- |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 4096         | 16384                                      | 出力トークンの最大数。長い応答が必要な場合に増加 | シェル設定ファイル（推奨）または .env |
| `NODE_ENV`                      | -            | development                                | Node.js 環境                                     | .env                                  |
| `DATABASE_URL`                  | -            | postgres://test:test@localhost:5432/testdb | テストデータベース接続URL                        | .env                                  |
| `PORT`                          | -            | 3000                                       | API サーバーポート                               | .env                                  |
| `API_BASE_URL`                  | -            | http://localhost:3000                      | API ベースURL                                    | .env                                  |

**注意**:

- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` は Claude Code が使用するため、シェル設定ファイルに設定することを推奨します
- トークン数を増やすと、API コストが増加する可能性があります
- `.env` ファイルは `.gitignore` に含まれているため、Git にコミットされません

### 2. Claude Code の設定

#### MCP サーバーの確認

`.mcp.json` に以下の MCP サーバーが設定されていることを確認：

- `memory`: 永続的なメモリストレージ
- `filesystem`: ファイルシステムアクセス
- `sequential-thinking`: 段階的な推論
- `claude-flow`: Claude Flow MCP サーバー
- `spec-workflow`: 仕様駆動開発ワークフロー

#### Claude Code の再起動

環境変数を設定した後、**Claude Code を再起動**して MCP サーバーを再接続してください。

### 3. Git Hooks のセットアップ

Pre-commit hooks は `npm install` 時に自動的にインストールされます（`prepare` スクリプト経由）。

手動でセットアップする場合：

```bash
npm run pre-commit:install
```

### 4. 開発ツールのセットアップ

```bash
# Just, Act, pre-commit をインストール
npm run setup
```

## 🔧 組み込み機能

### 1. Subagents (サブエージェント)

Claude Code の Subagents 機能により、専門的なエージェントが自動的に呼び出されます。

#### 利用可能なエージェント

| エージェント              | 役割                       | 用途                                |
| ------------------------- | -------------------------- | ----------------------------------- |
| `ddd-orchestrator`        | 主要コーディネーター       | すべての開発タスク                  |
| `ddd-architect-reviewer`  | アーキテクチャガーディアン | 設計レビュー、準拠チェック          |
| `domain-engineer`         | ドメイン専門家             | Aggregates, Entities, Value Objects |
| `application-engineer`    | アプリケーション専門家     | Use Cases, Commands, Queries        |
| `infrastructure-engineer` | インフラ専門家             | Repositories, 外部サービス          |
| `test-specialist`         | テスト専門家               | Unit, Integration, E2E テスト       |

#### 自動呼び出し

`ddd-orchestrator` は以下の場合に自動的に呼び出されます：

- 機能実装のリクエスト
- `src/` ディレクトリのコード変更
- アーキテクチャの議論
- ドメインモデリングのリクエスト

詳細は `CLAUDE.md` の「Agent Selection Protocol」セクションを参照してください。

### 2. Spec-Workflow (仕様駆動開発)

[spec-workflow-mcp](https://github.com/Pimzino/spec-workflow-mcp) を使用した構造化された承認ベースの仕様ワークフロー。

#### ワークフロー

```
Requirements → Design → Approve → Implement → Validate → Complete
```

#### クイックスタート

```bash
# ダッシュボードを起動（オプション）
npm run spec:dashboard

# Claude Code で自然言語を使用：
# - "Create a spec for user authentication feature"
# - "List all specs"
# - "Execute task 1.2 in spec user-auth"
```

#### 重要なルール

**このプロジェクトでは spec-workflow-mcp の使用が必須です。**

- ✅ コード実装前に必ず spec を作成・確認すること
- ✅ spec なしでの実装は禁止
- ✅ ワークフローを必ず遵守すること

詳細は `CLAUDE.md` の「MANDATORY: Spec-Workflow-MCP Usage」セクションを参照してください。

### 3. Pre-commit Hooks

**Husky** + **lint-staged** + **commitlint** による自動品質チェック。

#### コミット時の自動チェック

`git commit` を実行すると、以下のチェックが自動的に実行されます：

1. **lint-staged**: ESLint + Prettier をステージされたファイルに実行
2. **TypeScript 型チェック**: `npm run typecheck`
3. **アーキテクチャ検証**: `npm run validate:layers`
4. **コミットメッセージ検証**: Conventional Commits 形式

#### コミットメッセージ形式

コミットメッセージは [Conventional Commits](https://www.conventionalcommits.org/) に従う必要があります：

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**例**:

```bash
git commit -m "feat: add user authentication"
git commit -m "fix(api): handle null response"
git commit -m "docs: update README"
```

### 4. Just - コマンドランナー

[Just](https://github.com/casey/just) を使用した統一された開発ワークフロー。

#### インストール

```bash
# macOS
brew install just

# Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# またはセットアップスクリプトを使用
npm run setup
```

#### 主要ワークフロー

| コマンド          | 説明                                                                  |
| ----------------- | --------------------------------------------------------------------- |
| `just ci`         | 完全な CI パイプライン（format → lint → test → docker → integration） |
| `just check`      | クイックな pre-commit チェック                                        |
| `just pre-commit` | Pre-commit ワークフロー（git hook で使用）                            |

#### ステップバイステップワークフロー

```bash
just format          # 1. コードフォーマット (Prettier)
just lint            # 2. ESLint
just typecheck       # 3. TypeScript 型チェック
just test-unit       # 4. ユニットテスト
just test-docker     # 5. Docker 環境テスト
just test-integration # 6. 統合テスト
just gh-actions      # 7. ローカル GitHub Actions 検証
```

#### すべてのコマンド

```bash
just --list          # 利用可能なすべてのレシピを表示
just help            # 詳細なヘルプを表示
```

詳細は `justfile` を参照してください。

### 5. Claude Flow

Claude Flow による Swarm、メモリ、アーキテクチャ検証機能。

#### メモリ命名空間

- `domain`: エンティティ、VO、集約、ドメインイベント
- `application`: ユースケース、コマンド、クエリ
- `infrastructure`: リポジトリ実装、マッパー、外部サービス
- `interface`: コントローラ、DTO、API
- `architecture`: レイヤー決定、パターン適用履歴
- `specs`: Spec ワークフロー情報

#### 設定ファイル

詳細な設定は `.flowconfig.json` を参照してください。

詳細は `FLOW.md` を参照してください。

### 6. MCP Servers

以下の MCP サーバーが設定されています：

- **memory**: 永続的なメモリストレージ（ドメインコンテキストとユビキタス言語）
- **filesystem**: プロジェクト管理のためのファイルシステムアクセス
- **sequential-thinking**: 複雑なアーキテクチャ決定のための段階的推論
- **claude-flow**: Swarm、メモリ、アーキテクチャ検証のための Claude Flow MCP サーバー
- **spec-workflow**: DDD/Clean Architecture プロジェクト向けの承認プロセス付き仕様駆動開発ワークフロー

設定は `.mcp.json` を参照してください。

### 7. Hooks

Claude Code の Hooks による自動検証。

#### PreToolUse Hooks

コードを書き込む前に実行：

- **レイヤー依存関係の検証**: ドメインレイヤーが外側のレイヤーをインポートしていないかチェック
- **命名規則の検証**: 一貫した命名パターンを確保
- **Orchestrator チェック**: 開発タスクで orchestrator が必要かチェック

#### PostToolUse Hooks

コードを書き込んだ後に実行：

- **ドメインイベントの検証**: イベントの命名と構造を検証
- **アーキテクチャ検証**: Claude Flow による厳密なアーキテクチャ検証

設定は `.claude/settings.json` を参照してください。

### 8. Docker

テスト環境と CI/CD 統合。

#### テスト用イメージ

- `Dockerfile.test`: テスト用 Docker イメージ
- `docker-compose.test.yml`: テスト環境の Compose 設定

#### 主要コマンド

```bash
# テストイメージをビルド
npm run docker:build

# ユニット+統合テストを Docker で実行
npm run docker:test

# 問題検出とレポート生成
npm run docker:check

# ユニットテストのみ（高速）
npm run docker:test:unit
```

#### レポート

`reports/*.json` にレポートが生成されます（`scripts/docker-problem-detector.sh` が生成）。

### 9. GitHub Actions

自動化された CI/CD パイプライン。

#### 利用可能なワークフロー

| ワークフロー             | トリガー                    | 目的               |
| ------------------------ | --------------------------- | ------------------ |
| `claude-code-issue.yml`  | `claude-dev` ラベルの Issue | 自動実装           |
| `claude-code-test.yml`   | PR/push                     | クラウドテスト     |
| `claude-code-review.yml` | PR                          | 自動コードレビュー |
| `docker-ci.yml`          | PR/push                     | Docker テスト      |
| `task-validation.yml`    | PR                          | タスク検証         |

#### ローカルでの GitHub Actions テスト

```bash
# 特定のワークフローを実行
just gh-actions workflow="claude-code-test.yml"

# 利用可能なワークフローをリスト
just gh-actions-list

# ドライラン（実行内容を表示）
just gh-actions-dry
```

詳細は `docs/claude-code-github-actions.md` を参照してください。

## 💻 開発ワークフロー

### 1. 新機能の実装

```bash
# 1. Spec を作成（必須）
# Claude Code で: "Create a spec for [feature name]"

# 2. Spec を承認
# Claude Code で: "Approve spec [name]"

# 3. 実装を開始（Orchestrator が自動的に呼び出される）
# Claude Code で: "Implement task 1.1 in spec [name]"

# 4. アーキテクチャを検証
npm run validate:layers

# 5. テストを実行
npm test

# 6. コミット（pre-commit hooks が自動実行）
git commit -m "feat: implement [feature name]"
```

### 2. コード品質チェック

```bash
# クイックチェック（pre-commit 相当）
just check

# 完全な CI パイプライン
just ci

# 個別チェック
just format          # コードフォーマット
just lint            # ESLint
just typecheck       # TypeScript 型チェック
just test-unit       # ユニットテスト
```

### 3. 新しい Bounded Context の作成

1. コンテキストディレクトリ構造を作成：

```bash
mkdir -p src/[context]/{domain,application,infrastructure,interface}
mkdir -p src/[context]/domain/events
mkdir -p src/[context]/application/{commands,queries,handlers}
mkdir -p src/[context]/infrastructure/mappers
```

2. ドメインモデルを定義：
   - `domain/` にエンティティと値オブジェクトを作成
   - `domain/` にリポジトリインターフェースを定義
   - `domain/events/` にドメインイベントを作成

3. `application/` にユースケースを実装：
   - コマンドとクエリを作成
   - ハンドラーを実装

4. `infrastructure/` にインフラを追加：
   - リポジトリを実装
   - ドメイン ↔ 永続化のマッパーを追加

5. `interface/` に API エンドポイントを作成

詳細は `CLAUDE.md` を参照してください。

## 📚 ドキュメント

- [CLAUDE.md](./CLAUDE.md) - プロジェクトコンテキストとコーディングガイドライン
- [FLOW.md](./FLOW.md) - Claude Flow ガイド
- [docs/ubiquitous-language.md](./docs/ubiquitous-language.md) - ドメイン語彙
- [docs/context-map.md](./docs/context-map.md) - Bounded Context の関係
- [docs/claude-code-github-actions.md](./docs/claude-code-github-actions.md) - GitHub Actions 統合
- [docs/claude-flow-setup.md](./docs/claude-flow-setup.md) - Claude Flow セットアップ
- [docs/memory-namespaces.md](./docs/memory-namespaces.md) - メモリ命名空間

## 🔍 トラブルシューティング

### MCP サーバーが見つからない

1. `.mcp.json` の存在を確認
2. Claude Code を再起動（MCP サーバーの再接続）
3. `npm run spec:verify` で spec-workflow の設定を確認

### Pre-commit hooks が動作しない

```bash
# Git hooks を再インストール
npm run pre-commit:install

# 手動で実行してテスト
npm run pre-commit
```

### Docker テストが失敗する

```bash
# Docker の問題を検出
npm run docker:check

# Docker 環境をクリーンアップ
npm run docker:clean

# 再ビルド
npm run docker:build
```

### Just コマンドが見つからない

```bash
# Just をインストール
npm run setup

# または手動でインストール
brew install just  # macOS
```

### 環境変数が読み込まれない

1. `.env` ファイルがプロジェクトルートに存在することを確認
2. Claude Code を再起動
3. シェルで環境変数を確認: `echo $CLAUDE_CODE_MAX_OUTPUT_TOKENS`

## 📝 ベストプラクティス

### Domain Layer

- ✅ エンティティと値オブジェクトにドメインロジックを保持
- ✅ オブジェクト作成にファクトリーメソッドを使用
- ✅ ドメインオブジェクトで不変条件を検証
- ✅ 状態変更でドメインイベントを発行
- ❌ インフラストラクチャやアプリケーションレイヤーからインポートしない

### Application Layer

- ✅ クラスごとに1つのユースケース
- ✅ ドメインオブジェクトをオーケストレート、ビジネスロジックは実装しない
- ✅ 入出力に DTO を使用
- ✅ イベントパブリッシャーを通じてドメインイベントを発行

### Infrastructure Layer

- ✅ ドメインレイヤーのリポジトリインターフェースを実装
- ✅ ドメイン ↔ 永続化の変換にマッパーを使用
- ✅ ドメインオブジェクトを返す、データベースモデルは返さない

詳細は `CLAUDE.md` の「Best Practices」セクションを参照してください。

## 🤖 Claude による初期環境構築

Claude Code を使用してこのプロジェクトを開始する際は、以下の手順に従ってください。

### 自動環境構築手順

Claude Code に以下の指示をすることで、環境構築を自動化できます：

```
このプロジェクトの初期環境構築を実行してください。
以下の手順に従って、すべての設定を完了させてください：

1. 依存関係のインストール
   - npm install を実行
   - 依存関係のインストールが完了したことを確認

2. 環境変数の設定
   - .env.example が存在することを確認
   - .env ファイルが存在しない場合は、.env.example をコピーして作成
   - CLAUDE_CODE_MAX_OUTPUT_TOKENS が 16384 に設定されていることを確認

3. 開発ツールのセットアップ
   - npm run setup を実行して Just, Act, pre-commit をインストール
   - インストールが完了したことを確認

4. Git Hooks のセットアップ
   - npm run pre-commit:install を実行
   - .husky/pre-commit と .husky/commit-msg が存在することを確認

5. MCP サーバーの確認
   - .mcp.json が存在し、以下のサーバーが設定されていることを確認：
     * memory
     * filesystem
     * sequential-thinking
     * claude-flow
     * spec-workflow

6. プロジェクトのビルド
   - npm run build を実行
   - ビルドが成功したことを確認

7. アーキテクチャ検証
   - npm run validate:layers を実行
   - 検証が成功したことを確認

8. セットアップ完了の確認
   - すべての手順が完了したことを報告
   - 次のステップ（spec の作成など）について案内
```

### 手動環境構築

自動環境構築を使用しない場合は、以下のコマンドを順番に実行してください：

```bash
# 1. 依存関係のインストール
npm install

# 2. 環境変数の設定
cp .env.example .env
# .env ファイルを編集して必要に応じて値を変更

# 3. 開発ツールのセットアップ
npm run setup

# 4. Git Hooks のセットアップ（自動的にインストールされますが、確認）
npm run pre-commit:install

# 5. プロジェクトのビルド
npm run build

# 6. アーキテクチャ検証
npm run validate:layers

# 7. Claude Code を再起動（MCP サーバーを再接続）
# Claude Code を再起動してください
```

### 環境構築後の確認事項

環境構築が完了したら、以下を確認してください：

- [ ] `.env` ファイルが存在し、推奨環境変数が設定されている
- [ ] `node_modules` がインストールされている
- [ ] `.husky/pre-commit` と `.husky/commit-msg` が存在する
- [ ] `just --version` で Just がインストールされていることを確認
- [ ] `npm run spec:verify` で spec-workflow の設定が正しいことを確認
- [ ] Claude Code を再起動して MCP サーバーが接続されていることを確認

### 次のステップ

環境構築が完了したら、以下のステップに進んでください：

1. **Spec の作成**: Claude Code で "Create a spec for [feature name]" と指示して、最初の spec を作成
2. **Bounded Context の作成**: 新しい Bounded Context を作成してドメインモデルを定義
3. **開発の開始**: spec-workflow に従って実装を開始

詳細は「開発ワークフロー」セクションを参照してください。

## 📄 ライセンス

MIT
