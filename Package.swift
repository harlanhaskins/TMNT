// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMNT",
    dependencies: [
        .package(url: "https://github.com/harlanhaskins/CMUDict.git", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "TMNT",
            dependencies: [
                "CMUDict"
            ]
        ),
    ]
)
