#!/bin/bash

# =============================================================================
# Dev Browser Maker Installer v1.0.0
# =============================================================================
# Simple installer script that sets up dev-browser-maker for easy access
#
# Author: cjflory
# License: MIT
# =============================================================================

set -e

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Display header
echo -e "${BLUE}🚀 Dev Browser Maker Installer v${VERSION}${NC}"
echo "============================================="
echo

# Check if we're in the right directory
if [[ ! -f "make-dev-browser.sh" ]]; then
    print_error "make-dev-browser.sh not found in current directory"
    print_info "Please run this installer from the dev-browser-maker project directory"
    exit 1
fi

# Make the main script executable
print_info "Making make-dev-browser.sh executable..."
chmod +x make-dev-browser.sh
print_success "Script is now executable"

# Check for supported browsers
print_info "Checking for supported browsers..."
browsers_found=0
browser_paths=(
    "/Applications/Google Chrome.app"
    "/Applications/Brave Browser.app"
    "/Applications/Microsoft Edge.app"
    "/Applications/Chromium.app"
    "/Applications/Opera.app"
    "/Applications/Arc.app"
)

browser_names=(
    "Google Chrome"
    "Brave Browser"
    "Microsoft Edge"
    "Chromium"
    "Opera"
    "Arc"
)

for i in "${!browser_paths[@]}"; do
    if [[ -d "${browser_paths[i]}" ]]; then
        print_success "Found: ${browser_names[i]}"
        ((browsers_found++))
    fi
done

if [[ $browsers_found -eq 0 ]]; then
    print_warning "No supported browsers found!"
    print_info "Please install at least one Chromium-based browser:"
    for name in "${browser_names[@]}"; do
        echo "  - $name"
    done
    echo
else
    print_success "Found $browsers_found supported browser(s)"
fi

# Check icon directory
print_info "Checking icon assets..."
if [[ -d "icons" ]]; then
    icon_count=$(find icons -name "*.png" -type f | wc -l | xargs)
    if [[ $icon_count -gt 0 ]]; then
        print_success "Found $icon_count icon files"
    else
        print_warning "No PNG icons found in icons/ directory"
    fi
else
    print_warning "Icons directory not found"
fi

echo
print_info "Installation options:"
echo "1. Use from current directory (recommended)"
echo "2. Create symlink in /usr/local/bin (requires admin password)"
echo "3. Skip installation setup"
echo

read -p "Choose option (1-3): " choice

case $choice in
    1)
        print_success "You can now run: ./make-dev-browser.sh"
        print_info "Or add this directory to your PATH for global access"
        ;;
    2)
        print_info "Creating symlink in /usr/local/bin..."
        if sudo ln -sf "$(pwd)/make-dev-browser.sh" /usr/local/bin/make-dev-browser; then
            print_success "Symlink created! You can now run: make-dev-browser"
            print_info "Note: You may need to restart your terminal"
        else
            print_error "Failed to create symlink"
        fi
        ;;
    3)
        print_info "Skipping installation setup"
        ;;
    *)
        print_warning "Invalid choice. You can run ./make-dev-browser.sh from this directory"
        ;;
esac

echo
print_success "Setup complete!"
print_info "Run './make-dev-browser.sh --help' for usage information"

if [[ $browsers_found -eq 0 ]]; then
    echo
    print_warning "Remember to install a Chromium-based browser before using the tool"
fi