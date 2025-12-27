# Zarli iOS SDK

The **Zarli iOS SDK** enables publishers to monetize their iOS apps with video and interstitial ads.

## Installation

### Swift Package Manager (SPM)

1.  In Xcode, navigate to **File > Add Package Dependencies...**
2.  Paste the repository URL: `https://github.com/zarli-ai/zarli-ios-sdk`
3.  Select the version you want to install.

## Usage

### Privacy Manifest
Scale ads with confidence. The SDK includes a `PrivacyInfo.xcprivacy` manifest to comply with Apple's privacy requirements.

### Interstitial Ads

Import the SDK and load an ad using your Ad Unit ID.

```swift
import ZarliSDKSwift

// Load an interstitial ad
ZarliInterstitialAd.load(adUnitId: "YOUR_AD_UNIT_ID") { result in
    switch result {
    case .success(let ad):
        // Show the ad from your view controller
        ad.show(from: self) {
            print("Ad finished/dismissed")
        }
    case .failure(let error):
        print("Failed to load ad: \(error)")
    }
}
```

For more details, check the [Examples](Examples/) folder.

## AdMob Mediation

If you use AdMob Mediation, include the `ZarliAdapterAdMob` library provided in this package.

## Author
Zarli AI
