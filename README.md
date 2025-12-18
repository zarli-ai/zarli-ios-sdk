# Zarli iOS SDK

Zarli iOS SDK allows mobile publishers to easily integrate interactive HTML5 playable ads into their apps.

## Installation

### Swift Package Manager

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL of this package.
3. Select the `ZarliSDK` library.

## Usage

### 1. Initialize the SDK

In your `AppDelegate` or at app launch:

```swift
import ZarliSDK

ZarliSDK.shared.initialize(apiKey: "YOUR_API_KEY") { success in
    print("Zarli SDK Initialized: \(success)")
}
```

### 2. Load and Show an Interstitial Ad

In your View Controller:

```swift
import UIKit
import ZarliSDK

class ViewController: UIViewController, ZarliInterstitialAdDelegate {
    var interstitialAd: ZarliInterstitialAd?

    func loadAd() {
        // Create an ad instance
        interstitialAd = ZarliInterstitialAd(adUnitId: "demo-ad-unit")
        interstitialAd?.delegate = self
        
        // Load the ad
        interstitialAd?.load()
    }
    
    // Trigger this method to show (e.g., on button tap or game over)
    func showAd() {
        interstitialAd?.show(from: self)
    }

    // MARK: - ZarliInterstitialAdDelegate
    
    func adDidLoad(_ ad: ZarliInterstitialAd) {
        print("Ad loaded successfully")
        // You can show the ad now or later
        showAd()
    }
    
    func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        print("Ad failed to load: \(error)")
    }
    
    func adDidShow(_ ad: ZarliInterstitialAd) {
        print("Ad is being displayed")
    }
    
    func adDidDismiss(_ ad: ZarliInterstitialAd) {
        print("Ad was dismissed")
        // Resume game or app flow
    }
    
    func adDidClick(_ ad: ZarliInterstitialAd) {
        print("User clicked the ad")
    }
}
```
