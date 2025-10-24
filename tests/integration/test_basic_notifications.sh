#!/bin/bash

# MARK: - Basic Notifications Integration Tests
echo "Running Basic Notifications Integration Tests..."
echo "=============================================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Test 1: Basic notification
echo "1. Testing basic notification..."
$BINARY -message "Basic notification test" -title "Basic Test" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Basic notification"
else
    echo "❌ Basic notification failed"
    exit 1
fi

# Test 2: Notification with subtitle
echo "2. Testing notification with subtitle..."
$BINARY -message "Subtitle test" -title "Subtitle Test" -subtitle "This is a subtitle" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Subtitle notification"
else
    echo "❌ Subtitle notification failed"
    exit 1
fi

# Test 3: Notification with sound
echo "3. Testing notification with sound..."
$BINARY -message "Sound test" -title "Sound Test" -sound "default" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Sound notification"
else
    echo "❌ Sound notification failed"
    exit 1
fi

# Test 4: Notification with group ID
echo "4. Testing notification with group ID..."
$BINARY -message "Group test" -title "Group Test" -group "test-group" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Group notification"
else
    echo "❌ Group notification failed"
    exit 1
fi

# Test 5: Debug mode
echo "5. Testing debug mode..."
$BINARY --debug -message "Debug test" -title "Debug Test" 2>&1 | grep -q "DEBUG:"
if [ $? -eq 0 ]; then
    echo "✅ Debug mode"
else
    echo "❌ Debug mode failed"
    exit 1
fi

echo ""
echo "All basic notifications integration tests passed! 🎉"