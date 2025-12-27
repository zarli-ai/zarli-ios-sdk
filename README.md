# Zarli iOS SDK

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

### Info.plist Configuration

To ensure full functionality and compliance, add the following keys to your `Info.plist`:

1. **App Transport Security (ATS)**: Ad creatives often require resources from non-secure (HTTP) domains.
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoadsInWebContent</key>
       <true/>
   </dict>
   ```

2. **User Tracking Usage Description**: Required for requesting permission to track the user (IDFA access).
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>This identifier will be used to deliver personalized ads to you.</string>
   ```

## Usage

### 1. Initialize the SDK

Initialize the SDK in your `AppDelegate` or application entry point:

```swift
import ZarliSDKSwift
import AppTrackingTransparency // Important for iOS 14+

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Initialize with your API Key (optional debug mode)
    let config = ZarliConfiguration(apiKey: "YOUR_API_KEY", isDebugMode: true)
    
    if #available(iOS 14, *) {
        // Best practice: Wait a moment or show a pre-prompt before requesting IDFA
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Initialize after permission result so IDFA is captured if allowed
                ZarliSDK.shared.initialize(configuration: config) { success in
                    print("Zarli SDK Initialized: \(success)")
                }
            }
        }
    } else {
        ZarliSDK.shared.initialize(configuration: config) { success in
            print("Zarli SDK Initialized: \(success)")
        }
    }
    
    return true
}
```

### 2. Interstitial Ads

Use `ZarliInterstitialAd` to load and show full-screen ads.

```swift
import UIKit
import ZarliSDKSwift

class ViewController: UIViewController, ZarliInterstitialAdDelegate {
    
    var interstitialAd: ZarliInterstitialAd?

    func loadAd() {
        // 1. Create instance
        interstitialAd = ZarliInterstitialAd(adUnitId: "YOUR_AD_UNIT_ID")
        
        // 2. Set delegate
        interstitialAd?.delegate = self
        
        // 3. Load
        interstitialAd?.load()
    }
    
    func showAd() {
        // 4. Show if ready
        if let ad = interstitialAd, ad.isReady {
            ad.show(from: self)
        } else {
            print("Ad not ready yet")
        }
    }

    // MARK: - ZarliInterstitialAdDelegate
    
    func adDidLoad(_ ad: ZarliInterstitialAd) {
        print("Ad Loaded!")
    }
    
    func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        print("Ad Failed to Load: \(error)")
    }
    
    func adDidShow(_ ad: ZarliInterstitialAd) { print("Ad Shown") }
    func adDidDismiss(_ ad: ZarliInterstitialAd) { print("Ad Dismissed") }
    func adDidClick(_ ad: ZarliInterstitialAd) { print("Ad Clicked") }
}
```

### 3. Rewarded Ads

Use `ZarliRewardedAd` to reward users for watching ads.

```swift
import UIKit
import ZarliSDKSwift

class GameViewController: UIViewController, ZarliRewardedAdDelegate {
    
    var rewardedAd: ZarliRewardedAd?

    func loadRewardedAd() {
        rewardedAd = ZarliRewardedAd(adUnitId: "YOUR_REWARDED_UNIT_ID")
        rewardedAd?.delegate = self
        rewardedAd?.load()
    }
    
    func showRewardedAd() {
        if let ad = rewardedAd, ad.isReady {
            ad.show(from: self)
        }
    }

    // MARK: - ZarliRewardedAdDelegate
    
    func adDidLoad(_ ad: ZarliRewardedAd) {
        print("Rewarded Ad Loaded")
    }
    
    func ad(_ ad: ZarliRewardedAd, didEarnReward reward: ZarliReward) {
        print("User earned reward: \(reward.amount) \(reward.type)")
        // Code to grant coins/lives/gems to user
    }
    
    func ad(_ ad: ZarliRewardedAd, didFailToLoad error: Error) { print("Failed: \(error)") }
    func adDidShow(_ ad: ZarliRewardedAd) { print("Shown") }
    func adDidDismiss(_ ad: ZarliRewardedAd) { print("Dismissed") }
    func adDidClick(_ ad: ZarliRewardedAd) { print("Clicked") }
}
```

## AdMob Mediation

To use Zarli with AdMob mediation, include the `ZarliAdapterAdMob` library provided in this package.

1.  Add `ZarliAdapterAdMob` to your target dependencies.
2.  Configure Custom Event in AdMob UI:
    *   **Class Name**: `ZarliAdapterAdMob.ZarliAdMobMediationAdapter`
    *   **Parameter**: Pass your Zarli Ad Unit ID string.

## Author
Zarli AI
