#!/bin/bash

# =============================================================================
# Dev Browser Maker Uninstaller v1.0.2
# =============================================================================
# Removes dev-browser-maker installation from the system
#
# Author: cjflory
# License: MIT
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m' 
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_info() { 
    echo -e "${BLUE}[INFO] $1${NC}"
}

print_success() { 
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_warning() { 
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_error() { 
    echo -e "${RED}[ERROR] $1${NC}"
}

# Configuration
INSTALL_DIR="$HOME/.local/share/dev-browser-maker"
BIN_DIR="$HOME/.local/bin"
WRAPPER_SCRIPT="$BIN_DIR/make-dev-browser"

echo -e "${BLUE}Dev Browser Maker Uninstaller${NC}"
echo "===================================="
echo

# Check if installed
if [[ ! -d "$INSTALL_DIR" ]] && [[ ! -f "$WRAPPER_SCRIPT" ]]; then
    print_warning "Dev Browser Maker doesn't appear to be installed"
    print_info "Installation directory: $INSTALL_DIR"
    print_info "Wrapper script: $WRAPPER_SCRIPT"
    exit 0
fi

# Show what will be removed
print_info "The following will be removed:"
if [[ -d "$INSTALL_DIR" ]]; then
    echo "  Installation directory: $INSTALL_DIR"
    echo "     $(find "$INSTALL_DIR" -type f | wc -l | xargs) files"
fi
if [[ -f "$WRAPPER_SCRIPT" ]]; then
    echo "  Wrapper script: $WRAPPER_SCRIPT"
fi

echo
print_warning "This will NOT remove any apps you've created with make-dev-browser"
print_info "Those are stored as .app bundles wherever you created them"
echo

# Confirmation
read -p "Continue with uninstall? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstall cancelled"
    exit 0
fi

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    print_info "Removing installation directory..."
    if rm -rf "$INSTALL_DIR"; then
        print_success "Removed $INSTALL_DIR"
    else
        print_error "Failed to remove $INSTALL_DIR"
    fi
fi

# Remove wrapper script
if [[ -f "$WRAPPER_SCRIPT" ]]; then
    print_info "Removing wrapper script..."
    if rm -f "$WRAPPER_SCRIPT"; then
        print_success "Removed $WRAPPER_SCRIPT"
    else
        print_error "Failed to remove $WRAPPER_SCRIPT"
    fi
fi

# Check if .local/bin is empty and can be removed
if [[ -d "$BIN_DIR" ]] && [[ -z "$(ls -A "$BIN_DIR")" ]]; then
    print_info "Removing empty $BIN_DIR directory..."
    rmdir "$BIN_DIR" 2>/dev/null || true
fi

# Check if .local/share is empty and can be removed
if [[ -d "$HOME/.local/share" ]] && [[ -z "$(ls -A "$HOME/.local/share")" ]]; then
    print_info "Removing empty $HOME/.local/share directory..."
    rmdir "$HOME/.local/share" 2>/dev/null || true
fi

echo
print_success "Uninstall complete!"
print_info "Any browser apps you created are still available"
print_info "You can manually delete them from Applications or wherever you saved them"