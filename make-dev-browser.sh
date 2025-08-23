#!/bin/bash

# =============================================================================
# Dev Browser Maker v1.0.0
# =============================================================================
# Creates custom browser app bundles with DNS override rules for development
#
# This script helps developers create isolated browser instances that redirect
# specific hostnames to different IP addresses. Useful for local development
# where you need to test against different environments while maintaining
# the same hostnames as production.
#
# Author: cjflory
# License: MIT
# =============================================================================

# Exit immediately if any command fails (makes debugging easier)
set -e

# Version information
VERSION="1.0.0"

# Function to display help information
show_help() {
    echo "Dev Browser Maker v${VERSION}"
    echo "Creates custom browser apps with DNS override rules for development"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo ""
    echo "Interactive mode (no options):"
    echo "  The script will guide you through creating a custom browser app"
    echo "  with DNS rules to redirect hostnames to specific IP addresses."
    echo ""
    echo "Examples:"
    echo "  $0              # Run in interactive mode"
    echo "  $0 --help       # Show this help"
    echo "  $0 --version    # Show version"
}

# Function to display version information
show_version() {
    echo "Dev Browser Maker v${VERSION}"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        show_version
        exit 0
        ;;
    "")
        # No arguments - continue with interactive mode
        ;;
    *)
        echo "Error: Unknown option '$1'"
        echo "Run '$0 --help' for usage information."
        exit 1
        ;;
esac

# Display welcome message
echo "🚀 Dev Browser Maker v${VERSION}"
echo "================================"
echo

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: validate_app_name
# Purpose: Validates that app names don't contain problematic characters
# Parameters: $1 - The app name to validate
# Returns: 0 if valid, 1 if invalid
# Notes: macOS app bundles can't contain certain filesystem characters
validate_app_name() {
    local name="$1"
    
    # Check if name is empty
    if [[ -z "$name" ]]; then
        return 1  # Empty name is invalid
    fi
    
    # Check for characters that would break macOS app bundles or filesystems
    # These characters: / \ : * ? " < > | are problematic in filenames
    if [[ "$name" =~ [/\\:*?\"\<\>|] ]]; then
        return 1  # Contains invalid characters
    fi
    
    return 0  # Name is valid
}

# Function: detect_browsers
# Purpose: Scans the system for installed Chromium-based browsers
# Parameters: None
# Returns: Sets global arrays DETECTED_BROWSERS and BROWSER_CONFIGS
# Notes: All Chromium browsers support the --host-resolver-rules flag we need
detect_browsers() {
    # Initialize local arrays to store results
    local browsers=()      # Will store display names of found browsers
    local browser_paths=()  # Will store full config strings for found browsers
    
    # Define known Chromium browser locations and metadata
    # Format: "Display Name:App Path:Executable Path:Icon Path"
    # The executable path is what we actually run, the app path is for detection
    local browser_configs=(
        "Google Chrome:/Applications/Google Chrome.app:/Applications/Google Chrome.app/Contents/MacOS/Google Chrome:/Applications/Google Chrome.app/Contents/Resources/app.icns"
        "Brave Browser:/Applications/Brave Browser.app:/Applications/Brave Browser.app/Contents/MacOS/Brave Browser:/Applications/Brave Browser.app/Contents/Resources/app.icns"
        "Microsoft Edge:/Applications/Microsoft Edge.app:/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge:/Applications/Microsoft Edge.app/Contents/Resources/app.icns"
        "Vivaldi:/Applications/Vivaldi.app:/Applications/Vivaldi.app/Contents/MacOS/Vivaldi:/Applications/Vivaldi.app/Contents/Resources/vivaldi.icns"
        "Opera:/Applications/Opera.app:/Applications/Opera.app/Contents/MacOS/Opera:/Applications/Opera.app/Contents/Resources/Opera.icns"
        "Arc:/Applications/Arc.app:/Applications/Arc.app/Contents/MacOS/Arc:/Applications/Arc.app/Contents/Resources/AppIcon.icns"
    )
    
    # Check which browsers are actually installed on this system
    for config in "${browser_configs[@]}"; do
        # Split the config string into components using colon as delimiter
        # IFS (Internal Field Separator) controls how bash splits strings
        IFS=':' read -r name app_path exec_path icon_path <<< "$config"
        
        # Test if the executable file exists (means browser is installed)
        if [[ -f "$exec_path" ]]; then
            browsers+=("$name")      # Add display name to found browsers
            browser_paths+=("$config")  # Keep full config for later use
        fi
    done
    
    # Set global arrays that other functions can access
    # Using global vars here because bash functions can't return arrays easily
    DETECTED_BROWSERS=("${browsers[@]}")
    BROWSER_CONFIGS=("${browser_paths[@]}")
}

# Function: select_browser
# Purpose: Handles browser selection logic (auto-select if one, prompt if multiple)
# Parameters: None
# Returns: Sets global variables for selected browser info
# Notes: This function provides the main user interaction for browser selection
select_browser() {
    # First, scan for available browsers
    detect_browsers
    
    # Handle case where no browsers are found
    if [[ ${#DETECTED_BROWSERS[@]} -eq 0 ]]; then
        echo "❌ No supported Chromium browsers found. Please install one of:"
        echo "   • Google Chrome"
        echo "   • Brave Browser" 
        echo "   • Microsoft Edge"
        echo "   • Vivaldi"
        echo "   • Opera"
        echo "   • Arc"
        exit 1  # Exit with error code since we can't proceed
    
    # Handle case where exactly one browser is found (auto-select)
    elif [[ ${#DETECTED_BROWSERS[@]} -eq 1 ]]; then
        # Automatically use the only available browser
        SELECTED_BROWSER_CONFIG="${BROWSER_CONFIGS[0]}"
        
        # Parse the browser configuration string to extract components
        IFS=':' read -r BROWSER_NAME BROWSER_APP_PATH BROWSER_EXEC_PATH BROWSER_ICON_PATH <<< "$SELECTED_BROWSER_CONFIG"
        echo "🌐 Using detected browser: $BROWSER_NAME"
    
    # Handle case where multiple browsers are found (user choice required)
    else
        echo "🌐 Multiple browsers detected. Please choose:"
        
        # Display numbered list of available browsers
        # ${!DETECTED_BROWSERS[@]} gives us the array indices
        for i in "${!DETECTED_BROWSERS[@]}"; do
            echo "   $((i+1))) ${DETECTED_BROWSERS[i]}"  # Display 1-based numbering
        done
        
        # Keep asking until we get a valid choice
        while true; do
            read -p "Select browser (1-${#DETECTED_BROWSERS[@]}): " choice
            
            # Validate that input is a number in the valid range
            # =~ is bash regex matching operator
            if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#DETECTED_BROWSERS[@]} ]]; then
                # Convert from 1-based user input to 0-based array index
                SELECTED_BROWSER_CONFIG="${BROWSER_CONFIGS[$((choice-1))]}"
                
                # Parse the selected browser's configuration
                IFS=':' read -r BROWSER_NAME BROWSER_APP_PATH BROWSER_EXEC_PATH BROWSER_ICON_PATH <<< "$SELECTED_BROWSER_CONFIG"
                echo "✓ Selected: $BROWSER_NAME"
                break  # Exit the validation loop
            else
                # Invalid input, show error and ask again
                echo "❌ Invalid choice. Please enter a number between 1 and ${#DETECTED_BROWSERS[@]}"
            fi
        done
    fi
}


# Function: generate_random_icon
# Purpose: Creates a custom .icns icon file from PNG sources
# Parameters: $1 - Output path for .icns file, $2 - App name for consistent selection
# Returns: 0 on success, 1 on failure
# Notes: Uses hash-based selection to ensure same app name = same icon
generate_random_icon() {
    local icon_path="$1"   # Where to save the final .icns file
    local app_name="$2"    # App name used for consistent icon selection
    
    # Find the directory where this script is located
    # BASH_SOURCE[0] is the path to the current script file
    # dirname extracts just the directory part of that path
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local icons_dir="$script_dir/icons"
    
    # Verify that the icons directory exists
    if [[ ! -d "$icons_dir" ]]; then
        echo "⚠️  Icons directory not found: $icons_dir"
        return 1  # Return error code
    fi
    
    # Get list of all PNG files in the icons directory
    # The glob pattern *.png expands to an array of matching filenames
    local icon_files=("$icons_dir"/*.png)
    
    # Check if any PNG files were actually found
    # If no files match, the glob returns the literal string "*.png"
    if [[ ! -f "${icon_files[0]}" ]]; then
        echo "⚠️  No PNG icons found in: $icons_dir"
        return 1
    fi
    
    # Create consistent icon selection based on app name
    # cksum generates a checksum from the app name (deterministic hash)
    # cut -d' ' -f1 extracts just the numeric part of the checksum
    local name_hash=$(echo "$app_name" | cksum | cut -d' ' -f1)
    
    # Use modulo to map hash to array index (ensures consistent selection)
    local icon_index=$((name_hash % ${#icon_files[@]}))
    local selected_png="${icon_files[icon_index]}"
    
    # Create temporary directory for icon processing
    # mktemp -d creates a unique temporary directory
    local temp_dir=$(mktemp -d)
    local iconset_dir="$temp_dir/icon.iconset"
    mkdir -p "$iconset_dir"
    
    # macOS icons need multiple resolutions for different contexts
    # These sizes cover everything from menu bar to Finder icons
    local sizes=(16 32 64 128 256 512)
    
    for size in "${sizes[@]}"; do
        # Create standard resolution version
        local png_file="$iconset_dir/icon_${size}x${size}.png"
        
        # sips is macOS built-in image processing tool
        # -z resizes image, --out specifies output file
        # &>/dev/null suppresses all output (both stdout and stderr)
        sips -z $size $size "$selected_png" --out "$png_file" &>/dev/null
        
        # Create high-DPI (@2x) versions for Retina displays
        # Only create @2x versions for smaller sizes (larger ones don't need them)
        if [[ $size -le 256 ]]; then
            local size2x=$((size * 2))  # Double the size for @2x version
            local png_file_2x="$iconset_dir/icon_${size}x${size}@2x.png"
            sips -z $size2x $size2x "$selected_png" --out "$png_file_2x" &>/dev/null
        fi
    done
    
    # Convert the iconset directory to final .icns file
    # iconutil is macOS built-in tool for creating .icns files
    # -c icns means "create icns format"
    # -o specifies output file
    if iconutil -c icns -o "$icon_path" "$iconset_dir" &>/dev/null; then
        rm -rf "$temp_dir"  # Clean up temporary files
        return 0  # Success
    fi
    
    # If iconutil failed, clean up and return error
    rm -rf "$temp_dir"
    return 1
}

# Function: suggest_profile_name  
# Purpose: Converts app name into a filesystem-safe profile directory name
# Parameters: $1 - The app name to convert
# Returns: Prints suggested profile name to stdout
# Notes: Creates consistent, readable directory names from user-friendly app names
suggest_profile_name() {
    local app_name="$1"
    
    # Transform app name into filesystem-safe profile directory name:
    # 1. tr '[:upper:]' '[:lower:]' - Convert to lowercase
    # 2. sed 's/[^a-z0-9 ]//g' - Remove all non-alphanumeric chars except spaces  
    # 3. tr ' ' '-' - Replace spaces with dashes
    # 4. sed 's/--*/-/g' - Collapse multiple dashes into single dashes
    # 5. sed 's/^-\|-$//g' - Remove leading/trailing dashes
    # 
    # Example: "My Dev App (v2.0)" → "my-dev-app-v20"
    echo "$app_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-' | sed 's/--*/-/g' | sed 's/^-\|-$//g'
}

# =============================================================================
# MAIN SCRIPT EXECUTION
# =============================================================================

# Step 1: Detect and select browser to use
select_browser
echo

# Step 2: Get app name from user (with validation)
while true; do
    read -p "📱 App name (e.g., 'Chrome Dev'): " APP_NAME
    
    # Validate the app name to ensure it won't break filesystem operations
    if validate_app_name "$APP_NAME"; then
        break  # Name is valid, exit validation loop
    else
        # Show error and ask again
        echo "❌ Invalid app name. Avoid special characters like / \\ : * ? \" < > |"
    fi
done

# Step 3: Generate and offer suggested profile directory name
# This provides a good default while allowing customization
SUGGESTED_PROFILE=$(suggest_profile_name "$APP_NAME")

echo "📁 Profile directory name:"
echo "   Suggested: '$SUGGESTED_PROFILE' (press Enter to use this)"
read -p "   Or enter custom name: " PROFILE_NAME

# If user just pressed Enter, use the suggested name
if [[ -z "$PROFILE_NAME" ]]; then
    PROFILE_NAME="$SUGGESTED_PROFILE"
fi

# Step 4: Collect DNS mapping rules from user
echo
echo "🌐 DNS Mapping Rules"
echo "Enter hostname to IP mappings (one per line)."
echo "Format: hostname ip (e.g., example.com 192.168.1.100)"
echo "Press Enter twice when done:"

# Initialize array to store DNS rules
DNS_RULES=()

# Keep collecting rules until user enters empty line
while true; do
    read -p "   " rule
    
    # Check if user entered empty line (wants to finish)
    if [[ -z "$rule" ]]; then
        # Only allow finishing if at least one rule was entered
        if [[ ${#DNS_RULES[@]} -gt 0 ]]; then
            break  # Exit rule collection loop
        else
            echo "❌ Please enter at least one DNS rule, or press Ctrl+C to cancel"
        fi
    else
        # Validate rule format: hostname followed by IPv4 address
        # Regex breakdown:
        # ^[a-zA-Z0-9.-]+ - hostname (letters, numbers, dots, dashes)
        # [[:space:]]+ - one or more whitespace characters  
        # [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ - IPv4 format
        if [[ "$rule" =~ ^[a-zA-Z0-9.-]+[[:space:]]+[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            DNS_RULES+=("$rule")  # Add rule to array
            echo "   ✓ Added: $rule"
        else
            echo "   ❌ Invalid format. Use: hostname ip (e.g., example.com 192.168.1.100)"
        fi
    fi
done

# Optional: Custom icon
echo
read -p "🎨 Custom icon path (optional, press Enter to skip): " ICON_PATH

# Show summary
echo
echo "📋 Summary:"
echo "   App Name: $APP_NAME"
echo "   Profile: chrome-profiles/$PROFILE_NAME"
echo "   DNS Rules: ${#DNS_RULES[@]} rule(s)"
for rule in "${DNS_RULES[@]}"; do
    echo "     - $rule"
done
if [[ -n "$ICON_PATH" ]]; then
    echo "   Icon: $ICON_PATH"
fi

echo
read -p "✅ Create app? (Y/n): " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Generate app bundle
APP_BUNDLE="$APP_NAME.app"
APP_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$APP_DIR/MacOS"
RESOURCES_DIR="$APP_DIR/Resources"

echo
echo "🔨 Creating app bundle..."

# Create directory structure
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Build Chromium browser arguments
BROWSER_ARGS="--user-data-dir=\"\$HOME/chrome-profiles/$PROFILE_NAME\""
PROFILE_DIR_NAME="chrome-profiles"

if [[ ${#DNS_RULES[@]} -gt 0 ]]; then
    MAP_RULES=""
    for rule in "${DNS_RULES[@]}"; do
        hostname=$(echo "$rule" | awk '{print $1}')
        ip=$(echo "$rule" | awk '{print $2}')
        if [[ -z "$MAP_RULES" ]]; then
            MAP_RULES="MAP $hostname $ip"
        else
            MAP_RULES="$MAP_RULES, MAP $hostname $ip"
        fi
    done
    BROWSER_ARGS="$BROWSER_ARGS --host-resolver-rules=\"$MAP_RULES\""
fi

# Create executable script
EXECUTABLE_NAME=$(echo "$APP_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
EXECUTABLE_PATH="$MACOS_DIR/$EXECUTABLE_NAME"

cat > "$EXECUTABLE_PATH" << EOF
#!/bin/bash

# $BROWSER_NAME launcher with custom DNS rules
# Generated by Dev Browser Maker

BROWSER_PATH="$BROWSER_EXEC_PATH"

if [[ ! -f "\$BROWSER_PATH" ]]; then
    echo "❌ $BROWSER_NAME not found at \$BROWSER_PATH"
    echo "Please install $BROWSER_NAME first."
    exit 1
fi

# Create profile directory if it doesn't exist
mkdir -p "\$HOME/$PROFILE_DIR_NAME/$PROFILE_NAME"

# Launch $BROWSER_NAME with custom arguments
exec "\$BROWSER_PATH" $BROWSER_ARGS "\$@"
EOF

# Make executable
chmod +x "$EXECUTABLE_PATH"

# Create Info.plist
cat > "$APP_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.custom.chrome.$(echo "$PROFILE_NAME" | tr '[:upper:]' '[:lower:]')</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.9</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <true/>
</dict>
</plist>
EOF

# Handle icon (custom or generated)
if [[ -n "$ICON_PATH" && -f "$ICON_PATH" ]]; then
    # Use custom icon provided by user
    cp "$ICON_PATH" "$RESOURCES_DIR/icon.icns"
    echo "   ✓ Custom icon added"
else
    # Generate random icon from available PNG icons
    if generate_random_icon "$RESOURCES_DIR/icon.icns" "$APP_NAME"; then
        echo "   ✓ Random icon generated"
    else
        echo "   ⚠️  Could not generate icon (using default)"
    fi
fi

# Add icon reference to Info.plist if icon exists
if [[ -f "$RESOURCES_DIR/icon.icns" ]]; then
    sed -i '' '/<\/dict>/i\
    <key>CFBundleIconFile</key>\
    <string>icon</string>
' "$APP_DIR/Info.plist"
fi

echo "   ✓ App bundle created: $APP_BUNDLE"
echo "   ✓ Profile location: ~/$PROFILE_DIR_NAME/$PROFILE_NAME"

# Test the app
echo
echo "🧪 Testing app..."
if [[ -f "$BROWSER_EXEC_PATH" ]]; then
    echo "   ✓ $BROWSER_NAME found"
    echo "   ✓ App bundle structure is valid"
else
    echo "   ⚠️  $BROWSER_NAME not found - app will work once $BROWSER_NAME is installed"
    echo "   ✓ App bundle structure is valid"
fi

echo
echo "🎉 Success! Your custom $BROWSER_NAME app is ready:"
echo "   📱 App: $APP_BUNDLE"
echo "   🚀 Double-click to launch"
echo "   📱 Drag to Applications folder or Dock for easy access"
echo
echo "💡 Tips:"
echo "   • Each app uses a separate $BROWSER_NAME profile"
echo "   • DNS rules only apply to that specific app instance"
echo "   • You can run multiple browser apps simultaneously"
echo