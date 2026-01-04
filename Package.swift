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
        .library(
            name: "ZarliShopifySupport",
            targets: ["ZarliShopifySupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.13.0"),
        .package(url: "https://github.com/Shopify/checkout-sheet-kit-swift", from: "3.0.0"),
    ],
    targets: [
        // 1. The Binary Core SDK
        .binaryTarget(
            name: "ZarliSDKSwift",
            url: "https://github.com/zarli-ai/zarli-ios-sdk/releases/download/1.3.20/ZarliSDKSwift.xcframework.zip",
            checksum: "11a4713731dcf5358c3709d27e8051bfa79bdde905a8dacfc0390cec8db6ca6a"
        ),

        // 2. The Open-Source AdMob Adapter
        .target(
            name: "ZarliAdapterAdMob",
            dependencies: [
                "ZarliSDKSwift",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        ),

        // 3. Shopify Support Module
        .target(
            name: "ZarliShopifySupport",
            dependencies: [
                "ZarliSDKSwift",
                .product(name: "ShopifyCheckoutSheetKit", package: "checkout-sheet-kit-swift")
            ]
        ),
    ]
)
