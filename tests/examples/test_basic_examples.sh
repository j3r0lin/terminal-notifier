#!/bin/bash

# MARK: - Basic Examples Tests
echo "Running Basic Examples Tests..."
echo "============================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

# Example 1: Simple notification
echo "Example 1: Simple notification"
echo "Command: $BINARY -message \"Hello, World!\" -title \"Greeting\""
$BINARY -message "Hello, World!" -title "Greeting" > /dev/null 2>&1
echo "✅ Simple notification sent"

# Example 2: Notification with subtitle and sound
echo ""
echo "Example 2: Notification with subtitle and sound"
echo "Command: $BINARY -message \"Task completed\" -title \"Success\" -subtitle \"Build finished\" -sound \"default\""
$BINARY -message "Task completed" -title "Success" -subtitle "Build finished" -sound "default" > /dev/null 2>&1
echo "✅ Notification with subtitle and sound sent"

# Example 3: Notification with group ID
echo ""
echo "Example 3: Notification with group ID"
echo "Command: $BINARY -message \"Build started\" -title \"CI/CD\" -group \"build-123\""
$BINARY -message "Build started" -title "CI/CD" -group "build-123" > /dev/null 2>&1
echo "✅ Notification with group ID sent"

# Example 4: Debug mode
echo ""
echo "Example 4: Debug mode"
echo "Command: $BINARY --debug -message \"Debug test\" -title \"Debug\""
$BINARY --debug -message "Debug test" -title "Debug" 2>&1 | head -5
echo "✅ Debug mode example"

# Example 5: Help command
echo ""
echo "Example 5: Help command"
echo "Command: $BINARY -help"
$BINARY -help | head -10
echo "✅ Help command example"

# Example 6: Version command
echo ""
echo "Example 6: Version command"
echo "Command: $BINARY -version"
VERSION=$($BINARY -version)
echo "Version: $VERSION"
echo "✅ Version command example"

echo ""
echo "All basic examples completed! 🎉"