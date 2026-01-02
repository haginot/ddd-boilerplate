# DDD Boilerplate - Development Workflow
# Usage: just <recipe>
# See all recipes: just --list

# Default recipe - show available commands
default:
    @just --list

# =============================================================================
# Configuration
# =============================================================================

# Project settings
project := "ddd-boilerplate"
node_version := "20"

# Docker settings
docker_compose := "docker-compose -f docker-compose.test.yml"
docker_image := "ddd-boilerplate-test"

# Colors for output
green := '\033[0;32m'
yellow := '\033[1;33m'
red := '\033[0;31m'
blue := '\033[0;34m'
nc := '\033[0m'

# =============================================================================
# Main Workflow (Full CI Pipeline)
# =============================================================================

# Run the complete CI workflow (format → lint → typecheck → unit → docker → integration → gh-actions)
ci: format lint typecheck test-unit test-docker test-integration validate-architecture
    @echo "{{green}}✅ Full CI workflow completed successfully!{{nc}}"

# Quick check before commit (faster than full CI)
check: format-check lint typecheck validate-architecture
    @echo "{{green}}✅ Quick check passed!{{nc}}"

# Pre-commit workflow (called by git hook)
pre-commit: lint-staged typecheck validate-architecture
    @echo "{{green}}✅ Pre-commit checks passed!{{nc}}"

# =============================================================================
# Step 1: Code Formatting
# =============================================================================

# Format all code with Prettier
format:
    @echo "{{blue}}📝 Formatting code...{{nc}}"
    npm run format
    @echo "{{green}}✅ Code formatted{{nc}}"

# Check code formatting without making changes
format-check:
    @echo "{{blue}}📝 Checking code format...{{nc}}"
    npm run format:check
    @echo "{{green}}✅ Format check passed{{nc}}"

# =============================================================================
# Step 2: Linting
# =============================================================================

# Run ESLint on all TypeScript files
lint:
    @echo "{{blue}}🔍 Running ESLint...{{nc}}"
    npm run lint
    @echo "{{green}}✅ Lint passed{{nc}}"

# Run ESLint and auto-fix issues
lint-fix:
    @echo "{{blue}}🔧 Running ESLint with auto-fix...{{nc}}"
    npm run lint:fix
    @echo "{{green}}✅ Lint fix completed{{nc}}"

# Run lint-staged (for pre-commit)
lint-staged:
    @echo "{{blue}}📝 Running lint-staged...{{nc}}"
    npx lint-staged
    @echo "{{green}}✅ Staged files checked{{nc}}"

# =============================================================================
# Step 3: Type Checking
# =============================================================================

# Run TypeScript type check
typecheck:
    @echo "{{blue}}🔎 Running TypeScript type check...{{nc}}"
    npm run typecheck
    @echo "{{green}}✅ Type check passed{{nc}}"

# =============================================================================
# Step 4: Unit Tests
# =============================================================================

# Run unit tests locally
test-unit:
    @echo "{{blue}}🧪 Running unit tests...{{nc}}"
    npm run test:unit -- --passWithNoTests
    @echo "{{green}}✅ Unit tests passed{{nc}}"

# Run unit tests with coverage
test-unit-coverage:
    @echo "{{blue}}🧪 Running unit tests with coverage...{{nc}}"
    npm run test:coverage
    @echo "{{green}}✅ Unit tests with coverage completed{{nc}}"

# Run unit tests in watch mode
test-watch:
    npm run test:unit -- --watch

# =============================================================================
# Step 5: Docker Environment Tests
# =============================================================================

# Build Docker test image
docker-build:
    @echo "{{blue}}🐳 Building Docker test image...{{nc}}"
    npm run docker:build
    @echo "{{green}}✅ Docker image built{{nc}}"

# Run unit tests in Docker
test-docker: docker-build
    @echo "{{blue}}🐳 Running tests in Docker...{{nc}}"
    {{docker_compose}} run --rm test-runner
    @echo "{{green}}✅ Docker tests passed{{nc}}"

# Run API tests in Docker environment
test-api: docker-build
    @echo "{{blue}}🐳 Running API tests in Docker...{{nc}}"
    {{docker_compose}} run --rm api-test
    @echo "{{green}}✅ API tests passed{{nc}}"

# Start Docker test environment
docker-up:
    @echo "{{blue}}🐳 Starting Docker test environment...{{nc}}"
    {{docker_compose}} up -d test-db
    @echo "{{green}}✅ Docker environment started{{nc}}"

# Stop Docker test environment
docker-down:
    @echo "{{blue}}🐳 Stopping Docker test environment...{{nc}}"
    {{docker_compose}} down -v --remove-orphans
    @echo "{{green}}✅ Docker environment stopped{{nc}}"

# View Docker logs
docker-logs service="":
    {{docker_compose}} logs -f {{service}}

# =============================================================================
# Step 6: Integration Tests
# =============================================================================

# Run integration tests in Docker
test-integration: docker-build
    @echo "{{blue}}🔗 Running integration tests...{{nc}}"
    {{docker_compose}} run --rm integration-test
    @echo "{{green}}✅ Integration tests passed{{nc}}"

# Run all tests (unit + integration)
test-all: test-unit test-docker test-integration
    @echo "{{green}}✅ All tests passed{{nc}}"

# =============================================================================
# Step 7: GitHub Actions Local Verification
# =============================================================================

# Run GitHub Actions locally with act
gh-actions workflow="claude-code-test.yml":
    @echo "{{blue}}🎬 Running GitHub Actions locally ({{workflow}})...{{nc}}"
    @if command -v act > /dev/null 2>&1; then \
        act -W .github/workflows/{{workflow}} --container-architecture linux/amd64; \
    else \
        echo "{{yellow}}⚠️  'act' is not installed. Install with: brew install act{{nc}}"; \
        exit 1; \
    fi
    @echo "{{green}}✅ GitHub Actions verification passed{{nc}}"

# List available GitHub Actions workflows
gh-actions-list:
    @echo "{{blue}}Available GitHub Actions workflows:{{nc}}"
    @ls -1 .github/workflows/*.yml | xargs -I {} basename {}

# Run all GitHub Actions workflows locally
gh-actions-all:
    @echo "{{blue}}🎬 Running all GitHub Actions locally...{{nc}}"
    @for workflow in .github/workflows/*.yml; do \
        echo "{{yellow}}Running: $$(basename $$workflow){{nc}}"; \
        act -W $$workflow --container-architecture linux/amd64 || true; \
    done
    @echo "{{green}}✅ All GitHub Actions completed{{nc}}"

# Dry run GitHub Actions (show what would be executed)
gh-actions-dry workflow="claude-code-test.yml":
    @echo "{{blue}}📋 Dry run for {{workflow}}...{{nc}}"
    act -W .github/workflows/{{workflow}} -n --container-architecture linux/amd64

# =============================================================================
# Architecture Validation
# =============================================================================

# Validate DDD architecture (layer dependencies)
validate-architecture:
    @echo "{{blue}}🏗️ Validating DDD architecture...{{nc}}"
    npm run validate:layers
    @echo "{{green}}✅ Architecture validation passed{{nc}}"

# =============================================================================
# Development Helpers
# =============================================================================

# Install all dependencies
install:
    @echo "{{blue}}📦 Installing dependencies...{{nc}}"
    npm install
    @echo "{{green}}✅ Dependencies installed{{nc}}"

# Clean build artifacts
clean:
    @echo "{{blue}}🧹 Cleaning build artifacts...{{nc}}"
    npm run clean
    rm -rf coverage reports
    @echo "{{green}}✅ Clean completed{{nc}}"

# Full clean including node_modules and Docker
clean-all: clean docker-down
    @echo "{{blue}}🧹 Full clean...{{nc}}"
    rm -rf node_modules
    docker rmi {{docker_image}} 2>/dev/null || true
    @echo "{{green}}✅ Full clean completed{{nc}}"

# Build the project
build:
    @echo "{{blue}}🔨 Building project...{{nc}}"
    npm run build
    @echo "{{green}}✅ Build completed{{nc}}"

# Start development server
dev:
    npm run dev

# =============================================================================
# Git Workflow
# =============================================================================

# Create a conventional commit
commit message:
    @echo "{{blue}}📝 Creating commit...{{nc}}"
    git add -A
    git commit -m "{{message}}"
    @echo "{{green}}✅ Commit created{{nc}}"

# Push changes
push:
    @echo "{{blue}}📤 Pushing changes...{{nc}}"
    git push
    @echo "{{green}}✅ Push completed{{nc}}"

# Create and push with message
ship message: (commit message) push
    @echo "{{green}}🚀 Changes shipped!{{nc}}"

# =============================================================================
# Reports & Status
# =============================================================================

# Show project status
status:
    @echo "{{blue}}📊 Project Status{{nc}}"
    @echo "─────────────────────────────────────────"
    @echo "Branch: $$(git branch --show-current)"
    @echo "Node: $$(node -v)"
    @echo "npm: $$(npm -v)"
    @echo "─────────────────────────────────────────"
    @git status --short

# View latest test report
report:
    npm run report:latest

# Run docker health check
docker-check:
    npm run docker:check

# =============================================================================
# Help
# =============================================================================

# Show detailed help
help:
    @echo ""
    @echo "{{blue}}DDD Boilerplate - Development Workflow{{nc}}"
    @echo "========================================"
    @echo ""
    @echo "{{yellow}}Main Workflows:{{nc}}"
    @echo "  just ci              Run full CI pipeline"
    @echo "  just check           Quick pre-commit check"
    @echo "  just pre-commit      Pre-commit hook workflow"
    @echo ""
    @echo "{{yellow}}Step-by-Step:{{nc}}"
    @echo "  1. just format       Format code (Prettier)"
    @echo "  2. just lint         Run ESLint"
    @echo "  3. just test-unit    Run unit tests"
    @echo "  4. just test-docker  Run Docker tests"
    @echo "  5. just test-integration  Run integration tests"
    @echo "  6. just gh-actions   Run GitHub Actions locally"
    @echo ""
    @echo "{{yellow}}Docker:{{nc}}"
    @echo "  just docker-build    Build test image"
    @echo "  just docker-up       Start test environment"
    @echo "  just docker-down     Stop test environment"
    @echo ""
    @echo "{{yellow}}Development:{{nc}}"
    @echo "  just install         Install dependencies"
    @echo "  just dev             Start dev server"
    @echo "  just build           Build project"
    @echo "  just clean           Clean artifacts"
    @echo ""
    @echo "Run 'just --list' for all available recipes."
    @echo ""
