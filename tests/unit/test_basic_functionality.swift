#!/usr/bin/env swift

import Foundation

// MARK: - Basic Functionality Tests
print("Running Basic Functionality Tests...")
print("====================================")

// Test 1: String operations
print("1. Testing string operations...")
let testString = "Hello, World!"
let reversed = String(testString.reversed())
assert(reversed == "!dlroW ,olleH")
print("✅ String operations")

// Test 2: Array operations
print("2. Testing array operations...")
let testArray = [1, 2, 3, 4, 5]
let sum = testArray.reduce(0, +)
assert(sum == 15)
print("✅ Array operations")

// Test 3: URL validation
print("3. Testing URL validation...")
let validURL = URL(string: "https://example.com")
let invalidURL = URL(string: "not-a-url")
assert(validURL != nil)
// Note: URL(string:) doesn't return nil for invalid URLs, it creates a URL object
// We'll test that the URL has a scheme instead
assert(validURL?.scheme == "https")
assert(invalidURL?.scheme == nil)
print("✅ URL validation")

// Test 4: Dictionary operations
print("4. Testing dictionary operations...")
var testDict: [String: Any] = [:]
testDict["key1"] = "value1"
testDict["key2"] = 42
assert(testDict["key1"] as? String == "value1")
assert(testDict["key2"] as? Int == 42)
print("✅ Dictionary operations")

// Test 5: File operations
print("5. Testing file operations...")
let tempDir = FileManager.default.temporaryDirectory
let tempFile = tempDir.appendingPathComponent("test.txt")
let testData = "test content".data(using: .utf8)!
try? testData.write(to: tempFile)
let fileExists = FileManager.default.fileExists(atPath: tempFile.path)
assert(fileExists)
try? FileManager.default.removeItem(at: tempFile)
print("✅ File operations")

print("\nAll basic functionality tests passed! 🎉")