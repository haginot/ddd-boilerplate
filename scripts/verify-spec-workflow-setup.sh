#!/bin/bash
# spec-workflow-mcp 環境セットアップ検証スクリプト

set -e

echo "=========================================="
echo "spec-workflow-mcp 環境チェック"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# 1. .mcp.json の存在確認
echo "1. .mcp.json の確認..."
if [ -f ".mcp.json" ]; then
    echo "   ✅ .mcp.json が存在します"

    # spec-workflow 設定の確認
    if grep -q "spec-workflow" .mcp.json; then
        echo "   ✅ spec-workflow の設定が存在します"
    else
        echo "   ❌ spec-workflow の設定がありません"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "   ❌ .mcp.json が存在しません"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 2. .spec-workflow ディレクトリの確認
echo "2. .spec-workflow ディレクトリの確認..."
if [ -d ".spec-workflow" ]; then
    echo "   ✅ .spec-workflow ディレクトリが存在します"

    # サブディレクトリの確認
    for dir in approvals specs steering templates; do
        if [ -d ".spec-workflow/$dir" ]; then
            echo "   ✅ .spec-workflow/$dir が存在します"
        else
            echo "   ⚠️  .spec-workflow/$dir が存在しません (初回実行時に作成されます)"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
else
    echo "   ⚠️  .spec-workflow ディレクトリが存在しません"
    echo "      (spec-workflow ツールの初回実行時に自動作成されます)"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 3. npm スクリプトの確認
echo "3. npm スクリプトの確認..."
if [ -f "package.json" ]; then
    if grep -q "spec:dashboard" package.json; then
        echo "   ✅ spec:dashboard スクリプトが設定されています"
    else
        echo "   ⚠️  spec:dashboard スクリプトが設定されていません"
        echo "      推奨: \"spec:dashboard\": \"npx @pimzino/spec-workflow-mcp@latest --dashboard\""
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "   ⚠️  package.json が存在しません"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 4. hookify ルールの確認
echo "4. Hookify ルールの確認..."
HOOKIFY_COUNT=$(ls -1 .claude/hookify.*.local.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$HOOKIFY_COUNT" -gt 0 ]; then
    echo "   ✅ $HOOKIFY_COUNT 個の hookify ルールが設定されています"
    ls -1 .claude/hookify.*.local.md 2>/dev/null | while read file; do
        name=$(grep "^name:" "$file" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
        enabled=$(grep "^enabled:" "$file" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
        if [ "$enabled" = "true" ]; then
            echo "      ✅ $name (有効)"
        else
            echo "      ⚠️  $name (無効)"
        fi
    done
else
    echo "   ⚠️  hookify ルールが設定されていません"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 5. npx の動作確認
echo "5. npx の動作確認..."
if command -v npx &> /dev/null; then
    echo "   ✅ npx が利用可能です"
else
    echo "   ❌ npx が見つかりません (Node.js をインストールしてください)"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 結果サマリー
echo "=========================================="
echo "結果サマリー"
echo "=========================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ すべてのチェックに合格しました！"
    echo "   spec-workflow-mcp を使用する準備ができています。"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  $WARNINGS 件の警告があります"
    echo "   基本的な機能は動作しますが、一部の設定が不足しています。"
else
    echo "❌ $ERRORS 件のエラーがあります"
    echo "   以下の手順でセットアップを完了してください:"
    echo ""
    echo "   1. .mcp.json に spec-workflow 設定を追加:"
    echo "      {"
    echo "        \"mcpServers\": {"
    echo "          \"spec-workflow\": {"
    echo "            \"command\": \"npx\","
    echo "            \"args\": [\"-y\", \"@pimzino/spec-workflow-mcp@latest\", \".\"]"
    echo "          }"
    echo "        }"
    echo "      }"
    echo ""
    echo "   2. Claude Code を再起動"
    echo ""
fi
echo ""

exit $ERRORS
