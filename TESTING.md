# Testing Guide

This document describes the comprehensive testing suite for the Swift terminal-notifier project.

## Test Structure

The tests are organized into several categories for better modularity and maintainability:

```
tests/
├── unit/                    # Unit tests (Swift)
│   ├── test_basic_functionality.swift
│   ├── test_notification_frameworks.swift
│   ├── test_command_line_parsing.swift
│   ├── test_action_buttons.swift
│   └── test_unix_output_streams.swift
├── integration/             # Integration tests (Shell)
│   ├── test_basic_notifications.sh
│   ├── test_image_notifications.sh
│   ├── test_action_buttons.sh
│   └── test_unix_tool_behavior.sh
├── frameworks/              # Framework-specific tests (Shell)
│   └── test_user_notifications.sh
└── examples/                # Example tests (Shell)
    ├── test_basic_examples.sh
    └── test_advanced_examples.sh
```

## Running Tests

### Available Test Targets
```bash
make test                    # Send a test notification
make test-actions           # Run action button tests
make test-unix              # Test Unix tool behavior (stdin/stdout/stderr)
make kill-processes         # Kill any running terminal-notifier processes
```

### Running Individual Tests

You can run individual test files directly:

```bash
# Unit tests
swift tests/unit/test_basic_functionality.swift
swift tests/unit/test_notification_frameworks.swift
swift tests/unit/test_command_line_parsing.swift
swift tests/unit/test_action_buttons.swift
swift tests/unit/test_unix_output_streams.swift

# Integration tests
./tests/integration/test_basic_notifications.sh
./tests/integration/test_image_notifications.sh
./tests/integration/test_action_buttons.sh
./tests/integration/test_unix_tool_behavior.sh

# Framework tests
./tests/frameworks/test_user_notifications.sh

# Example tests
./tests/examples/test_basic_examples.sh
./tests/examples/test_advanced_examples.sh
```

## Test Descriptions

### Unit Tests

#### `test_basic_functionality.swift`
Tests core Swift functionality:
- String operations
- Array operations
- URL validation
- Dictionary operations
- File operations

#### `test_notification_frameworks.swift`
Tests notification framework availability:
- Notification system availability
- Notification system availability
- UserNotifications types availability
- Notification content creation
- Image handling

#### `test_command_line_parsing.swift`
Tests command line argument parsing:
- Basic argument parsing
- Debug flag detection
- Optional arguments
- Content image handling
- Action button parsing (default, text input, destructive)
- Action icon parsing

#### `test_action_buttons.swift`
Tests action button creation and properties:
- Basic action buttons
- Destructive action buttons
- Text input action buttons
- Action buttons with SF Symbol icons (macOS 12.0+)
- Notification category creation

#### `test_unix_output_streams.swift`
Tests Unix output stream concepts:
- Output stream separation (stdout vs stderr)
- UTF-8 encoding for output
- Message formatting

### Integration Tests

#### `test_basic_notifications.sh`
Tests basic notification functionality:
- Basic notifications
- Notifications with subtitle
- Notifications with sound
- Notifications with group ID
- Debug mode

#### `test_image_notifications.sh`
Tests image notification functionality:
- Content image notifications
- App icon notifications
- Both content image and app icon
- Invalid image path handling
- Firefox icon testing

#### `test_action_buttons.sh`
Tests interactive action button functionality:
- Action button argument parsing
- Basic action buttons
- Text input action buttons
- Destructive action buttons
- Action response output format
- Process termination after actions

#### `test_unix_tool_behavior.sh`
Tests Unix tool behavior for proper shell integration:
- Stdin piping (reading messages from pipe)
- Stdout output (action responses, list, help, version)
- Stderr output (debug, errors)
- Exit codes (0 for success, 1 for errors)
- Command line precedence (-message over stdin)
- Output stream separation
- Clean process exit

### Framework-Specific Tests


#### `test_user_notifications.sh`
Tests notification system:
- Explicit UserNotifications usage
- Permission handling
- Fallback to NSUserNotificationCenter
- Custom icon detection
- Content image detection

### Example Tests

#### `test_basic_examples.sh`
Demonstrates basic usage examples:
- Simple notifications
- Notifications with subtitle and sound
- Notifications with group ID
- Debug mode
- Help and version commands

#### `test_advanced_examples.sh`
Demonstrates advanced usage examples:
- Content image notifications
- App icon notifications
- Firefox icon examples
- Explicit framework selection
- URL opening notifications
- Command execution notifications
- App activation notifications

## Test Features

### Unix Tool Behavior
Tests verify proper Unix tool conventions:
- **stdin**: Reads notification message from pipe
- **stdout**: Action responses, list output, help/version
- **stderr**: Debug output, error messages
- **Exit codes**: 0 for success, 1 for errors
- **Piping**: Works seamlessly in shell pipelines

### Debug Mode
All tests support debug mode with `--debug` flag for detailed output.

### Error Handling
Tests verify proper error handling for:
- Invalid image paths
- Permission issues
- Framework limitations


## Test Requirements

- macOS 10.15 or later
- Swift 5.0 or later
- Terminal-notifier app bundle built (`make app`)
- System icons available for image tests
- Firefox installed for Firefox icon tests (optional)

## Troubleshooting

### UserNotifications Permission Issues
Notification tests may fail due to permission issues. This is expected for command-line apps and the tests are designed to handle this gracefully.

### Image Test Failures
If image tests fail, ensure:
- System icons are available at expected paths
- Firefox is installed for Firefox icon tests
- App bundle is properly built and signed

### Debug Output
Use `--debug` flag to see detailed output from tests:
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier --debug -message "Test" -title "Test"
```