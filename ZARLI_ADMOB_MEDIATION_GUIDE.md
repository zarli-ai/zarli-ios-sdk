# Zarli iOS SDK - AdMob Mediation Integration Guide

This guide details how to integrate the **Zarli iOS SDK** as a **Custom Event** within your existing AdMob setup.

**Goal:** Fill ads using the Zarli network when eCPM >= **$10.00**.

---

## Prerequisites

1.  **Zarli API Key** (provided by your Zarli account manager).
2.  Existing AdMob account and iOS App ID.
3.  Existing iOS project with Google Mobile Ads SDK integrated.

---

## Step 1: Install Zarli iOS SDK

Add the Zarli SDK to your Xcode project using Swift Package Manager (SPM).

1.  In Xcode, go to **File > Add Packages Dependencies...**
2.  Enter the repository URL: `https://github.com/zarli-ai/zarli-ios-sdk`
3.  Select the latest version (e.g., `1.3.11`).
4.  **Important:** Select **both** products to add to your app target:
    -   `ZarliSDKSwift` (Core SDK)
    -   `ZarliAdapterAdMob` (AdMob Mediation Adapter)

---

## Step 2: Configure AdMob Custom Event

Configure a Custom Event in the AdMob UI to prioritize Zarli when the eCPM is high.

1.  Log in to your **AdMob** account.
2.  Navigate to **Mediation** and select your **Mediation Group** (or create a new one).
3.  Under **Ad Sources**, click **Add Custom Event**.
4.  **Label**: Enter `Zarli Interactive Ads`.
5.  **eCPM**: Set strict eCPM to **$10.00**.
    > **Note:** By setting this to $10.00, AdMob will attempt to load an ad from Zarli first. If Zarli fails to load (no bid >= $10), AdMob proceeds to the next source in your waterfall.
6.  Click **Continue**.
7.  **Class Name**: Enter `ZarliAdMobMediationAdapter`.
    > **Important:** This must match the Swift class name exactly.
9.  **Parameter**: Enter the configuration JSON string.
    
    *   `adUnitId`: You can use a **descriptive name** for this ad slot (e.g., "MainMenu_Rewarded", "GameOver_Screen"). This helps identify the request in your Zarli dashboard.
    *   `bidFloor`: Must be `10.0` to enforce the $10 eCPM floor.

    **Copy and paste the following JSON (and customize the ID):**
    ```json
    {"adUnitId": "YOUR_DESCRIPTIVE_NAME", "bidFloor": 10.0}
    ```

    > **⚠️ IMPORTANT:** 
    > *   **Smart Quotes**: Ensure you use straight quotes `"`.
    > *   **Custom ID**: We recommend naming the unit descriptively, e.g., `"FlappyBird_GameOver_Rewarded"`.
    
    *   **Example**: `{"adUnitId": "FlappyBird_GameOver", "bidFloor": 10.0}`

10. Click **Done**.

---

## Troubleshooting

If ads represent not showing or you see errors:

1.  **"Class not found" error**: Double check the **Class Name** in Step 2. It must be exactly `ZarliAdMobMediationAdapter`.
2.  **JSON Parsing Error**: If the logs show JSON errors, verify the **Parameter** field in AdMob. It must be valid JSON.
    *   **Correct**: `{"bidFloor": 10.0}`
    *   **Incorrect**: `{bidFloor: 10.0}` (missing quotes on key)
    *   **Incorrect**: `“bidFloor”: 10.0` (smart quotes)

---

## Step 3: Initialize Zarli SDK

In your `AppDelegate.swift` (or where you initialize AdMob), make sure to initialize the Zarli SDK with your API Key **before** ads are requested.

```swift
import ZarliSDKSwift
import GoogleMobileAds

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 1. Initialize Zarli SDK
    let config = ZarliConfiguration(apiKey: "YOUR_ZARLI_API_KEY")
    ZarliSDK.shared.initialize(configuration: config) { success in
        print("Zarli SDK Initialized: \(success)")
    }

    // 2. Initialize AdMob
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    
    return true
}
```

---

## Step 4: Update Info.plist

Ensure your `Info.plist` includes the Tracking Usage Description if you are using IDFA (recommended for better eCPM).

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

---

## Step 5: Request and Display Ad

Use the standard **AdMob** code to load and show the ad. You do **not** need to call Zarli directly; the AdMob adapter handles it.

```swift
import GoogleMobileAds

class AdsManager: NSObject, GADFullScreenContentDelegate {
    
    var rewardedAd: GADRewardedAd?

    func loadAd() {
        let request = GADRequest()
        // Use your AdMob Ad Unit ID here (NOT the Zarli ID)
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-YOUR_ADMOB_AD_UNIT_ID",
                           request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load ad: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("Ad loaded successfully.")
        }
    }

    func showAd(from viewController: UIViewController) {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: viewController) {
                // User earned reward
                let reward = ad.adReward
                print("Reward: \(reward.amount) \(reward.type)")
            }
        } else {
            print("Ad wasn't ready")
        }
    }
}
```

> **Note**: Replace `"ca-app-pub-YOUR_ADMOB_AD_UNIT_ID"` with your actual AdMob Ad Unit ID. The Zarli Ad Unit ID is **only** used in the AdMob Console (Step 2).

---

## Verification

1.  **Build and Run** your app.
2.  Trigger the Rewarded Ad logic in your app.
3.  **Check Logs**:
    - Look for `ZarliSDK initializing` in the console.
    - When AdMob calls the adapter, the system should automatically use `ZarliAdapterAdMob`.
    - If the eCPM logic works ($10 floor), Zarli will attempt to fetch a bid.
    - **Success case**: `Rewarded Ad loaded successfully`. Ad shows.
    - **Fallback case**: If Zarli cannot bid >= $10, it will fail to load, and AdMob will automatically move to the next network (its own bidding).
