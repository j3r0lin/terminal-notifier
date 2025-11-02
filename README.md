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