#!/bin/bash
# Watch and Fix - Interactive CI monitoring with Claude Code integration
# Usage: ./scripts/ci-monitor/watch-and-fix.sh [--auto] [--branch <branch>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
BRANCH=""
AUTO_FIX=false
POLL_INTERVAL=30

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

print_header() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║           CI Monitor & Auto-Fix with Claude Code              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    local status=$1
    local message=$2
    case $status in
        "success") echo -e "${GREEN}✓${NC} $message" ;;
        "failure") echo -e "${RED}✗${NC} $message" ;;
        "running") echo -e "${YELLOW}◐${NC} $message" ;;
        "info")    echo -e "${BLUE}ℹ${NC} $message" ;;
        "fix")     echo -e "${CYAN}🔧${NC} $message" ;;
    esac
}

show_help() {
    cat << EOF
Watch and Fix - Interactive CI monitoring with Claude Code integration

Usage: $0 [OPTIONS]

Options:
    --auto              Automatically fix failures without prompting
    --branch <name>     Monitor specific branch (default: current branch)
    --interval <secs>   Poll interval in seconds (default: 30)
    --help              Show this help message

Examples:
    $0                  # Interactive mode, monitor current branch
    $0 --auto           # Auto-fix mode
    $0 --branch main    # Monitor main branch
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_FIX=true
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --interval)
            POLL_INTERVAL="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [[ -z "$BRANCH" ]]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

get_workflow_status() {
    gh run list --branch "$BRANCH" --limit 6 --json databaseId,conclusion,status,name,createdAt,headSha 2>/dev/null || echo "[]"
}

display_workflows() {
    local workflows=$1

    echo -e "${BOLD}Branch:${NC} $BRANCH"
    echo -e "${BOLD}Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "${BOLD}Recent Workflow Runs:${NC}"
    echo "─────────────────────────────────────────────────────────────────"

    if [[ "$workflows" == "[]" || -z "$workflows" ]]; then
        echo "  No workflow runs found"
        return
    fi

    echo "$workflows" | jq -r '.[] | "\(.status)|\(.conclusion)|\(.name)|\(.databaseId)|\(.createdAt)"' | while IFS='|' read -r status conclusion name run_id created_at; do
        local display_time=$(echo "$created_at" | cut -d'T' -f2 | cut -d'.' -f1)
        local status_icon

        if [[ "$status" == "completed" ]]; then
            case $conclusion in
                "success") status_icon="${GREEN}✓${NC}" ;;
                "failure") status_icon="${RED}✗${NC}" ;;
                "cancelled") status_icon="${YELLOW}○${NC}" ;;
                *) status_icon="${BLUE}?${NC}" ;;
            esac
        else
            status_icon="${YELLOW}◐${NC}"
        fi

        printf "  %b %-40s %s  [%s]\n" "$status_icon" "$name" "$display_time" "$run_id"
    done

    echo "─────────────────────────────────────────────────────────────────"
}

get_latest_failure() {
    local workflows=$1
    echo "$workflows" | jq -r '[.[] | select(.status == "completed" and .conclusion == "failure")][0] | .databaseId // empty'
}

prompt_fix() {
    local run_id=$1

    if $AUTO_FIX; then
        return 0
    fi

    echo ""
    echo -e "${YELLOW}${BOLD}CI Failure Detected!${NC}"
    echo -e "Run ID: ${CYAN}$run_id${NC}"
    echo ""
    echo "Options:"
    echo "  [f] Fix with Claude Code"
    echo "  [v] View failure logs"
    echo "  [s] Skip this failure"
    echo "  [q] Quit"
    echo ""
    read -p "Choice [f/v/s/q]: " choice

    case $choice in
        f|F) return 0 ;;
        v|V)
            gh run view "$run_id" --log-failed | less
            prompt_fix "$run_id"
            ;;
        s|S) return 1 ;;
        q|Q) exit 0 ;;
        *) prompt_fix "$run_id" ;;
    esac
}

run_auto_fix() {
    local run_id=$1

    echo ""
    print_status "fix" "Starting auto-fix for run $run_id..."
    echo ""

    # Collect failure logs
    local failure_log="$PROJECT_ROOT/failure-log.md"

    echo "# CI Failure Log" > "$failure_log"
    echo "" >> "$failure_log"
    echo "## Run Information" >> "$failure_log"
    echo "- Run ID: $run_id" >> "$failure_log"
    echo "- Branch: $BRANCH" >> "$failure_log"
    echo "- Time: $(date)" >> "$failure_log"
    echo "" >> "$failure_log"
    echo "## Failed Logs" >> "$failure_log"
    echo '```' >> "$failure_log"
    gh run view "$run_id" --log-failed 2>/dev/null | tail -500 >> "$failure_log" || true
    echo '```' >> "$failure_log"

    # Create prompt for Claude
    local prompt="CI/CDが失敗しました。failure-log.md を読んで問題を分析し、修正してください。

このプロジェクトはDDD/Clean Architectureに従っています。CLAUDE.md を参照してルールを確認してください。

修正後、変更内容を説明してください。"

    print_status "info" "Launching Claude Code..."
    echo ""

    # Run Claude Code
    cd "$PROJECT_ROOT"

    if command -v claude &> /dev/null; then
        # Use Claude Code CLI
        echo "$prompt" | claude --dangerously-skip-permissions 2>&1 || true
    else
        echo -e "${YELLOW}Claude Code CLI not found.${NC}"
        echo ""
        echo "To install: npm install -g @anthropic-ai/claude-code"
        echo ""
        echo "Manual fix required. Failure log saved to: failure-log.md"
        echo ""
        echo "Prompt:"
        echo "─────────────────────────────────────────"
        echo "$prompt"
        echo "─────────────────────────────────────────"
    fi

    # Clean up
    rm -f "$failure_log"

    # Check for changes
    if [[ -n $(git status --porcelain) ]]; then
        echo ""
        print_status "success" "Changes detected!"
        git status --short
        echo ""

        if $AUTO_FIX; then
            commit_changes "$run_id"
        else
            read -p "Commit and push changes? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                commit_changes "$run_id"
            fi
        fi
    else
        print_status "info" "No changes made"
    fi
}

commit_changes() {
    local run_id=$1

    git add -A
    git commit -m "fix: auto-fix CI failures from run $run_id

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>" || {
        print_status "info" "Nothing to commit"
        return
    }

    git push origin "$BRANCH" && {
        print_status "success" "Changes pushed to $BRANCH"
    } || {
        print_status "failure" "Failed to push changes"
    }
}

main() {
    print_header

    echo -e "${BOLD}Configuration:${NC}"
    echo "  Branch: $BRANCH"
    echo "  Auto-fix: $AUTO_FIX"
    echo "  Poll interval: ${POLL_INTERVAL}s"
    echo ""
    echo -e "Press ${BOLD}Ctrl+C${NC} to stop"
    echo ""

    local last_failure_id=""

    while true; do
        print_header

        # Get workflow status
        local workflows=$(get_workflow_status)
        display_workflows "$workflows"

        # Check for new failures
        local latest_failure=$(get_latest_failure "$workflows")

        if [[ -n "$latest_failure" && "$latest_failure" != "$last_failure_id" ]]; then
            if prompt_fix "$latest_failure"; then
                run_auto_fix "$latest_failure"
                last_failure_id="$latest_failure"
            else
                last_failure_id="$latest_failure"
            fi
        fi

        echo ""
        echo -e "${BLUE}Next check in ${POLL_INTERVAL}s...${NC} (Ctrl+C to stop)"
        sleep "$POLL_INTERVAL"
    done
}

main
