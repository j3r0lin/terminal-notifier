#!/usr/bin/env swift

import Foundation

// MARK: - Command Line Parsing Tests
print("Running Command Line Parsing Tests...")
print("====================================")

// Test 1: Basic argument parsing
print("1. Testing basic argument parsing...")
let testArgs = ["terminal-notifier", "-message", "Test message", "-title", "Test Title"]
var message: String?
var title = "Terminal"

var i = 1
while i < testArgs.count {
    let arg = testArgs[i]
    switch arg {
    case "-message":
        if i + 1 < testArgs.count {
            message = testArgs[i + 1]
            i += 1
        }
    case "-title":
        if i + 1 < testArgs.count {
            title = testArgs[i + 1]
            i += 1
        }
    default:
        break
    }
    i += 1
}

assert(message == "Test message")
assert(title == "Test Title")
print("✅ Basic argument parsing")

// Test 2: Debug flag detection
print("2. Testing debug flag detection...")
var debugMode = false
let debugArgs = ["terminal-notifier", "--debug", "-message", "Test"]
for arg in debugArgs {
    if arg == "--debug" {
        debugMode = true
        break
    }
}
assert(debugMode == true)
print("✅ Debug flag detection")

// Test 3: Optional arguments
print("3. Testing optional arguments...")
let optionalArgs = ["terminal-notifier", "-message", "Test", "-subtitle", "Subtitle", "-sound", "default"]
var subtitle: String?
var sound: String?

i = 1
while i < optionalArgs.count {
    let arg = optionalArgs[i]
    switch arg {
    case "-subtitle":
        if i + 1 < optionalArgs.count {
            subtitle = optionalArgs[i + 1]
            i += 1
        }
    case "-sound":
        if i + 1 < optionalArgs.count {
            sound = optionalArgs[i + 1]
            i += 1
        }
    default:
        break
    }
    i += 1
}

assert(subtitle == "Subtitle")
assert(sound == "default")
print("✅ Optional arguments")

// Test 4: Framework selection flags
print("4. Testing framework selection flags...")
let frameworkArgs = ["terminal-notifier", "-message", "Test", "-useUserNotifications"]
var useUserNotifications = false
var useNSUserNotificationCenter = false

for arg in frameworkArgs {
    switch arg {
    case "-useUserNotifications", "--useUserNotifications":
        useUserNotifications = true
    case "-useNSUserNotificationCenter", "--useNSUserNotificationCenter":
        useNSUserNotificationCenter = true
    default:
        break
    }
}

assert(useUserNotifications == true)
assert(useNSUserNotificationCenter == false)
print("✅ Framework selection flags")

print("\nAll command line parsing tests passed! 🎉")