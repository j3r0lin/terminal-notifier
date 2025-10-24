#!/bin/bash

# MARK: - Image Notifications Integration Tests
echo "Running Image Notifications Integration Tests..."
echo "=============================================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Test 1: Content image notification
echo "1. Testing content image notification..."
$BINARY -message "Content image test" -title "Content Image Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Content image notification"
else
    echo "❌ Content image notification failed"
    exit 1
fi

# Test 2: App icon notification (will show terminal-notifier icon due to NSUserNotificationCenter limitation)
echo "2. Testing app icon notification..."
$BINARY -message "App icon test" -title "App Icon Test" -appIcon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ App icon notification"
else
    echo "❌ App icon notification failed"
    exit 1
fi

# Test 3: Both content image and app icon
echo "3. Testing both content image and app icon..."
$BINARY -message "Both images test" -title "Both Images Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" -appIcon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Both images notification"
else
    echo "❌ Both images notification failed"
    exit 1
fi

# Test 4: Invalid image path handling
echo "4. Testing invalid image path handling..."
$BINARY -message "Invalid image test" -title "Invalid Image Test" -contentImage "/nonexistent/path/image.icns" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Invalid image handling"
else
    echo "❌ Invalid image handling failed"
    exit 1
fi

# Test 5: Firefox icon test
echo "5. Testing Firefox icon..."
if [ -f "/Applications/Firefox.app/Contents/Resources/firefox.icns" ]; then
    $BINARY -message "Firefox icon test" -title "Firefox Icon Test" -appIcon "/Applications/Firefox.app/Contents/Resources/firefox.icns" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Firefox icon notification"
    else
        echo "❌ Firefox icon notification failed"
        exit 1
    fi
else
    echo "⚠️  Firefox not found, skipping Firefox icon test"
fi

echo ""
echo "All image notifications integration tests passed! 🎉"