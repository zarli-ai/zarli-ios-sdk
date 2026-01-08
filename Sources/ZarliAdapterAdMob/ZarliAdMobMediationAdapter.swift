import Foundation
import GoogleMobileAds
import ZarliSDKSwift

@objc(ZarliAdMobMediationAdapter)
public class ZarliAdMobMediationAdapter: NSObject, MediationAdapter {
    
    // Properties to retain the ads during the loading process
    private var interstitialAd: ZarliAdMobMediationInterstitialAd?
    private var rewardedAd: ZarliAdMobMediationRewardedAd?
    
    public static func adapterVersion() -> VersionNumber {
        let version = VersionNumber(majorVersion: 1, minorVersion: 0, patchVersion: 0)
        return version
    }
    
    public static func adSDKVersion() -> VersionNumber {
        let version = VersionNumber(majorVersion: 1, minorVersion: 0, patchVersion: 0)
        return version
    }
    
    public static func networkExtrasClass() -> AdNetworkExtras.Type? {
        return nil
    }
    
    required public override init() {
        super.init()
    }
    
    public func setUp(with configuration: MediationServerConfiguration, completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock) {
        
        // In this simple implementation, we assume readiness or successful setup.
        // Initialize SDK
        ZarliAdMobMediationAdapter.initializeZarliSDK()
        completionHandler(nil)
    }
    
    public func loadInterstitial(for adConfiguration: MediationInterstitialAdConfiguration, completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
        // Ensure SDK is initialized
        ZarliAdMobMediationAdapter.initializeZarliSDK()
        
        let ad = ZarliAdMobMediationInterstitialAd(configuration: adConfiguration, completionHandler: completionHandler)
        self.interstitialAd = ad // Retain
        ad.loadAd()
    }
    
    public func loadRewardedAd(for adConfiguration: MediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        // Ensure SDK is initialized
        ZarliAdMobMediationAdapter.initializeZarliSDK()
        
        let ad = ZarliAdMobMediationRewardedAd(configuration: adConfiguration, completionHandler: completionHandler)
        self.rewardedAd = ad // Retain
        ad.loadAd()
    }
    
    // Helper to initialize SDK if needed
    private static var isInitialized = false
    internal static func initializeZarliSDK() {
        if isInitialized { return }
        
        // Try to get API Key from Info.plist
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ZarliAPIKey") as? String, !apiKey.isEmpty else {
            print("ZarliAdapter: Warning - ZarliAPIKey not found in Info.plist. Ads may fail to load.")
            return
        }
        
        let config = ZarliConfiguration(apiKey: apiKey)
        ZarliSDK.shared.initialize(configuration: config) { success in
            print("ZarliAdapter: SDK Initialized: \(success)")
            isInitialized = true
        }
    }
}
