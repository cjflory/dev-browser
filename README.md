# Dev Browser Maker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-red.svg)](https://github.com/cjflory/dev-browser-maker)

A development tool that creates custom browser apps with DNS override rules, allowing developers to redirect specific hostnames to different IP addresses for local development and testing.

## Requirements

- **macOS** (tested on macOS 10.14+)
- **Bash** 4.0+ (pre-installed on macOS)
- At least one **Chromium-based browser** installed:
  - Google Chrome
  - Brave Browser
  - Microsoft Edge
  - Chromium
  - Opera
  - Arc Browser

## Problem

When developing web applications, you often need to test against local development environments while maintaining the same hostname as production (e.g., `example.com`). Traditional solutions like editing the hosts file affect the entire system and require admin privileges.

## Solution

This project provides `make-dev-browser.sh` - an interactive script that creates custom browser app bundles with DNS override rules using Chromium's `--host-resolver-rules` flag. Each app bundle:

- Uses a separate browser profile (isolated from your main browser)
- Applies DNS rules only to that specific browser instance
- Can run alongside regular browsers
- Appears as a native Mac app in Dock/Applications
- Gets a randomly assigned distinctive icon

## Installation

### One-Command Install (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/cjflory/dev-browser-maker/main/install.sh | bash
```
This downloads the script and icons to `~/.local/share/dev-browser-maker/` and creates a `make-dev-browser` command.

### Manual Install
```bash
git clone https://github.com/cjflory/dev-browser-maker.git
cd dev-browser-maker
chmod +x make-dev-browser.sh
```

### Uninstall
```bash
curl -fsSL https://raw.githubusercontent.com/cjflory/dev-browser-maker/main/uninstall.sh | bash
```
This removes the installation but keeps any browser apps you've created.

## Usage

1. Run the script:
   ```bash
   make-dev-browser          # If installed via curl
   ./make-dev-browser.sh     # If cloned manually
   ```

2. Follow the interactive prompts:
   - **Browser selection**: Automatically detects installed Chromium browsers
   - **App name**: "Dev Environment", "Staging", etc. 
   - **Profile name**: Auto-suggested from app name (customizable)
   - **DNS rules**: Enter hostname-to-IP mappings (one per line)
   - **Custom icon**: Optional custom icon path

3. The script creates a `.app` bundle that you can:
   - Double-click to launch
   - Drag to Applications folder  
   - Add to Dock for quick access

## Example

```
🌐 Using detected browser: Brave Browser

📱 App name: Dev Environment
📁 Profile directory name:
   Suggested: 'dev-environment' (press Enter to use this)
   Or enter custom name: 

🌐 DNS Mapping Rules:
   example.com 192.168.1.100
   api.example.com 192.168.1.101
   (press Enter twice when done)

✅ Create app? (Y/n): 
```

This creates "Dev Environment.app" that:
- Launches Brave Browser with a separate profile
- Redirects `example.com` → `192.168.1.100`  
- Redirects `api.example.com` → `192.168.1.101`
- Has a unique randomly-selected icon

## Use Cases

**Frontend Development**
- Test your React/Vue/Angular app against different API environments
- Switch between local, staging, and production backends
- Debug cross-origin issues with proper domain names

**Full-Stack Development**
- Run multiple microservices locally with production-like URLs
- Test authentication flows with real domain names
- Validate SSL certificate handling in development

**QA Testing**
- Create dedicated browser profiles for each test environment
- Isolate test data and browser state
- Quick switching between different API versions

**DevOps/Infrastructure**
- Test load balancer configurations locally
- Validate DNS changes before going live
- Debug service discovery issues

## Features

- ✅ **Multi-browser support**: Auto-detects Chrome, Brave, Edge, Vivaldi, Opera, Arc
- ✅ **Smart defaults**: Auto-suggests profile names from app names  
- ✅ **Interactive setup**: Guided prompts with input validation
- ✅ **Multiple DNS rules**: Support for complex routing scenarios
- ✅ **Separate profiles**: Isolated from your main browser data
- ✅ **Native Mac apps**: Proper `.app` bundles with icons
- ✅ **Random icons**: 10 distinctive icons automatically assigned
- ✅ **Custom icons**: Optional user-provided icon support
- ✅ **No admin privileges**: No system-wide changes required
- ✅ **Consistent behavior**: Same app name = same icon/profile

## Supported Browsers

- **Google Chrome** - `/Applications/Google Chrome.app/`
- **Brave Browser** - `/Applications/Brave Browser.app/`  
- **Microsoft Edge** - `/Applications/Microsoft Edge.app/`
- **Vivaldi** - `/Applications/Vivaldi.app/`
- **Opera** - `/Applications/Opera.app/`
- **Arc** - `/Applications/Arc.app/`

## Requirements

- **macOS** (tested on macOS 10.15+)
- **At least one Chromium browser** (see supported browsers above)  
- **Bash shell** (pre-installed on macOS)

## How It Works

### App Bundle Structure
```
Dev Environment.app/
├── Contents/
│   ├── Info.plist              # Bundle metadata & configuration
│   ├── MacOS/
│   │   └── dev-environment     # Executable launcher script
│   └── Resources/              # App icon (generated or custom)
│       └── icon.icns
```

### DNS Override Process
1. **Script detection**: Finds installed Chromium browsers
2. **User input**: Collects app name, profile, DNS rules
3. **Icon generation**: Selects from 10 unique PNG icons, converts to `.icns`
4. **Bundle creation**: Creates proper macOS app bundle structure
5. **Launcher script**: Generates bash script with `--host-resolver-rules`

### Technical Implementation
- Uses Chromium's `--host-resolver-rules="MAP hostname ip"` flag
- Each app uses `--user-data-dir` for profile isolation  
- Icons converted using `sips` and `iconutil` (macOS built-ins)
- Hash-based icon selection ensures consistency
- Validates hostname/IP format with regex patterns

## Icon System

The script includes 10 unique PNG icons (`icons/icon-01.png` through `icon-10.png`) that are:
- **Automatically selected** based on app name hash (consistent selection)
- **Converted to `.icns`** with multiple resolutions (16px-512px + Retina @2x)
- **Visually distinctive** to help identify different dev environments
- **Overridable** with custom icons if desired

## Use Cases

- **Local Development**: Point production domains to `localhost`
- **Staging Environments**: Route to staging servers without DNS changes  
- **Microservices**: Different services on different local ports
- **API Testing**: Route API calls to local mock servers
- **Multi-tenant Testing**: Different tenant environments

## Alternative Solutions Considered

1. **Hosts File Editing**: System-wide, requires admin, affects all apps
2. **Proxy Server**: Network overhead, complex setup, proxy conflicts
3. **Browser Extensions**: Cannot control DNS resolution directly  
4. **VPN/DNS Services**: Overkill, affects entire network stack
5. **Electron Wrapper**: Heavy resource usage, limited browser features

## Limitations

- **Chromium browsers only** (no Safari/Firefox support)
- **Static DNS rules** (require app relaunch to change)  
- **HTTP/HTTPS only** (standard web protocols)
- **macOS only** (uses macOS-specific app bundle format)

## Troubleshooting

### No Browsers Detected
```
❌ Error: No supported browsers found
```
**Solution**: Install one of the supported Chromium browsers (Chrome, Brave, Edge, etc.)

### App Won't Launch
**Issue**: Double-clicking the app does nothing
**Solutions**:
- Right-click → Open (bypass Gatekeeper on first run)
- Check Console app for error messages
- Verify the browser executable path hasn't changed

### DNS Rules Not Working
**Issue**: Still seeing original website
**Solutions**:
- Clear browser cache/cookies for the domain
- Check browser developer tools for DNS resolution
- Verify IP address is correct and accessible
- Try `curl -H "Host: example.com" http://192.168.1.100` to test

### Permission Denied Errors
**Issue**: Cannot create app bundle
**Solutions**:
- Ensure you have write permissions to the target directory
- Try running from a different location (e.g., your home directory)
- Check available disk space

### App Icon Issues
**Issue**: App shows generic folder icon
**Solutions**:
- Restart Finder: `sudo killall Finder`
- Clear icon cache: `sudo rm -rf /Library/Caches/com.apple.iconservices.store`
- Verify `icons/` directory contains PNG files

### Getting Help
```bash
./make-dev-browser.sh --help  # Show usage information
./make-dev-browser.sh --version  # Show version
```

For issues not covered here, please check the [GitHub Issues](https://github.com/cjflory/dev-browser-maker/issues).
