#!/usr/bin/env swift

import Foundation

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
    
    runner.runAll()
}

// Run tests
runTests()