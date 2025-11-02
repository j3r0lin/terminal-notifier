import Foundation

// MARK: - Global Constants
var DEBUG_MODE = false

// MARK: - Helper Functions

/// Print debug message to stderr
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if DEBUG_MODE {
        let message = items.map { "\($0)" }.joined(separator: separator)
        FileHandle.standardError.write((message + terminator).data(using: .utf8) ?? Data())
    }
}

/// Print error message to stderr
func errorPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let message = items.map { "\($0)" }.joined(separator: separator)
    FileHandle.standardError.write((message + terminator).data(using: .utf8) ?? Data())
}