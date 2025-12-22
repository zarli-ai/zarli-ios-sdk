# ZarliSDKSwift

The official iOS SDK for the Zarli Ad Network. Enables mobile publishers to seamlessly integrate high-performance, interactive HTML5 playable ads into their iOS applications to maximize revenue.

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 14.0+

## Installation

### Swift Package Manager

1. In Xcode, navigate to **File > Add Package Dependencies...**
2. Paste the repository URL: `https://github.com/zarli-ai/zarli-ios-sdk.git`
3. Select the `ZarliSDKSwift` library and add it to your target

## Privacy & Compliance

### Apple Privacy Manifest
ZarliSDK includes a `PrivacyInfo.xcprivacy` file that explicitly declares usage of the **Advertising Identifier (IDFA)** for tracking and ad attribution purposes, ensuring compliance with Apple's App Store requirements.

### App Transport Security (ATS)
While the Zarli SDK communicates with ad servers over secure HTTPS, ad creatives delivered by third-party bidders may occasionally require HTTP resources.

To ensure all ads render correctly, add the following to your app's `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

> **Note:** For strict security requirements, configure specific exception domains, though this may limit ad variety.

## Usage

### 1. Initialize the SDK

Initialize the SDK in your `AppDelegate` or application entry point:

```swift
import ZarliSDKSwift

// In application(_:didFinishLaunchingWithOptions:)
let config = ZarliConfiguration(apiKey: "YOUR_API_KEY", isDebugMode: false)
ZarliSDK.shared.initialize(configuration: config) { success in
    // SDK is ready
}
```

### 2. Load and Show an Interstitial Ad

Implement `ZarliInterstitialAdDelegate` to handle ad events:

```swift
import UIKit
import ZarliSDKSwift

class ViewController: UIViewController, ZarliInterstitialAdDelegate {
    
    var interstitialAd: ZarliInterstitialAd?

    func loadAd() {
        interstitialAd = ZarliInterstitialAd(adUnitId: "your-ad-unit-id")
        interstitialAd?.delegate = self
        interstitialAd?.load()
    }
    
    func showAd() {
        if let ad = interstitialAd, ad.isReady {
            ad.show()
        }
    }

    // MARK: - ZarliInterstitialAdDelegate
    
    func adDidLoad(_ ad: ZarliInterstitialAd) {
        // Ad is ready to show
    }
    
    func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        // Handle load failure
    }
    
    func adDidShow(_ ad: ZarliInterstitialAd) {
        // Ad is now on screen
    }
    
    func adDidDismiss(_ ad: ZarliInterstitialAd) {
        // Resume app flow
    }
    
    func adDidClick(_ ad: ZarliInterstitialAd) {
        // User clicked the ad
    }
}
```

## Best Practices

- **Pre-loading**: Call `.load()` well before displaying the ad (e.g., at level start) to ensure zero latency
- **Thread Safety**: All delegate callbacks are dispatched on the main thread, allowing safe UI updates
- **View Controller**: The SDK automatically finds the top-most view controller when calling `show()` without parameters

## API Reference

### ZarliConfiguration
- `apiKey: String` - Your Zarli API key
- `isDebugMode: Bool` - Enable for development (default: false)

### ZarliInterstitialAd
- `init(adUnitId: String)` - Create ad instance
- `load()` - Start loading the ad
- `show()` - Display the ad (auto-detects view controller)
- `show(from: UIViewController)` - Display from specific view controller
- `isReady: Bool` - Check if ad is loaded and ready

## Support

For issues or integration help, please open an issue on [GitHub](https://github.com/zarli-ai/zarli-ios-sdk).

## License

Proprietary - Zarli AI
