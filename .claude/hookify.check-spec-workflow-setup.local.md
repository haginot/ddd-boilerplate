---
name: check-spec-workflow-setup
enabled: true
event: prompt
conditions:
  - field: user_prompt
    operator: regex_match
    pattern: .+
---

**spec-workflow-mcp 環境チェック**

このプロジェクトでは spec-workflow-mcp が必須です。

**環境が正しくセットアップされているか確認してください:**

1. **MCP サーバー設定の確認**
   - `.mcp.json` に `spec-workflow` が設定されているか確認
   - 設定がない場合は以下をユーザーに案内:
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

2. **ディレクトリ構造の確認**
   - `.spec-workflow/` ディレクトリが存在するか確認
   - 存在しない場合、spec-workflow-mcp を初回実行すると自動作成される

3. **ツールの動作確認**
   - `mcp__spec-workflow__spec-workflow-guide` が呼び出せるか確認
   - エラーが発生する場合は、Claude Code を再起動してMCPサーバーを再接続

**セットアップが必要な場合の手順:**

```bash
# 1. .mcp.json を確認・作成
# 2. Claude Code を再起動
# 3. spec-workflow ツールが利用可能か確認
```

環境が整っていない場合は、実装作業を開始する前にセットアップを完了してください。
