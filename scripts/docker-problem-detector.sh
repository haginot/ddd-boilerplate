#!/bin/bash
set -e

REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"

checks=(
  "lint:npm run lint"
  "typecheck:npm run typecheck"
  "docker:test:npm run docker:test"
  "audit:npm audit --audit-level=moderate"
  "outdated:npm outdated"
)

start_all=$(date +%s%3N)
results=""
summary_total=0
summary_failed=0

run_check() {
  local name="$1"; shift
  local cmd="$@"
  local started=$(date +%s%3N)
  echo "🔎 Running $name..."
  set +e
  eval $cmd
  local code=$?
  set -e
  local ended=$(date +%s%3N)
  local duration=$((ended-started))
  summary_total=$((summary_total+1))
  if [[ $code -ne 0 ]]; then
    summary_failed=$((summary_failed+1))
    echo "❌ $name failed (exit $code)"
  else
    echo "✅ $name passed"
  fi
  # Append JSON snippet
  results+="\n    \"$name\": {\n      \"exit_code\": $code,\n      \"duration_ms\": $duration\n    },"
}

for entry in "${checks[@]}"; do
  IFS=":" read -r name cmd <<< "$entry"
  run_check "$name" $cmd
done

end_all=$(date +%s%3N)
summary_passed=$((summary_total-summary_failed))

# Trim trailing comma
results=${results%,}

timestamp=$(date +"%Y%m%d_%H%M%S")
report_path="$REPORT_DIR/${timestamp}.json"

cat > "$report_path" << EOF_JSON
{
  "timestamp": "$timestamp",
  "summary": {
    "total_checks": $summary_total,
    "passed": $summary_passed,
    "failed": $summary_failed,
    "duration_ms": $((end_all-start_all))
  },
  "checks": {${results}\n  }
}
EOF_JSON

if [[ $summary_failed -gt 0 ]]; then
  echo "❌ Some checks failed. See $report_path"
  exit 1
fi

echo "✅ All checks passed. Report: $report_path"
