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

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'ZarliSDKSwift', :git => 'https://github.com/zarli-ai/zarli-ios-sdk.git'
```


## Privacy & Compliance

### Apple Privacy Manifest
ZarliSDK includes a `PrivacyInfo.xcprivacy` file that explicitly declares usage of the **Advertising Identifier (IDFA)** for tracking and ad attribution purposes, ensuring compliance with Apple's App Store requirements.

### Info.plist Configuration

To ensure full functionality and compliance, add the following keys to your `Info.plist`:

1. **App Transport Security (ATS)**
   Ad creatives often require resources from non-secure (HTTP) domains.
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoadsInWebContent</key>
       <true/>
   </dict>
   ```

2. **User Tracking Usage Description**
   Required for requesting permission to track the user (IDFA access).
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>This identifier will be used to deliver personalized ads to you.</string>
   ```

## AdMob Mediation

To use Zarli with AdMob mediation, you must import the `ZarliAdapterAdMob` library.

### Swift Package Manager

Add the following to your target dependencies in `Package.swift` or Xcode:

- `ZarliAdapterAdMob`

### AdMob UI Configuration

1. **Class Name**: `ZarliAdapterAdMob.ZarliAdMobMediationAdapter`
2. **Parameter**: Pass your Zarli Ad Unit ID string (optional override).

## Usage

### 1. Initialize the SDK

Initialize the SDK in your `AppDelegate` or application entry point:

```swift
import ZarliSDKSwift
import AppTrackingTransparency // Important for iOS 14+

// In application(_:didFinishLaunchingWithOptions:)
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Request tracking permission (iOS 14+)
    // Note: It is best practice to show a pre-prompt explaining why you need this permission
    if #available(iOS 14, *) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Initialize Zarli SDK regardless of status, but IDFA will only be available if authorized
                self.initializeSDK()
            }
        }
    } else {
        // Fallback for earlier versions
        initializeSDK()
    }
    
    return true
}

func initializeSDK() {
    let config = ZarliConfiguration(apiKey: "YOUR_API_KEY", isDebugMode: false)
    ZarliSDK.shared.initialize(configuration: config) { success in
        print("Zarli SDK Initialized: \(success)")
    }
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

### 3. Load and Show a Rewarded Ad

Implement `ZarliRewardedAdDelegate` to handle ad events and rewards:

```swift
import UIKit
import ZarliSDKSwift

class GameViewController: UIViewController, ZarliRewardedAdDelegate {
    
    var rewardedAd: ZarliRewardedAd?

    func loadAd() {
        rewardedAd = ZarliRewardedAd(adUnitId: "your-rewarded-ad-unit-id")
        rewardedAd?.delegate = self
        rewardedAd?.load()
    }
    
    func showAd() {
        if let ad = rewardedAd, ad.isReady {
            ad.show()
        }
    }

    // MARK: - ZarliRewardedAdDelegate
    
    func adDidLoad(_ ad: ZarliRewardedAd) {
        print("Rewarded Ad Loaded")
    }
    
    func ad(_ ad: ZarliRewardedAd, didFailToLoad error: Error) {
        print("Failed to load: \(error)")
    }
    
    func adDidShow(_ ad: ZarliRewardedAd) {}
    func adDidDismiss(_ ad: ZarliRewardedAd) {}
    func adDidClick(_ ad: ZarliRewardedAd) {}
    
    func ad(_ ad: ZarliRewardedAd, didEarnReward reward: ZarliReward) {
        print("User earned reward: \(reward.amount) \(reward.type)")
        // Grant reward to user
    }
}
```

## Best Practices

### Pre-loading
Call `.load()` well before displaying the ad (e.g., at level start) to ensure zero latency.

```swift
// ✅ Good - Load at level start
override func viewDidLoad() {
    super.viewDidLoad()
    interstitialAd = ZarliInterstitialAd(adUnitId: "level_complete_ad")
    interstitialAd?.delegate = self
    interstitialAd?.load()
}

// ❌ Bad - Load right before showing
func showAd() {
    interstitialAd?.load() // User will wait!
    interstitialAd?.show()
}
```

### Memory Management
The SDK handles internal memory management, but strictly holds a `weak` reference to your delegate. Ensure your view controller persists while the ad is loading.

### Thread Safety
All delegate callbacks are dispatched on the main thread, allowing safe UI updates.

## Troubleshooting

### Ad fails to load
- **Error: Network**: Check your internet connection.
- **Logs**: Enable `isDebugMode: true` in `ZarliConfiguration` to see detailed logs in the console.

### Ad doesn't show
- Ensure `ad.isReady` returns `true`.
- Verify you are calling `show()` from a visible View Controller.
- Check if `NSAppTransportSecurity` is configured correctly in `Info.plist`.

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

MIT License - Copyright (c) 2025 Zarli AI
