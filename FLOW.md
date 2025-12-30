# Claude Flow ガイド (DDD Boilerplate)

## 1. Swarm エージェント構成
- **Domain Expert Agent**: エンティティ/VO/集約境界の提案・生成
- **Architecture Guardian Agent**: レイヤ依存の検証と修正案提示
- **Test Engineer Agent**: 不変条件・イベント・リポジトリのテスト生成
- **Repository Specialist Agent**: リポジトリ実装とマッパー生成

## 2. メモリ命名空間
- `domain`: エンティティ、VO、集約、ドメインイベント
- `application`: ユースケース、コマンド、クエリ
- `infrastructure`: リポジトリ実装、マッパー、外部サービス
- `interface`: コントローラ、DTO、API
- `architecture`: レイヤ決定、パターン適用履歴

## 3. 推奨スキルと役割
- `ddd-entity-builder`: エンティティ/集約/VO の生成と不変条件整理
- `repository-generator`: ドメインIF＋インフラ実装＋マッパー
- `domain-event-publisher`: ドメインイベント生成と発火組み込み
- `architecture-guardian`: レイヤ違反検出と修正ガイド

## 4. ナチュラルランゲージ・トリガー例
- 「ユーザ集約を作って」「Order aggregate を生成して」
- 「リポジトリを実装して」「永続化コードを書いて」
- 「ドメインイベントを発火して」「OrderPlaced を追加して」
- 「アーキテクチャを検証して」「依存違反をチェックして」

## 5. 既存 CLAUDE.md との連携
- CLAUDE.md のガードレール（レイヤ境界/命名）を維持しつつ、Claude Flow スキルで DDD ボイラープレート生成を高速化。
- メモリへの格納時は `architecture` namespace を既定とし、重要決定事項を AgentDB/ReasoningBank に保存。

## 6. Hive-Mind / Swarm 運用
- `.swarm/hive-config.json` を参照し、Queen が Domain/Architecture/Test 各エージェントを調整。
- セッションは `.swarm/sessions` に保存し、長期の境界づくりに再利用。

## 7. 参考
- `docs/claude-flow-setup.md`
- `docs/memory-namespaces.md`
- `.claude/skills/*`
