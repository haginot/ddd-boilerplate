#!/bin/bash
# Setup script for development tools (just, act, pre-commit)
# Usage: ./scripts/setup-dev-tools.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  DDD Boilerplate - Dev Tools Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    CYGWIN*)    PLATFORM=Windows;;
    MINGW*)     PLATFORM=Windows;;
    *)          PLATFORM="Unknown"
esac

log_info "Detected platform: $PLATFORM"

# =============================================================================
# Install Just
# =============================================================================

install_just() {
    log_info "Checking for Just..."

    if command -v just &> /dev/null; then
        log_success "Just is already installed: $(just --version)"
        return 0
    fi

    log_info "Installing Just..."

    case $PLATFORM in
        Mac)
            if command -v brew &> /dev/null; then
                brew install just
            else
                log_warning "Homebrew not found. Installing via cargo..."
                cargo install just
            fi
            ;;
        Linux)
            if command -v apt-get &> /dev/null; then
                # Try snap first for latest version
                if command -v snap &> /dev/null; then
                    sudo snap install --edge --classic just
                else
                    # Use prebuilt binary
                    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
                fi
            elif command -v cargo &> /dev/null; then
                cargo install just
            else
                log_error "Could not find a way to install Just. Please install manually."
                log_info "See: https://github.com/casey/just#installation"
                return 1
            fi
            ;;
        Windows)
            if command -v choco &> /dev/null; then
                choco install just
            elif command -v scoop &> /dev/null; then
                scoop install just
            else
                log_error "Please install Just manually using Chocolatey or Scoop"
                return 1
            fi
            ;;
        *)
            log_error "Unknown platform. Please install Just manually."
            return 1
            ;;
    esac

    if command -v just &> /dev/null; then
        log_success "Just installed successfully: $(just --version)"
    else
        log_error "Just installation failed"
        return 1
    fi
}

# =============================================================================
# Install Act (GitHub Actions local runner)
# =============================================================================

install_act() {
    log_info "Checking for Act (GitHub Actions local runner)..."

    if command -v act &> /dev/null; then
        log_success "Act is already installed: $(act --version)"
        return 0
    fi

    log_info "Installing Act..."

    case $PLATFORM in
        Mac)
            if command -v brew &> /dev/null; then
                brew install act
            else
                log_warning "Homebrew not found. Please install act manually."
                log_info "See: https://github.com/nektos/act#installation"
                return 1
            fi
            ;;
        Linux)
            if command -v apt-get &> /dev/null; then
                curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
            else
                log_warning "Please install act manually."
                log_info "See: https://github.com/nektos/act#installation"
                return 1
            fi
            ;;
        Windows)
            if command -v choco &> /dev/null; then
                choco install act-cli
            elif command -v scoop &> /dev/null; then
                scoop install act
            else
                log_warning "Please install act manually."
                return 1
            fi
            ;;
        *)
            log_warning "Unknown platform. Please install act manually."
            return 1
            ;;
    esac

    if command -v act &> /dev/null; then
        log_success "Act installed successfully: $(act --version)"
    else
        log_warning "Act installation may have failed. You can still use the project without it."
    fi
}

# =============================================================================
# Install pre-commit (Python-based)
# =============================================================================

install_precommit() {
    log_info "Checking for pre-commit..."

    if command -v pre-commit &> /dev/null; then
        log_success "pre-commit is already installed: $(pre-commit --version)"
        return 0
    fi

    log_info "Installing pre-commit..."

    if command -v pip3 &> /dev/null; then
        pip3 install pre-commit
    elif command -v pip &> /dev/null; then
        pip install pre-commit
    elif command -v brew &> /dev/null; then
        brew install pre-commit
    else
        log_warning "Could not install pre-commit. Please install manually."
        log_info "See: https://pre-commit.com/#installation"
        return 1
    fi

    if command -v pre-commit &> /dev/null; then
        log_success "pre-commit installed successfully"
    fi
}

# =============================================================================
# Setup Git hooks
# =============================================================================

setup_hooks() {
    log_info "Setting up Git hooks..."

    # npm install will trigger husky via prepare script
    npm install

    # Optionally install pre-commit hooks
    if command -v pre-commit &> /dev/null; then
        log_info "Installing pre-commit hooks..."
        pre-commit install
        pre-commit install --hook-type commit-msg
        log_success "pre-commit hooks installed"
    fi

    log_success "Git hooks setup complete"
}

# =============================================================================
# Main
# =============================================================================

main() {
    install_just
    echo ""
    install_act
    echo ""
    install_precommit
    echo ""
    setup_hooks

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Available commands:"
    echo "  just --list       List all available recipes"
    echo "  just ci           Run full CI pipeline"
    echo "  just check        Quick pre-commit check"
    echo "  just help         Show detailed help"
    echo ""
    echo "Try running: just status"
    echo ""
}

main "$@"
