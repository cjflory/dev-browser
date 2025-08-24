# Code Quality & Static Analysis

This document describes the automated code quality checks for the Dev Browser project.

## 🔍 Analysis Tools

### Shell Script Analysis (ShellCheck)
- **Purpose**: Catches bash scripting errors and improvements
- **Tool**: [ShellCheck](https://shellcheck.net)
- **Files**: `dev-browser` script
- **Configuration**: `.shellcheckrc`

### Security Analysis
- **Purpose**: Identifies potential security vulnerabilities
- **Checks**: Dangerous commands, hardcoded secrets
- **Files**: All shell scripts

### PNG File Validation
- **Purpose**: Ensures icon file integrity and optimization
- **Tools**: `pngcheck`, `optipng`, `identify`
- **Files**: `icons/*.png`
- **Features**:
  - Format validation
  - Size monitoring
  - Optimization suggestions

### Code Standards
- **Purpose**: Maintains consistent code style
- **Checks**:
  - File encoding (UTF-8)
  - Executable permissions
  - Shebang validation
  - Line endings (Unix)
  - Trailing whitespace

### Dependency Security
- **Purpose**: Validates external dependencies
- **Checks**:
  - URL accessibility
  - External tool documentation

## 🚀 Running Checks

### Automatic (GitHub Actions)
Checks run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main`

### Local Development
Run checks locally before committing:

```bash
# Run local validation script
./test/run-local-checks.sh

# Or run individual tools:
shellcheck dev-browser
pngcheck icons/*.png
```

### Installing Local Tools

**macOS (Homebrew):**
```bash
brew install shellcheck pngcheck imagemagick optipng
```

**Ubuntu/Debian:**
```bash
sudo apt-get install shellcheck pngcheck imagemagick optipng
```

## 📝 Configuration Files

- `.shellcheckrc` - ShellCheck configuration
- `.github/workflows/code-quality.yml` - GitHub Actions workflow
- `test/run-local-checks.sh` - Local testing script

## 🐛 Common Issues & Solutions

### ShellCheck Warnings

**SC2086 - Double quote variables:**
```bash
# Instead of:
rm $file
# Use:
rm "$file"
```

**SC2034 - Unused variables:**
```bash
# If variable is used in generated scripts, disable for that line:
var="value"  # shellcheck disable=SC2034
```

### PNG Issues

**Large file sizes:**
- Use `optipng` to optimize: `optipng icons/icon-1.png`
- Consider reducing dimensions or color depth

**Invalid format:**
- Re-save in proper PNG format
- Check file hasn't been corrupted

## 📊 Workflow Results

Each workflow run provides:
- ✅/❌ Status for each check
- Detailed logs for failures
- Optimization suggestions
- Security recommendations

## 🔧 Customization

### Disabling Specific ShellCheck Rules
Add to `.shellcheckrc`:
```
disable=SC2086  # Disable double quote warnings
```

### Excluding Files
Update workflow `ignore_paths` or `ignore_names` in `.github/workflows/code-quality.yml`

### Adding New Checks
Add new jobs to the workflow file following the existing pattern.

## 📚 Resources

- [ShellCheck Documentation](https://shellcheck.net)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PNG Optimization Guide](https://developers.google.com/speed/docs/insights/OptimizeImages)