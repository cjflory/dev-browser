# Dev Browser

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Version: 2.1.0](https://img.shields.io/badge/Version-2.1.0-red.svg)](https://github.com/cjflory/dev-browser)

A development tool that creates custom browser shortcuts with DNS override rules, allowing developers to redirect specific hostnames to different IP addresses for local development and testing.

📖 **[View Full Documentation & Examples →](https://cjflory.github.io/dev-browser/)**

## Quick Start

### One-Command Install
```bash
curl -fsSL https://raw.githubusercontent.com/cjflory/dev-browser/main/dev-browser | bash -s install
```

### Create Your First Dev Browser
```bash
dev-browser create
```

Follow the interactive prompts to set up DNS rules like:
- `example.com` → `192.168.1.100` (your local dev server)
- `api.example.com` → `192.168.1.101` (your local API)

## What This Does

- **Creates native macOS apps** that launch browsers with custom DNS rules
- **Uses separate browser profiles** isolated from your main browser
- **Works with Chromium browsers**: Chrome, Brave, Edge, Vivaldi, Opera, Arc
- **No admin privileges required** - no system-wide changes
- **Perfect for local development** where you need production domain names

## Key Commands

```bash
dev-browser create          # Create a new browser app
dev-browser list            # List all created apps  
dev-browser remove <id>     # Remove an app
dev-browser uninstall       # Remove dev-browser entirely
```

## Requirements

- **macOS** (10.14+)
- **At least one Chromium-based browser**
- **Bash** (pre-installed)

## Example Use Cases

- Test your React app against different API environments
- Run microservices locally with production-like URLs
- Create isolated browser profiles for different projects
- Debug authentication flows with real domain names

---

**Need more details?** Check out the [full documentation](https://cjflory.github.io/dev-browser/) with examples, troubleshooting, and advanced features.