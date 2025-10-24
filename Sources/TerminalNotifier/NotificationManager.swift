import Foundation
import Cocoa
import UserNotifications

// MARK: - Constants
var DEBUG_MODE = false

// MARK: - Notification Manager
class NotificationManager: NSObject, UNUserNotificationCenterDelegate, NSUserNotificationCenterDelegate {
    
    func deliverNotification(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) {
        if DEBUG_MODE { print("DEBUG: Delivering notification - Title: \(title), Message: \(message)") }
        
        // Remove earlier notification with the same group ID
        if let groupID = options["groupID"] as? String {
            removeNotification(groupID: groupID)
        }
        
        // Try UserNotifications first (modern approach)
        if tryUserNotifications(title: title, subtitle: subtitle, message: message, options: options, sound: sound) {
            if DEBUG_MODE { print("DEBUG: Using UserNotifications framework") }
            return
        }
        
        // Fallback to NSUserNotificationCenter
        if DEBUG_MODE { print("DEBUG: Falling back to NSUserNotificationCenter") }
        deliverNotificationFallback(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
    }
    
    private func tryUserNotifications(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Check for features not supported in UserNotifications
        if let ignoreDnD = options["ignoreDnD"] as? Bool, ignoreDnD {
            if DEBUG_MODE { print("DEBUG: ignoreDnD not supported in UserNotifications, falling back to NSUserNotificationCenter") }
            DispatchQueue.main.async {
                self.deliverNotificationFallback(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
            }
            return true
        }
        
        // Check authorization status first
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.scheduleUserNotification(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
            } else {
                if DEBUG_MODE { print("DEBUG: UserNotifications not authorized, falling back to NSUserNotificationCenter") }
                DispatchQueue.main.async {
                    self.deliverNotificationFallback(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
                }
            }
        }
        
        return true
    }
    
    private func scheduleUserNotification(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) {
        let center = UNUserNotificationCenter.current()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        
        // Set sound
        if let sound = sound {
            if sound == "default" {
                content.sound = UNNotificationSound.default
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
            }
        }
        
        // Set user info
        var userInfo: [String: Any] = options
        userInfo["originalTitle"] = title
        userInfo["originalMessage"] = message
        content.userInfo = userInfo
        
        // Set app icon if provided
        if let appIconURL = options["appIcon"] as? String,
           let _ = URL(string: appIconURL) {
            // UserNotifications doesn't have direct appIcon support, but we can store it in userInfo
            userInfo["appIcon"] = appIconURL
            content.userInfo = userInfo
        }
        
        // Set content image if provided
        if let contentImageURL = options["contentImage"] as? String,
           let url = URL(string: contentImageURL) {
            // UserNotifications supports attachments for content images
            if #available(macOS 10.14, *) {
                // Try to create an attachment for the content image
                if let attachment = createAttachment(from: url) {
                    content.attachments = [attachment]
                } else {
                    // Fallback: store in userInfo for delegate handling
                    userInfo["contentImage"] = contentImageURL
                    content.userInfo = userInfo
                }
            }
        }
        
        // Set sender if provided
        if let sender = options["sender"] as? String {
            userInfo["sender"] = sender
            content.userInfo = userInfo
        }
        
        // Set activate app if provided
        if let bundleID = options["bundleID"] as? String {
            userInfo["bundleID"] = bundleID
            content.userInfo = userInfo
        }
        
        // Set category for actions if needed
        if options["open"] != nil || options["command"] != nil || options["bundleID"] != nil {
            content.categoryIdentifier = "TERMINAL_NOTIFIER_ACTIONS"
        }
        
        // Note: ignoreDnD is not directly supported in UserNotifications framework
        // It's handled at the system level and cannot be overridden programmatically
        
        // Create request with identifier
        let identifier = options["groupID"] as? String ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        // Schedule notification
        center.add(request) { error in
            if let error = error {
                if DEBUG_MODE { print("DEBUG: UserNotifications error: \(error)") }
                // Fallback to NSUserNotificationCenter on error
                DispatchQueue.main.async {
                    self.deliverNotificationFallback(title: title, subtitle: subtitle, message: message, options: options, sound: sound)
                }
            } else {
                if DEBUG_MODE { print("DEBUG: UserNotifications notification scheduled") }
                // Keep the app running briefly to allow notification delivery
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if DEBUG_MODE { print("DEBUG: Timeout reached, exiting") }
                    exit(0)
                }
            }
        }
    }
    
    private func deliverNotificationFallback(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.userInfo = options
        
        if let subtitle = subtitle {
            notification.subtitle = subtitle
        }
        
        if let sound = sound {
            if sound == "default" {
                notification.soundName = NSUserNotificationDefaultSoundName
            } else {
                notification.soundName = sound
            }
        }
        
        // Set content image if provided
        if let contentImageURL = options["contentImage"] as? String,
           let url = URL(string: contentImageURL) {
            notification.contentImage = NSImage(contentsOf: url)
        }
        
        // Set app icon if provided (NSUserNotification doesn't have appIcon property)
        if let appIconURL = options["appIcon"] as? String {
            // Store in userInfo for potential future use
            var userInfo = notification.userInfo ?? [:]
            userInfo["appIcon"] = appIconURL
            notification.userInfo = userInfo
        }
        
        // Set sender if provided (NSUserNotification doesn't have sender property)
        if let sender = options["sender"] as? String {
            // Store in userInfo for potential future use
            var userInfo = notification.userInfo ?? [:]
            userInfo["sender"] = sender
            notification.userInfo = userInfo
        }
        
        // Set Do Not Disturb override if provided
        if let ignoreDnD = options["ignoreDnD"] as? Bool, ignoreDnD {
            notification.setValue(true, forKey: "_ignoresDoNotDisturb")
        }
        
        // Schedule notification
        let center = NSUserNotificationCenter.default
        center.delegate = self
        center.scheduleNotification(notification)
        
        if DEBUG_MODE { print("DEBUG: NSUserNotificationCenter notification scheduled") }
        
        // Keep the app running briefly to allow notification delivery
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if DEBUG_MODE { print("DEBUG: Timeout reached, exiting") }
            exit(0)
        }
    }
    
    func removeNotification(groupID: String) {
        // Try UserNotifications first
        let unCenter = UNUserNotificationCenter.current()
        unCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                unCenter.getDeliveredNotifications { notifications in
                    for notification in notifications {
                        let userInfo = notification.request.content.userInfo
                        if let notificationGroupID = userInfo["groupID"] as? String,
                           notificationGroupID == groupID {
                            unCenter.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                            print("* Removing previously sent notification, which was sent on: \(Date())")
                            return
                        }
                    }
                    
                    // Fallback to NSUserNotificationCenter
                    self.removeNotificationFallback(groupID: groupID)
                }
            } else {
                // UserNotifications not authorized, use NSUserNotificationCenter
                self.removeNotificationFallback(groupID: groupID)
            }
        }
    }
    
    private func removeNotificationFallback(groupID: String) {
        let center = NSUserNotificationCenter.default
        let deliveredNotifications = center.deliveredNotifications
        
        for notification in deliveredNotifications {
            if let userInfo = notification.userInfo,
               let notificationGroupID = userInfo["groupID"] as? String,
               notificationGroupID == groupID {
                center.removeDeliveredNotification(notification)
                print("* Removing previously sent notification, which was sent on: \(Date())")
                return
            }
        }
    }
    
    func listNotifications(groupID: String) {
        print("GroupID\tTitle\tSubtitle\tMessage\tDelivered At")
        
        // Try UserNotifications first
        let unCenter = UNUserNotificationCenter.current()
        unCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                unCenter.getDeliveredNotifications { notifications in
                    var foundNotifications = false
                    
                    for notification in notifications {
                        let userInfo = notification.request.content.userInfo
                        let groupIDValue = userInfo["groupID"] as? String ?? ""
                        let title = notification.request.content.title
                        let subtitle = notification.request.content.subtitle
                        let message = notification.request.content.body
                        let deliveryDate = notification.date.description
                        
                        if groupID == "ALL" {
                            print("\(groupIDValue)\t\(title)\t\(subtitle)\t\(message)\t\(deliveryDate)")
                            foundNotifications = true
                        } else if groupIDValue == groupID {
                            print("\(groupID)\t\(title)\t\(subtitle)\t\(message)\t\(deliveryDate)")
                            foundNotifications = true
                        }
                    }
                    
                    // If no notifications found in UserNotifications, try NSUserNotificationCenter
                    if !foundNotifications {
                        self.listNotificationsFallback(groupID: groupID)
                    }
                }
            } else {
                // UserNotifications not authorized, use NSUserNotificationCenter
                self.listNotificationsFallback(groupID: groupID)
            }
        }
    }
    
    private func listNotificationsFallback(groupID: String) {
        let center = NSUserNotificationCenter.default
        let deliveredNotifications = center.deliveredNotifications
        
        for notification in deliveredNotifications {
            if groupID == "ALL" {
                let groupIDValue = notification.userInfo?["groupID"] as? String ?? ""
                let title = notification.title ?? ""
                let subtitle = notification.subtitle ?? ""
                let message = notification.informativeText ?? ""
                let deliveryDate = Date().description
                
                print("\(groupIDValue)\t\(title)\t\(subtitle)\t\(message)\t\(deliveryDate)")
            } else {
                if let userInfo = notification.userInfo,
                   let notificationGroupID = userInfo["groupID"] as? String,
                   notificationGroupID == groupID {
                    let title = notification.title ?? ""
                    let subtitle = notification.subtitle ?? ""
                    let message = notification.informativeText ?? ""
                    let deliveryDate = Date().description
                    
                    print("\(groupID)\t\(title)\t\(subtitle)\t\(message)\t\(deliveryDate)")
                }
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if DEBUG_MODE { print("DEBUG: UserNotifications - didReceive response") }
        
        let userInfo = response.notification.request.content.userInfo
        
        if let bundleID = userInfo["bundleID"] as? String {
            activateApp(bundleID: bundleID)
        }
        if let urlString = userInfo["open"] as? String,
           let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
        if let command = userInfo["command"] as? String {
            executeShellCommand(command)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if DEBUG_MODE { print("DEBUG: UserNotifications - willPresent notification") }
        if #available(macOS 11.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    // MARK: - NSUserNotificationCenterDelegate (Fallback)
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if let userInfo = notification.userInfo {
            if let bundleID = userInfo["bundleID"] as? String {
                activateApp(bundleID: bundleID)
            }
            if let urlString = userInfo["open"] as? String,
               let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
            if let command = userInfo["command"] as? String {
                executeShellCommand(command)
            }
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationCenter - shouldPresent called") }
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        if DEBUG_MODE { print("DEBUG: NSUserNotificationCenter - Notification delivered successfully") }
        // Don't exit immediately, let the app run a bit longer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    // MARK: - Helper Methods
    private func createAttachment(from url: URL) -> UNNotificationAttachment? {
        if #available(macOS 10.14, *) {
            do {
                // Download the image data
                let data = try Data(contentsOf: url)
                
                // Create a temporary file
                let tempDir = FileManager.default.temporaryDirectory
                let tempFile = tempDir.appendingPathComponent(UUID().uuidString + ".tmp")
                
                try data.write(to: tempFile)
                
                // Create the attachment
                let attachment = try UNNotificationAttachment(identifier: "content-image", url: tempFile, options: nil)
                
                // Clean up the temp file after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    try? FileManager.default.removeItem(at: tempFile)
                }
                
                return attachment
            } catch {
                if DEBUG_MODE { print("DEBUG: Failed to create attachment from URL: \(error)") }
                return nil
            }
        }
        return nil
    }
    
    private func activateApp(bundleID: String) {
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            if app.bundleIdentifier == bundleID {
                app.activate(options: [])
                return
            }
        }
        NSWorkspace.shared.launchApplication(bundleID)
    }
    
    private func executeShellCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Error executing command: \(error)")
        }
    }
    
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