#!/bin/bash
# =============================================================================
# Agent Invocation Rate Measurement Script
# =============================================================================
# Measures ddd-orchestrator invocation rate from Claude Code session logs
# Outputs a Markdown report with statistics
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_ROOT/reports"
REPORT_FILE="$REPORT_DIR/agent-invocation-rate.md"
LOG_DIR="$PROJECT_ROOT/.claude/logs"

# Create directories if needed
mkdir -p "$REPORT_DIR"
mkdir -p "$LOG_DIR"

# Development task patterns (keywords that indicate a development task)
DEV_TASK_PATTERNS=(
    "implement"
    "create"
    "add"
    "build"
    "develop"
    "fix"
    "debug"
    "resolve"
    "update"
    "modify"
    "refactor"
    "optimize"
    "test"
    "aggregate"
    "entity"
    "value object"
    "domain"
    "use case"
    "repository"
    "handler"
    "command"
    "query"
)

# Agent invocation patterns
ORCHESTRATOR_PATTERN="ddd-orchestrator"
ARCHITECT_PATTERN="ddd-architect-reviewer"
DOMAIN_PATTERN="domain-engineer"
APPLICATION_PATTERN="application-engineer"
INFRASTRUCTURE_PATTERN="infrastructure-engineer"
TEST_PATTERN="test-specialist"

echo "=========================================="
echo "Agent Invocation Rate Measurement"
echo "=========================================="
echo ""

# Initialize counters
TOTAL_DEV_TASKS=0
ORCHESTRATOR_INVOCATIONS=0
ARCHITECT_INVOCATIONS=0
DOMAIN_INVOCATIONS=0
APPLICATION_INVOCATIONS=0
INFRASTRUCTURE_INVOCATIONS=0
TEST_INVOCATIONS=0

# Check if log files exist
if [ -d "$LOG_DIR" ] && [ "$(ls -A $LOG_DIR 2>/dev/null)" ]; then
    echo "Analyzing log files in $LOG_DIR..."

    # Count development tasks and invocations from logs
    for log_file in "$LOG_DIR"/*.log "$LOG_DIR"/*.jsonl 2>/dev/null; do
        if [ -f "$log_file" ]; then
            # Count development task patterns
            for pattern in "${DEV_TASK_PATTERNS[@]}"; do
                count=$(grep -ci "$pattern" "$log_file" 2>/dev/null || echo 0)
                TOTAL_DEV_TASKS=$((TOTAL_DEV_TASKS + count))
            done

            # Count agent invocations
            ORCHESTRATOR_INVOCATIONS=$((ORCHESTRATOR_INVOCATIONS + $(grep -ci "$ORCHESTRATOR_PATTERN" "$log_file" 2>/dev/null || echo 0)))
            ARCHITECT_INVOCATIONS=$((ARCHITECT_INVOCATIONS + $(grep -ci "$ARCHITECT_PATTERN" "$log_file" 2>/dev/null || echo 0)))
            DOMAIN_INVOCATIONS=$((DOMAIN_INVOCATIONS + $(grep -ci "$DOMAIN_PATTERN" "$log_file" 2>/dev/null || echo 0)))
            APPLICATION_INVOCATIONS=$((APPLICATION_INVOCATIONS + $(grep -ci "$APPLICATION_PATTERN" "$log_file" 2>/dev/null || echo 0)))
            INFRASTRUCTURE_INVOCATIONS=$((INFRASTRUCTURE_INVOCATIONS + $(grep -ci "$INFRASTRUCTURE_PATTERN" "$log_file" 2>/dev/null || echo 0)))
            TEST_INVOCATIONS=$((TEST_INVOCATIONS + $(grep -ci "$TEST_PATTERN" "$log_file" 2>/dev/null || echo 0)))
        fi
    done
else
    echo "No log files found in $LOG_DIR"
    echo "This script analyzes Claude Code session logs."
    echo ""
    echo "To generate logs, enable logging in Claude Code settings"
    echo "or manually track agent invocations."

    # Use placeholder values for demonstration
    TOTAL_DEV_TASKS=0
    ORCHESTRATOR_INVOCATIONS=0
fi

# Calculate rates
if [ $TOTAL_DEV_TASKS -gt 0 ]; then
    ORCHESTRATOR_RATE=$(echo "scale=1; ($ORCHESTRATOR_INVOCATIONS * 100) / $TOTAL_DEV_TASKS" | bc)
else
    ORCHESTRATOR_RATE="N/A"
fi

TOTAL_AGENT_INVOCATIONS=$((ORCHESTRATOR_INVOCATIONS + ARCHITECT_INVOCATIONS + DOMAIN_INVOCATIONS + APPLICATION_INVOCATIONS + INFRASTRUCTURE_INVOCATIONS + TEST_INVOCATIONS))

# Generate report
cat > "$REPORT_FILE" << EOF
# Agent Invocation Rate Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Project:** DDD Boilerplate

---

## Summary

| Metric | Value | Target |
|--------|-------|--------|
| Total Development Tasks Detected | $TOTAL_DEV_TASKS | - |
| Orchestrator Invocations | $ORCHESTRATOR_INVOCATIONS | 90%+ of dev tasks |
| **Orchestrator Invocation Rate** | **${ORCHESTRATOR_RATE}%** | **90%+** |

---

## Agent Invocation Breakdown

| Agent | Invocations | Description |
|-------|-------------|-------------|
| ddd-orchestrator | $ORCHESTRATOR_INVOCATIONS | Primary coordinator |
| ddd-architect-reviewer | $ARCHITECT_INVOCATIONS | Architecture reviews |
| domain-engineer | $DOMAIN_INVOCATIONS | Domain layer implementation |
| application-engineer | $APPLICATION_INVOCATIONS | Application layer implementation |
| infrastructure-engineer | $INFRASTRUCTURE_INVOCATIONS | Infrastructure implementation |
| test-specialist | $TEST_INVOCATIONS | Test implementation |
| **Total** | **$TOTAL_AGENT_INVOCATIONS** | - |

---

## Analysis

### Invocation Rate Assessment

EOF

# Add assessment based on rate
if [ "$ORCHESTRATOR_RATE" != "N/A" ]; then
    RATE_INT=$(echo "$ORCHESTRATOR_RATE" | cut -d. -f1)
    if [ "$RATE_INT" -ge 90 ]; then
        echo "**Status: EXCELLENT** - Orchestrator invocation rate meets target (90%+)" >> "$REPORT_FILE"
    elif [ "$RATE_INT" -ge 70 ]; then
        echo "**Status: GOOD** - Orchestrator invocation rate is acceptable (70-89%)" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Recommendations:**" >> "$REPORT_FILE"
        echo "- Review missed invocations to identify patterns" >> "$REPORT_FILE"
        echo "- Consider adding more trigger keywords to orchestrator description" >> "$REPORT_FILE"
    else
        echo "**Status: NEEDS IMPROVEMENT** - Orchestrator invocation rate below target (<70%)" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Recommendations:**" >> "$REPORT_FILE"
        echo "- Verify orchestrator description includes all relevant keywords" >> "$REPORT_FILE"
        echo "- Enable hooks for automatic triggering" >> "$REPORT_FILE"
        echo "- Review CLAUDE.md for clear agent selection protocol" >> "$REPORT_FILE"
        echo "- Consider explicit @ddd-orchestrator invocations" >> "$REPORT_FILE"
    fi
else
    echo "**Status: NO DATA** - Insufficient data to calculate invocation rate" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Next Steps:**" >> "$REPORT_FILE"
    echo "- Enable Claude Code logging to track agent invocations" >> "$REPORT_FILE"
    echo "- Run development tasks and re-run this analysis" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## Development Task Keywords Tracked

The following keywords are used to identify development tasks:

\`\`\`
${DEV_TASK_PATTERNS[*]}
\`\`\`

---

## How to Improve Invocation Rate

### Layer 1: Intelligent Automatic (Target: 70-80%)
- Ensure orchestrator description includes comprehensive trigger keywords
- Use ultra-proactive descriptions for all agents

### Layer 2: Hooks-based Trigger (Target: +10-15%)
- Enable \`.claude/settings.json\` hooks for src/ file changes
- Use hookify rules to prompt orchestrator usage

### Layer 3: Explicit Invocation (Fallback: 100%)
- Document \`@ddd-orchestrator\` pattern in CLAUDE.md
- Train users to explicitly invoke for complex tasks

---

## Commands

\`\`\`bash
# Re-run this measurement
npm run measure:agents

# View latest report
cat reports/agent-invocation-rate.md
\`\`\`

---

*Report generated by measure-agent-invocation.sh*
EOF

echo ""
echo "Report generated: $REPORT_FILE"
echo ""
echo "Summary:"
echo "- Development tasks detected: $TOTAL_DEV_TASKS"
echo "- Orchestrator invocations: $ORCHESTRATOR_INVOCATIONS"
echo "- Invocation rate: ${ORCHESTRATOR_RATE}%"
echo ""
