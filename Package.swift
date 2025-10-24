// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "terminal-notifier",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "terminal-notifier", targets: ["TerminalNotifier"])
    ],
    targets: [
        .executableTarget(
            name: "TerminalNotifier",
            path: "Sources"
        )
    ]
)