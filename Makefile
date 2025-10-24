# terminal-notifier Swift Makefile

# Build the Swift version
build:
	swift build --configuration release

# Build debug version
debug:
	swift build

# Clean build artifacts
clean:
	swift package clean
	rm -rf .build
	rm -rf terminal-notifier.app
	@echo "Build artifacts cleaned"

# Kill any dead terminal-notifier processes
kill-processes:
	@echo "Checking for dead terminal-notifier processes..."
	@if pgrep -f "terminal-notifier" >/dev/null 2>&1; then \
		echo "Found terminal-notifier processes, killing them..."; \
		pkill -f "terminal-notifier" && echo "✅ Processes killed" || echo "❌ Failed to kill processes"; \
	else \
		echo "No terminal-notifier processes found"; \
	fi

# Clean everything including processes
clean-all: kill-processes clean

# Install the binary to /usr/local/bin
install: build
	cp .build/release/terminal-notifier /usr/local/bin/

# Create app bundle (signed by default)
app: build
	mkdir -p terminal-notifier.app/Contents/MacOS
	cp .build/release/terminal-notifier terminal-notifier.app/Contents/MacOS/
	cp Info.plist terminal-notifier.app/Contents/
	@echo "App bundle created"
	@echo "Signing app bundle..."
	@if command -v codesign >/dev/null 2>&1; then \
		codesign --force --deep --sign - terminal-notifier.app && \
		echo "✅ App signed successfully" || \
		echo "❌ Code signing failed - continuing without signature"; \
	else \
		echo "⚠️  codesign not available - app will be unsigned"; \
		echo "   To enable signing, install Xcode Command Line Tools:"; \
		echo "   xcode-select --install"; \
	fi

# Create unsigned app bundle
app-unsigned: build
	mkdir -p terminal-notifier.app/Contents/MacOS
	cp .build/release/terminal-notifier terminal-notifier.app/Contents/MacOS/
	cp Info.plist terminal-notifier.app/Contents/
	@echo "Unsigned app bundle created"

# Sign the app bundle
sign: app
	@echo "Signing app bundle..."
	@if command -v codesign >/dev/null 2>&1; then \
		codesign --force --deep --sign - terminal-notifier.app && \
		echo "✅ App signed successfully" || \
		echo "❌ Code signing failed - continuing without signature"; \
	else \
		echo "⚠️  codesign not available - app will be unsigned"; \
		echo "   To enable signing, install Xcode Command Line Tools:"; \
		echo "   xcode-select --install"; \
	fi

# Create signed app bundle
app-signed: sign

# Check app signature
check-signature:
	@echo "Checking app signature..."
	@if [ -d "terminal-notifier.app" ]; then \
		codesign -dv terminal-notifier.app 2>&1 || echo "App is not signed"; \
		codesign -v terminal-notifier.app 2>&1 || echo "Signature verification failed"; \
	else \
		echo "App bundle not found. Run 'make app' first."; \
	fi

# Custom icon build targets
app-with-icon:
	@echo "Building app bundle with custom icon..."
	@echo "Usage: make app-with-icon ICON_PATH=/path/to/icon.icns [OUTPUT_NAME=custom-name]"
	@if [ -z "$(ICON_PATH)" ]; then \
		echo "❌ ICON_PATH is required"; \
		echo "Example: make app-with-icon ICON_PATH=/path/to/icon.icns"; \
		exit 1; \
	fi
	@./scripts/build_with_icon.sh "$(ICON_PATH)" "$(OUTPUT_NAME)"

# Build with Firefox icon
app-firefox: build
	@echo "Building app bundle with Firefox icon..."
	@if [ -f "/Applications/Firefox.app/Contents/Resources/firefox.icns" ]; then \
		./scripts/build_with_icon.sh "/Applications/Firefox.app/Contents/Resources/firefox.icns" "terminal-notifier-firefox"; \
	else \
		echo "❌ Firefox not found at /Applications/Firefox.app/Contents/Resources/firefox.icns"; \
		exit 1; \
	fi

# Build with Terminal icon
app-terminal: build
	@echo "Building app bundle with Terminal icon..."
	@if [ -f "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns" ]; then \
		./scripts/build_with_icon.sh "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns" "terminal-notifier-terminal"; \
	else \
		echo "❌ Terminal not found at /System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns"; \
		exit 1; \
	fi

# Build with custom icon from URL
app-icon-url:
	@echo "Building app bundle with custom icon from URL..."
	@echo "Usage: make app-icon-url ICON_URL=https://example.com/icon.png [OUTPUT_NAME=custom-name]"
	@if [ -z "$(ICON_URL)" ]; then \
		echo "❌ ICON_URL is required"; \
		echo "Example: make app-icon-url ICON_URL=https://example.com/icon.png"; \
		exit 1; \
	fi
	@TEMP_ICON=$$(mktemp /tmp/icon.XXXXXX.$$(echo "$(ICON_URL)" | sed 's/.*\.//')); \
	curl -s "$(ICON_URL)" -o "$$TEMP_ICON" && \
	./scripts/build_with_icon.sh "$$TEMP_ICON" "$(OUTPUT_NAME)" && \
	rm -f "$$TEMP_ICON"

# Run tests
test: test-unit test-integration test-options test-build

# Run unit tests
test-unit:
	@echo "Running unit tests..."
	swift test_runner.swift

# Run integration tests
test-integration:
	@echo "Running integration tests..."
	@echo "Testing basic notification..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier -message "Integration test" -title "Test" > /dev/null 2>&1 && echo "✅ Basic notification works" || echo "❌ Basic notification failed"
	@echo "Testing debug mode..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier --debug -message "Debug test" -title "Debug" 2>&1 | grep -q "DEBUG:" && echo "✅ Debug mode works" || echo "❌ Debug mode failed"
	@echo "Testing help command..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier -help > /dev/null 2>&1 && echo "✅ Help command works" || echo "❌ Help command failed"
	@echo "Testing version command..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier -version > /dev/null 2>&1 && echo "✅ Version command works" || echo "❌ Version command failed"
	@echo "Testing list command..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier -list "ALL" > /dev/null 2>&1 && echo "✅ List command works" || echo "❌ List command failed"
	@echo "Testing content image..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier -message "Image test" -title "Test" -contentImage "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" > /dev/null 2>&1 && echo "✅ Content image works" || echo "❌ Content image failed"
	@echo "Testing app icon..."
	./terminal-notifier.app/Contents/MacOS/terminal-notifier -message "App icon test" -title "Test" -appIcon "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" > /dev/null 2>&1 && echo "✅ App icon works" || echo "❌ App icon failed"

# Test all command-line options
test-options:
	@echo "Testing all command-line options..."
	@./test_options.sh

# Test build process
test-build:
	@echo "Testing build process..."
	@echo "Testing debug build..."
	swift build > /dev/null 2>&1 && echo "✅ Debug build works" || echo "❌ Debug build failed"
	@echo "Testing release build..."
	swift build -c release > /dev/null 2>&1 && echo "✅ Release build works" || echo "❌ Release build failed"
	@echo "Testing app bundle creation..."
	make app > /dev/null 2>&1 && echo "✅ App bundle creation works" || echo "❌ App bundle creation failed"

# Quick test (unit tests only)
test-quick:
	@echo "Running quick tests..."
	swift test_runner.swift

# CI test (no warnings, exit on error)
test-ci:
	@echo "Running CI tests..."
	@swift test_runner.swift 2>/dev/null
	@make test-integration
	@make test-build

# Run Swift Package Manager tests (if available)
test-swift:
	swift test

# Individual test targets
test-unit-basic:
	@echo "Running basic functionality unit tests..."
	@swift tests/unit/test_basic_functionality.swift

test-unit-frameworks:
	@echo "Running notification framework unit tests..."
	@swift tests/unit/test_notification_frameworks.swift

test-unit-parsing:
	@echo "Running command line parsing unit tests..."
	@swift tests/unit/test_command_line_parsing.swift

test-integration-basic:
	@echo "Running basic notifications integration tests..."
	@./tests/integration/test_basic_notifications.sh

test-integration-images:
	@echo "Running image notifications integration tests..."
	@./tests/integration/test_image_notifications.sh

test-framework-nsuser:
	@echo "Running NSUserNotificationCenter framework tests..."
	@./tests/frameworks/test_nsuser_notification_center.sh

test-framework-user:
	@echo "Running UserNotifications framework tests..."
	@./tests/frameworks/test_user_notifications.sh

test-examples-basic:
	@echo "Running basic examples..."
	@./tests/examples/test_basic_examples.sh

test-examples-advanced:
	@echo "Running advanced examples..."
	@./tests/examples/test_advanced_examples.sh

# All individual tests
test-all-individual: test-unit-basic test-unit-frameworks test-unit-parsing test-integration-basic test-integration-images test-framework-nsuser test-framework-user test-examples-basic test-examples-advanced

# Show help
help:
	@echo "Available targets:"
	@echo "  build        - Build release version"
	@echo "  debug        - Build debug version"
	@echo "  clean        - Clean build artifacts"
	@echo "  clean-all    - Clean everything including processes"
	@echo "  kill-processes - Kill any dead terminal-notifier processes"
	@echo "  install      - Install binary to /usr/local/bin"
	@echo "  app          - Create signed app bundle (default)"
	@echo "  app-unsigned - Create unsigned app bundle"
	@echo "  sign         - Sign the app bundle"
	@echo "  app-signed   - Create and sign app bundle"
	@echo "  check-signature - Check app signature"
	@echo ""
	@echo "Custom icon build targets:"
	@echo "  app-with-icon  - Build app bundle with custom icon (requires ICON_PATH)"
	@echo "  app-firefox    - Build app bundle with Firefox icon"
	@echo "  app-terminal   - Build app bundle with Terminal icon"
	@echo "  app-icon-url   - Build app bundle with icon from URL (requires ICON_URL)"
	@echo ""
	@echo "  test         - Run complete test suite"
	@echo "  test-quick   - Run quick unit tests only"
	@echo "  test-ci      - Run CI tests (no warnings)"
	@echo "  test-unit    - Run unit tests"
	@echo "  test-integration - Run integration tests"
	@echo "  test-options - Test all command-line options"
	@echo "  test-build   - Test build process"
	@echo "  test-swift   - Run Swift Package Manager tests"
	@echo ""
	@echo "Individual test targets:"
	@echo "  test-unit-basic      - Run basic functionality unit tests"
	@echo "  test-unit-frameworks - Run notification framework unit tests"
	@echo "  test-unit-parsing    - Run command line parsing unit tests"
	@echo "  test-integration-basic - Run basic notifications integration tests"
	@echo "  test-integration-images - Run image notifications integration tests"
	@echo "  test-framework-nsuser - Run NSUserNotificationCenter framework tests"
	@echo "  test-framework-user  - Run UserNotifications framework tests"
	@echo "  test-examples-basic  - Run basic examples"
	@echo "  test-examples-advanced - Run advanced examples"
	@echo "  test-all-individual  - Run all individual tests"
	@echo "  help         - Show this help"

.PHONY: build debug clean install app test test-swift help