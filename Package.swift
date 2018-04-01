// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YoudaoCLI-Swift",
    dependencies: [
        .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "4.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/kiliankoe/CLISpinner", from: "0.3.5"),
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "YoudaoCLI-Swift",
            dependencies: ["YoudaoCLI-SwiftCore"]),
        .target(name: "YoudaoCLI-SwiftCore",
            dependencies: ["Kanna", "Rainbow", "CLISpinner", "Files"]),
        .testTarget(
            name: "YoudaoCLI-SwiftTests",
            dependencies: ["YoudaoCLI-SwiftCore"]
        ),
    ]
)
