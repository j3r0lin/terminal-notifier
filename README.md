# terminal-notifier

[![GitHub release](https://img.shields.io/github/release/julienXX/terminal-notifier.svg)](https://github.com/julienXX/terminal-notifier/releases)

terminal-notifier is a command-line tool to send macOS User Notifications, written in Swift for macOS 10.15 and higher.

## Features

- Send macOS notifications from the command line
- Support for titles, subtitles, and custom sounds
- Group notifications and remove previous ones
- Open URLs or activate applications when clicked
- Execute shell commands when notifications are clicked
- Interactive action buttons with text input support (macOS 11.0+)
- Action buttons with SF Symbol icons (macOS 12.0+)
- Support for content images and custom app bundles
- Bypass Do Not Disturb mode
- List and remove existing notifications
- Debug mode for troubleshooting

## Installation

### Swift Package Manager

```bash
git clone https://github.com/julienXX/terminal-notifier.git
cd terminal-notifier
swift build -c release
```

### Ruby Gem

```bash
gem install terminal-notifier
```

### Homebrew

```bash
brew install terminal-notifier
```

## Custom Icon Builds

Since macOS doesn't support custom app icons in notifications, you can build app bundles with custom icons instead:

### Build with Custom Icon

```bash
# Build with your own icon file
make app-with-icon ICON_PATH=/path/to/your/icon.icns

# Build with icon from URL
make app-icon-url ICON_URL=https://example.com/icon.png

# Default build includes Terminal icon
make app
```

### Manual Build with Custom Icon

```bash
# Use the build script directly
./scripts/build_with_icon.sh /path/to/icon.icns my-custom-notifier

# The script supports .icns, .png, .jpg, .jpeg files
# It will automatically convert non-ICNS files to ICNS format
```

### Signing Requirements

**For custom app bundles, you need:**
- **Xcode Command Line Tools** (for `codesign` command)
- **No developer account required** - uses ad-hoc signing
- **macOS system** - signing only works on macOS

The build process automatically signs the app bundle with **ad-hoc signing**, which doesn't require specific developer credentials but is necessary for macOS to recognize the app bundle properly. This means anyone can build custom app bundles without needing an Apple Developer account.

**If you don't have Xcode Command Line Tools:**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Then build your custom app bundle
make app-with-icon ICON_PATH=/path/to/your/icon.icns
```

For detailed information about code signing, see [SIGNING_GUIDE.md](SIGNING_GUIDE.md).

### Using Custom Icon App Bundles

```bash
# Use your custom app bundle
./my-custom-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Hello from custom app!" \
  -title "Custom Icon Test"

# All notifications will use your custom icon
```

## Usage

### Swift Version

```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier -[message|list|remove] [VALUE|ID|ID] [options]
```

### Ruby Gem

```bash
terminal-notifier -[message|list|remove] [VALUE|ID|ID] [options]
```

## Options

### Required (unless message data is piped to the tool)

- `-help` - Display help banner
- `-version` - Display version information
- `-message VALUE` - The notification message
- `-remove ID` - Remove a notification with the specified group ID
- `-list ID` - List notifications (use 'ALL' to see all notifications)

### Optional

- `-title VALUE` - The notification title (defaults to 'Terminal')
- `-subtitle VALUE` - The notification subtitle
- `-sound NAME` - Sound to play (use 'default' for default sound)
- `-group ID` - Group identifier (removes old notifications with same ID)
- `-activate ID` - Bundle identifier of app to activate when clicked
- `-contentImage URL` - URL of image to display in notification
- `-open URL` - URL to open when notification is clicked
- `-execute COMMAND` - Shell command to execute when clicked
- `-ignoreDnD` - Send notification even if Do Not Disturb is enabled
- `--debug` - Enable debug output
- `-action TITLE` - Add an action button (macOS 11.0+)
- `-action-text TITLE` - Add a text input action button (macOS 11.0+)
- `-prompt TITLE` - Alias for `-action-text` (user can reply to notification)
- `-action-destructive TITLE` - Add a destructive action button shown in red (macOS 11.0+)
- `-action-icon TITLE:ICON` - Add an action button with SF Symbol icon (macOS 12.0+)

## Unix Tool Behavior

terminal-notifier follows Unix conventions for proper integration with shell scripts and pipelines:

### Input/Output Streams

- **stdin**: Reads notification message from pipe if `-message` is not provided
- **stdout**: Action responses, list output, help, and version information
- **stderr**: Debug output (`--debug`), error messages, informational messages

### Exit Codes

- **0**: Success (notification sent, list/remove completed)
- **1**: Error (invalid arguments, failed operations)

### Piping Examples

```bash
# Pipe message from stdin
echo "Build complete!" | terminal-notifier -title "Build"

# Pipe action response to another command
terminal-notifier -message "Continue?" -action "Yes" -action "No" | \
    grep -q "action_0" && echo "User chose Yes" || echo "User chose No"

# Pipe list output for processing
terminal-notifier -list "ALL" | awk '{print $1}'  # Extract group IDs

# Chain commands
cat status.txt | terminal-notifier -title "Status" && \
    echo "Notification sent" >> log.txt
```

### Action Response Format

Action button responses are output to stdout in a pipeable format:
- Regular action: `ACTION:identifier`
- Text input action (prompt/reply): `ACTION:identifier:text`

Example usage in scripts:
```bash
RESPONSE=$(terminal-notifier -message "What to do?" \
    -action "Continue" \
    -action "Cancel")
if echo "$RESPONSE" | grep -q "action_0"; then
    echo "User chose Continue"
elif echo "$RESPONSE" | grep -q "action_1"; then
    echo "User chose Cancel"
fi
```

### Prompt/Reply Notifications

You can prompt users for text input and pipe their response to other commands. **See [ACTION_EXAMPLES.md](ACTION_EXAMPLES.md) for comprehensive real-world examples.**

```bash
# Simple prompt
USER_INPUT=$(terminal-notifier -message "Enter commit message:" -prompt "OK")

# Extract the user input text (format: ACTION:identifier:text)
COMMIT_MSG=$(echo "$USER_INPUT" | sed 's/ACTION:action_0://')
echo "$COMMIT_MSG" > commit.txt

# Use in a pipeline
terminal-notifier -message "Review?" -prompt "Comment" | \
    sed 's/ACTION:action_0://' | \
    xargs -I {} echo "User comment: {}"

# Multiple prompts with different actions
RESPONSE=$(terminal-notifier -message "Choose action:" \
    -prompt "Add Note" \
    -action "Skip")
# Response will be either "ACTION:action_0:note_text" or "ACTION:action_1"
```

## Examples

### Basic notification
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier -message "Hello, World!" -title "Greeting"
```

### With piped data
```bash
echo "Piped Message Data!" | ./terminal-notifier.app/Contents/MacOS/terminal-notifier -sound default
```

### Custom icon and URL
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -title "Project Update" \
  -subtitle "Build Complete" \
  -message "Version 2.1.0 is ready" \
  -open "https://github.com/your-repo"
```

### Prompt/Reply notification
```bash
# Ask user for input and use it in a script
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter commit message:" \
  -prompt "Commit")

# Extract the user's input
COMMIT_MSG=$(echo "$RESPONSE" | sed 's/ACTION:action_0://')

# Use the input
if [ -n "$COMMIT_MSG" ]; then
  git commit -m "$COMMIT_MSG"
fi
```

### Grouped notifications
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -group "build-status" \
  -title "Build Started" \
  -message "Compiling project..."
```

### Execute command on click
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Build complete!" \
  -execute "open /path/to/project"
```

### Debug mode
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier --debug -message "Debug test" -title "Debug"
```

### Interactive notifications with action buttons (macOS 11.0+)
```bash
# Simple action buttons
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Build complete!" \
  -title "Project Status" \
  -action "View" \
  -action "Dismiss"

# Text input action (user can type a response)
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Pull request ready for review" \
  -title "Code Review" \
  -action-text "Reply" \
  -action "Approve" \
  -action-destructive "Reject"

# Using -prompt alias (same as -action-text, outputs to stdout for piping)
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter your name:" \
  -prompt "Submit" \
  -action "Skip"

# Action buttons with icons (macOS 12.0+)
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "New message received" \
  -title "Messages" \
  -action-icon "Reply:envelope.fill" \
  -action-icon "Delete:trash.fill"

# Capture action button responses in scripts
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "What would you like to do?" \
  -title "Question" \
  -action "Yes" \
  -action "No")
echo "User selected: $RESPONSE"
# Output format: ACTION:action_0 or ACTION:action_0:user_text (for text input)
```

## Building

### Requirements
- macOS 10.15 or later
- Swift 5.7 or later

### Build commands
```bash
# Debug build
swift build

# Release build
swift build -c release

# Run tests
make test

# Clean build
swift package clean
```

## Development

The Swift version is organized into three main files:

- `Sources/TerminalNotifier/main.swift` - Application entry point
- `Sources/TerminalNotifier/NotificationManager.swift` - Notification handling
- `Sources/TerminalNotifier/ArgumentParser.swift` - Command-line argument parsing

## Testing

Run the test suite:
```bash
make test
```

This runs a comprehensive test suite covering:
- URL validation
- Argument parsing
- Debug flag handling
- Data structure operations
- File operations

## Migration from Objective-C Version

This Swift rewrite provides improved functionality while maintaining compatibility with the original Objective-C version. Here's what changed:

### Feature Comparison

| Feature | Objective-C Version | Swift Version | Status |
|---------|---------------------|---------------|--------|
| **Core Functionality** |
| Basic notifications | ✅ | ✅ | **Maintained** |
| Title, subtitle, message | ✅ | ✅ | **Maintained** |
| Custom sounds | ✅ | ✅ | **Maintained** |
| Group notifications | ✅ | ✅ | **Maintained** |
| Remove notifications | ✅ | ✅ | **Maintained** |
| List notifications | ✅ | ✅ | **Maintained** |
| **User Interaction** |
| Open URLs on click | ✅ | ✅ | **Maintained** |
| Activate apps on click | ✅ | ✅ | **Maintained** |
| Execute commands on click | ✅ | ✅ | **Maintained** |
| **Images** |
| Content images (`-contentImage`) | ✅ | ✅ | **Maintained** |
| Custom app icon (`-appIcon`) | ⚠️ Worked on older macOS | ❌ Removed | **Removed** (macOS limitation) |
| Sender icon (`-sender`) | ⚠️ Worked on older macOS | ❌ Removed | **Removed** (macOS limitation) |
| **Advanced Features** |
| Do Not Disturb bypass | ✅ | ✅ | **Maintained** |
| Debug mode (`--debug`) | ❌ | ✅ | **New** |
| Piped input | ✅ | ✅ | **Maintained** |
| Custom icon app bundles | ❌ | ✅ | **New** (workaround for removed options) |
| Interactive action buttons | ❌ | ✅ | **New** (macOS 11.0+) |
| Text input actions | ❌ | ✅ | **New** (macOS 11.0+) |
| Action button icons | ❌ | ✅ | **New** (macOS 12.0+) |
| **Framework** |
| Notification framework | NSUserNotificationCenter (legacy) | UserNotifications (modern) | **Upgraded** |
| **Code Quality** |
| Error handling | Basic | Improved | **Enhanced** |
| Code structure | Single file | Modular | **Improved** |
| Testing | Minimal | Comprehensive | **Enhanced** |

### Key Changes

#### ✅ **Improvements**

1. **Modern Framework**: Uses `UserNotifications` framework instead of deprecated `NSUserNotificationCenter`
   - Better permission handling
   - More reliable on modern macOS
   - Supports future notification features

2. **Debug Mode**: New `--debug` flag for troubleshooting
   - Detailed debug output
   - Helps diagnose permission issues
   - Useful for development

3. **Custom Icon Builds**: New workaround for app icon customization
   - Build app bundles with custom icons
   - Terminal icon is default
   - Supports any icon format

4. **Better Code Structure**: Modular design with separated concerns
   - Easier to maintain
   - Better error handling
   - Comprehensive test suite

#### ⚠️ **Breaking Changes**

1. **Removed `-appIcon` option**: No longer supported due to macOS limitations
   - **Workaround**: Use custom icon app bundles (`make app-with-icon`)

2. **Removed `-sender` option**: No longer supported due to macOS limitations
   - **Workaround**: Build custom app bundles with desired icon

3. **Framework Change**: Uses modern `UserNotifications` framework
   - May require permission prompts on first use
   - Better compatibility with modern macOS

#### 📋 **Migration Guide**

**For scripts using `-appIcon` or `-sender`:**
```bash
# Old way (no longer works)
terminal-notifier -message "Test" -appIcon "/path/to/icon.icns"

# New way - use custom app bundle
make app-with-icon ICON_PATH=/path/to/icon.icns
./terminal-notifier-custom.app/Contents/MacOS/terminal-notifier -message "Test"
```

**For all other options:**
- No changes needed! All other features work exactly the same.
- Scripts using `-title`, `-message`, `-sound`, `-group`, `-open`, etc. work without modification.

## License

Copyright © 2012-2024 Eloy Durán, Julien Blanchard. All rights reserved.

See [LICENSE.md](LICENSE.md) for details.

## Deprecated Options


## Limitations

### App Icon Customization
⚠️ **Custom app icons are not supported in notifications** due to macOS system limitations:

- **macOS notifications**: Do not support custom app icons (app icon is always the app bundle's icon)
- **Workaround**: Use custom app bundles with different icons
- **Content images**: Use `-contentImage` for visual customization

### Modern Framework
- **Modern notifications**: Uses the latest macOS notification system with advanced capabilities
- **Interactive notifications**: Support for action buttons and text input
- **Rich content**: Multiple attachments, custom sounds, and enhanced formatting
- **Smart scheduling**: Calendar-based and location-based notifications
- **Better management**: Advanced notification grouping and management

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Ruby Integration

The Ruby gem provides a convenient wrapper around the Swift binary:

```ruby
require 'terminal-notifier'

TerminalNotifier.notify('Hello, World!', title: 'Greeting')
TerminalNotifier.notify('Build complete!', group: 'builds', execute: 'open .')
```

For more Ruby examples, see the [Ruby documentation](Ruby/README.markdown).