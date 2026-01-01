---
name: feature-request-spec
enabled: true
event: prompt
conditions:
  - field: user_prompt
    operator: regex_match
    pattern: (実装|作成|追加|機能|feature|implement|create|add|build|develop|新しい|新規)
---

**Spec Workflow 開始が必要です**

ユーザーから機能実装・作成の指示を受けました。

**このプロジェクトでは spec-workflow-mcp の使用が必須です。**

**必ず以下の手順に従ってください:**

1. **spec-workflow-guide を読み込む**
   ```
   mcp__spec-workflow__spec-workflow-guide を呼び出す
   ```

2. **既存 spec を確認**
   ```
   mcp__spec-workflow__spec-status で関連する spec を確認
   ```

3. **spec がない場合は作成**
   - Requirements document を作成
   - Design document を作成
   - Tasks を定義
   - ユーザーに承認を依頼

4. **承認後に実装開始**
   - DDD レイヤー順に実装 (Domain → Application → Infrastructure → Interface)
   - 各タスク完了後に implementation log を記録

**禁止事項:**
- spec なしでのコード実装
- 承認なしでの実装開始
- spec に記載されていないタスクの実装

まず `mcp__spec-workflow__spec-workflow-guide` を呼び出してワークフローを開始してください。
