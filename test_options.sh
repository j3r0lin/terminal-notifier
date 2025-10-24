#!/bin/bash

# Test script for all terminal-notifier options
# This script tests various command-line options to ensure they work correctly

set -e

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

echo "Testing terminal-notifier Swift version..."
echo "========================================"

# Test basic functionality
echo "1. Testing basic notification..."
$BINARY -message "Basic test" -title "Test Title" > /dev/null 2>&1
echo "✅ Basic notification"

# Test with subtitle
echo "2. Testing with subtitle..."
$BINARY -message "Subtitle test" -title "Test Title" -subtitle "Test Subtitle" > /dev/null 2>&1
echo "✅ Subtitle notification"

# Test with sound
echo "3. Testing with sound..."
$BINARY -message "Sound test" -title "Test Title" -sound "default" > /dev/null 2>&1
echo "✅ Sound notification"

# Test with group
echo "4. Testing with group..."
$BINARY -message "Group test" -title "Test Title" -group "test-group-$(date +%s)" > /dev/null 2>&1
echo "✅ Group notification"

# Test with activate
echo "5. Testing with activate..."
$BINARY -message "Activate test" -title "Test Title" -activate "com.apple.finder" > /dev/null 2>&1
echo "✅ Activate notification"

# Test with open URL
echo "6. Testing with open URL..."
$BINARY -message "Open test" -title "Test Title" -open "https://www.apple.com" > /dev/null 2>&1
echo "✅ Open URL notification"

# Test with execute command
echo "7. Testing with execute command..."
$BINARY -message "Execute test" -title "Test Title" -execute "echo 'Hello from notification'" > /dev/null 2>&1
echo "✅ Execute command notification"

# Test with ignoreDnD
echo "8. Testing with ignoreDnD..."
$BINARY -message "DnD test" -title "Test Title" -ignoreDnD > /dev/null 2>&1
echo "✅ Ignore DnD notification"

# Test debug mode
echo "9. Testing debug mode..."
DEBUG_OUTPUT=$($BINARY --debug -message "Debug test" -title "Debug" 2>&1)
if echo "$DEBUG_OUTPUT" | grep -q "DEBUG:"; then
    echo "✅ Debug mode"
else
    echo "❌ Debug mode failed"
    exit 1
fi

# Test help command
echo "10. Testing help command..."
HELP_OUTPUT=$($BINARY -help 2>&1)
if echo "$HELP_OUTPUT" | grep -q "terminal-notifier"; then
    echo "✅ Help command"
else
    echo "❌ Help command failed"
    exit 1
fi

# Test version command
echo "11. Testing version command..."
VERSION_OUTPUT=$($BINARY -version 2>&1)
if echo "$VERSION_OUTPUT" | grep -q "3.0.0"; then
    echo "✅ Version command"
else
    echo "❌ Version command failed"
    exit 1
fi

# Test list command
echo "12. Testing list command..."
$BINARY -list "ALL" > /dev/null 2>&1
echo "✅ List command"

# Test piped input
echo "13. Testing piped input..."
echo "Piped message" | $BINARY -title "Piped Test" > /dev/null 2>&1
echo "✅ Piped input"

# Test error handling (invalid URL)
echo "14. Testing error handling..."
if $BINARY -message "Error test" -title "Test" -open "invalid-url" 2>&1 | grep -q "not a valid URI"; then
    echo "✅ Error handling"
else
    echo "❌ Error handling failed"
    exit 1
fi

# Test with content image (using a system icon)
echo "15. Testing with content image..."
$BINARY -message "Content image test" -title "Image Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" > /dev/null 2>&1
echo "✅ Content image notification"

# Test with app icon (using a different system icon)
echo "16. Testing with app icon..."
$BINARY -message "App icon test" -title "App Icon Test" -appIcon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" > /dev/null 2>&1
echo "✅ App icon notification"

# Test with both content image and app icon (using different icons)
echo "17. Testing with both images..."
$BINARY -message "Both images test" -title "Both Images Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" -appIcon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" > /dev/null 2>&1
echo "✅ Both images notification"

# Test with invalid image path
echo "18. Testing with invalid image path..."
$BINARY -message "Invalid image test" -title "Invalid Image Test" -contentImage "/nonexistent/path/image.icns" > /dev/null 2>&1
echo "✅ Invalid image handling"

echo ""
echo "========================================"
echo "All tests passed! 🎉"