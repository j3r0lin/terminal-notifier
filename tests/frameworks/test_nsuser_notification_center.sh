#!/bin/bash

# MARK: - NSUserNotificationCenter Framework Tests
echo "Running NSUserNotificationCenter Framework Tests..."
echo "================================================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Test 1: Explicit NSUserNotificationCenter usage
echo "1. Testing explicit NSUserNotificationCenter usage..."
$BINARY --debug -message "NSUserNotificationCenter test" -title "NSUserNotificationCenter Test" -useNSUserNotificationCenter 2>&1 | grep -q "NSUserNotificationManager"
if [ $? -eq 0 ]; then
    echo "✅ Explicit NSUserNotificationCenter usage"
else
    echo "❌ Explicit NSUserNotificationCenter usage failed"
    exit 1
fi

# Test 2: NSUserNotificationCenter with custom icon (should show limitation message)
echo "2. Testing NSUserNotificationCenter with custom icon..."
$BINARY --debug -message "NSUserNotificationCenter custom icon test" -title "NSUserNotificationCenter Custom Icon Test" -appIcon "/Applications/Firefox.app/Contents/Resources/firefox.icns" -useNSUserNotificationCenter 2>&1 | grep -q "doesn't support custom app icons"
if [ $? -eq 0 ]; then
    echo "✅ NSUserNotificationCenter custom icon limitation detected"
else
    echo "❌ NSUserNotificationCenter custom icon test failed"
    exit 1
fi

# Test 3: NSUserNotificationCenter with content image
echo "3. Testing NSUserNotificationCenter with content image..."
$BINARY --debug -message "NSUserNotificationCenter content image test" -title "NSUserNotificationCenter Content Image Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" -useNSUserNotificationCenter 2>&1 | grep -q "Content image set"
if [ $? -eq 0 ]; then
    echo "✅ NSUserNotificationCenter content image"
else
    echo "❌ NSUserNotificationCenter content image failed"
    exit 1
fi

# Test 4: NSUserNotificationCenter with sound
echo "4. Testing NSUserNotificationCenter with sound..."
$BINARY --debug -message "NSUserNotificationCenter sound test" -title "NSUserNotificationCenter Sound Test" -sound "default" -useNSUserNotificationCenter 2>&1 | grep -q "Notification scheduled"
if [ $? -eq 0 ]; then
    echo "✅ NSUserNotificationCenter sound"
else
    echo "❌ NSUserNotificationCenter sound failed"
    exit 1
fi

# Test 5: NSUserNotificationCenter with group ID
echo "5. Testing NSUserNotificationCenter with group ID..."
$BINARY --debug -message "NSUserNotificationCenter group test" -title "NSUserNotificationCenter Group Test" -group "nsuser-test-group" -useNSUserNotificationCenter 2>&1 | grep -q "Notification scheduled"
if [ $? -eq 0 ]; then
    echo "✅ NSUserNotificationCenter group ID"
else
    echo "❌ NSUserNotificationCenter group ID failed"
    exit 1
fi

echo ""
echo "All NSUserNotificationCenter framework tests passed! 🎉"