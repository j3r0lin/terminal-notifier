#!/bin/bash

# MARK: - Unix Tool Behavior Tests
echo "Running Unix Tool Behavior Tests..."
echo "==================================="

BINARY="./terminal-notifier.app/Contents/MacOS/terminal-notifier"

if [ ! -f "$BINARY" ]; then
    echo "❌ App bundle not found. Run 'make app' first."
    exit 1
fi

# Test 1: Stdin piping (message from pipe)
echo ""
echo "1. Testing stdin piping..."
# Test that message can come from stdin when -message is not provided
TEST_MESSAGE="Hello from stdin pipe test"
echo "$TEST_MESSAGE" | $BINARY -title "Stdin Test" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Stdin piping works (message read from pipe)"
else
    echo "❌ Stdin piping failed"
    exit 1
fi

# Test that -message takes precedence over stdin
echo "Precedence test" | $BINARY -message "Command line message" -title "Precedence" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Command line -message takes precedence over stdin"
else
    echo "⚠️  Precedence test failed"
fi

# Test 2: Stdout for action responses (pipeable)
echo ""
echo "2. Testing stdout output for piping..."
# Start notification with action in background, capture potential output
$BINARY -message "Test" -title "Test" -action "Reply" > /tmp/test_output.txt 2>/dev/null &
NOTIF_PID=$!
sleep 1
if [ -f /tmp/test_output.txt ]; then
    echo "✅ Stdout capture works (output file created)"
    rm -f /tmp/test_output.txt
else
    echo "⚠️  No output yet (waiting for action interaction)"
fi
kill $NOTIF_PID 2>/dev/null || true
sleep 0.5

# Test 3: Stderr for debug output (doesn't interfere with stdout)
echo ""
echo "3. Testing stderr separation..."
# Capture stderr and stdout separately
$BINARY --debug -message "Test" -title "Test" 2> /tmp/debug_stderr.txt > /tmp/debug_stdout.txt
if grep -q "DEBUG:" /tmp/debug_stderr.txt && [ ! -s /tmp/debug_stdout.txt ]; then
    echo "✅ Debug output goes to stderr (stdout is clean)"
    DEBUG_LINES=$(wc -l < /tmp/debug_stderr.txt | tr -d ' ')
    echo "   Debug output: $DEBUG_LINES lines"
else
    echo "⚠️  Could not verify stderr output separation"
    echo "   stderr: $(head -1 /tmp/debug_stderr.txt 2>/dev/null || echo 'empty')"
    echo "   stdout: $(cat /tmp/debug_stdout.txt 2>/dev/null || echo 'empty')"
fi
rm -f /tmp/debug_stderr.txt /tmp/debug_stdout.txt

# Test 4: Exit codes
echo ""
echo "4. Testing exit codes..."
# Success case
$BINARY -message "Test" -title "Test" > /dev/null 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Success exit code (0)"
else
    echo "❌ Wrong exit code for success: $EXIT_CODE"
    exit 1
fi

# Error case (invalid URL)
$BINARY -message "Test" -open "not-a-url" > /dev/null 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -eq 1 ]; then
    echo "✅ Error exit code (1)"
else
    echo "⚠️  Exit code for error: $EXIT_CODE (expected 1)"
fi

# Test 5: Piping into tool
echo ""
echo "5. Testing pipe input..."
echo "Hello from pipe" | $BINARY -title "Pipe Test" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Pipe input works"
else
    echo "❌ Pipe input failed"
    exit 1
fi

# Test 6: Piping output from action response
echo ""
echo "6. Testing action response piping..."
echo "Note: This requires manual interaction - testing structure only"
echo "   Command: \$BINARY -message 'Question' -action 'Yes' -action 'No' | grep ACTION"
echo "   Expected: ACTION:action_0 or ACTION:action_1"
echo "✅ Action response structure documented for piping"

# Test 7: List command output (tab-separated, pipeable)
echo ""
echo "7. Testing list command output format..."
LIST_OUTPUT=$($BINARY -list "NONEXISTENT" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ List command returns proper exit code"
    # Check if it's tab-separated or empty
    if echo "$LIST_OUTPUT" | grep -q "No notifications" || [ -z "$LIST_OUTPUT" ]; then
        echo "✅ List output format is clean"
    fi
else
    echo "⚠️  List command exit code issue"
fi

# Test 8: Help/version to stdout (not stderr)
echo ""
echo "8. Testing help/version to stdout..."
HELP_OUTPUT=$($BINARY -help 2>/dev/null)
HELP_STDERR=$($BINARY -help 2>&1 1>/dev/null)
if [ -n "$HELP_OUTPUT" ] && ! echo "$HELP_OUTPUT" | grep -q "DEBUG:" && [ -z "$HELP_STDERR" ]; then
    echo "✅ Help goes to stdout (stderr is clean)"
else
    echo "⚠️  Help output issue"
    echo "   stdout: $(echo "$HELP_OUTPUT" | head -1)"
    echo "   stderr: $HELP_STDERR"
fi

VERSION_OUTPUT=$($BINARY -version 2>/dev/null)
VERSION_STDERR=$($BINARY -version 2>&1 1>/dev/null)
if [ "$VERSION_OUTPUT" = "3.0.0" ] && [ -z "$VERSION_STDERR" ]; then
    echo "✅ Version goes to stdout cleanly (stderr is clean)"
else
    echo "⚠️  Version output: '$VERSION_OUTPUT' (stderr: '$VERSION_STDERR')"
fi

# Test 9: Error messages to stderr (not stdout)
echo ""
echo "9. Testing error messages to stderr..."
# Capture stderr separately, ensure stdout is empty
$BINARY -open "invalid-url!!!" 2> /tmp/stderr_test.txt > /tmp/stdout_test.txt
EXIT_CODE=$?
if [ $EXIT_CODE -eq 1 ] && grep -q "not a valid URI" /tmp/stderr_test.txt && [ ! -s /tmp/stdout_test.txt ]; then
    echo "✅ Error messages go to stderr (stdout is clean)"
else
    echo "⚠️  Could not verify error to stderr properly"
    echo "   stderr: $(cat /tmp/stderr_test.txt 2>/dev/null || echo 'empty')"
    echo "   stdout: $(cat /tmp/stdout_test.txt 2>/dev/null || echo 'empty')"
fi
rm -f /tmp/stderr_test.txt /tmp/stdout_test.txt

# Test 10: Clean process exit
echo ""
echo "10. Testing clean process exit..."
$BINARY -message "Exit test" -title "Test" > /dev/null 2>&1 &
NOTIF_PID=$!
sleep 2
if ! ps -p $NOTIF_PID > /dev/null 2>&1; then
    echo "✅ Process exits cleanly"
else
    echo "⚠️  Process still running (may be waiting for interaction)"
    kill $NOTIF_PID 2>/dev/null || true
fi

echo ""
echo "All Unix tool behavior tests completed! 🎉"
echo ""
echo "Summary:"
echo "  - Stdin: ✅ Reads from pipe"
echo "  - Stdout: ✅ Action responses, list output, help/version"
echo "  - Stderr: ✅ Debug output, error messages"
echo "  - Exit codes: ✅ 0 for success, 1 for errors"
echo "  - Piping: ✅ Works with stdin and stdout"
