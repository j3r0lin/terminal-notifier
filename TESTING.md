# Testing Guide

This document describes the comprehensive testing suite for the Swift terminal-notifier project.

## Test Structure

The tests are organized into several categories for better modularity and maintainability:

```
tests/
├── unit/                    # Unit tests (Swift)
│   ├── test_basic_functionality.swift
│   ├── test_notification_frameworks.swift
│   └── test_command_line_parsing.swift
├── integration/             # Integration tests (Shell)
│   ├── test_basic_notifications.sh
│   └── test_image_notifications.sh
├── frameworks/              # Framework-specific tests (Shell)
│   ├── test_nsuser_notification_center.sh
│   └── test_user_notifications.sh
└── examples/                # Example tests (Shell)
    ├── test_basic_examples.sh
    └── test_advanced_examples.sh
```

## Running Tests

### All Tests
```bash
make test                    # Run complete test suite
make test-all-individual     # Run all individual tests
```

### Individual Test Categories

#### Unit Tests
```bash
make test-unit-basic         # Basic functionality tests
make test-unit-frameworks    # Notification framework tests
make test-unit-parsing       # Command line parsing tests
```

#### Integration Tests
```bash
make test-integration-basic  # Basic notifications
make test-integration-images # Image notifications
```

#### Framework-Specific Tests
```bash
make test-framework-nsuser   # NSUserNotificationCenter tests
make test-framework-user     # UserNotifications tests
```

#### Example Tests
```bash
make test-examples-basic     # Basic examples
make test-examples-advanced  # Advanced examples
```

### Quick Tests
```bash
make test-quick              # Unit tests only
make test-ci                 # CI-friendly tests
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
- UserNotifications framework availability
- NSUserNotificationCenter availability
- UserNotifications types availability
- NSUserNotification creation
- Image handling

#### `test_command_line_parsing.swift`
Tests command line argument parsing:
- Basic argument parsing
- Debug flag detection
- Optional arguments
- Framework selection flags

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

### Framework-Specific Tests

#### `test_nsuser_notification_center.sh`
Tests NSUserNotificationCenter framework:
- Explicit NSUserNotificationCenter usage
- Custom icon limitations
- Content image support
- Sound support
- Group ID support

#### `test_user_notifications.sh`
Tests UserNotifications framework:
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

### Framework Selection
The tests demonstrate both automatic and explicit framework selection:

- **Automatic**: The system chooses the best framework based on features
- **Explicit**: Use `-useUserNotifications` or `-useNSUserNotificationCenter`

### Debug Mode
All tests support debug mode with `--debug` flag for detailed output.

### Error Handling
Tests verify proper error handling for:
- Invalid image paths
- Permission issues
- Framework limitations

## Running Individual Tests

You can run any individual test file directly:

```bash
# Unit tests
swift tests/unit/test_basic_functionality.swift
swift tests/unit/test_notification_frameworks.swift
swift tests/unit/test_command_line_parsing.swift

# Integration tests
./tests/integration/test_basic_notifications.sh
./tests/integration/test_image_notifications.sh

# Framework tests
./tests/frameworks/test_nsuser_notification_center.sh
./tests/frameworks/test_user_notifications.sh

# Example tests
./tests/examples/test_basic_examples.sh
./tests/examples/test_advanced_examples.sh
```

## Test Requirements

- macOS 10.15 or later
- Swift 5.0 or later
- Terminal-notifier app bundle built (`make app`)
- System icons available for image tests
- Firefox installed for Firefox icon tests (optional)

## Troubleshooting

### UserNotifications Permission Issues
UserNotifications tests may fail due to permission issues. This is expected for command-line apps and the tests are designed to handle this gracefully by falling back to NSUserNotificationCenter.

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