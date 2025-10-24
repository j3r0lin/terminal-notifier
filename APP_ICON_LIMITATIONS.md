# App Icon Limitations in macOS Notifications

## Summary

After thorough investigation of both macOS notification frameworks, **custom app icons are not supported** in macOS notifications due to fundamental system limitations.

## Framework Analysis

### 1. NSUserNotificationCenter (Legacy Framework)
- ❌ **No app icon customization support**
- ❌ No `appIcon` property in `NSUserNotification`
- ✅ Supports `contentImage` for notification content
- ✅ Reliable delivery for command-line apps

### 2. UserNotifications (Modern Framework)
- ❌ **No app icon customization support**
- ❌ No `appIcon` property in `UNMutableNotificationContent`
- ✅ Supports `attachments` for notification content
- ⚠️ Permission issues with command-line apps

## Technical Details

### NSUserNotification Properties
```swift
let notification = NSUserNotification()
// Available properties:
notification.title = "Title"
notification.subtitle = "Subtitle"
notification.informativeText = "Message"
notification.contentImage = NSImage()  // ✅ Content image only
// ❌ No appIcon property exists
```

### UNMutableNotificationContent Properties
```swift
let content = UNMutableNotificationContent()
// Available properties:
content.title = "Title"
content.subtitle = "Subtitle"
content.body = "Message"
content.attachments = [attachment]  // ✅ Content images only
// ❌ No appIcon property exists
```

## What Actually Happens

When you use `-appIcon` in terminal-notifier:

1. **NSUserNotificationCenter**: Stores the icon path in `userInfo` but displays the app bundle's icon
2. **UserNotifications**: Stores the icon path in `userInfo` but displays the app bundle's icon
3. **Result**: The notification always shows the terminal-notifier app icon, not the custom icon

## Workarounds

### 1. Use Content Images
Instead of `-appIcon`, use `-contentImage` for visual customization:
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Custom image notification" \
  -title "Test" \
  -contentImage "/path/to/your/icon.png"
```

### 2. Build Custom Icon App Bundles (Recommended)
Use the built-in custom icon build system:

```bash
# Build with Firefox icon
make app-firefox

# Build with Terminal icon
make app-terminal

# Build with your own icon
make app-with-icon ICON_PATH=/path/to/your/icon.icns

# Build with icon from URL
make app-icon-url ICON_URL=https://example.com/icon.png

# Use the build script directly
./scripts/build_with_icon.sh /path/to/icon.icns my-custom-notifier
```

### 3. Use Different App Bundles
Create multiple app bundles with different icons for different use cases:
```bash
# Development notifications
./terminal-notifier-terminal.app/Contents/MacOS/terminal-notifier -message "Build complete"

# Web notifications  
./terminal-notifier-firefox.app/Contents/MacOS/terminal-notifier -message "Site updated"

# General notifications
./terminal-notifier.app/Contents/MacOS/terminal-notifier -message "General alert"
```

## Why This Limitation Exists

1. **Security**: Prevents apps from impersonating other applications
2. **Consistency**: Ensures users can identify the source of notifications
3. **System Design**: macOS notification system is designed around app identity
4. **User Experience**: Prevents confusion about notification sources

## Recommendations

### For Users
- Use `-contentImage` instead of `-appIcon` for visual customization
- Accept that app icons are determined by the app bundle
- Focus on other notification features that work well

### For Developers
- Update documentation to clarify this limitation
- Consider using content images for visual differentiation
- Focus on other notification features (sounds, actions, content)

## Conclusion

The `-appIcon` option in terminal-notifier is provided for compatibility with the original Ruby version, but it does not actually change the app icon due to macOS system limitations. This is a fundamental constraint of the macOS notification system, not a bug in terminal-notifier.

For visual customization, use `-contentImage` instead, which works reliably on both notification frameworks.