#!/bin/bash
# =============================================================================
# Check Orchestrator Needed Script
# =============================================================================
# Checks if ddd-orchestrator has been invoked for current development task
# Used by Claude Code hooks to ensure orchestrator usage
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# File being edited (passed as argument or from environment)
EDITED_FILE="${1:-$CLAUDE_EDIT_FILE}"

# Check if this is a src/ file that requires orchestrator
if [[ "$EDITED_FILE" =~ ^src/.*(domain|application|infrastructure|interface)/.*.ts$ ]]; then
    # This is a DDD layer file - orchestrator should be involved

    echo "=========================================="
    echo "DDD Layer File Modification Detected"
    echo "=========================================="
    echo ""
    echo "File: $EDITED_FILE"
    echo ""
    echo "This file is in a DDD layer directory."
    echo ""
    echo "RECOMMENDATION: Ensure ddd-orchestrator is coordinating this change."
    echo ""
    echo "If orchestrator is not active, invoke it:"
    echo "  @ddd-orchestrator, please coordinate: [your task description]"
    echo ""
    echo "Available specialist agents:"
    echo "  - ddd-architect-reviewer (architecture review)"
    echo "  - domain-engineer (Domain layer)"
    echo "  - application-engineer (Application layer)"
    echo "  - infrastructure-engineer (Infrastructure layer)"
    echo "  - test-specialist (Testing)"
    echo ""
    echo "=========================================="

    # Return success but with warning message
    # We don't block the operation, just remind
    exit 0
fi

# Not a DDD layer file - no orchestrator needed
exit 0
