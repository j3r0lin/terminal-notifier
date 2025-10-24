#!/bin/bash

# MARK: - Advanced Examples Tests
echo "Running Advanced Examples Tests..."
echo "================================"

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Example 1: Notification with content image
echo "Example 1: Notification with content image"
echo "Command: $BINARY -message \"Image notification\" -title \"Image Test\" -contentImage \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns\""
$BINARY -message "Image notification" -title "Image Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" > /dev/null 2>&1
echo "✅ Content image notification sent"

# Example 2: Notification with app icon (will show terminal-notifier icon due to NSUserNotificationCenter limitation)
echo ""
echo "Example 2: Notification with app icon"
echo "Command: $BINARY -message \"App icon notification\" -title \"App Icon Test\" -appIcon \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns\""
$BINARY -message "App icon notification" -title "App Icon Test" -appIcon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" > /dev/null 2>&1
echo "✅ App icon notification sent (shows terminal-notifier icon due to NSUserNotificationCenter limitation)"

# Example 3: Firefox icon example
echo ""
echo "Example 3: Firefox icon example"
if [ -f "/Applications/Firefox.app/Contents/Resources/firefox.icns" ]; then
    echo "Command: $BINARY -message \"Firefox notification\" -title \"Firefox Test\" -appIcon \"/Applications/Firefox.app/Contents/Resources/firefox.icns\""
    $BINARY -message "Firefox notification" -title "Firefox Test" -appIcon "/Applications/Firefox.app/Contents/Resources/firefox.icns" > /dev/null 2>&1
    echo "✅ Firefox icon notification sent"
else
    echo "⚠️  Firefox not found, skipping Firefox icon example"
fi

# Example 4: Explicit framework selection
echo ""
echo "Example 4: Explicit NSUserNotificationCenter selection"
echo "Command: $BINARY -message \"NSUserNotificationCenter test\" -title \"Framework Test\" -useNSUserNotificationCenter"
$BINARY -message "NSUserNotificationCenter test" -title "Framework Test" -useNSUserNotificationCenter > /dev/null 2>&1
echo "✅ NSUserNotificationCenter explicit selection sent"

# Example 5: Explicit UserNotifications selection (may fail due to permissions)
echo ""
echo "Example 5: Explicit UserNotifications selection"
echo "Command: $BINARY -message \"UserNotifications test\" -title \"Framework Test\" -useUserNotifications"
$BINARY -message "UserNotifications test" -title "Framework Test" -useUserNotifications > /dev/null 2>&1
echo "✅ UserNotifications explicit selection sent (may have fallen back to NSUserNotificationCenter)"

# Example 6: Notification with URL opening
echo ""
echo "Example 6: Notification with URL opening"
echo "Command: $BINARY -message \"Click to open website\" -title \"URL Test\" -open \"https://github.com/julienXX/terminal-notifier\""
$BINARY -message "Click to open website" -title "URL Test" -open "https://github.com/julienXX/terminal-notifier" > /dev/null 2>&1
echo "✅ URL opening notification sent"

# Example 7: Notification with command execution
echo ""
echo "Example 7: Notification with command execution"
echo "Command: $BINARY -message \"Click to execute command\" -title \"Command Test\" -execute \"echo 'Command executed'\""
$BINARY -message "Click to execute command" -title "Command Test" -execute "echo 'Command executed'" > /dev/null 2>&1
echo "✅ Command execution notification sent"

# Example 8: Notification with app activation
echo ""
echo "Example 8: Notification with app activation"
echo "Command: $BINARY -message \"Click to activate app\" -title \"Activation Test\" -activate \"com.apple.finder\""
$BINARY -message "Click to activate app" -title "Activation Test" -activate "com.apple.finder" > /dev/null 2>&1
echo "✅ App activation notification sent"

echo ""
echo "All advanced examples completed! 🎉"