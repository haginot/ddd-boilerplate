---
name: require-spec-workflow
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: src/.*\.(ts|tsx)$
  - field: new_text
    operator: regex_match
    pattern: (class|function|interface|type|export|const)
---

**spec-workflow-mcp 必須**

`src/` 配下のコードを編集・作成しようとしています。

このプロジェクトでは **spec-workflow-mcp** を使った仕様駆動開発が必須です。

**実装前に確認してください:**

1. **既存の spec があるか確認**
   - `mcp__spec-workflow__spec-status` で該当する spec を確認
   - または `.spec-workflow/specs/` ディレクトリを確認

2. **spec がない場合は作成**
   - `mcp__spec-workflow__spec-workflow-guide` でワークフローを確認
   - Requirements → Design → Tasks の順で spec を作成
   - ユーザーの承認を得てから実装開始

3. **spec がある場合**
   - 該当タスクを確認し、tasks.md に記載されたタスクに従って実装
   - 実装完了後は `mcp__spec-workflow__log-implementation` で記録

**ワークフロー:**
```
Requirements → Design → Approve → Implement → Validate → Complete
```

spec なしでの実装は禁止されています。まず spec を確認・作成してください。
