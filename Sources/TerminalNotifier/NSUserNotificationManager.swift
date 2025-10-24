import Foundation
import Cocoa

// MARK: - NSUserNotification Manager
class NSUserNotificationManager: NSObject, NSUserNotificationCenterDelegate {
    
    // MARK: - Properties
    private let center = NSUserNotificationCenter.default
    
    // MARK: - Initialization
    override init() {
        super.init()
        center.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Delivers a notification using the NSUserNotificationCenter framework
    /// - Parameters:
    ///   - title: Notification title
    ///   - subtitle: Notification subtitle (optional)
    ///   - message: Notification message
    ///   - options: Additional notification options
    ///   - sound: Sound name (optional)
    /// - Returns: True if notification was scheduled successfully, false otherwise
    func deliverNotification(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) -> Bool {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Delivering notification") }
        
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.userInfo = options
        
        if let subtitle = subtitle {
            notification.subtitle = subtitle
        }
        
        // Set sound
        if let sound = sound {
            if sound == "default" {
                notification.soundName = NSUserNotificationDefaultSoundName
            } else {
                notification.soundName = sound
            }
        }
        
        // Set content image if provided
        if let contentImageURL = options["contentImage"] as? String {
            // Handle both file paths and URLs
            let url: URL
            if contentImageURL.hasPrefix("http://") || contentImageURL.hasPrefix("https://") {
                url = URL(string: contentImageURL)!
            } else {
                url = URL(fileURLWithPath: contentImageURL)
            }
            notification.contentImage = NSImage(contentsOf: url)
            if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Content image set") }
        }
        
        // Handle app icon (NSUserNotificationCenter doesn't support custom app icons)
        if let appIconURL = options["appIcon"] as? String {
            // Store in userInfo for potential future use
            var userInfo = notification.userInfo ?? [:]
            userInfo["appIcon"] = appIconURL
            notification.userInfo = userInfo
            if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Custom app icon specified but NSUserNotificationCenter doesn't support custom app icons - using terminal-notifier app icon") }
        } else if options["sender"] == nil {
            // Only use default terminal icon if no sender is specified
            let terminalIconPath = "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns"
            if FileManager.default.fileExists(atPath: terminalIconPath) {
                var userInfo = notification.userInfo ?? [:]
                userInfo["appIcon"] = terminalIconPath
                notification.userInfo = userInfo
                if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Using default terminal icon") }
            }
        }
        
        // Set sender if provided (NSUserNotification doesn't have sender property)
        if let sender = options["sender"] as? String {
            // Store in userInfo for potential future use
            var userInfo = notification.userInfo ?? [:]
            userInfo["sender"] = sender
            notification.userInfo = userInfo
            if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Sender specified: \(sender)") }
        }
        
        // Set ignoreDnD if provided
        if let ignoreDnD = options["ignoreDnD"] as? Bool, ignoreDnD {
            notification.deliveryDate = Date()
            if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - IgnoreDnD enabled") }
        }
        
        // Schedule notification
        center.scheduleNotification(notification)
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Notification scheduled") }
        
        return true
    }
    
    /// Removes notifications with a specific group ID
    /// - Parameter groupID: The group ID to remove
    func removeNotification(groupID: String) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Removing notifications with group ID: \(groupID)") }
        
        let scheduledNotifications = center.scheduledNotifications
        for notification in scheduledNotifications {
            if let userInfo = notification.userInfo,
               let notificationGroupID = userInfo["groupID"] as? String,
               notificationGroupID == groupID {
                center.removeScheduledNotification(notification)
                if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Removed notification with group ID: \(groupID)") }
            }
        }
    }
    
    /// Lists notifications with a specific group ID
    /// - Parameter groupID: The group ID to list (use "ALL" for all notifications)
    func listNotifications(groupID: String) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Listing notifications with group ID: \(groupID)") }
        
        let scheduledNotifications = center.scheduledNotifications
        
        if groupID == "ALL" {
            for notification in scheduledNotifications {
                let title = notification.title ?? "No title"
                let message = notification.informativeText ?? "No message"
                let groupID = notification.userInfo?["groupID"] as? String ?? "No group ID"
                print("\(groupID)\t\(title)\t\(message)")
            }
        } else {
            for notification in scheduledNotifications {
                if let userInfo = notification.userInfo,
                   let notificationGroupID = userInfo["groupID"] as? String,
                   notificationGroupID == groupID {
                    let title = notification.title ?? "No title"
                    let message = notification.informativeText ?? "No message"
                    print("\(groupID)\t\(title)\t\(message)")
                }
            }
        }
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - didActivate notification") }
        
        if let userInfo = notification.userInfo {
            // Handle app activation
            if let bundleID = userInfo["bundleID"] as? String {
                activateApp(bundleID: bundleID)
            }
            
            // Handle URL opening
            if let urlString = userInfo["open"] as? String,
               let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
            
            // Handle command execution
            if let command = userInfo["command"] as? String {
                executeShellCommand(command)
            }
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - shouldPresent called") }
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Notification delivered successfully - Title: \(notification.title ?? "nil"), Message: \(notification.informativeText ?? "nil")") }
        // Keep the app running briefly to allow notification to be seen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Notification display timeout reached, exiting") }
            exit(0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func activateApp(bundleID: String) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Activating app: \(bundleID)") }
        NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleID, options: [], additionalEventParamDescriptor: nil, launchIdentifier: nil)
    }
    
    private func executeShellCommand(_ command: String) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationManager - Executing command: \(command)") }
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
    }
}