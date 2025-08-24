#!/bin/bash

# Local code quality checks for dev-browser
# Run this before pushing to catch issues early

set -e

echo "🔍 Running local code quality checks..."
echo "======================================"

# Check if tools are installed
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ $1 not found. Install it first:"
        echo "   $2"
        return 1
    fi
    echo "✅ $1 found"
}

echo "📋 Checking required tools..."
check_tool "shellcheck" "brew install shellcheck (macOS) or apt install shellcheck (Linux)"
check_tool "pngcheck" "brew install pngcheck (macOS) or apt install pngcheck (Linux)"

echo ""
echo "🔧 Running ShellCheck on dev-browser script..."
if shellcheck dev-browser; then
    echo "✅ ShellCheck passed"
else
    echo "❌ ShellCheck found issues"
    exit 1
fi

echo ""
echo "🖼️  Validating PNG files..."
png_errors=0
for png_file in icons/*.png; do
    if [ -f "$png_file" ]; then
        echo "Checking: $png_file"
        if pngcheck -q "$png_file"; then
            echo "  ✅ Valid"
        else
            echo "  ❌ Invalid PNG"
            png_errors=$((png_errors + 1))
        fi
    fi
done

if [ $png_errors -gt 0 ]; then
    echo "❌ Found $png_errors PNG validation errors"
    exit 1
fi

echo ""
echo "🔍 Basic security checks..."
# Check for dangerous eval and system calls (but not legitimate exec usage)
if grep -n "eval\|system(" dev-browser; then
    echo "⚠️  Found potentially dangerous commands (eval/system)"
    exit 1
else
    echo "✅ No dangerous eval/system calls found"
fi

# Check for hardcoded secrets (exclude plist keys, comments)
if grep -i "password.*=\|secret.*=\|api_key.*=\|auth.*token.*=" dev-browser | grep -v "# " | grep -v "echo"; then
    echo "⚠️  Potential hardcoded secrets found - please review"
    exit 1
else
    echo "✅ No hardcoded secrets found"
fi

echo ""
echo "📝 File standards check..."
# Check executable permissions
if [ -x "dev-browser" ]; then
    echo "✅ Executable permissions correct"
else
    echo "❌ dev-browser missing executable permissions"
    exit 1
fi

# Check shebang
if head -1 dev-browser | grep -q "#!/bin/bash"; then
    echo "✅ Correct shebang"
else
    echo "❌ Missing or incorrect shebang"
    exit 1
fi

echo ""
echo "🎉 All local checks passed!"
echo ""
echo "💡 Tips:"
echo "  • Run this script before committing changes"
echo "  • The GitHub Actions will run more comprehensive checks"
echo "  • Consider adding this to your git pre-commit hook"