# terminal-notifier

[![GitHub release](https://img.shields.io/github/release/julienXX/terminal-notifier.svg)](https://github.com/julienXX/terminal-notifier/releases)

terminal-notifier is a command-line tool to send macOS User Notifications, written in Swift for macOS 10.15 and higher.

## Features

- Send macOS notifications from the command line
- Support for titles, subtitles, and custom sounds
- Group notifications and remove previous ones
- Open URLs or activate applications when clicked
- Execute shell commands when notifications are clicked
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

# Build with Firefox icon
make app-firefox

# Build with Terminal icon  
make app-terminal

# Build with icon from URL
make app-icon-url ICON_URL=https://example.com/icon.png
```

### Manual Build with Custom Icon

```bash
# Use the build script directly
./scripts/build_with_icon.sh /path/to/icon.icns my-custom-notifier

# The script supports .icns, .png, .jpg, .jpeg files
# It will automatically convert non-ICNS files to ICNS format
```

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
- `-sender ID` - Bundle identifier of app to show as sender
- `-appIcon URL` - URL of image to display as app icon (⚠️ Deprecated - use custom app bundles)
- `-contentImage URL` - URL of image to display in notification
- `-open URL` - URL to open when notification is clicked
- `-execute COMMAND` - Shell command to execute when clicked
- `-ignoreDnD` - Send notification even if Do Not Disturb is enabled
- `--debug` - Enable debug output

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
  -appIcon "https://example.com/icon.png" \
  -open "https://github.com/your-repo"
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

## Differences from Objective-C Version

- **Native Swift implementation** - No Objective-C dependencies
- **Better error handling** - More robust error management
- **Debug mode** - `--debug` flag for troubleshooting
- **Cleaner code structure** - Separated concerns into multiple files
- **Comprehensive testing** - Full test suite included
- **Modern Swift features** - Uses Swift 5.7+ features

## License

Copyright © 2012-2024 Eloy Durán, Julien Blanchard. All rights reserved.

See [LICENSE.md](LICENSE.md) for details.

## Deprecated Options

### App Icon and Sender Options
⚠️ **The `-appIcon` and `-sender` options are deprecated** and no longer work on modern macOS:

- **Reason**: These options worked on older macOS versions but were removed/deprecated in newer versions
- **Current behavior**: These options show deprecation warnings and store values in userInfo only
- **Alternative**: Use custom app bundles with `make app-with-icon ICON_PATH=/path/to/icon.icns`
- **Content images**: Use `-contentImage` for notification content images (still works)

## Limitations

### App Icon Customization
⚠️ **Custom app icons are not supported in notifications** due to macOS system limitations:

- **NSUserNotificationCenter**: Does not support custom app icons
- **UserNotifications**: Does not support custom app icons (app icon is always the app bundle's icon)
- **Workaround**: Use custom app bundles with different icons
- **Content images**: Use `-contentImage` for visual customization

### Framework Selection
- **UserNotifications**: Modern framework with better features but may have permission issues in command-line apps
- **NSUserNotificationCenter**: Legacy framework with reliable delivery but limited features
- **Auto-selection**: The tool automatically chooses the best framework based on features used

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