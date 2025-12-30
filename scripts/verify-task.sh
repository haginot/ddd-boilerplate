#!/bin/bash
# Verify task completion in Docker environment
set -e

echo "🐳 Building test image..."
npm run docker:build

echo "🧪 Running Docker checks..."
npm run docker:check

echo "✅ Task verification succeeded."
