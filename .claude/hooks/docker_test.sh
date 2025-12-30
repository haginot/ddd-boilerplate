#!/bin/bash
set -e

COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.test.yml}

echo "🐳 Running unit tests in Docker..."
docker-compose -f "$COMPOSE_FILE" run --rm test-runner

echo "✅ Docker unit tests passed"
