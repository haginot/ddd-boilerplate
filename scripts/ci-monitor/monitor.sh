#!/bin/bash
# CI Monitor Script - Watches GitHub Actions and triggers auto-fix on failure
# Usage: ./scripts/ci-monitor/monitor.sh [--once] [--branch <branch>] [--interval <seconds>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default configuration
POLL_INTERVAL=${CI_MONITOR_INTERVAL:-60}
BRANCH=""
RUN_ONCE=false
LAST_PROCESSED_RUN=""
PROCESSED_RUNS_FILE="$SCRIPT_DIR/.processed_runs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

show_help() {
    cat << EOF
CI Monitor - Watches GitHub Actions and triggers auto-fix on failure

Usage: $0 [OPTIONS]

Options:
    --once              Run once and exit (don't loop)
    --branch <name>     Monitor specific branch (default: current branch)
    --interval <secs>   Poll interval in seconds (default: 60)
    --help              Show this help message

Environment Variables:
    CI_MONITOR_INTERVAL     Default poll interval (seconds)
    ANTHROPIC_API_KEY       Required for Claude Code auto-fix

Examples:
    $0                          # Monitor current branch continuously
    $0 --once                   # Check once and exit
    $0 --branch main            # Monitor main branch
    $0 --interval 30            # Poll every 30 seconds
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --once)
            RUN_ONCE=true
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
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Get current branch if not specified
if [[ -z "$BRANCH" ]]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

# Initialize processed runs file
touch "$PROCESSED_RUNS_FILE"

is_run_processed() {
    local run_id=$1
    grep -q "^${run_id}$" "$PROCESSED_RUNS_FILE" 2>/dev/null
}

mark_run_processed() {
    local run_id=$1
    echo "$run_id" >> "$PROCESSED_RUNS_FILE"
    # Keep only last 100 processed runs
    tail -100 "$PROCESSED_RUNS_FILE" > "$PROCESSED_RUNS_FILE.tmp"
    mv "$PROCESSED_RUNS_FILE.tmp" "$PROCESSED_RUNS_FILE"
}

check_workflows() {
    log_info "Checking workflows for branch: $BRANCH"

    # Get recent workflow runs
    local runs=$(gh run list --branch "$BRANCH" --limit 10 --json databaseId,conclusion,status,name,headBranch,createdAt 2>/dev/null)

    if [[ -z "$runs" || "$runs" == "[]" ]]; then
        log_info "No workflow runs found"
        return 0
    fi

    # Parse and check each run
    echo "$runs" | jq -c '.[]' | while read -r run; do
        local run_id=$(echo "$run" | jq -r '.databaseId')
        local conclusion=$(echo "$run" | jq -r '.conclusion')
        local status=$(echo "$run" | jq -r '.status')
        local name=$(echo "$run" | jq -r '.name')
        local created_at=$(echo "$run" | jq -r '.createdAt')

        # Skip if already processed
        if is_run_processed "$run_id"; then
            continue
        fi

        # Skip if still running
        if [[ "$status" != "completed" ]]; then
            log_info "Workflow '$name' is still running..."
            continue
        fi

        # Mark as processed
        mark_run_processed "$run_id"

        if [[ "$conclusion" == "failure" ]]; then
            log_error "Workflow FAILED: $name (Run ID: $run_id)"
            log_info "Triggering auto-fix..."

            # Call auto-fix script
            "$SCRIPT_DIR/auto-fix.sh" --run-id "$run_id" --branch "$BRANCH"

            if [[ $? -eq 0 ]]; then
                log_success "Auto-fix completed successfully"
            else
                log_warning "Auto-fix could not resolve all issues"
            fi
        elif [[ "$conclusion" == "success" ]]; then
            log_success "Workflow PASSED: $name"
        else
            log_info "Workflow '$name' concluded with: $conclusion"
        fi
    done
}

main() {
    log_info "=========================================="
    log_info "CI Monitor Started"
    log_info "Branch: $BRANCH"
    log_info "Poll Interval: ${POLL_INTERVAL}s"
    log_info "Mode: $(if $RUN_ONCE; then echo 'Single run'; else echo 'Continuous'; fi)"
    log_info "=========================================="

    # Check prerequisites
    if ! command -v gh &> /dev/null; then
        log_error "gh CLI is not installed"
        exit 1
    fi

    if ! command -v claude &> /dev/null; then
        log_warning "Claude Code CLI not found - auto-fix will be limited"
    fi

    if $RUN_ONCE; then
        check_workflows
    else
        while true; do
            check_workflows
            log_info "Sleeping for ${POLL_INTERVAL}s..."
            sleep "$POLL_INTERVAL"
        done
    fi
}

main
