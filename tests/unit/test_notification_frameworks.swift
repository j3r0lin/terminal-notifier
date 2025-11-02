#!/usr/bin/env swift

import Foundation
import Cocoa
import notification

// MARK: - Notification System Tests
print("Running Notification System Tests...")
print("===================================")

// Test 1: notification framework availability
print("1. Testing notification framework availability...")
if #available(macOS 10.14, *) {
    let center = UNUserNotificationCenter.current()
    assert(center != nil)
    print("✅ notification framework available")
} else {
    print("❌ notification framework not available (requires macOS 10.14+)")
    exit(1)
}

// Test 2: notification types availability
print("2. Testing notification types availability...")
if #available(macOS 10.14, *) {
    let content = UNMutableNotificationContent()
    content.title = "Test"
    content.body = "Test body"
    content.subtitle = "Test subtitle"
    assert(content.title == "Test")
    assert(content.body == "Test body")
    assert(content.subtitle == "Test subtitle")
    print("✅ notification types available")
} else {
    print("❌ notification types not available (requires macOS 10.14+)")
    exit(1)
}

// Test 3: Notification content properties
print("3. Testing notification content properties...")
if #available(macOS 10.14, *) {
    let content = UNMutableNotificationContent()
    content.title = "Test Title"
    content.subtitle = "Test Subtitle"
    content.body = "Test Body"
    content.sound = UNNotificationSound.default
    content.badge = NSNumber(value: 1)
    content.userInfo = ["test": "value"]
    
    assert(content.title == "Test Title")
    assert(content.subtitle == "Test Subtitle")
    assert(content.body == "Test Body")
    assert(content.sound != nil)
    assert(content.badge?.intValue == 1)
    assert(content.userInfo["test"] as? String == "value")
    print("✅ Notification content properties")
} else {
    print("❌ Notification content properties not available (requires macOS 10.14+)")
    exit(1)
}

// Test 4: Notification triggers
print("4. Testing notification triggers...")
if #available(macOS 10.14, *) {
    // Time interval trigger
    let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
    assert(timeTrigger.timeInterval == 1.0)
    assert(timeTrigger.repeats == false)
    
    // Calendar trigger
    let calendar = Calendar.current
    let dateComponents = DateComponents(hour: 10, minute: 30)
    let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    assert(calendarTrigger.repeats == true)
    
    print("✅ Notification triggers")
} else {
    print("❌ Notification triggers not available (requires macOS 10.14+)")
    exit(1)
}

// Test 5: Notification categories and actions
print("5. Testing notification categories and actions...")
if #available(macOS 10.14, *) {
    let action = UNNotificationAction(identifier: "TEST_ACTION", title: "Test Action", options: [])
    let category = UNNotificationCategory(identifier: "TEST_CATEGORY", actions: [action], intentIdentifiers: [], options: [])
    
    assert(action.identifier == "TEST_ACTION")
    assert(action.title == "Test Action")
    assert(category.identifier == "TEST_CATEGORY")
    assert(category.actions.count == 1)
    print("✅ Notification categories and actions")
} else {
    print("❌ Notification categories and actions not available (requires macOS 10.14+)")
    exit(1)
}

// Test 6: Image handling
print("6. Testing image handling...")
let systemIconPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
if FileManager.default.fileExists(atPath: systemIconPath) {
    let image = NSImage(contentsOfFile: systemIconPath)
    assert(image != nil)
    print("✅ Image handling")
} else {
    print("⚠️  System icon not found, skipping image test")
}

// Test 7: Notification interruption levels (macOS 12+)
print("7. Testing notification interruption levels...")
if #available(macOS 12.0, *) {
    let content = UNMutableNotificationContent()
    content.interruptionLevel = .active
    content.relevanceScore = 0.8
    
    assert(content.interruptionLevel == .active)
    assert(content.relevanceScore == 0.8)
    print("✅ Notification interruption levels")
} else {
    print("⚠️  Notification interruption levels not available (requires macOS 12+)")
}

print("\nAll notification system tests passed! 🎉")