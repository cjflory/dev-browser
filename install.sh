#!/bin/bash

# =============================================================================
# Dev Browser Maker Remote Installer v1.0.0
# =============================================================================
# Downloads and sets up dev-browser-maker from GitHub
#
# Usage: curl -fsSL https://raw.githubusercontent.com/cjflory/dev-browser-maker/main/install.sh | bash
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
NC='\033[0m' # No Color

# Helper functions
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Configuration
REPO_URL="https://github.com/cjflory/dev-browser-maker"
RAW_URL="https://raw.githubusercontent.com/cjflory/dev-browser-maker/main"
INSTALL_DIR="$HOME/.local/share/dev-browser-maker"
BIN_DIR="$HOME/.local/bin"

echo -e "${BLUE}🚀 Dev Browser Maker Remote Installer${NC}"
echo "======================================"
echo

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This tool only works on macOS"
    exit 1
fi

# Check for required commands
for cmd in curl mkdir chmod; do
    if ! command -v "$cmd" &> /dev/null; then
        print_error "Required command '$cmd' not found"
        exit 1
    fi
done

# Create directories
print_info "Setting up directories..."
mkdir -p "$INSTALL_DIR" "$INSTALL_DIR/icons" "$BIN_DIR"

# Download main script
print_info "Downloading make-dev-browser.sh..."
if curl -fsSL "$RAW_URL/make-dev-browser.sh" -o "$INSTALL_DIR/make-dev-browser.sh"; then
    chmod +x "$INSTALL_DIR/make-dev-browser.sh"
    print_success "Downloaded main script"
else
    print_error "Failed to download main script"
    exit 1
fi

# Download icons
print_info "Downloading icon assets..."
for i in {1..10}; do
    if curl -fsSL "$RAW_URL/icons/icon-$i.png" -o "$INSTALL_DIR/icons/icon-$i.png" 2>/dev/null; then
        echo -n "."
    else
        print_warning "Failed to download icon-$i.png (continuing...)"
    fi
done
echo
print_success "Downloaded icon assets"

# Create wrapper script in bin
print_info "Creating wrapper script..."
cat > "$BIN_DIR/make-dev-browser" << 'EOF'
#!/bin/bash
exec "$HOME/.local/share/dev-browser-maker/make-dev-browser.sh" "$@"
EOF
chmod +x "$BIN_DIR/make-dev-browser"
print_success "Created wrapper script"

# Check PATH
echo
if echo "$PATH" | grep -q "$BIN_DIR"; then
    print_success "Installation complete! Run: make-dev-browser"
else
    print_success "Installation complete!"
    print_info "Add to your shell profile to use globally:"
    echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    echo
    print_info "Or run directly: $BIN_DIR/make-dev-browser"
fi

print_info "Installation directory: $INSTALL_DIR"
print_info "GitHub repository: $REPO_URL"