// swift-tools-version: 5.9
// This is a Skip (https://skip.tools) package,
// containing a Swift Package Manager project
// that will use the Skip build plugin to transpile the
// Swift Package, Sources, and Tests into an
// Android Gradle Project with Kotlin sources and JUnit tests.
import PackageDescription
import Foundation

// Set SKIP_ZERO=flase to build without Skip libraries
let hasSkip: Bool = ProcessInfo.processInfo.environment["SKIP_ON"] == "false"

let package: Package

if hasSkip {
    package = Package(
        name: "project-name",
        defaultLocalization: "en",
        platforms: [.iOS(.v17), .macOS(.v13), .macCatalyst(.v16)],
        products: [
            .library(name: "code_wordApp", type: .dynamic, targets: ["code_word"]),
        ],
        dependencies: [
            .package(url: "https://source.skip.tools/skip.git", from: "1.1.8"),
            .package(url: "https://source.skip.tools/skip-ui.git", from: "1.12.0")
        ],
        targets: [
            .target(name: "code_word", dependencies: [.product(name: "SkipUI", package: "skip-ui")], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
            .testTarget(name: "code_wordTests", dependencies: ["code_word", .product(name: "SkipTest", package: "skip")], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        ]
    )
} else {
    package = Package(
        name: "project-name",
        defaultLocalization: "en",
        platforms: [.iOS(.v17), .macOS(.v13), .macCatalyst(.v16)],
        products: [
            .library(name: "code_wordApp", type: .dynamic, targets: ["code_word"]),
        ],
        dependencies: [],
        targets: [
            .target(
                name: "code_word",
                dependencies: [],
                resources: [.process("Resources")],
                plugins: []
            ),
        ]
    )
}
