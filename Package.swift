// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZarliSDKSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZarliSDKSwift",
            targets: ["ZarliSDKSwift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZarliSDKSwift",
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [
                // Optimize for size in release builds
                .unsafeFlags(["-Osize"], .when(configuration: .release)),
                // Enable link-time optimization
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
            ]
        ),
        .testTarget(
            name: "ZarliSDKSwiftTests",
            dependencies: ["ZarliSDKSwift"]),
    ]
)
