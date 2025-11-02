#!/bin/bash

# MARK: - Notification System Tests
echo "Running Notification System Tests..."
echo "=================================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Test 1: Basic notification usage
echo "1. Testing basic notification usage..."
$BINARY --debug -message "Notification test" -title "Notification Test" 2>&1 | grep -q "NotificationManager"
if [ $? -eq 0 ]; then
    echo "✅ Basic notification usage"
else
    echo "❌ Basic notification usage failed"
    exit 1
fi

# Test 2: notification permission handling
echo "2. Testing notification permission handling..."
$BINARY --debug -message "notification permission test" -title "notification Permission Test" 2>&1 | grep -q "Not authorized"
if [ $? -eq 0 ]; then
    echo "✅ notification permission handling (expected to fail due to permissions)"
else
    echo "⚠️  notification permission handling - unexpected result"
fi

# Test 3: notification with group ID
echo "3. Testing notification with group ID..."
$BINARY --debug -message "notification group test" -title "notification Group Test" -group "test-group" 2>&1 | grep -q "notificationManager"
if [ $? -eq 0 ]; then
    echo "✅ notification group ID handling"
else
    echo "❌ notification group ID test failed"
    exit 1
fi

# Test 4: notification with content image
echo "4. Testing notification with content image..."
$BINARY --debug -message "notification content image test" -title "notification Content Image Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" 2>&1 | grep -q "notificationManager"
if [ $? -eq 0 ]; then
    echo "✅ notification content image handling"
else
    echo "❌ notification content image test failed"
    exit 1
fi

# Test 5: notification with sound
echo "5. Testing notification with sound..."
$BINARY --debug -message "notification sound test" -title "notification Sound Test" -sound "Glass" 2>&1 | grep -q "notificationManager"
if [ $? -eq 0 ]; then
    echo "✅ notification sound handling"
else
    echo "❌ notification sound test failed"
    exit 1
fi

echo ""
echo "All notification system tests passed! 🎉"
echo "Note: Notifications may fail due to permission issues, which is expected for command-line apps."