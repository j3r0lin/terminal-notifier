import Foundation
import Cocoa
import UserNotifications

// MARK: - Main Application
class TerminalNotifierApp: NSObject, NSApplicationDelegate {
    let notificationManager = NotificationManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if DEBUG_MODE { print("DEBUG: App launched, parsing arguments...") }

        // Note: Delegates are now handled by the individual framework managers
        // No need to set them here as they manage their own delegates
        
        // Parse command line arguments
        let arguments = CommandLine.arguments
        if DEBUG_MODE { print("DEBUG: Arguments: \(arguments)") }
        
        if arguments.count > 1 {
            let command = arguments[1]
            if command == "-help" || command == "--help" {
                if DEBUG_MODE { print("DEBUG: Showing help...") }
                notificationManager.printHelpBanner()
                exit(0)
            } else if command == "-version" || command == "--version" {
                if DEBUG_MODE { print("DEBUG: Showing version...") }
                notificationManager.printVersion()
                exit(0)
            }
        }
        
        // Use ArgumentParser for other commands
        if DEBUG_MODE { print("DEBUG: Using ArgumentParser...") }
        let argumentParser = ArgumentParser(notificationManager: notificationManager)
        argumentParser.parseArguments(arguments)
        
        if DEBUG_MODE { print("DEBUG: ArgumentParser completed, notification delivery will be handled by NotificationManager...") }
        // The NotificationManager will handle app termination after notification delivery
    }
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = TerminalNotifierApp()
app.delegate = delegate
app.run()