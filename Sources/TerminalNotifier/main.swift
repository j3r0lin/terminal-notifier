import Foundation
import Cocoa

// MARK: - Main Application
class TerminalNotifierApp: NSObject, NSApplicationDelegate {
    let notificationManager = NotificationManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        debugPrint("DEBUG: App launched, parsing arguments...")
        
        // Parse command line arguments
        let arguments = CommandLine.arguments
        debugPrint("DEBUG: Arguments: \(arguments)")
        
        if arguments.count > 1 {
            let command = arguments[1]
            if command == "-help" || command == "--help" {
                debugPrint("DEBUG: Showing help...")
                notificationManager.printHelpBanner()
                exit(0)
            } else if command == "-version" || command == "--version" {
                debugPrint("DEBUG: Showing version...")
                notificationManager.printVersion()
                exit(0)
            }
        }
        
        // Use ArgumentParser for other commands
        debugPrint("DEBUG: Using ArgumentParser...")
        let argumentParser = ArgumentParser(notificationManager: notificationManager)
        argumentParser.parseArguments(arguments)
        
        debugPrint("DEBUG: ArgumentParser completed, notification delivery will be handled by NotificationManager...")
        // The NotificationManager will handle app termination after notification delivery
    }
}

// MARK: - Main Entry Point
let app = NSApplication.shared
let delegate = TerminalNotifierApp()
app.delegate = delegate
app.run()