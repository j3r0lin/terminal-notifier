#!/bin/bash

# MARK: - Custom Icon Examples
echo "Custom Icon Build Examples"
echo "========================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_example() {
    echo -e "${BLUE}[EXAMPLE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Example 1: Build with Firefox icon
print_example "1. Building app bundle with Firefox icon..."
if [ -f "/Applications/Firefox.app/Contents/Resources/firefox.icns" ]; then
    make app-firefox
    print_success "Firefox app bundle created: terminal-notifier-firefox.app"
    
    # Test the Firefox app bundle
    print_info "Testing Firefox app bundle..."
    ./terminal-notifier-firefox.app/Contents/MacOS/terminal-notifier \
        -message "Hello from Firefox-themed notifier!" \
        -title "Firefox Icon Test" \
        -sound "default"
    print_success "Firefox notification sent!"
else
    print_info "Firefox not found, skipping Firefox example"
fi

echo ""

# Example 2: Build with Terminal icon
print_example "2. Building app bundle with Terminal icon..."
if [ -f "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns" ]; then
    make app-terminal
    print_success "Terminal app bundle created: terminal-notifier-terminal.app"
    
    # Test the Terminal app bundle
    print_info "Testing Terminal app bundle..."
    ./terminal-notifier-terminal.app/Contents/MacOS/terminal-notifier \
        -message "Hello from Terminal-themed notifier!" \
        -title "Terminal Icon Test" \
        -sound "default"
    print_success "Terminal notification sent!"
else
    print_info "Terminal not found, skipping Terminal example"
fi

echo ""

# Example 3: Build with custom icon from file
print_example "3. Building app bundle with custom icon from file..."
if [ -f "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" ]; then
    make app-with-icon ICON_PATH="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" OUTPUT_NAME="terminal-notifier-generic"
    print_success "Generic app bundle created: terminal-notifier-generic.app"
    
    # Test the Generic app bundle
    print_info "Testing Generic app bundle..."
    ./terminal-notifier-generic.app/Contents/MacOS/terminal-notifier \
        -message "Hello from Generic-themed notifier!" \
        -title "Generic Icon Test" \
        -sound "default"
    print_success "Generic notification sent!"
else
    print_info "Generic icon not found, skipping Generic example"
fi

echo ""

# Example 4: Build with icon from URL
print_example "4. Building app bundle with icon from URL..."
print_info "This example downloads an icon from a URL and builds an app bundle"
print_info "Note: This requires internet connection and curl"

# Use a simple icon URL (GitHub's octocat icon as an example)
ICON_URL="https://github.com/fluidicon.png"
print_info "Downloading icon from: $ICON_URL"

if command -v curl >/dev/null 2>&1; then
    make app-icon-url ICON_URL="$ICON_URL" OUTPUT_NAME="terminal-notifier-github"
    print_success "GitHub app bundle created: terminal-notifier-github.app"
    
    # Test the GitHub app bundle
    print_info "Testing GitHub app bundle..."
    ./terminal-notifier-github.app/Contents/MacOS/terminal-notifier \
        -message "Hello from GitHub-themed notifier!" \
        -title "GitHub Icon Test" \
        -sound "default"
    print_success "GitHub notification sent!"
else
    print_info "curl not available, skipping URL example"
fi

echo ""

# Example 5: Show how to use different app bundles
print_example "5. Using different app bundles for different purposes..."
print_info "You can now use different app bundles for different notification types:"
echo ""
echo "  # Development notifications with Terminal icon"
echo "  ./terminal-notifier-terminal.app/Contents/MacOS/terminal-notifier \\"
echo "    -message \"Build completed\" -title \"Dev Build\""
echo ""
echo "  # Web notifications with Firefox icon"
echo "  ./terminal-notifier-firefox.app/Contents/MacOS/terminal-notifier \\"
echo "    -message \"Website updated\" -title \"Web Update\""
echo ""
echo "  # General notifications with default icon"
echo "  ./terminal-notifier.app/Contents/MacOS/terminal-notifier \\"
echo "    -message \"General notification\" -title \"General\""

echo ""

# Example 6: Show app bundle information
print_example "6. App bundle information..."
print_info "Created app bundles:"
for app in *.app; do
    if [ -d "$app" ]; then
        echo "  - $app ($(du -sh "$app" | cut -f1))"
        if [ -f "$app/Contents/Resources/AppIcon.icns" ]; then
            echo "    └── Custom icon: $app/Contents/Resources/AppIcon.icns"
        fi
    fi
done

echo ""

print_success "Custom icon examples completed! 🎉"
print_info "All app bundles are ready to use with their custom icons."
print_info "The notifications will display the custom app icon instead of the default terminal-notifier icon."