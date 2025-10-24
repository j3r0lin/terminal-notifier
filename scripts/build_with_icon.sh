#!/bin/bash

# MARK: - Build App Bundle with Custom Icon
# Usage: ./scripts/build_with_icon.sh <icon_path> [output_name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if icon path is provided
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <icon_path> [output_name]"
    print_error "  icon_path: Path to .icns file or image file"
    print_error "  output_name: Optional name for the output app bundle (default: terminal-notifier-custom)"
    exit 1
fi

ICON_PATH="$1"
OUTPUT_NAME="${2:-terminal-notifier-custom}"

print_status "Building app bundle with custom icon..."
print_status "Icon path: $ICON_PATH"
print_status "Output name: $OUTPUT_NAME"

# Check if icon file exists
if [ ! -f "$ICON_PATH" ]; then
    print_error "Icon file not found: $ICON_PATH"
    exit 1
fi

# Get file extension
ICON_EXT="${ICON_PATH##*.}"
ICON_EXT_LOWER=$(echo "$ICON_EXT" | tr '[:upper:]' '[:lower:]')

# Check if it's a supported image format
if [[ "$ICON_EXT_LOWER" != "icns" && "$ICON_EXT_LOWER" != "png" && "$ICON_EXT_LOWER" != "jpg" && "$ICON_EXT_LOWER" != "jpeg" ]]; then
    print_error "Unsupported image format: $ICON_EXT"
    print_error "Supported formats: .icns, .png, .jpg, .jpeg"
    exit 1
fi

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
print_status "Using temporary directory: $TEMP_DIR"

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up temporary directory..."
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Convert image to ICNS if needed
ICNS_PATH="$TEMP_DIR/AppIcon.icns"
if [ "$ICON_EXT_LOWER" = "icns" ]; then
    print_status "Using provided ICNS file..."
    cp "$ICON_PATH" "$ICNS_PATH"
else
    print_status "Converting $ICON_EXT to ICNS..."
    
    # Create iconset directory
    ICONSET_DIR="$TEMP_DIR/AppIcon.iconset"
    mkdir -p "$ICONSET_DIR"
    
    # Convert to different sizes (required for ICNS)
    # Note: This is a simplified approach - in production you might want more sizes
    sips -z 16 16 "$ICON_PATH" --out "$ICONSET_DIR/icon_16x16.png" 2>/dev/null || true
    sips -z 32 32 "$ICON_PATH" --out "$ICONSET_DIR/icon_16x16@2x.png" 2>/dev/null || true
    sips -z 32 32 "$ICON_PATH" --out "$ICONSET_DIR/icon_32x32.png" 2>/dev/null || true
    sips -z 64 64 "$ICON_PATH" --out "$ICONSET_DIR/icon_32x32@2x.png" 2>/dev/null || true
    sips -z 128 128 "$ICON_PATH" --out "$ICONSET_DIR/icon_128x128.png" 2>/dev/null || true
    sips -z 256 256 "$ICON_PATH" --out "$ICONSET_DIR/icon_128x128@2x.png" 2>/dev/null || true
    sips -z 256 256 "$ICON_PATH" --out "$ICONSET_DIR/icon_256x256.png" 2>/dev/null || true
    sips -z 512 512 "$ICON_PATH" --out "$ICONSET_DIR/icon_256x256@2x.png" 2>/dev/null || true
    sips -z 512 512 "$ICON_PATH" --out "$ICONSET_DIR/icon_512x512.png" 2>/dev/null || true
    sips -z 1024 1024 "$ICON_PATH" --out "$ICONSET_DIR/icon_512x512@2x.png" 2>/dev/null || true
    
    # Convert iconset to ICNS
    if command -v iconutil >/dev/null 2>&1; then
        iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"
        print_success "ICNS file created successfully"
    else
        print_error "iconutil not found - cannot convert to ICNS"
        print_error "Please provide an .icns file or install Xcode command line tools"
        exit 1
    fi
fi

# Build the Swift binary
print_status "Building Swift binary..."
if ! swift build --configuration release; then
    print_error "Failed to build Swift binary"
    exit 1
fi

# Create app bundle structure
print_status "Creating app bundle structure..."
APP_BUNDLE="$OUTPUT_NAME.app"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy binary
print_status "Copying binary..."
cp .build/release/terminal-notifier "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist
print_status "Copying Info.plist..."
cp Info.plist "$APP_BUNDLE/Contents/"

# Copy custom icon
print_status "Installing custom icon..."
cp "$ICNS_PATH" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

# Update Info.plist to reference the custom icon
print_status "Updating Info.plist with custom icon reference..."
# Create a temporary Info.plist with the icon reference
python3 -c "
import plistlib
import sys

# Read the existing Info.plist
with open('$APP_BUNDLE/Contents/Info.plist', 'rb') as f:
    plist = plistlib.load(f)

# Add icon reference
plist['CFBundleIconFile'] = 'AppIcon'

# Write back
with open('$APP_BUNDLE/Contents/Info.plist', 'wb') as f:
    plistlib.dump(plist, f)
" 2>/dev/null || {
    print_warning "Could not update Info.plist with Python, using manual approach..."
    # Fallback: use sed to add the icon reference
    sed -i '' '/<key>CFBundleIdentifier<\/key>/a\
    <key>CFBundleIconFile</key>\
    <string>AppIcon</string>
' "$APP_BUNDLE/Contents/Info.plist"
}

# Sign the app bundle
print_status "Signing app bundle..."
if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null && \
        print_success "App bundle signed successfully" || \
        print_warning "Code signing failed - app will be unsigned"
else
    print_warning "codesign not available - app will be unsigned"
fi

# Test the app bundle
print_status "Testing the app bundle..."
if [ -f "$APP_BUNDLE/Contents/MacOS/terminal-notifier" ]; then
    print_success "App bundle created successfully: $APP_BUNDLE"
    print_status "You can now use: ./$APP_BUNDLE/Contents/MacOS/terminal-notifier"
    
    # Show app bundle info
    print_status "App bundle information:"
    echo "  - Bundle: $APP_BUNDLE"
    echo "  - Icon: $APP_BUNDLE/Contents/Resources/AppIcon.icns"
    echo "  - Binary: $APP_BUNDLE/Contents/MacOS/terminal-notifier"
    echo "  - Size: $(du -sh "$APP_BUNDLE" | cut -f1)"
    
    # Test notification
    print_status "Testing notification with custom icon..."
    ./"$APP_BUNDLE/Contents/MacOS/terminal-notifier" \
        -message "Test notification with custom icon" \
        -title "Custom Icon Test" \
        -sound "default" >/dev/null 2>&1 && \
        print_success "Test notification sent successfully" || \
        print_warning "Test notification failed"
        
else
    print_error "Failed to create app bundle"
    exit 1
fi

print_success "Build completed successfully! 🎉"
print_status "The app bundle '$APP_BUNDLE' now uses your custom icon for all notifications."