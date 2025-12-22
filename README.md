# ZarliSDKSwift

ZarliSDKSwift enables mobile publishers to seamlessly integrate high-performance, interactive HTML5 playable ads into their iOS applications. Designed for reliability and ease of use, it connects your app to the Zarli Ad Network to maximize revenue.

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 14.0+

## Installation

### Swift Package Manager

1. In Xcode, navigate to **File > Add Package Dependencies...**
2. Paste the repository URL: `https://github.com/zarli-ai/zarli-ios-sdk.git`
3. Select the `ZarliSDKSwift` library and add it to your target.

## Privacy & Compliance

### Apple Privacy Manifest
ZarliSDK includes a `PrivacyInfo.xcprivacy` file that explicitly declares usage of the **Advertising Identifier (IDFA)** for tracking and ad attribution purposes. This ensures compliance with Apple's privacy guidelines given current App Store requirements.

### App Transport Security (ATS)
While the Zarli SDK communicates with its ad servers over secure HTTPS, the *ad creatives* (interactive HTML5 ads) delivered by third-party bidders may occasionally require HTTP resources or use older protocols.

To ensure all ads render correctly, we recommend adding the following exception to your app's `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

> **Note:** If strict security is required, you may configure specific exception domains, but this may limit the variety of ads available to your app.

## Usage

### 1. Initialize the SDK

Initialize the SDK in your `AppDelegate` or at the entry point of your application.

```swift
import ZarliSDKSwift

// ... in application(_:didFinishLaunchingWithOptions:)

// For production:
ZarliSDK.shared.initialize(apiKey: "YOUR_API_KEY") { success in
    // SDK is ready
}

// For development/debugging (enables verbose logs):
ZarliSDK.shared.initialize(apiKey: "YOUR_API_KEY", isDebugMode: true) { success in
    print("Zarli SDK initialized")
}
```

### 2. Load and Show an Interstitial Ad

Implement `ZarliInterstitialAdDelegate` in your View Controller to handle ad events.

```swift
import UIKit
import ZarliSDKSwift

class ViewController: UIViewController, ZarliInterstitialAdDelegate {
    
    var interstitialAd: ZarliInterstitialAd?

    func loadAd() {
        // Initialize with your Ad Unit ID
        interstitialAd = ZarliInterstitialAd(adUnitId: "demo-ad-unit")
        interstitialAd?.delegate = self
        
        // Start loading the ad
        interstitialAd?.load()
    }
    
    func showAd() {
        // Display the ad over the current view controller
        interstitialAd?.show(from: self)
    }

    // MARK: - ZarliInterstitialAdDelegate
    
    func adDidLoad(_ ad: ZarliInterstitialAd) {
        print("Ad Loaded! You can now call showAd()")
        // e.g., Enable the 'Show Ad' button
    }
    
    func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        print("Ad failed to load: \(error.localizedDescription)")
    }
    
    func adDidShow(_ ad: ZarliInterstitialAd) {
        print("Ad is now on screen")
    }
    
    func adDidDismiss(_ ad: ZarliInterstitialAd) {
        print("Ad dismissed. Resume game/app flow.")
    }
    
    func adDidClick(_ ad: ZarliInterstitialAd) {
        print("User clicked on the ad")
    }
}
```

## Best Practices

- **Pre-loading**: Call `.load()` well before you intend to show the ad (e.g., at the start of a level) to ensure zero latency when the user triggers it.
- **Main Thread**: The SDK handles background threading for network requests, but ensures delegate callbacks are dispatched on the **Main Thread**, so you can safely update your UI directly in the delegate methods.

## Support

For issues, feature requests, or integration help, please open an issue on GitHub.
