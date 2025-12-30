#!/bin/bash
# Task Architecture Validator Hook
# ============================================
# Validates that task implementations follow DDD architecture principles.
# This hook runs architecture validation when task status changes.
#
# Usage: ./task-architecture-validator.sh [task_id] [files_changed]
# ============================================

set -e

TASK_ID=${1:-""}
FILES_CHANGED=${2:-""}
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Task Architecture Validator"
echo "================================"

# Function to check layer dependencies
check_layer_dependencies() {
    local file=$1
    local layer=""
    local violations=0
    
    # Determine which layer the file belongs to
    if [[ $file == *"/domain/"* ]]; then
        layer="domain"
    elif [[ $file == *"/application/"* ]]; then
        layer="application"
    elif [[ $file == *"/infrastructure/"* ]]; then
        layer="infrastructure"
    elif [[ $file == *"/interface/"* ]]; then
        layer="interface"
    else
        return 0
    fi
    
    echo -e "  Checking $layer layer: $file"
    
    # Domain layer should NOT import from outer layers
    if [[ $layer == "domain" ]]; then
        # Check for forbidden imports
        if grep -qE "from ['\"].*/(application|infrastructure|interface)/" "$file" 2>/dev/null; then
            echo -e "  ${RED}❌ Domain layer violation: importing from outer layer${NC}"
            violations=$((violations + 1))
        fi
        
        # Check for infrastructure concerns
        if grep -qE "(import.*from ['\"](express|fastify|typeorm|prisma|mongoose))" "$file" 2>/dev/null; then
            echo -e "  ${RED}❌ Domain layer violation: infrastructure dependency${NC}"
            violations=$((violations + 1))
        fi
    fi
    
    # Application layer should NOT import from infrastructure/interface
    if [[ $layer == "application" ]]; then
        if grep -qE "from ['\"].*/(infrastructure|interface)/" "$file" 2>/dev/null; then
            echo -e "  ${RED}❌ Application layer violation: importing from outer layer${NC}"
            violations=$((violations + 1))
        fi
    fi
    
    if [[ $violations -eq 0 ]]; then
        echo -e "  ${GREEN}✓ Layer dependencies OK${NC}"
    fi
    
    return $violations
}

# Function to check naming conventions
check_naming_conventions() {
    local file=$1
    local filename=$(basename "$file")
    local violations=0
    
    # Domain events should end with Event
    if [[ $file == *"/domain/events/"* ]] && [[ ! $filename =~ .*Event\.ts$ ]]; then
        echo -e "  ${YELLOW}⚠ Warning: Domain event file should end with 'Event.ts': $filename${NC}"
    fi
    
    # Repositories in domain should be interfaces
    if [[ $file == *"/domain/"* ]] && [[ $filename =~ .*Repository\.ts$ ]]; then
        if ! grep -qE "^export (interface|abstract class)" "$file" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠ Warning: Repository in domain should be an interface${NC}"
        fi
    fi
    
    return 0
}

# Main validation logic
total_violations=0

if [[ -n "$FILES_CHANGED" ]]; then
    # Validate specific files
    for file in $FILES_CHANGED; do
        if [[ -f "$file" ]] && [[ $file == *.ts ]]; then
            echo ""
            echo "📄 Validating: $file"
            
            check_layer_dependencies "$file"
            total_violations=$((total_violations + $?))
            
            check_naming_conventions "$file"
        fi
    done
else
    # Validate all TypeScript files in src
    echo "Validating all source files..."
    
    # Run npm validation if available
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        if grep -q '"validate:layers"' "$PROJECT_ROOT/package.json"; then
            echo ""
            echo "Running npm run validate:layers..."
            cd "$PROJECT_ROOT"
            npm run validate:layers 2>/dev/null || total_violations=$((total_violations + 1))
        fi
    fi
fi

echo ""
echo "================================"

if [[ $total_violations -gt 0 ]]; then
    echo -e "${RED}❌ Architecture validation failed with $total_violations violation(s)${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Architecture validation passed${NC}"
    exit 0
fi
