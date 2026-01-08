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
            url: "https://github.com/zarli-ai/zarli-ios-sdk/releases/download/1.3.25/ZarliSDKSwift.xcframework.zip",
            checksum: "fe3a4a752adff3664dea49d80a5fc95b51540c65c361e073f65b8f852db1c4a8"
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
