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

// Test 4: Content image handling
print("4. Testing content image handling...")
let contentImageArgs = ["terminal-notifier", "-message", "Test", "-contentImage", "/path/to/image.png"]
var hasContentImage = false

for arg in contentImageArgs {
    switch arg {
    case "-contentImage":
        hasContentImage = true
    default:
        break
    }
}

assert(hasContentImage == true)
print("✅ Content image handling")

// Test 5: Action button parsing
print("5. Testing action button parsing...")
let actionArgs = ["terminal-notifier", "-message", "Test", "-action", "Reply", "-action", "Delete", "-action-text", "Comment", "-prompt", "Reply Prompt", "-action-destructive", "Remove"]
var actions: [[String: String]] = []
var currentAction: [String: String]?

i = 1
while i < actionArgs.count {
    let arg = actionArgs[i]
    switch arg {
    case "-action":
        if i + 1 < actionArgs.count {
            let action: [String: String] = ["title": actionArgs[i + 1], "type": "default"]
            actions.append(action)
            i += 1
        }
    case "-action-text", "-prompt":
        if i + 1 < actionArgs.count {
            let action: [String: String] = ["title": actionArgs[i + 1], "type": "text"]
            actions.append(action)
            i += 1
        }
    case "-action-destructive":
        if i + 1 < actionArgs.count {
            let action: [String: String] = ["title": actionArgs[i + 1], "type": "destructive"]
            actions.append(action)
            i += 1
        }
    default:
        break
    }
    i += 1
}

assert(actions.count == 5)
assert(actions[0]["title"] == "Reply")
assert(actions[0]["type"] == "default")
assert(actions[1]["title"] == "Delete")
assert(actions[1]["type"] == "default")
assert(actions[2]["title"] == "Comment")
assert(actions[2]["type"] == "text")
assert(actions[3]["title"] == "Reply Prompt")
assert(actions[3]["type"] == "text")
assert(actions[4]["title"] == "Remove")
assert(actions[4]["type"] == "destructive")
print("✅ Action button parsing (including -prompt alias)")

// Test 6: Action icon parsing
print("6. Testing action icon parsing...")
let actionIconArgs = ["terminal-notifier", "-message", "Test", "-action-icon", "Reply:envelope.fill", "-action-icon", "Delete:trash.fill"]
var iconActions: [[String: String]] = []

i = 1
while i < actionIconArgs.count {
    let arg = actionIconArgs[i]
    if arg == "-action-icon" && i + 1 < actionIconArgs.count {
        let actionSpec = actionIconArgs[i + 1]
        let parts = actionSpec.components(separatedBy: ":")
        var action: [String: String] = ["type": "default"]
        if parts.count >= 1 {
            action["title"] = parts[0]
        }
        if parts.count >= 2 {
            action["icon"] = parts[1]
        }
        iconActions.append(action)
        i += 1
    }
    i += 1
}

assert(iconActions.count == 2)
assert(iconActions[0]["title"] == "Reply")
assert(iconActions[0]["icon"] == "envelope.fill")
assert(iconActions[1]["title"] == "Delete")
assert(iconActions[1]["icon"] == "trash.fill")
print("✅ Action icon parsing")

print("\nAll command line parsing tests passed! 🎉")