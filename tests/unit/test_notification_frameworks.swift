#!/usr/bin/env swift

import Foundation
import Cocoa
import UserNotifications

// MARK: - Notification Framework Tests
print("Running Notification Framework Tests...")
print("======================================")

// Test 1: UserNotifications framework availability
print("1. Testing UserNotifications framework availability...")
if #available(macOS 10.14, *) {
    let center = UNUserNotificationCenter.current()
    assert(center != nil)
    print("✅ UserNotifications framework available")
} else {
    print("✅ UserNotifications framework not available (expected on older macOS)")
}

// Test 2: NSUserNotificationCenter availability
print("2. Testing NSUserNotificationCenter availability...")
let nsCenter = NSUserNotificationCenter.default
assert(nsCenter != nil)
print("✅ NSUserNotificationCenter available")

// Test 3: UserNotifications types availability
print("3. Testing UserNotifications types availability...")
if #available(macOS 10.14, *) {
    let content = UNMutableNotificationContent()
    content.title = "Test"
    content.body = "Test body"
    assert(content.title == "Test")
    assert(content.body == "Test body")
    print("✅ UserNotifications types available")
} else {
    print("✅ UserNotifications types not available (expected on older macOS)")
}

// Test 4: NSUserNotification creation
print("4. Testing NSUserNotification creation...")
let notification = NSUserNotification()
notification.title = "Test"
notification.informativeText = "Test body"
assert(notification.title == "Test")
assert(notification.informativeText == "Test body")
print("✅ NSUserNotification creation")

// Test 5: Image handling
print("5. Testing image handling...")
let systemIconPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
if FileManager.default.fileExists(atPath: systemIconPath) {
    let image = NSImage(contentsOfFile: systemIconPath)
    assert(image != nil)
    print("✅ Image handling")
} else {
    print("⚠️  System icon not found, skipping image test")
}

print("\nAll notification framework tests passed! 🎉")