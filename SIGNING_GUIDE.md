# Code Signing Guide for terminal-notifier

## Overview

terminal-notifier uses **ad-hoc code signing** which doesn't require specific developer credentials or Apple Developer accounts. This makes it easy for anyone to build and use custom app bundles.

## What is Ad-hoc Signing?

Ad-hoc signing (`codesign --force --deep --sign -`) creates a signature that:
- ✅ **Works on any macOS system** without specific credentials
- ✅ **Allows the app bundle to function** as a proper macOS application
- ✅ **Enables notification delivery** (required for macOS notifications)
- ❌ **Cannot be distributed** through the App Store or outside the system
- ❌ **Shows "unidentified developer"** warnings (but still works)

## Requirements

### For Basic Usage
- **No signing required** - just use the pre-built app bundle
- **No Xcode needed** - download and use directly

### For Custom Icon Builds
- **Xcode Command Line Tools** (for `codesign` command)
- **macOS system** (signing only works on macOS)
- **No Apple Developer account** required

## Installation

If you need to build custom app bundles, install Xcode Command Line Tools:

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify codesign is available
codesign --help
```

## Building Custom App Bundles

Once you have Xcode Command Line Tools installed:

```bash
# Build with custom icon
make app-with-icon ICON_PATH=/path/to/your/icon.icns

# Build with system icon
make app-firefox
make app-terminal

# Build from URL
make app-icon-url ICON_URL=https://example.com/icon.png
```

## How It Works

1. **Build Swift binary** - compiles the Swift code
2. **Create app bundle** - creates the `.app` structure
3. **Add custom icon** - copies and configures the icon
4. **Sign with ad-hoc** - `codesign --force --deep --sign -`
5. **Ready to use** - app bundle works immediately

## Troubleshooting

### "codesign not available"
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Then try building again
make app-with-icon ICON_PATH=/path/to/icon.icns
```

### "Code signing failed"
- Check that you're on macOS
- Verify Xcode Command Line Tools are installed
- Try running the build command again

### "Unidentified developer" warning
- This is normal for ad-hoc signed apps
- Click "Open" to allow the app to run
- The app will work normally after this

## Security Note

Ad-hoc signing is safe and commonly used for:
- Development tools
- Command-line utilities
- Internal applications
- Open source projects

The signature ensures the app bundle is properly structured and can access macOS APIs like notifications, but doesn't provide the same security guarantees as App Store distribution.

## Advanced: Custom Signing

If you have an Apple Developer account and want to use your own signing identity:

```bash
# Find your signing identity
security find-identity -v -p codesigning

# Use specific identity (replace with your identity)
codesign --force --deep --sign "Your Name (TEAM_ID)" terminal-notifier.app
```

But for most users, ad-hoc signing is sufficient and much simpler.