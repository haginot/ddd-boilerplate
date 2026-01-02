#!/bin/bash
# Auto-Fix Script - Analyzes CI failures and uses Claude Code to fix them
# Usage: ./scripts/ci-monitor/auto-fix.sh --run-id <run_id> [--branch <branch>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
RUN_ID=""
BRANCH=""
DRY_RUN=false
MAX_ATTEMPTS=3

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

show_help() {
    cat << EOF
Auto-Fix Script - Analyzes CI failures and uses Claude Code to fix them

Usage: $0 --run-id <run_id> [OPTIONS]

Required:
    --run-id <id>       GitHub Actions run ID to analyze

Options:
    --branch <name>     Branch name (default: current branch)
    --dry-run           Analyze only, don't apply fixes
    --help              Show this help message

Environment Variables:
    ANTHROPIC_API_KEY   Required for Claude Code

Examples:
    $0 --run-id 12345678
    $0 --run-id 12345678 --dry-run
    $0 --run-id 12345678 --branch feature/my-branch
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --run-id)
            RUN_ID="$2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [[ -z "$RUN_ID" ]]; then
    log_error "Run ID is required"
    show_help
    exit 1
fi

if [[ -z "$BRANCH" ]]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

# Create temp directory for logs
TEMP_DIR=$(mktemp -d)
FAILURE_LOG="$TEMP_DIR/failure-log.md"
PROMPT_FILE="$TEMP_DIR/prompt.md"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

collect_failure_info() {
    log_step "Collecting failure information for run: $RUN_ID"

    # Get workflow run details
    local run_info=$(gh run view "$RUN_ID" --json name,conclusion,headBranch,event,createdAt,jobs 2>/dev/null)

    if [[ -z "$run_info" ]]; then
        log_error "Could not fetch run information"
        return 1
    fi

    local workflow_name=$(echo "$run_info" | jq -r '.name')
    local event=$(echo "$run_info" | jq -r '.event')
    local created_at=$(echo "$run_info" | jq -r '.createdAt')

    cat > "$FAILURE_LOG" << EOF
# CI Failure Report

## Workflow Information
- **Workflow:** $workflow_name
- **Run ID:** $RUN_ID
- **Branch:** $BRANCH
- **Event:** $event
- **Created:** $created_at

## Failed Jobs

EOF

    # Get failed jobs
    local failed_jobs=$(gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/jobs" --jq '.jobs[] | select(.conclusion == "failure") | {id, name, conclusion}' 2>/dev/null)

    if [[ -z "$failed_jobs" ]]; then
        log_warning "No failed jobs found"
        echo "No failed jobs found in this run." >> "$FAILURE_LOG"
        return 0
    fi

    # Collect logs for each failed job
    gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/jobs" --jq '.jobs[] | select(.conclusion == "failure") | .id' 2>/dev/null | while read -r job_id; do
        local job_name=$(gh api "repos/{owner}/{repo}/actions/jobs/$job_id" --jq '.name' 2>/dev/null)

        echo "### Job: $job_name" >> "$FAILURE_LOG"
        echo "" >> "$FAILURE_LOG"
        echo '```' >> "$FAILURE_LOG"

        # Get job logs (last 200 lines to capture errors)
        gh run view "$RUN_ID" --log-failed 2>/dev/null | grep -A 1000 "$job_name" | head -200 >> "$FAILURE_LOG" || true

        echo '```' >> "$FAILURE_LOG"
        echo "" >> "$FAILURE_LOG"
    done

    # Also get the raw failed logs
    echo "## Raw Failed Logs (last 300 lines)" >> "$FAILURE_LOG"
    echo "" >> "$FAILURE_LOG"
    echo '```' >> "$FAILURE_LOG"
    gh run view "$RUN_ID" --log-failed 2>/dev/null | tail -300 >> "$FAILURE_LOG" || true
    echo '```' >> "$FAILURE_LOG"

    log_success "Failure information collected"
}

generate_prompt() {
    log_step "Generating Claude Code prompt"

    cat > "$PROMPT_FILE" << 'EOF'
CI/CDパイプラインが失敗しました。以下の手順で問題を分析し、修正してください。

## 分析手順

1. まず `failure-log.md` を読んで失敗の原因を特定してください
2. エラーメッセージから根本原因を特定してください
3. 関連するソースファイルを読んで問題箇所を確認してください

## よくある失敗パターンと対処法

### TypeScript型エラー
- `exactOptionalPropertyTypes` エラー: オプショナルプロパティの型に `undefined` を追加
- 型の不一致: インターフェースと実装の型を一致させる

### ESLintエラー
- 設定ファイルなし: `.eslintrc.js` を確認・作成
- ルール違反: コードを修正してルールに準拠

### テスト失敗
- アサーションエラー: テストまたは実装を修正
- モック不足: 必要なモックを追加

### 依存関係エラー
- Node.jsバージョン: `package.json` の `engines` を確認
- パッケージ不足: `npm install` で解決

## 重要な制約

このプロジェクトはDDD（ドメイン駆動設計）とClean Architectureに従っています：

- **Domain層**: 外部依存なし、ビジネスロジックのみ
- **Application層**: Domainのみ依存可、ユースケース実装
- **Infrastructure層**: Domainインターフェースを実装
- **Interface層**: 外部とのやり取り（API、CLI等）

レイヤー間の依存関係ルールを必ず遵守してください。

## 作業

1. 問題を分析
2. 必要なファイルを修正
3. 修正内容を説明

修正が完了したら、何を修正したか簡潔に説明してください。
EOF

    # Append failure log content
    echo "" >> "$PROMPT_FILE"
    echo "## 失敗ログ" >> "$PROMPT_FILE"
    echo "" >> "$PROMPT_FILE"
    cat "$FAILURE_LOG" >> "$PROMPT_FILE"

    log_success "Prompt generated"
}

run_claude_code() {
    log_step "Running Claude Code for auto-fix"

    if $DRY_RUN; then
        log_warning "Dry run mode - showing prompt only"
        echo ""
        echo "========== PROMPT =========="
        cat "$PROMPT_FILE"
        echo "============================"
        return 0
    fi

    # Check if Claude Code is available
    if ! command -v claude &> /dev/null; then
        log_error "Claude Code CLI is not installed"
        log_info "Install with: npm install -g @anthropic-ai/claude-code"
        log_info "Falling back to manual prompt display..."
        echo ""
        echo "========== MANUAL FIX REQUIRED =========="
        echo "Copy this prompt to Claude Code:"
        echo ""
        cat "$PROMPT_FILE"
        echo ""
        echo "========================================="
        return 1
    fi

    # Copy failure log to project root for Claude to read
    cp "$FAILURE_LOG" "$PROJECT_ROOT/failure-log.md"

    # Run Claude Code with the prompt
    log_info "Starting Claude Code..."
    cd "$PROJECT_ROOT"

    # Use claude with the prompt (non-interactive mode)
    claude --print "$PROMPT_FILE" 2>&1 || {
        log_warning "Claude Code exited with non-zero status"
    }

    # Clean up temp file
    rm -f "$PROJECT_ROOT/failure-log.md"
}

check_and_commit_fixes() {
    log_step "Checking for fixes to commit"

    cd "$PROJECT_ROOT"

    # Check if there are any changes
    if [[ -z $(git status --porcelain) ]]; then
        log_info "No changes detected"
        return 0
    fi

    log_info "Changes detected:"
    git status --short

    if $DRY_RUN; then
        log_warning "Dry run mode - not committing"
        return 0
    fi

    # Stage and commit changes
    git add -A
    git commit -m "fix: auto-fix CI failures from run $RUN_ID

Automated fix applied by CI Monitor + Claude Code

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>" || {
        log_warning "Nothing to commit or commit failed"
        return 0
    }

    log_success "Changes committed"

    # Push changes
    log_step "Pushing changes to $BRANCH"
    git push origin "$BRANCH" || {
        log_error "Failed to push changes"
        return 1
    }

    log_success "Changes pushed successfully"
}

main() {
    echo ""
    log_info "=========================================="
    log_info "Auto-Fix Started"
    log_info "Run ID: $RUN_ID"
    log_info "Branch: $BRANCH"
    log_info "Mode: $(if $DRY_RUN; then echo 'Dry Run'; else echo 'Live'; fi)"
    log_info "=========================================="
    echo ""

    # Step 1: Collect failure information
    collect_failure_info || {
        log_error "Failed to collect failure information"
        exit 1
    }

    # Step 2: Generate prompt
    generate_prompt

    # Step 3: Run Claude Code
    run_claude_code || {
        log_warning "Claude Code analysis completed with warnings"
    }

    # Step 4: Check and commit fixes
    check_and_commit_fixes

    echo ""
    log_info "=========================================="
    log_info "Auto-Fix Completed"
    log_info "=========================================="
}

main
