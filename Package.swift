// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZarliSDKSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZarliSDKSwift",
            targets: ["ZarliSDKSwift"]),
        .library(
            name: "ZarliAdapterAdMob",
            targets: ["ZarliAdapterAdMob"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.13.0"),
    ],
    targets: [
        // 1. The Binary Core SDK
        // TODO: Replace 'url' and 'checksum' with your actual GitHub Release values.
        .binaryTarget(
            name: "ZarliSDKSwift",
            url: "https://github.com/zarli-ai/zarli-ios-sdk/releases/download/v1.3.3/ZarliSDKSwift.xcframework.zip",
            checksum: "a4625356fc4e2dae02eea6cd941378b003a88ef49f17c39a2f309551deebee46" 
        ),

        // 2. The Open-Source AdMob Adapter
        .target(
            name: "ZarliAdapterAdMob",
            dependencies: [
                "ZarliSDKSwift",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        ),
    ]
)
