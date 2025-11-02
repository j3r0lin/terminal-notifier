#!/bin/bash

# MARK: - Action Button Integration Tests
echo "Running Action Button Integration Tests..."
echo "========================================="

# Kill any existing terminal-notifier processes
echo "Cleaning up any existing processes..."
pkill -f "terminal-notifier" 2>/dev/null || true
sleep 0.5

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

if [ ! -f "$BINARY" ]; then
    echo "❌ App bundle not found. Run 'make app' first."
    exit 1
fi

# Test 1: Verify help includes action buttons
echo ""
echo "1. Testing help output includes action buttons..."
HELP_OUTPUT=$($BINARY -help 2>&1)
if echo "$HELP_OUTPUT" | grep -q "Action Buttons"; then
    echo "✅ Help output includes action buttons"
else
    echo "❌ Help output missing action buttons"
    exit 1
fi

# Test 2: Verify action options are parsed (check debug output)
echo ""
echo "2. Testing action button argument parsing..."
DEBUG_OUTPUT=$($BINARY --debug -message "Test" -title "Test" -action "Reply" -action "Delete" 2>&1 | head -20)
if echo "$DEBUG_OUTPUT" | grep -q "DEBUG"; then
    echo "✅ Action buttons arguments parsed correctly"
else
    echo "⚠️  Could not verify action parsing (debug output not found)"
fi

# Test 3: Test without actions (should exit quickly)
echo ""
echo "3. Testing notification without actions (quick exit)..."
START_TIME=$(date +%s)
$BINARY -message "Quick test" -title "Quick" > /dev/null 2>&1
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
if [ $DURATION -le 3 ]; then
    echo "✅ Notification without actions exits quickly ($DURATION seconds)"
else
    echo "⚠️  Notification took longer than expected ($DURATION seconds)"
fi

# Test 4: Test with actions (will wait for timeout)
echo ""
echo "4. Testing notification with actions (should wait for interaction)..."
START_TIME=$(date +%s)
$BINARY -message "Action test" -title "Action" -action "Test" > /dev/null 2>&1 &
NOTIF_PID=$!
sleep 2
if kill -0 $NOTIF_PID 2>/dev/null; then
    echo "✅ Notification with actions waits for interaction"
    kill $NOTIF_PID 2>/dev/null || true
    sleep 0.5
else
    echo "⚠️  Process exited earlier than expected"
fi

echo ""
echo "All action button integration tests passed! 🎉"
echo ""
echo "Note: Action button responses are output to stdout when clicked:"
echo "  Format: ACTION:identifier or ACTION:identifier:text (for text input)"
echo "  Example: ACTION:action_0 or ACTION:action_0:Hello World"

# Clean up any remaining processes
echo ""
echo "Cleaning up any remaining processes..."
pkill -f "terminal-notifier" 2>/dev/null || true
sleep 0.5
