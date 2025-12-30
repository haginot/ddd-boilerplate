#!/bin/bash
set -e

REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"

# Note: outdated uses "|| true" because npm outdated returns 1 when updates are available
checks=(
  "lint|npm run lint"
  "typecheck|npm run typecheck"
  "docker_test|npm run docker:test"
  "audit|npm audit --audit-level=moderate || true"
  "outdated|npm outdated || true"
)

start_all=$(date +%s%3N)
declare -a check_results=()
summary_total=0
summary_failed=0

run_check() {
  local name="$1"; shift
  local cmd="$*"
  local started=$(date +%s%3N)
  echo "🔎 Running $name..."
  set +e
  eval "$cmd" > /dev/null 2>&1
  local code=$?
  set -e
  local ended=$(date +%s%3N)
  local duration=$((ended - started))
  summary_total=$((summary_total + 1))
  if [[ $code -ne 0 ]]; then
    summary_failed=$((summary_failed + 1))
    echo "❌ $name failed (exit $code)"
  else
    echo "✅ $name passed"
  fi
  check_results+=("\"$name\": { \"exit_code\": $code, \"duration_ms\": $duration }")
}

for entry in "${checks[@]}"; do
  IFS="|" read -r name cmd <<< "$entry"
  run_check "$name" "$cmd"
done

end_all=$(date +%s%3N)
summary_passed=$((summary_total - summary_failed))

timestamp=$(date +"%Y%m%d_%H%M%S")
report_path="$REPORT_DIR/${timestamp}.json"

# Build JSON using printf for proper formatting
{
  printf '{\n'
  printf '  "timestamp": "%s",\n' "$timestamp"
  printf '  "summary": {\n'
  printf '    "total_checks": %d,\n' "$summary_total"
  printf '    "passed": %d,\n' "$summary_passed"
  printf '    "failed": %d,\n' "$summary_failed"
  printf '    "duration_ms": %d\n' "$((end_all - start_all))"
  printf '  },\n'
  printf '  "checks": {\n'
  for i in "${!check_results[@]}"; do
    if [[ $i -lt $((${#check_results[@]} - 1)) ]]; then
      printf '    %s,\n' "${check_results[$i]}"
    else
      printf '    %s\n' "${check_results[$i]}"
    fi
  done
  printf '  }\n'
  printf '}\n'
} > "$report_path"

if [[ $summary_failed -gt 0 ]]; then
  echo "❌ Some checks failed. See $report_path"
  exit 1
fi

echo "✅ All checks passed. Report: $report_path"
