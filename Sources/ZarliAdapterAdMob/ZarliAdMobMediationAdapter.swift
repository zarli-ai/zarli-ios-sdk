import Foundation
import GoogleMobileAds
import ZarliSDKSwift

@objc(ZarliAdMobMediationAdapter)
public class ZarliAdMobMediationAdapter: NSObject, GADMediationAdapter {
    
    // Properties to retain the ads during the loading process
    private var interstitialAd: ZarliAdMobMediationInterstitialAd?
    private var rewardedAd: ZarliAdMobMediationRewardedAd?
    
    public static func adapterVersion() -> GADVersionNumber {
        let version = GADVersionNumber(majorVersion: 1, minorVersion: 0, patchVersion: 0)
        return version
    }
    
    public static func adSDKVersion() -> GADVersionNumber {
        let version = GADVersionNumber(majorVersion: 1, minorVersion: 0, patchVersion: 0)
        return version
    }
    
    public static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
        return nil
    }
    
    required public override init() {
        super.init()
    }
    
    public func setUp(with configuration: GADMediationServerConfiguration, completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock) {
        
        // In this simple implementation, we assume readiness or successful setup.
        completionHandler(nil)
    }
    
    public func loadInterstitial(for adConfiguration: GADMediationInterstitialAdConfiguration, completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
        let ad = ZarliAdMobMediationInterstitialAd(configuration: adConfiguration, completionHandler: completionHandler)
        self.interstitialAd = ad // Retain
        ad.loadAd()
    }
    
    public func loadRewardedAd(for adConfiguration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        let ad = ZarliAdMobMediationRewardedAd(configuration: adConfiguration, completionHandler: completionHandler)
        self.rewardedAd = ad // Retain
        ad.loadAd()
    }
}
