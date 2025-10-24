import Foundation
import Cocoa
import UserNotifications

// MARK: - Main Application
class TerminalNotifierApp: NSObject, NSApplicationDelegate {
    let notificationManager = NotificationManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the notification center delegates
        NSUserNotificationCenter.default.delegate = notificationManager
        UNUserNotificationCenter.current().delegate = notificationManager
        
        // Request UserNotifications authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                if DEBUG_MODE { print("DEBUG: UserNotifications authorization error: \(error)") }
            } else if granted {
                if DEBUG_MODE { print("DEBUG: UserNotifications authorization granted") }
            } else {
                if DEBUG_MODE { print("DEBUG: UserNotifications authorization denied") }
            }
        }
        
        // Parse command line arguments
        let arguments = CommandLine.arguments
        
        if arguments.count > 1 {
            let command = arguments[1]
            if command == "-help" {
                notificationManager.printHelpBanner()
                exit(0)
            } else if command == "-version" {
                notificationManager.printVersion()
                exit(0)
            }
        }
        
        // Use ArgumentParser for other commands
        let argumentParser = ArgumentParser(notificationManager: notificationManager)
        argumentParser.parseArguments(arguments)
        
        // The app will exit when notification is delivered or after timeout in NotificationManager
    }
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = TerminalNotifierApp()
app.delegate = delegate
app.run()