#!/bin/bash

# Test script to demonstrate framework selection options

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

echo "Testing terminal-notifier framework selection options..."
echo "=================================================="

echo ""
echo "1. Testing explicit NSUserNotificationCenter (should work):"
$BINARY --debug -message "NSUserNotificationCenter test" -title "NSUserNotificationCenter Test" -useNSUserNotificationCenter

echo ""
echo "2. Testing explicit UserNotifications (may get stuck due to permissions):"
echo "   Note: This may hang due to permission request - use Ctrl+C to cancel"
$BINARY --debug -message "UserNotifications test" -title "UserNotifications Test" -useUserNotifications

echo ""
echo "3. Testing auto-selection with custom icon (should use UserNotifications but fallback):"
$BINARY --debug -message "Auto-selection test with custom icon" -title "Auto-selection Test" -appIcon "/Applications/Firefox.app/Contents/Resources/firefox.icns"

echo ""
echo "4. Testing auto-selection without custom icon (should use NSUserNotificationCenter):"
$BINARY --debug -message "Auto-selection test without custom icon" -title "Auto-selection Test"

echo ""
echo "Framework selection options:"
echo "-useUserNotifications     Force use of UserNotifications framework (modern)"
echo "-useNSUserNotificationCenter  Force use of NSUserNotificationCenter framework (legacy)"
echo ""
echo "Note: UserNotifications may require system permissions and may hang if not granted."