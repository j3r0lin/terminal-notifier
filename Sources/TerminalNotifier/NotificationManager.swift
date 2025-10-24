import Foundation
import Cocoa
import UserNotifications

// MARK: - Notification Manager
class NotificationManager: NSObject {
    
    // MARK: - Properties
    private let userNotificationsManager = UserNotificationsManager()
    private let nsUserNotificationManager = NSUserNotificationManager()
    
    // MARK: - Public Methods
    
    /// Delivers a notification using the appropriate framework
    /// - Parameters:
    ///   - title: Notification title
    ///   - subtitle: Notification subtitle (optional)
    ///   - message: Notification message
    ///   - options: Additional notification options
    ///   - sound: Sound name (optional)
    func deliverNotification(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) {
        if DEBUG_MODE { print("DEBUG: NotificationManager - Delivering notification - Title: \(title), Message: \(message)") }
        
        // Remove earlier notification with the same group ID
        if let groupID = options["groupID"] as? String {
            removeNotification(groupID: groupID)
        }
        
        // Check for explicit framework selection
        let useUserNotifications = options["useUserNotifications"] as? Bool ?? false
        let useNSUserNotificationCenter = options["useNSUserNotificationCenter"] as? Bool ?? false
        
        if useUserNotifications {
            if DEBUG_MODE { print("DEBUG: NotificationManager - Explicitly using UserNotifications framework") }
            if userNotificationsManager.deliverNotification(title: title, subtitle: subtitle, message: message, options: options, sound: sound) {
                return
            }
            if DEBUG_MODE { print("DEBUG: NotificationManager - UserNotifications failed, falling back to NSUserNotificationCenter") }
        }
        
        if useNSUserNotificationCenter {
            if DEBUG_MODE { print("DEBUG: NotificationManager - Explicitly using NSUserNotificationCenter framework") }
            nsUserNotificationManager.deliverNotification(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
            return
        }
        
        // Auto-select framework based on features
        let hasAppIcon = options["appIcon"] != nil || options["sender"] != nil
        let hasContentImage = options["contentImage"] != nil
        
        if hasAppIcon || hasContentImage {
            if DEBUG_MODE { print("DEBUG: NotificationManager - Custom icons detected, using UserNotifications framework") }
            if userNotificationsManager.deliverNotification(title: title, subtitle: subtitle, message: message, options: options, sound: sound) {
                return
            }
            if DEBUG_MODE { print("DEBUG: NotificationManager - UserNotifications failed, falling back to NSUserNotificationCenter") }
        }
        
        // Use NSUserNotificationCenter for basic notifications
        if DEBUG_MODE { print("DEBUG: NotificationManager - Using NSUserNotificationCenter for basic notifications") }
        nsUserNotificationManager.deliverNotification(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
    }
    
    /// Removes notifications with a specific group ID
    /// - Parameter groupID: The group ID to remove
    func removeNotification(groupID: String) {
        if DEBUG_MODE { print("DEBUG: NotificationManager - Removing notifications with group ID: \(groupID)") }
        
        // Try UserNotifications first
        if #available(macOS 10.14, *) {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests { requests in
                let identifiersToRemove = requests.compactMap { request in
                    if let userInfo = request.content.userInfo as? [String: Any],
                       let requestGroupID = userInfo["groupID"] as? String,
                       requestGroupID == groupID {
                        return request.identifier
                    }
                    return nil
                }
                
                if !identifiersToRemove.isEmpty {
                    center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                    if DEBUG_MODE { print("DEBUG: NotificationManager - Removed \(identifiersToRemove.count) UserNotifications") }
                }
            }
        }
        
        // Also try NSUserNotificationCenter
        nsUserNotificationManager.removeNotification(groupID: groupID)
    }
    
    /// Lists notifications with a specific group ID
    /// - Parameter groupID: The group ID to list (use "ALL" for all notifications)
    func listNotifications(groupID: String) {
        if DEBUG_MODE { print("DEBUG: NotificationManager - Listing notifications with group ID: \(groupID)") }
        
        // Try UserNotifications first
        if #available(macOS 10.14, *) {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests { requests in
                var foundAny = false
                
                for request in requests {
                    if groupID == "ALL" {
                        let title = request.content.title
                        let message = request.content.body
                        let requestGroupID = request.content.userInfo["groupID"] as? String ?? "No group ID"
                        print("\(requestGroupID)\t\(title)\t\(message)")
                        foundAny = true
                    } else if let userInfo = request.content.userInfo as? [String: Any],
                              let requestGroupID = userInfo["groupID"] as? String,
                              requestGroupID == groupID {
                        let title = request.content.title
                        let message = request.content.body
                        print("\(groupID)\t\(title)\t\(message)")
                        foundAny = true
                    }
                }
                
                if !foundAny {
                    // If no notifications found in UserNotifications, try NSUserNotificationCenter
                    self.nsUserNotificationManager.listNotifications(groupID: groupID)
                }
            }
        } else {
            // UserNotifications not available, use NSUserNotificationCenter
            nsUserNotificationManager.listNotifications(groupID: groupID)
        }
    }
    
    // MARK: - Helper Methods
    
    func printHelpBanner() {
        print("terminal-notifier (3.0.0) is a command-line tool to send macOS User Notifications.")
        print("")
        print("Usage: terminal-notifier -[message|list|remove] [VALUE|ID|ID] [options]")
        print("")
        print("   Either of these is required (unless message data is piped to the tool):")
        print("")
        print("       -help              Display this help banner.")
        print("       -version           Display terminal-notifier version.")
        print("       -message VALUE     The notification message.")
        print("       -remove ID         Removes a notification with the specified 'group' ID.")
        print("       -list ID           If the specified 'group' ID exists show when it was delivered,")
        print("                          or use 'ALL' as ID to see all notifications.")
        print("                          The output is a tab-separated list.")
        print("")
        print("   Optional:")
        print("")
        print("       -title VALUE       The notification title. Defaults to 'Terminal'.")
        print("       -subtitle VALUE    The notification subtitle.")
        print("       -sound NAME        The name of a sound to play when the notification appears. The names are listed")
        print("                          in Sound Preferences. Use 'default' for the default notification sound.")
        print("       -group ID          A string which identifies the group the notifications belong to.")
        print("                          Old notifications with the same ID will be removed.")
        print("       -activate ID       The bundle identifier of the application to activate when the user clicks the notification.")
        print("       -sender ID         The bundle identifier of the application that should be shown as the sender, including its icon.")
        print("       -appIcon URL       The URL of a image to display instead of the application icon (Mavericks+ only)")
        print("       -contentImage URL  The URL of a image to display attached to the notification (Mavericks+ only)")
        print("       -open URL          The URL of a resource to open when the user clicks the notification.")
        print("       -execute COMMAND   A shell command to perform when the user clicks the notification.")
        print("       -ignoreDnD         Send notification even if Do Not Disturb is enabled.")
        print("       --debug            Enable debug output.")
        print("       -useUserNotifications  Force use of UserNotifications framework (modern).")
        print("       -useNSUserNotificationCenter  Force use of NSUserNotificationCenter framework (legacy).")
        print("")
        print("When the user activates a notification, the results are logged to the system logs.")
        print("Use Console.app to view these logs.")
        print("")
        print("Note that in some circumstances the first character of a message has to be escaped in order to be recognized.")
        print("An example of this is when using an open bracket, which has to be escaped like so: '\\['.")
        print("")
        print("For more information see https://github.com/julienXX/terminal-notifier.")
    }
    
    func printVersion() {
        print("3.0.0")
    }
}