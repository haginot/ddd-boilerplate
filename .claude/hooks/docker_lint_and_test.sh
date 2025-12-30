#!/bin/bash
set -e

COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.test.yml}

run_step() {
  local name="$1"; shift
  echo "🔎 $name..."
  "$@"
  echo "✅ $name passed"
}

run_step "Lint" npm run lint
run_step "Typecheck" npm run typecheck
run_step "Docker unit tests" docker-compose -f "$COMPOSE_FILE" run --rm test-runner
run_step "Docker integration tests" docker-compose -f "$COMPOSE_FILE" run --rm integration-test
run_step "Layer validation" npm run validate:layers
