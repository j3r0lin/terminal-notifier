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

# Install the binary to /usr/local/bin
install: build
	cp .build/release/terminal-notifier /usr/local/bin/

# Create app bundle
app: build
	mkdir -p terminal-notifier.app/Contents/MacOS
	cp .build/release/terminal-notifier terminal-notifier.app/Contents/MacOS/
	cp Info.plist terminal-notifier.app/Contents/

# Run tests
test:
	swift test_runner.swift

# Run Swift Package Manager tests (if available)
test-swift:
	swift test

# Show help
help:
	@echo "Available targets:"
	@echo "  build     - Build release version"
	@echo "  debug     - Build debug version"
	@echo "  clean     - Clean build artifacts"
	@echo "  install   - Install binary to /usr/local/bin"
	@echo "  app       - Create app bundle"
	@echo "  test      - Run test suite"
	@echo "  test-swift- Run Swift Package Manager tests"
	@echo "  help      - Show this help"

.PHONY: build debug clean install app test test-swift help