#!/bin/bash

# MARK: - UserNotifications Framework Tests
echo "Running UserNotifications Framework Tests..."
echo "=========================================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Test 1: Explicit UserNotifications usage (may fail due to permissions)
echo "1. Testing explicit UserNotifications usage..."
$BINARY --debug -message "UserNotifications test" -title "UserNotifications Test" -useUserNotifications 2>&1 | grep -q "UserNotificationsManager"
if [ $? -eq 0 ]; then
    echo "✅ Explicit UserNotifications usage"
else
    echo "❌ Explicit UserNotifications usage failed"
    exit 1
fi

# Test 2: UserNotifications permission handling
echo "2. Testing UserNotifications permission handling..."
$BINARY --debug -message "UserNotifications permission test" -title "UserNotifications Permission Test" -useUserNotifications 2>&1 | grep -q "Not authorized"
if [ $? -eq 0 ]; then
    echo "✅ UserNotifications permission handling (expected to fail due to permissions)"
else
    echo "⚠️  UserNotifications permission handling - unexpected result"
fi

# Test 3: UserNotifications fallback to NSUserNotificationCenter
echo "3. Testing UserNotifications fallback to NSUserNotificationCenter..."
$BINARY --debug -message "UserNotifications fallback test" -title "UserNotifications Fallback Test" -useUserNotifications 2>&1 | grep -q "falling back to NSUserNotificationCenter"
if [ $? -eq 0 ]; then
    echo "✅ UserNotifications fallback to NSUserNotificationCenter"
else
    echo "❌ UserNotifications fallback test failed"
    exit 1
fi

# Test 4: UserNotifications with custom icon (should attempt UserNotifications first)
echo "4. Testing UserNotifications with custom icon..."
$BINARY --debug -message "UserNotifications custom icon test" -title "UserNotifications Custom Icon Test" -appIcon "/Applications/Firefox.app/Contents/Resources/firefox.icns" 2>&1 | grep -q "Custom icons detected, using UserNotifications framework"
if [ $? -eq 0 ]; then
    echo "✅ UserNotifications custom icon detection"
else
    echo "❌ UserNotifications custom icon test failed"
    exit 1
fi

# Test 5: UserNotifications with content image (should attempt UserNotifications first)
echo "5. Testing UserNotifications with content image..."
$BINARY --debug -message "UserNotifications content image test" -title "UserNotifications Content Image Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" 2>&1 | grep -q "Custom icons detected, using UserNotifications framework"
if [ $? -eq 0 ]; then
    echo "✅ UserNotifications content image detection"
else
    echo "❌ UserNotifications content image test failed"
    exit 1
fi

echo ""
echo "All UserNotifications framework tests passed! 🎉"
echo "Note: UserNotifications may fail due to permission issues, which is expected for command-line apps."