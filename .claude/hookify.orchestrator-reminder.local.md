---
name: orchestrator-reminder
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: src/.*(domain|application|infrastructure|interface)/.*\.ts$
---

**DDD Orchestrator 確認**

`src/` 配下の DDD レイヤーファイルを編集しようとしています。

**ddd-orchestrator は起動されていますか？**

このプロジェクトでは、すべての開発タスクで `ddd-orchestrator` を経由することが推奨されています。

**確認事項:**
1. ddd-orchestrator が起動済み -> そのまま実装を続行
2. 起動されていない場合 -> 以下を実行

```
@ddd-orchestrator, please coordinate: [実装内容の説明]
```

**オーケストレーターの役割:**
- タスクを DDD レイヤー別に分解
- 適切な専門エージェントに委譲
- レイヤー依存関係の検証
- 実装結果の統合

**利用可能な専門エージェント:**
- `ddd-architect-reviewer` - アーキテクチャレビュー
- `domain-engineer` - Domain 層実装
- `application-engineer` - Application 層実装
- `infrastructure-engineer` - Infrastructure 層実装
- `test-specialist` - テスト作成

直接実装を開始する前に、オーケストレーターの起動を確認してください。
