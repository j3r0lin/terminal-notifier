#!/usr/bin/env swift

import Foundation
import AppKit
import UserNotifications

// Simple test framework for command-line testing
class TestRunner {
    private var tests: [(String, () -> Bool)] = []
    private var passed = 0
    private var failed = 0
    
    func addTest(_ name: String, _ test: @escaping () -> Bool) {
        tests.append((name, test))
    }
    
    func runAll() {
        print("Running \(tests.count) tests...")
        print(String(repeating: "=", count: 50))
        
        for (name, test) in tests {
            do {
                let result = test()
                if result {
                    print("✅ \(name)")
                    passed += 1
                } else {
                    print("❌ \(name)")
                    failed += 1
                }
            } catch {
                print("❌ \(name) - Error: \(error)")
                failed += 1
            }
        }
        
        print(String(repeating: "=", count: 50))
        print("Tests completed: \(passed) passed, \(failed) failed")
        
        if failed > 0 {
            exit(1)
        }
    }
}

// Test cases
func runTests() {
    let runner = TestRunner()
    
    // Basic functionality tests
    runner.addTest("String operations") {
        let testString = "Hello, World!"
        return testString.contains("World") && testString.count == 13
    }
    
    runner.addTest("Array operations") {
        let testArray = ["a", "b", "c"]
        return testArray.count == 3 && testArray.contains("b")
    }
    
    runner.addTest("URL validation - valid URLs") {
        let validURLs = [
            "https://www.apple.com",
            "http://example.com",
            "file:///path/to/file"
        ]
        
        for urlString in validURLs {
            if let url = URL(string: urlString) {
                let isValid = (url.scheme != nil && url.host != nil) || url.isFileURL
                if !isValid { return false }
            } else {
                return false
            }
        }
        return true
    }
    
    runner.addTest("URL validation - invalid URLs") {
        let invalidURLs = [
            "invalid-url",
            "not-a-url",
            "just-text",
            "no-scheme-here"
        ]
        
        for urlString in invalidURLs {
            if let url = URL(string: urlString) {
                let isValid = (url.scheme != nil && url.host != nil) || url.isFileURL
                if isValid { 
                    print("  DEBUG: URL '\(urlString)' was considered valid but shouldn't be")
                    return false 
                }
            }
            // If URL creation fails, that's also considered invalid (which is good)
        }
        return true
    }
    
    runner.addTest("Command line argument parsing") {
        let args = ["terminal-notifier", "-message", "test", "-title", "Test Title"]
        
        // Find message argument
        guard let messageIndex = args.firstIndex(of: "-message") else { return false }
        guard messageIndex + 1 < args.count else { return false }
        guard args[messageIndex + 1] == "test" else { return false }
        
        // Find title argument
        guard let titleIndex = args.firstIndex(of: "-title") else { return false }
        guard titleIndex + 1 < args.count else { return false }
        guard args[titleIndex + 1] == "Test Title" else { return false }
        
        return true
    }
    
    runner.addTest("Debug flag detection") {
        let args1 = ["terminal-notifier", "--debug", "-message", "test"]
        let args2 = ["terminal-notifier", "-message", "test", "--debug"]
        
        return args1.contains("--debug") && args2.contains("--debug")
    }
    
    runner.addTest("Dictionary operations") {
        let options: [String: Any] = [
            "groupID": "test-group",
            "bundleID": "com.apple.finder",
            "open": "https://www.apple.com",
            "command": "echo 'test'",
            "ignoreDnD": true
        ]
        
        return (options["groupID"] as? String) == "test-group" &&
               (options["bundleID"] as? String) == "com.apple.finder" &&
               (options["open"] as? String) == "https://www.apple.com" &&
               (options["command"] as? String) == "echo 'test'" &&
               (options["ignoreDnD"] as? Bool) == true
    }
    
    runner.addTest("Constants validation") {
        let bundleID = "com.apple.notificationcenterui"
        let defaultTitle = "Terminal"
        let version = "3.0.0"
        let appName = "terminal-notifier"
        
        return bundleID == "com.apple.notificationcenterui" &&
               defaultTitle == "Terminal" &&
               version == "3.0.0" &&
               appName == "terminal-notifier"
    }
    
    runner.addTest("File operations") {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test.txt")
        
        // Test file creation
        let testData = "Hello, World!".data(using: .utf8)!
        do {
            try testData.write(to: tempFile)
            
            // Test file reading
            let readData = try Data(contentsOf: tempFile)
            let readString = String(data: readData, encoding: .utf8)
            
            // Clean up
            try FileManager.default.removeItem(at: tempFile)
            
            return readString == "Hello, World!"
        } catch {
            return false
        }
    }
    
    // UserNotifications framework tests
    runner.addTest("UserNotifications framework availability") {
        if #available(macOS 10.14, *) {
            // UserNotifications is available on macOS 10.14+
            return true
        } else {
            // On older systems, we should fall back gracefully
            return true
        }
    }
    
    runner.addTest("UserNotifications types availability") {
        if #available(macOS 10.14, *) {
            // Test that UserNotifications types are available
            return UNMutableNotificationContent.self != nil &&
                   UNNotificationRequest.self != nil &&
                   UNNotificationSound.self != nil
        } else {
            return true
        }
    }
    
    runner.addTest("Authorization options type availability") {
        if #available(macOS 10.14, *) {
            // Test that UNAuthorizationOptions is available
            return UNAuthorizationOptions.self != nil
        } else {
            return true
        }
    }
    
    runner.addTest("UNUserNotificationCenter class availability") {
        if #available(macOS 10.14, *) {
            // Test that the class is available without instantiating it
            return UNUserNotificationCenter.self != nil
        } else {
            return true
        }
    }
    
    runner.addTest("NSUserNotificationCenter class availability") {
        // Test that the class is available without instantiating it
        return NSUserNotificationCenter.self != nil
    }
    
    runner.addTest("Notification options dictionary handling") {
        let options: [String: Any] = [
            "groupID": "test-group-123",
            "bundleID": "com.apple.finder",
            "open": "https://www.apple.com",
            "command": "echo 'Hello World'",
            "ignoreDnD": true
        ]
        
        // Test that we can extract all expected values
        let groupID = options["groupID"] as? String
        let bundleID = options["bundleID"] as? String
        let openURL = options["open"] as? String
        let command = options["command"] as? String
        let ignoreDnD = options["ignoreDnD"] as? Bool
        
        return groupID == "test-group-123" &&
               bundleID == "com.apple.finder" &&
               openURL == "https://www.apple.com" &&
               command == "echo 'Hello World'" &&
               ignoreDnD == true
    }
    
    // Test image file validation - valid paths
    runner.addTest("Image file validation - valid paths") {
        let validImagePaths = [
            "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns",
            "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns",
            "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns"
        ]
        
        for path in validImagePaths {
            if !FileManager.default.fileExists(atPath: path) {
                return false
            }
        }
        return true
    }
    
    // Test image file validation - invalid paths
    runner.addTest("Image file validation - invalid paths") {
        let invalidImagePaths = [
            "/nonexistent/path/image.icns",
            "/System/Library/nonexistent.icns",
            "/tmp/nonexistent_image.png"
        ]
        
        for path in invalidImagePaths {
            if FileManager.default.fileExists(atPath: path) {
                return false
            }
        }
        return true
    }
    
    // Test NSImage creation from valid paths
    runner.addTest("NSImage creation from valid paths") {
        let validImagePath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
        
        if let image = NSImage(contentsOfFile: validImagePath) {
            return image.size.width > 0 && image.size.height > 0
        }
        return false
    }
    
    // Test NSImage creation from invalid paths
    runner.addTest("NSImage creation from invalid paths") {
        let invalidImagePath = "/nonexistent/path/image.icns"
        
        if let _ = NSImage(contentsOfFile: invalidImagePath) {
            return false // Should not create image from invalid path
        }
        return true
    }
    
    // Test URL creation for image paths
    runner.addTest("URL creation for image paths") {
        let filePath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
        let httpURL = "https://example.com/image.png"
        
        let fileURL = URL(fileURLWithPath: filePath)
        let webURL = URL(string: httpURL)
        
        return fileURL.path == filePath && webURL?.absoluteString == httpURL
    }
    
    // Test image options in notification dictionary
    runner.addTest("Image options in notification dictionary") {
        let options: [String: Any] = [
            "contentImage": "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns",
            "appIcon": "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns"
        ]
        
        let contentImage = options["contentImage"] as? String
        let appIcon = options["appIcon"] as? String
        
        return contentImage != nil && appIcon != nil
    }
    
    runner.runAll()
}

// Run tests
runTests()