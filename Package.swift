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
            url: "https://github.com/zarli-ai/zarli-ios-sdk/releases/download/1.3.62/ZarliSDKSwift.xcframework.zip",
            checksum: "b6ec1b293044a7ef82223143f7e4b1b900de4ec4bef03cecafaff4d66bd5367c"
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
