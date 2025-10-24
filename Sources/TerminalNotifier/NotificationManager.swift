import Foundation
import Cocoa

// MARK: - Constants
var DEBUG_MODE = false

// MARK: - Notification Manager
class NotificationManager: NSObject, NSUserNotificationCenterDelegate {
    
    func deliverNotification(title: String, subtitle: String?, message: String, options: [String: Any], sound: String?) {
        if DEBUG_MODE { print("DEBUG: Delivering notification - Title: \(title), Message: \(message)") }
        
        // Remove earlier notification with the same group ID
        if let groupID = options["groupID"] as? String {
            removeNotification(groupID: groupID)
        }
        
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
        
        // Set Do Not Disturb override if provided
        if let ignoreDnD = options["ignoreDnD"] as? Bool, ignoreDnD {
            notification.setValue(true, forKey: "_ignoresDoNotDisturb")
        }
        
        // Schedule notification
        let center = NSUserNotificationCenter.default
        center.delegate = self
        center.scheduleNotification(notification)
        
        if DEBUG_MODE { print("DEBUG: Notification scheduled") }
        
        // Keep the app running briefly to allow notification delivery
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if DEBUG_MODE { print("DEBUG: Timeout reached, exiting") }
            exit(0)
        }
    }
    
    func removeNotification(groupID: String) {
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
        let center = NSUserNotificationCenter.default
        let deliveredNotifications = center.deliveredNotifications
        
        print("GroupID\tTitle\tSubtitle\tMessage\tDelivered At")
        
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
    
    // MARK: - NSUserNotificationCenterDelegate
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
        if DEBUG_MODE { print("DEBUG: shouldPresent called") }
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        if DEBUG_MODE { print("DEBUG: Notification delivered successfully") }
        // Don't exit immediately, let the app run a bit longer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    // MARK: - Helper Methods
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