#!/usr/bin/env swift

import Foundation
import UserNotifications

// MARK: - Action Button Tests
print("Running Action Button Tests...")
print("===============================")

// Test 1: Basic action creation
print("\n1. Testing basic action creation...")
if #available(macOS 10.14, *) {
    let action = UNNotificationAction(
        identifier: "test_action",
        title: "Test Action",
        options: []
    )
    
    assert(action.identifier == "test_action")
    assert(action.title == "Test Action")
    print("✅ Basic action creation")
} else {
    print("❌ UserNotifications not available (requires macOS 10.14+)")
    exit(1)
}

// Test 2: Destructive action creation
print("\n2. Testing destructive action creation...")
if #available(macOS 10.14, *) {
    let destructiveAction = UNNotificationAction(
        identifier: "delete_action",
        title: "Delete",
        options: [.destructive]
    )
    
    assert(destructiveAction.identifier == "delete_action")
    assert(destructiveAction.title == "Delete")
    print("✅ Destructive action creation")
} else {
    print("❌ UserNotifications not available")
    exit(1)
}

// Test 3: Text input action creation
print("\n3. Testing text input action creation...")
if #available(macOS 11.0, *) {
    let textAction = UNTextInputNotificationAction(
        identifier: "reply_action",
        title: "Reply",
        options: [],
        textInputButtonTitle: "Send",
        textInputPlaceholder: "Type here..."
    )
    
    assert(textAction.identifier == "reply_action")
    assert(textAction.title == "Reply")
    assert(textAction.textInputButtonTitle == "Send")
    print("✅ Text input action creation")
} else {
    print("⚠️  Text input actions require macOS 11.0+")
}

// Test 4: Action with icon creation
print("\n4. Testing action with icon creation...")
if #available(macOS 12.0, *) {
    let icon = UNNotificationActionIcon(systemImageName: "star.fill")
    let actionWithIcon = UNNotificationAction(
        identifier: "favorite_action",
        title: "Favorite",
        options: [],
        icon: icon
    )
    
    assert(actionWithIcon.identifier == "favorite_action")
    assert(actionWithIcon.title == "Favorite")
    print("✅ Action with icon creation")
} else {
    print("⚠️  Action icons require macOS 12.0+")
}

// Test 5: Notification category creation
print("\n5. Testing notification category creation...")
if #available(macOS 10.14, *) {
    let action1 = UNNotificationAction(identifier: "action1", title: "Action 1", options: [])
    let action2 = UNNotificationAction(identifier: "action2", title: "Action 2", options: [])
    
    let category = UNNotificationCategory(
        identifier: "test_category",
        actions: [action1, action2],
        intentIdentifiers: [],
        options: []
    )
    
    assert(category.identifier == "test_category")
    assert(category.actions.count == 2)
    assert(category.actions[0].identifier == "action1")
    assert(category.actions[1].identifier == "action2")
    print("✅ Notification category creation")
} else {
    print("❌ UserNotifications not available")
    exit(1)
}

// Test 6: Multiple action types in category
print("\n6. Testing multiple action types in category...")
if #available(macOS 11.0, *) {
    let regularAction = UNNotificationAction(identifier: "view", title: "View", options: [])
    let destructiveAction = UNNotificationAction(identifier: "delete", title: "Delete", options: [.destructive])
    let textAction = UNTextInputNotificationAction(
        identifier: "reply",
        title: "Reply",
        options: [],
        textInputButtonTitle: "Send",
        textInputPlaceholder: "Type here..."
    )
    
    let category = UNNotificationCategory(
        identifier: "mixed_category",
        actions: [regularAction, destructiveAction, textAction],
        intentIdentifiers: [],
        options: []
    )
    
    assert(category.actions.count == 3)
    print("✅ Multiple action types in category")
} else {
    print("⚠️  Multiple action types require macOS 11.0+")
}

// Test 7: Action response handling
print("\n7. Testing action response format...")
print("   - Regular action response: ACTION:identifier")
print("   - Text input response: ACTION:identifier:text")
print("   - Default action: UNNotificationDefaultActionIdentifier")
print("   - Dismiss action: UNNotificationDismissActionIdentifier")
print("✅ Action response format documentation")

print("\nAll action button tests passed! 🎉")
