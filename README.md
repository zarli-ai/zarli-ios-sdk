# Zarli iOS SDK

The official iOS SDK for the Zarli Ad Network. Enables mobile publishers to seamlessly integrate high-performance, interactive HTML5 playable ads into their iOS applications to maximize revenue.

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 14.0+

## Installation

Zarli iOS SDK supports both **Swift Package Manager (SPM)** and **CocoaPods**. Choose the method that best fits your project.

### Choosing Your Installation Method

| Method | Best For | Requirements | Status |
|--------|----------|--------------|--------|
| **Swift Package Manager** | New projects, future-proofing | Xcode 14.0+, iOS 13.0+ | ✅ Recommended |
| **CocoaPods** | Existing CocoaPods projects | CocoaPods 1.10+ | ✅ Supported (until Dec 2026) |

> [!TIP]
> **For new projects**, we recommend Swift Package Manager as Apple's native dependency manager. CocoaPods will become read-only in December 2026.

---

### Swift Package Manager (Recommended)

#### Installing Core SDK

1. In Xcode, navigate to **File > Add Package Dependencies...**
2. Paste the repository URL:
   ```
   https://github.com/zarli-ai/zarli-ios-sdk.git
   ```
3. Select version rule (e.g., "Up to Next Major Version" with `1.3.33`)
4. Select the **`ZarliSDKSwift`** library
5. Click **Add Package**

#### Installing with AdMob Mediation

If you're using AdMob mediation, also add the adapter:

1. After adding the package, select **`ZarliAdapterAdMob`** library in addition to `ZarliSDKSwift`
2. The adapter will automatically include Google Mobile Ads SDK as a dependency

**Package Products:**
- `ZarliSDKSwift` - Core SDK (required)
- `ZarliAdapterAdMob` - AdMob mediation adapter (optional)
- `ZarliShopifySupport` - Shopify integration (optional)

---

### CocoaPods

Add to your `Podfile`:

```ruby
# Core SDK only
pod 'ZarliSDKSwift', '~> 1.3'

# With AdMob Mediation
pod 'ZarliAdapterAdMob', '~> 1.3'
```

Then run:
```bash
pod install
```

---

### Flutter Integration

#### For Flutter 3.24+ (Recommended: SPM)

Flutter 3.24+ supports Swift Package Manager natively. This is the recommended approach for new Flutter projects.

1. **Enable SPM in Flutter:**
   ```bash
   flutter config --enable-swift-package-manager
   ```

2. **Add the Zarli Flutter plugin** to `pubspec.yaml`:
   ```yaml
   dependencies:
     zarli_flutter: ^0.0.1
   ```

3. **Add native iOS dependencies via SPM:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Navigate to **File > Add Package Dependencies...**
   - Add `https://github.com/zarli-ai/zarli-ios-sdk.git`
   - Select `ZarliAdapterAdMob` library

4. **Run your Flutter app:**
   ```bash
   flutter pub get
   flutter run
   ```

#### For Flutter < 3.24 (CocoaPods)

The Zarli Flutter plugin automatically includes CocoaPods dependencies. Simply add to `pubspec.yaml`:

```yaml
dependencies:
  zarli_flutter: ^0.0.1
```

Then run:
```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

> [!NOTE]
> The Flutter plugin's podspec automatically declares the dependency on `ZarliAdapterAdMob`, so you don't need to modify your Podfile manually.

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
   <string>This identifier will be used to deliver personalized content to you.</string>
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

Zarli integrates seamlessly with Google AdMob as a custom mediation adapter. This allows you to serve Zarli ads through your existing AdMob waterfall.

### Installation

Choose the method that matches your project setup:

#### Swift Package Manager

If you installed via SPM, ensure you've added the **`ZarliAdapterAdMob`** library:

1. In Xcode, go to your project settings
2. Select your app target > **General** > **Frameworks, Libraries, and Embedded Content**
3. Verify `ZarliAdapterAdMob` is listed
4. If not, add the package again and select `ZarliAdapterAdMob` library

The adapter automatically includes:
- `ZarliSDKSwift` (Core SDK)
- `GoogleMobileAds` (AdMob SDK v11.0+)

#### CocoaPods

Add to your `Podfile`:

```ruby
pod 'ZarliAdapterAdMob', '~> 1.3'
```

Then run:
```bash
pod install
```

### AdMob Dashboard Configuration

1. **Log in to AdMob Console**: [https://apps.admob.com](https://apps.admob.com)

2. **Create a Mediation Group** (or edit existing):
   - Navigate to **Mediation** > **Create Mediation Group**
   - Select your ad format (Interstitial or Rewarded)
   - Select your ad unit

3. **Add Custom Event**:
   - Click **Add Custom Event**
   - **Class Name**: `ZarliAdapterAdMob.ZarliAdMobMediationAdapter`
   - **Parameter**: Your Zarli Ad Unit ID (e.g., `"your-zarli-ad-unit-id"`)

4. **Set eCPM** for waterfall positioning

5. **Save** the mediation group

### Code Implementation

Initialize the Zarli SDK in your `AppDelegate`:

```swift
import ZarliSDKSwift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize Zarli SDK
    let config = ZarliConfiguration(apiKey: "YOUR_ZARLI_API_KEY")
    ZarliSDK.shared.initialize(configuration: config) { success in
        print("Zarli SDK initialized: \(success)")
    }
    
    // Initialize AdMob
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    
    return true
}
```

Then use AdMob's standard APIs to load and show ads. The adapter will automatically serve Zarli ads when selected by the mediation waterfall.

### Troubleshooting

**Adapter not found:**
- Verify `ZarliAdapterAdMob` is added to your target
- Clean build folder (Cmd+Shift+K) and rebuild
- For SPM: Check Package Dependencies in Xcode project settings

**Ads not serving:**
- Verify Zarli SDK is initialized before AdMob requests ads
- Check AdMob mediation waterfall eCPM settings
- Verify Zarli Ad Unit ID is correct in AdMob custom event parameter
- Enable debug mode: `ZarliConfiguration(apiKey: "...", isDebugMode: true)`

## Author
Zarli AI
